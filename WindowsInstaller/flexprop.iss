;============================================================================
; Installer for FlexProp
; Created with Inno Setup 6.1.2.
; (C) 2019-2021 Jac Goudsmit
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
; This is the location of the directory from where the zip file is
; created.
#define SRCDIR      "..\flexprop\"

; Secondary source directory
; Some files are taken from the main tree instead of the ZIP staging tree.
; If the installer source code is ever integrated into the main tree,
; this (and references to this) can be removed.
#define SRCDIR2     "..\"

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
MinVersion=0,6.1sp1
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
CloseApplications=yes

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

; Make sure that a configuration file does NOT exist in the app directory.
; Otherwise it would take priority over the config file in the home directory.
; That would make it impossible for non-administrator users to change
; settings, since they don't have write access to the app directory.
; Note: The only way this could happen is that someone previously did a
; portable installation into the Program Files(x86) directory.
Type: files; Name: "{app}\{code:GetConfigFileName}";

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
Source:   "{#SRCDIR2}License.txt";      DestDir: "{app}";                             Flags: ignoreversion;
Source:   "{#SRCDIR2}README.md";        DestDir: "{app}";                             Flags: ignoreversion;

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

Type: files; Name: "{%USERPROFILE}\{code:GetConfigFileName}"

[Run]
Filename: {app}\flexprop.exe;           Description: "Launch {#SHORTPROD} after installation"; Flags: nowait postinstall skipifsilent

[Code]
{===========================================================================}


const
  UninstallKeyName = 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\30EA9831-3B35-41B5-8D82-CE51796D014E_is1';


{============================================================================
  This provides the configuration name as a function that can be called from
  one of the other sections
}
function GetConfigFileName(dummy: string) : string;
begin
  result := LowerCase(ExpandConstant('.{#SHORTPROD}.config'));
  Log('Config file base name is: ' + result);
end;


{============================================================================
  Initialization
}
function InitializeSetup(): Boolean;
var
  homedir: string;
  fromname: string;
  toname: string;
begin
  {
    If there is a config file with an old name in the user's home directory,
    rename it.
  }
  homedir := AddBackslash(ExpandConstant('{%USERPROFILE}'));
  fromname := homedir + '.flexgui.config';
  toname := homedir + GetConfigFileName('');
  if (FileExists(fromname)) then
  begin
    if (not FileExists(toname)) then
    begin
      Log('Renaming configuration file from ' + fromname + ' to ' + toname);

      if (not RenameFile(fromname, toname)) then
      begin
        Log('Rename failed! It may not be possible to save settings in the application.');
      end
      else
      begin
        Log('Rename successful');
      end;
    end
    else
    begin
      Log('Detected presence of both ' + fromname + ' and ' + toname + '. Deleting the old file.');
      DeleteFile(fromname);
    end;
  end
  else
  begin
    { No old file; Nothing to do }
  end;
  
  result := true;
end;


{============================================================================
  End
}
