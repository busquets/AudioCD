unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls,
  Buttons, ExtCtrls, process;

type

  { TForm2 }

  TForm2 = class(TForm)
    BitBtn1: TBitBtn;
    btnCancel: TBitBtn;
    btnOK: TBitBtn;
    CheckBox1: TCheckBox;
    CheckBox2: TCheckBox;
    CheckBox3: TCheckBox;
    CheckBox4: TCheckBox;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Panel1: TPanel;
    Process1: TProcess;
    procedure BitBtn1Click(Sender: TObject);
    procedure CheckBox1Change(Sender: TObject);
    procedure CheckBox3Change(Sender: TObject);
    procedure CheckBox4Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    titel: string;
    function Execute: Boolean;
  end;

var
  Form2: TForm2;

implementation

{$R *.lfm}

{ TForm2 }


procedure TForm2.CheckBox3Change(Sender: TObject);
begin
  if CheckBox3.Checked then CheckBox4.Checked:=false;
end;

procedure TForm2.CheckBox1Change(Sender: TObject);
begin
 if Edit1.Enabled then Edit1.Enabled:=false
 else Edit1.Enabled:=true;

end;

procedure TForm2.BitBtn1Click(Sender: TObject);
var cdinfo: TStrings;i:Integer; device:String;
begin
  cdinfo := TStringList.Create;
  device:=ComboBox1.Items[ComboBox1.ItemIndex];
  device:=Copy(device, 0, Pos(' ', device));

  Process1.Executable:='/usr/bin/cdrdao';
  Process1.Parameters.Append('--device '+device);
  Process1.Parameters.Append('disk-info');
  Process1.Execute;
  Process1.Parameters.Clear;
  cdinfo.LoadFromStream(Process1.Output);
  for i:=0 to cdinfo.Count-1 do if Pos('empty',cdinfo[i])>0 then
  if Pos('yes',cdinfo[i])>0 then ShowMessage('beschreibbar');
  cdinfo.Free;
end;

procedure TForm2.CheckBox4Change(Sender: TObject);
begin
  if CheckBox4.Checked then CheckBox3.Checked:=false;
end;

procedure TForm2.FormCreate(Sender: TObject);
var cdinfo: TStrings;i:Integer;
begin
  cdinfo := TStringList.Create;
  Process1.Executable:='/usr/bin/cdrdao';
  Process1.Parameters.Append('scanbus');
  Process1.Execute;
  Process1.Parameters.Clear;
  cdinfo.LoadFromStream(Process1.Output);
  ComboBox1.Clear;
  for i:=0 to cdinfo.Count-1 do begin
     if pos('/dev/',cdinfo[i]) > 0 then ComboBox1.Items.Append(cdinfo[i]);
  end;
  cdinfo.Free;
  ComboBox1.ItemIndex:=0;
end;

function TForm2.Execute: Boolean;
begin
  Result := (ShowModal = mrOK);
  titel := Edit1.Text;
end;

end.

