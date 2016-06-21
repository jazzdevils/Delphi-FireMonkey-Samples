program ScrollBoxWithFrame;



{$R *.dres}

uses
//  EMemLeaks,
//  EResLeaks,
//  EDialogWinAPIMSClassic,
//  EDialogWinAPIEurekaLogDetailed,
//  EDialogWinAPIStepsToReproduce,
//  EDebugExports,
//  EFixSafeCallException,
//  EMapWin32,
//  EAppVCL,
//  ExceptionLog7,
  System.StartUpCopy,
  FMX.Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Frame2: TFrame},
  Unit3 in 'Unit3.pas' {Frame3: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
