; Inno Setup Script for i_iwara
; 注意: {{version}} 和 {{root_path}} 会在构建时被 build.py 替换

#define MyAppName "i_iwara"
#define MyAppVersion "{{version}}"
#define MyAppPublisher "i_iwara"
#define MyAppURL "https://github.com/FoxSensei001/i_iwara"
#define MyAppExeName "i_iwara.exe"

[Setup]
; 应用程序基本信息
AppId={{B8F9E8A0-1234-5678-9ABC-DEF012345678}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
; 输出配置
OutputDir={{root_path}}/build/windows
OutputBaseFilename=i_iwara-{{version}}-windows-setup
SetupIconFile={{root_path}}/windows/runner/resources/app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; 权限和架构
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64compatible

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimplified"; MessagesFile: "compiler:Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{{root_path}}/build/windows/x64/runner/Release/{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{{root_path}}/build/windows/x64/runner/Release/*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; 注意: 不要在任何共享系统文件上使用 "Flags: ignoreversion"

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
