inherited fmCollectorConfig: TfmCollectorConfig
  Left = 740
  Top = 396
  Caption = 'Colector Config'
  ClientHeight = 181
  ClientWidth = 711
  ExplicitLeft = 740
  ExplicitTop = 396
  ExplicitWidth = 727
  ExplicitHeight = 219
  PixelsPerInch = 96
  TextHeight = 18
  inherited RzPanel1: TRzPanel
    Width = 711
    Height = 154
    inherited gbModal: TRzGroupBox
      Width = 711
      Height = 154
      Caption = 'Config'
      ExplicitLeft = -1
      ExplicitTop = -4
      ExplicitWidth = 711
      object RzLabel1: TRzLabel
        Left = 8
        Top = 24
        Width = 90
        Height = 18
        Caption = 'LEA Config File'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -15
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
      end
      object MsgSourceID: TRzLabel
        Left = 8
        Top = 88
        Width = 80
        Height = 18
        Caption = 'MsgSourceID'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -15
        Font.Name = 'Calibri'
        Font.Style = []
        ParentFont = False
      end
      object RzLabel2: TRzLabel
        Left = 128
        Top = 88
        Width = 36
        Height = 18
        Caption = 'FileID'
      end
      object RzLabel3: TRzLabel
        Left = 304
        Top = 88
        Width = 50
        Height = 18
        Caption = 'Position'
      end
      object ebLEAConfFile: TRzButtonEdit
        Left = 8
        Top = 48
        Width = 689
        Height = 26
        Text = ''
        FrameStyle = fsBump
        FrameVisible = True
        TabOrder = 0
        AltBtnWidth = 15
        ButtonWidth = 15
        OnButtonClick = ebLEAConfFileButtonClick
      end
      object neMsgSourceID: TRzNumericEdit
        Left = 8
        Top = 112
        Width = 80
        Height = 26
        FrameStyle = fsBump
        FrameVisible = True
        TabOrder = 1
        DisplayFormat = '0'
      end
      object neFileID: TRzNumericEdit
        Left = 128
        Top = 112
        Width = 145
        Height = 26
        FrameStyle = fsBump
        FrameVisible = True
        TabOrder = 2
        DisplayFormat = '0'
      end
      object neFilePosition: TRzNumericEdit
        Left = 304
        Top = 112
        Width = 145
        Height = 26
        FrameStyle = fsBump
        FrameVisible = True
        TabOrder = 3
        DisplayFormat = '0'
      end
      object ckbAudit: TRzCheckBox
        Left = 472
        Top = 112
        Width = 53
        Height = 20
        Caption = 'Audit'
        HotTrack = True
        State = cbUnchecked
        TabOrder = 4
      end
    end
  end
  inherited pnBottom: TRzPanel
    Top = 154
    Width = 711
    ExplicitLeft = 16
    ExplicitTop = 171
    ExplicitWidth = 711
    inherited pnOKCancel: TRzPanel
      Left = 549
    end
  end
  object odConf: TOpenDialog
    DefaultExt = '*.txt'
    Filter = 'Txt Files (*.txt)|*.txt|All Files (*.*)|*.*'
    Left = 224
    Top = 40
  end
end
