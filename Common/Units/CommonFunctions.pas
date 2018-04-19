unit CommonFunctions;

interface

uses
  SysUtils, Classes, Winapi.Windows, Winapi.Messages, ShlObj, Registry;

const
  WM_REFRESH_MSG = WM_APP + 1;
  FM_SELECT = 0;
  FM_VIEW = 1;

  WARNING_7_1_5 = 'EMDB Versions 7.1.5 and earlier require a 6.x KB Package';
  WARNING_7_1_6 = 'EMDB Versions 7.1.6 and later require a 7.x KB Package';

function GetFileSize(const AFileName: String): Int64;
function GetFileCreationTime(const AFileName: String): TDateTime;
function GetFileLastWriteTime(const AFileName: String): TDateTime;
procedure SetRegistryString(AKeyName, AValueName, AValue: String);
function GetRegistryString(AKeyName, AValueName: String): String;
procedure SetFormKey(AFormName, AValueName, AValue: String);
function GetFormKey(AFormName, AValueName: String): String;
function GetSpecialFolder(FolderID : DWORD) : String;
function GetAppDataDir: String;
function GetAppDataDirNonRoaming: String;
function GetCommonAppDataDir: String;
procedure GetCurrentUserAndDomain(var User, Domain: String);
function GetAppVersionStr: string;
function GetMachineGUID: String;

implementation

function GetFileSize(const AFileName: String): Int64;
var
  AttributeData: TWin32FileAttributeData;
begin
  Result := -1;
  if GetFileAttributesEx(PChar(AFileName), GetFileExInfoStandard, @AttributeData) then
  begin
    Int64Rec(Result).Lo := AttributeData.nFileSizeLow;
    Int64Rec(Result).Hi := AttributeData.nFileSizeHigh;
  end;
end;

function GetFileCreationTime(const AFileName: String): TDateTime;
var
  AttributeData: TWin32FileAttributeData;
  LLocalTime: TFileTime;
  LDOSTime: Integer;
begin
  Result := -1.00;
  if GetFileAttributesEx(PChar(AFileName), GetFileExInfoStandard, @AttributeData) then
  begin
    FileTimeToLocalFileTime(AttributeData.ftCreationTime, LLocalTime);
    FileTimeToDosDateTime(LLocalTime, LongRec(LDOSTime).Hi, LongRec(LDOSTime).Lo);
    FileDateToDateTime( LDOSTime );
  end;
end;

function GetFileLastWriteTime(const AFileName: String): TDateTime;
var
  AttributeData: TWin32FileAttributeData;
  LLocalTime: TFileTime;
  LDOSTime: Integer;
begin
  Result := -1.00;
  if GetFileAttributesEx(PChar(AFileName), GetFileExInfoStandard, @AttributeData) then
  begin
    FileTimeToLocalFileTime(AttributeData.ftLastWriteTime, LLocalTime);
    FileTimeToDosDateTime(LLocalTime, LongRec(LDOSTime).Hi, LongRec(LDOSTime).Lo);
    FileDateToDateTime( LDOSTime );
  end;
end;

procedure SetRegistryString(AKeyName, AValueName, AValue: String);
var
  LReg: TRegistry;
begin
  LReg := TRegistry.Create;
  try
    LREG.RootKey := HKEY_CURRENT_USER;
    LREG.OpenKey(String.Format('SOFTWARE\BastardSoftware\ProtoTypes\%s', [AKeyName]), TRUE);
    LREG.WriteString(AValueName, AValue);
    LREG.CloseKey;
  finally
    LReg.Free;
  end;
end;

function GetRegistryString(AKeyName, AValueName: String): String;
var
  LReg: TRegistry;
begin
  LReg := TRegistry.Create;
  try
    LREG.RootKey := HKEY_CURRENT_USER;
    LREG.OpenKey(String.Format('SOFTWARE\BastardSoftware\ProtoTypes\%s', [AKeyName]), TRUE);
    Result := LREG.ReadString(AValueName);
    LREG.CloseKey;
  finally
    LReg.Free;
  end;
end;

procedure SetFormKey(AFormName, AValueName, AValue: String);
var
  LReg: TRegistry;
begin
  LReg := TRegistry.Create;
  try
    LREG.RootKey := HKEY_CURRENT_USER;
    LREG.OpenKey('SOFTWARE\BastardSoftware\ProtoTypes\' + AFormName, TRUE);
    LREG.WriteString(AValueName, AValue);
    LREG.CloseKey;
  finally
    LReg.Free;
  end;
end;

function GetFormKey(AFormName, AValueName: String): String;
var
  LReg: TRegistry;
begin
  LReg := TRegistry.Create;
  try
    LREG.RootKey := HKEY_CURRENT_USER;
    LREG.OpenKey('SOFTWARE\BastardSoftware\ProtoTypes\' + AFormName, TRUE);
    Result := LREG.ReadString(AValueName);
    LREG.CloseKey;
  finally
    LReg.Free;
  end;
end;

function GetSpecialFolder(FolderID : DWORD) : String;
var
 Path : PChar;
 idList : PItemIDList;
begin
  GetMem(Path, (2 * MAX_PATH));
  try
    SHGetSpecialFolderLocation(0, FolderID, idList);
    SHGetPathFromIDList(idList, Path);
    Result := String(Path);
  finally
    FreeMem(Path);
  end;
end;

function GetAppDataDir: String;
begin
  Result := ExcludeTrailingPathDelimiter(GetSpecialFolder(CSIDL_APPDATA));
end;

function GetAppDataDirNonRoaming: String;
begin
  Result := ExcludeTrailingPathDelimiter(GetSpecialFolder(CSIDL_LOCAL_APPDATA));
end;

function GetCommonAppDataDir: String;
begin
  Result := ExcludeTrailingPathDelimiter(GetSpecialFolder(CSIDL_COMMON_APPDATA));
end;

procedure GetCurrentUserAndDomain(var User, Domain: String);
var
  hProcess, hAccessToken: THandle;
  InfoBuffer: Pointer;
  szAccountName, szDomainName: array [0..200] of Char;
  dwInfoBufferSize, dwAccountSize, dwDomainSize: DWORD;
  pUser: PTokenUser;
  snu: SID_NAME_USE;
begin
  dwAccountSize := 200;
  dwDomainSize := 200;
  hProcess := GetCurrentProcess;
  OpenProcessToken(hProcess,TOKEN_READ,hAccessToken);
  FillChar(szAccountName, SizeOf(szAccountName), 0);
  FillChar(szDomainName, SizeOf(szDomainName), 0);
  if not GetTokenInformation(hAccessToken, TokenUser, nil, 0, dwInfoBufferSize) then
  begin
    GetMem(InfoBuffer, dwInfoBufferSize);
    try
      GetTokenInformation(hAccessToken, TokenUser, InfoBuffer, dwInfoBufferSize, dwInfoBufferSize);
      pUser := PTokenUser(InfoBuffer);
      LookupAccountSid(nil, pUser.User.Sid, @szAccountName, dwAccountSize, @szDomainName, dwDomainSize, snu);
    finally
      FreeMem(InfoBuffer);
    end;
    User := szAccountName;
    Domain := szDomainName;
    CloseHandle(hAccessToken);
  end;

end;

function GetAppVersionStr: string;
var
  Exe: string;
  Size, Handle: DWORD;
  Buffer: TBytes;
  FixedPtr: PVSFixedFileInfo;
begin
  Exe := ParamStr(0);
  Size := GetFileVersionInfoSize(PChar(Exe), Handle);
  if Size = 0 then
    RaiseLastOSError;
  SetLength(Buffer, Size);
  if not GetFileVersionInfo(PChar(Exe), Handle, Size, Buffer) then
    RaiseLastOSError;
  if not VerQueryValue(Buffer, '\', Pointer(FixedPtr), Size) then
    RaiseLastOSError;
  Result := Format('%d.%d.%d.%d',
    [LongRec(FixedPtr.dwFileVersionMS).Hi,  //major
     LongRec(FixedPtr.dwFileVersionMS).Lo,  //minor
     LongRec(FixedPtr.dwFileVersionLS).Hi,  //release
     LongRec(FixedPtr.dwFileVersionLS).Lo]) //build
end;

function GetMachineGUID: String;
var
  LReg: TRegistry;
begin
  Result := String.Empty;
  LReg := TRegistry.Create(KEY_READ);
  try
    LReg.RootKey := HKEY_LOCAL_MACHINE;
    if LReg.OpenKey('SOFTWARE\Microsoft\Cryptography', FALSE) then
    begin
      if LReg.ValueExists('MachineGuid') then
        Result := LReg.ReadString('MachineGuid');
      LReg.CloseKey;
    end;
  finally
    LReg.Free;
  end;
end;

end.
