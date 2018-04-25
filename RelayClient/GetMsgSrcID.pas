unit GetMsgSrcID;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, BaseModalForm, RzButton, RzPanel,
  Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.Mask, RzEdit, CommonFunctions;

type
  TfmGetMsgSrcID = class(TfmBaseModalForm)
    neMsgSrcID: TRzNumericEdit;
  private
    { Private declarations }
    FMsgSrcID: Integer;
  protected
    { Protected declarations }
    function AllOK: Boolean; override;
  public
    { Public declarations }
    property MsgSrcID: Integer read FMsgSrcID;
    constructor Create(AOwner: TComponent); override;
  end;

implementation

{$R *.dfm}

constructor TfmGetMsgSrcID.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  neMsgSrcID.IntValue :=  StrToIntDef(GetFormKey('MsgSrcID', 'LastSelected'), 0);
end;

function TfmGetMsgSrcID.AllOK: Boolean;
begin
  FMsgSrcID := neMsgSrcID.IntValue;
  SetFormKey('MsgSrcID', 'LastSelected', IntToStr(neMsgSrcID.IntValue));
  Result := TRUE;
end;

end.
