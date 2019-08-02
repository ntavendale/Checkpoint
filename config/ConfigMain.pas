unit ConfigMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, System.IOUtils, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, cxStyles, cxEdit,
  cxCheckBox, cxDropDownEdit, cxSpinEdit, cxDataControllerConditionalFormattingRulesManagerDialog,
  dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint, dxSkinCaramel,
  dxSkinCoffee, dxSkinDarkroom, dxSkinDarkSide, dxSkinDevExpressDarkStyle,
  dxSkinDevExpressStyle, dxSkinFoggy, dxSkinGlassOceans, dxSkinHighContrast,
  dxSkiniMaginary, dxSkinLilian, dxSkinLiquidSky, dxSkinLondonLiquidSky,
  dxSkinMcSkin, dxSkinMetropolis, dxSkinMetropolisDark, dxSkinMoneyTwins,
  dxSkinOffice2007Black, dxSkinOffice2007Blue, dxSkinOffice2007Green,
  dxSkinOffice2007Pink, dxSkinOffice2007Silver, dxSkinOffice2010Black,
  dxSkinOffice2010Blue, dxSkinOffice2010Silver, dxSkinOffice2013DarkGray,
  dxSkinOffice2013LightGray, dxSkinOffice2013White, dxSkinOffice2016Colorful,
  dxSkinOffice2016Dark, dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic,
  dxSkinSharp, dxSkinSharpPlus, dxSkinSilver, dxSkinSpringtime, dxSkinStardust,
  dxSkinSummer2008, dxSkinTheAsphaltWorld, dxSkinTheBezier,
  dxSkinsDefaultPainters, dxSkinValentine, dxSkinVisualStudio2013Blue,
  dxSkinVisualStudio2013Dark, dxSkinVisualStudio2013Light, dxSkinVS2010,
  dxSkinWhiteprint, dxSkinXmas2008Blue, RzButton, RzPanel, cxVGrid,
  cxInplaceContainer, RzBtnEdt, RzEdit, Vcl.StdCtrls, Vcl.Mask, RzLabel,
  Vcl.ExtCtrls, CommonFunctions, LEAConfig, System.ImageList, Vcl.ImgList,
  Vcl.Menus, cxTextEdit;

type
  TfmMain = class(TForm)
    gbModal: TRzGroupBox;
    opsec_sic_name: TRzLabel;
    RzLabel1: TRzLabel;
    RzLabel2: TRzLabel;
    RzLabel3: TRzLabel;
    RzLabel4: TRzLabel;
    RzLabel5: TRzLabel;
    ebOpsecSicName: TRzEdit;
    ebLeaServerIP: TRzEdit;
    neLeaServerAuthPort: TRzNumericEdit;
    ebLeaServerAuthType: TRzEdit;
    ebLeaServerOpsecEntitySicName: TRzEdit;
    ebOpsecSslcaFile: TRzButtonEdit;
    gbAdditional: TRzGroupBox;
    vgAdditionalSettings: TcxVerticalGrid;
    catRow: TcxCategoryRow;
    rowOpsecDebug: TcxEditorRow;
    rowOpsecDebugFile: TcxEditorRow;
    rowStartAtBeginning: TcxEditorRow;
    rowLogLevel: TcxEditorRow;
    rowFlushBatchSize: TcxEditorRow;
    rowFlushBatchTimeout: TcxEditorRow;
    rowLogBufferSize: TcxEditorRow;
    rowRelayMode: TcxEditorRow;
    rowRelayIP: TcxEditorRow;
    rowRelayPort: TcxEditorRow;
    rowAuditFW: TcxEditorRow;
    rowAuditFWFilterField: TcxEditorRow;
    rowAuditFWFilterValue: TcxEditorRow;
    rowRecordHandlerLogging: TcxEditorRow;
    pnBottom: TRzPanel;
    pnOKCancel: TRzPanel;
    btnExit: TRzBitBtn;
    gbConfig: TRzGroupBox;
    odMain: TOpenDialog;
    ilMain: TImageList;
    menMain: TMainMenu;
    menFile: TMenuItem;
    miOpen: TMenuItem;
    miSave: TMenuItem;
    miSaveAs: TMenuItem;
    sdMain: TSaveDialog;
    ebFileName: TRzEdit;
    imgDirty: TImage;
    rowLogTrack: TcxEditorRow;
    procedure miOpenClick(Sender: TObject);
    procedure miSaveClick(Sender: TObject);
    procedure miSaveAsClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure ebOpsecSicNameChange(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    procedure LoadConfig(AFileName: String);
    procedure SaveConfig(AFileName: String; ASaveAs: Boolean);
    procedure ConfigToForm(AConfig: TLEAConfig);
    function FormToConfig: TLEAConfig;
    procedure SetIndexDetailGrid(AConfig: TLEAConfig);
    procedure GetIndexDetailGrid(AConfig: TLEAConfig);
  public
    { Public declarations }
    constructor Create(AOwner: Tcomponent); override;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

constructor TfmMain.Create(AOwner: Tcomponent);
begin
  inherited Create(AOwner);
  var LFileName := GetFormKey('Main', 'ConfFile');
  if String.IsNullOrWhiteSpace(LFileName) then
  begin
    if odMain.Execute then
      ebFileName.Text := odMain.FileName;
  end else
  begin
    ebFileName.Text := LFileName;
  end;
  if TFile.Exists(ebFileName.Text) then
    LoadConfig(ebFileName.Text);
  imgDirty.Visible := FALSE;
end;

procedure TfmMain.LoadConfig(AFileName: String);
begin
  var LConfig := TLEAConfig.Create;
  try
    LConfig.LoadFromFile(AFileName);
    ConfigToForm(LConfig);
  finally
    LConfig.Free;
  end;
end;

procedure TfmMain.SaveConfig(AFileName: String; ASaveAs: Boolean);
begin
  var LConfig := FormToConfig;
  try
    try
      LConfig.SaveToFile(AFileName);
      if ASaveAs then
        MessageDlg(String.Format('Config Save to %s', [AFileName]), mtInformation, [mbOK], 0);
      SetFormKey('Main', 'ConfFile', AFileName);
      imgDirty.Visible := FALSE;
    except on E:Exception do
      MessageDlg(String.Format('Error saving config to %s: %s', [AFileName, E.Message]), mtError, [mbOK], 0);
    end;
  finally
    LConfig.Free;
  end;
end;

procedure TfmMain.ConfigToForm(AConfig: TLEAConfig);
begin
  ebOpsecSicName.Text := AConfig.OpsecSicName;
  ebLeaServerIP.Text := AConfig.LEAServer.IP;
  neLeaServerAuthPort.IntValue := AConfig.LEAServer.AuthPort;
  ebLeaServerAuthType.Text := AConfig.LEAServer.AuthType;
  ebLeaServerOpsecEntitySicName.Text := AConfig.LEAServer.OpsecEntitySicName;
  ebOpsecSslcaFile.Text := AConfig.OpsecSslcaFile;
  SetIndexDetailGrid(AConfig);
end;

procedure TfmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if imgDirty.Visible  then
  begin
    var LModalResult := MessageDlg('Save Changes?', mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if mrYes = LModalResult then
      SaveConfig(ebFileName.Text, FALSE);
    CanClose := (mrCancel <> LModalResult);
  end else
    CanClose := TRUE;
end;

function TfmMain.FormToConfig: TLEAConfig;
begin
  Result := TLEAConfig.Create;
  Result.OpsecSicName := ebOpsecSicName.Text;
  Result.LEAServer.IP := ebLeaServerIP.Text;
  Result.LEAServer.AuthPort := neLeaServerAuthPort.IntValue;
  Result.LEAServer.AuthType := ebLeaServerAuthType.Text;
  Result.LEAServer.OpsecEntitySicName := ebLeaServerOpsecEntitySicName.Text;
  Result.OpsecSslcaFile := ebOpsecSslcaFile.Text;
  GetIndexDetailGrid(Result);
end;

procedure TfmMain.SetIndexDetailGrid(AConfig: TLEAConfig);
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

procedure TfmMain.GetIndexDetailGrid(AConfig: TLEAConfig);
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

procedure TfmMain.miOpenClick(Sender: TObject);
begin
  if not odMain.Execute then
    EXIT;

  if imgDirty.Visible then
  begin
    var LMsgDlgResult := MessageDlg(String.Format('Save changes to file %s?', [ebFileName.Text]), mtConfirmation, [mbYes, mbNo, mbCancel], 0);
    if mrCancel = LMsgDlgResult then
    begin
      EXIT;
    end
    else if mrYes = LMsgDlgResult then
    begin
      SaveConfig(ebFileName.Text, FALSE);
    end;
  end;

  ebFileName.Text := odMain.FileName;
  if TFile.Exists(ebFileName.Text) then
    LoadConfig(ebFileName.Text);

  imgDirty.Visible := FALSE;
end;

procedure TfmMain.miSaveClick(Sender: TObject);
begin
  SaveConfig(ebFileName.Text, FALSE);
end;

procedure TfmMain.miSaveAsClick(Sender: TObject);
begin
  if sdMain.Execute then
    ebFileName.Text := sdMain.FileName;
  SaveConfig(ebFileName.Text, TRUE);
end;

procedure TfmMain.btnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TfmMain.ebOpsecSicNameChange(Sender: TObject);
begin
  imgDirty.Visible := TRUE;
end;

end.
