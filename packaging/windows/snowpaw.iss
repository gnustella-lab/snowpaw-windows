; Inno Setup Script for Snowpaw (Windows x64)
; Produces an intuitive, modern, standalone GUI installer.

#define MyAppName "Snowpaw"
#define MyAppVersion "0.1.0"
#define MyAppPublisher "gnustella-lab"
#define MyAppURL "https://github.com/gnustella-lab/snowpaw-windows"
#define MyAppExeName "snowpaw.exe"
#define MyServerExeName "snowpaw-server.exe"

[Setup]
AppId={{5E79B6C2-88B1-4F43-A3B9-49722340E6E9}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\Snowpaw
DefaultGroupName={#MyAppName}
AllowNoIcons=yes
LicenseFile=..\..\LICENSE
OutputDir=..\..\dist
OutputBaseFilename=Snowpaw-v0.1.0-Windows-x64-Setup
SetupIconFile=..\snowpaw.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=lowest
PrivilegesRequiredOverridesAllowed=dialog
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "portuguese"; MessagesFile: "compiler:Languages\Portuguese.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "quicklaunchicon"; Description: "{cm:CreateQuickLaunchIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked; OnlyBelowVersion: 6.1; Check: not IsAdminInstallMode
Name: "addtopath"; Description: "Add Snowpaw CLI tools to system/user PATH"; GroupDescription: "System Integration:"

[Files]
Source: "..\..\target\release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\target\release\{#MyServerExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\target\release\snowpaw-render.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\target\release\snowpaw-agent.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\run.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\build.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\README.md"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\LICENSE"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\snowpaw.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "..\..\config\server.example.toml"; DestDir: "{app}\config"; Flags: ignoreversion

[Icons]
Name: "{group}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; IconFilename: "{app}\snowpaw.ico"
Name: "{group}\Snowpaw Server (Init & Run)"; Filename: "powershell.exe"; Parameters: "-ExecutionPolicy Bypass -NoExit -File ""{app}\run.ps1"" -Component server"; IconFilename: "{app}\snowpaw.ico"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon; IconFilename: "{app}\snowpaw.ico"

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#MyAppName}}"; Flags: nowait postinstall skipifsilent

[Registry]
; Add to user environment PATH if selected
Root: HKCU; Subkey: "Environment"; ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; Tasks: addtopath; Check: NeedsAddPath(ExpandConstant('{app}'))

[Code]
function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_CURRENT_USER, 'Environment', 'Path', OrigPath) then
  begin
    Result := True;
    exit;
  end;
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;
