unit RelayClientConfig;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, WinApi.Windows, WinApi.Ole2,
  Xml.XMLIntf, Xml.XMLDoc, CommonFunctions, FileLogger;

type
  TRelayClientConfig = class
  private
    class var FConfig: TRelayClientConfig;
  protected
    FHost: String;
    FPort: WORD;
    FLogLevel: Integer;
    procedure DecodeFromXmlDoc(AXMLDocument: IXMLDocument);
    function EncodeToXmlDoc: IXMLDocument;
  public
    constructor Create(AHost:String; APort: WORD; ALogLevel: Integer); overload;
    constructor Create(ARelayClientConfig: TRelayClientConfig = nil); overload;
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    procedure LoadFromFile(AFileName: String);
    procedure SaveToFile(AFileName: String);
    class function GetDefaultConfigFile: String;
    property Host: String read FHost write FHost;
    property Port: WORD read FPort write FPort;
    property LogLevel: Integer read FLogLevel write FLogLevel;
    class property Config: TRelayClientConfig read FConfig write FConfig;
  end;

implementation

constructor TRelayClientConfig.Create(AHost:String; APort: WORD; ALogLevel: Integer);
begin
  FHost := AHost;
  FPort := APort;
  FLogLevel := ALogLevel;
end;

constructor TRelayClientConfig.Create(ARelayClientConfig: TRelayClientConfig = nil);
begin
  FHost := String.Empty;
  FPort := 322;
  FLogLevel := LOG_INFO;
  if nil <> ARelayClientConfig then
  begin
    FHost := ARelayClientConfig.Host;
    FPort := ARelayClientConfig.Port;
    FLogLevel := ARelayClientConfig.LogLevel;
  end;
end;

procedure TRelayClientConfig.DecodeFromXmlDoc(AXMLDocument: IXMLDocument);
var
  LNodeElement: IXMLNode;
begin
  LNodeElement := AXmlDocument.DocumentElement.ChildNodes.FindNode('Config');
  if (LNodeElement <> nil) then
  begin
    if (LNodeElement.HasAttribute('Host')) then
      FHost := LNodeElement.Attributes['Host'];
    if (LNodeElement.HasAttribute('Port')) then
    begin
      try
        FPort := StrToInt(LNodeElement.Attributes['Port']);
      except
        FPort := 322;
      end;
    end;
    if (LNodeElement.HasAttribute('LogLevel')) then
    begin
      try
        FLogLevel := StrToInt(LNodeElement.Attributes['LogLevel']);
        if (FLogLevel < LOG_NONE) or (LOG_DEBUG < FLogLevel) then
          FLogLevel := LOG_INFO;
      except
        FLogLevel := LOG_INFO;
      end;
    end;
  end;
end;

function TRelayClientConfig.EncodeToXmlDoc: IXMLDocument;
var
  LNodeElement, LNode: IXMLNode;
  i: Integer;
begin
  Result := TXMLDocument.Create(nil);
  Result.Active := True;
  Result.Version:='1.0';
  Result.Encoding:='utf-8';
  Result.Options := [doNodeAutoIndent];

  Result.DocumentElement := Result.CreateNode('RelayClient', ntElement, '');
  LNodeElement := Result.DocumentElement.AddChild('Config', -1);
  LNodeElement.Attributes['Host'] := FHost;
  LNodeElement.Attributes['Port'] := IntToStr(FPort);
  LNodeElement.Attributes['LogLevel'] := IntToStr(FLogLevel);
end;

procedure TRelayClientConfig.LoadFromStream(AStream: TStream);
var
  LDocument: IXMLDocument;
begin
  CoInitialize(nil);
  try
    LDocument := TXMLDocument.Create(nil);
    AStream.Seek(0, soFromBeginning);
    LDocument.LoadFromStream(AStream); { File should exist. }
    DecodeFromXmlDoc(LDocument);
  finally
    CoUninitialize;
  end;
end;

procedure TRelayClientConfig.SaveToStream(AStream: TStream);
var
  LDocument: IXMLDocument;
begin
  CoInitialize(nil);
  try
    LDocument := EncodeToXmlDoc;
    AStream.Seek(0, soFromBeginning);
    LDocument.SaveToStream(AStream);
  finally
    CoUninitialize;
  end;
end;

procedure TRelayClientConfig.LoadFromFile(AFileName: String);
var
  LStream: TStream;
begin
  if not FileExists(AFileName) then
    raise Exception.Create(String.Format('File %s does not exist', [AFileName]));

  LStream := TFileStream.Create(AFileName, fmOpenRead);
  try
    LoadFromStream(LStream);
  finally
    LStream.Free;
  end;
end;

procedure TRelayClientConfig.SaveToFile(AFileName: String);
var
  LStream: TStream;
begin
  LStream := TFileStream.Create(AFileName, fmCreate);
  try
    SaveToStream(LStream);
  finally
    LStream.Free;
  end;
end;

class function TRelayClientConfig.GetDefaultConfigFile: String;
var
  LDir: String;
begin
  LDir := String.Format('%s\%s\%s\%s', [ExcludeTrailingPathDelimiter(GetCommonAppDataDir), 'HoodedClaw', 'Checkpoint', 'RelayClient']);
  if not TDirectory.Exists(LDir) then
    TDirectory.CreateDirectory(LDir);
  Result := String.Format('%s\%s', [LDir, 'ControlCfg.xml']);
end;

end.
