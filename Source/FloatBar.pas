unit FloatBar;

(*
  TFloatBar control
  by Jerry Dodge

  The Float Bar is a container which "floats" within a form, typically
  at the top, which can be collapsed and shown by a small arrow icon.
  The design is inspired by that of the TeamViewer remote software.

  NOTE: THIS PROJECT IS IN NO WAY FUNCTIONAL YET!!!
*)

interface

uses
  System.Classes, System.SysUtils, System.Types,
  Vcl.Controls, Vcl.Graphics, Vcl.Forms,
  Winapi.Windows, Winapi.Messages, Winapi.DwmApi;

type
  TFloatBar = class;

  //Up/Down state - to change since control can be aligned to left or right
  TFBUpDown = (fbudUp, fbudDown) deprecated;

  //Edge of form to position control to
  TFBEdge = (fbeTop, fbeBottom, fbeLeft, fbeRight);

  TFloatBar = class(TCustomControl)
  private
    FInternalAlign: Boolean;
    FCollapsed: Boolean;
    FBtnHeight: Integer;
    FBtnWidth: Integer;
    procedure RepaintBorder;
    procedure PaintBorder;
    procedure SetCollapsed(const Value: Boolean);
    function BtnRect: TRect;
    procedure SetBtnHeight(const Value: Integer);
    procedure SetBtnWidth(const Value: Integer);
    function TransRect: TRect;
    function GetLeft: Integer;
    function GetTop: Integer;
    procedure SetLeft(const Value: Integer);
    procedure SetTop(const Value: Integer);
    procedure ParentResized;
    function GetAlign: TAlign;
    procedure SetAlign(const Value: TAlign);
  protected
    procedure RequestAlign; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCPaint(var Message: TWMNCPaint); message WM_NCPAINT;
    procedure WMNCHitTest(var Message: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMNCCalcSize(var Msg: TWMNCCalcSize); message WM_NCCALCSIZE;
    procedure WMLButtonUp(var Msg: TWMLButtonUp); message WM_LBUTTONUP;
    procedure WMNCLButtonUp(var Msg: TWMNCLButtonUp); message WM_NCLBUTTONUP;
    procedure Paint; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property Align: TAlign read GetAlign write SetAlign;
    function DestTop: Integer;
  published
    property BtnWidth: Integer read FBtnWidth write SetBtnWidth;
    property BtnHeight: Integer read FBtnHeight write SetBtnHeight;
    property Collapsed: Boolean read FCollapsed write SetCollapsed;

    property Top: Integer read GetTop write SetTop;
    property Left: Integer read GetLeft write SetLeft;

    property Color;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Float Bar', [TFloatBar]);
end;

procedure DrawChevron(ACanvas: TCanvas; ARect: TRect;
  AUpDown: TFBUpDown = TFBUpDown.fbudUp; AColor: TColor = clBlack);
var
  LP, CP, RP, VCP, TP, BP: Integer;
begin
  //Calculate position of chevron from center...
  CP:= Trunc((ARect.Width / 2) + ARect.Left);
  LP:= Trunc(CP - 10);
  RP:= Trunc(CP + 10);
  VCP:= Trunc((ARect.Height / 2) + ARect.Top);
  TP:= Trunc(VCP - 5);
  BP:= Trunc(VCP + 5);

  case AUpDown of
    fbudUp: begin
      ACanvas.MoveTo(LP, BP);
      ACanvas.LineTo(CP, TP);
      ACanvas.LineTo(RP, BP);
    end;
    fbudDown: begin
      ACanvas.MoveTo(LP, TP);
      ACanvas.LineTo(CP, BP);
      ACanvas.LineTo(RP, TP);
    end;
  end;
end;

{ TFloatBar }

constructor TFloatBar.Create(AOwner: TComponent);
begin
  inherited;
  Align:= alCustom;
  ControlStyle:= [csAcceptsControls,
    csCaptureMouse,
    csDesignInteractive,
    csClickEvents,
    csReplicatable,
    csNoStdEvents
    ];
  Width:= 400;
  Height:= 60;
  FBtnWidth:= 50;
  FBtnHeight:= 20;
  FCollapsed:= False;
end;

procedure TFloatBar.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  with Params.WindowClass do
    Style := Style and not (CS_HREDRAW or CS_VREDRAW);
end;

destructor TFloatBar.Destroy;
begin

  inherited;
end;

procedure TFloatBar.WndProc(var Message: TMessage);
begin

  //TODO: Need to make sure this works in a custom control - it was originally
  //  provided as a solution for a TForm, but this is not a TForm.
  //  The purpose is to make the rest of the form's non-client area actually respond.

  //if GlassFrame.Enabled and HandleAllocated and
    //DwmDefWindowProc(Handle, Message.Msg, Message.WParam,
      //Message.LParam, Message.Result) then Exit;

  inherited;
end;

function TFloatBar.DestTop: Integer;
begin
  if FCollapsed then begin
    Result:= -Height + FBtnHeight;
  end else begin
    Result:= 0;
  end;
end;

function TFloatBar.GetAlign: TAlign;
begin
  Result:= inherited Align;
end;

function TFloatBar.GetLeft: Integer;
begin
  Result:= inherited Left;
end;

function TFloatBar.GetTop: Integer;
begin
  Result:= DestTop;
end;

procedure TFloatBar.RepaintBorder;
begin
  if Visible and HandleAllocated then
    Perform(WM_NCPAINT, 0, 0);
end;

procedure TFloatBar.RequestAlign;
begin
  FInternalAlign := True;
  try
    inherited RequestAlign;
  finally
    FInternalAlign := False;
  end;
end;

procedure TFloatBar.SetAlign(const Value: TAlign);
begin
  inherited Align:= alCustom;
end;

procedure TFloatBar.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
begin
  if not FInternalAlign then
    if (Align <> alCustom) or ((ALeft = Left) and (ATop = Top) and
        (AWidth = Width) and (AHeight = Height)) then
      ParentResized;
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
end;

procedure TFloatBar.SetBtnHeight(const Value: Integer);
begin
  FBtnHeight := Value;
  RepaintBorder;
  Invalidate;
end;

procedure TFloatBar.SetBtnWidth(const Value: Integer);
begin
  FBtnWidth := Value;
  RepaintBorder;
  Invalidate;
end;

procedure TFloatBar.SetCollapsed(const Value: Boolean);
begin
  FCollapsed := Value;
  Top:= DestTop;
  RepaintBorder;
  Invalidate;
end;

procedure TFloatBar.SetLeft(const Value: Integer);
var
  V: Integer;
begin
  V:= (Parent.ClientWidth div 2) - (Width div 2);
  if inherited Left <> V then
    inherited Left:= V;
end;

procedure TFloatBar.SetTop(const Value: Integer);
begin
  if inherited Top <> 0 then
    inherited Top:= 0;
end;

procedure TFloatBar.WMNCPaint(var Message: TWMNCPaint);
begin
  inherited;
  PaintBorder;
end;

procedure TFloatBar.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

procedure TFloatBar.WMLButtonUp(var Msg: TWMLButtonUp);
begin
end;

procedure TFloatBar.WMNCLButtonUp(var Msg: TWMNCLButtonUp);
var
  P: TPoint;
begin
  P:= Point(Msg.XCursor, Msg.YCursor);
  if PtInRect(BtnRect, P) then begin
    //User clicked button...
    Self.Collapsed:= not Self.Collapsed;
  end;
end;

procedure TFloatBar.WMNCCalcSize(var Msg: TWMNCCalcSize);
var
  lpncsp: PNCCalcSizeParams;
begin
  //if Msg.CalcValidRects then begin
    lpncsp := Msg.CalcSize_Params;
    if lpncsp = nil then Exit;
    lpncsp.rgrc[0].Bottom:= lpncsp.rgrc[0].Bottom-FBtnHeight;
    Msg.Result := 0;
  //end;
  inherited;
end;

function TFloatBar.BtnRect: TRect;
begin
  //Return a rect where the non-client collapse button is to be...
  Result:= Rect(ClientWidth-FBtnWidth, ClientHeight, ClientWidth, ClientHeight+FBtnHeight);
end;

function TFloatBar.TransRect: TRect;
begin
  //Return a rect where the non-client transparent area is to be...
  Result:= Rect(0, ClientHeight, ClientWidth, ClientHeight+FBtnHeight);
end;

procedure TFloatBar.WMNCHitTest(var Message: TWMNCHitTest);
//var
  //P: TPoint;
begin
  {
  P:= Point(Message.XPos, Message.YPos);

  if PtInRect(BtnRect, P) then begin
    Message.Result:= HTCAPTION; // HTCLIENT;
  end else
  if PtInRect(TransRect, P) then
    Message.Result:= HTTRANSPARENT
  else
  }
    inherited;
end;

procedure TFloatBar.Paint;
begin
  inherited;

  //Paint Background
  Canvas.Brush.Style:= bsSolid;
  Canvas.Pen.Style:= psClear;
  Canvas.Brush.Color:= Color;
  Canvas.FillRect(Canvas.ClipRect);

  Canvas.Pen.Style:= psSolid;
  Canvas.Pen.Width:= 3;
  Canvas.Brush.Style:= bsClear;
  Canvas.Pen.Color:= clBlue;

  Canvas.MoveTo(0, 0);
  Canvas.LineTo(ClientWidth, 0); //Top
  Canvas.LineTo(ClientWidth, ClientHeight+FBtnHeight); //Right
  Canvas.LineTo(ClientWidth-FBtnWidth, ClientHeight+FBtnHeight); //Bottom of Button
  Canvas.LineTo(ClientWidth-FBtnWidth, ClientHeight); //Left of Button
  Canvas.LineTo(0, ClientHeight); //Bottom
  Canvas.LineTo(0, 0);

end;

procedure TFloatBar.PaintBorder;
begin
  Canvas.Handle:= GetWindowDC(Handle);
  try

    //TODO: Paint "transparent" area by painting parent...


    //Paint NC button background
    Canvas.Brush.Style:= bsSolid;
    Canvas.Pen.Style:= psClear;
    Canvas.Brush.Color:= Color;
    Canvas.Rectangle(ClientWidth-FBtnWidth, ClientHeight, ClientWidth, ClientHeight+FBtnHeight);

    //Paint NC button border
    Canvas.Pen.Style:= psSolid;
    Canvas.Pen.Width:= 3;
    Canvas.Brush.Style:= bsClear;
    Canvas.Pen.Color:= clBlue;
    Canvas.MoveTo(ClientWidth, ClientHeight);
    Canvas.LineTo(ClientWidth, ClientHeight+FBtnHeight);
    Canvas.LineTo(ClientWidth-FBtnWidth, ClientHeight+FBtnHeight);
    Canvas.LineTo(ClientWidth-FBtnWidth, ClientHeight);


    //Paint NC Button Chevron      //TODO: Calculate chevron size/position
    if FCollapsed then begin
      DrawChevron(Canvas, BtnRect, fbudDown, clBlack);
    end else begin
      DrawChevron(Canvas, BtnRect, fbudUp, clBlack);
    end;

  finally
    ReleaseDC(Handle, Canvas.Handle);
  end;
end;

procedure TFloatBar.ParentResized;
var
  L, T: Integer;
begin
  L:= (Parent.ClientWidth div 2) - (Width div 2);
  if FCollapsed then
    T:= -Height + FBtnHeight
  else
    T:= 0;
  if Left <> L then
    Left:= L;
  if Top <> T then
    Top:= T;
end;

end.
