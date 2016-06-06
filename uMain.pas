unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, IPPeerClient, REST.Client,REST.Types,
  REST.Response.Adapter, Data.Bind.Components, Data.Bind.ObjectScope,
  System.Rtti, System.Bindings.Outputs, Vcl.Bind.Editors, Data.Bind.EngExt,
  Vcl.Bind.DBEngExt, Data.DB, Datasnap.DBClient, Vcl.Grids, Vcl.DBGrids,
  Vcl.StdCtrls, Vcl.ComCtrls, Data.Win.ADODB, Vcl.ExtCtrls, Vcl.DBCtrls;

type
  TfMain = class(TForm)
    btnStart: TButton;
    ADOConnection1: TADOConnection;
    ProgressBar1: TProgressBar;
    Timer1: TTimer;
    Label1: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    ADOQ_QE_Count: TADOQuery;
    Label2: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    ADOQuery1: TADOQuery;
    procedure btnStartClick(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    counter: integer;
    count_task : integer;
    count_que : integer;
  end;

  TMyThread = class(TThread)
  private
    { Private declarations }
  protected
    start: integer;
    stop: integer;
    procedure Execute; override;
  end;
  TOrbThread = class(TThread)
  private
    { Private declarations }
  protected
    count_que: integer;
    procedure Execute; override;
  end;
var
  fMain: TfMain;
  MyThread: TMyThread;
  OrbThread: TOrbThread;

implementation

{$R *.dfm}

procedure TMyThread.Execute;
var i: integer;
    s: string;
    MyRESTResponse1: TRESTResponse;
    MyRESTClient1: TRESTClient;
    MyRESTResponseDataSetAdapter1: TRESTResponseDataSetAdapter;
    MyRESTRequest1: TRESTRequest;
    MyClientDataSet1: TClientDataSet;
    MyDataSource1: TDataSource ;
    MyADOStoredProc1: TADOStoredProc;
    MyADOQuery: TADOQuery;

    v_dt      : Tdatetime;
    v_nn  : integer;
    v_rest_q  : string;
    v_jsontext      : string;
begin

  MyADOQuery:=TADOQuery.Create(nil);
  MyADOQuery.ConnectionString:='Provider=OraOLEDB.Oracle.1;Password=A;Persist Security Info=True;User ID=risk_alexey;Data Source=rdwh;Extended Properties=""';
  //                            Provider=OraOLEDB.Oracle.1;Password=A;Persist Security Info=True;User ID=risk_alexey;Data Source=rdwh;Extended Properties=""

  MyADOQuery.Close;
  MyADOQuery.SQL.Clear;
  MyADOQuery.SQL.Text:='select * from LUNA_TASK where dt = (select max(dt) from LUNA_TASK) and nn between '
                      + IntToStr(start) +' and '+ IntToStr(stop);
  MyADOQuery.Open;
  if MyADOQuery.RecordCount > 0 then begin
      MyADOStoredProc1:=TADOStoredProc.Create(nil);
      MyRESTClient1:= TRESTClient.Create('http://vislabs-node1.hq.bc:8082/similar_templates?id=3956152&candidates=3956152');
      MyRESTResponse1:=TRESTResponse.Create(nil);
      MyRESTRequest1:=TRESTRequest.Create(nil);
      MyRESTResponseDataSetAdapter1:=TRESTResponseDataSetAdapter.Create(nil);
      MyClientDataSet1:=TClientDataSet.Create(nil);
      MyDataSource1:=TDataSource.Create(nil);

      MyRESTClient1.Accept:='application/json, text/plain; q=0.9, text/html;q=0.8,';
      MyRESTClient1.AcceptCharset:='UTF-8, *;q=0.8';
      MyRESTResponseDataSetAdapter1.Dataset:=MyClientDataSet1;
      MyRESTResponseDataSetAdapter1.Response:=MyRESTResponse1;
      MyDataSource1.DataSet:=MyClientDataSet1;
      MyRESTRequest1.Client:=MyRESTClient1;
      MyRESTRequest1.Response:=MyRESTResponse1;
      MyRESTRequest1.Method:=TRestRequestMethod.rmGET;

      MyADOStoredProc1.Connection:=fMain.ADOConnection1;
      MyADOStoredProc1.ProcedureName := 'LUNA_RES_ADD';

      MyADOQuery.First;
      while not MyADOQuery.Eof do
      begin
         v_dt:= MyADOQuery.FieldByName('DT').AsDateTime;
         v_nn:= MyADOQuery.FieldByName('NN').AsInteger;
         v_rest_q:= MyADOQuery.FieldByName('REST_QUERY').AsString;
         v_jsontext:='';
         MyRESTClient1.BaseURL:=v_rest_q;
         //fMain.Memo1.Lines.Add(v_rest_q);
         inc(fMain.counter);
         try
            MyRESTRequest1.Execute;
            if Assigned(MyRESTResponse1.JSONValue) then
              begin
                v_jsontext:= MyRESTResponse1.JSONValue.ToString; //MyRESTResponse1.JSONText;
                MyADOStoredProc1.Parameters.Clear;
                MyADOStoredProc1.Parameters.CreateParameter('@P_NN',ftInteger,pdinput,50,v_nn);
                MyADOStoredProc1.Parameters.CreateParameter('@P_DT',ftDateTime,pdinput,50,v_dt);
                MyADOStoredProc1.Parameters.CreateParameter('@P_JSONTEXT',ftstring,pdinput,4000,v_jsontext);
                MyADOStoredProc1.ExecProc;
              end;
         except
              v_jsontext:= 'Ошибка в ответе с сервера LUNA'; //MyRESTResponse1.JSONText;
              MyADOStoredProc1.Parameters.Clear;
              MyADOStoredProc1.Parameters.CreateParameter('@P_NN',ftInteger,pdinput,50,v_nn);
              MyADOStoredProc1.Parameters.CreateParameter('@P_DT',ftDateTime,pdinput,50,v_dt);
              MyADOStoredProc1.Parameters.CreateParameter('@P_JSONTEXT',ftstring,pdinput,4000,v_jsontext);
              MyADOStoredProc1.ExecProc;
              //fMain.Memo1.Lines.Add('Ошибка');
         end;
         //fMain.Memo1.Lines.Add(MyRESTResponse1.JSONValue.ToString);
          //выводим данные
          //MyRESTResponse1.ErrorMessage;
         MyADOQuery.Next;
      end;
      MyDataSource1.Free;
      MyClientDataSet1.Free;
      MyRESTResponseDataSetAdapter1.Free;
      MyRESTRequest1.Free;
      MyRESTResponse1.Free;
      MyRESTClient1.Free;
      MyADOStoredProc1.Free;
  end;
  MyADOQuery.Free;
end;

procedure TOrbThread.Execute;
var i: integer;
    q_count_exec: integer;
    q_count_max: integer;
    cnt_q : integer;
    cnt_q1 : integer;
begin
  q_count_exec:= StrToInt(fMain.Label6.Caption);
  q_count_max:= StrToInt(fMain.Edit2.Text);
  {for i := 0 to count_que do
    begin
        MyThread:=TMyThread.Create(True);  //Параметр False запускает поток сразу после создания, True - запуск впоследствии , методом Resume
        MyThread.start:=i*10000;
        MyThread.stop:=i*10000+9999;
        MyThread.Resume;
        MyThread.Priority:=tpNormal;
        sleep(5000); //притормаживаем создание рабочих потоков, иначе можно утопить систему
        if (i >= 1) and (i mod q_count_max = 0) then
           begin
              repeat
                q_count_exec:= StrToInt(fMain.Label6.Caption);
                fMain.Label5.Caption:='Ожидание исполнения. '+ IntToStr(q_count_exec) + ' из '+ IntToStr(q_count_max);
                sleep(10*1000);
                q_count_max:= StrToInt(fMain.Edit2.Text);
              until (q_count_max - q_count_exec <=10) and (q_count_max - q_count_exec >=0);
              fMain.Label5.Caption:='Создание очередей';
           end;
    end;  }
    cnt_q:=0;
    cnt_q1:=q_count_max;
    repeat
      fMain.Label5.Caption:='Создание очередей';
      repeat
         MyThread:=TMyThread.Create(True);  //Параметр False запускает поток сразу после создания, True - запуск впоследствии , методом Resume
         MyThread.start:=cnt_q*10000;
         MyThread.stop:=cnt_q*10000+9999;
         MyThread.Resume;
         MyThread.Priority:=tpNormal;
         sleep(5000); //притормаживаем создание рабочих потоков, иначе можно утопить систему
         cnt_q1:=cnt_q1-1;
         inc(cnt_q);
      until (cnt_q1 <=0);
      repeat
        fMain.Label5.Caption:='Ожидание исполнения. '+ IntToStr(q_count_exec) + ' из '+ IntToStr(q_count_max);
        sleep(30*1000);
        q_count_max:= StrToInt(fMain.Edit2.Text);
        q_count_exec:= StrToInt(fMain.Label6.Caption);
        cnt_q1:= q_count_max-q_count_exec;
      until (cnt_q1 >0);
    until (cnt_q>count_que);
end;


procedure TfMain.btnStartClick(Sender: TObject);

begin
  btnStart.Enabled:=False;
  ADOQuery1.Close;
  ADOQuery1.SQL.Clear;
  ADOQuery1.SQL.Text:='select count(*) as cnt from LUNA_TASK where dt = (select max(dt) from LUNA_TASK) ';
  ADOQuery1.Open;
  count_task:= ADOQuery1.FieldByName('cnt').AsInteger;
  count_que:= trunc(count_task/10000);
  Label2.Caption:='Всего очередей: '+ IntToStr(count_que);


  counter:=0;

  OrbThread:=TOrbThread.Create(True);
  OrbThread.count_que:=count_que;
  OrbThread.Resume;
  OrbThread.Priority:=tpNormal;

  Timer1.Enabled:=True;
end;

procedure TfMain.FormShow(Sender: TObject);
begin
  ProgressBar1.Min:=0;
  ProgressBar1.Max:=100;

end;

procedure TfMain.Timer1Timer(Sender: TObject);
begin
   Application.ProcessMessages;
   ProgressBar1.Position:= round(counter/count_task*100);
   Label1.Caption:= IntToStr(ProgressBar1.Position);
   ADOQ_QE_Count.Close;
   ADOQ_QE_Count.Open;
   Label6.Caption:=ADOQ_QE_Count.FieldByName('CNT').AsString;
end;

end.
