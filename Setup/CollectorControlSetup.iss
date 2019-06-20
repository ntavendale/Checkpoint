[Setup]
; Required by Inno=
AppName=Checkpoint Controller
#define ver GetFileVersion(".\CollectorControl.exe")
AppVersion={#ver}
DefaultDirName={pf}\HoodedClaw

; Optional by Inno=
AppVerName=Checkpoint Controller {#ver}
DefaultGroupName=Checkpoint Controller
OutputBaseFilename=CheckpointControlerSetup
PrivilegesRequired=admin
LicenseFile=EULA.rtf
SetupLogging=yes
UninstallFilesDir={app}\uninstall
AppCopyright=Copyright © The Hooded Claw 2018
SetupIconFile=TheIcon.ico
; VersionInfo values for file properties=
VersionInfoCompany=The Hooded Claw
VersionInfoCopyright=© The Hooded Claw 2018
VersionInfoVersion={#ver}
VersionInfoProductVersion={#ver}
VersionInfoProductName=Checkpoint Controller
WizardImageFile=WizardImage.bmp

; "ArchitecturesAllowed=x64" specifies that Setup cannot run on
; anything but x64.
ArchitecturesAllowed=x64
; "ArchitecturesInstallIn64BitMode=x64" requests that the install be
; done in "64-bit mode" on x64, meaning it should use the native
; 64-bit Program Files directory and the 64-bit view of the registry.
ArchitecturesInstallIn64BitMode=x64

[Files]
; ***** App files *****:
Source: ".\CollectorControl.exe"; DestDir: "{app}"
Source: ".\RelayClient.exe"; DestDir: "{app}"
Source: ".\ChkptControllerInstructions.pdf"; DestDir: "{app}"

[Icons]
Name: {commonprograms}\The Hooded Claw\Checkpoint Collection Controler; Filename: {app}\CollectorControl.exe; WorkingDir: {app}
Name: {commonprograms}\The Hooded Claw\Checkpoint Relay CLient; Filename: {app}\RelayClient.exe; WorkingDir: {app}


[Code]
var
  g_bCopyInstLog: Boolean;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep = ssDone) then
    g_bCopyInstLog := True;
end;

procedure DeinitializeSetup();
begin
  if (g_bCopyInstLog) then
    FileCopy(ExpandConstant('{log}'), ExpandConstant('{app}\') + ExtractFileName(ExpandConstant('{log}')), True)
end;
