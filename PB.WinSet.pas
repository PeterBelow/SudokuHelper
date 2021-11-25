{!
<summary>
 Collects routines to save and restore form state</summary>
<author>Dr. Peter Below</author>
<history>
 Version 1.0 created 1997-07-03<p>
 Version 1.1 created 2002-06-07, changed to use of TcustomInifile
  <p>
 Version 1.2 created 2007-05-09, added option to save splitter
  positions and removed D1 compatibility.<p>
 Version 1.3 created 2009-01-16, modified for Unicode/D2009.<p>
 Version 1.4 created 2016-05-19, changed unit name to use the
 new qualified name syntax<p>
 Last modified       2016-05-19<p>
</history>
<copyright>
 Copyright 1997,2011 by Dr. Peter Below</copyright>
<licence>
 The code in this unit is released to the public domain without
 restrictions for use or redistribution. Just leave the copyright note
 above intact. The code carries no warranties whatsoever, use at your
 own risk!</licence>
}
unit PB.Winset;
{$INCLUDE PBDEFINES.INC}
interface

uses
  System.Inifiles, Vcl.Forms;

procedure SaveWindowstate(ini: TCustomInifile; form: TForm;
  SaveSplitters: Boolean = false);
procedure RestoreWindowstate(ini: TCustomInifile; form: TForm;
    RestoreSplitters: Boolean = false);
procedure SaveWindowstateEx(ini: TCustomInifile; form: TForm; const
  section: string; SaveSplitters: Boolean = false);
procedure RestoreWindowstateEx(ini: TCustomInifile; form: TForm; const
    section: string; RestoreSplitters: Boolean = false);

implementation

uses
  System.TypInfo, Winapi.Windows, Winapi.Messages, System.Classes,
  Vcl.ExtCtrls, Vcl.Controls, System.Sysutils, PB.CommonTypesU;

//NODOC-BEGIN
const
  sSettings = 'Settings';
  sLeft = 'Left';
  sTop = 'Top';
  sWidth = 'Width';
  sHeight = 'Height';
  sState = 'State';
  sSplitterPositions = 'SplitterPositions';

{! Create a string describing the splitter positions on the passed form.
 The generated string is composed of a comma-separated list of entries
 of the form controlname=Xnumber, where X is W or H to indicate whether
 the number following is the controls width or height, respectively.
 The control used is the one the splitter controls. We only examine
 splitters owned by the form!
 Note that this function is not compatible with Delphi versions before
 BDS 3.0, since the Align property was not available on the TControl
 class in older versions. One can work around this by using TypInfo
 methods to check whether Control has a published Align property and
 also to get its value. }
function ConstructSplitterString(form: TForm): string;

  function SplitterPosition(Splitter: TSplitter): string;
  var
    K: Integer;
    Parent: TWinControl;
    Control: TControl;
  begin
    Parent := Splitter.Parent;
    Result := '';
    for K := 0 to Parent.Controlcount - 1 do begin
      Control := Parent.Controls[K];
      if (Control <> Splitter) and (Control.Align = Splitter.Align)
      then begin
        case Splitter.Align of
          alTop, alBottom:
            Result := Format('%s=H%d',[Control.Name, Control.Height]);
          alLeft, alRight:
            Result := Format('%s=W%d',[Control.Name, Control.Width]);
        else
          Assert(false, 'Unexpected align value for the splitter');    
        end; {case}
        Break;
      end; {if}
    end; {for}
  end;

var
  SL: TStringList;
  I: Integer;
  Comp: TComponent;
begin
  SL := TStringList.Create();
  try
    for I := 0 to form.ComponentCount - 1 do begin
      Comp := form.Components[I];
      if Comp is TSplitter then
        SL.Add(Splitterposition(TSplitter(Comp)));
    end; {for}
    Result := SL.Commatext;
  finally
    SL.Free;
  end; {finally}
end;

{! Set the positions of splitters on form from the data contained in
 S. S is supposed to have been created by ConstructSplitterString. }
procedure SetSplitters(form: TForm; const S: string);
var
  SL: TStringList;
  I, N: Integer;
  Comp: TComponent;
  Value: string;
begin
  if S <> '' then begin
    SL := TStringList.Create();
    try
      Sl.Commatext := S;
      for I := 0 to SL.Count - 1 do begin
        Comp := form.FindComponent(SL.Names[I]);
        if Assigned(Comp) and (Comp Is TControl) then begin
          Value := SL.ValueFromIndex[I];
          if (Length(Value) > 1)
            and ((Value[1] = 'H') or (Value[1] = 'W'))
            and TryStrToInt(Copy(Value, 2, Maxint), N)
          then
            case Value[1] of
              'H': TControl(Comp).Height := N;
              'W': TControl(Comp).Width := N;
            end; {case}
        end; {if}
      end; {for}
    finally
      SL.Free;
    end; {finally}
  end; {if}
end;
//NODOC-END

{!
<summary>
 Saves the form's position, size, and (optionally) splitter positions
   to an INI file or equivalent.</summary>
<param name="ini">
 is the inifile to save the settings in, cannot be nil.</param>
<param name="form">
 s the form to save the settings for, cannot be nil.</param>
<param name="section">
 is the section to use for the settings.</param>
<param name="SaveSplitters">
 determines whether to save the positions for all
  splitters on the form as well.</param>
<exception cref="EParameterCannotBeNil">
 is raised if the ini or form parameters are nil.</exception>
}
procedure SaveWindowstateEx(ini: TCustomInifile; form: TForm; const
  section: string; SaveSplitters: Boolean = false);
const
  procname = 'SaveWindowstateEx';
var
  wp: TWindowPlacement;
begin
  if not Assigned(ini) then
    raise EParameterCannotBeNil.Create(procname,'ini');
  if not Assigned(form) then
    raise EParameterCannotBeNil.Create(procname,'form');

  wp.length := Sizeof(wp);
  GetWindowPlacement(form.handle, @wp);
  with Ini, wp.rcNormalPosition do begin
    WriteInteger(section, sLeft, Left);
    WriteInteger(section, sTop, Top);
    WriteInteger(section, sWidth, Right - Left);
    WriteInteger(section, sHeight, Bottom - Top);
    WriteString(section, sState,
      GetEnumName(TypeInfo(TwindowState), Ord(form.WindowState)));
  end; { With }
  if SaveSplitters then
    Ini.WriteString(section, sSplitterPositions,
      ConstructSplitterString(form));
end;

{!
<summary>
 Restores the form's position, size, and (optionally) splitter positions
   from an INI file or equivalent.</summary>
<param name="ini">
 is the inifile to restore the settings from, cannot be nil.</param>
<param name="form">
 s the form to restore the settings for, cannot be nil.</param>
<param name="section">
 is the section to read for the settings.</param>
<param name="SaveSplitters">
 determines whether to restore the positions for all
  splitters on the form as well.</param>
<exception cref="EParameterCannotBeNil">
 is raised if the ini or form parameters are nil.</exception>
}
procedure RestoreWindowstateEx(ini: TCustomInifile; form: TForm; const
    section: string; RestoreSplitters: Boolean = false);
const
  procname = 'RestoreWindowstateEx';
var
  L, T, W, H: Integer;
  WS: TWindowstate;
begin
  if not Assigned(ini) then
    raise EParameterCannotBeNil.Create(procname,'ini');
  if not Assigned(form) then
    raise EParameterCannotBeNil.Create(procname,'form');
  with Ini do begin
    L := ReadInteger(section, sLeft, form.Left);
    T := ReadInteger(section, sTop, form.Top);
    W := ReadInteger(section, sWidth, form.Width);
    H := ReadInteger(section, sHeight, form.Height);
    form.WindowState := wsNormal;
    form.SetBounds(L, T, W, H);
    try
      WS :=
        TWindowState(GetEnumValue(TYpeinfo(TWindowState),
        ReadString(section, sState, 'wsNormal')));
      {2009-01-26: In D2007 and D2009 setting the Windowstate to
       wsMinimized during startup does not create a taskbar button
       for the form! The application does not appear on screen at all
       and has to be killed via Taskmanager!}
      if WS = wsMinimized then
        WS := wsNormal;
      form.WindowState := WS;
//      case WS of
//        wsMaximized:
//          PostMessage(form.Handle, WM_SYSCOMMAND, SC_MAXIMIZE, 0);
//        wsMinimized:
//          PostMessage(form.Handle, WM_SYSCOMMAND, SC_MINIMIZE, 0);
//      end; { case }
      {*****BUG ALERT! ****
       For some reason sending instead of posting the message to a
       form during the create sequence can lead to the form to come
       up disabled on the API level. Posting the message does not
       have the problem but it has another: if the forms handle is
       recreated before the message is received it will get lost.
       Setting the forms windowstate directly has also problems.}
    except
    end;
  end; { With }
  if RestoreSplitters then
    SetSplitters(form, Ini.ReadString(section, sSplitterPositions, ''));
end;

{!
<summary>
 Saves the form's position, size, and (optionally) splitter positions
   to an INI file or equivalent, using the default section name.</summary>
<param name="ini">
 is the inifile to save the settings in, cannot be nil.</param>
<param name="form">
 s the form to save the settings for, cannot be nil.</param>
<param name="SaveSplitters">
 determines whether to save the positions for all
  splitters on the form as well.</param>
<exception cref="EParameterCannotBeNil">
 is raised if the ini or form parameters are nil.</exception>
}
procedure SaveWindowstate(ini: TCustomInifile; form: TForm;
  SaveSplitters: Boolean = false);
begin
  SaveWindowstateEx(ini, form, sSettings, SaveSplitters);
end;

{!
<summary>
 Restores the form's position, size, and (optionally) splitter positions
 from an INI file or equivalent, using the default section name.</summary>
<param name="ini">
 is the inifile to restore the settings from, cannot be nil.</param>
<param name="form">
 s the form to restore the settings for, cannot be nil.</param>
<param name="SaveSplitters">
 determines whether to restore the positions for all
  splitters on the form as well.</param>
<exception cref="EParameterCannotBeNil">
 is raised if the ini or form parameters are nil.</exception>
}
procedure RestoreWindowstate(ini: TCustomInifile; form: TForm;
    RestoreSplitters: Boolean = false);
begin
  RestoreWindowStateEx(ini, form, sSettings, RestoreSplitters);
end;

end.
