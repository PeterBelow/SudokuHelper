{!
<summary>
 This unit contains the singleton managing the app's settings.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-10-16<p>
 Last modified       2021-11-17<p>
</history>
<remarks>
<copyright>Copyright 2021 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
</remarks>
}
unit SH_MemoryU;

interface
uses
  System.Sysutils,
  Vcl.Forms;

type
  IAppMemory = interface(IInterface)
  ['{629ECBCD-CE8D-4A16-95F6-2363B967462B}']
    {! Getter for  the LastFolder property  }
    function GetLastFolder: string;
    {! Getter for  the LastSudoku property  }
    function GetLastSudoku: string;
    { !
    <summary>
     Restore the state and position of a form from stored values.</summary>
    <param name="aForm">
     is the form to restore, cannot be nil.</param>
    <exception cref="EParameterCannotBeNil">
     is raised if aForm is nil.</exception>
    }
    procedure RestoreFormState(aForm: TForm);
    { !
    <summary>
     Save the state and position of a form.</summary>
    <param name="aForm">
     is the form to save, cannot be nil.</param>
    <exception cref="EParameterCannotBeNil">
     is raised if aForm is nil.</exception>
    }
    procedure SaveFormState(aForm: TForm);
    {! Getter for  the LastFolder property  }
    procedure SetLastFolder(const Value: string);
    {! Setter for  the LastSudoku property  }
    procedure SetLastSudoku(const Value: string);
    {!
    <value>
     Last folder used to save a Sudoku to or load it from
    </value>}
    property LastFolder: string read GetLastFolder write SetLastFolder;
    {!
    <value>
     Display name of the last Sudoku type used
    </value>}
    property LastSudoku: string read GetLastSudoku write SetLastSudoku;

  end;

function AppMemory: IAppMemory;

implementation

uses
  WinAPI.Windows,
  System.Inifiles,
  System.IOUtils,
  System.RegularExpressions,
  System.Win.Registry,
  PB.CharactersU,
  PB.CommonTypesU,
  PB.InterlockedOpsU,
  PB.WinSet,
  ClassicSudokuHelperU;

const
  CDataFolder = 'SudokuHelper';
  CLastFolder = 'LastFolder';
  CLastSudokuKey = 'LastSudoku';
  CSettings = 'Settings';
  CAppRegKey = 'Software\PeterBelow\SudokuHelper';


type
  TAppMemory = class(TInterfacedObject, IAppMemory)
  strict private
    FMemory: TCustomInifile;
    function GetLastFolder: string;
    function GetLastSudoku: string;
    function GetSectionnameForForm(aForm: TForm): string; virtual;
    function NameContainsNumericSuffix(const aName: string): boolean;
    function RemoveNumericSuffix(aName: string): string;
    procedure RestoreFormState(aForm: TForm);
    procedure SaveFormState(aForm: TForm);
    procedure SetLastFolder(const Value: string);
    procedure SetLastSudoku(const Value: string);
  public
    constructor Create;
    destructor Destroy; override;
    property Memory: TCustomInifile read FMemory;
  end;

var
  InternalAppMemory: IAppMemory = nil;
  InternalShutDownInProgress: Boolean = false;

function AppMemory: IAppMemory;
var
  P: TObject;
begin
  if InternalShutDownInProgress then begin
    Result := nil;
    Assert(false, 'AppMemory referenced during shutdown!');
  end {if}
  else
  if Assigned(InternalAppMemory) then
    Result := InternalAppMemory
  else begin
    Result := TAppMemory.Create;
    Result._AddRef; // the call below does not increment the refcount!
    P:= InterlockedCompareExchangeObject(InternalAppMemory,
      TObject(Pointer(Result)), nil);
    if P <> nil then begin
      Result._Release;
      Result := InternalAppMemory;
    end; {if}
  end; {else}
end; {AppMemory}

constructor TAppMemory.Create;
var
  LAppname: string;
begin
  inherited;
  LAppname:= TPath.GetFileNameWithoutExtension(Paramstr(0));
  FMemory := TRegistryIniFile.Create(CAppRegKey + LAppname)
end;

destructor TAppMemory.Destroy;
begin
  FMemory.Free;
  inherited;
end;

function TAppMemory.GetLastFolder: string;
begin
  Result := Memory.ReadString(CSettings, CLastFolder,
    TPath.Combine(TPath.GetDocumentsPath, CDataFolder));
end;

function TAppMemory.GetLastSudoku: string;
begin
  Result := Memory.ReadString(CSettings, CLastSudokuKey, CClassicSudoku9x9);
end;

function TAppMemory.GetSectionnameForForm(aForm: TForm): string;
var
  LSection: string;
begin
  LSection := aForm.name;
  if LSection.IsEmpty then
    LSection := aform.Classname
  else if NameContainsNumericSuffix(LSection) then
    LSection := RemoveNumericSuffix(LSection);
  Result := LSection;
end;

function TAppMemory.NameContainsNumericSuffix(const aName: string): boolean;
begin
  {If more than one instance of a given form class exists the VCL will
   add a numeric suffix of the form "_#" to the form Name to create a
   unique component name. Check for that.}
  Result := TRegEx.IsMatch(aName, '^.+(_[0-9]+)$');
end;

function TAppMemory.RemoveNumericSuffix(aName: string): string;
begin
  {If more than one instance of a given form class exists the VCL will
   add a numeric suffix of the form "_#" to the form Name to create a
   unique component name. Remove that to yield the design-time form name.}
  Result := aName.Substring(0, aName.LastIndexOf(Underbar));
end;

procedure TAppMemory.RestoreFormState(aForm: TForm);
begin
  if not Assigned(aForm) then
    raise EParameterCannotBeNil.Create('TAppMemory.RestoreFormState', 'aForm');
  RestoreWindowstateEx(Memory, aForm, GetSectionnameForForm(aForm), true);
end;

procedure TAppMemory.SaveFormState(aForm: TForm);
begin
  if not Assigned(aForm) then
    raise EParameterCannotBeNil.Create('TAppMemory.SaveFormState', 'aForm');
  SaveWindowstateEx(Memory, aForm, GetSectionnameForForm(aForm), true);
end;

procedure TAppMemory.SetLastFolder(const Value: string);
begin
  Memory.WriteString(CSettings, CLastFolder, Value );
end;

procedure TAppMemory.SetLastSudoku(const Value: string);
begin
  if not Value.IsEmpty then
    Memory.WriteString(CSettings, CLastSudokuKey, Value);
end;

initialization
finalization
  InternalShutDownInProgress := true;
  InternalAppMemory := nil;
end.
