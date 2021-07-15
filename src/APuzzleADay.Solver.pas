unit APuzzleADay.Solver;

interface

uses
  System.Generics.Collections,
  System.Types,
  FMX.Graphics,
  APuzzleADay.Board,
  APuzzleADay.Piece;

type
  TSolver = class
  private
    FBoard: TBoard;
    FSolutions: TObjectList<TBoard>;
    procedure Backtracking(PieceIndex: Integer);
  public
    procedure Solve(Board: TBoard; Solutions: TObjectList<TBoard>);
  end;

procedure BuildPieces;

var
  PieceCounts: array [0..7] of Integer;
  Pieces: array [0..7, 0..7] of TPiece;

implementation

uses
  System.Math,
  System.UITypes;

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

  for var i := 0 to 7 do
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

{ TSolver }

procedure TSolver.Backtracking(PieceIndex: Integer);
begin
  if PieceIndex < 0 then
  begin
    var Solution := TBoard.Create;
    FSolutions.Add(Solution);
    Solution.Assign(FBoard);
    Exit;
  end;

  var Current: UInt64 := 1;
  for var i := 0 to 6 * 8 + 3 - 1 do
  begin
    if FBoard.Mask and Current = 0 then
    begin
      for var j := PieceCounts[PieceIndex] - 1 downto 0 do
      begin
        var Piece := Pieces[PieceIndex, j].ShiftedMask shl i;
        if Piece and FBoard.Mask <> 0 then
          Continue;

        FBoard.PushPiece(Piece);
        Backtracking(PieceIndex - 1);
        FBoard.PopPiece;
      end;
    end;
    Current := Current shl 1;
  end;
end;

procedure TSolver.Solve(Board: TBoard; Solutions: TObjectList<TBoard>);
begin
  FBoard := Board;
  FSolutions := Solutions;
  Backtracking(7);
end;

end.
