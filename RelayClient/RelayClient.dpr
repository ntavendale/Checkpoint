program RelayClient;

uses
  {$IFDEF EurekaLog}
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
  {$ENDIF EurekaLog}
  Vcl.Forms,
  RelayClientMain in 'RelayClientMain.pas' {fmMain},
  RelayClientConfig in 'RelayClientConfig.pas',
  CommonFunctions in '..\Common\Units\CommonFunctions.pas',
  CustomThread in '..\Common\Units\CustomThread.pas',
  FileLogger in '..\Common\Units\FileLogger.pas',
  LockableObject in '..\Common\Units\LockableObject.pas',
  BaseModalForm in '..\Common\Forms\BaseModalForm.pas' {fmBaseModalForm},
  ConfigEdit in 'ConfigEdit.pas' {fmConfigEdit},
  LEAMsg in 'LEAMsg.pas',
  BlockingSocket in '..\Common\Units\BlockingSocket.pas',
  LEASendThread in 'LEASendThread.pas',
  GetDate in 'GetDate.pas' {fmGetDate},
  GetMsgSrcID in 'GetMsgSrcID.pas' {fmGetMsgSrcID};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.

