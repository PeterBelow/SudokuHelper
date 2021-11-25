{!
<summary>
 This unit implements a simple browser for the app's helppage.
 </summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 2021-11-19<p>
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
unit SH_HelpviewerU;

interface

uses
  Winapi.Windows,
  Winapi.Messages,
  System.SysUtils,
  System.Variants,
  System.Classes,
  Vcl.Graphics,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Dialogs,
  Vcl.OleCtrls,
  SHDocVw;

type
  THelpViewerForm = class(TForm)
    Browser: TWebBrowser;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  strict private
    class procedure CreateInstance; static;
    class function FindAndShowExisting: boolean; static;
    procedure ShowHelp;

   protected
      procedure CreateParams(var Params: TCreateParams); override;
   public
     class procedure Execute; static;
  end;

implementation

uses
  SH_MemoryU, System.IOUtils;

{$R *.dfm}

class procedure THelpViewerForm.CreateInstance;
var
  LForm: TForm;
begin
  LForm:= THelpViewerForm.Create(Application);
  LForm.Show;
end;

procedure THelpViewerForm.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := HWND_DESKTOP;
  { This allows the main form to move to above this form in Z order. By
    default all secondary forms stay above the main form and get in the
    way in this case, since the help viewer is modeless. }
end;

class procedure THelpViewerForm.Execute;
begin
  if not FindAndShowExisting then
    CreateInstance;
end;

class function THelpViewerForm.FindAndShowExisting: boolean;
var
  LForm: TForm;
  I: Integer;
begin
  Result := false;
  for I := 0 to Screen.FormCount - 1 do begin
    LForm := Screen.Forms[I];
    if LForm is THelpViewerForm then begin
      if LForm.WindowState = TWindowState.wsMinimized then
        LForm.WindowState := TWindowState.wsNormal;
      LForm.Show;
      LForm.BringToFront;
      Exit(true);
    end; {if}
  end; {for }
end;

procedure THelpViewerForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caHide;
end;

procedure THelpViewerForm.FormCreate(Sender: TObject);
begin
  AppMemory.RestoreFormState(self);
  ShowHelp;
end;

procedure THelpViewerForm.FormCloseQuery(Sender: TObject; var CanClose:
    Boolean);
begin
  AppMemory.SaveFormState(self);
end;

procedure THelpViewerForm.ShowHelp;
var
  LPath: string;
  LResource: TResourceStream;
begin
  LPath := TPath.Combine(TPath.GetTempPath, 'SudokuHelper.html');
  LResource := TResourceStream.Create(MainInstance, 'HELPTEXT', RT_RCDATA);
  try
    LResource.SaveToFile(LPath);
    Browser.Navigate(LPath);
  finally
    LResource.Free;
  end;
end;

end.
