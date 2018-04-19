unit CollectorConfig;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BaseModalForm, RzButton,
  RzPanel, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, RzEdit, RzBtnEdt,  RzLabel,
  ControllerSettings, RzRadChk, System.UITypes;

type
  TfmCollectorConfig = class(TfmBaseModalForm)
    RzLabel1: TRzLabel;
    ebLEAConfFile: TRzButtonEdit;
    odConf: TOpenDialog;
    MsgSourceID: TRzLabel;
    neMsgSourceID: TRzNumericEdit;
    RzLabel2: TRzLabel;
    neFileID: TRzNumericEdit;
    neFilePosition: TRzNumericEdit;
    RzLabel3: TRzLabel;
    ckbAudit: TRzCheckBox;
    procedure ebLEAConfFileButtonClick(Sender: TObject);
  private
    { Private declarations }
    FConfig: TCollectorConfig;
    procedure ObjectToForm;
    procedure FormToObject;
  protected
    { Protected declarations }
    function AllOK: Boolean; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AConfig: TCollectorConfig); reintroduce;
    destructor Destroy; override;
    property Config: TCollectorConfig read FConfig;
  end;

implementation

{$R *.dfm}

constructor TfmCollectorConfig.Create(AOwner: TComponent; AConfig: TCollectorConfig);
begin
  inherited Create(AOwner);
  FConfig := TCollectorConfig.Create(AConfig);
  ObjectToForm;
end;

destructor TfmCollectorConfig.Destroy;
begin
  FConfig.Free;
  inherited Destroy;
end;

procedure TfmCollectorConfig.ObjectToForm;
begin
  ebLEAConfFile.Text := FConfig.LEAConfigFile;
  neMsgSourceID.IntValue := FConfig.MsgSourceID;
  neFileID.IntValue := FConfig.FileID;
  neFilePosition.IntValue := FConfig.FilePosition;
  ckbAudit.Checked := FConfig.IsAudit;
end;

procedure TfmCollectorConfig.FormToObject;
begin
  FConfig.LEAConfigFile := ebLEAConfFile.Text;
  FConfig.MsgSourceID := neMsgSourceID.IntValue;
  FConfig.IsAudit := ckbAudit.Checked;
  if FConfig.IsAudit then
    FConfig.FileID := -1
  else
    FConfig.FileID := neFileID.IntValue;
  if FConfig.FileID < 1 then
    FConfig.FileID := -1;
  FConfig.FilePosition := neFilePosition.IntValue;
end;

function TfmCollectorConfig.AllOK: Boolean;
begin
  Result := FALSE;
  if '' = Trim(ebLEAConfFile.Text) then
  begin
    MessageDlg('You must enter an LEA Config File', mtError, [mbOK], 0);
    EXIT;
  end;
  if 1 > neMsgSourceID.IntValue then
  begin
    MessageDlg('You must enter a MsgSourceID', mtError, [mbOK], 0);
    EXIT;
  end;
  FormToObject;
  Result := TRUE;
end;

procedure TfmCollectorConfig.ebLEAConfFileButtonClick(Sender: TObject);
begin
  inherited;
  if not odConf.Execute then
    EXIT;
  ebLEAConfFile.Text := odConf.FileName;
end;

end.
