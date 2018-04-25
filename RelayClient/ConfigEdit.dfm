inherited fmConfigEdit: TfmConfigEdit
  Left = 1020
  Top = 489
  Caption = 'Config'
  ClientHeight = 196
  ClientWidth = 406
  ExplicitLeft = 1020
  ExplicitTop = 489
  ExplicitWidth = 422
  ExplicitHeight = 234
  PixelsPerInch = 96
  TextHeight = 18
  inherited RzPanel1: TRzPanel
    Width = 406
    Height = 169
    inherited gbModal: TRzGroupBox
      Width = 406
      Height = 169
      Caption = 'Edit Settings'
      object RzLabel1: TRzLabel
        Left = 16
        Top = 32
        Width = 87
        Height = 18
        Caption = 'Collector Host'
      end
      object RzLabel2: TRzLabel
        Left = 296
        Top = 32
        Width = 85
        Height = 18
        Caption = 'Collector Port'
      end
      object RzLabel3: TRzLabel
        Left = 16
        Top = 96
        Width = 57
        Height = 18
        Caption = 'Log Level'
      end
      object ebCollectorHost: TRzEdit
        Left = 16
        Top = 56
        Width = 241
        Height = 26
        Text = ''
        FrameStyle = fsBump
        FrameVisible = True
        TabOrder = 0
      end
      object neCollectorPort: TRzNumericEdit
        Left = 316
        Top = 56
        Width = 65
        Height = 26
        FrameStyle = fsBump
        FrameVisible = True
        TabOrder = 1
        Max = 65536.000000000000000000
        Min = 1.000000000000000000
        DisplayFormat = '0'
      end
      object cbLogLevel: TRzComboBox
        Left = 16
        Top = 120
        Width = 185
        Height = 26
        Style = csDropDownList
        Ctl3D = False
        FrameStyle = fsBump
        FrameVisible = True
        ParentCtl3D = False
        TabOrder = 2
        Items.Strings = (
          'None'
          'Fatal'
          'Error'
          'Warning'
          'Info'
          'Debug')
      end
    end
  end
  inherited pnBottom: TRzPanel
    Top = 169
    Width = 406
    inherited pnOKCancel: TRzPanel
      Left = 244
    end
  end
end
