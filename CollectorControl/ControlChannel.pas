unit ControlChannel;

interface

uses
  System.Classes, System.SysUtils, WinApi.Windows, WinApi.Messages,
  System.SyncObjs, WinApi.Winsock, CustomThread, BaseSocketThread,
  FileLogger, BaseSocketServer, System.Generics.Collections,
  System.Threading;

type
  TControlChannel = class(TBaseSocketServer)
  private
    class var FControlChanel: TControlChannel;
    FConnectEvent: THandle;
    FShutdownEvent: THandle;
    FMessages: TDictionary<Integer, String>;
    FProcesses: TDictionary<Integer, Integer>;
    procedure SendConnectInfo(ASocket: TSocket; AMsgSrcID: Integer);
    procedure SendShutDownInfo(ASocket: TSocket; AMsgSrcID: Integer);
  protected
    procedure ServiceConnection(AAcceptSocket: TSocket; AConnectingIP: String); override;
  public
    constructor Create(AHost: String; APort: WORD; AProtocol: Integer = IPPROTO_TCP); override;
    destructor Destroy; override;
    function ConnectToLEA(ACollectorExe: String; ALEAConfigFile: String; AMsgSrcID: Integer; AFileId: Integer; AFilePosition: Integer; AIsAudit: Boolean): Boolean;
    function StartCollection(AMsgSrcID: Integer; AReceiverHost: String; AReceiverPort: WORD): Boolean;
    function StopCollection(AMsgSrcID: Integer): Boolean;
    class property ControlChanel: TControlChannel read FControlChanel write FControlChanel;
  end;

implementation

constructor TControlChannel.Create(AHost: String; APort: WORD; AProtocol: Integer = IPPROTO_TCP);
begin
  inherited Create(AHost, APort, AProtocol);
  FConnectEvent := CreateEvent(nil, TRUE, FALSE, nil);
  FShutdownEvent := CreateEvent(nil, TRUE, FALSE, nil);
  FMessages := TDictionary<Integer, String>.Create;
  FProcesses := TDictionary<Integer, Integer>.Create;
end;

destructor TControlChannel.Destroy;
begin
  FMessages.Free;
  FProcesses.Free;
  CloseHandle(FConnectEvent);
  CloseHandle(FShutdownEvent);
  inherited Destroy;
end;

procedure TControlChannel.SendConnectInfo(ASocket: TSocket; AMsgSrcID: Integer);
var
  LMyData: TArray<String>;
  LMsg: String;
begin
  MonitorEnter(FMessages);
  try
    if FMessages.ContainsKey(AMsgSrcID) then
    begin
      LMyData := FMessages[AMsgSrcID].Split([':']);
      FMessages.Remove(AMsgSrcID);
      LMsg := String.Format('DataChannel:%s:%d', [LMyData[0], StrToInt(LMyData[1])]);
      TBaseSocketServer.SendTransmission(ASocket, LMsg);
      if ('ACK' <> TBaseSocketServer.ReceiveTransmission(ASocket)) then
      begin
        raise Exception.Create('Connect transmission not acknowledged');
      end;
    end;
  finally
    MonitorExit(FMessages);
  end;
end;

procedure TControlChannel.SendShutDownInfo(ASocket: TSocket; AMsgSrcID: Integer);
var
  LMsg: String;
begin
  MonitorEnter(FMessages);
  try
    if FMessages.ContainsKey(AMsgSrcID) then
    begin
      LMsg := FMessages[AMsgSrcID];
      FMessages.Remove(AMsgSrcID);
      TBaseSocketServer.SendTransmission(ASocket, LMsg);
      if ('ACK' <> TBaseSocketServer.ReceiveTransmission(ASocket)) then
      begin
        raise Exception.Create('ShutDown transmission not acknowledged');
      end;
    end;
  finally
    MonitorExit(FMessages);
  end;
end;

procedure TControlChannel.ServiceConnection(AAcceptSocket: TSocket; AConnectingIP: String);
var
  LMsgSrcID: Integer;
  LKeepReceiving: Boolean;
  LReceivedString: String;
  LTxtStrings, LSplit: TArray<String>;
  LEvents: array[0..1] of THandle;
  LWaitObject: Cardinal;
begin
  LMsgSrcID := 0;
  //Do intial handshake with collector
  //and obtain it's MsgSourceID
  TBaseSocketServer.SendTransmission(AAcceptSocket, 'Agent initiating connection');

  LKeepReceiving := TRUE;
  repeat
    try
      LReceivedString := TBaseSocketServer.ReceiveTransmission(AAcceptSocket);
      LogInfo(LreceivedString);
      LTxtStrings := TBaseSocketServer.GetTransmissionStrings(LReceivedString);
      if (Length(LTxtStrings) >= 1) then
      begin
        if (0 = LTxtStrings[0].IndexOf('MsgSrcID=')) then
        begin
          LSplit := LTxtStrings[0].Split(['=']);
          LMsgSrcID := StrToInt(LSplit[1]);
        end;
      end;

      //At this point the thread has it's message source ID.
      //So now we go into the wait loop

      LEvents[0] := FConnectEvent;
      LEvents[1] := FShutdownEvent;
      while (true) do
      begin
        LWaitObject := WaitForMultipleObjects(2, @LEvents, FALSE, INFINITE);
        case (LWaitObject - WAIT_OBJECT_0) of
        0:begin
            ResetEvent(FConnectEvent);
            SendConnectInfo(AAcceptSocket, LMsgSrcID)
          end;
        1:begin
            ResetEvent(FShutdownEvent);
            SendShutDownInfo(AAcceptSocket, LMsgSrcID);
          end;
        end;
      end;
    except
      on Ex:Exception do
      begin
         LogDebug(String.Format('Execption in Receive Loop: %s', [Ex.Message]));
         LKeepReceiving := false;
         if FProcesses.ContainsKey(LMsgSrcID) then
           FProcesses.Remove(LMsgSrcID);
      end;
    end;
  until (not LKeepReceiving);
end;


function TControlChannel.ConnectToLEA(ACollectorExe: String; ALEAConfigFile: String; AMsgSrcID: Integer; AFileId: Integer; AFilePosition: Integer; AIsAudit: Boolean): Boolean;
var
  LCollectorTask: ITask;
  LCommandLine: string;
  LStartInfo: TStartupInfo;
  LProcInfo: TProcessInformation;
begin
  Result := FALSE;

  if (AIsAudit) then
    LCommandLine := '"' + ACollectorExe + '" -cf "' + ALEAConfigFile + '" ' + String.Format('-host %s -port %d -m %d -f %d -p %d -audit', [FHost, FPort, AMsgSrcID, AFileID, AFilePosition])
  else
    LCommandLine := '"' + ACollectorExe + '" -cf "' + ALEAConfigFile + '" ' + String.Format('-host %s -port %d -m %d -f %d -p %d', [FHost, FPort, AMsgSrcID, AFileID, AFilePosition]);

  if ( not FProcesses.ContainsKey(AMsgSrcID) ) then
  begin
    LCollectorTask := TTask.Run(
    procedure
    const
      BUFF_SIZE = 4096;
    var
      si: TStartupInfo;
      pi: TProcessInformation;
      LCmdLine: String;
    begin
      FillChar(si, SizeOf(TStartupInfo), 0);
      FillChar(pi, SizeOf(TProcessInformation), 0);

      LCmdLine := LCommandLine;
      LogInfo(String.Format('Using Command Line: %s', [LCmdLine]));
      if CreateProcess(nil, PChar(LCmdLine), nil, nil, FALSE, NORMAL_PRIORITY_CLASS, nil, nil, si, pi) then
      begin
        FProcesses.AddOrSetValue(AMsgSrcID, LProcInfo.dwProcessId);
        CloseHandle( pi.hProcess );
        CloseHandle( pi.hThread );
      end;
    end
    );

    EXIT;

    FillChar(LStartInfo, SizeOf(TStartupInfo), 0);
    FillChar(LProcInfo, SizeOf(TProcessInformation), 0);
    LStartInfo.cb := SizeOf(TStartupInfo);
    if (AIsAudit) then
      LCommandLine := '"' + ACollectorExe + '" -cf "' + ALEAConfigFile + '" ' + String.Format('-host %s -port %d -m %d -f %d -p %d -audit', [FHost, FPort, AMsgSrcID, AFileID, AFilePosition])
    else
      LCommandLine := '"' + ACollectorExe + '" -cf "' + ALEAConfigFile + '" ' + String.Format('-host %s -port %d -m %d -f %d -p %d', [FHost, FPort, AMsgSrcID, AFileID, AFilePosition]);
    LogInfo(String.Format('Using Command Line: %s', [LCommandLine]));
    if CreateProcess(nil, PChar(LCommandLine), nil, nil,False, CREATE_NEW_PROCESS_GROUP + NORMAL_PRIORITY_CLASS, nil, nil, LStartInfo, LProcInfo) then
    begin
      FProcesses.AddOrSetValue(AMsgSrcID, LProcInfo.dwProcessId);
      Result := TRUE;
    end;
  end;
end;

function TControlChannel.StartCollection(AMsgSrcID: Integer; AReceiverHost: String; AReceiverPort: WORD): Boolean;
begin
 Result := FALSE;
 if not FMessages.ContainsKey(AMsgSrcID) then
  begin
    FMessages.Add(AMsgSrcID, String.Format('%s:%d', [AReceiverHost, AReceiverPort]) );
    SetEvent(FConnectEvent);
    Result := TRUE;
  end;
end;

function TControlChannel.StopCollection(AMsgSrcID: Integer): Boolean;
begin
  Result := FALSE;
  if not FMessages.ContainsKey(AMsgSrcID) then
  begin
    FMessages.Add(AMsgSrcID, 'Terminate');
    SetEvent(FShutdownEvent);
    Result := TRUE;
  end;
end;

end.
