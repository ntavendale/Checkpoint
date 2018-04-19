{*******************************************************}
{                                                       }
{      Copyright(c) 2003-2016 Oamaru Group , Inc.       }
{                                                       }
{   Copyright and license exceptions noted in source    }
{                                                       }
{*******************************************************}
unit FileLogger;

interface

uses
  System.Classes, System.SysUtils, SyncObjs, Vcl.Forms, WinApi.Windows, System.Types,
  WinApi.Messages, System.Generics.Collections, CustomThread,  Vcl.FileCtrl,
  System.IOUtils, System.DateUtils, CommonFunctions;

const
  LOG_NONE = 0;
  LOG_FATAL = 1;
  LOG_ERROR = 2;
  LOG_WARN = 3;
  LOG_INFO = 4;
  LOG_DEBUG = 5;
  MAX_LOG_FILE_SIZE = 2097152; //2MB

type
  TMessageProc = procedure(AValue: String) of Object;
  TFileLogger = class(TCustomThread)
  private
    { Private declarations }
    FIsConsoleApp: Boolean;
    FLogMessageQueue: TQueue<String>;
    FLogLevel: Integer;
    FLogFile: String;
    FLogEvent: THandle;
    FMessageProc: TMessageProc;
    FFileLock: TCriticalSection;
    procedure RolloverLogs;
    procedure SetLogLevel(AValue: Integer);
    function GetLogLevel: Integer;
    procedure SetLogFile(AValue: String);
    function GetLogFile: String;
  protected
    function OnBeforeThreadBegin(AWaitTillStarted: Boolean = FALSE): Boolean; override;
    function OnAfterThreadEnd: Boolean; override;
    procedure WriteFatal(AValue: String); overload;
    procedure WriteError(AValue: String); overload;
    procedure WriteWarning(AValue: String); overload;
    procedure WriteInfo(AValue: String); overload;
    procedure WriteDebug(AValue: String); overload;
    procedure WriteFatal(AValue: TStrings); overload;
    procedure WriteError(AValue: TStrings); overload;
    procedure WriteWarning(AValue: TStrings); overload;
    procedure WriteInfo(AValue: TStrings); overload;
    procedure WriteDebug(AValue: TStrings); overload;
    procedure WriteFormatDebug(const AValue: String; const AArgs: array of TVarRec);
    function OnThreadExecute: Boolean; override;
  public
    constructor Create(AMessageProc: TMessageProc = nil); reintroduce;
    destructor Destroy; override;
    function GetCurrentLogContents: TStringList;
    procedure Flush;
    property Loglevel: Integer read GetLogLevel write SetLogLevel;
    property LogFile: String read GetLogFile write SetLogFile;
    class procedure SetFileLogLevel(AValue: Integer; AMessageProc: TMessageProc = nil);
    class function LogLevelString: String;
    class function CurrentLogLevel: Integer;
    class function CurrentLogFile: String;
    class function CurrentLogFileContents: TStringList;
    class function LogLevelToString(ALogLevel: Integer): String;
    class procedure Fatal(AValue: String); overload;
    class procedure Error(AValue: String); overload;
    class procedure Warn(AValue: String); overload;
    class procedure Info(AValue: String); overload;
    class procedure Debug(AValue: String); overload;
    class procedure Fatal(AValue: TStrings); overload;
    class procedure Error(AValue: TStrings); overload;
    class procedure Warn(AValue: TStrings); overload;
    class procedure Info(AValue: TStrings); overload;
    class procedure Debug(AValue: TStrings); overload;
    class procedure FormatDebug(const AValue: String; const AArgs: array of TVarRec);
    class procedure CloseLog;
  end;

procedure LogFatal(AValue: String); overload;
procedure LogError(AValue: String); overload;
procedure LogWarn(AValue: String); overload;
procedure LogInfo(AValue: String); overload;
procedure LogDebug(AValue: String); overload;
procedure FormatDebug(const AValue: String; const AArgs: array of TVarRec);
procedure LogFatal(AValue: TStrings); overload;
procedure LogError(AValue: TStrings); overload;
procedure LogWarn(AValue: TStrings); overload;
procedure LogInfo(AValue: TStrings); overload;
procedure LogDebug(AValue: TStrings); overload;

implementation

var
  MyLogThread: TFileLogger = nil;

procedure LogFatal(AValue: String);
begin
  TFileLogger.Fatal(AValue);
end;

procedure LogError(AValue: String);
begin
  TFileLogger.Error(AValue);
end;

procedure LogWarn(AValue: String);
begin
  TFileLogger.Warn(AValue);
end;

procedure LogInfo(AValue: String);
begin
  TFileLogger.Info(AValue);
end;

procedure LogDebug(AValue: String);
begin
  TFileLogger.Debug(AValue);
end;

procedure FormatDebug(const AValue: String; const AArgs: array of TVarRec);
begin
  TFileLogger.FormatDebug(AValue, AArgs);
end;

procedure LogFatal(AValue: TStrings);
begin
  TFileLogger.Fatal(AValue);
end;

procedure LogError(AValue: TStrings);
begin
  TFileLogger.Error(AValue);
end;

procedure LogWarn(AValue: TStrings);
begin
  TFileLogger.Warn(AValue);
end;

procedure LogInfo(AValue: TStrings);
begin
  TFileLogger.Info(AValue);
end;

procedure LogDebug(AValue: TStrings);
begin
  TFileLogger.Debug(AValue);
end;

class procedure TFileLogger.SetFileLogLevel(AValue: Integer; AMessageProc: TMessageProc = nil);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create(AMessageProc);
    MyLogThread.Loglevel := AValue;
    MyLogThread.ThreadStart;
  end else
    MyLogThread.Loglevel := AValue;
end;

class function TFileLogger.LogLevelString: String;
var
  LLogLevel: Integer;
begin
  Result := 'UNKNOWN';
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  LLogLevel := MyLogThread.Loglevel;
  case LLogLevel of
    LOG_NONE: Result := 'LOG_NONE';
    LOG_FATAL: Result := 'LOG_FATAL';
    LOG_ERROR: Result := 'LOG_ERROR';
    LOG_WARN: Result := 'LOG_WARN';
    LOG_INFO: Result := 'LOG_INFO';
    LOG_DEBUG: Result := 'LOG_DEBUG';
  end;
end;

class function TFileLogger.CurrentLogLevel: Integer;
begin
  Result := MyLogThread.Loglevel;
end;

class function TFileLogger.CurrentLogFile: String;
begin
  Result := MyLogThread.GetLogFile;
end;

class function TFileLogger.CurrentLogFileContents: TStringList;
begin
  Result := MyLogThread.GetCurrentLogContents;
end;

class function TFileLogger.LogLevelToString(ALogLevel: Integer): String;
begin
  case ALogLevel of
    LOG_NONE: Result := 'LOG_NONE';
    LOG_FATAL: Result := 'LOG_FATAL';
    LOG_ERROR: Result := 'LOG_ERROR';
    LOG_WARN: Result := 'LOG_WARN';
    LOG_INFO: Result := 'LOG_INFO';
    LOG_DEBUG: Result := 'LOG_DEBUG';
  else
    Result := 'INVALID';
  end;
end;

class procedure TFileLogger.Fatal(AValue: String);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteFatal(AValue);
end;

class procedure TFileLogger.Error(AValue: String);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteError(AValue);
end;

class procedure TFileLogger.Warn(AValue: String);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteWarning(AValue);
end;

class procedure TFileLogger.Info(AValue: String);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteInfo(AValue);
end;

class procedure TFileLogger.Debug(AValue: String);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteDebug(AValue);
end;

class procedure TFileLogger.FormatDebug(const AValue: String; const AArgs: array of TVarRec);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteFormatDebug(AValue, AArgs);
end;

class procedure TFileLogger.Fatal(AValue: TStrings);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteDebug(AValue);
end;

class procedure TFileLogger.Error(AValue: TStrings);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteDebug(AValue);
end;

class procedure TFileLogger.Warn(AValue: TStrings);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteDebug(AValue);
end;

class procedure TFileLogger.Info(AValue: TStrings);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteDebug(AValue);
end;

class procedure TFileLogger.Debug(AValue: TStrings);
begin
  if nil = MyLogThread then
  begin
    MyLogThread := TFileLogger.Create;
    MyLogThread.ThreadStart;
  end;
  MyLogThread.WriteDebug(AValue);
end;

class procedure TFileLogger.CloseLog;
begin
  if nil = MyLogThread then
  begin
    MyLogThread.ThreadStop(TRUE);
    MyLogThread.Free;
    MyLogThread := nil;
  end;
end;

constructor TFileLogger.Create(AMessageProc: TMessageProc = nil);
begin
  inherited Create;
  FFileLock := TCriticalSection.Create;
  FMessageProc := AMessageProc;
  FLogLevel := LOG_NONE;
  if not Assigned(FMessageProc) then
  begin
    if not TDirectory.Exists(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'Log') then
      TDirectory.CreateDirectory(IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'Log');

    FLogFile := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName)) + 'Log\' +  ChangeFileExt(ExtractFileName(Application.ExeName), '.log');
  end;
  FLogMessageQueue := TQueue<String>.Create;
end;

destructor TFileLogger.Destroy;
begin
  FLogMessageQueue.Free;
  FFileLock.Free;
  inherited Destroy;
end;

procedure TFileLogger.RolloverLogs;
var
  LLogFolder: String;
  LFileList: TStringDynArray;
  LNewFile: String;
  i: Integer;
begin
  LLogFolder := ExcludeTrailingPathDelimiter(ExtractFilePath(FLogFile));
  if not TDirectory.Exists(LLogFolder) then
    EXIT;

  if not FileExists(FLogFile) then
    EXIT;

  if (GetFileSize(FlogFile) < MAX_LOG_FILE_SIZE) then
    EXIT;

  LFileList := TDirectory.GetFiles(LLogFolder, '*.log');
  for i := 0 to Length(LFileList) do
  begin
    if 7 < DaysBetween(Date, GetFileCreationTime(LFileList[i])) then
      DeleteFile(PChar(LFileList[i]));
  end;
  LNewFile := LLogFolder + '\' + ChangeFileExt(ExtractFileName(Application.ExeName), '') + FormatDateTime('YYYYMMDDhhnnss', Now) + '.log';
  MoveFileEx(PChar(FLogFile), PChar(LNewFile), MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH);
end;

procedure TFileLogger.SetLogLevel(AValue: Integer);
begin
  FLogLevel := AValue;
end;

function TFileLogger.GetLogLevel: Integer;
begin
  Result := FLogLevel;
end;

procedure TFileLogger.SetLogFile(AValue: String);
begin
  Lock;
  try
    FLogFile := AValue;
  finally
    Unlock;
  end;
end;

function TFileLogger.GetLogFile: String;
begin
  Lock;
  try
    Result := FLogFile;
  finally
    Unlock;
  end;
end;

function TFileLogger.OnBeforeThreadBegin(AWaitTillStarted: Boolean = FALSE): Boolean;
var
  Stdout: THandle;
begin
  if (inherited OnBeforeThreadBegin) then
  begin
    FLogEvent := CreateEvent( nil, TRUE, FALSE, nil );
    Stdout := GetStdHandle(Std_Output_Handle);
    Win32Check(Stdout <> Invalid_Handle_Value);
    FIsConsoleApp := Stdout <> 0;
  end;
  Result := TRUE;
end;

function TFileLogger.OnAfterThreadEnd: Boolean;
begin
  CloseHandle(FLogEvent);
  Result := inherited OnAfterThreadEnd();
end;

procedure TFileLogger.WriteFatal(AValue: String);
var
  LLogMessage: String;
begin
  if FLogLevel < LOG_FATAL then
    EXIT;
  //LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' FATAL - ' + AValue;
  LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x]', [GetCurrentThreadId]) + ' FATAL - ' + AValue;
  Lock;
  try
    FLogMessageQueue.Enqueue(LLogMessage);
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

procedure TFileLogger.WriteError(AValue: String);
var
  LLogMessage: String;
begin
  if FLogLevel < LOG_ERROR then
    EXIT;
  //LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' ERROR - ' + AValue;
  LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x]', [GetCurrentThreadId]) + ' ERROR - ' + AValue;
  Lock;
  try
    FLogMessageQueue.Enqueue(LLogMessage);
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

procedure TFileLogger.WriteWarning(AValue: String);
var
  LLogMessage: String;
begin
  if FLogLevel < LOG_WARN then
    EXIT;
  //LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' WARN  - ' + AValue;
  LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x]', [GetCurrentThreadId]) + ' WARN  - ' + AValue;
  Lock;
  try
    FLogMessageQueue.Enqueue(LLogMessage);
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

procedure TFileLogger.WriteInfo(AValue: String);
var
  LLogMessage: String;
begin
  if FLogLevel < LOG_INFO then
    EXIT;
  //LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' INFO  - ' + AValue;
  LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x]', [GetCurrentThreadId]) + ' INFO  - ' + AValue;
  Lock;
  try
    FLogMessageQueue.Enqueue(LLogMessage);
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

procedure TFileLogger.WriteDebug(AValue: String);
var
  LLogMessage: String;
begin
  if FLogLevel < LOG_DEBUG then
    EXIT;
  //LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' DEBUG - ' + AValue;
  LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x]', [GetCurrentThreadId]) + ' DEBUG - ' + AValue;
  Lock;
  try
    FLogMessageQueue.Enqueue(LLogMessage);
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

procedure TFileLogger.WriteFatal(AValue: TStrings);
var
  LLogMessage: String;
  i: Integer;
begin
  if FLogLevel < LOG_FATAL then
    EXIT;
  Lock;
  try
    for i := 0 to (AValue.Count - 1) do
    begin
      LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' FATAL - ' + AValue[i];
      FLogMessageQueue.Enqueue(LLogMessage);
    end;
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

procedure TFileLogger.WriteError(AValue: TStrings);
var
  LLogMessage: String;
  i: Integer;
begin
  if FLogLevel < LOG_ERROR then
    EXIT;
  Lock;
  try
    for i := 0 to (AValue.Count - 1) do
    begin
      LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' ERROR - ' + AValue[i];
      FLogMessageQueue.Enqueue(LLogMessage);
    end;
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

procedure TFileLogger.WriteWarning(AValue: TStrings);
var
  LLogMessage: String;
  i: Integer;
begin
  if FLogLevel < LOG_WARN then
    EXIT;
  Lock;
  try
    for i := 0 to (AValue.Count - 1) do
    begin
      LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' WARN  - ' + AValue[i];
      FLogMessageQueue.Enqueue(LLogMessage);
    end;
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

procedure TFileLogger.WriteInfo(AValue: TStrings);
var
  LLogMessage: String;
  i: Integer;
begin
  if FLogLevel < LOG_INFO then
    EXIT;
  Lock;
  try
    for i := 0 to (AValue.Count - 1) do
    begin
      LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' INFO  - ' + AValue[i];
      FLogMessageQueue.Enqueue(LLogMessage);
    end;
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

procedure TFileLogger.WriteDebug(AValue: TStrings);
var
  LLogMessage: String;
  i: Integer;
begin
  if FLogLevel < LOG_DEBUG then
    EXIT;
  Lock;
  try
    for i := 0 to (AValue.Count - 1) do
    begin
      LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' DEBUG - ' + AValue[i];
      FLogMessageQueue.Enqueue(LLogMessage);
    end;
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

procedure TFileLogger.WriteFormatDebug(const AValue: String; const AArgs: array of TVarRec);
var
  LLogMessage: String;
begin
  if FLogLevel < LOG_DEBUG then
    EXIT;
  //LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x/0x%.8x]', [GetCurrentProcessId, GetCurrentThreadId]) + ' DEBUG - ' + AValue;
  LLogMessage := FormatDateTime('YYYY-MMM-DD hh:nn:ss.zzz', Now) + ' ' + Format('[0x%.8x]', [GetCurrentThreadId]) + ' DEBUG - ' + String.Format(AValue, AArgs);
  Lock;
  try
    FLogMessageQueue.Enqueue(LLogMessage);
    SetEvent(FLogEvent);
  finally
    Unlock;
  end;
end;

function TFileLogger.GetCurrentLogContents: TStringList;
begin
  Result := TStringList.Create;
  FFileLock.Acquire;
  try
    Result.LoadFromFile(FLogFile);
  finally
    FFileLock.Release;
  end;
end;

procedure TFileLogger.Flush;
const
  UnicodeBOM: array[0..1] of Byte = ($FF, $FE);
var
  LLogMessage: String;
  LQueue, LTemp: TQueue<String>;
  LFS: TFileStream;
  LOut: String;
  LFlags: WORD;
begin
  //Do an A <-> B Swap to minimise lock time
  LTemp := TQueue<String>.Create;
  Lock;
  try
    LQueue := FLogMessageQueue;
    FLogMessageQueue := LTemp;
  finally
    Unlock;
  end;

  if Assigned(FMessageProc) then
  begin
    while LQueue.Count > 0 do
    begin
      LLogMessage := LQueue.Dequeue;
      if IsConsole then
         WriteLn(Output, LLogMessage);
      if Assigned(FMessageProc) then
        FMessageProc(LLogMessage);
    end;
  end else
  begin
    FFileLock.Acquire;
    try
      RolloverLogs;

      LFlags := fmOpenReadWrite;
      if not FileExists(FLogFile) then
        LFlags := fmCreate;
      LFS := TFileStream.Create(FLogFile, LFlags, fmShareDenyWrite);
      try
        LFS.Position := LFS.Size;
        if 0 = LFS.Position then
        begin
          LFS.Write(UnicodeBOM, Sizeof(UnicodeBOM));
        end;
        while LQueue.Count > 0 do
        begin
          LLogMessage := LQueue.Dequeue;
          LOut := LLogMessage + #13#10;
          LFS.Write(LOut[1], Length(LOut) * SizeOf(Char));
          if IsConsole then
             WriteLn(Output, LLogMessage);
        end;
      finally
        LFS.Free;
      end;
    finally
      FFileLock.Release;
    end;
  end;
  LQueue.Free;
end;

function TFileLogger.OnThreadExecute: Boolean;
var
  LWaitObject: Cardinal;
  LEvents: array[0..1] of THandle;
begin
  Result := TRUE;
  LEvents[0] := FShouldFinishEvent;
  LEvents[1] := FLogEvent;
    while (not Terminated) do
    begin
      LWaitObject := WaitForMultipleObjects(2, @LEvents, FALSE, INFINITE);
      case (LWaitObject - WAIT_OBJECT_0) of
        0:begin
          Self.Info('Queue Processor Received Should Finish Event');
          BREAK;
        end;
        1:begin
          ResetEvent(FLogEvent);
          try
            Flush;
          except
            On E:Exception do
            begin
              Result := FALSE;
              Self.Fatal(Format('Exception In Log processing: %s', [E.Message]));
            end;
          end;
        end;
      end;
    end;
  Flush;
  SetEvent(FFinishedEvent);
end;

end.
