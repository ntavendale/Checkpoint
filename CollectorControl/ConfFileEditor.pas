unit ConfFileEditor;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BaseModalForm, RzButton, RzPanel,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, RzEdit, RzLabel, cxGraphics, cxControls,
  cxLookAndFeels, cxLookAndFeelPainters, cxStyles, cxEdit, dxSkinsCore,
  dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel, dxSkinCoffee,
  dxSkinDarkRoom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringTime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinsDefaultPainters,
  dxSkinValentine, dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, cxInplaceContainer, cxDataStorage, cxVGrid,
  LEAConfig, cxDropDownEdit, cxCheckBox, cxButtonEdit,
  dxNumericWheelPicker, cxSpinEdit, RzBtnEdt,
  cxDataControllerConditionalFormattingRulesManagerDialog, dxSkinTheBezier;

type
  TfmConfFileEditor = class(TfmBaseModalForm)
    gbAdditional: TRzGroupBox;
    opsec_sic_name: TRzLabel;
    ebOpsecSicName: TRzEdit;
    RzLabel1: TRzLabel;
    ebLeaServerIP: TRzEdit;
    RzLabel2: TRzLabel;
    neLeaServerAuthPort: TRzNumericEdit;
    RzLabel3: TRzLabel;
    ebLeaServerAuthType: TRzEdit;
    RzLabel4: TRzLabel;
    ebLeaServerOpsecEntitySicName: TRzEdit;
    vgAdditionalSettings: TcxVerticalGrid;
    catRow: TcxCategoryRow;
    rowOpsecDebug: TcxEditorRow;
    rowOpsecDebugFile: TcxEditorRow;
    rowLogLevel: TcxEditorRow;
    rowFlushBatchSize: TcxEditorRow;
    rowFlushBatchTimeout: TcxEditorRow;
    rowLogBufferSize: TcxEditorRow;
    rowRelayMode: TcxEditorRow;
    rowRelayIP: TcxEditorRow;
    rowRelayPort: TcxEditorRow;
    rowStartAtBeginning: TcxEditorRow;
    RzLabel5: TRzLabel;
    ebOpsecSslcaFile: TRzButtonEdit;
    odConf: TOpenDialog;
    sdConf: TSaveDialog;
    rowAuditFW: TcxEditorRow;
    rowAuditFWFilterField: TcxEditorRow;
    rowAuditFWFilterValue: TcxEditorRow;
    rowRecordHandlerLogging: TcxEditorRow;
    rowLogTrack: TcxEditorRow;
    procedure ebOpsecSslcaFileButtonClick(Sender: TObject);
  private
    { Private declarations }
    FConfig: TLEAConfig;
    FConfFileName: String;
    procedure ObjectToForm;
    procedure FormToObject;
    procedure SetIndexDetailGrid(AConfig: TLEAConfig);
    procedure GetIndexDetailGrid(AConfig: TLEAConfig);
  protected
    { Protected declarations }
    function AllOK: Boolean; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AConfigFile: String); reintroduce;
    destructor Destroy; override;
    property Config: TLEAConfig read FConfig;
    property ConfigFile: String read FConfFileName;
  end;

implementation

{$R *.dfm}

constructor TfmConfFileEditor.Create(AOwner: TComponent; AConfigFile: String);
begin
  inherited Create(AOwner);
  FConfig := TLEAConfig.Create;
  if not String.IsNullOrWhiteSpace(AConfigFile) then
  begin
    sdConf.FileName := AConfigFile;
    FConfig.LoadFromFile(AConfigFile);
  end;
  ObjectToForm;
end;

destructor TfmConfFileEditor.Destroy;
begin
  FConfig.Free;
  inherited Destroy;
end;

procedure TfmConfFileEditor.ObjectToForm;
begin
  ebOpsecSicName.Text := FConfig.OpsecSicName;
  ebLeaServerIP.Text := FConfig.LEAServer.IP;
  neLeaServerAuthPort.IntValue := FConfig.LEAServer.AuthPort;
  ebLeaServerAuthType.Text := FConfig.LEAServer.AuthType;
  ebLeaServerOpsecEntitySicName.Text := FConfig.LEAServer.OpsecEntitySicName;
  ebOpsecSslcaFile.Text := FConfig.OpsecSslcaFile;
  SetIndexDetailGrid(FConfig);
end;

procedure TfmConfFileEditor.FormToObject;
begin
  FConfig.OpsecSicName := ebOpsecSicName.Text;
  FConfig.LEAServer.IP := ebLeaServerIP.Text;
  FConfig.LEAServer.AuthPort := neLeaServerAuthPort.IntValue;
  FConfig.LEAServer.AuthType := ebLeaServerAuthType.Text;
  FConfig.LEAServer.OpsecEntitySicName := ebLeaServerOpsecEntitySicName.Text;
  FConfig.OpsecSslcaFile := ebOpsecSslcaFile.Text;
  GetIndexDetailGrid(FConfig);
end;

procedure TfmConfFileEditor.SetIndexDetailGrid(AConfig: TLEAConfig);
begin
  vgAdditionalSettings.BeginUpdate;
  try
    rowOpsecDebug.Properties.Value := AConfig.OpsecDebug;
    rowOpsecDebugFile.Properties.Value := AConfig.OpsecDebugFile;
    rowStartAtBeginning.Properties.Value := AConfig.StartAtBeginning;
    case AConfig.LogLevel of
      LOG_NONE: rowLogLevel.Properties.Value := 'None';
      LOG_FATAL: rowLogLevel.Properties.Value := 'Fatal';
      LOG_ERROR: rowLogLevel.Properties.Value := 'Error';
      LOG_WARN: rowLogLevel.Properties.Value := 'Warning';
      LOG_DEBUG: rowLogLevel.Properties.Value := 'Debug';
    else
      rowLogLevel.Properties.Value := 'Info';
    end;
    rowFlushBatchSize.Properties.Value := AConfig.FlushBatchSize;
    rowFlushBatchTimeout.Properties.Value := AConfig.FlushBatchTimeout;
    rowLogBufferSize.Properties.Value := AConfig.LogBufferSize;
    rowRelayMode.Properties.Value := AConfig.RelayMode;
    rowRelayIP.Properties.Value := AConfig.RelayIP;
    rowRelayPort.Properties.Value := AConfig.RelayPort;
    rowAuditFW.Properties.Value := AConfig.AuditFWRecordHandler;
    rowAuditFWFilterField.Properties.Value := AConfig.AuditFWField;
    rowAuditFWFilterValue.Properties.Value := AConfig.AuditFWValue;
    rowRecordHandlerLogging.Properties.Value := AConfig.RecordHandlerLogging;
    rowLogTrack.Properties.Value := AConfig.LogTrack;
  finally
    vgAdditionalSettings.EndUpdate;
  end;
end;

procedure TfmConfFileEditor.GetIndexDetailGrid(AConfig: TLEAConfig);
begin
  vgAdditionalSettings.BeginUpdate;
  try
    AConfig.OpsecDebug := rowOpsecDebug.Properties.Value;
    AConfig.OpsecDebugFile := rowOpsecDebugFile.Properties.Value;
    AConfig.StartAtBeginning := rowStartAtBeginning.Properties.Value;
    if 'None' = rowLogLevel.Properties.Value then
      AConfig.LogLevel := 0
    else if 'Fatal' = rowLogLevel.Properties.Value then
      AConfig.LogLevel := 1
    else if 'Error' = rowLogLevel.Properties.Value then
      AConfig.LogLevel := 2
    else if 'Warning' = rowLogLevel.Properties.Value then
      AConfig.LogLevel := 3
    else if 'Debug' = rowLogLevel.Properties.Value then
      AConfig.LogLevel := 5
    else
      AConfig.LogLevel := 4;
    AConfig.FlushBatchSize := rowFlushBatchSize.Properties.Value;
    AConfig.FlushBatchTimeout := rowFlushBatchTimeout.Properties.Value;
    AConfig.LogBufferSize := rowLogBufferSize.Properties.Value;
    AConfig.RelayMode := rowRelayMode.Properties.Value;
    AConfig.RelayIP := rowRelayIP.Properties.Value;
    AConfig.RelayPort := rowRelayPort.Properties.Value;
    AConfig.AuditFWRecordHandler := rowAuditFW.Properties.Value;
    AConfig.AuditFWField := rowAuditFWFilterField.Properties.Value;
    AConfig.AuditFWValue := rowAuditFWFilterValue.Properties.Value;
    AConfig.RecordHandlerLogging := rowRecordHandlerLogging.Properties.Value;
    AConfig.LogTrack := rowLogTrack.Properties.Value;
  finally
    vgAdditionalSettings.EndUpdate;
  end;
end;

function TfmConfFileEditor.AllOK: Boolean;
begin
  Result := FALSE;
  FormToObject;
  if not sdConf.Execute then
    EXIT;
  FConfFileName := sdConf.FileName;
  FConfig.SaveToFile(sdConf.FileName);
  Result := TRUE;
end;

procedure TfmConfFileEditor.ebOpsecSslcaFileButtonClick(Sender: TObject);
begin
  inherited;
  if not odConf.Execute then
    EXIT;
  ebOpsecSslcaFile.Text := odConf.FileName;
end;

end.
