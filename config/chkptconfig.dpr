program chkptconfig;

uses
  Vcl.Forms,
  ConfigMain in 'ConfigMain.pas' {fmMain},
  LEAConfig in '..\Common\Units\LEAConfig.pas',
  CommonFunctions in '..\Common\Units\CommonFunctions.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Checkpoint Config Edit';
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
