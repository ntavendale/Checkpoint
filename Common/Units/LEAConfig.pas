unit LEAConfig;

interface

uses
  System.SysUtils, System.Classes, WinApi.Windows;

const
  LOG_NONE  = 0;
  LOG_FATAL = 1;
  LOG_ERROR = 2;
  LOG_WARN  = 3;
  LOG_INFO  = 4;
  LOG_DEBUG = 5;
type
  TLEAServer = class
  protected
    FIP: String;
    FAuthPort: Integer;
    FAuthType: String;
    FOpsecEntitySicName: String;
  public
    constructor Create(ALEAServer: TLEAServer = nil); overload;
    constructor Create(AIP: String; AAuthPort: Integer; AAuthType: String; AOpsecEntitySicName: String); overload;
    property IP: String read FIP write FIP;
    property AuthPort: Integer read FAuthPort write FAuthPort;
    property AuthType: String read FAuthType write FAuthType;
    property OpsecEntitySicName: String read FOpsecEntitySicName write FOpsecEntitySicName;
  end;

  TLEAConfig = class
  protected
    FOpsecSicName: String;
    FLEAServer: TLEAServer;
    FOpsecSslcaFile: String;
    FOpsecDebug: Boolean;
    FOpsecDebugFile: String;
    FStartAtBeginning: Boolean;
    FLogLevel: Integer;
    FFlushBatchSize: Integer;
    FFlushBatchTimeout: Integer;
    FLogBufferSize: Integer;
    FRelayMode: Boolean;
    FRelayIP: String;
    FRelayPort: WORD;
    FAuditFWRecordHandler: Boolean;
    FAuditFWField: String;
    FAuditFWValue: String;
    FRecordHandlerLogging: Boolean;
    FLogTrack: String;
    procedure SetLEAServer(AValue: TLEAServer);
  public
    constructor Create(ALEAConfig: TLEAConfig = nil);
    function ToStrings: TStrings;
    procedure FromStrings(AValue: TStrings);
    procedure LoadFromFile(AValue: String);
    procedure SaveToFile(AValue: String);
    property OpsecSicName: String read FOpsecSicName write FOpsecSicName;
    property LEAServer: TLEAServer read FLEAServer write SetLEAServer;
    property OpsecSslcaFile: String read FOpsecSslcaFile write FOpsecSslcaFile;
    property OpsecDebug: Boolean read FOpsecDebug write FOpsecDebug;
    property OpsecDebugFile: String read FOpsecDebugFile write FOpsecDebugFile;
    property StartAtBeginning: Boolean read FStartAtBeginning write FStartAtBeginning;
    property LogLevel: Integer read FLogLevel write FLogLevel;
    property FlushBatchSize: Integer read FFlushBatchSize write FFlushBatchSize;
    property FlushBatchTimeout: Integer read FFlushBatchTimeout write FFlushBatchTimeout;
    property LogBufferSize: Integer read FLogBufferSize write FLogBufferSize;
    property RelayMode: Boolean read FRelayMode write FRelayMode;
    property RelayIP: String read FRelayIP write FRelayIP;
    property RelayPort: WORD read FRelayPort write FRelayPort;
    property AuditFWRecordHandler: Boolean read FAuditFWRecordHandler write FAuditFWRecordHandler;
    property AuditFWField: String read FAuditFWField write FAuditFWField;
    property AuditFWValue: String read FAuditFWValue write FAuditFWValue;
    property RecordHandlerLogging: Boolean read FRecordHandlerLogging write FRecordHandlerLogging;
    property LogTrack: String read FLogTrack write FLogTrack;
  end;

implementation

{$REGION 'TLEAServer'}
constructor TLEAServer.Create(ALEAServer: TLEAServer = nil);
begin
  FIP := String.Empty;
  FAuthPort := -1;
  FAuthType := String.Empty;
  FOpsecEntitySicName := String.Empty;
  if nil <> ALEAServer then
  begin
    FIP := ALEAServer.IP;
    FAuthPort := ALEAServer.AuthPort;
    FAuthType := ALEAServer.AuthType;
    FOpsecEntitySicName := ALEAServer.OpsecEntitySicName;
  end;
end;

constructor TLEAServer.Create(AIP: String; AAuthPort: Integer; AAuthType: String; AOpsecEntitySicName: String);
begin
  FIP := AIP;
  FAuthPort := AAuthPort;
  FAuthType := AAuthType;
  FOpsecEntitySicName := AOpsecEntitySicName;
end;
{$ENDREGION}

{$REGION 'TLEAConfig'}
constructor TLEAConfig.Create(ALEAConfig: TLEAConfig = nil);
begin
  if nil = ALEAConfig then
  begin
    FOpsecSicName := String.Empty;
    FLEAServer := TLEAServer.Create;
    FOpsecSslcaFile := String.Empty;
    FOpsecDebug := FALSE;
    FOpsecDebugFile := String.Empty;
    FStartAtBeginning := FALSE;
    FLogLevel := LOG_INFO;
    FFlushBatchSize := 10000;
    FFlushBatchTimeout := 120;
    FLogBufferSize := 2048;
    FRelayMode := FALSE;
    FRelayIP := '127.0.0.1';
    FRelayPort := 322;
    FAuditFWRecordHandler := FALSE;
    FAuditFWField := String.Empty;
    FAuditFWValue := String.Empty;
    FRecordHandlerLogging := FALSE;
    FLogTrack := 'Normal';
  end else
  begin
    FOpsecSicName := ALEAConfig.OpsecSicName;
    FLEAServer := TLEAServer.Create(ALEAConfig.LEAServer);
    FOpsecSslcaFile := ALEAConfig.OpsecSslcaFile;
    FOpsecDebug := ALEAConfig.OpsecDebug;
    FOpsecDebugFile := ALEAConfig.OpsecDebugFile;
    FStartAtBeginning := ALEAConfig.StartAtBeginning;
    FLogLevel := ALEAConfig.LogLevel;
    FFlushBatchSize := ALEAConfig.FlushBatchSize;
    FFlushBatchTimeout := ALEAConfig.FlushBatchTimeout;
    FLogBufferSize := ALEAConfig.LogBufferSize;
    FRelayMode := ALEAConfig.RelayMode;
    FRelayIP := ALEAConfig.RelayIP;
    FRelayPort := ALEAConfig.RelayPort;
    FAuditFWRecordHandler := ALEAConfig.AuditFWRecordHandler;
    FAuditFWField := ALEAConfig.AuditFWField;
    FAuditFWValue := ALEAConfig.AuditFWValue;
    FRecordHandlerLogging := ALEAConfig.RecordHandlerLogging;
    FLogTrack := ALEAConfig.LogTrack;
  end;
end;

procedure TLEAConfig.SetLEAServer(AValue: TLEAServer);
begin
  var LTemp := FLEAServer;
  FLEAServer := AValue;
  LTemp.Free;
end;

function TLEAConfig.ToStrings: TStrings;
begin
  Result := TStringList.Create;
  Result.Add(String.Format('opsec_sic_name "%s"', [FOpsecSicName.DequotedString('"')]));
  Result.Add(String.Format('lea_server ip %s', [FLEAServer.IP]));
  Result.Add(String.Format('lea_server auth_port %d', [FLEAServer.AuthPort]));
  Result.Add(String.Format('lea_server auth_type %s', [FLEAServer.AuthType]));
  Result.Add(String.Format('lea_server opsec_entity_sic_name "%s"', [FLEAServer.OpsecEntitySicName.DeQuotedString('"')]));
  Result.Add(String.Format('opsec_sslca_file "%s"', [FOpsecSslcaFile.DequotedString('"')]));
  Result.Add('');
  Result.Add('');
  Result.Add('#Below are settings used for support/debugging/testing.');
  Result.Add('');
  Result.Add('# Debug Opsec');
  Result.Add('# Need to create System Wide Environment Variable called "OPSEC_DEBUG_LEVEL"');
  Result.Add('# and set it to to a value in range 1-9 for this to work (3 is typical).');
  Result.Add('');
  if FOpsecDebug then
    Result.Add('OpsecDebug=True')
  else
    Result.Add('OpsecDebug=False');
  Result.Add('');
  Result.Add('# Debug Opsec');
  Result.Add(String.Format('OpsecDebugFile=%s', [FOpsecDebugFile.DequotedString('"')]));
  Result.Add('');
  Result.Add('# Collect From Start of the current Checkpoint log file on the Log Server.');
  Result.Add('# Default on new deployment is FileId: -1 (usually the current fw.log)');
  Result.Add('# and FilePostion -1, usually the end of the current fw.log');
  if FStartAtBeginning then
    Result.Add('StartAtBeginning=True')
  else
    Result.Add('StartAtBeginning=False');
  Result.Add('');
  Result.Add('#Log Level - Default is 4');
  Result.Add('#0=None');
  Result.Add('#1=Fatal');
  Result.Add('#2=Error');
  Result.Add('#3=Warn');
  Result.Add('#4=Info');
  Result.Add('#5=Debug');
  Result.Add(String.Format('LogLevel=%d', [FLogLevel]));
  Result.Add('');
  Result.Add('# Override Default Flush Batch Setting (Default Is 10K)');
  Result.Add(String.Format('FlushBatchSize=%d', [FFlushBatchSize]));
  Result.Add('# Override Default Flush Batch Timeout Setting (Default Is 120 Sec)');
  Result.Add(String.Format('FlushBatchTimeout=%d',[FFlushBatchTimeout]));
  Result.Add('');
  Result.Add('# Preallocated string size for log records (bytes)');
  Result.Add(String.Format('LogBufferSize=%d', [FLogBufferSize]));
  Result.Add('');
  Result.Add('# Use auditing FW Record Handler.');
  if FAuditFWRecordHandler then
  begin
    Result.Add('FWAuditMode=True');
    Result.Add(String.Format('FWAuditField=%s',[FAuditFWField]));
    Result.Add(String.Format('FWAuditValue=%s',[FAuditFWValue]));
  end else
  begin
    Result.Add('FWAuditMode=False');
    Result.Add('FWAuditField=');
    Result.Add('FWAuditValue=');
  end;
  Result.Add('');
  Result.Add('# Write Logs from Record Handlers. Requires Debug LogLevel');
  if FRecordHandlerLogging then
    Result.Add('RecordHandlerLogging=True')
  else
    Result.Add('RecordHandlerLogging=False');
  Result.Add('');
  Result.Add('# How to handle log fragments. ');
  Result.Add('# Normal: Default mode for backward compatability with ver 4.1. Same as Semi, but whith some minor midifications (docs don''t say what those are). ');
  Result.Add('# Unified: When a chain is read all it''s fragements are sent. If a new frament coome in, it is not sent. ');
  Result.Add('# Semi: When a chain is read all it''s fragements are sent. Any new framents are sent separately. ');
  Result.Add('# Raw: Each fragment sent individully to the record handler ');
  if String.IsNullOrWhiteSpace(FLogTrack) then
    Result.Add('LogTrack=Normal ')
  else
    Result.Add(String.Format('LogTrack=%s ', [FLogTrack]));

  Result.Add('');
  Result.Add('# Put Collector In Relay Mode. Do this to play logs from dump file back through.');
  Result.Add('# Causes collector to bind to IP/Port as server listening for connections.');
  Result.Add('# You need a separate application to connect and send the logs through.');
  if FRelayMode then
    Result.Add('RelayMode=True')
  else
    Result.Add('RelayMode=False');
  Result.Add(String.Format('RelayIP=%s', [FRelayIP]));
  Result.Add(String.Format('RelayPort=%d', [FRelayPort]));
end;

procedure TLEAConfig.FromStrings(AValue: TStrings);
var
  i: Integer;
  LTemp: String;
begin
  for i := 0 to (AValue.Count - 1) do
  begin
    if -1 <> AValue[i].IndexOf('opsec_sic_name') then
    begin
      LTemp := AValue[i].Replace('opsec_sic_name', '').Trim.DeQuotedString('"');
      FOpsecSicName := LTemp;
    end
    else if -1 <> AValue[i].IndexOf('lea_server ip') then
    begin
      LTemp := AValue[i].Replace('lea_server ip', '').Trim.DeQuotedString('"');
      FLEAServer.IP := LTemp;
    end
    else if -1 <> AValue[i].IndexOf('lea_server auth_port') then
    begin
      LTemp := AValue[i].Replace('lea_server auth_port', '').Trim.DeQuotedString('"');
      FLEAServer.AuthPort := StrToIntDef(LTemp, 0);
    end
    else if -1 <> AValue[i].IndexOf('lea_server auth_type') then
    begin
      LTemp := AValue[i].Replace('lea_server auth_type', '').Trim.DeQuotedString('"');
      FLEAServer.AuthType := LTemp
    end
    else if -1 <> AValue[i].IndexOf('lea_server opsec_entity_sic_name') then
    begin
      LTemp := AValue[i].Replace('lea_server opsec_entity_sic_name', '').Trim.DeQuotedString('"');
      FLEAServer.OpsecEntitySicName := LTemp
    end
    else if -1 <> AValue[i].IndexOf('opsec_sslca_file') then
    begin
      LTemp := AValue[i].Replace('opsec_sslca_file', '').Trim.DeQuotedString('"');
      FOpsecSslcaFile := LTemp
    end
    else if -1 <> AValue[i].IndexOf('OpsecDebug=') then
    begin
      LTemp := AValue[i].Replace('OpsecDebug=', '').Trim.DeQuotedString('"').ToUpper;
      FOpsecDebug := ('TRUE' = LTemp);
    end
    else if -1 <> AValue[i].IndexOf('OpsecDebugFile=') then
    begin
      LTemp := AValue[i].Replace('OpsecDebugFile=', '').Trim.DeQuotedString('"');
      FOpsecDebugFile := LTemp;
    end
    else if -1 <> AValue[i].IndexOf('StartAtBeginning=') then
    begin
      LTemp := AValue[i].Replace('StartAtBeginning=', '').Trim.DeQuotedString('"').ToUpper;
      FStartAtBeginning := ('TRUE' = LTemp);
    end
    else if -1 <> AValue[i].IndexOf('LogLevel=') then
    begin
      LTemp := AValue[i].Replace('LogLevel=', '').Trim.DeQuotedString('"').ToUpper;
      FLogLevel := StrToIntDef(LTemp, LOG_INFO);
    end
    else if -1 <> AValue[i].IndexOf('FlushBatchSize=') then
    begin
      LTemp := AValue[i].Replace('FlushBatchSize=', '').Trim.DeQuotedString('"').ToUpper;
      FFlushBatchSize := StrToIntDef(LTemp, 10000);
    end
    else if -1 <> AValue[i].IndexOf('FlushBatchTimeout=') then
    begin
      LTemp := AValue[i].Replace('FlushBatchTimeout=', '').Trim.DeQuotedString('"').ToUpper;
      FFlushBatchTimeout := StrToIntDef(LTemp, 120);
    end
    else if -1 <> AValue[i].IndexOf('LogBufferSize=') then
    begin
      LTemp := AValue[i].Replace('LogBufferSize=', '').Trim.DeQuotedString('"').ToUpper;
      FLogBufferSize := StrToIntDef(LTemp, 2048);
    end
    else if -1 <> AValue[i].IndexOf('RelayMode=') then
    begin
      LTemp := AValue[i].Replace('RelayMode=', '').Trim.DeQuotedString('"').ToUpper;
      FRelayMode := ('TRUE' = LTemp);
    end
    else if -1 <> AValue[i].IndexOf('FWAuditMode=') then
    begin
      LTemp := AValue[i].Replace('FWAuditMode=', '').Trim.DeQuotedString('"').ToUpper;
      FAuditFWRecordHandler  := ('TRUE' = LTemp);
    end
    else if -1 <> AValue[i].IndexOf('FWAuditField=') then
    begin
      LTemp := AValue[i].Replace('FWAuditField=', '').Trim.DeQuotedString('"');
      FAuditFWField := LTemp;
    end
    else if -1 <> AValue[i].IndexOf('FWAuditValue=') then
    begin
      LTemp := AValue[i].Replace('FWAuditValue=', '').Trim.DeQuotedString('"');
      FAuditFWValue := LTemp;
    end
    else if -1 <> AValue[i].IndexOf('RecordHandlerLogging=') then
    begin
      LTemp := AValue[i].Replace('RecordHandlerLogging=', '').Trim.DeQuotedString('"').ToUpper;
      FRecordHandlerLogging  := ('TRUE' = LTemp);
    end
    else if -1 <> AValue[i].IndexOf('LogTrack=') then
    begin
      LTemp := AValue[i].Replace('LogTrack=', '').Trim.DeQuotedString('"');
      if ('Semi'<>LTemp) and ('Unified'<>LTemp) and ('Raw'<>LTemp) then
        FLogTrack := 'Normal'
      else
        FLogTrack := LTemp;
    end
    else if -1 <> AValue[i].IndexOf('RelayIP=') then
    begin
      LTemp := AValue[i].Replace('RelayIP=', '').Trim.DeQuotedString('"');
      FRelayIP := LTemp;
    end
    else if -1 <> AValue[i].IndexOf('RelayPort=') then
    begin
      LTemp := AValue[i].Replace('RelayPort=', '').Trim.DeQuotedString('"').ToUpper;
      FRelayPort := StrToIntDef(LTemp, 322);
    end;
  end;
end;

procedure TLEAConfig.LoadFromFile(AValue: String);
begin
  var LFileLines := TStringList.Create;
  try
    LFileLines.LoadFromFile(AValue);
    FromStrings(LFileLines);
  finally
    LFileLines.Free;
  end;
end;

procedure TLEAConfig.SaveToFile(AValue: String);
begin
  var LFileLines := ToStrings as TStringList;
  try
    LFileLines.SaveToFile(AValue);
  finally
    LFileLines.Free;
  end;
end;
{$ENDREGION}
end.
