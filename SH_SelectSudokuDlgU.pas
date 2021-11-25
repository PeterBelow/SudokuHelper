{!
<summary>
 This unit implements a simple modal dialog to select one of the registered
 Sudoku helpers from.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-11-07<p>
 Last modified       2021-11-07<p>
</history>
<copyright>Copyright 2021 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
restrictions for use or redistribution. Just leave the copyright note
above intact. The code carries no warranties whatsoever, use at your
own risk!</licence>
}
unit SH_SelectSudokuDlgU;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, SH_SelectFromListDlgU,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls;

type
  TSelectSudokuDlg = class(TSelectFromListDlg)
  public
    procedure AfterConstruction; override;
    class function Execute(var aSudoku: string; aControl: TControl): Boolean;
    property SelectedSudoku: string read GetSelectedValue;
  end;

implementation

uses
  BaseSudokuHelperU, SH_StringsU;


{$R *.dfm}

procedure TSelectSudokuDlg.AfterConstruction;
begin
  inherited;
  HelperRegistry.GetKnownHelpers(ValueList.Items);
  ValueList.Itemindex := 0;
end;

class function TSelectSudokuDlg.Execute(var aSudoku: string; aControl:
    TControl): Boolean;
var
  Dlg: TSelectSudokuDlg;
begin
  Dlg:= TSelectSudokuDlg.Create(nil);
  try
    Dlg.Caption :=SSelectSudokuCaption;
    Dlg.PositionBelow(aControl);
    Result := Dlg.ShowModal = mrOK;
    if Result then
      aSudoku := Dlg.SelectedSudoku;
  finally
    Dlg.Free;
  end;
end;


end.
