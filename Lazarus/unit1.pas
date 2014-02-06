unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs,
  StdCtrls, ComCtrls, Buttons, ExtCtrls, process, math, LCLIntf, LConvEncoding, unit2, unit3;

type

  { TForm1 }

  TForm1 = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    BitBtn5: TBitBtn;
    BitBtn6: TBitBtn;
    Image1: TImage;
    ListView1: TListView;
    Memo1: TMemo;
    Memo2: TMemo;
    Memo3: TMemo;
    Memo4: TMemo;
    OpenDialog1: TOpenDialog;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Process1: TProcess;
    Process2: TProcess;
    ProgressBar1: TProgressBar;
    SaveDialog1: TSaveDialog;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn5Click(Sender: TObject);
    procedure BitBtn6Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormDropFiles(Sender: TObject; const FileNames: array of String);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form1: TForm1;
  gesamtsekunden:Single=0;
  titel:String;

implementation

{$R *.lfm}

{ TForm1 }



procedure TForm1.BitBtn1Click(Sender: TObject);
begin
   Listview1.Clear;
   Image1.Width:=0;
   Application.Processmessages;
   gesamtsekunden:=0;
   DeleteDirectory('/tmp/audiocd', true);
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
var zusammenstellung:TStringList; dateiname, endung:String;
    i:Integer;
begin
  if gesamtsekunden>0 then begin
     If SaveDialog1.Execute then begin
        zusammenstellung:=TStringList.Create;
        dateiname:=ExtractFileName(SaveDialog1.FileName);
        endung:= ExtractFileExt(dateiname);
        delete(dateiname,length(dateiname)-length(endung)+1,length(endung));
        titel:=dateiname;
        zusammenstellung.Append(dateiname);
        for i:=0 to ListView1.Items.Count-1 do zusammenstellung.Append(ListView1.Items[i].SubItems[0]);
        zusammenstellung.SaveToFile(SaveDialog1.FileName);
        zusammenstellung.Free;
     end;
  end
  else ShowMessage('Zusammenstellung ist leer!');
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
var zusammenstellung:TStringList; dateiname,endung:String;
    i:Integer; minuten,sekunden:Single;
    output:TStrings;
begin
  If OpenDialog1.Execute then begin
    //leeren
     BitBtn1Click(nil);
     output:=TStringList.Create;
     ListView1.SortColumn:=-1;
     zusammenstellung:=TStringList.Create;
     zusammenstellung.LoadFromFile(OpenDialog1.FileName);

     for i:=0 to zusammenstellung.Count-1 do begin
       if i=0 then titel:=zusammenstellung[i]
       else begin
          dateiname:=ExtractFileName(zusammenstellung[i]);
          endung:= ExtractFileExt(dateiname);
          delete(dateiname,length(dateiname)-length(endung)+1,length(endung));
          ListView1.Items.Add;
          ListView1.Items.Item[ListView1.Items.Count-1].Caption:=dateiname;
          ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append(zusammenstellung[i]);

          //Audio Länge
          Process2.Executable:='/usr/bin/soxi';
          Process2.Parameters.Append('-D');
          Process2.Parameters.Append(zusammenstellung[i]);
          Process2.Execute;
          Process2.Parameters.Clear;
          output.LoadFromStream(Process2.Output);
          try
            sekunden:=StrToFloat(output[0]);
            gesamtsekunden:=gesamtsekunden+sekunden;
            minuten:=sekunden/60;
            sekunden:=(minuten-Floor(minuten))*60;
          except ShowMessage('soxi gibt keine gültige Länge der Audiodatei zurück!');
          end;
          ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append(IntToStr(Floor(minuten))+':'+IntToStr(Floor(sekunden)));
          ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append(output[0]);
          ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append('leer');
          output.Clear;
       end;
     end;
     ListView1.SortColumn:=0;
     Image1.Width:=Round((480*gesamtsekunden)/4440);
     if Image1.Width > 480 then Image1.Width:=481;
     Application.Processmessages;
     output.Free;
     zusammenstellung.Free;
  end;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  if ListView1.Selected<>nil then begin
     gesamtsekunden:=gesamtsekunden-StrToFloat(ListView1.Selected.SubItems[2]);
     ListView1.Selected.Delete;
     Image1.Width:=Round((480*gesamtsekunden)/4440);
     if Image1.Width > 480 then Image1.Width:=481;
     Application.Processmessages;
  end;
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
var i:Integer; dateiname,driver,device:String;
begin
 if gesamtsekunden>0 then begin
    //cd titel festlegen
    form2.Edit1.Text:=titel;
  if Form2.Execute then begin
   titel:=form2.titel;
   if Form2.CheckBox1.Checked then driver:='generic-mmc-raw'
   else  driver:='generic-mmc';
   device:=Form2.ComboBox1.Items[Form2.ComboBox1.ItemIndex];
   device:=Copy(device, 0, Pos(' ', device));

  //Dekodieren
   ProgressBar1.Max:=ListView1.Items.Count;
   ProgressBar1.Position:=0;

  for i:=0 to ListView1.Items.Count-1 do begin
     dateiname:=ExtractFileName(Listview1.Items[i].SubItems[0]);
     dateiname:='/tmp/audiocd/'+IntToStr(i)+'.wav';
     Process1.Executable:='/usr/bin/sox';
     Process1.Parameters.DelimitedText:='"'+Listview1.Items[i].SubItems[0]+'" -c 2 -r 44100 "'+dateiname+'"';
     if Form2.CheckBox3.Checked then Process1.Parameters.DelimitedText:=Process1.Parameters.DelimitedText+' remix 1'
     else if Form2.CheckBox4.Checked then Process1.Parameters.DelimitedText:=Process1.Parameters.DelimitedText+' remix 2';
     if Form2.CheckBox2.Checked then Process1.Parameters.DelimitedText:=Process1.Parameters.DelimitedText+' norm -0.5';
     Process1.Execute;
     Process1.Parameters.Clear;
     Progressbar1.StepIt;
     Application.Processmessages;
     Listview1.Items[i].SubItems[3]:=dateiname;//zu brennende Dateien
  end;

  //Toc Datei erstellen
  Memo4.Lines.Clear;
  Memo1.Lines[8]:='  TITLE "'+titel+'"';
  Memo4.Lines.AddStrings(Memo1.Lines);
  for i:=0 to ListView1.Items.Count-1 do begin
     Memo2.Lines[3]:='  TITLE "'+Listview1.Items[i].Caption+'"';
     Memo2.Lines[7]:='FILE "'+Listview1.Items[i].SubItems[3]+'" 0';
     Memo4.Lines.AddStrings(Memo2.Lines);
  end;
  for i:=0 to Memo4.Lines.Count-1 do begin
    Memo4.Lines[i]:=UTF8ToCP1252(Memo4.Lines[i]);
  end;

  //Brennen
  Memo4.Lines.SaveToFile('/tmp/audiocd/burn.toc');
  repeat
     Process1.Executable:='xterm';
     Process1.Parameters.DelimitedText:='-e /usr/bin/pkexec /usr/bin/cdrdao write --device '+device+' --driver '+driver+' --reload --eject /tmp/audiocd/burn.toc';
     Process1.Execute;
  until MessageDlg('AudioCD', 'Soll eine weitere CD gebrannt werden?', mtConfirmation, [mbNo,mbYes],0,mbNo) <> mrYes;
  Process1.Parameters.Clear;
  DeleteDirectory('/tmp/audiocd', true);
  end;
 end
 else ShowMessage('Zusammenstellung ist leer!');
end;

procedure TForm1.BitBtn6Click(Sender: TObject);
var i:Integer;
begin
  Form3.tracktitel:=TStringList.Create;
  Form3.trackdauer:=TStringList.Create;
  Form3.PRLabel1.Caption:=titel;
  for i:=0 to ListView1.Items.Count-1 do begin
     Form3.tracktitel.Append(Listview1.Items[i].Caption);
     Form3.trackdauer.Append(Listview1.Items[i].SubItems[1]);
  end;
  if Form3.tracktitel.Count > 10 then Form3.PRGridPanel1.RowCount:=Form3.tracktitel.Count
  else Form3.PRGridPanel1.RowCount:=10;
  Form3.Button1Click(nil);
  Form3.tracktitel.Free;
  Form3.trackdauer.Free;
end;


procedure TForm1.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
    //leeren
  BitBtn1Click(nil);
  RemoveDir('/tmp/audiocd');
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  CreateDir('/tmp/audiocd');
  Image1.Width:=0;
end;

procedure TForm1.FormDropFiles(Sender: TObject; const FileNames: array of String
  );
var dateiname,endung:String; i:Integer; minuten,sekunden:Single;
    output:TStrings;
begin
  output:=TStringList.Create;
  ListView1.SortColumn:=-1;
  for i:=0 to length(FileNames)-1 do begin
    dateiname:=ExtractFileName(FileNames[i]);
    endung:= ExtractFileExt(dateiname);
    delete(dateiname,length(dateiname)-length(endung)+1,length(endung));
    ListView1.Items.Add;
    ListView1.Items.Item[ListView1.Items.Count-1].Caption:=dateiname;
    ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append(FileNames[i]);

    //Audio Länge
    Process2.Executable:='/usr/bin/soxi';
    Process2.Parameters.Append('-D');
    Process2.Parameters.Append(FileNames[i]);
    Process2.Execute;
    Process2.Parameters.Clear;
    output.LoadFromStream(Process2.Output);
    try
    sekunden:=StrToFloat(output[0]);
    gesamtsekunden:=gesamtsekunden+sekunden;
    minuten:=sekunden/60;
    sekunden:=(minuten-Floor(minuten))*60;
    except ShowMessage('soxi gibt keine gültige Länge der Audiodatei zurück!');
    end;
    ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append(IntToStr(Floor(minuten))+':'+IntToStr(Floor(sekunden)));
    ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append(output[0]);
    ListView1.Items.Item[ListView1.Items.Count-1].SubItems.Append('leer');
    output.Clear;
 end;
  ListView1.SortColumn:=0;
  Image1.Width:=Round((480*gesamtsekunden)/4440);
  if Image1.Width > 480 then Image1.Width:=481;
  Application.Processmessages;
  output.Free;
end;


end.

