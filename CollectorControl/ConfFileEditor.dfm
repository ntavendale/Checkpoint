inherited fmConfFileEditor: TfmConfFileEditor
  Left = 890
  Top = 384
  Caption = 'LEA Config File Editor'
  ClientHeight = 652
  ClientWidth = 552
  ExplicitWidth = 558
  ExplicitHeight = 680
  PixelsPerInch = 96
  TextHeight = 18
  inherited RzPanel1: TRzPanel
    Width = 552
    Height = 625
    ExplicitWidth = 552
    ExplicitHeight = 593
    inherited gbModal: TRzGroupBox
      Width = 552
      Height = 233
      Align = alTop
      Caption = 'Opsec Settings'
      ExplicitWidth = 552
      ExplicitHeight = 233
      object opsec_sic_name: TRzLabel
        Left = 8
        Top = 24
        Width = 101
        Height = 18
        Caption = 'opsec_sic_name'
      end
      object RzLabel1: TRzLabel
        Left = 8
        Top = 56
        Width = 80
        Height = 18
        Caption = 'lea_server ip'
      end
      object RzLabel2: TRzLabel
        Left = 8
        Top = 88
        Width = 129
        Height = 18
        Caption = 'lea_server auth_port'
      end
      object RzLabel3: TRzLabel
        Left = 8
        Top = 120
        Width = 131
        Height = 18
        Caption = 'lea_server auth_type'
      end
      object RzLabel4: TRzLabel
        Left = 8
        Top = 152
        Width = 212
        Height = 18
        Caption = 'lea_server opsec_entity_sic_name'
      end
      object RzLabel5: TRzLabel
        Left = 8
        Top = 184
        Width = 99
        Height = 18
        Caption = 'opsec_sslca_file'
      end
      object ebOpsecSicName: TRzEdit
        Left = 235
        Top = 21
        Width = 310
        Height = 26
        Text = ''
        TabOrder = 0
      end
      object ebLeaServerIP: TRzEdit
        Left = 235
        Top = 53
        Width = 174
        Height = 26
        Text = ''
        TabOrder = 1
      end
      object neLeaServerAuthPort: TRzNumericEdit
        Left = 235
        Top = 85
        Width = 78
        Height = 26
        TabOrder = 2
        Max = 65536.000000000000000000
        DisplayFormat = '0'
      end
      object ebLeaServerAuthType: TRzEdit
        Left = 235
        Top = 117
        Width = 174
        Height = 26
        Text = ''
        TabOrder = 3
      end
      object ebLeaServerOpsecEntitySicName: TRzEdit
        Left = 235
        Top = 149
        Width = 310
        Height = 26
        Text = ''
        TabOrder = 4
      end
      object ebOpsecSslcaFile: TRzButtonEdit
        Left = 235
        Top = 184
        Width = 310
        Height = 26
        Text = ''
        TabOrder = 5
        AltBtnWidth = 15
        ButtonWidth = 15
        OnButtonClick = ebOpsecSslcaFileButtonClick
      end
    end
    object gbAdditional: TRzGroupBox
      Left = 0
      Top = 233
      Width = 552
      Height = 392
      Align = alClient
      Caption = 'Additional Settings'
      TabOrder = 1
      ExplicitHeight = 360
      object vgAdditionalSettings: TcxVerticalGrid
        Left = 1
        Top = 19
        Width = 550
        Height = 372
        Align = alClient
        OptionsView.RowHeaderWidth = 189
        TabOrder = 0
        ExplicitHeight = 340
        Version = 1
        object catRow: TcxCategoryRow
          Properties.Caption = 'Opsec Debug Options'
          ID = 0
          ParentID = -1
          Index = 0
          Version = 1
        end
        object rowOpsecDebug: TcxEditorRow
          Properties.Caption = 'OpsecDebug'
          Properties.EditPropertiesClassName = 'TcxCheckBoxProperties'
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 1
          ParentID = -1
          Index = 1
          Version = 1
        end
        object rowOpsecDebugFile: TcxEditorRow
          Properties.Caption = 'OpsecDebugFile'
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 2
          ParentID = -1
          Index = 2
          Version = 1
        end
        object rowStartAtBeginning: TcxEditorRow
          Properties.Caption = 'StartAtBeginning'
          Properties.EditPropertiesClassName = 'TcxCheckBoxProperties'
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 3
          ParentID = -1
          Index = 3
          Version = 1
        end
        object rowLogLevel: TcxEditorRow
          Properties.Caption = 'LogLevel'
          Properties.EditPropertiesClassName = 'TcxComboBoxProperties'
          Properties.EditProperties.DropDownListStyle = lsFixedList
          Properties.EditProperties.Items.Strings = (
            'None'
            'Fatal'
            'Error'
            'Warning'
            'Info'
            'Debug')
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 4
          ParentID = -1
          Index = 4
          Version = 1
        end
        object rowFlushBatchSize: TcxEditorRow
          Properties.Caption = 'FlushBatchSize'
          Properties.EditPropertiesClassName = 'TcxSpinEditProperties'
          Properties.EditProperties.MaxValue = 1000000.000000000000000000
          Properties.EditProperties.MinValue = 1.000000000000000000
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 5
          ParentID = -1
          Index = 5
          Version = 1
        end
        object rowFlushBatchTimeout: TcxEditorRow
          Properties.Caption = 'FlushBatchTimeout'
          Properties.EditPropertiesClassName = 'TcxSpinEditProperties'
          Properties.EditProperties.MaxValue = 600.000000000000000000
          Properties.EditProperties.MinValue = 1.000000000000000000
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 6
          ParentID = -1
          Index = 6
          Version = 1
        end
        object rowLogBufferSize: TcxEditorRow
          Properties.Caption = 'LogBufferSize'
          Properties.EditPropertiesClassName = 'TcxSpinEditProperties'
          Properties.EditProperties.MaxValue = 4096.000000000000000000
          Properties.EditProperties.MinValue = 256.000000000000000000
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 7
          ParentID = -1
          Index = 7
          Version = 1
        end
        object rowRelayMode: TcxEditorRow
          Properties.Caption = 'RelayMode'
          Properties.EditPropertiesClassName = 'TcxCheckBoxProperties'
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 8
          ParentID = -1
          Index = 8
          Version = 1
        end
        object rowRelayIP: TcxEditorRow
          Properties.Caption = 'RelayIP'
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 9
          ParentID = -1
          Index = 9
          Version = 1
        end
        object rowRelayPort: TcxEditorRow
          Properties.Caption = 'RelayPort'
          Properties.EditPropertiesClassName = 'TcxSpinEditProperties'
          Properties.EditProperties.MaxValue = 65536.000000000000000000
          Properties.EditProperties.MinValue = 1.000000000000000000
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 10
          ParentID = -1
          Index = 10
          Version = 1
        end
        object rowAuditFW: TcxEditorRow
          Properties.Caption = 'Audit FW Record Handler'
          Properties.EditPropertiesClassName = 'TcxCheckBoxProperties'
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 11
          ParentID = -1
          Index = 11
          Version = 1
        end
        object rowAuditFWFilterField: TcxEditorRow
          Properties.Caption = 'Audit FW Filter Field'
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 12
          ParentID = -1
          Index = 12
          Version = 1
        end
        object rowAuditFWFilterValue: TcxEditorRow
          Properties.Caption = 'Audit FW Filter Value'
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 13
          ParentID = -1
          Index = 13
          Version = 1
        end
        object rowRecordHandlerLogging: TcxEditorRow
          Properties.Caption = 'Record Handler Logging'
          Properties.EditPropertiesClassName = 'TcxCheckBoxProperties'
          Properties.DataBinding.ValueType = 'String'
          Properties.Value = Null
          ID = 14
          ParentID = -1
          Index = 14
          Version = 1
        end
      end
    end
  end
  inherited pnBottom: TRzPanel
    Top = 625
    Width = 552
    ExplicitTop = 593
    ExplicitWidth = 552
    inherited pnOKCancel: TRzPanel
      Left = 390
      ExplicitLeft = 390
    end
  end
  object odConf: TOpenDialog
    DefaultExt = '*.p12'
    Filter = 'P12 Files (*.p12)|*.p12|All Files (*.*)|*.*'
    Left = 336
    Top = 176
  end
  object sdConf: TSaveDialog
    DefaultExt = '*.txt'
    Filter = 'Text Files (*txt)|*.txt|All Files (*.*)|*.*'
    Left = 312
    Top = 473
  end
end
