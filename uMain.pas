unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  FloatBar, Vcl.Buttons;

type
  TForm1 = class(TForm)
    FloatBar1: TFloatBar;
    BitBtn1: TBitBtn;
    procedure FormCreate(Sender: TObject);
  private

  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
  FloatBar1.Width:= FloatBar1.Width + 1;
end;

end.
