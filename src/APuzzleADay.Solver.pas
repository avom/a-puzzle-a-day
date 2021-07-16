unit APuzzleADay.Solver;

interface

uses
  System.Generics.Collections,
  System.Types,
  FMX.Graphics,
  APuzzleADay.Board,
  APuzzleADay.Piece;

procedure Solve(Board: TBoard; Solutions: TObjectList<TBoard>);

implementation

uses
  System.Math,
  System.UITypes;

const
  PieceCount = 8;

var
  PieceCounts: array [0..PieceCount - 1] of Integer;
  Pieces: array [0..PieceCount - 1, 0..7] of TPiece;
  Board: TBoard;
  Solutions: TObjectList<TBoard>;
  IsPieceUsed: array [0..PieceCount - 1] of Boolean;

function Contains(PieceIdx: Integer; const Piece: TPiece): Boolean;
begin
  for var i := 0 to PieceCounts[PieceIdx] - 1 do
  begin
    if Piece.Mask = Pieces[PieceIdx, i].Mask then
    Exit(True);
  end;
  Exit(False);
end;

procedure BuildPieces;
begin
  Pieces[0, 0] := TPiece.Create($000F + $0800);
  Pieces[1, 0] := TPiece.Create($000F + $0400);
  Pieces[2, 0] := TPiece.Create($0003 + $0E00);
  Pieces[3, 0] := TPiece.Create($0007 + $0700);
  Pieces[4, 0] := TPiece.Create($0007 + $0300);
  Pieces[5, 0] := TPiece.Create($0007 + $0500);
  Pieces[6, 0] := TPiece.Create($000007 + $000100 + $010000);
  Pieces[7, 0] := TPiece.Create($000003 + $000200 + $060000);

  for var i := 0 to PieceCount - 1 do
  begin
    PieceCounts[i] := 1;
    var Piece := Pieces[i, 0].Mirror;
    if not Contains(i, Piece) then
    begin
      Pieces[i, PieceCounts[i]] := Piece;
      Inc(PieceCounts[i]);
    end;
    var j := 0;
    while PieceCounts[i] > j do
    begin
      Piece := Pieces[i, j].Rotate;
      if not Contains(i, Piece) then
      begin
        Pieces[i, PieceCounts[i]] := Piece;
        Inc(PieceCounts[i]);
      end;
      Inc(j);
    end;
  end;
end;

procedure Backtracking(Depth: Integer = 1; StartIdx: Integer = 0; UsedPieces: Byte = 0);
begin
  if Depth > PieceCount then
  begin
    var Solution := TBoard.Create;
    Solutions.Add(Solution);
    Solution.Assign(Board);
    Exit;
  end;

  var Idx := StartIdx;
  var Current := UInt64(1) shl StartIdx;
  while Board.Mask and Current <> 0 do
  begin
    Inc(Idx);
    Current := Current shl 1;
  end;

  for var i := 0 to PieceCount - 1 do
  begin
    if UsedPieces and (1 shl i) <> 0 then
      Continue;

    for var j := PieceCounts[i] - 1 downto 0 do
    begin
      var Piece := Pieces[i, j].ShiftedMask shl Idx;
      if Piece and Board.Mask <> 0 then
        Continue;

      Board.PushPiece(Piece);
      Backtracking(Depth + 1, Idx + 1, UsedPieces or (1 shl i));
      Board.PopPiece;
    end;
  end;
end;

procedure Solve(Board: TBoard; Solutions: TObjectList<TBoard>);
begin
  APuzzleADay.Solver.Board := Board;
  APuzzleADay.Solver.Solutions := Solutions;
  Backtracking;
end;

initialization

  BuildPieces;

end.
