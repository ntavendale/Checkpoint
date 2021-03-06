unit RelayClientMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, RelayClientConfig, RzTabs, Vcl.ExtCtrls,
  RzPanel, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
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
  cxDataStorage, cxEdit, cxNavigator, cxGridLevel, cxGridCustomTableView,
  cxGridTableView, cxClasses, cxGridCustomView, cxGrid, LEAMsg, ConfigEdit,
  Vcl.Menus, RzBtnEdt, Vcl.StdCtrls, Vcl.Mask, RzEdit, RzLabel, System.DateUtils,
  cxInplaceContainer, cxVGrid, LEASendThread, BlockingSocket, GetDate,
  GetMsgSrcID, System.Generics.Collections, System.SyncObjs, FileLogger,
  dxSkinTheBezier, cxDataControllerConditionalFormattingRulesManagerDialog,
  dxDateRanges;

type
  TMessageWriteProc = procedure(AValue: String) of Object;
  TMessagesWriteProc = procedure(AValue: TStrings) of Object;
  TGridDataSource = class(TcxCustomDataSource)
  private
    FList: TLeaMsgList;
  protected
    function GetRecordCount: Integer; override;
    function GetValue(ARecordHandle: TcxDataRecordHandle; AItemHandle: TcxDataItemHandle): Variant; override;
  public
    constructor Create(ALeaMsgList: TLeaMsgList);
    destructor Destroy; override;
    property Messages: TLeaMsgList read FList;
  end;
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
  TfmMain = class(TForm)
    gbSettings: TRzGroupBox;
    gbMessages: TRzGroupBox;
    RzPageControl1: TRzPageControl;
    gMessages: TcxGrid;
    tvMessages: TcxGridTableView;
    colMsgSrcID: TcxGridColumn;
    colMsgDate: TcxGridColumn;
    colMsg: TcxGridColumn;
    lvMessages: TcxGridLevel;
    menMain: TMainMenu;
    Settings1: TMenuItem;
    RelayClientConfig1: TMenuItem;
    RzLabel1: TRzLabel;
    lbRelayHost: TRzLabel;
    WaitTimeout: TRzLabel;
    neRepeat: TRzNumericEdit;
    btnebFile: TRzButtonEdit;
    RzLabel2: TRzLabel;
    odFile: TOpenDialog;
    vgMsgDetail: TcxVerticalGrid;
    ppmGridMenu: TPopupMenu;
    ppmiSetMsgSrcID: TMenuItem;
    ppmiSetDate: TMenuItem;
    ppmiSendToRelay: TMenuItem;
    ppmiSendWithRepeat: TMenuItem;
    tsLog: TRzTabSheet;
    memLog: TRzMemo;
    procedure RelayClientConfig1Click(Sender: TObject);
    procedure btnebFileButtonClick(Sender: TObject);
    procedure ppmiSendToRelayClick(Sender: TObject);
    procedure ppmiSetDateClick(Sender: TObject);
    procedure ppmiSetMsgSrcIDClick(Sender: TObject);
    procedure ppmiSendWithRepeatClick(Sender: TObject);
    procedure tvMessagesSelectionChanged(Sender: TcxCustomGridTableView);
  private
    { Private declarations }
    FSendThread: TLEASendThread;
    FLogReceptionThread: TTextMessageReceptionThread;
    procedure DisplayConfig;
    procedure DisplayMessage(AMessage: String);
    procedure LoadGrid(AMsgList: TLeaMsgList);
    procedure WriteLog(AValue: String);
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

{$REGION 'TGridDataSource'}
constructor TGridDataSource.Create(ALeaMsgList: TLeaMsgList);
begin
  FList := TLeaMsgList.Create(ALeaMsgList);
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
begin
  Result := NULL;
  var LRecordIndex := Integer(ARecordHandle);
  var LRec := FList[LRecordIndex];
  if nil = LRec then
    EXIT;

  var LCloumnIndex := Integer(AItemHandle);

  case LCloumnIndex of
    0: Result := LRec.MsgSrcID;
    1: Result := LRec.NormalDateTime;
    2: Result := LRec.Msg;
  end;
end;
{$ENDREGION}

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
  LEvents: array[0..1] of THandle;
begin
  LEvents[0] := FFinishEvent;
  LEvents[1] := FMessageEvent;
  while not Terminated do
  begin
    var LWaitObject := WaitForMultipleObjects(2, @LEvents, FALSE, INFINITE);
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
    for var i := 0 to (LTempList.Count - 1) do
      FCurrentLogMessages.Add(LTempList[i]);
    Synchronize(PushMessagesToMainThread);
  end
  else if Assigned(FMessageWriteProc) then
  begin
    for var i := 0 to (LTempList.Count - 1) do
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

constructor TfmMain.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  TRelayClientConfig.Config := TRelayClientConfig.Create;
  if FileExists(TRelayClientConfig.GetDefaultConfigFile) then
    TRelayClientConfig.Config.LoadFromFile(TRelayClientConfig.GetDefaultConfigFile);

  FLogReceptionThread := TTextMessageReceptionThread.Create(TRUE);
  FLogReceptionThread.MessageWriteProc := WriteLog;
  FLogReceptionThread.FreeOnTerminate := FALSE;
  TFileLogger.SetFileLogLevel(TRelayClientConfig.Config.LogLevel, FLogReceptionThread.AddMessage);
  FLogReceptionThread.Suspended := FALSE;

  DisplayConfig;
end;

destructor TfmMain.Destroy;
begin
  FLogReceptionThread.Terminate;
  FLogReceptionThread.Free;
  inherited Destroy;
end;

procedure TfmMain.DisplayConfig;
begin
  lbRelayHost.Caption := String.Format('%s:%d', [TRelayClientConfig.Config.Host, TRelayClientConfig.Config.Port]);
end;

procedure TfmMain.DisplayMessage(AMessage: String);
begin
  var LMsgArray := AMessage.Split(['|']);
  var LLen := Length(LMsgArray);
  vgMsgDetail.BeginUpdate;
  try
    vgMsgDetail.ClearRows;

    var myCat := vgMsgDetail.Add( TcxCategoryRow ) As TcxCategoryRow;
    myCat.Properties.Caption := 'Message Detail';

    for var i := 0 to (LLen - 1) do
    begin
      var LFieldArray := LMsgArray[i].Split(['=']);
      var myRow := vgMsgDetail.Add( TcxEditorRow ) as TcxEditorRow;
      myRow.Properties.Caption := LFieldArray[0];
      myRow.Properties.DataBinding.ValueTypeClass := TcxStringValueType;
      if (2 = Length(LFieldArray)) and (not String.IsNullOrWhiteSpace(LFieldArray[1])) then
        myRow.Properties.Value := LFieldArray[1];
      myRow.Properties.Options.Editing := FALSE;
    end;
  finally
    vgMsgDetail.EndUpdate;
  end;
end;

procedure TfmMain.LoadGrid(AMsgList: TLeaMsgList);
begin
  tvMessages.BeginUpdate(lsimImmediate);
  try
    if (nil <> tvMessages.DataController.CustomDataSource) then
    begin
      TGridDataSource(tvMessages.DataController.CustomDataSource).Free;
      tvMessages.DataController.CustomDataSource := nil;
    end;

    tvMessages.DataController.BeginFullUpdate;
    try
      tvMessages.DataController.CustomDataSource := TGridDataSource.Create(AMsgList);
    finally
      tvMessages.DataController.EndFullUpdate;
    end;
  finally
    tvMessages.EndUpdate;
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.WriteLog(AValue: String);
begin
  memLog.Lines.Add(AValue);
end;

procedure TfmMain.btnebFileButtonClick(Sender: TObject);
begin
  if odFile.Execute then
    btnebFile.Text := odFile.FileName;
  Screen.Cursor := crHourglass;
  try
    var LMsgList := TLeaMsgList.Create;
    try
      LMsgList.LoadFromFile(odFile.FileName);
      LoadGrid(LMsgList);
      LogInfo(String.Format('Loaded %d messages', [LMsgList.Count]));
    finally
      LMsgList.Free;
    end;
  finally
    Screen.Cursor := crDefault;
  end;
end;

procedure TfmMain.ppmiSendToRelayClick(Sender: TObject);
var
  LMessage: AnsiString;
begin
  LMessage := '';
  for var i := 0 to (tvMessages.Controller.SelectedRecordCount - 1) do
  begin
    var LRecordIndex := tvMessages.Controller.SelectedRecords[i].RecordIndex;
    LMessage := LMessage + AnsiString(TGridDataSource(tvMessages.DataController.CustomDataSource).Messages[LRecordIndex].Msg) + AnsiChar(#03);
  end;
  if '' = LMessage then
    EXIT;
  LMessage := LMessage + #04;
  var LBuffSize := Length(LMessage);
  var LBuff: PByte := AllocMem(LBuffSize);
  var LBuffPointer := LBuff;
  try
    for var i := 1 to LBuffSize do
    begin
      LBuffPointer^ := Byte(LMessage[i]);
      Inc(LBuffPointer);
    end;
    var LSocket := TBlockingTCPSocket.Create(TRelayClientConfig.Config.Host, TRelayClientConfig.Config.Port);
    try
      LSocket.ConnectSocket;
      LSocket.SendMessage(LBuff, LBuffSize);
      LSocket.DisconnectSocket;
    finally
      LSocket.Free;
    end;
  finally
    FreeMem(LBuff);
  end;
end;

procedure TfmMain.ppmiSetDateClick(Sender: TObject);
begin
  var fm := TfmGetDate.Create(nil);
  try
    if (mrOK = fm.ShowModal) then
    begin
      tvMessages.DataController.BeginFullUpdate;
      try
        for var i := 0 to (tvMessages.Controller.SelectedRecordCount - 1) do
        begin
          var LRecordIndex := tvMessages.Controller.SelectedRecords[i].RecordIndex;
          TGridDataSource(tvMessages.DataController.CustomDataSource).Messages[LRecordIndex].LocalDateTime := fm.SelectedDate + TimeOf(TGridDataSource(tvMessages.DataController.CustomDataSource).Messages[LRecordIndex].LocalDateTime);
        end;
      finally
        tvMessages.DataController.EndFullUpdate;
      end;
      tvMessages.DataController.CustomDataSource.DataChanged;
    end;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.ppmiSetMsgSrcIDClick(Sender: TObject);
begin
  var fm := TfmGetMsgSrcID.Create(nil);
  try
    if (mrOK = fm.ShowModal) then
    begin
      tvMessages.DataController.BeginFullUpdate;
      try
        for var i := 0 to (tvMessages.Controller.SelectedRecordCount - 1) do
        begin
          var LRecordIndex := tvMessages.Controller.SelectedRecords[i].RecordIndex;
          TGridDataSource(tvMessages.DataController.CustomDataSource).Messages[LRecordIndex].MsgSrcID := fm.MsgSrcID;
        end;
      finally
        tvMessages.DataController.EndFullUpdate;
      end;
      tvMessages.DataController.CustomDataSource.DataChanged;
    end;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.ppmiSendWithRepeatClick(Sender: TObject);
begin
  if nil = FSendThread then
  begin
    var LMessage: String := String.Empty;
    for var i := 0 to (tvMessages.Controller.SelectedRecordCount - 1) do
    begin
      var LRecordIndex := tvMessages.Controller.SelectedRecords[i].RecordIndex;
      LMessage := LMessage + String(AnsiString(TGridDataSource(tvMessages.DataController.CustomDataSource).Messages[LRecordIndex].Msg)) + String(AnsiChar(#03));
    end;
    if String.IsNullOrWhiteSpace(LMessage) then
      EXIT;
    LMessage := LMessage + #04;
    FSendThread := TLEASendThread.Create(LMessage, TRelayClientConfig.Config.Host, TRelayClientConfig.Config.Port, neRepeat.IntValue);
    FSendThread.ThreadStart;
    ppmiSendWithRepeat.Caption := 'Stop Sending';
  end else
  begin
    FSendThread.ThreadStop(TRUE);
    FSendThread.Free;
    FSendThread := nil;
    ppmiSendWithRepeat.Caption := 'Send To Relay With Repeat';
  end;
end;

procedure TfmMain.RelayClientConfig1Click(Sender: TObject);
begin
  var fm := TfmConfigEdit.Create(nil, TRelayClientConfig.Config);
  try
    if mrOK = fm.ShowModal then
    begin
      TRelayClientConfig.Config.Host := fm.Config.Host;
      TRelayClientConfig.Config.Port := fm.Config.Port;
      TRelayClientConfig.Config.LogLevel := fm.Config.LogLevel;
      TRelayClientConfig.Config.SaveToFile(TRelayClientConfig.GetDefaultConfigFile);
      DisplayConfig;
    end;
  finally
    fm.Free;
  end;
end;

procedure TfmMain.tvMessagesSelectionChanged(Sender: TcxCustomGridTableView);
begin
  var LMsg: String := String.Empty;
  if 0 <> tvMessages.Controller.SelectedRecordCount then
  begin
    var LRecordIndex := tvMessages.Controller.SelectedRecords[0].RecordIndex;
    LMsg :=  String(TGridDataSource(tvMessages.DataController.CustomDataSource).Messages[LRecordIndex].Msg);
  end;
  DisplayMessage(LMsg);
end;

end.
