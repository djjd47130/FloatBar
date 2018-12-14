object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Float Bar Test'
  ClientHeight = 456
  ClientWidth = 796
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object FloatBar1: TFloatBar
    Left = 16
    Top = 0
    Width = 425
    Height = 57
    BtnWidth = 50
    BtnHeight = 20
    Collapsed = False
    Color = clWhite
    object BitBtn1: TBitBtn
      AlignWithMargins = True
      Left = 3
      Top = 3
      Width = 102
      Height = 31
      Align = alLeft
      Caption = 'Test Button'
      TabOrder = 0
    end
  end
end
