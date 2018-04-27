unit Unit1;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Button2: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  var
   Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  DLLRoutine: procedure;
  DLLHandle: THandle;
begin
  DLLHandle := LoadLibrary('amqp.dll');
  try
    DLLRoutine := GetProcAddress(DLLHandle, 'ShowDLLForm');

    if Assigned(DLLRoutine) then
      DLLRoutine
    else
      MessageDlg('The specified routine cannot be found.', mtInformation,
                  [mbOK], 0)
  finally
    FreeLibrary(DLLHandle);
  end;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  DLLRoutine: procedure(HostHandle: THandle);
  DLLHandle: THandle;
begin
  DLLHandle := LoadLibrary('FormLib.dll');
  try
    { DLLRoutine указывает на процедуру ShowDLLFormEx в файле amqp.dll }
    DLLRoutine := GetProcAddress(DLLHandle, 'ShowDLLFormEx');

    { Вызываем процедуру ShowDLLFormEx }
    if Assigned(DLLRoutine) then
      DLLRoutine(Handle) { Передаем дескриптор формы }
    else
      MessageDlg('The specified routine cannot be found.', mtInformation,
                  [mbOK], 0)
  finally
    FreeLibrary(DLLHandle);
  end;
end;

end.
