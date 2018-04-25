unit GetDate;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BaseModalForm, RzButton, RzPanel,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, RzEdit, DateUtils, CommonFunctions;

type
  TfmGetDate = class(TfmBaseModalForm)
    dtDate: TRzDateTimeEdit;
  private
    { Private declarations }
    FDate: TDate;
  protected
    { Protected declarations }
    function AllOK: Boolean; override;
  public
    { Public declarations }
    constructor Create(AOwner: TComponent); override;
    property SelectedDate: TDate read FDate;
  end;

implementation

{$R *.dfm}

constructor TfmGetDate.Create(AOwner: TComponent);
var
  LYear, LMonth, LDay: WORD;
  LDate: TDateTime;
begin
  inherited Create(AOwner);
  LYear := StrToIntDef(GetFormKey('GetDate', 'Year'), 0);
  LMonth := StrToIntDef(GetFormKey('GetDate', 'Month'), 0);
  LDay := StrToIntDef(GetFormKey('GetDate', 'Day'), 0);
  if TryEncodeDate(LYear, LMonth, LDay, LDate) then
    dtDate.Date := LDate
  else
    dtDate.Date := Date;
end;

function TfmGetDate.AllOK: Boolean;
var
  LYear, LMonth, LDay: WORD;
begin
  DecodeDate(dtDate.Date, LYear, LMonth, LDay);
  SetFormKey('GetDate', 'Year', IntToStr(LYear));
  SetFormKey('GetDate', 'Month', IntToStr(LMonth));
  SetFormKey('GetDate', 'Day', IntToStr(LDay));
  FDate := dtDate.Date;
  Result := TRUE;
end;

end.
