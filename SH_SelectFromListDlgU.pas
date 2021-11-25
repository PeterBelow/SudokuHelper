{!
<summary>
 This unit implements a simple modal dialog to select one value from
 a list.
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
unit SH_SelectFromListDlgU;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Buttons,
  Vcl.ExtCtrls;

type
  TSelectFromListDlg = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    Cancelbutton: TBitBtn;
    OKButton: TBitBtn;
    Label1: TLabel;
    ValueList: TListBox;
  strict protected
    function GetSelectedValue: string;
    procedure PositionBelow(aControl: TControl);
  protected
    procedure UpdateActions; override;
  end;


implementation


{$R *.dfm}

function TSelectFromListDlg.GetSelectedValue: string;
begin
  Result := ValueList.Items[ValueList.ItemIndex];
end;

procedure TSelectFromListDlg.PositionBelow(aControl: TControl);
var
  P: TPoint;
begin
  P:= aControl.BoundsRect.TopLeft;
  P.Offset(0, aControl.Height);
  P := aControl.Parent.ClientToScreen(P);
  Left := P.X - 2;
  Top := P.Y;
end;

procedure TSelectFromListDlg.UpdateActions;
begin
  inherited;
  OKButton.Enabled := ValueList.ItemIndex >= 0;
end;

end.
