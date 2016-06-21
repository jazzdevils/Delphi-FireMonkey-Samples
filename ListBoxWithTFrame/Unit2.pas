unit Unit2;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts, FMX.Effects, FMX.Filter.Effects,
  FMX.Controls.Presentation, RectangleButton, FMX.Ani;

type
  TFrame2 = class(TFrame)
    GridPanelLayout1: TGridPanelLayout;
    Rectangle1: TRectangle;
    Layout1: TLayout;
    Text1: TText;
    Rectangle2: TRectangle;
    Layout2: TLayout;
    Text2: TText;
    Rectangle3: TRectangle;
    FlatRectButton1: TFlatRectButton;
    FloatAnimation1: TFloatAnimation;
    procedure Rectangle1Tap(Sender: TObject; const Point: TPointF);
    procedure FlatRectButton1Click(Sender: TObject);
  private
    { Private declarations }
//    oData: String;
  public
    { Public declarations }
    procedure Init;
  end;

implementation

{$R *.fmx}

procedure TFrame2.FlatRectButton1Click(Sender: TObject);
begin
  Showmessage(Text1.Text);
end;

procedure TFrame2.Init;
begin
  Rectangle1.Stroke.kind := TBrushKind.None;
  Rectangle2.Stroke.kind := TBrushKind.None;

  Rectangle1.Fill.Kind := TBrushKind.Bitmap;
  Rectangle2.Fill.Kind := TBrushKind.Bitmap;

  Rectangle1.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
  Rectangle2.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
end;

procedure TFrame2.Rectangle1Tap(Sender: TObject; const Point: TPointF);
begin
  Showmessage(TRectangle(Sender).TagString);
end;


end.
