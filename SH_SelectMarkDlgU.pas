{!
<summary>
 This unit implements a simple modal dialog to select one of the defined
 stack marks from.
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
unit SH_SelectMarkDlgU;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.Buttons, Vcl.ExtCtrls, SH_SelectFromListDlgU,
  SudokuInterfacesU;

type
  TSelectMarkDlg = class(TSelectFromListDlg)
  public
    class function Execute(var aMark: string; const aSudoku: ISudokuHelper;
        aControl: TControl): Boolean;
    property SelectedMark: string read GetSelectedValue;
  end;

implementation

uses
  SH_StringsU;


{$R *.dfm}

class function TSelectMarkDlg.Execute(var aMark: string; const aSudoku:
    ISudokuHelper; aControl: TControl): Boolean;
var
  Dlg: TSelectMarkDlg;
begin
  Dlg:= TSelectMarkDlg.Create(nil);
  try
    Dlg.Caption :=SSelectMarkCaption;
    aSudoku.GetMarks(Dlg.ValueList.Items);
    Dlg.PositionBelow(aControl);
    Result := Dlg.ShowModal = mrOK;
    if Result then
      aMark := Dlg.SelectedMark;
  finally
    Dlg.Free;
  end;
end;

end.
