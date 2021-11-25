{!
<summary>
 SH_MainU
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2015-09-26<p>
 Version 2.0 created 2021-09-30<p>
 Last modified       2021-11-16<p>
</history>
<copyright>Copyright 2021 by Dr. Peter Below</copyright>
<licence> The code in this unit is released to the public domain without
 restrictions for use or redistribution. Just leave the copyright note
 above intact. The code carries no warranties whatsoever, use at your
 own risk!
</licence>
<remarks>
 This unit implements the main form of the SudokuHelper aqpplication.
 Its main features are a draw grid for the display of the Sudoku and
 a set of buttons on a panel to the right of the grid. The grid and the
 set of buttons used to select values for mouse/touch input are adapted
 to the requirements of a specific kind of Sudoku. This will also adjust
 the form size as needed.

 The program logic is completely handled by a set of classes the main form
 only accesses via as set of interfaces, and the form also implements an
 interface itself to allow the classes in question (especially the one
 handling mouse and keyboard input) to get some info on the state of the
 UI.
</remarks>
}
unit SH_MainU;

interface

uses
  System.Actions,
  System.Classes,
  System.ImageList,
  System.SysUtils,
  System.Types,
  System.Variants,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.ActnList,
  Vcl.Buttons,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Dialogs,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Grids,
  Vcl.ImgList,
  Vcl.StdActns,
  Vcl.StdCtrls,
  Forms,
  SudokuInterfacesU;

const
  UM_FOCUSGRID = WM_USER + 111;
type
  {! The application's main form, autocreated. The form "remembers" the
    position and type of Sudoku used in the last program run. }
  TMainform = class(TForm, ISudokuHostform)
    UndoButton: TButton;
    Messagetimer: TTimer;
    SudokuPanel: TPanel;
    ButtonsPanel: TPanel;
    StatusBar: TStatusBar;
    SudokuGrid: TDrawGrid;
    ActionList: TActionList;
    Images: TImageList;
    UndoAction: TAction;
    ClearStackButton: TButton;
    ClearStackAction: TAction;
    StartNewButton: TButton;
    StartNewAction: TAction;
    TestButton: TButton;
    MouseButtonsPanel: TPanel;
    ToggleGosuButton: TSpeedButton;
    SetCandidatesButton: TSpeedButton;
    UnsetCandidatesButton: TSpeedButton;
    ClearCellButton: TSpeedButton;
    ValueButtonsPanel: TPanel;
    ActionsLabel: TLabel;
    RevertToMarkButton: TButton;
    SetMarkButton: TButton;
    SetMarkAction: TAction;
    RevertToMarkAction: TAction;
    LoadSudokuAction: TFileOpen;
    SaveSudokuAction: TFileSaveAs;
    LoadSudokuButton: TButton;
    SaveSudokuButton: TButton;
    HelpAction: TAction;
    procedure SpeedButtonClick(Sender: TObject);
    procedure ClearStackActionExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormPaint(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure HelpActionExecute(Sender: TObject);
    procedure LoadSudokuActionAccept(Sender: TObject);
    procedure LoadSudokuActionBeforeExecute(Sender: TObject);
    procedure MessagetimerTimer(Sender: TObject);
    procedure RevertToMarkActionExecute(Sender: TObject);
    procedure RevertToMarkActionUpdate(Sender: TObject);
    procedure SaveSudokuActionAccept(Sender: TObject);
    procedure SaveSudokuActionBeforeExecute(Sender: TObject);
    procedure SetMarkActionExecute(Sender: TObject);
    procedure StartNewActionExecute(Sender: TObject);
    procedure SudokuGridClick(Sender: TObject);
    procedure SudokuGridContextPopup(Sender: TObject; MousePos: TPoint; var
        Handled: Boolean);
    procedure SudokuGridKeyPress(Sender: TObject; var Key: Char);
    procedure SudokuGridKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure SudokuGridMouseDown(Sender: TObject; Button: TMouseButton; Shift:
        TShiftState; X, Y: Integer);
    procedure TestButtonClick(Sender: TObject);
    procedure UndoActionExecute(Sender: TObject);
    procedure UndoActionUpdate(Sender: TObject);
  strict private
    FLastMarkNum: Integer;
    FLastMouseButton: TMouseButton;
    FSudoku: ISudokuHelper;
    function GetCurrentCandidate: TSudokuValue;
    function GetCurrentValue: TSudokuValue;
    function GetDownValue(aParent: TWincontrol): TSudokuValue;
    procedure CreateSudokuHelper(const aName: string);
    procedure FocusGrid;
    procedure InitializeSudoku;
    procedure RunTest;
    procedure ShowHelpPrompt;
  strict protected
    function GetButtonsContainer: TWincontrol;
    function GetModifierkeys: TShiftstate;
    function GetRightClickAction: TRightClickAction;
  protected
    procedure UpdateActions; override;
    procedure UMFocusGrid(var Message: TMessage); message UM_FOCUSGRID;
    property CurrentCandidate: TSudokuValue read GetCurrentCandidate;
    property CurrentValue: TSudokuValue read GetCurrentValue;
    property Sudoku: ISudokuHelper read FSudoku;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Display(const S: string; Timed: Boolean = false); overload;
    procedure Display(const Fmt: string; const A: array of const; Timed:
      Boolean = false); overload;
  end;

var
  Mainform: TMainform;

implementation

uses
  System.Character,
  System.Generics.Collections,
  System.IOUtils,
  BaseSudokuHelperU,
  ClassicSudokuHelperU,
  SudokuFilerU,
  SH_MemoryU,
  SH_SelectSudokuDlgU,
  SH_StringsU,
  SH_SelectMarkDlgU, Winapi.ShellAPI, SH_HelpviewerU;

{$R *.dfm}

const
  MessageTimeout = 30000;  // 30 seconds

constructor TMainform.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  AppMemory.RestoreFormState(self);
end;

destructor TMainform.Destroy;
begin
  FSudoku := nil;
  inherited Destroy;
end;

{ This handler is used for all speedbuttons for which only the
  down state is relevant. The buttons are part of two button groups,
  which takes care of setting Down to false for all other buttons in
  the group. }
procedure TMainform.SpeedButtonClick(Sender: TObject);
begin
  (Sender as TSpeedbutton).Down := true;
end;

procedure TMainform.ClearStackActionExecute(Sender: TObject);
begin
  Sudoku.ClearUndostack;
  FocusGrid;
end;

procedure TMainform.CreateSudokuHelper(const aName: string);
begin
  FSudoku := HelperRegistry.CreateInstance(aName);
  InitializeSudoku;
end;

procedure TMainform.Display(const S: string; Timed:
  Boolean = false);
begin
  if Statusbar.SimplePanel then
    Statusbar.SimpleText := S
  else if Statusbar.Panels.Count > 0 then
    Statusbar.Panels[0].Text := S;
  if Timed then begin
    MessageTimer.Interval := MessageTimeout;
    MessageTimer.Enabled := true
  end; {if}
end;

procedure TMainform.Display(const Fmt: string; const A: array of const; Timed:
  Boolean = false);
begin
  Display(Format(Fmt, A), Timed);
end;

procedure TMainform.FocusGrid;
begin
//  SudokuGrid.SetFocus;
  PostMessage(Handle, UM_FOCUSGRID, 0, 0);
end;

procedure TMainform.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  AppMemory.SaveFormState(self);
end;

procedure TMainform.FormPaint(Sender: TObject);
begin
  OnPaint := nil;
  { We need to delay the helper creation at launch until the form is
    completely displayed, to avoid a collision with startup state
    restoration done by the constructor. }
  CreateSudokuHelper(AppMemory.LastSudoku);
  (*TODO: extracted code
  Display('Press F1 for a brief help overview');
  *)
  ShowHelpPrompt;
end;

procedure TMainform.FormResize(Sender: TObject);
begin
  Statusbar.Panels[0].Width :=
    Statusbar.ClientWidth - Statusbar.Panels[1].Width -
    Statusbar.Panels[2].Width - Statusbar.Height;
end;

{! Implements ISudokuHostform.GetButtonsContainer }
function TMainform.GetButtonsContainer: TWincontrol;
begin
  Result := ValueButtonsPanel;
end;

{! Implements ISudokuHostform.GetCurrentCandidate }
function TMainform.GetCurrentCandidate: TSudokuValue;
begin
  Result := GetDownValue(ValueButtonsPanel);
end;

{! Implements ISudokuHostform.GetCurrentValue }
function TMainform.GetCurrentValue: TSudokuValue;
begin
  Result := GetDownValue(ValueButtonsPanel);
end;

{! Get the Tag (encoding the value the button represents) of the
 speedbutton that is down.  }
function TMainform.GetDownValue(aParent: TWincontrol): TSudokuValue;
var
  Ctrl: TControl;
  I: Integer;
begin
  Result := 0;
  for I := 0 to aParent.ControlCount - 1 do begin
    Ctrl := aParent.Controls[I];
    if (Ctrl is TSpeedButton) and TSpeedButton(Ctrl).Down then begin
      Result := Ctrl.Tag;
      Break;
    end; {if}
  end; {for};
end;

{! Implements ISudokuHostform.GetModifierkeys }
function TMainform.GetModifierkeys: TShiftstate;
begin
  Result := KeyboardStateToShiftState();
end;

{!
<summary>
 Implements ISudokuHostform.GetRightClickAction</summary>
<returns>
 The action to take on a right click or keyboard input</returns>
<remarks>
 To set a candidate the user can hold down the Alt key and just type
 the value, or right-click with the mouse. To clear a candidate he
 can use the Ctrl key instead. The right-click action is also controlled
 with a group of speedbuttons, but the modifier keys take precedence.
 </remarks>
}
function TMainform.GetRightClickAction: TRightClickAction;
var
  LState: TShiftstate;
begin
  LState:= KeyboardStateToShiftState;
  if ssAlt in LState then
    Result := TRightClickAction.SetCandidate
  else if ssCtrl in LState then
    Result := TRightClickAction.UnsetCandidate
  else if ToggleGosuButton.Enabled and ToggleGosuButton.Down then
    Result := TRightClickAction.ToggleGosu
  else if SetCandidatesButton.Down then
     Result := TRightClickAction.SetCandidate
  else if UnsetCandidatesButton.Down then
    Result := TRightClickAction.UnsetCandidate
  else  // default action is to set a candidate
    Result := TRightClickAction.SetCandidate
end;

procedure TMainform.HelpActionExecute(Sender: TObject);
begin
  THelpViewerForm.Execute;
end;

procedure TMainform.InitializeSudoku;
begin
  Sudoku.Display.InitializeGrid(SudokuGrid);
  Sudoku.InputHandler.Initialize(self as ISudokuHostform);
  ToggleGosuButton.Enabled := Sudoku.IsGosu;
  AppMemory.LastSudoku := Sudoku.Displayname;
  Caption := String.Format(SMainformCaptionMask, [Sudoku.Displayname]);

  { Hack alert! Make sure the grid's OnClick handler can reliably distinguish
    a click fired by the left mouse button from one fired by cursor
    keys moving the selected cell.  The startup value for FLastMouseButton
    is 0, which equals TMouseButton.mbLeft! }
  FLastMouseButton := TMouseButton.mbMiddle;
end;

procedure TMainform.LoadSudokuActionAccept(Sender: TObject);
var
  LFilename: string;
  LSudoku: ISudokuHelper;
begin
  LFilename := LoadSudokuAction.Dialog.FileName;
  LSudoku := TSudokuFiler.LoadFromFile(LFilename);
  if Assigned(LSudoku) then begin
    FSudoku := LSudoku;
    InitializeSudoku;
    Sudoku.Display.Refresh;
    AppMemory.LastFolder := TPath.GetDirectoryName(LFilename);
  end; {if}
  FocusGrid;
end;

procedure TMainform.LoadSudokuActionBeforeExecute(Sender: TObject);
begin
  LoadSudokuAction.Dialog.InitialDir := AppMemory.LastFolder;
end;

procedure TMainform.MessagetimerTimer(Sender: TObject);
begin
  Messagetimer.Enabled := false;
  ShowHelpPrompt;
end;

procedure TMainform.RevertToMarkActionExecute(Sender: TObject);
var
  LMark: string;
begin
  if TSelectMarkDlg.Execute(LMark, Sudoku, RevertToMarkButton) then
    Sudoku.RevertToMark(LMark);
  FocusGrid;
end;

procedure TMainform.RevertToMarkActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Sudoku.HasMarks;
end;

procedure TMainform.RunTest;
(*
  var
    LList: TStack<Integer>;
    I: Integer;
    LArray: TArray<Integer>;
    SB: TStringbuilder;
 *)
begin
  (*
    SB := TStringbuilder.Create(4096);
    try
      LList := TStack<Integer>.Create();
      try
        for I := 1 to 10 do
          LList.Push(I);
        SB.AppendLine('Enumerator sequence:');
        for I in LList do
          SB.AppendFormat('%d, ',[I]);
        SB.AppendLine;
        SB.AppendLine('ToArray sequence:');
        LArray:= LList.ToArray;
        for I := Low(LArray) to High(LArray) do
          SB.AppendFormat('%d, ',[LArray[I]]);
        SB.AppendLine;
        SB.AppendLine('Pop sequence:');
        while LLIst.Count >0 do
          SB.AppendFormat('%d, ',[LList.Pop]);
        SB.AppendLine;
        ShowMessage(SB.ToString);
      finally
        LList.Free;
      end;
    finally
      SB.Free;
    end;
   *)
end;

procedure TMainform.SaveSudokuActionAccept(Sender: TObject);
var
  LFilename: string;
begin
  LFilename := SaveSudokuAction.Dialog.FileName;
  TSudokuFiler.SaveToFile(Sudoku, LFilename);
  AppMemory.LastFolder := TPath.GetDirectoryName(LFilename);
  FocusGrid;
  Display(SSaveFileMessageMask, [LFilename], true);
end;

procedure TMainform.SaveSudokuActionBeforeExecute(Sender: TObject);
begin
  SaveSudokuAction.Dialog.InitialDir := AppMemory.LastFolder;
end;

procedure TMainform.SetMarkActionExecute(Sender: TObject);
var
  LMark: string;
begin
  // Generate a proposed name
  repeat
    Inc(FLastMarkNum);
    LMark := String.Format(SNewMarkMask, [FLastMarkNum]);
  until not Sudoku.MarkExists(LMark) ;

  if InputQuery(SNewStackMarkCaption, SNewStackMarkPrompt, LMark) then begin
    Sudoku.AddMark(LMark);
  end; {if}
  FocusGrid;
end;

procedure TMainform.ShowHelpPrompt;
begin
  Display(SHelpPrompt);
end;

procedure TMainform.StartNewActionExecute(Sender: TObject);
var
  LSudokuName: string;
begin
  if TSelectSudokuDlg.Execute(LSudokuName, StartNewButton) then
    CreateSudokuHelper(LSudokuName);
  FocusGrid;
end;

procedure TMainform.SudokuGridClick(Sender: TObject);
var
  aCol: Integer;
  aRow: Integer;
  Mousepos: TPoint;
begin
  if FLastMouseButton <> TMouseButton.mbLeft then
    Exit;  // click event fired by cursor keys

  Mousepos:= SudokuGrid.ScreenToClient(Mouse.CursorPos);
  SudokuGrid.MouseToCell(Mousepos.X, MousePos.Y, aCol, aRow);

  Sudoku.InputHandler.HandleCellClick(aCol, aRow);
  { Make sure the next click can identify a mouse click vs. keyboard
    "click". }
  FLastMouseButton := TMouseButton.mbMiddle;
end;

procedure TMainform.SudokuGridContextPopup(Sender: TObject; MousePos: TPoint;
    var Handled: Boolean);
var
  aCol: Integer;
  aRow: Integer;
begin
  Handled := true;
  Mousepos:= SudokuGrid.ScreenToClient(Mouse.CursorPos);
  SudokuGrid.MouseToCell(Mousepos.X, MousePos.Y, aCol, aRow);
  if (aCol >= 0) and (aRow >= 0) then begin
    SudokuGrid.Col := aCol;
    SudokuGrid.Row := aRow;
    Sudoku.InputHandler.HandleCellClick(aCol, aRow, true);
  end; {if}
end;

procedure TMainform.SudokuGridKeyPress(Sender: TObject; var Key: Char);
begin
  if (SudokuGrid.Col >= 0) and (SudokuGrid.Row >= 0) then begin
    Sudoku.InputHandler.HandleCharacter(SudokuGrid.Col, SudokuGrid.Row, Key.ToUpper);
    Key := #0;
  end; {if}
end;

procedure TMainform.SudokuGridKeyUp(Sender: TObject; var Key: Word; Shift:
    TShiftState);
var
  LChar: Char;
begin
  if (Shift * [ssCtrl, ssAlt]) <> [] then begin
    // if Ctrl or Alt are down the OnKeyPress event will not fire! We
    // have to figure out which character key was pressed ourself
    case Key of
      VK_NUMPAD1..VK_NUMPAD9: LChar := Char(Ord('0') + Key - VK_NUMPAD0);
      Ord('1')..Ord('9'),
      Ord('A')..Ord('G'): LChar := Char(Key);
    else
      LChar := #0;
    end; {case }

    if LChar <> #0 then
      SudokuGridKeyPress(Sender, LChar);
  end;
  FocusGrid;
end;

procedure TMainform.SudokuGridMouseDown(Sender: TObject; Button: TMouseButton;
    Shift: TShiftState; X, Y: Integer);
begin
  FLastMouseButton := Button;
end;

procedure TMainform.TestButtonClick(Sender: TObject);
begin
  RunTest;
end;

procedure TMainform.UMFocusGrid(var Message: TMessage);
begin
  Message.Result := 1;
  SudokuGrid.SetFocus;
end;

procedure TMainform.UndoActionExecute(Sender: TObject);
begin
  Sudoku.Undo;
  FocusGrid;
end;

procedure TMainform.UndoActionUpdate(Sender: TObject);
begin
  (Sender as TAction).Enabled := Sudoku.CanUndo;
end;

procedure TMainform.UpdateActions;
begin
  inherited;
  StatusBar.Panels[1].Text := Format(SLeftMask,[CurrentValue]);
  StatusBar.Panels[2].Text := Format(SRightMask,[CurrentCandidate]);
  if GetAsyncKeyState(VK_MENU) < 0 then
    SetCandidatesButton.Down := true
  else
    if GetAsyncKeyState(VK_CONTROL) < 0 then
      UnsetCandidatesButton.Down := true;
end;

end.
