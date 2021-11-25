object HelpViewerForm: THelpViewerForm
  Left = 0
  Top = 0
  ActiveControl = Browser
  Caption = 'Help '
  ClientHeight = 441
  ClientWidth = 624
  Color = clBtnFace
  DefaultMonitor = dmDesktop
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 15
  object Browser: TWebBrowser
    Left = 0
    Top = 0
    Width = 624
    Height = 441
    Align = alClient
    TabOrder = 0
    SelectedEngine = EdgeIfAvailable
    ExplicitLeft = 136
    ExplicitTop = 64
    ExplicitWidth = 300
    ExplicitHeight = 150
    ControlData = {
      4C0000007E400000942D00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126209000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
end
