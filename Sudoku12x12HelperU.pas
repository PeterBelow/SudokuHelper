{!
<summary>
 This unit implements the helper for the  12x12 Sudoku and its
 support classes.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-10-20<p>
 Last modified       2021-11-10<p>
</history>
<copyright>Copyright 2021 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
<remarks>
 This Sudoku uses a 12x12 grid and the numerals 1 to 12 as cell
 values. We use 0 to mark an empty cell. Blocks have a 4x3 size.
 We also support the Gosu variant and one using hexadecimal digits
 instead of decimal, with the value range 1 to C.
</remarks>
}
unit Sudoku12x12HelperU;

interface

uses
  BaseSudokuHelperU, SudokuInterfacesU;

type
  {! Helper for the classic 12x12 Sudoku }
  T12x12SudokuHelper = class(TBaseSudokuHelper)
  strict protected
    procedure CreateDatastorage; override;
    procedure CreateDisplayhandler; override;
    procedure CreateInputHandler; override;
  public
    class function GetDisplayname: string; override;
  end;

  {! Helper for the 12x12 Sudoku Gosu }
  T12x12SudokuGosuHelper = class(T12x12SudokuHelper)
  strict protected
    procedure CreateDatastorage; override;
  public
    class function GetDisplayname: string; override;
  end;

  {! Helper for the 12x12 Sudoku using hexadecimal numbers }
  T12x12HexSudokuHelper = class(T12x12SudokuHelper)
  strict protected
    procedure CreateDisplayhandler; override;
    procedure CreateInputHandler; override;
  public
    class function GetDisplayname: string; override;
  end;

  {! Helper for the 12x12 Sudoku Gosu using hexadecimal numbers }
  T12x12HexSudokuGosuHelper = class(T12x12HexSudokuHelper)
  strict protected
    procedure CreateDatastorage; override;
  public
    class function GetDisplayname: string; override;
  end;

implementation

uses
  System.SysUtils,
  Buttons,
  BaseSudokuDataStorageU,
  BaseSudokuDisplayhandlerU,
  BaseSudokuInputhandlerU;

resourcestring
  CSudoku12x12 = '12x12 Sudoku';
  CSudoku12x12Gosu = '12x12 Sudoku Gosu';
  CHexSudoku12x12 = '12x12 Sudoku (hexadecimal)';
  CHexSudoku12x12Gosu = '12x12 Sudoku Gosu (hexadecimal)';
const
  CMaxValue = 12;
  CBlockWidth = 4;
  CBlockHeight = 3;
  CSymbols: array [0..12] of Char =
    (' ','1','2','3','4','5','6','7','8','9','A','B','C');

{
  For 12x12 Sudokus all necessary functionality for data storage and display
  is provided by the base classes; we only declare descendants for clarity
  and to support future refactorings. We need a descendant for the input
  handler, though, since we support letters a to c for the keyboard
  input of values 10 to 12. For the hexadecimal variants we also need
  a display handler.
}
type
  T12x12SudokuDataStorage = class(TBaseSudokuDatastorage)
  end;

  T12x12SudokuDisplayhandler = class(TBaseSudokuDisplayhandler)
  end;

  T12x12SudokuInputhandler = class(TBaseSudokuInputHandler)
  strict protected
    function IsAllowedValue(aChar: Char): boolean; override;
  end;

  T12x12HexSudokuDisplayhandler = class(T12x12SudokuDisplayhandler)
  strict protected
    function GetSymbol(aValue: TSudokuValue): string; override;
  end;

  T12x12HexSudokuInputhandler = class(T12x12SudokuInputhandler)
  strict protected
    procedure SetButtonSymbol(aButton: TSpeedbutton; aValue: TSudokuValue);
        override;
  end;

{== T12x12SudokuHelper ================================================}

procedure T12x12SudokuHelper.CreateDatastorage;
begin
  Data := T12x12SudokuDataStorage.Create(CMaxValue, CBlockHeight, CBlockWidth, False);
end;

procedure T12x12SudokuHelper.CreateDisplayhandler;
begin
  Display := T12x12SudokuDisplayhandler.Create(Data);
end;

procedure T12x12SudokuHelper.CreateInputHandler;
begin
  InputHandler := T12x12SudokuInputhandler.Create(Data);
end;

class function T12x12SudokuHelper.GetDisplayname: string;
begin
  Result := CSudoku12x12;
end;

{== T12x12SudokuGosuHelper ============================================}

procedure T12x12SudokuGosuHelper.CreateDatastorage;
begin
  Data := T12x12SudokuDataStorage.Create(CMaxValue, CBlockHeight, CBlockWidth, true);
end;

class function T12x12SudokuGosuHelper.GetDisplayname: string;
begin
  Result := CSudoku12x12Gosu;
end;

{== T12x12SudokuInputhandler ==========================================}

function T12x12SudokuInputhandler.IsAllowedValue(aChar: Char): boolean;
begin
  Result := CharInSet(aChar, ['0'..'9','A'..'C','a'..'c']);
end;

{== T12x12HexSudokuHelper =============================================}

procedure T12x12HexSudokuHelper.CreateDisplayhandler;
begin
  Display := T12x12HexSudokuDisplayhandler.Create(Data);
end;

procedure T12x12HexSudokuHelper.CreateInputHandler;
begin
  InputHandler := T12x12HexSudokuInputhandler.Create(Data);
end;

class function T12x12HexSudokuHelper.GetDisplayname: string;
begin
  Result := CHexSudoku12x12;
end;

{== T12x12HexSudokuGosuHelper =========================================}

procedure T12x12HexSudokuGosuHelper.CreateDatastorage;
begin
  Data := T12x12SudokuDataStorage.Create(CMaxValue, CBlockHeight, CBlockWidth, true);
end;

class function T12x12HexSudokuGosuHelper.GetDisplayname: string;
begin
  Result := CHexSudoku12x12Gosu;
end;

{== T12x12HexSudokuInputhandler =======================================}

procedure T12x12HexSudokuInputhandler.SetButtonSymbol(aButton: TSpeedbutton;
    aValue: TSudokuValue);
begin
  aButton.Caption := CSymbols[aValue];
end;

{== T12x12HexSudokuDisplayhandler =====================================}

{! Get the string to draw in a cell for cell value }
function T12x12HexSudokuDisplayhandler.GetSymbol(aValue: TSudokuValue): string;
begin
  Result :=  CSymbols[aValue];
end;


initialization
  HelperRegistry.Register(T12x12SudokuHelper);
  HelperRegistry.Register(T12x12SudokuGosuHelper);
  HelperRegistry.Register(T12x12HexSudokuHelper);
  HelperRegistry.Register(T12x12HexSudokuGosuHelper);
end.
