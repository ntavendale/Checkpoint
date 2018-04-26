program CollectorControl;

uses
  EMemLeaks,
  EResLeaks,
  ESendAPIFogBugz,
  EDialogWinAPIMSClassic,
  EDialogWinAPIEurekaLogDetailed,
  EDialogWinAPIStepsToReproduce,
  EDebugExports,
  EDebugJCL,
  EMapWin32,
  EAppVCL,
  ExceptionLog7,
  Vcl.Forms,
  CollectorControlMain in 'CollectorControlMain.pas' {fmMain},
  BaseSocketServer in '..\Common\Units\BaseSocketServer.pas',
  BaseSocketThread in '..\Common\Units\BaseSocketThread.pas',
  BaseModalForm in '..\Common\Forms\BaseModalForm.pas' {fmBaseModalForm},
  CollectorConfig in 'CollectorConfig.pas' {fmCollectorConfig},
  ControllerSettings in 'ControllerSettings.pas',
  ControlChannel in 'ControlChannel.pas',
  ReceiverChannel in 'ReceiverChannel.pas',
  ConfFileEditor in 'ConfFileEditor.pas' {fmConfFileEditor},
  LEAConfig in 'LEAConfig.pas',
  CommonFunctions in '..\Common\Units\CommonFunctions.pas',
  CustomThread in '..\Common\Units\CustomThread.pas',
  FileLogger in '..\Common\Units\FileLogger.pas',
  LockableObject in '..\Common\Units\LockableObject.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
