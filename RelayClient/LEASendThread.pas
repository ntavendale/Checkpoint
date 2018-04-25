unit LEASendThread;

interface

uses
  System.Classes, System.SysUtils, SyncObjs, Vcl.Forms, WinApi.Windows, System.Types,
  WinApi.Messages, System.Generics.Collections, CustomThread,  Vcl.FileCtrl,
  System.IOUtils, System.DateUtils, CommonFunctions, BlockingSocket;

type
  TLEASendThread = class(TCustomThread)
    private
      FMessage: AnsiString;
      FHost: String;
      FPort: WORD;
      FRepeatInterval: DWORD;
      FSocket: TBlockingTCPSocket;
    protected
      function OnThreadExecute: Boolean; override;
    public
      constructor Create(AMessage: AnsiString; AHost: String; APort: WORD; ARepeatInterval: DWORD); reintroduce;
      destructor Destroy; override;
  end;

implementation

constructor TLEASendThread.Create(AMessage: AnsiString; AHost: String; APort: WORD; ARepeatInterval: DWORD);
begin
  inherited Create;
  FMessage := AMessage;
  FHost := AHost;
  FPort := APort;
  FRepeatInterval := ARepeatInterval;
end;

destructor TLEASendThread.Destroy;
begin
  if nil <> FSocket then
  begin
    FSocket.DisconnectSocket;
    FSocket.Free;
  end;
  inherited Destroy;
end;

function TLEASendThread.OnThreadExecute: Boolean;
var
  LWaitObject: Cardinal;
begin
  Result := FALSE;
  while not (Terminated or Result) do
  begin
    LWaitObject := WaitForSingleObject(FShouldFinishEvent, FRepeatInterval);
    if (WAIT_OBJECT_0 = LWaitObject) then
    begin
      Result := TRUE;
    end;
    if (WAIT_TIMEOUT = LWaitObject) then
    begin
      FSocket := TBlockingTCPSocket.Create(FHost, FPort);
      try
        FSocket.ConnectSocket;
        FSocket.SendMessage(FMessage);
        FSocket.DisconnectSocket;
      finally
        FSocket.Free;
        FSocket := nil;
      end;
    end;
  end;
end;

end.
