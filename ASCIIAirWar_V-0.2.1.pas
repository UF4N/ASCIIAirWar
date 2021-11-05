program ASCII_AirWar;
uses crt;

const
	{Constants of characters	for terminals, using UTF-8}
	Grass = #95; 
	Ground = #130;
	Space = ' ';	

	{Constants of numerical values}	
	Speed = 50; 

	{Constants of game objects}
	Jet: array[1..7] of String = (
		'          ',
    '  ___   __  ',
    '  \☭:\_|:@\    ',
    ' ##>|_///__|>-- ',
    '      //       ',
		'      ̅ ̅      ',
		'             ');

	Explosion: array[1..7] of String = (
		'      *       ',
    '  *       *   ',
    '    *   *     ',
    '*     *     * ',
    '    *   *     ',
		'  *       *   ',
		'      *       ' );

	{Identifiers of processed keys}
	ExitToTerminal = 'x';
	JetMovingUp = 'w';
	JetMovingDown = 's';
	JetMovingLeft = 'a';
	JetMovingRight = 'd';
	JetShot = '/';
	
type 
	ColumnArray = array[1..300] of Byte; // Количество элементов массива зависит от длины строко в терминале. В данном исходнике оно взято с запасом.

function StartRandomPointInColumn: Byte;
	begin
		StartRandomPointInColumn := random(ScreenHeight);
		while StartRandomPointInColumn < trunc(ScreenHeight / 100 * 80) do
			StartRandomPointInColumn := StartRandomPointInColumn + 1;
		while StartRandomPointInColumn > trunc(ScreenHeight / 100 * 90) do
					StartRandomPointInColumn := StartRandomPointInColumn - 1;		
	end;

function RandomPointInColumn(var PredZnac: Byte): Byte;
	begin
		case random(4) of
			0: RandomPointInColumn := PredZnac + 1;
			1: RandomPointInColumn := PredZnac - 1;
			2: RandomPointInColumn := PredZnac + 0;
			3: RandomPointInColumn := PredZnac + 0
			
		end;

		if RandomPointInColumn < trunc(ScreenHeight / 100 * 80) then
			RandomPointInColumn := RandomPointInColumn + 1
		else if RandomPointInColumn > trunc(ScreenHeight / 100 * 90) then
			RandomPointInColumn := RandomPointInColumn - 1
	end;

function HowKeyPressed: Char;
	begin
		if KeyPressed then
			HowKeyPressed := ReadKey
	end;

function Collision(CoordinateX, CoordinateY, tek, columns_from_tek: Byte): Boolean; // Функция, говорящая есть столкновение или нет. Нужна для процедуры "обработчик столкновений".
	begin
		if (tek = CoordinateX + 7) and (columns_from_tek = CoordinateY + 5) or // Нижняя точка столкновени самолёта
			 (tek = CoordinateX + 15) and (columns_from_tek = CoordinateY + 3) or // Передняя точка столкновени самолёта
			 (tek = CoordinateX) and (columns_from_tek = CoordinateY + 3) or // Задняя точка столкновени самолёта
			 (tek = CoordinateX + 9) and (columns_from_tek = CoordinateY + 4) then // Точка столкновения самолёта на "фюзеляже"
			Collision := True
		else 
			Collision := False
	end;

procedure InitializingArrayOfColumns(var columns: ColumnArray); // Инициализация массива, чтобы избежать неопределённых значений его элементов
	var
		i: Integer;
		
	begin
		for i := 1 to 200 do
			columns[i] := 38
	end;

procedure CollisionHandler(CoordinateX, CoordinateY, tek, columns: Byte); // Обработчик столкновений самолёта с землёй или снарядами
	var
		i: Byte;
	begin
		if Collision(CoordinateX, CoordinateY, tek, columns) then
			begin
				TextColor(Red);
				for i := 1 to 7 do
					begin
						GotoXY(CoordinateX + 1, CoordinateY);
						write(Explosion[i]);
						CoordinateY := CoordinateY + 1
					end;
				Delay(3000);
				ClrScr;
				Halt
			end
	end;

procedure InputScreen(var columns: ColumnArray; CoordinateX, CoordinateY: Byte); // Вывод земли
	var
		tek: Byte;
	begin
		for tek := 1 to ScreenWidth do
			begin
				if columns[tek + 1] - columns[tek] = 0 then
						continue
					else if columns[tek + 1] - columns[tek] > 0 then //Если предыдущий столбец выше следующего
						begin // От 'высоты' верхушки предыдущего столбца напечатать пробел до высоты следующего
							GotoXY(tek, columns[tek]);
							write(Space);
							GotoXY(tek, columns[tek] + 1);
							TextColor(Green);
							write(Grass)
						end
					else if columns[tek + 1] - columns[tek] < 0 then //Если предыдущий столбец ниже следующего
						begin // От 'высоты' верхушки предыдущего столбца напечатать 'землю' до высоты следующего
							GotoXY(tek, columns[tek]);
							TextColor(Brown);
							write(Ground);
							GotoXY(tek, columns[tek] - 1);
							TextColor(Green);
							write(Grass)
						end;
						
				// Обработчик столкновений самолёта с землёй или снарядами
				CollisionHandler(CoordinateX, CoordinateY, tek, columns[tek])
			end;
	end;

procedure MovePointsInArray(var columns: ColumnArray);
	var
		tek: Byte;
	begin
		for tek := 1 to ScreenWidth do // Переприсваивание значений высот предыдущим столбцам из следующих
			columns[tek] := columns[tek + 1];
	end;

procedure PrintJet(CoordinateX, CoordinateY: Byte); // Вывод самолёта на экран
	var
		MoveBy_Y, i: Byte;
	begin
		TextColor(Yellow); //5
		MoveBy_Y := CoordinateY;
		for i := 1 to 7 do
			begin
				GotoXY(CoordinateX, MoveBy_Y);
				write(Jet[i]);
				MoveBy_Y := MoveBy_Y + 1
			end
	end;

procedure ProcessingOfPressingKeys(var CoordinateX, CoordinateY: Byte); //Обработка нажатия клавиш
	begin
		case HowKeyPressed of
			JetMovingUp:
				begin
					if CoordinateY > 1 then
						CoordinateY := CoordinateY - 1;
					PrintJet(CoordinateX, CoordinateY)
				end;
				
			JetMovingDown:
				begin
					CoordinateY := CoordinateY + 1;
					PrintJet(CoordinateX, CoordinateY)
				end;
				
			JetMovingLeft:
				begin
					if CoordinateX > 1 then
						CoordinateX := CoordinateX - 1;
					PrintJet(CoordinateX, CoordinateY)
				end;

			JetMovingRight:
				begin
					if CoordinateX < ScreenWidth - 17 then
						CoordinateX := CoordinateX + 1;
					PrintJet(CoordinateX, CoordinateY)
				end;

			{JetShot:
				begin
				
				end;}

			ExitToTerminal:
				begin
					ClrScr;
					halt
				end
		end
	end;

procedure PrintBottomGroundAndJet(CoordinateX, CoordinateY: Byte); // Вывод "нижней части земли". Она выводится только 1 раз. 
	var
		i, j: Integer;
	begin
		PrintJet(CoordinateX, CoordinateY + 1);
		TextColor(Brown);
		for i := 1 to ScreenWidth do
			for j := trunc(ScreenHeight / 100 * 80) + 2 to ScreenHeight do
				begin
					GotoXY(i, j);
					write(Ground)
				end;
	end;

procedure Initializing_CoordinateX_CoordinateY(var CoordinateX, CoordinateY: Byte); // Инициализация начального положения самолёта на экране
	begin
		CoordinateX := trunc(ScreenWidth / 100 * 10);
		CoordinateY := trunc(ScreenHeight / 100 * 10) // Заменить trunc(ScreenHeight / 100 * 10) на константное значение 
	end;

var
	columns: ColumnArray;
	CoordinateX, CoordinateY: Byte;
	
begin
	Randomize;
	ClrScr;
	columns[ScreenWidth] := StartRandomPointInColumn; // Присваивание начального рандомного значения высоты в первый столбик
	InitializingArrayOfColumns(columns);  // Инициализация массива, чтобы избежать неопределённых значений его элементов 
	Initializing_CoordinateX_CoordinateY(CoordinateX, CoordinateY); // Инициализация начального положения самолёта на экране
	PrintBottomGroundAndJet(CoordinateX, CoordinateY); // Вывод "нижней части земли" и самолёта

	while True do // Основной цикл работы программы
		begin

			// Переприсваивание значений высот предыдущим столбцам из следующих
			MovePointsInArray(columns); 
	
			// Вывод на экран объектов игры (земля, самолёт, взрывы)
			InputScreen(columns, CoordinateX, CoordinateY);

			// Обработка нажатия клавиш
			ProcessingOfPressingKeys(CoordinateX, CoordinateY);
		
			// Присваивание нового значения высоты первому столбцу
			columns[ScreenWidth] := RandomPointInColumn(columns[ScreenWidth - 1]);

			// Задержка вывода "картинки" в терминал
			Delay(Speed);
			
  	end
  	
end.
