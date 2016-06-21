unit Unit3;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, 
  FMX.Types, FMX.Graphics, FMX.Controls, FMX.Forms, FMX.Dialogs, FMX.StdCtrls,
  FMX.Objects, FMX.Layouts;

type
  TFrame3 = class(TFrame)
    HorzScrollBox1: THorzScrollBox;
    Layout1: TLayout;
    Layout2: TLayout;
    Rectangle1: TRectangle;
    Layout3: TLayout;
    Layout4: TLayout;
    Rectangle2: TRectangle;
    Rectangle3: TRectangle;
    Rectangle4: TRectangle;
    Text1: TText;
    Text2: TText;
    Text3: TText;
    Text4: TText;
    Text5: TText;
    procedure Rectangle1Tap(Sender: TObject; const Point: TPointF);
    procedure Rectangle1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }

    procedure Init;
  end;

implementation

{$R *.fmx}

procedure TFrame3.Init;
begin
  Rectangle1.Stroke.kind := TBrushKind.None;
  Rectangle2.Stroke.kind := TBrushKind.None;
  Rectangle3.Stroke.kind := TBrushKind.None;
  Rectangle4.Stroke.kind := TBrushKind.None;

  Rectangle1.Fill.Kind := TBrushKind.Bitmap;
  Rectangle2.Fill.Kind := TBrushKind.Bitmap;
  Rectangle3.Fill.Kind := TBrushKind.Bitmap;
  Rectangle4.Fill.Kind := TBrushKind.Bitmap;

  Rectangle1.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
  Rectangle2.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
  Rectangle3.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
  Rectangle4.Fill.Bitmap.WrapMode := TWrapMode.TileStretch;
end;

procedure TFrame3.Rectangle1Click(Sender: TObject);
begin
//  showmessage(TRectangle(Sender).TagString);
end;

procedure TFrame3.Rectangle1Tap(Sender: TObject; const Point: TPointF);
begin
  showmessage(TRectangle(Sender).TagString);
end;

end.

