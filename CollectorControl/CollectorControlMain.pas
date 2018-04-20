unit CollectorControlMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, ControllerSettings,
  Vcl.ExtCtrls, RzPanel, Vcl.StdCtrls, Vcl.Mask, RzEdit, RzDBEdit, RzDBBnEd,
  RzLabel, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxStyles, dxSkinsCore, dxSkinBlack, dxSkinBlue, dxSkinBlueprint,
  dxSkinCaramel, dxSkinCoffee, dxSkinDarkRoom, dxSkinDarkSide,
  dxSkinDevExpressDarkStyle, dxSkinDevExpressStyle, dxSkinFoggy,
  dxSkinGlassOceans, dxSkinHighContrast, dxSkiniMaginary, dxSkinLilian,
  dxSkinLiquidSky, dxSkinLondonLiquidSky, dxSkinMcSkin, dxSkinMetropolis,
  dxSkinMetropolisDark, dxSkinMoneyTwins, dxSkinOffice2007Black,
  dxSkinOffice2007Blue, dxSkinOffice2007Green, dxSkinOffice2007Pink,
  dxSkinOffice2007Silver, dxSkinOffice2010Black, dxSkinOffice2010Blue,
  dxSkinOffice2010Silver, dxSkinOffice2013DarkGray, dxSkinOffice2013LightGray,
  dxSkinOffice2013White, dxSkinOffice2016Colorful, dxSkinOffice2016Dark,
  dxSkinPumpkin, dxSkinSeven, dxSkinSevenClassic, dxSkinSharp, dxSkinSharpPlus,
  dxSkinSilver, dxSkinSpringTime, dxSkinStardust, dxSkinSummer2008,
  dxSkinTheAsphaltWorld, dxSkinsDefaultPainters, dxSkinValentine,
  dxSkinVisualStudio2013Blue, dxSkinVisualStudio2013Dark,
  dxSkinVisualStudio2013Light, dxSkinVS2010, dxSkinWhiteprint,
  dxSkinXmas2008Blue, dxSkinscxPCPainter, cxCustomData, cxFilter, cxData,
  cxDataStorage, cxEdit, cxNavigator, cxGridCustomView, cxGridCustomTableView,
  cxGridTableView, cxClasses, cxGridLevel, cxGrid, Vcl.Menus, System.ImageList,
  Vcl.ImgList, RzButton, CollectorConfig, RzBtnEdt, System.UITypes,
  System.Generics.Collections, System.SyncObjs, RzTabs, FileLogger,
  ControlChannel, ReceiverChannel, cxCheckBox;

type
  TMessageWriteProc = procedure(AValue: String) of Object;
  TMessagesWriteProc = procedure(AValue: TStrings) of Object;
  TTextMessageReceptionThread = class(TThread)
    private
      FFinishEvent: THandle;
      FMessageEvent: Thandle;
      FCrticalSection: TCriticalSection;
      FCurrentLogMessage: String;
      FCurrentLogMessages: TStrings;
      FList: TList<String>;
      FMessageWriteProc: TMessageWriteProc;
      FMessagesWriteProc: TMessagesWriteProc;
      procedure PushMessageToMainThread;
      procedure PushMessagesToMainThread;
      procedure WriteMessages;
    protected
      procedure TerminatedSet; override;
      procedure Execute; override;
    public
      constructor Create; reintroduce; overload; virtual;
      constructor Create(CreateSuspended: Boolean); reintroduce; overload; virtual;
      destructor Destroy; override;
      procedure AddMessage(AValue: String);
      procedure AddMessages(AValue: TStrings); overload;
      procedure AddMessages(AValue: TArray<String>); overload;
      property MessageWriteProc: TMessageWriteProc read FMessageWriteProc write FMessageWriteProc;
      property MessagesWriteProc: TMessagesWriteProc read FMessagesWriteProc write FMessagesWriteProc;
  end;

  TGridDataSource = class(TcxCustomDataSource)
  private
    FList: TCollectorConfigList;
  protected
    function GetRecordCount: Integer; override;
    function GetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Variant; override;
  public
    constructor Create(AList: TCollectorConfigList);
    destructor Destroy; override;
    property List: TCollectorConfigList read FList;
  end;

  TfmMain = class(TForm)
    gbCollector: TRzGroupBox;
    gbControlSockets: TRzGroupBox;
    RzLabel1: TRzLabel;
    RzLabel2: TRzLabel;
    ebControlHost: TRzEdit;
    neControlPort: TRzNumericEdit;
    RzLabel3: TRzLabel;
    ebReceiverHost: TRzEdit;
    RzLabel4: TRzLabel;
    neReceiverPort: TRzNumericEdit;
    RzGroupBox1: TRzGroupBox;
    lvConfigs: TcxGridLevel;
    gConfigs: TcxGrid;
    tvConfigs: TcxGridTableView;
    colConfigOpsecFile: TcxGridColumn;
    colConfigMsgSrcID: TcxGridColumn;
    colConfigFileID: TcxGridColumn;
    colConfigFilePsition: TcxGridColumn;
    ppmConfigs: TPopupMenu;
    ilNewEditDelete: TImageList;
    ppmiNew: TMenuItem;
    ppmiEdit: TMenuItem;
    ppmiDelete: TMenuItem;
    pnBottom: TPanel;
    btnSave: TRzBitBtn;
    btnExit: TRzBitBtn;
    ebCollectorExe: TRzButtonEdit;
    ocCollectorExe: TOpenDialog;
    pcOutput: TRzPageControl;
    tsLog: TRzTabSheet;
    memLog: TRzMemo;
    tsCheckpointLogs: TRzTabSheet;
    memCheckpointLogs: TRzMemo;
    btnControl: TRzBitBtn;
    btnConnect: TRzButton;
    btnDisconnect: TRzBitBtn;
    btnCloseControlPorts: TRzBitBtn;
    colConfigsIsAudit: TcxGridColumn;
    procedure ppmiNewClick(Sender: TObject);
    procedure ppmiEditClick(Sender: TObject);
    procedure ppmiDeleteClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure ebCollectorExeButtonClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnControlClick(Sender: TObject);
    procedure btnConnectClick(Sender: TObject);
    procedure btnDisconnectClick(Sender: TObject);
    procedure btnCloseControlPortsClick(Sender: TObject);
  private
    { Private declarations }
    FLogReceptionThread: TTextMessageReceptionThread;
    FCheckpoiintLogReceptionThread: TTextMessageReceptionThread;
    procedure ControllerToForm;
    procedure FormToController;
    procedure LoadGrid(AList: TCollectorConfigList);
    procedure WriteLog(AValue: String);
    procedure WriteCheckpointMessages(AValue: TStrings);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

{$REGION 'TTextMessageReceptionThread'}
constructor TTextMessageReceptionThread.Create;
begin
  Create(TRUE);
end;

constructor TTextMessageReceptionThread.Create(CreateSuspended: Boolean);
begin
  inherited Create(CreateSuspended);
  FCrticalSection := TCriticalSection.Create;
  FFinishEvent := CreateEvent(nil, TRUE, FALSE, nil);
  FMessageEvent := CreateEvent(nil, TRUE, FALSE, nil);
  FList := TList<String>.Create;
  FCurrentLogMessages := TStringList.Create;
end;

destructor TTextMessageReceptionThread.Destroy;
begin
  FCurrentLogMessages.Clear;
  FList.Free;
  CloseHandle(FFinishEvent);
  CloseHandle(FMessageEvent);
  FCrticalSection.Release;
  FCrticalSection.Free;
  inherited Destroy;
end;

procedure TTextMessageReceptionThread.TerminatedSet;
begin
  SetEvent( FFinishEvent );
end;

procedure TTextMessageReceptionThread.Execute;
var
  LWaitObject: Cardinal;
  LEvents: array[0..1] of THandle;
begin
  LEvents[0] := FFinishEvent;
  LEvents[1] := FMessageEvent;
  while not Terminated do
  begin
    LWaitObject := WaitForMultipleObjects(2, @LEvents, FALSE, INFINITE);
    case (LWaitObject - WAIT_OBJECT_0) of
    0:begin
       BREAK;
      end;
    1:begin
       ResetEvent(FMessageEvent);
       WriteMessages;
     end;
    end;
  end;
end;

procedure TTextMessageReceptionThread.PushMessageToMainThread;
begin
  FMessageWriteProc(FCurrentLogMessage);
end;

procedure TTextMessageReceptionThread.PushMessagesToMainThread;
begin
  FMessagesWriteProc(FCurrentLogMessages);
end;

procedure TTextMessageReceptionThread.WriteMessages;
var
  LNewList, LTempList: TList<String>;
  i: Integer;
begin
  LNewList := TList<String>.Create;
  FCrticalSection.Acquire;
  try
    LTempList := FList;
    FList := LNewList;
  finally
    FCrticalSection.Release;
  end;
  if Assigned(FMessagesWriteProc) then
  begin
    FCurrentLogMessages.Clear;
    for i := 0 to (LTempList.Count - 1) do
      FCurrentLogMessages.Add(LTempList[i]);
    Synchronize(PushMessagesToMainThread);
  end
  else if Assigned(FMessageWriteProc) then
  begin
    for i := 0 to (LTempList.Count - 1) do
    begin
      FCurrentLogMessage := LTempList[i];
      Synchronize(PushMessageToMainThread);
    end;
  end;
  LTempList.Free;
end;

procedure TTextMessageReceptionThread.AddMessage(AValue: String);
begin
  FCrticalSection.Acquire;
  try
    FList.Add(AValue);
    SetEvent(FMessageEvent);
  finally
    FCrticalSection.Release;
  end;
end;

procedure TTextMessageReceptionThread.AddMessages(AValue: TStrings);
var
  i: Integer;
  LLen: Integer;
begin
  LLen := AValue.Count;
  FCrticalSection.Acquire;
  try
    for i := 0 to (LLen - 1) do
      FList.Add(AValue[i]);
    SetEvent(FMessageEvent);
  finally
    FCrticalSection.Release;
  end;
end;

procedure TTextMessageReceptionThread.AddMessages(AValue: TArray<String>);
var
  i: Integer;
  LLen: Integer;
begin
  LLen := Length(AValue);
  FCrticalSection.Acquire;
  try
    for i := 0 to (LLen - 1) do
      FList.Add(AValue[i]);
    SetEvent(FMessageEvent);
  finally
    FCrticalSection.Release;
  end;
end;

{$ENDREGION}

{$REGION 'TGridDataSource'}
constructor TGridDataSource.Create(AList: TCollectorConfigList);
begin
  FList := TCollectorConfigList.Create(AList);
end;

destructor TGridDataSource.Destroy;
begin
  FList.Free;
  inherited Destroy;
end;

function TGridDataSource.GetRecordCount: Integer;
begin
  if nil = FList then
    Result := 0
  else
    Result := FList.Count;
end;

function TGridDataSource.GetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Variant;
var
  LRec: TCollectorConfig;
  LCloumnIndex: Integer;
  LRecordIndex: Integer;
begin
  Result := NULL;
  LRecordIndex := Integer(ARecordHandle);
  LRec := FList[LRecordIndex];
  if nil = LRec then
    EXIT;

  LCloumnIndex := Integer(AItemHandle);

  case LCloumnIndex of
    0: Result := LRec.LEAConfigFile;
    1: Result := LRec.MsgSourceID;
    2: Result := LRec.FileID;
    3: Result := LRec.FilePosition;
    4: Result := LRec.IsAudit;
  end;
end;
{$ENDREGION}

constructor TfmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TControlerSettings.Settings := TControlerSettings.Create(TControlerSettings.GetDefaultConfigFile);
  TControlerSettings.Settings.Load;
  ControllerToForm;

  FLogReceptionThread := TTextMessageReceptionThread.Create(TRUE);
  FLogReceptionThread.MessageWriteProc := WriteLog;
  FLogReceptionThread.FreeOnTerminate := FALSE;
  TFileLogger.SetFileLogLevel(LOG_DEBUG, FLogReceptionThread.AddMessage);
  FLogReceptionThread.Suspended := FALSE;

  FCheckpoiintLogReceptionThread := TTextMessageReceptionThread.Create(TRUE);
  FCheckpoiintLogReceptionThread.MessagesWriteProc := WriteCheckpointMessages;
  FCheckpoiintLogReceptionThread.FreeOnTerminate := FALSE;
  FCheckpoiintLogReceptionThread.Suspended := FALSE;

  pcOutput.ActivePageIndex := 0;
  LogInfo('Started');
end;

destructor TfmMain.Destroy;
begin
  FCheckpoiintLogReceptionThread.Terminate;
  FCheckpoiintLogReceptionThread.Free;

  FLogReceptionThread.Terminate;
  FLogReceptionThread.Free;
  inherited Destroy;
end;

procedure TfmMain.ControllerToForm;
begin
  ebCollectorExe.Text := TControlerSettings.Settings.CollectorExe;
  ebControlHost.Text := TControlerSettings.Settings.ControlHost;
  neControlPort.IntValue := TControlerSettings.Settings.ControlPort;
  ebReceiverHost.Text := TControlerSettings.Settings.ReceiverHost;
  neReceiverPort.IntValue := TControlerSettings.Settings.ReceiverPort;
  LoadGrid(TControlerSettings.Settings.Configs);
end;

procedure TfmMain.FormToController;
begin
  TControlerSettings.Settings.CollectorExe := ebCollectorExe.Text;
  TControlerSettings.Settings.ControlHost := ebControlHost.Text;
  TControlerSettings.Settings.ControlPort := neControlPort.IntValue;
  TControlerSettings.Settings.ReceiverHost := ebReceiverHost.Text;
  TControlerSettings.Settings.ReceiverPort := neReceiverPort.IntValue;
  TControlerSettings.Settings.Configs := TCollectorConfigList.Create( TGridDataSource(tvConfigs.DataController.CustomDataSource).List );
end;

procedure TfmMain.LoadGrid(AList: TCollectorConfigList);
var
  LDS: TGridDataSource;
begin
  tvConfigs.BeginUpdate(lsimImmediate);
  try
    if (nil <> tvConfigs.DataController.CustomDataSource) then
    begin
      LDS := TGridDataSource(tvConfigs.DataController.CustomDataSource);
      tvConfigs.DataController.CustomDataSource := nil;
      LDS.Free;
    end;

    tvConfigs.DataController.BeginFullUpdate;
    try
      LDS := TGridDataSource.Create(AList);
      tvConfigs.DataController.CustomDataSource := LDS;
    finally
      tvConfigs.DataController.EndFullUpdate;
    end;
  finally
    tvConfigs.EndUpdate;
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.WriteLog(AValue: String);
begin
  memLog.Lines.Add(AValue);
end;

procedure TfmMain.WriteCheckpointMessages(AValue: TStrings);
begin
  if memCheckpointLogs.Lines.Count > 10000 then
    memCheckpointLogs.Lines.Clear;
  memCheckpointLogs.Lines.AddStrings(AValue);
end;

procedure TfmMain.ppmiNewClick(Sender: TObject);
var
  fm: TfmCollectorConfig;
begin
  fm := TfmCollectorConfig.Create(nil, nil);
  try
    if mrOK = fm.ShowModal then
    begin
      tvConfigs.DataController.BeginFullUpdate;
      try
        TGridDataSource(tvConfigs.DataController.CustomDataSource).List.Add( TCollectorConfig.Create(fm.Config) );
      finally
        tvConfigs.DataController.EndFullUpdate;
      end;
      tvConfigs.DataController.CustomDataSource.DataChanged;
    end;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.ppmiEditClick(Sender: TObject);
var
  fm: TfmCollectorConfig;
  LIndex: Integer;
begin
  LIndex := tvConfigs.DataController.FocusedRecordIndex;
  if LIndex < 0 then
  begin
    MessageDlg('You must select a Config.', mtError, [mbOK], 0);
    EXIT;
  end;

  fm := TfmCollectorConfig.Create(nil, TGridDataSource(tvConfigs.DataController.CustomDataSource).List[LIndex]);
  try
    if mrOK = fm.ShowModal then
    begin
      tvConfigs.DataController.BeginFullUpdate;
      try
        TGridDataSource(tvConfigs.DataController.CustomDataSource).List[LIndex] := TCollectorConfig.Create(fm.Config);
      finally
        tvConfigs.DataController.EndFullUpdate;
      end;
      tvConfigs.DataController.CustomDataSource.DataChanged;
    end;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.ppmiDeleteClick(Sender: TObject);
var
  LIndex: Integer;
begin
  LIndex := tvConfigs.DataController.FocusedRecordIndex;
  if LIndex < 0 then
  begin
    MessageDlg('You must select a Config.', mtError, [mbOK], 0);
    EXIT;
  end;

  if mrYes = MessageDlg('Delete Collector Config?', mtConfirmation, [mbYes, mbNo], 0) then
  begin
    tvConfigs.DataController.BeginFullUpdate;
    try
      TGridDataSource(tvConfigs.DataController.CustomDataSource).List.Delete(LIndex);
    finally
      tvConfigs.DataController.EndFullUpdate;
    end;
    tvConfigs.DataController.CustomDataSource.DataChanged;
  end;
end;

procedure TfmMain.btnSaveClick(Sender: TObject);
begin
  FormToController;
  TControlerSettings.Settings.Save;
  MessageDlg(String.Format('Config saved to %s', [TControlerSettings.GetDefaultConfigFile]), mtConfirmation, [mbYes, mbNo], 0)
end;

procedure TfmMain.ebCollectorExeButtonClick(Sender: TObject);
begin
  if not ocCollectorExe.Execute then
    EXIT;
  ebCollectorExe.Text := ocCollectorExe.FileName;
end;

procedure TfmMain.btnExitClick(Sender: TObject);
begin
  Application.Terminate;
end;
procedure TfmMain.btnControlClick(Sender: TObject);
begin
  if nil = TControlChannel.ControlChanel then
  begin
    TControlChannel.ControlChanel := TControlChannel.Create(TControlerSettings.Settings.ControlHost, TControlerSettings.Settings.ControlPort);
    TControlChannel.ControlChanel.ThreadStart;

    TReceiverChannel.ReceiverChanel := TReceiverChannel.Create(TControlerSettings.Settings.ReceiverHost, TControlerSettings.Settings.ReceiverPort, FCheckpoiintLogReceptionThread.AddMessages);
    TReceiverChannel.ReceiverChanel.ThreadStart;
  end;
end;

procedure TfmMain.btnConnectClick(Sender: TObject);
var
  LIndex: Integer;
  LCFG: TCollectorConfig;
begin
  if (nil = TControlChannel.ControlChanel) or (nil = TReceiverChannel.ReceiverChanel) then
  begin
    MessageDlg('Controller/Reciever not active. You must open a control port', mtError, [mbOK], 0);
    EXIT;
  end;

  LIndex := tvConfigs.DataController.FocusedRecordIndex;
  if LIndex < 0 then
  begin
    MessageDlg('You must select a Config.', mtError, [mbOK], 0);
    EXIT;
  end;

  LCFG := TGridDataSource(tvConfigs.DataController.CustomDataSource).List[LIndex];
  TControlChannel.ControlChanel.ConnectToLEA(TControlerSettings.Settings.CollectorExe, LCFG.LeaConfigFile, LCFG.MsgSourceID, LCFG.FileId, LCFG.FilePosition, LCFG.IsAudit);
  TControlChannel.ControlChanel.StartCollection(LCFG.MsgSourceID, TControlerSettings.Settings.ReceiverHost, TControlerSettings.Settings.ReceiverPort);
end;

procedure TfmMain.btnDisconnectClick(Sender: TObject);
var
  LIndex: Integer;
  LCFG: TCollectorConfig;
begin
  if (nil = TControlChannel.ControlChanel) or (nil = TReceiverChannel.ReceiverChanel) then
  begin
    MessageDlg('Controller/Reciever not active. You must open a control port', mtError, [mbOK], 0);
    EXIT;
  end;

  LIndex := tvConfigs.DataController.FocusedRecordIndex;
  if LIndex < 0 then
  begin
    MessageDlg('You must select a Config.', mtError, [mbOK], 0);
    EXIT;
  end;

  LCFG := TGridDataSource(tvConfigs.DataController.CustomDataSource).List[LIndex];
  TControlChannel.ControlChanel.StopCollection(LCFG.MsgSourceID);
end;

procedure TfmMain.btnCloseControlPortsClick(Sender: TObject);
begin
  if nil <> TControlChannel.ControlChanel then
  begin
    TControlChannel.ControlChanel.ThreadStop(TRUE);
    TReceiverChannel.ReceiverChanel.ThreadStop(TRUE);
    LogInfo('Status: Not Lisening');

    TControlChannel.ControlChanel.Free;
    TControlChannel.ControlChanel := nil;

    TReceiverChannel.ReceiverChanel.Free;
    TReceiverChannel.ReceiverChanel := nil;
  end;
end;

end.
