{*******************************************************}
{                                                       }
{      Copyright(c) 2003-2016 Oamaru Group , Inc.       }
{                                                       }
{   Copyright and license exceptions noted in source    }
{                                                       }
{*******************************************************}
unit BaseSocketThread;

interface

uses
  System.Classes, System.SysUtils, WinApi.Windows, WinApi.Messages,
  System.SyncObjs, WinApi.Winsock, CustomThread, FileLogger, IdWship6;

const
  BTHPROTO_RFCOMM = 3;
  IPPROTO_ICMPV6  = 58;
  IPPROTO_RM      = 113;
  MAX_UDP_BUFF_LEN = 65536;
type
  PaPInAddr = ^TaPInAddr;
  TaPInAddr = array[0..3] of Byte;

  TBaseSocketThread = class(TCustomThread)
    private
      FProtocol: Integer;
    protected
      { Protected declarations }
      Addr: TSockAddrIn;
      FWsaData: TWSAData;
      FSocket: TSocket;
      FHost: String;
      FPort: WORD;
      FIP: ULong;
      FStopRequested: THandle;
      function SetupSocket: Boolean;
      function OnBeforeThreadBegin(AWaitTillStarted: Boolean = FALSE): Boolean; override;
      function OnBeforeThreadEnd(AWaitTillFinished: Boolean = FALSE): Boolean; override;
    public
      { Public declarations }
      constructor Create(AHost: String; APort: WORD; AProtocol: Integer = IPPROTO_TCP); reintroduce; virtual;
      destructor Destroy; override;
  end;


implementation

constructor TBaseSocketThread.Create(AHost: String; APort: WORD; AProtocol: Integer = IPPROTO_TCP);
begin
  inherited Create;
  FHost := AHost;
  FPort := APort;
  FStopRequested := CreateEvent(nil, TRUE, FALSE, nil);
  FProtocol := AProtocol;
end;

destructor TBaseSocketThread.Destroy;
begin
  CloseHandle(FStopRequested);
  inherited Destroy;
end;

function TBaseSocketThread.SetupSocket: Boolean;
var
  LHostEnt: PHostEnt;
  LHostAddress : TSockAddrIn;
  LError: DWORD;
  LAddrPtr: PaPInAddr;
  LStartUpResult: Integer;
  LRecvBufSize: Integer;
  LLen: Integer;
begin
  Result := FALSE;
  LStartUpResult := WsaStartup(MAKEWORD(2,2), FWsaData);
  if (0 <> LStartUpResult) then
  begin
    case LStartUpResult of
      WSASYSNOTREADY: LogFatal('WSAStartup returned WSASYSNOTREADY: The underlying network subsystem is not ready for network communication.');
      WSAVERNOTSUPPORTED: LogFatal('WSAStartup returned WSAVERNOTSUPPORTED: The version of Windows Sockets support requested (2.2) is not provided by this particular Windows Sockets implementation.');
      WSAEINPROGRESS: LogFatal('WSAStartup returned WSAEINPROGRESS: A blocking Windows Sockets 1.1 operation is in progress.');
      WSAEPROCLIM: LogFatal('WSAStartup returned WSAEPROCLIM: A limit on the number of tasks supported by the Windows Sockets implementation has been reached.');
      WSAEFAULT: LogFatal('WSAStartup returned WSASYSNOTREADY: The data parameter is not a valid pointer.');
    else
      LogFatal(Format('WSAStartup returned 0x%.4x: Unknown error.',[LStartUpResult]));
    end;
    EXIT;
  end;

  LHostEnt := GetHostByName(PAnsiChar(AnsiString(FHost)));
  if (AF_INET <> LHostEnt^.h_addrtype) then
  begin
    LogFatal(Format('GetHostByName returned invalid adress type 0x%.4x', [LHostEnt^.h_addrtype]));
    WSACleanup;
    EXIT;
  end;

  if nil = LHostEnt then
  begin
    LError := WSAGetLastError;
    LogFatal(Format('GetHostByName failed with error code %d: %s', [LError, SysErrorMessage(LError)]));
    WSACleanup;
    EXIT;
  end;

  if Assigned(LHostEnt^.h_addr_list[0]) then
  begin
    LAddrPtr := PaPInAddr(LHostEnt^.h_addr_list^);
    LHostAddress.sin_addr.S_un_b.s_b1 := AnsiChar(LAddrPtr^[0]);
    LHostAddress.sin_addr.S_un_b.s_b2 := AnsiChar(LAddrPtr^[1]);
    LHostAddress.sin_addr.S_un_b.s_b3 := AnsiChar(LAddrPtr^[2]);
    LHostAddress.sin_addr.S_un_b.s_b4 := AnsiChar(LAddrPtr^[3]);
    FIP := LHostAddress.sin_addr.S_addr;
    LogDebug(Format('Got IP Address %s for host %s', [AnsiString(inet_ntoa(LHostAddress.sin_addr)), FHost]));
  end else
  begin
    LogFatal(Format('No IP Address found for host %s', [FHost]));
    WSACleanup;
    EXIT;
  end;

  case FProtocol of
    IPPROTO_ICMP: LogDebug('Creating socket. Protocol = IPPROTO_ICMP.');
    IPPROTO_IGMP: LogDebug('Creating socket. Protocol = IPPROTO_IGMP.');
    BTHPROTO_RFCOMM: LogDebug('Creating socket. Protocol = BTHPROTO_RFCOMM.');
    IPPROTO_TCP: LogDebug('Creating socket. Protocol = IPPROTO_TCP.');
    IPPROTO_UDP: LogDebug('Creating socket. Protocol = IPPROTO_UDP.');
    IPPROTO_ICMPV6: LogDebug('Creating socket. Protocol = IPPROTO_ICMPV6.');
    IPPROTO_RM: LogDebug('Creating socket. Protocol = IPPROTO_RM.');
  end;

  if IPPROTO_UDP = FProtocol then
    FSocket := Socket(AF_INET, SOCK_DGRAM, 0)
  else
    FSocket := Socket(AF_INET, SOCK_STREAM, FProtocol);

  LLen := sizeof(LRecvBufSize);
  GetSockOpt(FSocket, SOL_SOCKET, SO_RCVBUF, PAnsiChar(@LRecvBufSize), LLen);
  LogDebug(String.Format('Socket buffer size = %d.', [LRecvBufSize]));

  if INVALID_SOCKET = FSocket then
  begin
    LError := WSAGetLastError;
    LogFatal(Format('Socket Failed. Error Code: %d. %s', [LError, SysErrorMessage(LError)]));
    WSACleanup;
    EXIT;
  end;
  Result := TRUE;
end;

function TBaseSocketThread.OnBeforeThreadBegin(AWaitTillStarted: Boolean = FALSE): Boolean;
begin
  Result := SetupSocket;
end;

function TBaseSocketThread.OnBeforeThreadEnd(AWaitTillFinished: Boolean = FALSE): Boolean;
begin
  CloseSocket(FSocket);
  Result := inherited OnBeforeThreadEnd;
end;

end.
