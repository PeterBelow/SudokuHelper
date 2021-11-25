{!
<summary>
 This unit implements the helper for the classic 9x9 Sudoku and its
 support classes.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-10-02<p>
 Last modified       2021-11-10<p>
</history>
<copyright>Copyright 2021 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
<remarks>
 The classic Sudoku uses a 9x9 grid and the numerals 1 to 9 as cell
 values. We use 0 to mark an empty cell. Blocks have a 3x3 size.
</remarks>
}
unit ClassicSudokuHelperU;

interface

uses
  BaseSudokuHelperU, SudokuInterfacesU;

{The classic 9x9 Sudoku is the default, so its name has to be accesible
 from other units. }
resourcestring
  CClassicSudoku9x9 = 'Classic Sudoku (9x9)';
  CClassicSudokuGosu9x9 = 'Classic Sudoku Gosu (9x9)';


type
  {! Helper for the classic 9x9 Sudoku }
  TClassicSudokuHelper = class(TBaseSudokuHelper)
  strict protected
    procedure CreateDatastorage; override;
    procedure CreateDisplayhandler; override;
    procedure CreateInputHandler; override;
  public
    class function GetDisplayname: string; override;
  end;

  {! Helper for the classic 9x9 Sudoku Gosu }
  TClassicSudokuGosuHelper = class(TClassicSudokuHelper)
  strict protected
    procedure CreateDatastorage; override;
  public
    class function GetDisplayname: string; override;
  end;


implementation

uses
  BaseSudokuDataStorageU, BaseSudokuDisplayhandlerU, BaseSudokuInputHandlerU;

const
  CBlockSize = 3;
  CMaxValue = 9;

{
For the classic 9x9 Sudokus all the functionality needed is implemented
in the base classes for data storage, display and input handlers. Derived
classes are only declared here for clarity and to support future
refactorings.
}
type
  TClassicSudokuDataStorage = class(TBaseSudokuDatastorage)
  end;

  TClassicSudokuDisplayhandler = class(TBaseSudokuDisplayhandler)
  end;

  TClassicSudokuInputhandler = class(TBaseSudokuInputhandler)
  end;


{== TClassicSudokuHelper ==============================================}

procedure TClassicSudokuHelper.CreateDatastorage;
begin
  Data := TClassicSudokuDataStorage.Create(CMaxValue, CBlockSize, CBlockSize, False);
end;

procedure TClassicSudokuHelper.CreateDisplayhandler;
begin
  Display := TClassicSudokuDisplayhandler.Create(Data);
end;

procedure TClassicSudokuHelper.CreateInputHandler;
begin
  InputHandler := TClassicSudokuInputhandler.Create(Data);
end;

class function TClassicSudokuHelper.GetDisplayname: string;
begin
  Result := CClassicSudoku9x9;
end;

{== TClassicSudokuGosuHelper ==========================================}

procedure TClassicSudokuGosuHelper.CreateDatastorage;
begin
  Data := TClassicSudokuDataStorage.Create(CMaxValue, CBlockSize, CBlockSize, True);
end;

class function TClassicSudokuGosuHelper.GetDisplayname: string;
begin
  Result := CClassicSudokuGosu9x9;
end;

initialization
  HelperRegistry.Register(TClassicSudokuHelper);
  HelperRegistry.Register(TClassicSudokuGosuHelper);
end.

