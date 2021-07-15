program APuzzleADay;

uses
  System.StartUpCopy,
  FMX.Forms,
  APuzzleADay.MainForm in 'APuzzleADay.MainForm.pas' {MainForm},
  APuzzleADay.Solver in 'APuzzleADay.Solver.pas',
  APuzzleADay.Piece in 'APuzzleADay.Piece.pas',
  APuzzleADay.Board in 'APuzzleADay.Board.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
