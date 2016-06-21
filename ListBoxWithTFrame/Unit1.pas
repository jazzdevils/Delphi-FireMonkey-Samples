unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Layouts, FMX.StdCtrls,
  FMX.ListBox, System.Math, FMX.Platform, FMX.Controls.Presentation, AListBoxHelper,
  FMX.ScrollBox, FMX.Memo, FMX.Gestures, uImageLoader,  FMX.Objects, System.IOUtils, Unit4,
  FGX.ProgressDialog
  {$IFDEF ANDROID}
  , Androidapi.NativeActivity,
  Posix.Pthread
  {$ENDIF};

type
  TForm1 = class(TForm)
    Layout1: TLayout;
    ListBox1: TListBox;
    Timer1: TTimer;
    AniIndicator1: TAniIndicator;
    Timer2: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure Layout1Gesture(Sender: TObject;
      const EventInfo: TGestureEventInfo; var Handled: Boolean);
    procedure ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Single);
    procedure Timer1Timer(Sender: TObject);
    procedure ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Single);
    procedure Timer2Timer(Sender: TObject);
    procedure ListBox1ViewportPositionChange(Sender: TObject;
      const OldViewportPosition, NewViewportPosition: TPointF;
      const ContentSizeChanged: Boolean);
  private
    { Private declarations }
    ListBox_S_Y: Single;
    PullToRefreshCheck: Boolean;
    RefreshPos: Single;
    ImageLoader: TImageLoader;
    CurrentItemIndex: Integer;
    isScrolling: Boolean;

    aCurrentFrameIndex: Integer;

    aImage: array [0.. 19] of String;

    aFrameList: array [0.. 9] of TFrame4;

    oListBoxScrollDetector: TListBoxScrollDetector;

    function ExtractFileNameFromUrl(const AUrl: string): string;

    procedure ItemApplyStyleLookup(Sender: TObject);
    procedure RegisterRenderingSetup;
    procedure RenderingSetupCallBack(const Sender, Context: TObject; var ColorBits, DepthBits: Integer; var Stencil: Boolean;
        var Multisamples: Integer);
    procedure UnLoadImage;

    function LoadImage(sPath: String; Rectangle: TRectangle): Boolean;
    procedure LoadImageThread(sPath: String; Rectangle: TRectangle);
    procedure UnMemoryListBoxOutOfBound(iIndex: Integer);


    procedure OnScrollBegin(Sender: TObject; ABegIndex, AEndIndex: Integer);
    procedure OnScrollEnd(Sender: TObject; ABegIndex, AEndIndex: Integer);
    procedure OnScroll(Sender: TObject; ABegIndex, AEndIndex: Integer);

    procedure addItem(iCount: Integer);

    procedure OnScrollPassingCheckPointForMoreItem(Sender: TObject; ABegIndex,
      AEndIndex: Integer);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses  Unit2, Unit3, AsyncTask, AsyncTask.HTTP,
  FMX.Devgear.HelperClass, AnonThread, Unit5, System.Threading;

procedure TForm1.addItem(iCount: Integer);
var
  i: integer;
  Item: TListBoxItem;
  FrameCard4 : TFrame4;
  aTask: ITask;
  a: TGridPanelLayout;
  imageName: String;
begin
//  fgActivityDialog1.show;
//  sleep(1000);// for test

  ListBox1.BeginUpdate;
  for i := 0 to iCount - 1 do begin
    Item := TListBoxItem.Create(ListBox1);
    Item.Height := 250;//FrameCard4.Height;
    Item.Selectable := False;
    inc(aCurrentFrameIndex);
    Item.ItemData.Text := 'Index : ' + IntToStr(aCurrentFrameIndex);
    Item.OnApplyStyleLookup := ItemApplyStyleLookup;
    ListBox1.AddObject(Item);

//    Application.ProcessMessages;
  end;
  ListBox1.EndUpdate;

//  fgActivityDialog1.hide;
end;

function TForm1.ExtractFileNameFromUrl(const AUrl: string): string;
var
  i: Integer;
begin
  i := LastDelimiter('/', AUrl);
  Result := Copy(AUrl, i + 1, Length(AUrl) - (i));
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ScreenSize : TSize;
  i, y: Integer;
  FrameCard: TFrame2;
  FrameCard4: TFrame4;
  FrameCard5: TFrame5;
  FrameScrollCard: TFrame3;
  InStream1, InStream2, InStream3, InStream4: TResourceStream;
  imageName: String;
  Item: TListBoxItem;
  Card_Panel : TPanel;
//  Frame: TFrame4;


begin
  ScreenSize := Screen.Size;
  isScrolling := False;

//  aImage[0] := 'http://spnimage.edaily.co.kr/images/photo/files/NP/S/2014/06/PS14061200136.jpg';
//  aImage[1] := 'http://spnimage.edaily.co.kr/images/photo/files/NP/S/2014/07/PS14070400149.jpg';
//  aImage[2] := 'http://news.hankyung.com/nas_photo/201407/01.8907832.1.jpg';
//  aImage[3] := 'http://cphoto.asiae.co.kr/listimglink/6/2014062210555351507_1.jpg';
//  aImage[4] := 'http://www.sisaweek.com/news/photo/201406/24244_7634_92.jpg';
//  aImage[5] := 'http://img.etoday.co.kr/pto_db/2014/08/600/20140806094524_490705_889_487.jpg';
//  aImage[6] := 'http://file.dailian.co.kr/news/201405/news_1400101935_437582_m_1.jpg';
//  aImage[7] := 'http://image.ajunews.com/content/image/2014/08/13/20140813111006107824.jpg';
//  aImage[8] := 'http://www.niusnews.com/upload/imgs/default/13MayE/leehyori/1.jpg';
//  aImage[9] := 'http://www.starseoultv.com/news/photo/201409/265876_19496_2049.PNG';
//  aImage[10] := 'http://img.mbn.co.kr/filewww/news/other/2013/05/30/030515504114.jpg';
//  aImage[11] := 'http://thumb.mt.co.kr/06/2013/07/2013071910303226394_1.jpg';
//  aImage[12] := 'http://organicchiangmai.com/wp-content/uploads/2015/03/25.jpg';
//  aImage[13] := 'http://www.ekn.kr/data/photos/20140731/art_1406686581.jpg';
//  aImage[14] := 'http://cphoto.asiae.co.kr/listimglink/6/2014080608591918604_1.jpg';
//  aImage[15] := 'http://cphoto.asiae.co.kr/listimglink/6/2014072307223850843_1.jpg';
//  aImage[16] := 'http://upload.enews24.net/News/Contents/20140723/42054342.jpg';
//  aImage[17] := 'http://spnimage.edaily.co.kr/images/photo/files/NP/S/2014/05/PS14051400068.jpg';
//  aImage[18] := 'http://i.ytimg.com/vi/d-e8EBWoPU4/maxresdefault.jpg';
//  aImage[19] := 'http://img.newspim.com/content/image/2014/05/13/20140513000347_0.jpg';
  aImage[0] := 'http://momonestyle.com/wp-content/uploads/2015/03/150x150xdrip-546306_1280-150x150.jpg.pagespeed.ic.h31dAbuMgN.jpg';
  aImage[1] := 'http://static1.squarespace.com/static/54e3903be4b0c4c37d8730fb/55254900e4b026f75311d719/55254902e4b080589493eb53/1428506882852/BLANTON-150x150.jpg';
  aImage[2] := 'http://3-ps.googleusercontent.com/hk/MFeiBu8kLxr9ADI-y5QbmDaLOG/www.mec.ph/horizon/wp-content/uploads/2014/01/150xNxshutterfly1-150x150.jpg.pagespeed.ic.mc--bMUol2O2rA6DQ2x8.jpg';
  aImage[3] := 'http://cdn.couponcrew.net/shop/6428/logo/150x150xorange_140x140.standard.jpg.pagespeed.ic.8-4DOqeuK2.jpg';
  aImage[4] := 'http://nomad-saving.com/wp-content/uploads/2014/06/au_WALLET-150x150.jpg';
  aImage[5] := 'http://cdn.tutorialzine.com/wp-content/uploads/2014/04/10-mistakes-javascript-beginners-make-150x150.jpg';
  aImage[6] := 'http://dtsc.etri.re.kr/wp-content/uploads/2014/08/beacon_etri-150x150.jpg';
  aImage[7] := 'http://itstrike.biz/wp-content/uploads/2014-07-11-at-10-43-11-am1-150x150.jpg';
  aImage[8] := 'http://www.highwaysindustry.com/wp-content/uploads/2014/12/road_safety_week22-150x150.jpg';
  aImage[9] := 'http://www.highwaysindustry.com/wp-content/uploads/2015/01/Drive-me-to-the-moon-150x150.jpg';
  aImage[10] := 'http://www.samsungnyou.com/wp-content/uploads/2015/01/36_brand1_tit-150x150.jpg';
  aImage[11] := 'http://www.eurobiz.com.cn/wp-content/uploads/2014/05/BCS-cover-EN.jpg-e1401432417840-150x150.jpg';
  aImage[12] := 'http://www.img.lirent.net/2012/04/google-chrome-hack-update-new-download-tips-150x150.jpg';
  aImage[13] := 'http://all-lab.ru/wp-content/uploads/2014/09/Screenshot_2014-09-09-09-06-52-800x600-150x150.jpg.pagespeed.ce.sIBnLdUrfF.jpg';
  aImage[14] := 'http://itstrike.biz/wp-content/uploads/findmyiphoneupdate1-150x150.jpg';
  aImage[15] := 'http://gori.me/wp-content/uploads/2011/07/email_500.jpg.scaled500-150x150.jpg';
  aImage[16] := 'http://n3n6.com/wp-content/uploads/2013/11/20131115-132427-150x150.jpg';
  aImage[17] := 'http://2-ps.googleusercontent.com/hk/8rCklkmqxkkh332R8miU7gBDRm/www.mobilejury.com/wp-content/uploads/2013/10/150x150xQuiet-mode_LG-G2-150x150.jpg.pagespeed.ic.ieOFeFFk0DP_BTk_UpEA.jpg';
  aImage[18] := 'http://stealthsettings.com/wp-content/uploads/2014/06/firefox30-150x150.jpg';
  aImage[19] := 'http://nullpo-matome.com/wp-content/uploads/2015/06/wpid-012-150x150.jpg';

//  ListBox1.BeginUpdate;
//  for i := 0 to 99 do begin
//    if i mod 10 = 0 then begin
//      Item := TListBoxItem.Create(ListBox1);
//      FrameScrollCard := TFrame3.Create(Self);
//      FrameScrollCard.HitTest := False;
//      FrameScrollCard.Parent := Item;
//      FrameScrollCard.Name := 'FrameScrollCard' + IntToStr(i);
//      FrameScrollCard.Width := ListBox1.Width;
//  //    FrameScrollCard.Height := 235;
//      FrameScrollCard.Position.X := 0;
//      FrameScrollCard.Position.Y := 0;
//      Item.Height := 280;//FrameScrollCard.Height;
//      Item.Width := FrameScrollCard.Width;
//      Item.Selectable := False;
//      FrameScrollCard.Init;
//
//      imageName := aImage[RandomRange(0, 19)];
//      FrameScrollCard.Rectangle1.TagString := imageName;
//
//      imageName := aImage[RandomRange(0, 19)];
//      FrameScrollCard.Rectangle2.TagString := imageName;
//
//      imageName := aImage[RandomRange(0, 19)];
//      FrameScrollCard.Rectangle3.TagString := imageName;
//
//      imageName := aImage[RandomRange(0, 19)];
//      FrameScrollCard.Rectangle4.TagString := imageName;
//
//      Item.OnApplyStyleLookup := ItemApplyStyleLookup;
//      Item.Data := FrameScrollCard;
//      ListBox1.AddObject(Item);
//
//    end
//    else begin
//      Item := TListBoxItem.Create(ListBox1);
//      FrameCard := TFrame2.Create(Self);
//      FrameCard.HitTest := False;
//      FrameCard.Parent := Item;
//      FrameCard.Name := 'FrameCard' + IntToStr(i);
//      FrameCard.Width := ListBox1.Width;
//  //    FrameCard.Height := 235;
//      FrameCard.Position.X := 0;
//      FrameCard.Position.Y := 0;
//      Item.Height := 254;//FrameCard.Height;
//      Item.Width := FrameCard.Width;
//      Item.Selectable := False;
//      FrameCard.Init;
//
//      imageName := aImage[RandomRange(0, 19)];
//      FrameCard.Rectangle1.TagString := imageName;
//
//      imageName := aImage[RandomRange(0, 19)];
//      FrameCard.Rectangle2.TagString := imageName;
//
//      Item.OnApplyStyleLookup := ItemApplyStyleLookup;
//      Item.Data := FrameCard;
//      ListBox1.AddObject(Item);
//    end;
//  end;
  aCurrentFrameIndex := 0;

  for i := 0 to 9 do begin
    aFrameList[i] := TFrame4.Create(nil);
    aFrameList[i].Parent := nil;
    aFrameList[i].Width := ListBox1.Width;
    aFrameList[i].Position.X := 0;
    aFrameList[i].Position.Y := 0;

    imageName := aImage[RandomRange(0, 19)];
    aFrameList[i].Rectangle1.TagString := imageName;

    imageName := aImage[RandomRange(0, 19)];
    aFrameList[i].Rectangle2.TagString := imageName;

    aFrameList[i].Init;
  end;

  ListBox1.BeginUpdate;
  for i := 0 to 9 do begin
    Item := TListBoxItem.Create(ListBox1);
//    Item.Parent := ListBox1;
    Item.Height := 250;//FrameCard4.Height;
    Item.Selectable := False;
    inc(aCurrentFrameIndex);
    Item.ItemData.Text := 'fdsfdsfdsfds : ' + IntToStr(aCurrentFrameIndex);
//    Item.Width := ListBox1.Width;
    Item.OnApplyStyleLookup := ItemApplyStyleLookup;
//    Item.Data := FrameCard4;
//    aFrameList[i].Parent := Item;
    ListBox1.AddObject(Item);
  end;
  ListBox1.EndUpdate;

  oListBoxScrollDetector := TListBoxScrollDetector.Create(ListBox1);
  oListBoxScrollDetector.OnScrollEnd := OnScrollEnd;
  oListBoxScrollDetector.OnScrollBegin := OnScrollBegin;
  oListBoxScrollDetector.OnScroll := OnScroll;
end;

procedure TForm1.ItemApplyStyleLookup(Sender: TObject);
var
  CItem: TListBoxItem;
  FrameCard: TFrame2;
  FrameCard4: TFrame4;
  FrameScrollCard: TFrame3;
  sFileName1, sFileName2: String;
  TopIndex, BottomIndex: Integer;
begin
  CItem := TListBoxItem(Sender);
  if Assigned(CItem) then begin
    FrameCard4 := aFrameList[CurrentItemIndex];
    CItem.Data := FrameCard4;
    FrameCard4.Parent := CItem;
    FrameCard4.Visible := True;

    FrameCard4.Rectangle1.HitTest := False;
    FrameCard4.Rectangle2.HitTest := False;
    UnMemoryListBoxOutOfBound(CItem.Index);

    if FrameCard4.Rectangle1.Fill.Bitmap.Bitmap.IsEmpty = True then begin
      sFileName1 := ExtractFileNameFromUrl(FrameCard4.Rectangle1.TagString);
      if LoadImage(TPath.Combine(TPath.GetDocumentsPath, sFileName1), FrameCard4.Rectangle1) = False then begin
        FrameCard4.Rectangle1.Fill.Bitmap.Bitmap.SaveToFileFromUrl(FrameCard4.Rectangle1.TagString,
          TPath.Combine(TPath.GetDocumentsPath, sFileName1),
          procedure () begin
            LoadImage(TPath.Combine(TPath.GetDocumentsPath, sFileName1), FrameCard4.Rectangle1);
            FrameCard4.Text1.Text := 'New File: ' + IntToStr(CItem.Index);
          end);
      end
      else begin
        FrameCard4.Text1.Text := 'Cached File: ' + IntToStr(CItem.Index);
      end;
    end;

    if FrameCard4.Rectangle2.Fill.Bitmap.Bitmap.IsEmpty = True then begin
      sFileName2 := ExtractFileNameFromUrl(FrameCard4.Rectangle2.TagString);
      if LoadImage(TPath.Combine(TPath.GetDocumentsPath, sFileName2), FrameCard4.Rectangle2) = False then begin
        FrameCard4.Rectangle2.Fill.Bitmap.Bitmap.SaveToFileFromUrl(FrameCard4.Rectangle2.TagString,
          TPath.Combine(TPath.GetDocumentsPath, sFileName2),
          procedure () begin
            LoadImage(TPath.Combine(TPath.GetDocumentsPath, sFileName2), FrameCard4.Rectangle2);
            FrameCard4.Text2.Text := 'New File: ' + IntToStr(CItem.Index);
          end);
      end
      else begin
        FrameCard4.Text2.Text := 'Cached File: ' + IntToStr(CItem.Index);
      end;
    end;

    if CurrentItemIndex = 9 then
      CurrentItemIndex := 0
    else
      Inc(CurrentItemIndex);
  end;
end;

procedure TForm1.Layout1Gesture(Sender: TObject;
  const EventInfo: TGestureEventInfo; var Handled: Boolean);
begin
//  if GestureToIdent(EventInfo.GestureID, S) then begin
//    if S = 'sgiDown' then begin
//      Layout1.Position.Y := EventInfo.TapLocation.Y;
//
//    end;
//    Memo1.Lines.Insert(0, S + ' ' + IntToStr(Round(EventInfo.TapLocation.Y)));
//
//  end
//  else
//    Memo1.Lines.Insert(0, 'Could not translate gesture identifier');
//
//  Handled := True;

end;

procedure TForm1.ListBox1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  isScrolling := False;

  if ListBox1.ViewportPosition.Y = 0 then begin
    PullToRefreshCheck := True;
    RefreshPos := Y;
  end;
end;

procedure TForm1.ListBox1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Single);
var
  i: Integer;
begin
//  isScrolling := True;

  if PullToRefreshCheck then begin
    if Y > RefreshPos then begin
      if ListBox1.Position.Y < 100 then begin
        ListBox1.Position.Y := ListBox1.Position.Y + Y- RefreshPos
//      else begin
//        Timer1.Enabled := True;
      end;
    end;
  end;
end;

procedure TForm1.ListBox1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Single);
begin
  if PullToRefreshCheck then begin
    if (ListBox1.Position.Y - ListBox_S_Y) > 100 then begin
      Timer1.Enabled := True;
    end
    else begin
      PullToRefreshCheck := False;
      RefreshPos := 0;
      ListBox1.Position.Y := ListBox_S_Y;
    end;
  end;
end;

procedure TForm1.ListBox1ViewportPositionChange(Sender: TObject;
  const OldViewportPosition, NewViewportPosition: TPointF;
  const ContentSizeChanged: Boolean);
begin
//
end;

function TForm1.LoadImage(sPath: String; Rectangle: TRectangle): Boolean;
begin
  Result := False;

  if FileExists(sPath) then begin
//    Rectangle.Opacity := 0;
    Rectangle.Fill.Bitmap.Bitmap.LoadFromFile(sPath);
//    Rectangle.AnimateFloat('Opacity', 1.0, 1, TAnimationType.InOut,TInterpolationType.Linear);
    Result := True;
  end;
end;

procedure TForm1.LoadImageThread(sPath: String; Rectangle: TRectangle);
var
  _Thread: TAnonymousThread<TBitmap>;
begin
  _Thread := TAnonymousThread<TBitmap>.Create(
    function: TBitmap
    begin
//      Result := True;
//      _Thread.Synchronize(
//        procedure () begin
//          Rectangle.Opacity := 0;
//          Rectangle.Fill.Bitmap.Bitmap.LoadFromFile(sPath);
//          Rectangle.AnimateFloat('Opacity', 1.0, 0.5, TAnimationType.InOut,TInterpolationType.Linear);
//        end
//      )
      Result := TBitmap.Create;

    end,
    procedure(AResult: TBitmap)
    begin
//      Rectangle.Opacity := 0;
      AResult.LoadFromFile(sPath);
      Rectangle.Fill.Bitmap.Bitmap.Assign(AResult);
      AResult.Free;
//      Rectangle.AnimateFloat('Opacity', 1.0, 0.5, TAnimationType.InOut,TInterpolationType.Linear);
    end,
    procedure(AException: Exception)
    begin
    end
  );
end;

procedure TForm1.OnScroll(Sender: TObject; ABegIndex, AEndIndex: Integer);
begin
  addItem(20);
//  addItemThread(20);
end;

procedure TForm1.OnScrollBegin(Sender: TObject; ABegIndex, AEndIndex: Integer);
var
  i: integer;
begin
  if (ABegIndex > -1) and (AEndIndex > -1) then begin
    for i := ABegIndex to AEndIndex do begin
//      TFrame4(ListBox1.ItemByIndex(i).Data).Rectangle1.HitTest := False;
//      TFrame4(ListBox1.ItemByIndex(i).Data).Rectangle2.HitTest := False;
    end;
  end;
end;

procedure TForm1.OnScrollEnd(Sender: TObject; ABegIndex, AEndIndex: Integer);
var
  i: Integer;
begin
  if (ABegIndex > -1) and (AEndIndex > -1) then begin
    for i := ABegIndex to AEndIndex do begin
      TFrame4(ListBox1.ItemByIndex(i).Data).Rectangle1.HitTest := True;
      TFrame4(ListBox1.ItemByIndex(i).Data).Rectangle2.HitTest := True;
    end;

    if AEndIndex = ListBox1.Items.Count - 1 then
//      addItem(20);
  end;
end;

procedure TForm1.OnScrollPassingCheckPointForMoreItem(Sender: TObject;
  ABegIndex, AEndIndex: Integer);
begin
  addItem(1);
end;

procedure TForm1.RegisterRenderingSetup;
var
  SetupService: IFMXRenderingSetupService;
begin
//  if TPlatformServices.Current.SupportsPlatformService(IFMXRenderingSetupService, IInterface(SetupService)) then
//    SetupService.Subscribe(RenderingSetupCallBack);

end;

procedure TForm1.RenderingSetupCallBack(const Sender, Context: TObject;
  var ColorBits, DepthBits: Integer; var Stencil: Boolean;
  var Multisamples: Integer);
begin
  ColorBits := 16;
  DepthBits := 0;
  Stencil := False;
  Multisamples := 0;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
begin
  Timer1.Enabled := False;
  RefreshPos := 0;
  PullToRefreshCheck := False;
  ListBox1.Position.Y := ListBox_S_Y;
end;

procedure TForm1.Timer2Timer(Sender: TObject);
begin
  Timer2.Enabled := False;

//  ShowMessage('Stop scrolling');
end;

procedure TForm1.UnLoadImage;
begin
//
end;

procedure TForm1.UnMemoryListBoxOutOfBound(iIndex: Integer);
var
  TopIndex, BottomIndex: Integer;
  oFrame: TFrame4;
begin
  TopIndex := iIndex - 5;
  if TopIndex > -1 then begin
    oFrame := TFrame4(ListBox1.ItemByIndex(TopIndex).Data);
    if Assigned(oFrame) then begin
      TFrame4(ListBox1.ItemByIndex(TopIndex).Data).Rectangle1.Fill.Bitmap.Bitmap.DisposeOf;
      TFrame4(ListBox1.ItemByIndex(TopIndex).Data).Rectangle1.Fill.Bitmap.Bitmap.Width := 0;
      TFrame4(ListBox1.ItemByIndex(TopIndex).Data).Rectangle2.Fill.Bitmap.Bitmap.DisposeOf;
      TFrame4(ListBox1.ItemByIndex(TopIndex).Data).Rectangle2.Fill.Bitmap.Bitmap.Width := 0;
    end;
  end;

  BottomIndex := iIndex + 5;
  if BottomIndex < ListBox1.Items.Count - 1 then begin
    oFrame := TFrame4(ListBox1.ItemByIndex(BottomIndex).Data);
    if Assigned(oFrame) then begin
      TFrame4(ListBox1.ItemByIndex(BottomIndex).Data).Rectangle1.Fill.Bitmap.Bitmap.DisposeOf;
      TFrame4(ListBox1.ItemByIndex(BottomIndex).Data).Rectangle1.Fill.Bitmap.Bitmap.Width := 0;
      TFrame4(ListBox1.ItemByIndex(BottomIndex).Data).Rectangle2.Fill.Bitmap.Bitmap.DisposeOf;
      TFrame4(ListBox1.ItemByIndex(BottomIndex).Data).Rectangle2.Fill.Bitmap.Bitmap.Width := 0;
    end;

  end;
end;

end.

