unit APuzzleADay.Piece;

interface

type
  TPiece = record
  private
    FMask: UInt64;
    FShiftedMask: UInt64;
  public
    constructor Create(Mask: UInt64);

    function Rotate: TPiece;
    function Mirror: TPiece;

    property Mask: UInt64 read FMask;
    property ShiftedMask: UInt64 read FShiftedMask;
  end;

implementation

{ TPiece }

constructor TPiece.Create(Mask: UInt64);
begin
  FMask := Mask;
  FShiftedMask := FMask;
  while FShiftedMask and 1 = 0 do
    FShiftedMask := FShiftedMask shr 1;
end;

function TPiece.Mirror: TPiece;

  function ReverseHalfByte(X: UInt64): UInt64;
  begin
    Result := (X and $1 shl 3) + (X and $2 shl 1) + (X and $4 shr 1) + (X and $8 shr 3);
  end;

begin
  var R0 := ReverseHalfByte(FMask and $F);
  var R1 := ReverseHalfByte((FMask shr 8) and $F);
  var R2 := ReverseHalfByte((FMask shr 16) and $F);
  var R3 := ReverseHalfByte((FMask shr 24) and $F);

  var Mask := R0 + (R1 shl 8) + (R2 shl 16) + (R3 shl 24);
  while Mask and $01010101 = 0 do
    Mask := Mask shr 1;

  Result := TPiece.Create(Mask);
end;

function TPiece.Rotate: TPiece;
begin
  var Mask: UInt64 := 0;
  var Bit: UInt64 := 1;
  var Row := 0;
  while True do
  begin
    var RowMask := (FMask shr (Row * 8)) and $FF;
    if RowMask = 0 then
      Break;
    for var Col := 0 to 3 do
    begin
      Mask := Mask or (((FMask and Bit) shl 4 shr (Row * 8) shl (Col * 8) shr Col shr Row));
      Bit := Bit shl 1;
    end;
    Bit := Bit shl 4;
    Inc(Row);
  end;
  while Mask and $1010101 = 0 do
    Mask := Mask shr 1;
  Result := TPiece.Create(Mask);
end;

end.
