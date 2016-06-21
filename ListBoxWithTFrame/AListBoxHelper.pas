unit AListBoxHelper;

interface

uses
  Classes, Types, FMX.ListBox, FMX.Types;

Const
  CLastCheckPointTimerInterval = 150;

type
  TListBoxScrollEvent = procedure(Sender: TObject; ABegIndex, AEndIndex: Integer) of object;

  TListBoxScrollDetector = class
  public
    procedure ViewportPositionChangeFired(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);

  private
    FListBox: TListBox;
    FListBoxItemCount: Integer;
    FOnAir: Boolean;
    FLastCheckPoint: TDateTime;
    FLastCheckPointTimer: TTimer;
    FUpdatePoint: Integer;
    FCanNotifyUpdatePoint: Boolean;
    FOldViewportPosition, FNewViewportPosition: TPointF;

    FOnScrollBegin: TListBoxScrollEvent;
    FOnScroll: TListBoxScrollEvent;
    FOnScrollEnd: TListBoxScrollEvent;

    procedure FireOnScrollBegin;
    procedure FireOnScroll;
    procedure FireOnScrollEnd;
    procedure OnLastCheckPointTimerFired(Sender: TObject);

  public
    constructor Create(AListBox: TListBox);

  public
    property UpdatePoint: Integer write FUpdatePoint;
    property OnScrollBegin: TListBoxScrollEvent write FOnScrollBegin;
    property OnScroll: TListBoxScrollEvent write FOnScroll;
    property OnScrollEnd: TListBoxScrollEvent write FOnScrollEnd;
  end;

  function CreateListBoxItem(AHeight: Single; AListBox: TListBox): TListBoxItem;

implementation

uses
  SysUtils, FMX.Dialogs;

function CreateListBoxItem(AHeight: Single; AListBox: TListBox): TListBoxItem;
var
  LItem: TListBoxItem;
begin
  LItem := TListBoxItem.Create(nil); begin
    LItem.Height := AHeight;
    AListBox.AddObject(LItem);
  end;

  Result := LItem;
end;

{ TListBoxScrollDetector }

procedure TListBoxScrollDetector.ViewportPositionChangeFired(Sender: TObject; const OldViewportPosition, NewViewportPosition: TPointF; const ContentSizeChanged: Boolean);
begin
  FLastCheckPoint := Now;

  FOldViewportPosition := OldViewportPosition;
  FNewViewportPosition := NewViewportPosition;

  if FOnAir = False then begin
    FOnAir := True;
    FireOnScrollBegin;
    FLastCheckPointTimer.Enabled := True;
  end
  else begin
    FireOnScroll;
//    if NewViewportPosition.Y > FListBox.ContentBounds.Height - FListBox.Height then
//      showmessage('End');

  end;

end;

constructor TListBoxScrollDetector.Create(AListBox: TListBox);
begin
  FListBox := AListBox; begin
    FListBox.OnViewportPositionChange := ViewportPositionChangeFired;
    FListBoxItemCount := FListBox.Items.Count;
    FUpdatePoint := 75;
    FCanNotifyUpdatePoint := True;
  end;
  FLastCheckPointTimer := TTimer.Create(nil); begin
    FLastCheckPointTimer.Interval := CLastCheckPointTimerInterval;
    FLastCheckPointTimer.OnTimer := OnLastCheckPointTimerFired;
  end;
end;

procedure TListBoxScrollDetector.FireOnScrollBegin;
var
  LTopItem: TListBoxItem;
  LBottomItem: TListBoxItem;

  LTopItemIndex: Integer;
  LBottomItemIndex: Integer;
begin
  if Assigned(FOnScrollBegin) then begin
    LTopItem := FListBox.ItemByPoint(1, 0);
    LBottomItem := FListBox.ItemByPoint(1, FListBox.Size.Height - 1);

    LTopItemIndex := -1; if Assigned(LTopItem) then LTopItemIndex := LTopItem.Index;
    LBottomItemIndex := -1; if Assigned(LBottomItem) then LBottomItemIndex := LBottomItem.Index;

    FOnScrollBegin(nil, LTopItemIndex, LBottomItemIndex);
  end;
end;

procedure TListBoxScrollDetector.FireOnScroll;
var
//  LTopItem: TListBoxItem;
  LBottomItem: TListBoxItem;

//  LTopItemIndex: Integer;
  LBottomItemIndex: Integer;
begin
  if Assigned(FOnScroll) and FCanNotifyUpdatePoint then begin
//    LTopItem := FListBox.ItemByPoint(1, 0);
    LBottomItem := FListBox.ItemByPoint(1, FListBox.Size.Height - 1);

//    LTopItemIndex := -1; if Assigned(LTopItem) then LTopItemIndex := LTopItem.Index;
    LBottomItemIndex := -1; if Assigned(LBottomItem) then LBottomItemIndex := LBottomItem.Index;

    if LBottomItemIndex + 5 > FListBox.Items.Count then begin
      FCanNotifyUpdatePoint := False;
      FOnScroll(nil, -1, -1);
    end;
  end;
end;

procedure TListBoxScrollDetector.FireOnScrollEnd;
var
  LTopItem: TListBoxItem;
  LBottomItem: TListBoxItem;

  LTopItemIndex: Integer;
  LBottomItemIndex: Integer;
begin
  if Assigned(FOnScrollEnd) then begin
    LTopItem := FListBox.ItemByPoint(1, 0);
    LBottomItem := FListBox.ItemByPoint(1, FListBox.Size.Height - 1);
    LTopItemIndex := -1; if Assigned(LTopItem) then LTopItemIndex := LTopItem.Index;
    LBottomItemIndex := -1; if Assigned(LBottomItem) then LBottomItemIndex := LBottomItem.Index;

    FOnScrollEnd(nil, LTopItemIndex, LBottomItemIndex);
  end;
end;

procedure TListBoxScrollDetector.OnLastCheckPointTimerFired(Sender: TObject);
begin
  if FOnAir then begin
    if FLastCheckPoint + EncodeTime(0, 0, 0, CLastCheckPointTimerInterval) < Now then begin
      FireOnScrollEnd; FOnAir := False;
    end;

    if FListBoxItemCount <> FListBox.Items.Count then
      FCanNotifyUpdatePoint := True;
  end
  else
    FLastCheckPointTimer.Enabled := False;
end;

end.
