unit ControllerSettings;

interface

uses
  System.SysUtils, System.Classes, System.IOUtils, WinApi.Windows, WinApi.Ole2,
  Xml.XMLIntf, Xml.XMLDoc, System.Generics.Collections,
  CommonFunctions;

type
  TCollectorConfig = class
  protected
    FLEAConfigFile: String;
    FPort: WORD;
    FMsgSourceID: Integer;
    FFileID: Integer;
    FFilePosition: Integer;
    FIsAudit: Boolean;
  public
    constructor Create(ACollectorConfig: TCollectorConfig = nil);
    property LEAConfigFile: String read FLEAConfigFile write FLEAConfigFile;
    property Port: WORD read FPort write FPort;
    property MsgSourceID: Integer read FMsgSourceID write FMsgSourceID;
    property FileID: Integer read FFileID write FFileID;
    property FilePosition: Integer read FFilePosition write FFilePosition;
    property IsAudit: Boolean read FIsAudit write FIsAudit;
  end;

  TCollectorConfigList = class
  protected
    FList: TObjectList<TCollectorConfig>;
    function GetCount: Integer;
    function GetListItem(AIndex: Integer): TCollectorConfig;
    procedure SetListItem(AIndex: Integer; AValue: TCollectorConfig);
  public
    constructor Create(ACollectorConfigList: TCollectorConfigList = nil);
    destructor Destroy; override;
    property Count: Integer read GetCount;
    procedure Add(AValue: TCollectorConfig);
    procedure Delete(AIndex: Integer);
    property CollectorConfig[AIndex: Integer]: TCollectorConfig read GetListItem write SetListItem; default;
  end;

  TControlerSettings = class
  private
    class var FControllerSettings: TControlerSettings;
  protected
    FCollectorExe: String;
    FFileLocation: String;
    FControlHost: String;
    FControlPort: WORD;
    FReceiverHost: String;
    FReceiverPort: WORD;
    FConfigs: TCollectorConfigList;
    FWriteReceivedLogsToFile: Boolean;
    FReceivedLogFile: String;
    procedure SetConfigs(AValue: TCollectorConfigList);
  public
    constructor Create(AFileName: String);
    destructor Destroy; override;
    procedure Load;
    procedure Save;
    procedure DecodeFromXmlDoc(AXMLDocument: IXMLDocument);
    function EncodeToXmlDoc: IXMLDocument;
    property CollectorExe: String read FCollectorExe write FCollectorExe;
    property ControlHost:String read FControlHost write FControlHost;
    property ControlPort: WORD read FControlPort write FControlPort;
    property ReceiverHost: String read FReceiverHost write FReceiverHost;
    property ReceiverPort: WORD read FReceiverPort write FReceiverPort;
    property Configs: TCollectorConfigList read FConfigs write SetConfigs;
    property WriteReceivedLogsToFile: Boolean read FWriteReceivedLogsToFile write FWriteReceivedLogsToFile;
    property ReceivedLogFile: String read FReceivedLogFile write FReceivedLogFile;
    class function GetDefaultConfigFile: String;
    class property Settings: TControlerSettings read FControllerSettings write FControllerSettings;
  end;

implementation

{$REGION 'TCollectorConfig'}
constructor TCollectorConfig.Create(ACollectorConfig: TCollectorConfig = nil);
begin
  FLEAConfigFile := String.Empty;
  FPort := 0;
  FMsgSourceID := -1;
  FFileID := -1;
  FFilePosition := -1;
  FIsAudit := FALSE;
  if nil <> ACollectorConfig then
  begin
    FLEAConfigFile := ACollectorConfig.LEAConfigFile;
    FPort := ACollectorConfig.Port;
    FMsgSourceID := ACollectorConfig.MsgSourceID;
    FFileID := ACollectorConfig.FileID;
    FFilePosition := ACollectorConfig.FilePosition;
    FIsAudit := ACollectorConfig.IsAudit;
  end;
end;
{$ENDREGION}

{$REGION 'TCollectorConfigList'}
constructor TCollectorConfigList.Create(ACollectorConfigList: TCollectorConfigList = nil);
var
  i: Integer;
begin
  FList := TObjectList<TCollectorConfig>.Create(TRUE);
  if nil <> ACollectorConfigList then
  begin
    for i := 0 to (ACollectorConfigList.Count - 1) do
      FList.Add(TCollectorConfig.Create(ACollectorConfigList[i]));
  end;
end;

destructor TCollectorConfigList.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TCollectorConfigList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCollectorConfigList.GetListItem(AIndex: Integer): TCollectorConfig;
begin
  Result := FList[AIndex];
end;

procedure TCollectorConfigList.SetListItem(AIndex: Integer; AValue: TCollectorConfig);
begin
  FList[AIndex] := AValue;
end;

procedure TCollectorConfigList.Add(AValue: TCollectorConfig);
begin
  FList.Add(AValue);
end;

procedure TCollectorConfigList.Delete(AIndex: Integer);
begin
  FLIst.Delete(AIndex);
end;
{$ENDREGION}

{$REGION 'TControlerSettings'}
constructor TControlerSettings.Create(AFileName: String);
begin
  FConfigs := TCollectorConfigList.Create;
  FCollectorExe := String.Empty;
  FFileLocation := AFileName;
  FControlHost := '127.0.0.1';
  FControlPort := 3200;
  FReceiverHost := '127.0.0.1';
  FReceiverPort := 4200;
  FWriteReceivedLogsToFile := FALSE;;
  FReceivedLogFile := String.Empty;
end;

destructor TControlerSettings.Destroy;
begin
  FConfigs.Free;
  inherited Destroy;
end;

procedure TControlerSettings.SetConfigs(AValue: TCollectorConfigList);
begin
  FConfigs.Free;
  FConfigs := AValue;
end;

procedure TControlerSettings.Load;
var
  LDocument: IXMLDocument;
begin
  if not FileExists(FFileLocation) then
    EXIT;
  CoInitialize(nil);
  try
    LDocument := TXMLDocument.Create(nil);
    LDocument.LoadFromFile(FFileLocation); { File should exist. }

    DecodeFromXmlDoc(LDocument);
  finally
    CoUninitialize;
  end;
end;

procedure TControlerSettings.Save;
var
  LDocument: IXMLDocument;
begin
  CoInitialize(nil);
  try
    LDocument := EncodeToXmlDoc;
    LDocument.SaveToFile(FFileLocation); { File should exist. }
  finally
    CoUninitialize;
  end;
end;

procedure TControlerSettings.DecodeFromXmlDoc(AXMLDocument: IXMLDocument);
var
  LNodeElement, LNode: IXMLNode;
  LCfg: TCollectorConfig;
  i: Integer;
begin
  { Find a specific node. }
  LNodeElement := AXmlDocument.DocumentElement.ChildNodes.FindNode('CollectorExe');
  if (LNodeElement <> nil) then
  begin
    if (LNodeElement.HasAttribute('FullPath')) then
      FCollectorExe := LNodeElement.Attributes['FullPath'];
  end;
  LNodeElement := AXmlDocument.DocumentElement.ChildNodes.FindNode('ControlSocket');
  if (LNodeElement <> nil) then
  begin
    if (LNodeElement.HasAttribute('Host')) then
    begin
      FControlHost := LNodeElement.Attributes['Host'];
    end;
    if (LNodeElement.HasAttribute('Port')) then
    begin
      FControlPort := StrToIntDef(LNodeElement.Attributes['Port'], 3200);
    end;
  end;

  LNodeElement := AXmlDocument.DocumentElement.ChildNodes.FindNode('ReceiverSocket');
  if (LNodeElement <> nil) then
  begin
    if (LNodeElement.HasAttribute('Host')) then
    begin
      FReceiverHost := LNodeElement.Attributes['Host'];
    end;
    if (LNodeElement.HasAttribute('Port')) then
    begin
      FReceiverPort := StrToIntDef(LNodeElement.Attributes['Port'], 3200);
    end;
  end;

  LNodeElement := AXmlDocument.DocumentElement.ChildNodes.FindNode('ReceivedLogs');
  if (LNodeElement <> nil) then
  begin
    if (LNodeElement.HasAttribute('WriteToFile')) then
      FWriteReceivedLogsToFile := (('TRUE' = UpperCase(LNodeElement.Attributes['WriteToFile'])) or ('T' = UpperCase(LNodeElement.Attributes['WriteToFile'])) or ('1' = UpperCase(LNodeElement.Attributes['WriteToFile'])));
    if (LNodeElement.HasAttribute('ReceivedLogFile')) then
      FReceivedLogFile := LNodeElement.Attributes['ReceivedLogFile'];
  end;

  LNodeElement := AXmlDocument.DocumentElement.ChildNodes.FindNode('Collectors');
  if LNodeElement.HasChildNodes then
  begin
    { Traverse child nodes. }
    for i := 0 to LNodeElement.ChildNodes.Count - 1 do
    begin
      LNode := LNodeElement.ChildNodes[i];
      LCfg := TCollectorConfig.Create;
      if LNode.HasAttribute('LEAConfFile') then
        LCfg.LEAConfigFile := LNode.Attributes['LEAConfFile'];
      if LNode.HasAttribute('MsgSrcID') then
        LCfg.MsgSourceID := StrToIntDef(LNode.Attributes['MsgSrcID'], 0);
      if LNode.HasAttribute('FileID') then
        LCfg.FileID := StrToIntDef(LNode.Attributes['FileID'], -1);
      if LNode.HasAttribute('FilePosition') then
        LCfg.FilePosition := StrToIntDef(LNode.Attributes['FilePosition'], 0);
      if LNode.HasAttribute('IsAudit') then
        LCfg.IsAudit := ( ('T' = UpperCase(LNode.Attributes['IsAudit'])) or ('TRUE' = UpperCase(LNode.Attributes['IsAudit'])) or ('1' = UpperCase(LNode.Attributes['IsAudit'])) );

      FConfigs.Add(LCfg);
    end;
  end;
end;

function TControlerSettings.EncodeToXmlDoc: IXMLDocument;
var
  LNodeElement, LNode: IXMLNode;
  i: Integer;
begin
  Result := TXMLDocument.Create(nil);
  Result.Active := True;
  Result.Version:='1.0';
  Result.Encoding:='utf-8';
  Result.Options := [doNodeAutoIndent];

  Result.DocumentElement := Result.CreateNode('CollectorController', ntElement, '');
  LNodeElement := Result.DocumentElement.AddChild('CollectorExe', -1);
  LNodeElement.Attributes['FullPath'] := FCollectorExe;

  LNodeElement := Result.DocumentElement.AddChild('ControlSocket', -1);
  LNodeElement.Attributes['Host'] := FControlHost;
  LNodeElement.Attributes['Port'] := IntToStr(FControlPort);

  LNodeElement := Result.DocumentElement.AddChild('ReceiverSocket', -1);
  LNodeElement.Attributes['Host'] := FReceiverHost;
  LNodeElement.Attributes['Port'] := IntToStr(FReceiverPort);

  LNodeElement := Result.DocumentElement.AddChild('ReceivedLogs');
  if FWriteReceivedLogsToFile then
    LNodeElement.Attributes['WriteToFile'] := 'True'
  else
    LNodeElement.Attributes['WriteToFile'] := 'False';
  LNodeElement.Attributes['ReceivedLogFile'] := FReceivedLogFile;

  LNodeElement := Result.DocumentElement.AddChild('Collectors', -1);
  for i := 0 to (FConfigs.Count - 1) do
  begin
    LNode := LNodeElement.AddChild('Collector');
    LNode.Attributes['LEAConfFile'] := FConfigs[i].LEAConfigFile;
    LNode.Attributes['MsgSrcID'] := IntToStr(FConfigs[i].MsgSourceID);
    LNode.Attributes['FileID'] := IntToStr(FConfigs[i].FileID);
    LNode.Attributes['FilePosition'] := IntToStr(FConfigs[i].FilePosition);
    if FConfigs[i].IsAudit then
      LNode.Attributes['IsAudit'] := 'True'
    else
      LNode.Attributes['IsAudit'] := 'False';
  end;
end;

class function TControlerSettings.GetDefaultConfigFile: String;
var
  LDir: String;
begin
  LDir := String.Format('%s\%s\%s\%s', [ExcludeTrailingPathDelimiter(GetCommonAppDataDir), 'HoodedClaw', 'Checkpoint', 'CollectorControl']);
  if not TDirectory.Exists(LDir) then
    TDirectory.CreateDirectory(LDir);
  Result := String.Format('%s\%s', [LDir, 'ControlCfg.xml']);
end;
{$ENDREGION}
end.
