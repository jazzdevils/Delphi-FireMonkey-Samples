
program Project1;

{$R *.dres}

uses
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Frame2: TFrame},
  Unit3 in 'Unit3.pas' {Frame3: TFrame},
  Unit4 in 'Unit4.pas' {Frame4: TFrame},
  uImageLoader in 'uImageLoader.pas',
  AsyncTask.HTTP in 'AsyncTask.HTTP.pas',
  AsyncTask in 'AsyncTask.pas',
  FMX.Devgear.Extentions in 'FMX.Devgear.Extentions.pas',
  AnonThread in 'AnonThread.pas',
  FMX.Devgear.HelperClass in 'FMX.Devgear.HelperClass.pas',
  Unit5 in 'Unit5.pas' {Frame5: TFrame},
  AListBoxHelper in 'AListBoxHelper.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
