inherited fmCollectorConfig: TfmCollectorConfig
  Left = 740
  Top = 396
  Caption = 'Colector Config'
  ClientHeight = 181
  ClientWidth = 711
  ExplicitWidth = 717
  ExplicitHeight = 209
  PixelsPerInch = 96
  TextHeight = 13
  inherited RzPanel1: TRzPanel
    Width = 711
    Height = 154
    ExplicitWidth = 711
    ExplicitHeight = 154
    inherited gbModal: TRzGroupBox
      Width = 711
      Height = 154
      Caption = 'Config'
      ExplicitWidth = 711
      ExplicitHeight = 154
      object RzLabel1: TRzLabel
        Left = 8
        Top = 24
        Width = 71
        Height = 13
        Caption = 'LEA Config File'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object MsgSourceID: TRzLabel
        Left = 8
        Top = 88
        Width = 63
        Height = 13
        Caption = 'MsgSourceID'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = clBlue
        Font.Height = -11
        Font.Name = 'Tahoma'
        Font.Style = []
        ParentFont = False
      end
      object RzLabel2: TRzLabel
        Left = 128
        Top = 88
        Width = 27
        Height = 13
        Caption = 'FileID'
      end
      object RzLabel3: TRzLabel
        Left = 304
        Top = 88
        Width = 37
        Height = 13
        Caption = 'Position'
      end
      object ebLEAConfFile: TRzButtonEdit
        Left = 8
        Top = 48
        Width = 689
        Height = 21
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
        Height = 21
        FrameStyle = fsBump
        FrameVisible = True
        TabOrder = 1
        DisplayFormat = '0'
      end
      object neFileID: TRzNumericEdit
        Left = 128
        Top = 112
        Width = 145
        Height = 21
        FrameStyle = fsBump
        FrameVisible = True
        TabOrder = 2
        DisplayFormat = '0'
      end
      object neFilePosition: TRzNumericEdit
        Left = 304
        Top = 112
        Width = 145
        Height = 21
        FrameStyle = fsBump
        FrameVisible = True
        TabOrder = 3
        DisplayFormat = '0'
      end
      object ckbAudit: TRzCheckBox
        Left = 472
        Top = 112
        Width = 44
        Height = 15
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
    ExplicitTop = 154
    ExplicitWidth = 711
    inherited pnOKCancel: TRzPanel
      Left = 549
      ExplicitLeft = 549
    end
  end
  object odConf: TOpenDialog
    DefaultExt = '*.txt'
    Filter = 'Txt Files (*.txt)|*.txt|All Files (*.*)|*.*'
    Left = 224
    Top = 40
  end
end
