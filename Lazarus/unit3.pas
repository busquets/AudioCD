unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, PReport, Forms, Controls, Graphics, Dialogs,
  StdCtrls, process;

type

  { TForm3 }

  TForm3 = class(TForm)
    Button1: TButton;
    PReport1: TPReport;
    PRGridPanel1: TPRGridPanel;
    PRGridPanel2: TPRGridPanel;
    PRLabel1: TPRLabel;
    PRLabel2: TPRLabel;
    PRLabel3: TPRLabel;
    PRLabel4: TPRLabel;
    PRLayoutPanel1: TPRLayoutPanel;
    Process1: TProcess;
    PRPage1: TPRPage;
    PRRect1: TPRRect;
    PRRect2: TPRRect;
    procedure Button1Click(Sender: TObject);
    procedure PRGridPanel1BeforePrintChild(Sender: TObject; ACanvas: TPRCanvas;
      ACol, ARow: integer; Rect: TRect);
  private
    { private declarations }
  public
    { public declarations }
    tracktitel,trackdauer:TStrings;
  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

procedure TForm3.Button1Click(Sender: TObject);
begin
    with PReport1 do
    begin
      FileName := '/tmp/audiocd/cover.pdf';
      BeginDoc;
      Print(PRPage1);
      EndDoc;
    end;
    Process1.Execute;
end;


procedure TForm3.PRGridPanel1BeforePrintChild(Sender: TObject;
  ACanvas: TPRCanvas; ACol, ARow: integer; Rect: TRect);
begin
    if ARow > tracktitel.Count-1 then begin
      Prlabel2.Caption:='';
      Prlabel3.Caption:='';
      Prlabel4.Caption:='';
      PRRect2.Printable:=false;
    end
    else begin
      Prlabel4.Caption:=IntToStr(ARow+1);
      Prlabel2.Caption:=tracktitel[ARow];
      Prlabel3.Caption:=trackdauer[ARow];
    end;
end;


end.

