; Inno Setup Script for i_iwara
; 注意: {{version}} 和 {{root_path}} 会在构建时被 build.py 替换

#define MyAppName "i_iwara"
#define MyAppVersion "{{version}}"
#define MyAppPublisher "i_iwara"
#define MyAppURL "https://github.com/FoxSensei001/i_iwara"
#define MyAppExeName "i_iwara.exe"
#define RootPath "{{root_path}}"

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
OutputDir={#RootPath}\build\windows
OutputBaseFilename=i_iwara-{#MyAppVersion}-windows-setup
SetupIconFile={#RootPath}\windows\runner\resources\app_icon.ico
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
; 权限和架构
PrivilegesRequired=lowest
ArchitecturesInstallIn64BitMode=x64compatible
; 文件关联需要更改通知
ChangesAssociations=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "chinesesimplified"; MessagesFile: "{#RootPath}\windows\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked
Name: "associatevideofiles"; Description: "Associate video files with {#MyAppName}"; GroupDescription: "File Associations:"; Flags: unchecked

[Files]
Source: "{#RootPath}\build\windows\x64\runner\Release\{#MyAppExeName}"; DestDir: "{app}"; Flags: ignoreversion
Source: "{#RootPath}\build\windows\x64\runner\Release\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs
; 注意: 不要在任何共享系统文件上使用 "Flags: ignoreversion"

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Registry]
; 注册应用程序
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}"; ValueType: string; ValueName: "FriendlyAppName"; ValueData: "{#MyAppName}"; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".mp4"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".mkv"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".avi"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".mov"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".wmv"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".flv"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".webm"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".m4v"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".3gp"; ValueData: ""; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\Applications\{#MyAppExeName}\SupportedTypes"; ValueType: string; ValueName: ".ts"; ValueData: ""; Flags: uninsdeletekey

; 注册文件关联（仅当用户选择该选项时）
; MP4
Root: HKA; Subkey: "Software\Classes\.mp4\OpenWithProgids"; ValueType: string; ValueName: "i_iwara.mp4"; ValueData: ""; Tasks: associatevideofiles; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\i_iwara.mp4"; ValueType: string; ValueName: ""; ValueData: "Video File"; Tasks: associatevideofiles; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\i_iwara.mp4\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Tasks: associatevideofiles; Flags: uninsdeletekey
; MKV
Root: HKA; Subkey: "Software\Classes\.mkv\OpenWithProgids"; ValueType: string; ValueName: "i_iwara.mkv"; ValueData: ""; Tasks: associatevideofiles; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\i_iwara.mkv"; ValueType: string; ValueName: ""; ValueData: "Video File"; Tasks: associatevideofiles; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\i_iwara.mkv\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Tasks: associatevideofiles; Flags: uninsdeletekey
; AVI
Root: HKA; Subkey: "Software\Classes\.avi\OpenWithProgids"; ValueType: string; ValueName: "i_iwara.avi"; ValueData: ""; Tasks: associatevideofiles; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\i_iwara.avi"; ValueType: string; ValueName: ""; ValueData: "Video File"; Tasks: associatevideofiles; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\i_iwara.avi\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Tasks: associatevideofiles; Flags: uninsdeletekey
; MOV
Root: HKA; Subkey: "Software\Classes\.mov\OpenWithProgids"; ValueType: string; ValueName: "i_iwara.mov"; ValueData: ""; Tasks: associatevideofiles; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\i_iwara.mov"; ValueType: string; ValueName: ""; ValueData: "Video File"; Tasks: associatevideofiles; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\i_iwara.mov\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Tasks: associatevideofiles; Flags: uninsdeletekey
; WEBM
Root: HKA; Subkey: "Software\Classes\.webm\OpenWithProgids"; ValueType: string; ValueName: "i_iwara.webm"; ValueData: ""; Tasks: associatevideofiles; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\i_iwara.webm"; ValueType: string; ValueName: ""; ValueData: "Video File"; Tasks: associatevideofiles; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\i_iwara.webm\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Tasks: associatevideofiles; Flags: uninsdeletekey
; M4V
Root: HKA; Subkey: "Software\Classes\.m4v\OpenWithProgids"; ValueType: string; ValueName: "i_iwara.m4v"; ValueData: ""; Tasks: associatevideofiles; Flags: uninsdeletevalue
Root: HKA; Subkey: "Software\Classes\i_iwara.m4v"; ValueType: string; ValueName: ""; ValueData: "Video File"; Tasks: associatevideofiles; Flags: uninsdeletekey
Root: HKA; Subkey: "Software\Classes\i_iwara.m4v\shell\open\command"; ValueType: string; ValueName: ""; ValueData: """{app}\{#MyAppExeName}"" ""%1"""; Tasks: associatevideofiles; Flags: uninsdeletekey

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent
