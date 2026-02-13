program HanoiTower;

uses crt;


const
    DelayDuration = 1000;
    PivotSymbol = '#';
    RingSymbol = ' ';
    AmountOfPivots = 3;
    ColorCount = 9;

type
    point = record
        x, y: integer;
    end;
    
    ring = record
        PivotIndex: integer;
        ID: integer;
        Place: integer;
        Width: integer;
        Center: point;
    end;

    nodeOfStackPtr = ^nodeOfStack;
    nodeOfStack = record
        Data: ring;
        Prev, Next: nodeOfStackPtr;
    end;
    
    stackOfRings = record
        PivotIndex: integer;
        Size: integer;
        Head, Tail: nodeOfStackPtr;
    end;

    pivotNum = 1..3;
    pivot = record
        Center: point;
        RingStack: stackOfRings;
    end;
    arrayOfPivots = array [1..AmountOfPivots] of pivot; 

var
    Steps: integer;
    AmountOfRings: integer;
    PivotWidth, PivotHeight: integer;
    AnimationDelay: integer;
    Pivots: arrayOfPivots;    
    StepByStep, FastAnimation: boolean;
    AllColors: array [1..ColorCount] of word =
    (
        Blue, Green, Red, Cyan, Yellow, Magenta,
        LightBlue, LightGreen, LightRed
    );


procedure InitPoint(Point: point; x, y: integer);
begin
    Point.x := x;
    Point.y := y;
end;


procedure SetXY(var Point: point; x, y: integer);
begin
    Point.x := x;
    Point.y := y;
end;


procedure InitRing(var Ring: ring; ID: integer);
begin
    Ring.ID := ID;
    Ring.Width := PivotWidth - ID * 4;
end;


procedure UpdateRing(var Ring: ring);
begin
    Ring.Center.x := Pivots[Ring.PivotIndex].Center.x;
    Ring.Center.y := Pivots[Ring.PivotIndex].Center.y - Ring.Place * 2;
end;


function IsEmpty(var Stack: stackOfRings): boolean;
begin
    IsEmpty := (Stack.Head = nil) and (Stack.Tail = nil);
end;


procedure PushSOR(var Stack: stackOfRings; Ring: ring);
var
    Node: nodeOfStackPtr;
begin
    new(Node);
    Node^.Data := Ring;
    if IsEmpty(Stack) then begin
        Node^.Data.Place := 1;
        Node^.Prev := nil;
        Node^.Next := nil;
        Stack.Head := Node;
        Stack.Tail := Node;
    end else begin
        Node^.Data.Place := Stack.Size + 1;
        Node^.Prev := nil;
        Stack.Head^.Prev := Node;
        Node^.Next := Stack.Head;
        Stack.Head := Node; 
    end;

    Stack.Head^.Data.PivotIndex := Stack.PivotIndex;
    UpdateRing(Stack.Head^.Data);
    inc(Stack.Size);
end;


function PopSOR(var Stack: stackOfRings): ring;
var
    TempNode: nodeOfStackPtr;
    TempRing: ring;
begin
    TempRing := Stack.Head^.Data;
    TempNode := Stack.Head^.Next;
    dispose(Stack.Head);

    Stack.Head := TempNode;
    if Stack.Size = 1 then
        Stack.Tail := nil
    else
        TempNode^.Prev := nil;
    dec(Stack.Size);
    PopSOR := TempRing;
end;


procedure FreeSOR(var Stack: stackOfRings);
begin
    while not IsEmpty(Stack) do
        PopSOR(Stack);
end;


procedure FreeAllSOR();
var
    i: integer;
begin
    for i := 1 to AmountOfPivots do 
        FreeSOR(Pivots[i].RingStack)
end;


procedure InitSOR(var Stack: stackOfRings; PivotIndex: integer);
begin
    Stack.Size := 0;
    Stack.Head := nil;
    Stack.Tail := nil;
    Stack.PivotIndex := PivotIndex;
end;


procedure InitFirstSOR(var Stack: stackOfRings);
var
    i: integer;
    TempRing: ring;
begin
    for i := 1 to AmountOfRings do begin
        InitRing(TempRing, i);
        PushSOR(Stack, TempRing);
    end;
end;


procedure InitAOP();
var
    i: integer;
begin
    PivotWidth := ScreenWidth div 5;
    PivotHeight := ScreenHeight div 2;

    for i := 1 to AmountOfPivots do begin
        Pivots[i].Center.x := ScreenWidth - (4 - i) * ScreenWidth div 3 + 
                              ScreenWidth div 20 + PivotWidth div 2;
        Pivots[i].Center.y := ScreenHeight - ScreenHeight div 10;
        InitSOR(Pivots[i].RingStack, i);
    end;
    
    InitFirstSOR(Pivots[1].RingStack);
end;


procedure InitLocales();
begin
    Steps := 0;
    Val(ParamStr(1), AmountOfRings);
    StepByStep := not ((ParamStr(2) = '') or (ParamStr(2) = '0'));
    FastAnimation := not ((ParamStr(3) = '') or (ParamStr(3) = '0'));
    Val(ParamStr(4), AnimationDelay);
    if AnimationDelay = 0 then
        AnimationDelay := 25; 
    if AmountOfRings = 0 then begin
        write('Input amount of rings to solve: ');
        readln(AmountOfRings)
    end;
    if (AmountOfRings <= 0) or (AmountOfRings > 9) then begin
        writeln('Amount Of Rings must be at least 1 and not exceed 9');
        halt(1);
    end;
    InitAOP();
end;


procedure DrawRing(Ring: ring);
var
    i, x, y: integer;
begin
    x := Ring.Center.x - Ring.Width div 2;
    y := Ring.Center.y;
    TextBackground(AllColors[Ring.ID]);
    TextColor(Black);
    for i := 0 to Ring.Width do begin
        GotoXY(x + i, y);
        if (i = Ring.Width div 2) then
            write(Ring.ID)
        else
            write(RingSymbol)
    end;
    TextColor(White);
    TextBackGround(Black);
end;


procedure DrawSOR(var Stack: stackOfRings);
var
    TempNode: nodeOfStackPtr;
begin
    TempNode := Stack.Head;
    while TempNode <> nil do begin
        DrawRing(TempNode^.Data);
        TempNode := TempNode^.Next;
    end
end;


procedure DrawPivot(index: integer);
var
    x, y, i, j: integer;
begin
    x := Pivots[index].Center.x - PivotWidth div 2;
    y := Pivots[index].Center.y;

    TextColor(Black);
    TextBackground(White);
    for i := 0 to PivotWidth do begin
        for j := 0 to 1 do begin
            GotoXY(x + i, y + j);
            write(PivotSymbol)
        end
    end;
    for i := 0 to PivotHeight do begin
        GotoXY(x + PivotWidth div 2 - 1, y - i);
        write(PivotSymbol, PivotSymbol, PivotSymbol)
    end;
    TextColor(White);
    TextBackground(Black);

    DrawSOR(Pivots[index].RingStack);
    GotoXY(1, 1);
end;


procedure ReloadScreen();
var
    i: integer;
begin
    clrscr;
    for i := 1 to 3 do
        DrawPivot(i);
end;


procedure HandleKeys();
var
    key: char;
begin
    if KeyPressed then begin
        key := ReadKey;
        GotoXY(1, 1);
        if key = 'q' then begin
            FreeAllSOR();
            clrscr;
            halt(0)
        end;
        if key = 's' then begin
            StepByStep := not StepByStep;
            if StepByStep then
                write('Step by Step mode activated')
            else
                write('Step by Step mode deactivated');
        end;
        if key = 'p' then begin
            write('Paused... Press Any key to continue...');
            ReadKey
        end
    end
end;


procedure DoAnimation(Ring: ring; PivotIndex: integer);
var
	dx, dy, sx, sy, err: integer; 
	e2, x1, x2, y1, y2: integer;
    NewPlace: integer;
begin
    NewPlace := Pivots[PivotIndex].RingStack.Size + 1;
    x1 := round(Ring.Center.x);
	y1 := round(Ring.Center.y);
	x2 := round(Pivots[PivotIndex].Center.x);
	y2 := round(Pivots[PivotIndex].Center.y - NewPlace * 2);
	dx := abs(x2 - x1);
	dy := abs(y2 - y1);
	if x1 < x2 then
		sx := 1
	else
		sx := -1;
	if y1 < y2 then
		sy := 1
	else
		sy := -1;
	err := dx - dy;
	while (x1 <> x2) or (y1 <> y2) do begin
        HandleKeys();
        SetXY(Ring.Center, x1, y1);
		ReloadScreen();
        DrawRing(Ring);
        delay(AnimationDelay);
		e2 := 2 * err;
		if e2 > -dy then begin
			err := err - dy;
			x1 := x1 + sx
		end;
		if e2 < dx then begin
			err := err + dx;
			y1 := y1 + sy
		end
	end;
    SetXY(Ring.Center, x1, y1);
	PushSOR(Pivots[PivotIndex].RingStack, Ring);
    ReloadScreen();
end;


procedure SolveHanoiTower(PivotBeg, PivotEnd: pivotNum; n: integer);
var
    PivotMid: pivotNum;
begin
    HandleKeys();
    if n = 1 then begin
        if StepByStep then
            ReadKey;
        DoAnimation(PopSOR(Pivots[PivotBeg].RingStack), PivotEnd);
        inc(Steps)
    end else begin
        PivotMid := 6 - PivotBeg - PivotEnd;
        SolveHanoiTower(PivotBeg, PivotMid, n - 1);
        if StepByStep then
            ReadKey;
        DoAnimation(PopSOR(Pivots[PivotBeg].RingStack), PivotEnd);
        inc(Steps);
        SolveHanoiTower(PivotMid, PivotEnd, n - 1);
    end
end;


begin
    InitLocales();
    ReloadScreen();
    writeln('Press Any key to start application...');
    ReadKey;

    if FastAnimation then
        AnimationDelay := 1;
    SolveHanoiTower(1, 3, AmountOfRings);

    writeln('Solved with ', Steps, ' Steps.');
    delay(DelayDuration);
    writeln('Press Any key to close application...');
    ReadKey;
    clrscr;
end.

