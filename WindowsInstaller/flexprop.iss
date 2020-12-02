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

Type: files; Name: "{%USERPROFILE}\{code:GetConfigFileName}"

[Run]
Filename: {app}\flexprop.exe;           Description: "Launch {#SHORTPROD} after installation"; Flags: nowait postinstall skipifsilent

[Code]
{===========================================================================}


const
  UninstallKeyName = 'SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\30EA9831-3B35-41B5-8D82-CE51796D014E_is1';

var
  ConfigFileName: String;


{============================================================================
  Function that returns the default configuration file name.
  This can't be a const so we put it in a function to make it easy to find.
}
function GetDefaultConfigFileName: string;
begin
  { result := '"$::env(HOME)/.' + LowerCase(ExpandConstant('{#SHORTPROD}')) + '.config"';}
  result := '"$CONFIGDIR/.' + LowerCase(ExpandConstant('{#SHORTPROD}')) + '.config"';
end;


{============================================================================
  Iterate an array of strings and find the given match string.
  Returns the line number of the first match, or -1 if not found.
}
function FindInLines(
  Lines: TArrayOfString;                { Array of lines }
  SearchStr: string;                    { String to match }
  StartLine: integer;                   { First line to start searching; top=0 }
  var Col: integer)                     { Out: column where string found; BOL=1 }
  : integer;                            { Returns line number; -1 = not found }
var
  row: integer;
  numlines: integer;
begin
  result := -1;
  numlines := GetArrayLength(Lines);

  for row := StartLine to numlines - 1 do
  begin
    Col := pos(SearchStr, Lines[row]);
    if Col <> 0 then
    begin
      result := row;
      break;
    end;
  end;
end;


{============================================================================
  Iterate an array of strings and find the given match string.
  Replace the line by the substitution string if found.
}
function ReplaceInLines(
  var Lines: TArrayOfString;            { Array of lines }
  SearchStr: string;                    { String to match }
  StartLine: integer;                   { First line to start searching; top=0 }
  ReplaceStr: string)                   { String to replace line with }
  : boolean;                            { Returns true=success }
var
  row: integer;
  dummy: integer;
begin
  row := FindInLines(Lines, SearchStr, StartLine, dummy);

  if row >= 0 then
  begin
    Log('Replacing: ' + Lines[row]);
    Log('       By: ' + ReplaceStr);

    Lines[row] := ReplaceStr;
  end
  else
  begin
    Log('Didn''t find search string so not replacing: ' + SearchStr);
  end;

  result := row >= 0;
end;


{============================================================================
  Iterate an array of strings and find the given match string.
  If found, copy the string following the matched string to the output.
  If not found, the output string is unchanged.
}  
function FindTextGetFollowing(
  Lines: TArrayOfString;                { Array of lines }
  SearchStr: string;                    { String to match }
  StartLine: integer;                   { First line to start searching; top=0 }
  var OutputStr: string)                { Text stored here; unchanged if search failed }
  : integer;                            { Returns line number; -1 = not found }
var
  col: integer;
begin
  result := FindInLines(Lines, SearchStr, 0, col);

  if result >= 0 then
  begin
    { Calculate position of string that follows search string }
    col := col + Length(SearchStr);
    OutputStr := Copy(Lines[result], col, Length(Lines[result])); { Length is too long, that's okay }
  end;
end;


{============================================================================
  Iterate an array of strings and find the given match string.
  Replace the text following the string by the substitution string if found.
}
function FindTextReplaceFollowing(
  var Lines: TArrayOfString;            { Array of lines }
  SearchStr: string;                    { String to match }
  StartLine: integer;                   { First line to start searching: top=0 }
  ReplaceStr: string)                   { String to replace text following match string }
  : integer;                            { Returns line number; -1 = not found }
var
  col: integer;
begin
  result := FindInLines(Lines, SearchStr, 0, col);

  if result >= 0 then
  begin
    Log('Replacing: ' + Lines[result]);

    { Calculate length of start of text including search string }
    col := col + Length(SearchStr) - 1;
    Lines[result] := copy(Lines[result], 1, col) + ReplaceStr;

    Log('       by: ' + Lines[result]);
  end;
end;


{============================================================================
  Initialize the global string that holds the configuration file name
}
procedure InitConfigFileName;
var
  lines: TArrayOfString;
begin
  ConfigFileName := GetDefaultConfigFileName;

  {
    If we're doing an upgrade install, get the name of the configuration 
    file from the previous installation
  }
  if (RegKeyExists(HKLM, UninstallKeyName)) then
  begin
    Log('Detected a previous install. Retrieving the old config name')

    {
      NOTE: When InnoSetup installers do an upgrade install, the default
      setting for the application directory 'app' which is defined as
      DefaultDirName above, is ignored. Instead, it uses the location of
      the previous version that's being overwritten. So the use of 'app'
      in the following code is correct.
    }
    if LoadStringsFromFile(ExpandConstant('{app}\src\gui.tcl'), lines) then
    begin
      if FindTextGetFollowing(lines, 'set CONFIG_FILE ', 0, ConfigFileName) >= 0 then
      begin
        Log('Old config file name retrieved successfully');
      end
      else
      begin
        Log('Unable to find config file setting in old TCL source; configuration may change to the default settings.');
      end;
    end
    else
    begin
      Log('Unable to read old TCL source; configuration may change to the default settings.');
    end;
  end;

  Log('Using config file name: ' + AddQuotes(ConfigFileName));
end;


{============================================================================
  Modify the TCL source code so it works with the installed version of the
  program.
}
procedure ModifyTCL(
  FileName: string);                    { TCL source file name }
var
  lines: TArrayOfString;
  row: integer;
  col: integer;
begin
  if LoadStringsFromFile(FileName, lines) then
  begin
    {
      Find the line that sets CONFIGDIR to $ROOTDIR after checking if the platform is Windows
      Replace it with blank.
    }
    row := FindInLines(lines, 'if { $tcl_platform(platform) == "windows" } {', 0, col);
    if (row >= 0) and ReplaceInLines(lines, 'set CONFIGDIR $ROOTDIR', row + 1, '') then
    begin
      Log('Successfully removed code that changes config file dir to install dir (where users have no write access)'); 
    end
    else
    begin
      Log('Unable to remove code that changes config file dir to install dir; Saving the configuration may not work. Try uninstalling before reinstalling.');
    end;

    {
      Find the line that combines the config directory and the file name.
      We replace the base name of the configuration file name to deal with
      the possibility that the TCL code changes the config file name
      over time (this happened at least once, when the application was
      renamed).
      If we do an upgrade install, we modify the TCL source code so it uses
      the old configuration file name.
    }
    row := FindTextReplaceFollowing(lines, 'set CONFIG_FILE ', 0, AddQuotes(ConfigFileName));
    if row >= 0 then
    begin
      Log('Replaced config file name initialization code with: ' + lines[row]);
    end
    else
    begin
      Log('Unable to find and/or replace config file name init code. Try uninstalling before reinstalling.');
    end;

    {
      Further modifications may be inserted here later.
    }

    {
      Save the file
    }
    if SaveStringsToFile(FileName, lines, false) then
    begin
      Log('TCL file saved to ' + AddQuotes(FileName));
    end
    else
    begin
      Log('TCL source file could not be saved. Try uninstalling and reinstalling.');
    end;
  end
  else
  begin
    Log('Unable to read gui.tcl file.');
  end;
end;


{============================================================================
  Override built-in procedure that gets called at the beginning of each
  installer step. The override is needed so we can change the configuration
  file location.
}
procedure CurStepChanged(CurStep: TSetupStep);
begin
  if (CurStep = ssInstall) then
  begin
    InitConfigFileName;
  end;

  if (CurStep = ssPostInstall) then
  begin
    ModifyTCL(ExpandConstant('{app}\src\gui.tcl'));
  end;
end;


{============================================================================
  Override built-in procedure that gets called at the beginning of each
  uninstaller step. The override is needed so we can change the configuration
  file location.
}
procedure CurUnInstallStepChanged(CurStep: TUninstallStep);
begin
  if (CurStep = usUnInstall) then
  begin
    InitConfigFileName;
  end;
end;


{============================================================================
  This provides the configuration name as a function that can be called from
  one of the other sections
}
function GetConfigFileName(dummy: string) : string;
begin
  result := ExtractFileName(ConfigFileName);
  Log('Config file base name is: ' + result);
end;


{============================================================================
  End
}
