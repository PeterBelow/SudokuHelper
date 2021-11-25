object SelectFromListDlg: TSelectFromListDlg
  Left = 0
  Top = 0
  ActiveControl = ValueList
  BorderIcons = []
  BorderStyle = bsNone
  Caption = 'Select Sudoku'
  ClientHeight = 349
  ClientWidth = 351
  Color = clBtnFace
  DefaultMonitor = dmMainForm
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  PopupMode = pmAuto
  PixelsPerInch = 96
  TextHeight = 21
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 351
    Height = 303
    Align = alClient
    Caption = 'Panel1'
    Padding.Left = 6
    Padding.Top = 6
    Padding.Right = 6
    Padding.Bottom = 6
    ShowCaption = False
    TabOrder = 0
    object Label1: TLabel
      AlignWithMargins = True
      Left = 7
      Top = 7
      Width = 337
      Height = 21
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 6
      Align = alTop
      Caption = '&Known Sudokus'
      FocusControl = ValueList
      ExplicitWidth = 112
    end
    object ValueList: TListBox
      Left = 7
      Top = 34
      Width = 337
      Height = 262
      Align = alClient
      ItemHeight = 21
      TabOrder = 0
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 303
    Width = 351
    Height = 46
    Align = alBottom
    Caption = 'Panel2'
    Padding.Left = 6
    Padding.Top = 6
    Padding.Right = 6
    Padding.Bottom = 6
    ShowCaption = False
    TabOrder = 1
    object Cancelbutton: TBitBtn
      Left = 254
      Top = 7
      Width = 90
      Height = 32
      Align = alRight
      Kind = bkCancel
      NumGlyphs = 2
      TabOrder = 0
    end
    object OKButton: TBitBtn
      AlignWithMargins = True
      Left = 158
      Top = 7
      Width = 90
      Height = 32
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 6
      Margins.Bottom = 0
      Align = alRight
      Kind = bkOK
      NumGlyphs = 2
      TabOrder = 1
    end
  end
end
