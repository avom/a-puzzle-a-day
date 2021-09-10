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
    DaysComboBox: TComboBox;
    DayLabel: TLabel;
    PaintBox: TPaintBox;
    SolutionsFoundEdit: TEdit;
    TimeSpentLabel: TLabel;
    SolutionsFoundLabel: TLabel;
    TimeSpentEdit: TEdit;
    PreviousButton: TButton;
    NextButton: TButton;
    SolutionNumLabel: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
    procedure PreviousButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure DaysComboBoxChange(Sender: TObject);
  private
    FSolutionsPerDays: array [0..365] of TObjectList<TBoard>;
    FActiveDay: Integer;
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
  
  var i: Integer;
  for i := Low(FSolutionsPerDays) to High(FSolutionsPerDays) do
    FSolutionsPerDays[i] := TObjectList<TBoard>.Create;
end;

procedure TMainForm.DaysComboBoxChange(Sender: TObject);
begin
  FActiveDay := DaysComboBox.ItemIndex;
  ShowSolution(0);
end;

destructor TMainForm.Destroy;
begin
  var i: Integer;
  for i := Low(FSolutionsPerDays) to High(FSolutionsPerDays) do
    FSolutionsPerDays[i].Free;
  inherited;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  var Date := Now;
  var CurrentDayOfMonth := DayOfTheMonth(Date);
  var CurrentMonth := MonthOfTheYear(Date);

  var ActiveDay := Low(FSolutionsPerDays);
  var TotalSolutions := 0;
  var StartTick := Now;
  var Duration: TDateTime;
  var Month, DayOfMonth: Integer;
  for Month := Low(MonthDays[True]) to High(MonthDays[True]) do
    for DayOfMonth := 1 to MonthDays[True][Month] do
    begin
      var Board := TBoard.Create;
      try
        Board.Init(Month, DayOfMonth);
        FSolutionsPerDays[ActiveDay].Clear;

        Solve(Board, FSolutionsPerDays[ActiveDay]);
      finally
        Board.Free;
      end;

      if (CurrentDayOfMonth = DayOfMonth) and (CurrentMonth = Month) then
        FActiveDay := DaysComboBox.Items.Count;

      var DayLabel := Format('%s %d    has %d solutions', [FormatSettings.ShortMonthNames[Month], DayOfMonth, FSolutionsPerDays[ActiveDay].Count]);
      DaysComboBox.Items.Add(DayLabel);
      
      Inc(TotalSolutions, FSolutionsPerDays[ActiveDay].Count);
      Inc(ActiveDay);
    end;

  Duration := Now - StartTick;
  SolutionsFoundEdit.Text := IntToStr(TotalSolutions);
  TimeSpentEdit.Text := Format('%.3f s', [Duration * 86400]);

  DaysComboBox.ItemIndex := FActiveDay;
end;

procedure TMainForm.NextButtonClick(Sender: TObject);
begin
  ShowSolution((FActiveSolution + 1) mod FSolutionsPerDays[FActiveDay].Count);
end;

procedure TMainForm.PaintBoxPaint(Sender: TObject; Canvas: TCanvas);
begin
  Canvas.BeginScene;
  try
    if FActiveSolution < FSolutionsPerDays[FActiveDay].Count then
      FSolutionsPerDays[FActiveDay][FActiveSolution].Draw(Canvas)
  finally
    Canvas.EndScene;
  end;
end;

procedure TMainForm.PreviousButtonClick(Sender: TObject);
begin
  ShowSolution((FActiveSolution - 1 + FSolutionsPerDays[FActiveDay].Count) mod FSolutionsPerDays[FActiveDay].Count);
end;

procedure TMainForm.ShowSolution(Idx: Integer);
begin
  FActiveSolution := Idx;
  if FActiveSolution < FSolutionsPerDays[FActiveDay].Count then
    SolutionNumLabel.Text := 'Solution ' + IntToStr(Idx + 1)
  else
    SolutionNumLabel.Text := '';
  Invalidate;
end;

end.
