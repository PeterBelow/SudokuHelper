{!
<summary>
 This unit implements the base class for all Sudoku display handlers.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-10-04<p>
 Last modified       2021-11-20<p>
</history>
<copyright>Copyright 2021 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
<remarks>
 The display handler is responsible for drawing the Sudoku grid.
</remarks>
}
unit BaseSudokuDisplayhandlerU;

interface

uses
  System.Types,
  System.Classes,
  System.SysUtils,
  Graphics,
  Grids,
  SudokuInterfacesU;

type
  {!
  <summary>
   All Sudoku display handlers have to descend from this class.
    </summary>
  <remarks>
   The display handler draws the cells of the grid used to display the
   Sudoku. The base class implements all functionality needed for a
   Sudoku using integer numbers, but descendants can override some of
   the virtual methods to modify the behaviour as needed. </remarks>
  }
  TBaseSudokuDisplayhandler = class abstract(TInterfacedObject, ISudokuDisplay)
  strict private
    FDataStorage: ISudokuData;
    FGrid: TDrawGrid;
    FInitialized: Boolean;
  strict protected
    procedure DataChanged(Sender: TObject);
    procedure DrawCellBorders(aCell: ISudokuCell; var Rect: TRect; State:
        TGridDrawState); virtual;
    procedure DrawCellData(aCell: ISudokuCell; Rect: TRect); virtual;
    function GetDefaultCellSize: Integer; virtual;
    function GetSymbol(aValue: TSudokuValue): string; virtual;
    procedure InitializeGrid(aGrid: TDrawGrid);
    function IsInitialized: boolean;
    procedure RedrawCell(aCol, aRow: TSudokuCellIndex);
    procedure Refresh;
    procedure SudokuGridDrawCell(Sender: TObject; ACol, ARow: Integer; Rect: TRect;
        State: TGridDrawState);
    property DataStorage: ISudokuData read FDataStorage;
    property DefaultCellSize: Integer read GetDefaultCellSize;
    property Grid: TDrawGrid read FGrid write FGrid;
  public
    constructor Create(const ADataStorage: ISudokuData);
  end;



implementation

uses
  PB.CommonTypesU, System.Math, Vcl.Controls;

type
  { Gives access to protected methods of TDrawGrid }
  TGridCracker = class(TDrawGrid);

constructor TBaseSudokuDisplayhandler.Create(const ADataStorage: ISudokuData);
begin
  inherited Create;
  FDataStorage := ADataStorage;
  DataStorage.Events.OnDataChanged := DataChanged;
  DataStorage.Events.OnRedrawCell := RedrawCell;
end;

procedure TBaseSudokuDisplayhandler.DataChanged(Sender: TObject);
begin
  Refresh;
end;

procedure TBaseSudokuDisplayhandler.DrawCellBorders(aCell: ISudokuCell; var
    Rect: TRect; State: TGridDrawState);
var
  CV: TCanvas;
  LLocation: TCellInBlockLocation;
begin
  CV := Grid.Canvas;
  CV.Pen.Color := clBlack;
  CV.Pen.Style := psSolid;
  CV.Pen.Width := 1;
  if ([gdSelected, gdFocused] * State) <> [] then begin
    if aCell.EvenOnly then
      CV.Brush.Color := clAqua
    else
      CV.Brush.Color := clYellow;
  end
  else if aCell.EvenOnly then
    CV.Brush.Color := clSilver
  else
    CV.Brush.Color := clWhite;
  CV.Brush.Style := bsSolid;
  Rect.Inflate(1,1);
  if Rect.Left < 0 then Rect.Left := 0;
  if Rect.Top < 0 then Rect.Top := 0;
  CV.Rectangle(Rect);
  Rect.Inflate(-1,-1);
  LLocation := aCell.BlockLocation;
  CV.Pen.Width := 2;
  if TBlockPosition.Left in LLocation then
    CV.Polyline([Rect.TopLeft, Point(Rect.Left, Rect.Bottom)]);
  if (TBlockPosition.Right in LLocation) and (aCell.Col = Grid.ColCount) then
    CV.Polyline([Point(Rect.Right, Rect.Top), Point(Rect.Right, Rect.Bottom)]);

  if TBlockPosition.Top in LLocation then
    CV.Polyline([Rect.TopLeft, Point(Rect.Right, Rect.Top)]);
  if (TBlockPosition.Bottom in LLocation) and (aCell.Row = Grid.RowCount) then
    CV.Polyline([Point(Rect.Left, Rect.Bottom), Point(Rect.Right, Rect.Bottom)]);
  Rect.Inflate(-1,-1);
end;

procedure TBaseSudokuDisplayhandler.DrawCellData(aCell: ISudokuCell; Rect:
    TRect);
var
  Candidates: TSudokuValues;
  CV: TCanvas;
  N: TSudokuValue;
  R: TRect;
  S: string;
begin
    CV := Grid.Canvas;
    N := aCell.Value;
    if N > 0 then begin
      CV.Font.Height := - Rect.Height * 75 div 100;
      if aCell.IsValid then
        CV.Font.Color  := clBlack
      else
        CV.Font.Color  := clRed;
      CV.Font.Style  := [fsBold];
      S:= GetSymbol(N);
      CV.TextRect(Rect, S, [tfCenter, tfVerticalCenter, tfSingleLine]);
    end {if}
    else begin
      CV.Font.Height := - Rect.Height * 20 div 100;
      CV.Font.Color  := clBlue;
      CV.Font.Style  := [];
      Candidates := aCell.Candidates;
      R := Rect;
      R.Right := R.Left + Rect.Width div 3;
      R.Bottom:= R.Top + Rect.Height div 3;
      for N := 1 to High(N) do begin
        if N in Candidates then begin
          S:= GetSymbol(N);
          CV.TextRect(R, S, [tfCenter, tfVerticalCenter, tfSingleLine]);
          OffsetRect(R, R.Width, 0);
          if R.Right > Rect.Right then
            OffsetRect(R, -R.Width*3, R.Height);
        end; {if}
      end; {for}
    end; {else}
end;

function TBaseSudokuDisplayhandler.GetDefaultCellSize: Integer;
begin
  Result := 64;
end;

{! Get the string to draw in a cell for the cell value }
function TBaseSudokuDisplayhandler.GetSymbol(aValue: TSudokuValue): string;
begin
  Result := String.Parse(aValue);
end;

{!
<summary>
 Set up the draw grid as appropriate for the supported Sudoku type. </summary>
<param name="aGrid">is the grid to initialize, cannot be nil</param>
<exception cref="EParameterCannotBeNil">
 is raised if aGrid is nil. </exception>
<remarks>
 This method must be called once to connect the helper to the UI!</remarks>
}
procedure TBaseSudokuDisplayhandler.InitializeGrid(aGrid: TDrawGrid);
var
  LSudokuSize: integer;
  N, dx, dy: Integer;
  C: TControl;
begin
  if not Assigned(aGrid) then
    raise EParameterCannotBeNil.Create(Classname+'.InitiualizeGrid','aGrid');
  Grid := aGrid;
  Grid.OnDrawCell := SudokuGridDrawCell;
  LSudokuSize := Datastorage.Bounds.MaxValue;
  Grid.ColCount := LSudokuSize;
  Grid.RowCount := LSudokuSize;
  Grid.DefaultRowHeight := DefaultCellSize;
  Grid.DefaultColWidth := DefaultCellSize;
  Grid.DoubleBuffered := true;
  FInitialized := True;
  N:= Succ(Grid.DefaultColWidth) * LSudokuSize;
  dx :=  Grid.ClientWidth - N;
  dy :=  Grid.ClientHeight - N;
  C:= Grid.Owner as TControl;
  C.SetBounds(C.Left, C.Top, C.Width - dx, C.Height - dy);
end;

function TBaseSudokuDisplayhandler.IsInitialized: boolean;
begin
  Result := FInitialized;
end;

procedure TBaseSudokuDisplayhandler.RedrawCell(aCol, aRow: TSudokuCellIndex);
begin
  TGridCracker(Grid).InvalidateCell(aCol-1, aRow-1);
end;

procedure TBaseSudokuDisplayhandler.Refresh;
begin
  Grid.Invalidate;
end;

procedure TBaseSudokuDisplayhandler.SudokuGridDrawCell(Sender: TObject;
    ACol, ARow: Integer; Rect: TRect; State: TGridDrawState);
var
  LSudokuCell: ISudokuCell;
begin
  LSudokuCell := DataStorage.Cell[ACol+1, ARow+1];
  DrawCellBorders(LSudokuCell, Rect, State);
  DrawCellData(LSudokuCell, Rect);
end;

end.

