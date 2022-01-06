program edit_prog;

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Memo1: TMemo;
    ComboBox1: TComboBox;
    procedure ComboBox1Change(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;


{$R *.dfm}

procedure TForm1.ComboBox1Change(Sender: TObject);
var
   file_in : text;
   put_file_in : string;
   line : string;

begin

  put_file_in := 'd:\hpt\rss2fido\post.bat';
  Assign(file_in, put_file_in);
   reset(file_in);
   while (not eof(file_in)) do
   begin
     readLn(file_in, line);
     WriteLn(line);
   end;
   close(file_in);
end;

end.
