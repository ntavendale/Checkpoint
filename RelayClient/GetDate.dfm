inherited fmGetDate: TfmGetDate
  Left = 821
  Top = 407
  Caption = 'Get Date'
  ClientHeight = 98
  ClientWidth = 262
  ExplicitLeft = 821
  ExplicitTop = 407
  ExplicitWidth = 278
  ExplicitHeight = 136
  PixelsPerInch = 96
  TextHeight = 18
  inherited RzPanel1: TRzPanel
    Width = 262
    Height = 71
    ExplicitWidth = 262
    ExplicitHeight = 71
    inherited gbModal: TRzGroupBox
      Width = 262
      Height = 71
      Caption = 'Date'
      ExplicitTop = -4
      ExplicitWidth = 262
      ExplicitHeight = 71
      object dtDate: TRzDateTimeEdit
        Left = 8
        Top = 24
        Width = 241
        Height = 26
        EditType = etDate
        TabOrder = 0
      end
    end
  end
  inherited pnBottom: TRzPanel
    Top = 71
    Width = 262
    ExplicitTop = 71
    ExplicitWidth = 262
    inherited pnOKCancel: TRzPanel
      Left = 100
      ExplicitLeft = 100
    end
  end
end
