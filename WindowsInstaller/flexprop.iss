;============================================================================
; Installer for FlexProp
; Created with Inno Setup 6.0.5.
; (C) 2019-2020 Jac Goudsmit
;
; Licensed under the MIT license.
; See the file License.txt for details.
;============================================================================


;============================================================================
; The following code is meant to read the version.tcl file at compile time
; and convert it to an INI file which is used to generate the version number.

; Global variables
#define FileHandle
#define FileLine
#define IniFile = SourcePath + "tmp.ini"
#define IniSection = "Vars"

; Function to get the text in front of the first space of a string
#define BeforeSpace(Str S) \
  Local[0] = Pos(" ", S) , \
  (Local[0] ? Copy(S, 1, Local[0] - 1) : "")

; Function to get the text behind the first space of a string
#define AfterSpace(Str S) \
  Local[0] = Pos(" ", S) , \
  (Local[0] ? Copy(S, Local[0] + 1) : "")

; Function to get the text that follows a "set" Tcl command.
; Returns a blank string if the text doesn't start with "set".
#define RemoveSetCommand(Str S) \
  (Copy(S, 1, 4) == "set " ? Copy(S, 5) : "")

; Subroutine to read a line from the .tcl file and, if it's a "set" command,
; store it in an INI file.
#sub ProcessLine
  #define FileLine = RemoveSetCommand(FileRead(FileHandle))
  #if Len(FileLine)
    #define TclVar = BeforeSpace(FileLine)
    #define TclVal = AfterSpace(FileLine)
    #expr WriteIni(IniFile, IniSection, TclVar, TclVal)
    #pragma message TclVar + "=" + TclVal
  #endif
#endsub

; Preprocessor code to parse the version.tcl file at compile time
#for {FileHandle = FileOpen("..\flexprop\src\version.tcl"); \
  FileHandle && !FileEof(FileHandle); ""} \
  ProcessLine
#if FileHandle
  #expr FileClose(FileHandle)
#endif

; Shortcut to get a converted Tcl variable from the INI file
#define GetTcl(Str S) \
  ReadIni(IniFile, IniSection, S)

;============================================================================

; The Application ID is used in the registry to recognize existing
; installations. It's possible to use a name here but we use a GUID to
; prevent clashes with other applications. This should NEVER be changed.
#define APPID       "30EA9831-3B35-41B5-8D82-CE51796D014E"

; License file to use
;#define LICENSE     "License.txt"
#define LICENSE

; Source directory
; The file you are reading was designed to get its sources from this
; location.
#define SRCDIR      "..\flexprop"

; EXE file to extract version information from
#define EXE         "flexprop.exe"

; URL for more information
#define URL         "https://github.com/totalspectrum/flexprop"

; Base directory to use for installation
#define BASEDIR     "Total Spectrum Software"

; Short product name for use in directories etc.
#define SHORTPROD   "FlexProp"

; The easiest way to set the following information on the installer with
; InnoSetup is to extract it from an executable file. Unfortunately the
; product name and version number on the FlexProp executable aren't correct
; because that .exe is really just the Tcl/Tk runtime.
; In case this changes in the future, the code to extract the data is
; commented out below.
; For now, we get the version from the version.tcl instead, at compile time,
; using the InnoSetup preprocessor and the script at the top of this file.
#if 0
  ; Get the version and product name from the executable
  #define PRODNAME    GetStringFileInfo(EXE, PRODUCT_NAME)
  #define VERSION     GetStringFileInfo(EXE, FILE_VERSION)
  #define VERSIONX    VERSION
#else
  ; Get the version by parsing the TCL files at compile time,
  ; and the product name by expanding the short product name
  #define PRODNAME    SHORTPROD+" for Windows"
  #define VERSION     GetTcl("spin2gui_version_major") + "." + GetTcl("spin2gui_version_minor") + "." + GetTcl("spin2gui_version_rev")
  #define VERSIONX    VERSION + GetTcl("spin2gui_beta")
#endif

; Get the company and copyright from the executable
#define COMPANY     GetFileCompany(EXE)
#define COPYRIGHT   GetFileCopyright(EXE)

; Default directory to store projects
#define DATADIR     "{commondocs}\"+SHORTPROD

[Setup]
AppId={#APPID}
AppName={#PRODNAME}
AppVerName={#PRODNAME} {#VERSIONX}
AppVersion={#VERSIONX}
VersionInfoVersion={#VERSION}
AppCopyright={#COPYRIGHT}
SourceDir={#SRCDIR}
OutputDir=.
OutputBaseFilename={#SHORTPROD}Setup-{#VERSIONX}
AppPublisher={#COMPANY}
AppPublisherURL={#URL}
AppSupportURL={#URL}
AppUpdatesURL={#URL}
DefaultDirName={commonpf}\{#BASEDIR}\{#PRODNAME}
; Set Windows 7 as minimum required version
MinVersion=0,6.1.7600
DisableDirPage=yes
DefaultGroupName={#PRODNAME}
DisableProgramGroupPage=yes
DisableReadyPage=yes
LicenseFile={#LICENSE}
Compression=lzma/ultra
SolidCompression=yes
WizardStyle=modern
UninstallDisplayName={#PRODNAME}
PrivilegesRequired=admin

[Components]
Name: "docs";           Description: "Install Documentation";                    Types: full custom
Name: "samples";        Description: "Install Sample Code in {#DATADIR} folder"; Types: full custom

[InstallDelete]
; Any files that were ever in the Files section but are no longer in use,
; should be moved to this section.

; Files from when the program was still called "FlexGUI"
Type: files; Name: "{group}\FlexGUI for Windows.lnk";
Type: files; Name: "{app}\flexgui.exe";
Type: files; Name: "{app}\flexgui.tcl";
Type: files; Name: "{app}\src\flexgui.c";

; Files from before fastspin was renamed to flexspin
Type: files; Name: "{app}\fastspin.exe";

[Dirs]
; Create the default directory to store projects
Name:     "{#DATADIR}"

[Files]
; IMPORTANT: If any file in the distribution is no longer necessary,
; it should not only be removed from this section, but it should also
; be added to the InstallDelete section.

Source:   "flexprop.exe";               DestDir: "{app}";                             Flags: ignoreversion;
Source:   "flexprop.tcl";               DestDir: "{app}";                             Flags: ignoreversion;
Source:   "src\*";                      DestDir: "{app}\src";                         Flags: ignoreversion recursesubdirs;
Source:   "License.txt";                DestDir: "{app}";                             Flags: ignoreversion;
Source:   "README.md";                  DestDir: "{app}";                             Flags: ignoreversion;

Source:   "bin\flexcc.exe";             DestDir: "{app}\bin";                         Flags: ignoreversion;
Source:   "bin\flexspin.exe";           DestDir: "{app}\bin";                         Flags: ignoreversion
Source:   "bin\loadp2.exe";             DestDir: "{app}\bin";                         Flags: ignoreversion; 
Source:   "bin\proploader.exe";         DestDir: "{app}\bin";                         Flags: ignoreversion; 

Source:   "board\*";                    DestDir: "{app}\board";                       Flags: ignoreversion recursesubdirs; 

Source:   "doc\*";                      DestDir: "{app}\doc";                         Flags: ignoreversion recursesubdirs; Components: docs

Source:   "include\*";                  DestDir: "{app}\include";                     Flags: ignoreversion recursesubdirs;

; Samples will not be erased at uninstall time, in case the user made changes
Source:   "samples\*";                  DestDir: "{#DATADIR}\samples";                Flags: ignoreversion recursesubdirs uninsneveruninstall; Components: samples

[Icons]
Name:     "{group}\{#PRODNAME}";        Filename: "{app}\flexprop.exe"; WorkingDir: "{#DATADIR}";
Name:     "{group}\Documentation";      Filename: "{app}\doc";          WorkingDir: "{app}\doc"; Components: docs

[UninstallDelete]
; Files that should go in here are files that weren't installed by the
; installer, but need to be deleted to at uninstall time.

Type: files; Name: "{%USERPROFILE}\.flexprop.config"

[Run]
Filename: {app}\flexprop.exe;           Description: "Launch {#SHORTPROD} after installation"; Flags: nowait postinstall skipifsilent

[Code]

const
  UninstallKeyName = 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\30EA9831-3B35-41B5-8D82-CE51796D014E_is1';

var
  ConfigFileName: String;

{
  This procedure reads the give TCL source file and tries to find the
  line where the CONFIG_FILE variable is set.
  Optionally, the configuration file name is replaced by a new string.
  Keep in mind that the file name has to be in double quotes for TCL.
}
procedure ReadModifyConfigFileSetting(
  FileName: string; { TCL source file }
  var OldConfigFileName: string; { Output old config file name }
  NewConfigFileName: string); { Replacement config file name; blank=don't change }
var
  S: string;
  LineCount: Integer;
  SectionLine: Integer;    
  Lines: TArrayOfString;
  Replaced: Boolean;
begin
  if LoadStringsFromFile(FileName, Lines) then
  begin
    Log('Reading or changing file: ' + FileName);
    LineCount := GetArrayLength(Lines);
    for SectionLine := 0 to LineCount - 1 do
    begin
      S := Lines[SectionLine];

      if (Copy(S, 1, 16) = 'set CONFIG_FILE ') then
      begin
        Log('CONFIG location found: ' + S);
        OldConfigFileName := Copy(Lines[SectionLine], 17, 256);
        Replaced := (Length(NewConfigFileName) <> 0)
        if (Replaced) then
        begin
          Lines[Sectionline] := 'set CONFIG_FILE ' + NewConfigFileName;
          Log('Replaced by: ' + Lines[SectionLine]);
        end;
        Break;
      end;
    end;
    if (Replaced) then
    begin
      SaveStringsToFile(FileName, Lines, False);
    end;
  end;
end;


{
  Override for built-in procedure that gets called at the beginning of each
  installer step. The override is needed so we can change the configuration
  file location.
}
procedure CurStepChanged(CurStep: TSetupStep);
var
  Dummy : String;
begin
  if (CurStep = ssInstall) then
  begin
    { Initialize the configuration file name }
    ConfigFileName := '"$::env(HOME)/.' + LowerCase(ExpandConstant('{#SHORTPROD}')) + '.config"';

    {
      If we're doing an upgrade install, get the name of the configuration 
      file from the previous installation
    }
    if (RegKeyExists(HKLM, UninstallKeyName)) then
    begin
      Log('Detected an upgrade install. Retrieving the old config name')
      ReadModifyConfigFileSetting(ExpandConstant('{app}\src\gui.tcl'), ConfigFileName, '');
    end;
  end;

  if (CurStep = ssPostInstall) then
  begin
    {
      After the installation, update the configuration file name in the newly
      installed TCL source code.
    }
    Log('Replacing config file name');
    ReadModifyConfigFileSetting(ExpandConstant('{app}\src\gui.tcl'), Dummy, ConfigFileName);
  end;
end;
