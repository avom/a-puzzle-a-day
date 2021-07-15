unit APuzzleADay.Board;

interface

uses
  System.Generics.Collections,
  FMX.Graphics;

type
  TBoard = class
  private
    FPieces: TList<UInt64>;
    FMask: UInt64;
    FInitMask: UInt64;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Init(Month, Day: Integer);

    procedure Assign(Board: TBoard);
    procedure Draw(Canvas: TCanvas);

    procedure PushPiece(Mask: UInt64);
    procedure PopPiece;

    property Mask: UInt64 read FMask;
  end;

implementation

uses
  System.Math,
  System.Types,
  System.UITypes;

{ TBoard }

procedure TBoard.Assign(Board: TBoard);
begin
  FPieces.Clear;
  FPieces.AddRange(Board.FPieces);
  FMask := Board.Mask;
  FInitMask := Board.FInitMask;
end;

constructor TBoard.Create;
begin
  FPieces := TList<UInt64>.Create;
  FMask := $FFF880808080C0C0;
end;

destructor TBoard.Destroy;
begin
  FPieces.Free;
  inherited;
end;

procedure TBoard.Draw(Canvas: TCanvas);

  procedure DrawMask(Mask: UInt64; Color: TAlphaColor);
  begin
    var Side := Min(Canvas.Width, Canvas.Height) / 7;
    var Bit: UInt64 := 1;
    Canvas.Fill.Color := Color;
    for var Row := 0 to 6 do
    begin
      for var Col := 0 to 6 do
      begin
        if Bit and Mask > 0 then
        begin
          var Left := Col * Side;
          var Top := Row * Side;
          Canvas.FillRect(RectF(Left, Top, Left + Side, Top + Side), 0, 0, [], 1);
        end;
        Bit := Bit shl 1;
      end;
      Bit := Bit shl 1;
    end;
  end;

const
  Colors: array [0..7] of TAlphaColor = (
    TAlphaColorRec.Red,
    TAlphaColorRec.Orange,
    TAlphaColorRec.Green,
    TAlphaColorRec.Blue,
    TAlphaColorRec.Darkgrey,
    TAlphaColorRec.Cyan,
    TAlphaColorRec.Brown,
    TAlphaCOlorRec.Magenta);
begin
  DrawMask(FInitMask, TAlphaColorRec.White);
  for var i := 0 to FPieces.Count - 1 do
    DrawMask(FPieces[i], Colors[i]);
end;

procedure TBoard.Init(Month, Day: Integer);
begin
  var One := UInt64(1);
  if Month < 6 then
    FMask := FMask or (One shl Month)
  else
    FMask := FMask or (One shl (8 + Month - 6));

  var DayRow := 2 + (Day - 1) div 7;
  var DayCol := (Day - 1) mod 7;
  FMask := FMask or (One shl (DayRow * 8 + DayCol));
  FInitMask := FMask;
end;

procedure TBoard.PopPiece;
begin
  if FPieces.Count > 0 then
  begin
    FMask := FMask xor FPieces.Last;
    FPieces.Delete(FPieces.Count - 1);
  end;
end;

procedure TBoard.PushPiece(Mask: UInt64);
begin
  FPieces.Add(Mask);
  FMask := FMask or Mask;
end;

end.
