unit ConfigEdit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  System.UITypes, Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BaseModalForm,
  RzButton, RzPanel, Vcl.ExtCtrls, Vcl.StdCtrls, RzCmboBx, RzEdit, Vcl.Mask, RzLabel,
  RelayClientConfig;

type
  TfmConfigEdit = class(TfmBaseModalForm)
    RzLabel1: TRzLabel;
    RzLabel2: TRzLabel;
    RzLabel3: TRzLabel;
    ebCollectorHost: TRzEdit;
    neCollectorPort: TRzNumericEdit;
    cbLogLevel: TRzComboBox;
  private
    { Private declarations }
    FConfig: TRelayClientConfig;
    procedure ObjectToForm;
    procedure FormToObject;
  protected
    { Protected declarations }
    function AllOK: Boolean; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent; AConfig: TRelayClientConfig); reintroduce;
    destructor Destroy; override;
    property Config: TRelayClientConfig read FConfig;
  end;

implementation

{$R *.dfm}

constructor TfmConfigEdit.Create(AOwner: TComponent; AConfig: TRelayClientConfig);
begin
  inherited Create(AOwner);
  FConfig := TRelayClientConfig.Create(AConfig);
  ObjectToForm;
end;

destructor TfmConfigEdit.Destroy;
begin
  FConfig.Free;
  inherited Destroy;
end;

procedure TfmConfigEdit.ObjectToForm;
begin
  ebCollectorHost.Text := FConfig.Host;
  neCollectorPort.IntValue := FConfig.Port;
  cbLogLevel.ItemIndex := FConfig.LogLevel;
end;

procedure TfmConfigEdit.FormToObject;
begin
  FConfig.Host := Trim(ebCollectorHost.Text);
  FConfig.Port := neCollectorPort.IntValue;
  FConfig.LogLevel := cbLogLevel.ItemIndex;
end;

function TfmConfigEdit.AllOK: Boolean;
begin
  Result := FALSE;
  if -1 = cbLogLevel.ItemIndex then
  begin
    MessageDlg('You must selct a log level.', mtError, [mbOK], 0);
    EXIT;
  end;

  if String.IsNullOrWhiteSpace(Trim(ebCollectorHost.Text)) then
  begin
    MessageDlg('You must enter a host.', mtError, [mbOK], 0);
    EXIT;
  end;
  FormToObject;
  Result := TRUE;
end;

end.
