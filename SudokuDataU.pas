unit SudokuDataU;

interface

uses
  Generics.Collections;

type
  TSudokuValue = 0..9;   // 0 = unassigned
  TSudokuValues = set of TSudokuValue;
  TSudokuCell = record
    Value: TSudokuValue;
    Candidates: TSudokuValues;
    Valid: boolean;
    EvenOnly: boolean;
  end;
  TSudokuCellIndex = 1..High(TSudokuValue);
  TSudokuCells = array [TSudokuCellIndex,TSudokuCellIndex] of TSudokuCell;
  TSudokuCoord = record Col, Row: TSudokuCellIndex end;
  TSudokuRange = array [TSudokuCellIndex] of TSudokuCoord;
  TCellProc = reference to function (var aCell: TSudokuCell):Boolean;
  TSudokuStack = class (TStack<TSudokuCells>)
  end;
  TSudoku = class
  private
    FCells : TSudokuCells;
    FUndoStack: TSudokuStack;
    function BlockIndex(aCol, aRow: TSudokuCellIndex): TSudokuCellIndex;
    function BlockRange(N: TSudokuCellIndex): TSudokuRange;
    function ColRange(N: TSudokuCellIndex): TSudokuRange;
    function GetCandidates(aCol, aRow: TSudokuCellIndex): TSudokuValues;
    function GetValid: boolean;
    function GetValueIsValid(aCol, aRow: TSudokuCellIndex): boolean;
    function GetValues(aCol, aRow: TSudokuCellIndex): TSudokuValue;
    function RowRange(N: TSudokuCellIndex): TSudokuRange;
    procedure SetAllValid;
    procedure SetCandidates(aCol, aRow: TSudokuCellIndex; const Value:
        TSudokuValues);
    procedure SetValues(aCol, aRow: TSudokuCellIndex; const Value: TSudokuValue);
    procedure UpdateCandidateRange(const aRange: TSudokuRange; const Value:
        TSudokuValue);
    procedure UpdateCandidates(aCol, aRow: TSudokuCellIndex; const Value:
        TSudokuValue);
  protected
    procedure ValidateRange(const aRange: TSudokuRange);
    property UndoStack: TSudokuStack read FUndoStack;
  public
    constructor Create;
    destructor Destroy; override;
    function CanUndo: boolean;
    procedure ClearStack;
    procedure ForEachCell(aProc: TCellProc);
    procedure Undo;
    procedure Validate;
    property Candidates[aCol, aRow: TSudokuCellIndex]: TSudokuValues read
        GetCandidates write SetCandidates;
    property Valid: boolean read GetValid;
    property ValueIsValid[aCol, aRow: TSudokuCellIndex]: boolean read
        GetValueIsValid;
    property Values[aCol, aRow: TSudokuCellIndex]: TSudokuValue read GetValues
        write SetValues;
  end;


implementation

uses
  Math;

const
  Blocks : array [TSudokuCellIndex] of TSudokuRange =  (
  ((Col: 1; Row: 1),(Col: 2; Row: 1),(Col: 3; Row: 1),
   (Col: 1; Row: 2),(Col: 2; Row: 2),(Col: 3; Row: 2),
   (Col: 1; Row: 3),(Col: 2; Row: 3),(Col: 3; Row: 3)
  ),
  ((Col: 4; Row: 1),(Col: 5; Row: 1),(Col: 6; Row: 1),
   (Col: 4; Row: 2),(Col: 5; Row: 2),(Col: 6; Row: 2),
   (Col: 4; Row: 3),(Col: 5; Row: 3),(Col: 6; Row: 3)
  ),
  ((Col: 7; Row: 1),(Col: 8; Row: 1),(Col: 9; Row: 1),
   (Col: 7; Row: 2),(Col: 8; Row: 2),(Col: 9; Row: 2),
   (Col: 7; Row: 3),(Col: 8; Row: 3),(Col: 9; Row: 3)
  ),
  ((Col: 1; Row: 4),(Col: 2; Row: 4),(Col: 3; Row: 4),
   (Col: 1; Row: 5),(Col: 2; Row: 5),(Col: 3; Row: 5),
   (Col: 1; Row: 6),(Col: 2; Row: 6),(Col: 3; Row: 6)
  ),
  ((Col: 4; Row: 4),(Col: 5; Row: 4),(Col: 6; Row: 4),
   (Col: 4; Row: 5),(Col: 5; Row: 5),(Col: 6; Row: 5),
   (Col: 4; Row: 6),(Col: 5; Row: 6),(Col: 6; Row: 6)
  ),
  ((Col: 7; Row: 4),(Col: 8; Row: 4),(Col: 9; Row: 4),
   (Col: 7; Row: 5),(Col: 8; Row: 5),(Col: 9; Row: 5),
   (Col: 7; Row: 6),(Col: 8; Row: 6),(Col: 9; Row: 6)
  ),
  ((Col: 1; Row: 7),(Col: 2; Row: 7),(Col: 3; Row: 7),
   (Col: 1; Row: 8),(Col: 2; Row: 8),(Col: 3; Row: 8),
   (Col: 1; Row: 9),(Col: 2; Row: 9),(Col: 3; Row: 9)
  ),
  ((Col: 4; Row: 7),(Col: 5; Row: 7),(Col: 6; Row: 7),
   (Col: 4; Row: 8),(Col: 5; Row: 8),(Col: 6; Row: 8),
   (Col: 4; Row: 9),(Col: 5; Row: 9),(Col: 6; Row: 9)
  ),
  ((Col: 7; Row: 7),(Col: 8; Row: 7),(Col: 9; Row: 7),
   (Col: 7; Row: 8),(Col: 8; Row: 8),(Col: 9; Row: 8),
   (Col: 7; Row: 9),(Col: 8; Row: 9),(Col: 9; Row: 9)
  )
  );


constructor TSudoku.Create;
begin
  inherited Create;
  FUndoStack := TSudokuStack.Create();
end;

destructor TSudoku.Destroy;
begin
  FUndoStack.Free;
  inherited Destroy;
end;

function TSudoku.BlockIndex(aCol, aRow: TSudokuCellIndex): TSudokuCellIndex;
var
  I, N: TSudokuCellIndex;
begin
  Result := Low(Result);
  for I := Low(I) to High(I) do
    for N := Low(N) to High(N) do
      if (Blocks[I][N].Col = aCol) and (Blocks[I][N].Row = aRow) then
      begin
        Result := I;
        Break;
      end;

end;

function TSudoku.BlockRange(N: TSudokuCellIndex): TSudokuRange;
begin
  Result := Blocks[N];
end;

function TSudoku.CanUndo: boolean;
begin
  Result := UndoStack.Count > 0;
end;

procedure TSudoku.ClearStack;
begin
  Undostack.Clear;
end;

function TSudoku.ColRange(N: TSudokuCellIndex): TSudokuRange;
var
  I: TSudokuCellIndex;
begin
  for I := Low(TSudokuCellIndex) to High(TSudokuCellIndex) do begin
    Result[I].Col := N;
    Result[I].Row := I;
  end; {if}
end;

procedure TSudoku.ForEachCell(aProc: TCellProc);
var
  aCol, aRow: TSudokuCellIndex;
begin
  for aCol := Low(aCol) to High(aCol) do
    for aRow := Low(aCol) to High(aCol) do
      if not aProc(FCells[aCol, aRow]) then
        Exit;
end;

function TSudoku.GetCandidates(aCol, aRow: TSudokuCellIndex): TSudokuValues;
begin
  Result := FCells[aCol, aRow].Candidates;
end;

function TSudoku.GetValid: boolean;
var
  B: Boolean;
begin
  B := true;
  ForEachCell(
    function (var aCell: TSudokuCell): boolean
    begin
      Result := aCell.Valid or (aCell.Value <> 0);
      B:= B and Result;
    end
  );
  Result := B;
end;

function TSudoku.GetValueIsValid(aCol, aRow: TSudokuCellIndex): boolean;
begin
  Result := FCells[aCol, aRow].Valid or (FCells[aCol, aRow].Value = 0);
end;

function TSudoku.GetValues(aCol, aRow: TSudokuCellIndex): TSudokuValue;
begin
  Result := FCells[aCol, aRow].Value;
end;

function TSudoku.RowRange(N: TSudokuCellIndex): TSudokuRange;
var
  I: TSudokuCellIndex;
begin
  for I := Low(TSudokuCellIndex) to High(TSudokuCellIndex) do begin
    Result[I].Col := I;
    Result[I].Row := N;
  end; {for}
end;

procedure TSudoku.SetAllValid;
begin
  ForEachCell(
    function (var aCell: TSudokuCell): boolean
    begin
      Result := true;
      aCell.Valid := true;
    end);
end;

procedure TSudoku.SetCandidates(aCol, aRow: TSudokuCellIndex; const Value:
    TSudokuValues);
begin
  UndoStack.Push(FCells);
  FCells[aCol, aRow].Candidates := Value;
end;

procedure TSudoku.SetValues(aCol, aRow: TSudokuCellIndex; const Value:
    TSudokuValue);
begin
  if FCells[aCol, aRow].Value <> Value then begin
    UndoStack.Push(FCells);
    FCells[aCol, aRow].Value := Value;
    FCells[aCol, aRow].Candidates := [];
    Validate;
    if Valid then
      UpdateCandidates(aCol, aRow, Value);
  end; {if}
end;

procedure TSudoku.Undo;
begin
  if CanUndo then
    FCells := Undostack.Pop;
end;

procedure TSudoku.UpdateCandidateRange(const aRange: TSudokuRange; const Value:
    TSudokuValue);
var
  I: TSudokuCellIndex;
begin
  for I := Low(TSudokuCellIndex) to High(TSudokuCellIndex) do
    Exclude(FCells[aRange[I].Col,aRange[I].Row].Candidates, Value);
end;

procedure TSudoku.UpdateCandidates(aCol, aRow: TSudokuCellIndex; const Value:
    TSudokuValue);
begin
  UpdateCandidateRange(RowRange(aRow), Value);
  UpdateCandidateRange(ColRange(aCol), Value);
  UpdateCandidateRange(BlockRange(BlockIndex(aCol, aRow)), Value);
end;

procedure TSudoku.Validate;
var
  I: TSudokuCellIndex;
begin
  SetAllValid;
  for I := Low(TSudokuCellIndex) to High(TSudokuCellIndex)  do begin
    ValidateRange(RowRange(I));
    ValidateRange(ColRange(I));
    ValidateRange(BlockRange(I));
  end;
end;

procedure TSudoku.ValidateRange(const aRange: TSudokuRange);
var
  I: TSudokuCellIndex;
  Map : array [TSudokuValue] of TSudokuCellIndex;
  N: TSudokuValue;
begin
  FillChar(Map, Sizeof(Map), 0);
  for I := Low(TSudokuCellIndex) to High(TSudokuCellIndex) do begin
    N:= Values[aRange[I].Col,aRange[I].Row];
    if N <> 0 then begin
      if Map[N] <> 0 then begin
        FCells[aRange[I].Col,aRange[I].Row].Valid := false;
        FCells[aRange[Map[N]].Col,aRange[Map[N]].Row].Valid := false;
      end {if}
      else begin
        Map[N] := I;
      end; {else}
    end; {if}
  end;
end;

end.
