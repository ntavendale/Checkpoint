{*******************************************************}
{                                                       }
{      Copyright(c) 2003-2016 Oamaru Group , Inc.       }
{                                                       }
{   Copyright and license exceptions noted in source    }
{                                                       }
{*******************************************************}
unit BlockingSocket;

interface

uses
  System.Classes, System.SysUtils, WinApi.Windows, WinApi.Messages,
  System.SyncObjs, WinApi.Winsock, IdWship6, FileLogger,
  CommonFunctions, AnsiStrings,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdGlobal,
  IdIOHandler, IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL,
  IdSSLOpenSSLHeaders;

type
  TBlockingSocket = class
    protected
      { Protected Declarations }
      FHost: String;
      FPort: WORD;
      function SetupSocket(AProtocol: Integer; ASocketType: Integer): Boolean; virtual; abstract;
    public
      { Public Declarations }
      constructor Create(AHost: String; APort: WORD); virtual;
      function ConnectSocket: Boolean; virtual; abstract;
      procedure DisconnectSocket; virtual; abstract;
      function SendMessage(AMsg: String): Integer; overload; virtual; abstract;
      function SendMessage(AMsg: AnsiString): Integer; overload; virtual; abstract;
      function SendMessage(AMsg: PByte; ALength: Integer): Integer; overload; virtual; abstract;
      property Host: String read FHost;
      property Port: WORD read FPort;
  end;

  TRawBlockingSocket = class(TBlockingSocket)
    protected
      { Protected Declarations }
      FWsaData: TWSAData;
      FSocket: TSocket;
      FIP: ULong;
      function SetupSocket(AProtocol: Integer; ASocketType: Integer): Boolean; override;
    public
      { Public Declarations }
      constructor Create(AHost: String; APort: WORD); override;
      destructor Destroy; override;
      function ConnectSocket: Boolean; override;
      procedure DisconnectSocket; override;
      function SendMessage(AMsg: String): Integer; overload; override;
      function SendMessage(AMsg: AnsiString): Integer; overload; override;
      function SendMessage(AMsg: PByte; ALength: Integer): Integer; overload; override;
  end;

  TBlockingTCPSocket = class(TRawBlockingSocket)
    protected
      { Protected Declarations }
    public
      { Public Declarations }
      constructor Create(AHost: String; APort: WORD); override;
  end;

  TBlockingUDPSocket = class(TRawBlockingSocket)
    protected
      { Protected Declarations }
    public
      { Public Declarations }
      constructor Create(AHost: String; APort: WORD); override;
  end;

  TIndySecureBlockingSocket = class(TBlockingSocket)
    protected
      { Protected Declarations }
      FTlsVersion: TIdSSLVersion;
      FTCPClient: TIdTcpClient;
      FIdSSLIOHandler: TIdSSLIOHandlerSocketOpenSSL;
      function SetupSocket(AProtocol: Integer; ASocketType: Integer): Boolean; override;
    public
      { Public Declarations }
      constructor Create(AHost: String; APort: WORD; ATLSVersion: WORD); reintroduce;
      destructor Destroy; override;
      function ConnectSocket: Boolean; override;
      procedure DisconnectSocket; override;
      function SendMessage(AMsg: String): Integer; overload; override;
      function SendMessage(AMsg: AnsiString): Integer; overload; override;
      function SendMessage(AMsg: PByte; ALength: Integer): Integer; overload; override;
  end;

implementation

{$REGION 'TBlockingSocket'}
constructor TBlockingSocket.Create(AHost: String; APort: WORD);
begin
  FHost := AHost;
  FPort := APort;
end;
{$ENDREGION}

{$REGION 'TRawBlockingSocket'}
constructor TRawBlockingSocket.Create(AHost: String; APort: WORD);
begin
  inherited Create(AHost, APort);
  FSocket := 0;
end;

destructor TRawBlockingSocket.Destroy;
begin
  WSACleanup;
  inherited Destroy;
end;

function TRawBlockingSocket.SetupSocket(AProtocol: Integer; ASocketType: Integer): Boolean;
var
  LHostEnt: PHostEnt;
  LHostAddress : TSockAddrIn;
  LError: DWORD;
  LAddrPtr: PaPInAddr;
  LStartUpResult: Integer;
  LLinger: TLinger;
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

  FSocket := socket(AF_INET, ASocketType, AProtocol);
  if INVALID_SOCKET = FSocket then
  begin
    LError := WSAGetLastError;
    LogFatal(Format('Socket Failed. Error Code: %d. %s', [LError, SysErrorMessage(LError)]));
    WSACleanup;
    EXIT;
  end;

  LLinger.l_onoff := 1;
  LLinger.l_linger := 30;
  SetSockOpt(FSocket, SOL_SOCKET, SO_LINGER, PAnsiChar(@LLinger), sizeof(LLinger));
  Result := TRUE;
end;

function TRawBlockingSocket.ConnectSocket: Boolean;
var
  LAddr: TSockAddrIn;
  LError: DWORD;
begin
  LAddr.sin_family := AF_INET;      // Address family
  LAddr.sin_port := htons(FPort);   // Assign port to this socket
  LAddr.sin_addr.s_addr := FIP;
  Result := TRUE;
  if SOCKET_ERROR = Connect(FSocket, LAddr, sizeof(LAddr)) then
  begin
    LError := WSAGetLastError();
    LogFatal(Format('Connect Failed. Error Code: %d. %s', [LError, SysErrorMessage(LError)]));
    Result := FALSE;
    EXIT;
  end;
end;

procedure TRawBlockingSocket.DisconnectSocket;
var
  LError: DWORD;
begin
  if (0 = FSocket) then
    EXIT;

  if SOCKET_ERROR = CloseSocket(FSocket) then
  begin
    LError := WSAGetLastError();
    LogError(Format('CloseSocket failed. Error Code: %d. %s', [LError, SysErrorMessage(LError)]));
  end;
  FSocket := 0;
end;

function TRawBlockingSocket.SendMessage(AMsg: String): Integer;
var
  LEncoding: TEncoding;
  LBytes: TArray<Byte>;
  LLength: Integer;
begin
  LEncoding := TEncoding.UTF8;
  LLength := LEncoding.GetByteCount(AMsg);
  LBytes := LEncoding.GetBytes(AMsg);
  Result := Send(FSocket, LBytes, LLength, 0);
  SetLength(LBytes, 0);
end;

function TRawBlockingSocket.SendMessage(AMsg: AnsiString): Integer;
var
  LMsg: PAnsiChar;
  LLength: Integer;
begin
  Result := SOCKET_ERROR;
  LLength := Length(AMsg);
  GetMem(LMsg, LLength + 1);
  try
    AnsiStrings.StrPCopy(LMsg, AMsg);
    Result := Send(FSocket, PByte(LMsg)^, LLength, 0);
  finally
    FreeMem(LMsg);
  end;
end;

function TRawBlockingSocket.SendMessage(AMsg: PByte; ALength: Integer): Integer;
begin
  Result := Send(FSocket, AMsg^, ALength, 0);
end;

{$ENDREGION}

{$REGION 'TBlockingTCPSocket'}
constructor TBlockingTCPSocket.Create(AHost: String; APort: WORD);
begin
  inherited Create(AHost, APort);
  SetupSocket(IPPROTO_TCP, SOCK_STREAM);
end;
{$ENDREGION}

{$REGION 'TBlockingUDPSocket'}
constructor TBlockingUDPSocket.Create(AHost: String; APort: WORD);
begin
  inherited Create(AHost, APort);
  SetupSocket(IPPROTO_UDP, SOCK_DGRAM);
end;
{$ENDREGION}

{$REGION 'TIndySecureBlockingSocket'}
constructor TIndySecureBlockingSocket.Create(AHost: String; APort: WORD; ATLSVersion: WORD);
begin
  inherited Create(AHost, APort);
  FTCPClient := TIdTcpClient.Create(nil);
  FIdSSLIOHandler := TIdSSLIOHandlerSocketOpenSSL.Create(nil);

  if 1 = HiByte(ATLSVersion) then
  begin
    if 2 = LoByte(ATLSVersion) then
      FTlsVersion := sslvTLSv1_2
    else if 1 = LoByte(ATLSVersion) then
      FTlsVersion := sslvTLSv1_1
    else if 0 = LoByte(ATLSVersion) then
      FTlsVersion := sslvTLSv1;
  end;

  SetupSocket(IPPROTO_TCP, SOCK_STREAM);
end;

destructor TIndySecureBlockingSocket.Destroy;
begin
  if FTCPClient.Connected then
    FTCPClient.Disconnect;

  FIdSSLIOHandler.Free;
  FTCPClient.Free;
  inherited Destroy;
end;

function TIndySecureBlockingSocket.SetupSocket(AProtocol: Integer; ASocketType: Integer): Boolean;
begin
  FIdSSLIOHandler.SSLOptions.SSLVersions := [sslvTLSv1,sslvTLSv1_1,sslvTLSv1_2];
  FIdSSLIOHandler.SSLOptions.Method := FTlsVersion;
  FIdSSLIOHandler.SSLOptions.Mode := sslmClient;

  FTCPClient.IOHandler := FIdSSLIOHandler;

  FTCPClient.Host := FHost;
  FTCPClient.Port := Fport;
  Result := TRUE;
end;

function TIndySecureBlockingSocket.ConnectSocket: Boolean;
begin
  FTCPClient.Connect;
  Result := FTCPClient.Connected;
end;

procedure TIndySecureBlockingSocket.DisconnectSocket;
begin
  if FTCPClient.Connected then
    FTCPClient.Disconnect;
end;

function TIndySecureBlockingSocket.SendMessage(AMsg: String): Integer;
begin
  try
    FTCPClient.IOHandler.WriteLn(AMsg);
    Result := Length(AMsg) * Sizeof(Char);
  except
    on E:Exception do
    begin
      Result := 0;
      raise Exception.Create('Socket Error sending message');
    end;
  end;
end;

function TIndySecureBlockingSocket.SendMessage(AMsg: AnsiString): Integer;
begin
  try
    FTCPClient.IOHandler.WriteLn(String(AMsg));
    Result := Length(AMsg) * Sizeof(Char);
  except
    on E:Exception do
    begin
      Result := 0;
      raise Exception.Create('Socket Error sending message');
    end;
  end;
end;

function TIndySecureBlockingSocket.SendMessage(AMsg: PByte; ALength: Integer): Integer;
var
  LBytes: TIdBytes;
  LByte: PByte;
  i: Integer;
begin
  try
    SetLength(LBytes, ALength);
    LByte := AMsg;
    for i := 0 to ALength - 1 do
    begin
      LBytes[i] := LByte^;
      Inc(LByte);
    end;
    FTCPClient.IOHandler.Write(LBytes, ALength);
    FTCPClient.IOHandler.WriteBufferFlush();
    SetLength(LBytes, 0);
    Result := ALength;
  except
    Result := 0;
    raise Exception.Create('Socket Error sending message');
  end;
end;
{$ENDREGION}

end.
