program SudokuHelper;

{$R 'helptext.res' 'helptext.rc'}

uses
  Forms,
  SudokuInterfacesU in 'SudokuInterfacesU.pas',
  BaseSudokuHelperU in 'BaseSudokuHelperU.pas',
  BaseSudokuInputHandlerU in 'BaseSudokuInputHandlerU.pas',
  BaseSudokuDataStorageU in 'BaseSudokuDataStorageU.pas',
  BaseSudokuDisplayhandlerU in 'BaseSudokuDisplayhandlerU.pas' {SH_MainU in 'SH_MainU.pas' {Mainform},
  SH_MainU in 'SH_MainU.pas' {Mainform},
  SH_MemoryU in 'SH_MemoryU.pas',
  SH_StringsU in 'SH_StringsU.pas',
  SH_SelectFromListDlgU in 'SH_SelectFromListDlgU.pas' {SelectFromListDlg},
  SH_SelectMarkDlgU in 'SH_SelectMarkDlgU.pas' {SelectMarkDlg},
  SH_SelectSudokuDlgU in 'SH_SelectSudokuDlgU.pas' {SelectSudokuDlg},
  ClassicSudokuHelperU in 'ClassicSudokuHelperU.pas',
  Sudoku12x12HelperU in 'Sudoku12x12HelperU.pas',
  Sudoku16x16HelperU in 'Sudoku16x16HelperU.pas',
  SudokuFilerU in 'SudokuFilerU.pas',
  SH_HelpviewerU in 'SH_HelpviewerU.pas' {HelpViewerForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Sudoku Helper';
  Application.CreateForm(TMainform, Mainform);
  Application.Run;
end.
