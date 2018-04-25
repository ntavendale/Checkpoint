inherited fmGetMsgSrcID: TfmGetMsgSrcID
  Left = 967
  Top = 419
  Caption = 'Msg Src ID'
  ClientHeight = 102
  ClientWidth = 200
  ExplicitLeft = 967
  ExplicitTop = 419
  ExplicitWidth = 216
  ExplicitHeight = 140
  PixelsPerInch = 96
  TextHeight = 18
  inherited RzPanel1: TRzPanel
    Width = 200
    Height = 75
    ExplicitWidth = 200
    ExplicitHeight = 75
    inherited gbModal: TRzGroupBox
      Width = 200
      Height = 75
      Caption = 'Enter Msg Src ID...'
      ExplicitWidth = 200
      ExplicitHeight = 75
      object neMsgSrcID: TRzNumericEdit
        Left = 8
        Top = 32
        Width = 177
        Height = 26
        FrameStyle = fsBump
        FrameVisible = True
        TabOrder = 0
        DisplayFormat = '0;(0)'
      end
    end
  end
  inherited pnBottom: TRzPanel
    Top = 75
    Width = 200
    ExplicitTop = 75
    ExplicitWidth = 200
    inherited pnOKCancel: TRzPanel
      Left = 38
      ExplicitLeft = 38
    end
  end
end
