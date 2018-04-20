{*******************************************************}
{                                                       }
{      Copyright(c) 2003-2016 Oamaru Group , Inc.       }
{                                                       }
{   Copyright and license exceptions noted in source    }
{                                                       }
{*******************************************************}
unit BaseSocketServer;

interface

uses
  System.Classes, System.SysUtils, WinApi.Windows, WinApi.Messages,
  AnsiStrings, System.SyncObjs, WinApi.Winsock, CustomThread,
  BaseSocketThread, FileLogger, IdWship6;

type
  PThreadArguments = ^TThreadArguments;

  TEncodingHelper = class(TEncoding)
  public
    function GetString(Bytes: PByte; ByteCount: Integer): String;
  end;

  TBaseSocketServer = class(TBaseSocketThread)
    protected
      { Protected declarations }
      procedure ServiceConnection(AAcceptSocket: TSocket; AConnectingIP: String); virtual; abstract;
      function OnThreadExecute: Boolean; override;
      class function GetTransmissionStrings(ATxString: String):TArray<string> ;
      class function ReceiveTransmission(ASocket: TSocket): String;
      class function SendTransmission(ASocket: TSocket; AMessage: String): Integer;
    public
      { Public declarations }
  end;

  TThreadArguments = record
    MyServerThread: TBaseSocketServer;
    ConnectingIP: String[100];
    Sock: TSocket;
  end;

implementation

function TEncodingHelper.GetString(Bytes: PByte; ByteCount: Integer): String;
begin
  try
    SetLength(Result, GetCharCount(Bytes, ByteCount));
    GetChars(Bytes, ByteCount, PChar(Result), Length(Result));
  except
  end;
end;

function _ServiceConnection(const AArgs: PThreadArguments): Integer;
begin
  AArgs^.MyServerThread.ServiceConnection(AArgs^.Sock, String(AArgs^.ConnectingIP));
  EndThread(0);
	Result := 0;
end;

function TBaseSocketServer.OnThreadExecute: Boolean;
var
  LAddr: TSockAddrIn;
  LErr: DWORD;
  LErrorCode: Integer;
  LNewThreadID: TThreadID;
  LAcceptSocket: TSocket;
  LArgs: TThreadArguments;
  LLinger: TLinger;
  LConnectingAddr: TSockAddr;
  LSizeOf: Integer;
begin
  LAddr.sin_family := AF_INET;      // Address family
  LAddr.sin_port := htons(FPort);   // Assign port to this socket
  LAddr.sin_addr.s_addr := FIP;

  if SOCKET_ERROR = Bind(FSocket, LAddr, sizeof(LAddr)) then
  begin
    LErr := WSAGetLastError();
    LogFatal(Format('Server Bind Failed. Error Code: %d. %s', [LErr, SysErrorMessage(LErr)]));
    Result := FALSE;
    EXIT;
  end;

  LErrorCode := Listen(FSocket, SOMAXCONN);
  if SOCKET_ERROR = LErrorCode then
  begin
    LErr := WSAGetLastError();
    LogFatal(Format('Listen Failed. Error Code: %d. %s', [LErr, SysErrorMessage(LErr)]));
    Result := FALSE;
    EXIT;
  end;

  LogDebug(Format('Server Bound to Socket And Listening on %s:%d. Waiting For Connections.', [FHost, FPort]));
  while (not Terminated) do
  begin
    LogDebug('Calling Accept');
    LSizeOf := SizeOf(TSockAddr);
    LAcceptSocket := Accept(FSocket, @LConnectingAddr, @LSizeOf);
    LogDebug('Accept Returned');
    if INVALID_SOCKET <> LAcceptSocket then
    begin
      LogDebug('Accepted connection');

      LLinger.l_onoff := 1;
      LLinger.l_linger := 30;
      SetSockOpt(LAcceptSocket, SOL_SOCKET, SO_LINGER, PAnsiChar(@LLinger), sizeof(LLinger));

      LArgs.MyServerThread := Self;
      LArgs.ConnectingIP := ShortString(inet_ntoa(LConnectingAddr.sin_addr));
      LArgs.sock := LAcceptSocket;
      LogDebug('Begin Thread');
      BeginThread(nil, 0, @_ServiceConnection, Pointer(@LArgs), 0, LNewThreadID);
      LogDebug('Service Thread Created');
      if WAIT_OBJECT_0 = WaitForSingleObject(FStopRequested, 0) then
      begin
        LogDebug('Stop Requested for Server Thread');
        if INVALID_SOCKET <> LAcceptSocket then
          CloseSocket(LAcceptSocket);
        BREAK;
      end;
    end
    else
    begin
      LErr := WSAGetLastError();
      if not ((10004 = LErr) and (WAIT_OBJECT_0 = WaitForSingleObject(FShouldFinishEvent, 0))) then
        LogError(Format('Accept returned invalid socket. Error Code: %d. %s', [LErr, SysErrorMessage(LErr)]));
    end;
    if WAIT_OBJECT_0 = WaitForSingleObject(FShouldFinishEvent, 0) then
    begin
      LogDebug('ShouldFinish Event signalled for thread');
      BREAK;
    end;
  end;
  LogDebug('Exit thread. Signal finished.');
  SetEvent(FFinishedEvent);
  Result := TRUE;
end;

class function TBaseSocketServer.GetTransmissionStrings(ATxString: String):TArray<string> ;
begin
  Result := ATxString.Split([Char($03)]);
end;

class function TBaseSocketServer.ReceiveTransmission(ASocket: TSocket): String;
const
  BUFF_SIZE = 65536;
var
  LBuff: array[0..(BUFF_SIZE -1)] of Byte;
  LLastByte: Byte;
  LReceivedString: String;
  LBytesReceived: Integer;
  LZeroOut: Boolean;
begin
  LReceivedString := String.Empty;
  LLastByte := 0;
  LZeroOut := TRUE;
  while ($04 <> LLastByte) do
  begin
    LBytesReceived := recv(ASocket, LBuff, BUFF_SIZE, 0);
    LLastByte := LBuff[LBytesReceived - 1];
    if ($04 = LLastByte) then
    begin
      LBuff[LBytesReceived - 1] := 0;
      Dec(LBytesReceived, 2);
      LZeroOut := FALSE;
    end;
    LReceivedString := LReceivedString + TEncodingHelper(TEncoding.ANSI).GetString(@LBuff, LBytesReceived);
    if LZeroOut then
      FillChar(LBuff, Length(LBuff), 0);
  end;
  Result := LReceivedString
end;

class function TBaseSocketServer.SendTransmission(ASocket: TSocket; AMessage: String): Integer;
var
  LMsg: PAnsiChar;
  LLength: Integer;
  LString: AnsiString;
begin
  Result := SOCKET_ERROR;
  LString := AnsiString(AMessage + Char($04));
  LLength := Length(LString);
  GetMem(LMsg, LLength + 1);
  try
    AnsiStrings.StrPCopy(LMsg, LString);
    Result := Send(ASocket, PByte(LMsg)^, LLength, 0);
  finally
    FreeMem(LMsg);
  end;
end;


end.
