unit ReceiverChannel;

interface

uses
  System.Classes, System.SysUtils, WinApi.Windows, WinApi.Messages,
  System.SyncObjs, System.Threading, WinApi.Winsock, CustomThread, BaseSocketThread,
  FileLogger, BaseSocketServer;

type
  TCheckpointMessageProc = procedure(AValue: TArray<String>) of Object;
  TReceiverChannel = class(TBaseSocketServer)
  private
    class var FReceiverChannel: TReceiverChannel;
    FCheckpointMessageProc: TCheckpointMessageProc;
  protected
    procedure ServiceConnection(AAcceptSocket: TSocket; AConnectingIP: String); override;
  public
    constructor Create(AHost: String; APort: WORD; ACheckpointMessageProc: TCheckpointMessageProc; AProtocol: Integer = IPPROTO_TCP); reintroduce;
    class property ReceiverChanel: TReceiverChannel read FReceiverChannel write FReceiverChannel;
  end;

implementation

constructor TReceiverChannel.Create(AHost: String; APort: WORD; ACheckpointMessageProc: TCheckpointMessageProc; AProtocol: Integer = IPPROTO_TCP);
begin
  inherited Create(AHost, APort, AProtocol);
  FCheckpointMessageProc := ACheckpointMessageProc;
end;

procedure TReceiverChannel.ServiceConnection(AAcceptSocket: TSocket; AConnectingIP: String);
var
  LKeepReceiving: Boolean;
  LReceivedString: String;
  LRecords: TArray<String>;
begin
  LKeepReceiving := TRUE;
  repeat
    try
      LReceivedString := TBaseSocketServer.ReceiveTransmission(AAcceptSocket);
      if ( Assigned(FCheckpointMessageProc)) then
      begin
         LRecords := TBaseSocketServer.GetTransmissionStrings(LReceivedString);
         FCheckpointMessageProc(LRecords);
      end;
    except
      on Ex:Exception do
      begin
        LKeepReceiving := FALSE;
      end;
    end;
  until (not LKeepReceiving);
end;

end.
