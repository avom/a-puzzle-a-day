unit APuzzleADay.MainForm;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  FMX.Controls,
  FMX.Controls.Presentation,
  FMX.Dialogs,
  FMX.Edit,
  FMX.EditBox,
  FMX.Forms,
  FMX.Graphics,
  FMX.ListBox,
  FMX.NumberBox,
  FMX.Objects,
  FMX.StdCtrls,
  FMX.Types,
  APuzzleADay.Board;

type
  TMainForm = class(TForm)
    MonthComboBox: TComboBox;
    MonthLabel: TLabel;
    DayLabel: TLabel;
    DayNumberBox: TNumberBox;
    PaintBox: TPaintBox;
    SolveButton: TButton;
    SolutionsFoundEdit: TEdit;
    TimeSpentLabel: TLabel;
    SolutionsFoundLabel: TLabel;
    TimeSpentEdit: TEdit;
    SolutionNumLabel: TLabel;
    PreviousButton: TButton;
    NextButton: TButton;
    procedure FormCreate(Sender: TObject);
    procedure SolveButtonClick(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
    procedure PreviousButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
  private
    FBoard: TBoard;
    FSolutions: TObjectList<TBoard>;
    FActiveSolution: Integer;
    procedure ShowSolution(Idx: Integer);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.DateUtils,
  System.Math,
  APuzzleADay.Solver;

{$R *.fmx}

constructor TMainForm.Create(AOwner: TComponent);
begin
  inherited;
  BuildPieces;
  FBoard := TBoard.Create;
  FSolutions := TObjectList<TBoard>.Create;
end;

destructor TMainForm.Destroy;
begin
  FBoard.Free;
  FSolutions.Free;
  inherited;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  var Date := Now;
  DayNumberBox.Value := DayOfTheMonth(Date);
  MonthComboBox.ItemIndex := MonthOfTheYear(Date) - 1;
end;

procedure TMainForm.NextButtonClick(Sender: TObject);
begin
  ShowSolution((FActiveSolution + 1) mod FSolutions.Count);
end;

procedure TMainForm.PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
begin
  Canvas.BeginScene;
  try
    if FActiveSolution < FSolutions.Count then
      FSolutions[FActiveSolution].Draw(Canvas)
  finally
    Canvas.EndScene;
  end;
end;

procedure TMainForm.PreviousButtonClick(Sender: TObject);
begin
  ShowSolution((FActiveSolution - 1) mod FSolutions.Count);
end;

procedure TMainForm.ShowSolution(Idx: Integer);
begin
  FActiveSolution := Idx;
  if FActiveSolution < FSolutions.Count then
    SolutionNumLabel.Text := 'Solution ' + IntToStr(Idx + 1)
  else
    SolutionNumLabel.Text := '';
  Invalidate;
end;

procedure TMainForm.SolveButtonClick(Sender: TObject);
begin
  var Duration: TDateTime;
  FBoard.Init(MonthComboBox.ItemIndex, Round(DayNumberBox.Value));
  FSolutions.Clear;
  var Solver := TSolver.Create;
  try
    var StartTick := Now;
    Solver.Solve(FBoard, FSolutions);
    Duration := Now - StartTick;
  finally
    Solver.Free;
  end;

  SolutionsFoundEdit.Text := IntToStr(FSolutions.Count);
  TimeSpentEdit.Text := Format('%.3f s', [Duration * 86400]);
  ShowSolution(0);
end;

end.
