object fMain: TfMain
  Left = 0
  Top = 0
  Caption = 'fMain'
  ClientHeight = 88
  ClientWidth = 655
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 312
    Top = 31
    Width = 40
    Height = 13
    Caption = '----------'
  end
  object Label3: TLabel
    Left = 16
    Top = 55
    Width = 128
    Height = 13
    Caption = #1054#1076#1085#1086#1074#1088#1077#1084#1077#1085#1085#1099#1093' '#1087#1086#1090#1086#1082#1086#1074
  end
  object Label2: TLabel
    Left = 16
    Top = 31
    Width = 68
    Height = 13
    Caption = '-----------------'
  end
  object Label4: TLabel
    Left = 456
    Top = 31
    Width = 122
    Height = 13
    Caption = #1054#1095#1077#1088#1077#1076#1080' '#1085#1072' '#1080#1089#1087#1086#1083#1085#1077#1085#1080#1080
  end
  object Label5: TLabel
    Left = 248
    Top = 55
    Width = 44
    Height = 13
    Caption = '-----------'
  end
  object Label6: TLabel
    Left = 584
    Top = 31
    Width = 6
    Height = 13
    Caption = '0'
  end
  object btnStart: TButton
    Left = 572
    Top = 50
    Width = 75
    Height = 25
    Caption = 'btnStart'
    TabOrder = 0
    OnClick = btnStartClick
  end
  object ProgressBar1: TProgressBar
    Left = 8
    Top = 8
    Width = 633
    Height = 17
    TabOrder = 1
  end
  object Edit2: TEdit
    Left = 150
    Top = 52
    Width = 57
    Height = 21
    NumbersOnly = True
    TabOrder = 2
    Text = '10'
  end
  object ADOConnection1: TADOConnection
    Connected = True
    ConnectionString = 
      'Provider=OraOLEDB.Oracle.1;Password=A;Persist Securit' +
      'y Info=True;User ID=risk_alexey;Data Source=rdwh'
    LoginPrompt = False
    Provider = 'OraOLEDB.Oracle.1'
    Left = 128
    Top = 8
  end
  object Timer1: TTimer
    Enabled = False
    Interval = 5000
    OnTimer = Timer1Timer
    Left = 416
  end
  object ADOQ_QE_Count: TADOQuery
    Active = True
    Connection = ADOConnection1
    CursorType = ctStatic
    Parameters = <>
    SQL.Strings = (
      'select count(*) as cnt'
      'from ('
      '  select '
      '     trunc(t.nn/10000)'
      '     ,count(*) as cnt'
      '  from LUNA_RES t'
      '  where dt = (select max(dt) from LUNA_TASK)'
      '  group by trunc(t.nn/10000)'
      '  having count(*) < 9999'
      ') t')
    Left = 296
    Top = 8
  end
  object ADOQuery1: TADOQuery
    Connection = ADOConnection1
    Parameters = <>
    Left = 216
    Top = 8
  end
end
