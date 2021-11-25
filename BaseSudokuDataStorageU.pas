{!
<summary>
 This unit implements the base class of the data storage the Sudoku
 helpers use to manage the content of a Sudoku.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-10-03<p>
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
unit BaseSudokuDataStorageU;

interface

uses
  System.Classes,
  System.Generics.Collections,
  SudokuInterfacesU;

type
  TSudokuCell = record
    Value: TSudokuValue;
    Candidates: TSudokuValues;
    Valid: boolean;
    EvenOnly: boolean;  // for Sudoku Gosu
  public
    procedure Clear;
    function IsEmpty: boolean;
  end;
  PSudokuCell = ^TSudokuCell;
  {Indexing is [Column, Row]!}
  TSudokuCells = array [TSudokuCellIndex,TSudokuCellIndex] of TSudokuCell;

type
  { The Sudoku blocks form a 2D array, but the dimensions depend on the
    type of Sudoku. For a classic 9x9 Sudoku the blocks form a 3x3 array,
    for a 12x12 Sudoku a 3x4 array, for a 16x16 Sudoku a 4x4 array.
    The block definitions are static, and using dynamic arrays we can
    handle them in the base datastorage class.  All the descendants
    have to supply are the block width and height.
  }

  TSudokuBlockEntry = record
     Col, Row: TSudokuCellIndex;
     Location: TCellInBlockLocation;
     BlocksCol, BlocksRow: integer;
  public
     function Matches(aCol, aRow: TSudokuCellIndex): boolean;
  end;
  TSudokuBlockRow = array of TSudokuBlockEntry;
  TSudokuBlock = array of TSudokuBlockRow;
  TSudokuBlocksRow = array of TSudokuBlock;
  TSudokuBlocks = array of TSudokuBlocksRow;


{!
<summary>
 The data storage for a specific Sudoku type will descend from this
 class. </summary>
<remarks>
 Sudokus are square but they differ in the number of allowed values, the
 number of cells in a row (and column), and the size of a block. This makes
 it difficult to come up with a data structure that can both be copied
 en bloc (necessary for an efficient undo stack design), can be used
 for different types of Sudokus, and is type-safe as well.

 I decided to go with a fixed-size cell data approach, supporting at
 max a 16x16 Sudoku, which is about the largest practical. This wastes
 some memory space for smaller Sudokus, but I deemed that to be acceptable.
  </remarks>
  }
TBaseSudokuDatastorage = class abstract(
    TInterfacedObject, ISudokuData, ISudokuDataEvents, ISudokuProperties)
strict protected
type
  {! This class wraps a cell in the Sudoku and gives access to it via its
     ISudokuCell interface. }
  TSudokuCellHelper = class(TInterfacedObject, ISudokuCell)
  strict private
  var
    FCellRef: PSudokuCell;
    FCol: TSudokuCellIndex;
    FOwner: TBaseSudokuDatastorage;
    FRow: TSudokuCellIndex;
  strict protected
  type
    TCellOp = reference to procedure (var aCell: TSudokuCell);
    procedure AddCandidate(aValue: TSudokuValue);
    procedure Clear;
    procedure DoCellOp(aProc: TCellOp);
    function GetBlockLocation: TCellInBlockLocation;
    function GetCandidates: TSudokuValues;
    function GetCol: TSudokuCellIndex;
    function GetEvenOnly: Boolean;
    function GetRow: TSudokuCellIndex;
    function GetValue: TSudokuValue;
    function IsEmpty: Boolean;
    function IsValid: Boolean;
    procedure RemoveCandidate(aValue: TSudokuValue);
    procedure SetValue(const aValue: TSudokuValue);
    procedure ToggleEvenOnly;
  public
    constructor Create(aCol, aRow: TSudokuCellIndex; var aCell: TSudokuCell;
        aOwner: TBaseSudokuDatastorage);
    property Col: TSudokuCellIndex read FCol;
    property Owner: TBaseSudokuDatastorage read FOwner;
    property Row: TSudokuCellIndex read FRow;
    property Value: TSudokuValue read GetValue;
  end; {TSudokuCellHelper}

  {! Names a position on the undo stack }
  TStackMark  = record
    Count: Integer;
    Name: string;
  public
    constructor Create(const aCount: Integer; const aName: string);
  end; {TStackMark}

  {! Collection of defined stack marks }
  TStackMarks = class(TStack<TStackMark>)
  public
    procedure Load(aReader: TReader);
    procedure Store(aWriter: TWriter);
  end; {TStackMarks}

  {! Undo stack, saves the full state of the Sudoku before a change is made }
  TSudokuStack = class (TStack<TSudokuCells>)
  strict private
    FMarks: TStackMarks;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddMark(const aName: string);
    procedure Clear;
    procedure GetMarks(aList: TStrings);
    function IsEmpty: Boolean;
    procedure Load(aReader: TReader);
    function MarkExists(const aName: string): boolean;
    procedure RevertToMark(const aName: string);
    procedure Store(aWriter: TWriter);
    procedure ValidateMarks;
    property Marks: TStackMarks read FMarks;
  end; {TSudokuStack}

strict protected
  procedure AddMark(const Name: string);
  function CanUndo: Boolean;
  procedure CheckInvalidCells;
  procedure RedrawCell(aCol, aRow: TSudokuCellIndex);
  procedure ClearUndostack;
  procedure DataChanged;
  function DoIsGosu: boolean;
  function GetCell(aCol, aRow: TSudokuCellIndex): ISudokuCell;
  function GetBlockHeight: TSudokuValue;
  function GetBlockWidth: TSudokuValue;
  function GetBounds: ISudokuProperties;
  function GetEvents: ISudokuDataEvents;
  procedure GetMarks(aList: TStrings);
  function GetMaxValue: TSudokuValue;
  function GetOnRedrawCell: TRedrawCellEvent;
  function GetOnDataChanged: TNotifyEvent;
  function HasMarks: boolean;
  function IsValueValid(aCol, aRow: TSudokuCellIndex; aValue: TSudokuValue):
      boolean;
  procedure Load(aReader: TReader);
  procedure NewSudoku;
  procedure RevertToMark(const Name: string);
  procedure Store(aWriter: TWriter);
  procedure SetOnRedrawCell(const Value: TRedrawCellEvent);
  procedure SetOnDataChanged(const Value: TNotifyEvent);
  procedure Undo;
  procedure UpdateCandidates(aCol, aRow: TSudokuCellIndex);
  procedure ValidateCellCoord(aCol, aRow: TSudokuCellIndex; const aProcName:
      string);
  function ISudokuData.IsGosu = DoIsGosu;

strict private
var
  FBlocks : TSudokuBlocks;
  FCurrentState: TSudokuCells;
  FIsGosu: boolean;
  FMaxValue: TSudokuValue;
  FOnRedrawCell: TRedrawCellEvent;
  FOnDataChanged: TNotifyEvent;
  FBlockHeight: TSudokuValue;
  FBlockWidth: TSudokuValue;
  FUndoStack: TSudokuStack;
  procedure CalculateBlocks;
  procedure Clear;
  procedure FindBlockEntry(aCol, aRow: TSudokuCellIndex; var aEntry:
      TSudokuBlockEntry);
  function GetBlockLocation(aBlockCol, aBlockRow: Integer): TCellInBlockLocation;
  function GetCellInBlockLocation(aCol, aRow: TSudokuCellIndex):
      TCellInBlockLocation;
  function IsValidBlockValue(aCol, aRow: TSudokuCellIndex; aValue: TSudokuValue):
      boolean;
  function IsValidColValue(aCol: TSudokuCellIndex; aValue: TSudokuValue): boolean;
  function IsValidRowValue(aRow: TSudokuCellIndex; aValue: TSudokuValue): boolean;
  procedure SetBlockDimensions;
  procedure SetBlockEntries;
public
  constructor Create(const AMaxValue, ABlockHeight, ABlockWidth: TSudokuValue;
      const AIsGosu: boolean = false);
  destructor Destroy; override;
  function MarkExists(const aMark: string): boolean;
  procedure SaveState;
  {!
  <value>
   True marks a Sudoku Gosu, where cells can be defined to only contain
   even values. Set via the constructor.
  </value>}
  property IsGosu: boolean read FIsGosu;
  {!
  <value>
   Maximium of the valid values for the Sudoku, set via the constructor.
  </value>}
  property MaxValue: TSudokuValue read FMaxValue;
  {!
  <value>
   Height of a block for the Sudoku, set via the constructor.
  </value>}
  property BlockHeight: TSudokuValue read FBlockHeight;
  {!
  <value>
   Width of a block for the Sudoku, set via the constructor.
  </value>}
  property BlockWidth: TSudokuValue read FBlockWidth;
  {!
  <value>
   Access to the Undo stack, for descendants.
  </value>}
  property UndoStack: TSudokuStack read FUndoStack;
end;


implementation

uses
  PB.CommonTypesU,
  SH_StringsU,
  System.Math,
  System.SysUtils;

{!
<summary>
 Constructor to call by descendants to set the bounds for the Sudoku </summary>
<param name="AMaxValue">highest valid value of a cell</param>
<param name="ABlockHeight">height of a block, in cells</param>
<param name="ABlockWidth">width of a block, in cells</param>
<param name="AIsGosu">determines whether cells can be marked to only
 accept even values, false by default</param>
<remarks>
 Descendants must call this constructor to define the bounds of the
 Sudoku the helper supports. The constructor also sets up the blocks
 array and creates the Undo stack.</remarks>
}
constructor TBaseSudokuDatastorage.Create(
    const AMaxValue, ABlockHeight, ABlockWidth: TSudokuValue; const AIsGosu:
    boolean = false);
begin
  inherited Create;
  FMaxValue := AMaxValue;
  FBlockHeight := ABlockHeight;
  FBlockWidth := ABlockWidth;
  FIsGosu := AIsGosu;

  CalculateBlocks;
  FUndoStack := TSudokuStack.Create();
end;

{! Destroys the Undo stack. }
destructor TBaseSudokuDatastorage.Destroy;
begin
  FUndoStack.Free;
  inherited Destroy;
end;

{! Implements ISudokuData.AddMark }
procedure TBaseSudokuDatastorage.AddMark(const Name: string);
begin
  { We allow a mark to be set even if the undo stack is empty, to mark
    the starting state of the Sudoku. Generally the user will clear the
    stack after the Sudoku has been set up; he may want to return to
    that state later if he lost his way completely... }
  if UndoStack.IsEmpty then
    SaveState;
  UndoStack.AddMark(Name);
end;


{!
<summary>
 Initialize the blocks array </summary>
<remarks>
 There are MaxValue blocks in a Sudoku, each is Blockwidth cells wide
 and BlockHeight cells high. In 9x9 and 16x16 Sudokus the blocks are
 square, in a 12x12 Sudoku they are not.
 </remarks>
}
procedure TBaseSudokuDatastorage.CalculateBlocks;
begin
  SetBlockDimensions;
  SetBlockEntries;
end;

{! Implements ISudokuData.CanUndo }
function TBaseSudokuDatastorage.CanUndo: Boolean;
begin
  Result := not UndoStack.IsEmpty;
end;

{! Check if cells marked as invalid are actually still invalid, update
 their state if necessary. }
procedure TBaseSudokuDatastorage.CheckInvalidCells;
var
  LCol, LRow: TSudokuCellIndex;
  LCell: PSudokuCell;
  LValue: TSudokuValue;
begin
  for LRow := 1 to MaxValue do begin
    for LCol := 1 to MaxValue do begin
      LCell := @FCurrentState[LCol, LRow];
      if not LCell.Valid then begin
        LValue := LCell.Value;
        try
          { Since IsValueValid just takes the passed cell's Valid member
            if it matches the passed value we need to clear the cell first.}
          LCell.Clear;
          LCell.Valid := IsValueValid(LCol, LRow, LValue)
            and not (LCell.EvenOnly and Odd(LValue));
        finally
          LCell.Value := LValue;
        end;
        if LCell.Valid then
          RedrawCell(LCol, LRow);
      end; {if}
    end; {for LCol }
  end; {for LRow}
end;

procedure TBaseSudokuDatastorage.Clear;
begin
  FillChar(FCurrentState, Sizeof(FCurrentState), 0 );
  UndoStack.Clear;
end;

{! Fires the OnDrawCell pseudo-event (declared by ISudokuData).  }
procedure TBaseSudokuDatastorage.RedrawCell(aCol, aRow: TSudokuCellIndex);
begin
  if Assigned(FOnRedrawCell) then FOnRedrawCell(aCol, aRow);
end;

{! Implements ISudokuData.ClearUndostack }
procedure TBaseSudokuDatastorage.ClearUndostack;
begin
  UndoStack.Clear;
end;

{! Fires the OnDataChanged pseudo-event (declared by ISudokuData).  }
procedure TBaseSudokuDatastorage.DataChanged;
begin
  if Assigned(FOnDataChanged) then FOnDataChanged(Self);
end;

{! Implements ISudokuData.IsGosu }
function TBaseSudokuDatastorage.DoIsGosu: boolean;
begin
  Result := FIsGosu;
end;

{!
<summary>
 Find the block entry for a given Sudoku cell </summary>
<returns>
 true if the block entry was found, false otherwise </returns>
<param name="aCol">is the cell column index</param>
<param name="aRow">is the cell row index</param>
<param name="aEntry">receives a copy of the found block entry</param>
<exception cref="EPostconditionViolated">
 is raised if no block was found for the specified cell.</exception>
<remarks>
 This method should never fail if the blocks array has been set up
 correctly!</remarks>
}
procedure TBaseSudokuDatastorage.FindBlockEntry(aCol, aRow: TSudokuCellIndex;
    var aEntry: TSudokuBlockEntry);
const
  CProcname = 'TBaseSudokuDatastorage.FindBlockEntry';
var
  I, K, L, N: Integer;
begin
  for I := Low(FBlocks) to High(FBlocks) do
    for K := Low(FBlocks[I]) to High(FBlocks[I]) do
      for L := Low(FBlocks[I][K]) to High(FBlocks[I][K]) do
        for N := Low(FBlocks[I][K][L]) to High(FBlocks[I][K][L]) do begin
          aEntry := FBlocks[I][K][L][N];
          if aEntry.Matches(aCol, aRow) then
            Exit;
        end; {for}
  raise EPostconditionViolated.Create(CProcname, SBlockNotFoundMask,
    [aCol, aRow]);
end;

{! Implements ISudokuData.GetCell }
function TBaseSudokuDatastorage.GetCell(aCol, aRow: TSudokuCellIndex):
    ISudokuCell;
const
  CProcName = '.GetCell';
begin
  ValidateCellCoord(aCol, aRow, Classname + CProcName);
  Result := TSudokuCellHelper.Create(aCol, aRow,
    FCurrentState[aCol, aRow], Self) as ISudokuCell;
end;

{! Implements ISudokuProperties.GetBlockHeight }
function TBaseSudokuDatastorage.GetBlockHeight: TSudokuValue;
begin
  Result := BlockHeight;
end;

{!
<summary>
 Figure out the location of cell in a block. </summary>
<remarks>
 The location is used to determine which of the cell borders to draw
 thicker to show the block boundaries in the UI.</remarks>
}
function TBaseSudokuDatastorage.GetBlockLocation(aBlockCol, aBlockRow:
    Integer): TCellInBlockLocation;
begin
  Result := [];
  if aBlockRow = 0 then
    Include( Result, TBlockPosition.Top )
  else if aBlockRow = BlockHeight - 1 then
    Include( Result, TBlockPosition.Bottom );

  if aBlockCol = 0 then
    Include( Result, TBlockPosition.Left )
  else if aBlockCol = BlockWidth - 1 then
    Include( Result, TBlockPosition.Right )
  else if Result = [] then
    Include( Result, TBlockPosition.Inside );
end;

{! Implements ISudokuProperties.GetBlockWidth }
function TBaseSudokuDatastorage.GetBlockWidth: TSudokuValue;
begin
  Result := BlockWidth;
end;

{! Implements ISudokuData.GetBounds }
function TBaseSudokuDatastorage.GetBounds: ISudokuProperties;
begin
  Result := self as ISudokuProperties;
end;

{! Find the location of a Sudoku cell in its block. Used by TSudokuCellHelper
  to implement ISudokuCell.GetBlockLocation. }
function TBaseSudokuDatastorage.GetCellInBlockLocation(aCol, aRow:
    TSudokuCellIndex): TCellInBlockLocation;
var
  LEntry: TSudokuBlockEntry;
begin
  FindBlockEntry(aCol, aRow, LEntry);
  Result := LEntry.Location;
end;

{! Implements ISudokuData.GetEvents }
function TBaseSudokuDatastorage.GetEvents: ISudokuDataEvents;
begin
  Result := self as ISudokuDataEvents;
end;

{! Implements ISudokuData.GetMarks }
procedure TBaseSudokuDatastorage.GetMarks(aList: TStrings);
begin
  UndoStack.GetMarks(aList);
end;

{! Implements ISudokuProperties.GetMaxValue }
function TBaseSudokuDatastorage.GetMaxValue: TSudokuValue;
begin
  Result := MaxValue;
end;

{! Implements ISudokuDataEvents.GetOnRedrawCell }
function TBaseSudokuDatastorage.GetOnRedrawCell: TRedrawCellEvent;
begin
  Result := FOnRedrawCell;
end;

{! Implements ISudokuDataEvents.GetOnDataChanged }
function TBaseSudokuDatastorage.GetOnDataChanged: TNotifyEvent;
begin
  Result := FOnDataChanged;
end;

{! Implements ISudokuData.HasMarks }
function TBaseSudokuDatastorage.HasMarks: boolean;
begin
  Result := UndoStack.Marks.Count > 0;
end;

{!
<summary>
 Check if a value would be acceptable for a block </summary>
<returns>
 True if the value would be acceptible, false if not</returns>
<param name="aCol">is the cell's column index</param>
<param name="aRow">is the cell's row index</param>
<param name="aValue">is the value to check</param>
<exception cref="EPreconditionViolation">
 is raised if no block could be found for the passed cell
 coordinate; should never happen.</exception>
<remarks>
 The value would be OK if no cell in the block already contains it.
 For a Sudoku Gosu we have to also check if the block has an empty cell
 that can accept an odd value, if aValue is odd.</remarks>
}
function TBaseSudokuDatastorage.IsValidBlockValue(aCol, aRow: TSudokuCellIndex;
    aValue: TSudokuValue): boolean;
var
  LBlock: TSudokuBlock;
  LEntry: TSudokuBlockEntry;
  I, K: Integer;
  LCell: TSudokuCell;
begin
  FindBlockEntry(aCol, aRow, LEntry);
  LBlock := FBlocks[LEntry.BlocksRow][LEntry.BlocksCol];
  for I := Low(LBlock) to High(LBlock) do begin
    for K := Low(LBlock[I]) to High(LBlock[I]) do begin
      LEntry := LBlock[I][K];
      LCell  := FCurrentState[LEntry.Col, LEntry.Row];
      if LCell.Value = aValue then
        Exit(false);
    end; {for K}
  end; {for I}

  if IsGosu and Odd(aValue) then begin
    Result := false;
    for I := Low(LBlock) to High(LBlock) do
      for K := Low(LBlock[I]) to High(LBlock[I]) do begin
        LEntry := LBlock[I][K];
        LCell  := FCurrentState[LEntry.Col, LEntry.Row];
        if LCell.IsEmpty and not LCell.EvenOnly  then
          Exit(true);
      end; {for K}
  end {if}
  else
    Result := true;
end;

{!
<summary>
 Check if a value would be acceptable for a column </summary>
<returns>
 True if the value would be acceptible, false if not</returns>
<param name="aCol">is the column to check</param>
<param name="aValue">is the value to check</param>
<remarks>
 The value would be OK if no cell in the column already contains it.
 For a Sudoku Gosu we have to also check if the column has an empty cell
 that can accept an odd value, if aValue is odd.</remarks>
}
function TBaseSudokuDatastorage.IsValidColValue(aCol: TSudokuCellIndex; aValue:
    TSudokuValue): boolean;
var
  LCell: TSudokuCell;
  LRow: TSudokuCellIndex;
begin
  Result := true;
  for LRow := 1 to MaxValue do begin
    if FCurrentState[aCol, LRow].Value = aValue  then
      Exit(false);
  end; {for LRow}

  if IsGosu and Odd(aValue) then begin
    Result := false;
    for LRow := 1 to MaxValue do begin
      LCell := FCurrentState[aCol, LRow];
      if LCell.IsEmpty and not LCell.EvenOnly  then
        Exit(true);
    end; {for LRow}
  end; {if}
end;

{!
<summary>
 Check if a value would be acceptable for a row </summary>
<returns>
 True if the value would be acceptible, false if not</returns>
<param name="aRow">is the row to check</param>
<param name="aValue">is the value to check</param>
<remarks>
 The value would be OK if no cell in the row already contains it.
 For a Sudoku Gosu we have to also check if the row has an empty cell
 that can accept an odd value, if aValue is odd.</remarks>
}
function TBaseSudokuDatastorage.IsValidRowValue(aRow: TSudokuCellIndex; aValue:
    TSudokuValue): boolean;
var
  LCell: TSudokuCell;
  LCol: TSudokuCellIndex;
begin
  Result := true;
  for LCol := 1 to MaxValue do begin
    if FCurrentState[LCol, aRow].Value = aValue  then
      Exit(false);
  end; {for LCol}

  if IsGosu and Odd(aValue) then begin
    Result := false;
    for LCol := 1 to MaxValue do begin
      LCell := FCurrentState[LCol, aRow];
      if LCell.IsEmpty and not LCell.EvenOnly  then
        Exit(true);
    end; {for LCol}
  end; {if}
end;

{! Implements ISudokuData.IsValueValid }
function TBaseSudokuDatastorage.IsValueValid(aCol, aRow: TSudokuCellIndex;
    aValue: TSudokuValue): boolean;
var
  LCell: TSudokuCell;
begin
  LCell := FCurrentState[aCol, aRow];
  if LCell.Value = aValue then
    Result := LCell.Valid
  else
    Result :=
      IsValidRowValue(aRow, aValue)
      and
      IsValidColValue(aCol, aValue)
      and
      IsValidBlockValue(aCol, aRow, aValue);
end;

{!
<summary>Implements ISudokuData.Load </summary>
<param name="aReader">used to read the data from, required</param>
<exception cref="EParameterCannotBeNil">
 is raised if aReader is nil</exception>
}
procedure TBaseSudokuDatastorage.Load(aReader: TReader);
const
  CProcname = 'TBaseSudokuDatastorage.Load';
begin
  if not Assigned(aReader) then
    raise EParameterCannotBeNil.Create(CProcname,'aReader');
  Clear;
  aReader.Read(FCurrentState, Sizeof(FCurrentState));
  UndoStack.Load(aReader);
  {
    Note: We do not force a refresh of the display here, since the
    display handler may not have been completely initialized yet.
    Updating the display is left to the penultimate caller, which
    is usually an UI element.
  }
end;

{! Implements ISudokuData.MarkExists }
function TBaseSudokuDatastorage.MarkExists(const aMark: string): boolean;
begin
  Result:= UndoStack.MarkExists(aMark);
end;

{! Implements ISudokuData.NewSudoku }
procedure TBaseSudokuDatastorage.NewSudoku;
begin
  Clear;
  DataChanged;
end;

{! Implements ISudokuData.RevertToMark }
procedure TBaseSudokuDatastorage.RevertToMark(const Name: string);
begin
  Undostack.RevertToMark(Name);
  Undo;
end;

{!
<summary> Implements ISudokuData.Store </summary>
<param name="aWriter">used to write the data to, required</param>
<exception cref="EParameterCannotBeNil">
 is raised if aWriter is nil</exception>
}
procedure TBaseSudokuDatastorage.Store(aWriter: TWriter);
const
  CProcname = 'TBaseSudokuDatastorage.Store';
begin
  if not Assigned(aWriter) then
    raise EParameterCannotBeNil.Create(CProcname,'aWriter');
  aWriter.Write(FCurrentState, Sizeof(FCurrentState));
  UndoStack.Store(aWriter);
end;

procedure TBaseSudokuDatastorage.SaveState;
begin
  UndoStack.Push(FCurrentState);
end;

{! Allocate memory for the blocks array }
procedure TBaseSudokuDatastorage.SetBlockDimensions;
var
  I, K, N: Integer;
begin
  // Set the number of rows in the blocks array
  SetLength(FBlocks, MaxValue div BlockHeight);
  for I := Low(FBlocks) to High(FBlocks) do begin
    // Set the number of blocks in a row
    SetLength(FBlocks[I], MaxValue div BlockWidth);
    for K := Low(FBlocks[I]) to High(FBlocks[I]) do begin
      // Set the number of cell rows in a block
      SetLength(FBlocks[I][K], BlockHeight);
      for N := Low(FBlocks[I][K]) to High(FBlocks[I][K]) do begin
        // Set the number of cells in a row
        SetLength(FBlocks[I][K][N], BlockWidth);
      end; {for N}
    end; {for K}
  end; {for I}
end;

{! Build the entries of the blocks array }
procedure TBaseSudokuDatastorage.SetBlockEntries;
var
  LCol, LRow: TSudokuCellIndex;
  LBlocksCol, LBlocksRow: integer;
  LBlockCol, LBlockRow: integer;
  LEntry: TSudokuBlockEntry;
begin
  LBlocksRow := 0;
  LBlockRow := 0;
  // Walk the cells array in row-major order
  for LRow := 1 to MaxValue do begin
    LBlocksCol := 0;
    LBlockCol := 0;
    for LCol := 1 to MaxValue do  begin
      // Build the entry for the current cell
      LEntry.Col := LCol;
      LEntry.Row := LRow;
      LEntry.Location := GetBlockLocation(LBlockCol, LBlockRow);
      LEntry.BlocksCol := LBlocksCol;
      LEntry.BlocksRow := LBlocksRow;

      // Store it into the current slot of the blocks array
      FBlocks[LBlocksRow][LBlocksCol][LBlockRow][LBlockCol] := LEntry;

      // Calculate the slot for the next cell
      Inc(LBlockCol);
      if LBlockCol = BlockWidth then begin
        // continue in the next block to the right, on the same row
        Inc(LBlocksCol);
        LBlockCol := 0;
        if LBlocksCol = (MaxValue div BlockWidth) then begin
          // next row in this block row
          LBlocksCol := 0;
          Inc(LBlockRow);
          if LBlockRow = BlockHeight then begin
            // Continue in the first block of the next blocks row
            LBlockRow := 0;
            Inc(LBlocksRow);
          end; {if}
        end; {if}
      end; {if}
    end; { for LCol }
  end; {for LRow}
end;

{! Implements ISudokuDataEvents.SetOnRedrawCell }
procedure TBaseSudokuDatastorage.SetOnRedrawCell(const Value: TRedrawCellEvent);
begin
  FOnRedrawCell := Value;
end;

{! Implements ISudokuDataEvents.SetOnDataChanged }
procedure TBaseSudokuDatastorage.SetOnDataChanged(const Value: TNotifyEvent);
begin
  FOnDataChanged := Value;
end;

{! Implements ISudokuData.Undo }
procedure TBaseSudokuDatastorage.Undo;
begin
  if not CanUndo then
    raise EPreconditionViolation.Create(Classname+'.Undo',STheUndoStackIsEmpty);
  FCurrentState := Undostack.Pop;
  Undostack.ValidateMarks;
  DataChanged;
end;

{!
<summary>
 Update the candidates for all cells in the same row, column, or block
 the specified cell is in. </summary>
<param name="aCol">is the cell's column index</param>
<param name="aRow">is the cell's row index</param>
}
procedure TBaseSudokuDatastorage.UpdateCandidates(aCol, aRow: TSudokuCellIndex);
var
  LCell: PSudokuCell;
  LValue: TSudokuValue;
  LBlock: TSudokuBlock;
  LEntry: TSudokuBlockEntry;
  procedure RemoveCandidate(var aCell: TSudokuCell; C, R: TSudokuCellIndex);
  begin
    if aCell.IsEmpty and (LValue in aCell.Candidates) then begin
      Exclude(aCell.Candidates, LValue);
      RedrawCell(C, R);
    end; {if}
  end; {RemoveCandidate}
begin
  LCell := @FCurrentState[aCol, aRow];
  if not LCell.IsEmpty then begin
    LValue:= LCell.Value;
    for var I: TSudokuValue := 1 to MaxValue do begin
       RemoveCandidate(FCurrentState[aCol, I], aCol, I);
       RemoveCandidate(FCurrentState[I, aRow], I, aRow);
    end; {for}

    FindBlockEntry(aCol, aRow, LEntry);
    LBlock := FBlocks[LEntry.BlocksRow][LEntry.BlocksCol];
    for var I := Low(LBlock) to High(LBlock) do begin
      for var K := Low(LBlock[I]) to High(LBlock[I]) do begin
        LEntry := LBlock[I][K];
        RemoveCandidate(FCurrentState[LEntry.Col, LEntry.Row],
          LEntry.Col, LEntry.Row);
      end; {for K}
    end; {for I}
  end; {if}
end;

{!
<summary>
 Validate a Sudoku cell's column and row index </summary>
<param name="aCol">is the cell column index</param>
<param name="aRow">is the cell row index</param>
<param name="aProcName">name of the calling method, used to
  compose the error message</param>
<exception cref="ECellIndexOutOfBounds">
 is raised if aCol or aRow are not in the range 1 .. MaxValue </exception>
}
procedure TBaseSudokuDatastorage.ValidateCellCoord(aCol, aRow:
    TSudokuCellIndex; const aProcName: string);
const
  CColumn = 'Column';
  CRow = 'Row';
var
  LFault: string;
  LFaultValue: TSudokuCellIndex;
begin
  if not InRange(aCol, 1, MaxValue) then begin
    LFault := CColumn;
    LFaultValue := aCol;
  end
  else
    if not InRange(aRow, 1, MaxValue) then begin
      LFault := CRow;
      LFaultValue := aRow;
    end
    else begin
      LFault := String.Empty;
      LFaultValue := 1;   // not used, to remove a warning
    end;
  if not LFault.IsEmpty then
    raise ECellIndexOutOfBounds.Create(
      aProcName, '%s index %d is out of bounds, allowed values are 1 to %d.',
      [LFault, LFaultValue, MaxValue]);
end;

{== TBaseSudokuDatastorage.TSudokuStack ===============================}

constructor TBaseSudokuDatastorage.TSudokuStack.Create;
begin
  inherited Create;
  FMarks := TStackMarks.Create;
end;

destructor TBaseSudokuDatastorage.TSudokuStack.Destroy;
begin
  FMarks.Free;
  inherited Destroy;
end;

procedure TBaseSudokuDatastorage.TSudokuStack.AddMark(const aName: string);
begin
  if MarkExists(aName) then
    raise EPreconditionViolation.Create(Classname+'.AddMark',
        SAMarkAlreadyExists, [aName]);
  Marks.Push(TStackMark.Create(Count, aName));
end;

procedure TBaseSudokuDatastorage.TSudokuStack.Clear;
begin
  Marks.Clear;
  inherited Clear;
end;

procedure TBaseSudokuDatastorage.TSudokuStack.GetMarks(aList: TStrings);
var
  LMark: TStackMark;
begin
  if not Assigned(aList) then
    raise EParameterCannotBeNil.Create(Classname+'.GetMarks','aList');
  aList.Clear;
  for LMark in Marks do
    aList.Add(LMark.Name);
end;

function TBaseSudokuDatastorage.TSudokuStack.IsEmpty: Boolean;
begin
  Result := Count = 0;
end;

{!
<summary>
 Load the undo stack content, including the marks, overwriting any
 prior content.  </summary>
<param name="aReader">used to read the data from, required</param>
}
procedure TBaseSudokuDatastorage.TSudokuStack.Load(aReader: TReader);
var
  LItem: TSudokuCells;
  LCount: integer;
begin
  Clear;
  LCount := aReader.ReadInteger;
  while LCount > 0 do begin
    aReader.Read(LItem, Sizeof(LItem));
    Push(LItem);
    Dec(LCount);
  end; {while}
  Marks.Load(aReader);
end;

function TBaseSudokuDatastorage.TSudokuStack.MarkExists(const aName: string):
    boolean;
var
  LList: TStringlist;
begin
  LList := TStringlist.Create();
  try
    GetMarks(LList);
    Result := LList.IndexOf(aName) >= 0;
  finally
    LList.Free;
  end;  
end;

procedure TBaseSudokuDatastorage.TSudokuStack.RevertToMark(const aName: string);
var
  LMark: TStackMark;
begin
  if not MarkExists(aName) then
    raise EPreconditionViolation.Create(Classname+'.RevertToMark',
        SAMarkDoesNotExist, [aName]);
  while Marks.Count > 0 do begin
    LMark := Marks.Pop;
    if LMark.Name.Equals(aName) then begin
      while Count > LMark.Count do
        Pop;
      Break;
    end; {if}
  end; {while}
end;


{!
<summary>
 Save the undo stack content, including the marks.  </summary>
<param name="aWriter">used to write the data to, required</param>
<remarks>
 We depend on an implementation detail of TStack<T> here: its enumerator
 will iterate over the items in push order, so the top of the stack is
 the last item saved. This allows us to later restore the stack by just
 pushing the items in the order they are loaded from the stream.
 </remarks>
}
procedure TBaseSudokuDatastorage.TSudokuStack.Store(aWriter: TWriter);
var
  LItem: TSudokuCells;
begin
  aWriter.WriteInteger(Count);
  if not IsEmpty then begin
    for LItem in Self do 
      aWriter.Write(LItem, Sizeof(LItem));
  end; {if}
  Marks.Store(aWriter);
end;

procedure TBaseSudokuDatastorage.TSudokuStack.ValidateMarks;
var
  LMark: TStackMark;
begin
  while Marks.Count > 0 do begin
    LMark:= Marks.Peek;
    if LMark.Count > Count then
      Marks.Pop
    else
      Break;
  end; {while}
end;

{== TBaseSudokuDatastorage.TStackMark =================================}

constructor TBaseSudokuDatastorage.TStackMark.Create(const aCount: Integer;
    const aName: string);
begin
  Count := aCount;
  Name := aName;
end;

{== TBaseSudokuDatastorage.TSudokuCellHelper ==========================}

constructor TBaseSudokuDatastorage.TSudokuCellHelper.Create(aCol, aRow:
    TSudokuCellIndex; var aCell: TSudokuCell; aOwner: TBaseSudokuDatastorage);
begin
  inherited Create;
  FCol := aCol;
  FRow := aRow;
  FCellRef := @aCell;
  FOwner := aOwner;
end;

{! Implements ISudokuCell.AddCandidate }
procedure TBaseSudokuDatastorage.TSudokuCellHelper.AddCandidate(aValue:
    TSudokuValue);
begin
  if IsEmpty and not (aValue in FCellRef.Candidates) and (aValue > 0) then
    DoCellOp(
      procedure (var aCell: TSudokuCell)
      begin
        Include(aCell.Candidates, aValue);
      end);
end;

{! Implements ISudokuCell.Clear }
procedure TBaseSudokuDatastorage.TSudokuCellHelper.Clear;
begin
  if not IsEmpty then
    DoCellOp(
      procedure (var aCell: TSudokuCell)
      begin
        aCell.Clear;
      end);
end;

{!
<summary>
 Execute an operation that changes a cell's state in a way that can be
 undone. </summary>
<param name="aProc">implements the operation to execute</param>
<exception cref="EParameterCannotBeNil">
 is raised if aProc is nil</exception>
}
procedure TBaseSudokuDatastorage.TSudokuCellHelper.DoCellOp(aProc: TCellOp);
const
  CProcname = 'TBaseSudokuDatastorage.TSudokuCellHelper.DoCellOp';
begin
  if not Assigned(aProc) then
    raise EParameterCannotBeNil.Create(CProcname,'aProc');
  Owner.SaveState;
  aProc(FCellRef^);
  Owner.RedrawCell(Col, Row);
end;

{! Implements ISudokuCell.GetBlockLocation }
function TBaseSudokuDatastorage.TSudokuCellHelper.GetBlockLocation:
    TCellInBlockLocation;
begin
  Result := Owner.GetCellInBlockLocation(Col, Row);
end;

{! Implements ISudokuCell.GetCandidates }
function TBaseSudokuDatastorage.TSudokuCellHelper.GetCandidates: TSudokuValues;
begin
  Result := FCellRef.Candidates;
end;

{! Implements ISudokuCell.GetCol }
function TBaseSudokuDatastorage.TSudokuCellHelper.GetCol: TSudokuCellIndex;
begin
  Result := FCol;
end;

{! Implements ISudokuCell.GetEvenOnly }
function TBaseSudokuDatastorage.TSudokuCellHelper.GetEvenOnly: Boolean;
begin
  Result := FCellRef.EvenOnly;
end;

{! Implements ISudokuCell.GetRow }
function TBaseSudokuDatastorage.TSudokuCellHelper.GetRow: TSudokuCellIndex;
begin
  Result := FRow;
end;

{! Implements ISudokuCell.GetValue }
function TBaseSudokuDatastorage.TSudokuCellHelper.GetValue: TSudokuValue;
begin
  Result := FCellRef.Value;
end;

{! Implements ISudokuCell.IsEmpty }
function TBaseSudokuDatastorage.TSudokuCellHelper.IsEmpty: Boolean;
begin
  Result := FCellRef.IsEmpty;
end;

{! Implements ISudokuCell.IsValid }
function TBaseSudokuDatastorage.TSudokuCellHelper.IsValid: Boolean;
begin
  Result:= FCellRef.Valid
end;

{! Implements ISudokuCell.RemoveCandidate }
procedure TBaseSudokuDatastorage.TSudokuCellHelper.RemoveCandidate(aValue:
    TSudokuValue);
begin
  if IsEmpty and (aValue in FCellRef.Candidates) then
    DoCellOp(
      procedure (var aCell: TSudokuCell)
      begin
        Exclude(aCell.Candidates, aValue);
      end);
end;

{! Implements ISudokuCell.SetValue }
procedure TBaseSudokuDatastorage.TSudokuCellHelper.SetValue(const aValue:
    TSudokuValue);
begin
  if aValue > 0 then begin
    DoCellOp(
      procedure (var aCell: TSudokuCell)
      begin
        aCell.Valid := Owner.IsValueValid(Col, Row, aValue)
          and not (aCell.EvenOnly and Odd(aValue));
        // We allow a bad value to be set, that just is displayed in red.
        aCell.Value := aValue;
        aCell.Candidates := [];
      end);
    Owner.UpdateCandidates(Col, Row);
    Owner.CheckInvalidCells;
  end; {if}
end;

{! Implements ISudokuCell.ToggleEvenOnly }
procedure TBaseSudokuDatastorage.TSudokuCellHelper.ToggleEvenOnly;
begin
  DoCellOp(
    procedure (var aCell: TSudokuCell)
    begin
      aCell.EvenOnly := not aCell.EvenOnly;
      aCell.Valid := aCell.Valid
        and not (aCell.EvenOnly and Odd(aCell.Value));
    end);
end;

{== TSudokuCell =======================================================}

procedure TSudokuCell.Clear;
begin
  Value := 0;
  Valid := true;
  Candidates := [];
end;

function TSudokuCell.IsEmpty: boolean;
begin
  Result := Value = 0;
end;

{== TSudokuBlockEntry =================================================}

function TSudokuBlockEntry.Matches(aCol, aRow: TSudokuCellIndex): boolean;
begin
  Result := (Col = aCol) and (Row = aRow);
end;

{== TBaseSudokuDatastorage.TStackMarks ================================}

{!
<summary>
 Load the stack marks, overwriting any prior content.  </summary>
<param name="aReader">used to read the data from, required</param>
}
procedure TBaseSudokuDatastorage.TStackMarks.Load(aReader: TReader);
var
  LItem: TStackmark;
  LCount: integer;
begin
  Clear;
  LCount := aReader.ReadInteger;
  while LCount > 0 do begin
    LItem.Count := aReader.ReadInteger;
    LItem.Name  := aReader.ReadString;
    Push(LItem);
    Dec(LCount);
  end; {while}
end;

{
<summary>
 Store the stack marks.</summary>
<param name="aWriter">used to write the data to, required</param>
<remarks>
 We depend on an implementation detail of TStack<T> here: its enumerator
 will iterate over the items in push order, so the top of the stack is
 the last item saved. This allows us to later restore the stack by just
 pushing the items in the order they are loaded from the stream.
 </remarks>
}
procedure TBaseSudokuDatastorage.TStackMarks.Store(aWriter: TWriter);
var
  LItem: TStackmark;
begin
  aWriter.WriteInteger(Count);
  if Count > 0 then begin
    for LItem in Self do begin
      aWriter.WriteInteger(LItem.Count);
      aWriter.WriteString(LItem.Name);
    end;
  end; {if}
end;


end.

