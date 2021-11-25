{!
<summary>
 This unit defines the helper base class and also the registry for
 the Sudoku types we support.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-10-02<p>
 Last modified       2021-11-19<p>
</history>
<remarks>
<copyright>Copyright 2021 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
</remarks>
}
unit BaseSudokuHelperU;

interface

uses SudokuInterfacesU, System.Classes;

type
  {!
  <summary>
   All Sudoku helpers descend from this base class. </summary>
  <remarks>
   All derived classes have to

     * override the abstract GetDisplayname class method to return
       a string describing the Sudoku the helper supports.
     * override the abstract CreateDatastorage method to provide a
       suitable ISudokuData implementation for the Sudoku type they
       support.
     * override the abstract CreateDisplayhandler method to provide a
       suitable ISudokuDisplay implementation for the Sudoku type they
       support.
     * override the abstract CreateInputhandler method to provide a
       suitable ISudokuInput implementation for the Sudoku type they
       support.
     * Register the helper class with the HelperRegistry in the unit
       initialization. Doing it in the class constructor does not work
       since the smart linker may remove the class if it is never
       explicitely referenced!

  </remarks>
  }
  TBaseSudokuHelper = class abstract(TInterfacedObject, ISudokuHelper)
  strict private
    FData: ISudokuData;
    FDisplay: ISudokuDisplay;
    FInputHandler: ISudokuInputHandler;
    procedure SetData(const Value: ISudokuData);
    procedure SetDisplay(const Value: ISudokuDisplay);
    function GetDisplayname2: string;
    procedure SetInputHandler(const Value: ISudokuInputHandler);
  strict protected
    procedure AddMark(const Name: string);
    function CanUndo: boolean;
    procedure ClearUndostack;
    {! Descendants must override this method to create a data storage
     appropriate for the Sudoku type they support. }
    procedure CreateDatastorage; virtual; abstract;
    {! Descendants must override this method to create a display handler
     appropriate for the Sudoku type they support. }
    procedure CreateDisplayhandler; virtual; abstract;
    {! Descendants must override this method to create an input handler
     appropriate for the Sudoku type they support. }
    procedure CreateInputHandler; virtual; abstract;
    function GetData: ISudokuData;
    function GetDisplay: ISudokuDisplay;
    function ISudokuHelper.GetDisplayname = GetDisplayname2;
    function GetInputHandler: ISudokuInputHandler;
    procedure GetMarks(aList: TStrings);
    function HasMarks: boolean;
    function IsGosu: boolean;
    function MarkExists(const aMark: string): boolean;
    procedure NewSudoku;
    procedure RevertToMark(const Name: string);
    procedure Undo;

    {!
    <value>
     Interface for the helper's data storage, for descendants
    </value>}
    property Data: ISudokuData read FData write SetData;
    {!
    <value>
     Interface for the helper's display handler, for descendants
    </value>}
    property Display: ISudokuDisplay read FDisplay write SetDisplay;
    {!
    <value>
     Interface for the helper's inpu handler handler, for descendants
    </value>}
    property InputHandler: ISudokuInputHandler read FInputHandler write
        SetInputHandler;
  public
    constructor Create; virtual;
    {! Descendants must override this method to return a descriptive
     name for the Sudoku type they support. }
    class function GetDisplayname: string; virtual; abstract;
  end;

  TBaseSudokuHelperClass = class of TBaseSudokuHelper;

  {!
  <summary>
   Public interface of the helper registry singleton. </summary>
  }
  IHelperRegistry = interface(IInterface)
  ['{8508EE84-C803-434E-B33D-DF4A1217D6B4}']
    {!
    <summary>
     Create a helper instance  </summary>
    <returns>
     the interface of the created instance</returns>
    <param name="aDisplayname">is the display name of the helper
      class to find</param>
    <exception cref="EPostconditionViolated">
     is raised if no class with the passed display name has been
     registered.</exception>
    }
    function CreateInstance(const aDisplayname: string): ISudokuHelper;
    {!
    <summary>
     Copy the display names of the registered helpers into the passed
     list. </summary>
    <param name="aList">is the list to receive the display names,
     cannot be nil.</param>
    <exception cref="EParameterCannotBeNil">
     is raised if aList is nil.</exception>
    }
    procedure GetKnownHelpers(aList: TStrings);
    {!
    <summary>
     Register a helper class. </summary>
    <param name="aHelperclass">is the class to register, cannot be nil</param>
    <exception cref="EParameterCannotBeNil">
     is raised if aHelperclass is nil.</exception>
    <remarks>
     If the passed class is already registered the method does
     nothing; this is not treated as an error.</remarks>
    }
    procedure Register(aHelperclass: TBaseSudokuHelperClass);
  end;

{!
<summary>
 Get the public interface of the helper registry singleton. </summary>
<returns>
 the interface for the helper registry.</returns>
<remarks>
 The singleton is created by the first call to this funtion and exists
 until the application terminates. The function is thread-safe.</remarks>
}
function HelperRegistry: IHelperRegistry;

implementation

uses
  System.Generics.Collections, System.SysUtils,
  PB.InterlockedOpsU, PB.CommonTypesU,
  SH_StringsU;

type
  THelperRegistry = class(TInterfacedObject, IHelperRegistry)
  strict private
    FKnownHelpers: TList<TBaseSudokuHelperClass>;
  strict protected
    function CreateInstance(const aDisplayname: string): ISudokuHelper;
    procedure GetKnownHelpers(aList: TStrings);
    procedure Register(aHelperclass: TBaseSudokuHelperClass);
  public
    constructor Create;
    destructor Destroy; override;
    property KnownHelpers: TList<TBaseSudokuHelperClass> read FKnownHelpers;
  end;

var
  InternalHelperRegistry: IHelperRegistry = nil;
  InternalShutDownInProgress: Boolean = false;

function HelperRegistry: IHelperRegistry;
var
  P: TObject;
begin
  if InternalShutDownInProgress then begin
    Result := nil;
    Assert(false, 'HelperRegistry referenced during shutdown!');
  end {if}
  else
    if Assigned(InternalHelperRegistry) then
      Result := InternalHelperRegistry
    else begin
      Result := THelperRegistry.Create;
      Result._AddRef; // the call below does not increment the refcount!
      P:= InterlockedCompareExchangeObject(InternalHelperRegistry,
        TObject(Pointer(Result)), nil);
      if P <> nil then begin
        Result._Release;
        Result := InternalHelperRegistry;
      end; {if}
    end; {else}
end; {HelperRegistry}

{== TBaseSudokuHelper =================================================}

constructor TBaseSudokuHelper.Create;
begin
  inherited;
  CreateDatastorage;
  CreateDisplayhandler;
  CreateInputHandler;
end;

{! Implements ISudokuHelper.AddMark }
procedure TBaseSudokuHelper.AddMark(const Name: string);
begin
  Data.AddMark(Name);
end;

{! Implements ISudokuHelper.CanUndo }
function TBaseSudokuHelper.CanUndo: boolean;
begin
  Result := Data.CanUndo;
end;

{! Implements ISudokuHelper.ClearUndostack }
procedure TBaseSudokuHelper.ClearUndostack;
begin
  Data.ClearUndostack;
end;

{! Implements ISudokuHelper.GetData }
function TBaseSudokuHelper.GetData: ISudokuData;
begin
  Result := FData
end;

{! Implements ISudokuHelper.GetDisplay }
function TBaseSudokuHelper.GetDisplay: ISudokuDisplay;
begin
  Result := FDisplay;
end;

{! Implements ISudokuHelper.GetDisplayname }
function TBaseSudokuHelper.GetDisplayname2: string;
begin
  Result := GetDisplayname;
end;

{! Implements ISudokuHelper.GetInputHandler }
function TBaseSudokuHelper.GetInputHandler: ISudokuInputHandler;
begin
  Result := FInputHandler;
end;

{! Implements ISudokuHelper.GetMarks }
procedure TBaseSudokuHelper.GetMarks(aList: TStrings);
begin
  Data.GetMarks(aList);
end;

{! Implements ISudokuHelper.HasMarks }
function TBaseSudokuHelper.HasMarks: boolean;
begin
  Result := Data.HasMarks;
end;

{! Implements ISudokuHelper.IsGosu }
function TBaseSudokuHelper.IsGosu: boolean;
begin
  Result := Data.IsGosu;
end;

{! Implements ISudokuHelper.MarkExists }
function TBaseSudokuHelper.MarkExists(const aMark: string): boolean;
begin
  Result := Data.MarkExists(aMark);
end;

{!
<summary>
 Create a new empty Sudoku of the supported type </summary>
<exception cref="EPreconditionViolation">
 is raised if this method is called before the display grid has
 been initialized.</exception>
<remarks>
 Implements ISudokuHelper.NewSudoku</remarks>
}
procedure TBaseSudokuHelper.NewSudoku;
begin
  Data.NewSudoku;
  if not Display.IsInitialized then
    raise EPreconditionViolation.Create(Classname+'.NewSudoku',
      SDisplayHasNotBeenInitializedYet);
  Display.Refresh;
end;

{! Implements ISudokuHelper.RevertToMark }
procedure TBaseSudokuHelper.RevertToMark(const Name: string);
begin
  Data.RevertToMark(Name);
end;

{! Setter for the Data property }
procedure TBaseSudokuHelper.SetData(const Value: ISudokuData);
begin
  if not Assigned(Value) then
    raise EParameterCannotBeNil.Create(Classname+'.SetData','Value');
  FData := Value;
end;

{! Setter for the Display property }
procedure TBaseSudokuHelper.SetDisplay(const Value: ISudokuDisplay);
begin
  if not Assigned(Value) then
    raise EParameterCannotBeNil.Create(Classname+'.SetDisplay','Value');
  FDisplay := Value;
end;

{! Setter for the InputHandler property }
procedure TBaseSudokuHelper.SetInputHandler(const Value: ISudokuInputHandler);
begin
  if not Assigned(Value) then
    raise EParameterCannotBeNil.Create(Classname+'.SetInputHandler','Value');
  FInputHandler := Value;
end;

{! Implements ISudokuHelper.Undo }
procedure TBaseSudokuHelper.Undo;
begin
  Data.Undo;
end;

{== THelperRegistry ===================================================}

constructor THelperRegistry.Create;
begin
  inherited Create;
  FKnownHelpers := TList<TBaseSudokuHelperClass>.Create;
end;

destructor THelperRegistry.Destroy;
begin
  FKnownHelpers.Free;
  inherited Destroy;
end;

function THelperRegistry.CreateInstance(const aDisplayname: string):
    ISudokuHelper;
const
  CProcName = 'THelperRegistry.CreateInstance';
var
  aClass: TBaseSudokuHelperClass;
begin
  Result := nil;
  for aClass in KnownHelpers do
    if aClass.GetDisplayname.Equals(aDisplayname) then begin
      Result := aClass.Create as ISudokuHelper;
      Break;
    end;  {if}
  if not Assigned(Result) then
    raise EPostconditionViolated.Create(CProcName, SNoHelperFound, [aDisplayname]);
end;

procedure THelperRegistry.GetKnownHelpers(aList: TStrings);
const
  CProcName = 'THelperRegistry.GetKnownHelpers';
var
  aClass: TBaseSudokuHelperClass;
begin
  if not Assigned(aList) then
    raise EParameterCannotBeNil.Create(CProcName,'aList');
  aList.BeginUpdate;
  try
    aList.Clear;
    for aClass in KnownHelpers do
      aList.Add(aClass.GetDisplayname);
  finally
    aList.EndUpdate;
  end;
end;

procedure THelperRegistry.Register(aHelperclass: TBaseSudokuHelperClass);
const
  CProcName = 'THelperRegistry.Register';
begin
  if not Assigned(aHelperclass) then
    raise EParameterCannotBeNil.Create(CProcName,'aHelperclass');
  if not KnownHelpers.Contains(aHelperclass) then
    KnownHelpers.Add(aHelperclass);
end;

initialization
finalization
  InternalShutDownInProgress := true;
  InternalHelperRegistry := nil;

end.

