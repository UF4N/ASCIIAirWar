program ASCII_AirWar;
uses crt;

const
   {Constants of characters	for terminals, using UTF-8}
   Grass = #95; 
   Ground = #130;
   Space = ' ';	

   {Constants of numerical values}	
   Speed = 1; 
   
   {Constants of game objects}
   Jet: array[1..7] of String = (
       '          ',
       '  ___   __  ',
       '  \☭:\_|:@\    ',
       ' ##>|_///__|>-- ',
       '      //       ',
       '      ̅ ̅   ',
       '             ');

	FascistJet: array[1..65] of Char = (
	    ' ',' ',' ',' ',' ',' ',' ',' ',' ','_','_',' ',' ',
   	 ' ',' ',' ',' ','_','_','_','_','/','$','/',' ',' ',
   	 ' ',' ','_','/','@',':',' ',' ','_','|',' ',' ',' ',
   	 '<','|','_','_','_','\','\','|','<','#',' ',' ',' ',
   	 ' ',' ',' ',' ',' ','\','\',' ',' ',' ',' ',' ',' ');

   Explosion: array[1..7] of String = (
      '      *       ',
      '  *       *   ',
      '    *   *     ',
      '*     *     * ',
      '    *   *     ',
      '  *       *   ',
      '      *       ' );

	Rocket = '#]==>';

   {Identifiers of processed keys}
   ExitToTerminal = 'x';
   JetMovingUp = 'w';
   JetMovingDown = 's';
   JetMovingLeft = 'a';
   JetMovingRight = 'd';
   JetShot = '/';
	
type 
	ColumnArray = array[1..300] of Byte; // Количество элементов массива зависит от длины строко в терминале. В данном исходнике оно взято с запасом.
	
	enemy = record
		CoordinateX: Word;
		CoordinateY: Word;
	end;

	ArrOfEnemys = array[1..300] of enemy;

function StartHeightOfPointInColumn: Byte; // Функция вычисляет самое большое значение высоты столбика и присваивает его самом первому "столбику земли".
   begin
      StartHeightOfPointInColumn := trunc(ScreenHeight / 100 * 80) + 1
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
      else 
      	if RandomPointInColumn > trunc(ScreenHeight / 100 * 90) then
	      	RandomPointInColumn := RandomPointInColumn - 1

   end;

function HowKeyPressed: Char;
   begin
      if KeyPressed then
	 HowKeyPressed := ReadKey
   end;

function Collision(CoordinateX, CoordinateY, tek, columns_from_tek: Byte; var Enemys: ArrOfEnemys): Boolean; // Функция, говорящая есть столкновение или нет. Нужна для процедуры "обработчик столкновений".
   begin

      if (tek = CoordinateX + 7) and (columns_from_tek = CoordinateY + 5) or // Нижняя точка столкновени самолёта
	 		(tek = CoordinateX + 15) and (columns_from_tek = CoordinateY + 3) or // Передняя точка столкновени самолёта
	 		(tek = CoordinateX) and (columns_from_tek = CoordinateY + 3) or // Задняя точка столкновени самолёта
	 		(tek = CoordinateX + 9) and (columns_from_tek = CoordinateY + 4) or // Точка столкновения самолёта на "фюзеляже"
	 		(CoordinateX >= Enemys[tek].coordinateX) and (CoordinateX <= Enemys[tek].coordinateX + 12) and (CoordinateY + 3 >= Enemys[tek].coordinateY) and (CoordinateY <= Enemys[tek].coordinateY + 4) then 
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

procedure CollisionHandler(CoordinateX, CoordinateY, tek, columns: Word; var Enemys: ArrOfEnemys); // Обработчик столкновений самолёта с землёй или снарядами
   var
      i: Byte;
   begin
      if Collision(CoordinateX, CoordinateY, tek, columns, Enemys) then
			begin

			   TextColor(Red);
			   for i := 1 to 7 do
			      begin
					  GotoXY(CoordinateX + 1, CoordinateY);
					  TextColor(124);
					  Write(Explosion[i]);
					  CoordinateY := CoordinateY + 1
					end;
					
			   TextColor(0);
			   Delay(3000);
			   ClrScr;
			   Halt
			end
   end;

procedure MovePointsInArrays(var columns: ColumnArray; var Enemys: ArrOfEnemys);
	var
		tek: Byte;
		i: Word;
	begin
		for tek := 1 to ScreenWidth - 1 do // Переприсваивание значений высот предыдущим столбцам из следующих
			columns[tek] := columns[tek + 1];

		// Уменьшение координаты x вражеских объектов на единицу
		for i := 1 to ScreenWidth do
			begin
				if Enemys[i].coordinateY <> 0 then // Проверка наличия самолёта в элементе массива
					begin
						Enemys[i-1].coordinateX := Enemys[i].coordinateX - 1;
						Enemys[i].coordinateX := 0;
						Enemys[i-1].coordinateY := Enemys[i].coordinateY;
						Enemys[i].coordinateY := 0
					end;
			end
	end;

procedure GenerateEnemys(var Enemys: ArrOfEnemys);
	begin
		// Доработать это условие так, чтобы исключить возможность генерации врагов слишком близко друг к другу
		if random(30) = 13 then // Данная строка обуславливает частоту генерации врагов
			begin
				Enemys[ScreenWidth].coordinateX := ScreenWidth - 12;

				// В последующем цикле генерируется координата y для вражеского объекта
				Enemys[ScreenWidth].coordinateY := 0;
				while Enemys[ScreenWidth].coordinateY < 3 do
					Enemys[ScreenWidth].coordinateY := random( trunc(ScreenHeight / 100 * 65) )
					
			end
		else
			begin
				Enemys[ScreenWidth].coordinateX := 0;
				Enemys[ScreenWidth].coordinateY := 0
			end
	end;

procedure PrintJet(CoordinateX, CoordinateY: Byte); // Вывод самолёта на экран
	var
		MoveBy_Y, i: Byte;
	begin
		TextColor(Magenta); 
		MoveBy_Y := CoordinateY;
		for i := 1 to 7 do
			begin
				GotoXY(CoordinateX, MoveBy_Y);
				write(Jet[i]);
				MoveBy_Y := MoveBy_Y + 1
			end
	end;

procedure ProcessingOfPressingKeys(var CoordinateX, CoordinateY: Byte{; var Shot: Boolean}); //Обработка нажатия клавиш
	begin
		case HowKeyPressed of
			JetMovingUp:
				begin
					if CoordinateY > 1 then
						CoordinateY := CoordinateY - 1;
				end;
				
			JetMovingDown:
				begin
					CoordinateY := CoordinateY + 1;
				end;
				
			JetMovingLeft:
				begin
					if CoordinateX > 1 then
						CoordinateX := CoordinateX - 1;
				end;

			JetMovingRight:
				begin
					if CoordinateX < ScreenWidth - 17 then
						CoordinateX := CoordinateX + 1;
				end;

			{JetShot:
				Shot := True;}

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
			for j := trunc(ScreenHeight / 100 * 90) to ScreenHeight do
				begin
					GotoXY(i, j);
					write(Ground)
				end;
	end;

procedure Initializing_CoordinateX_CoordinateY(var CoordinateX, CoordinateY: Byte); // Инициализация начального положения самолёта на экране
	begin
		CoordinateX := trunc(ScreenWidth / 100 * 10);
		CoordinateY := trunc(ScreenHeight / 100 * 10)  
	end;

procedure OutputScreen(var columns: ColumnArray; CoordinateX, CoordinateY: Word; var Enemys: ArrOfEnemys); // Вывод земли
	var
		tek: Integer;
		j, y, k: Word;
		
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
						
				// Вывод вражеских самолётов на экран
				if Enemys[tek].coordinateY <> 0 then // Проверка наличия самолёта в элементе массива
					begin

						
						TextColor(yellow{11});
						y := Enemys[tek].coordinateY;

						for k := 0 to 4 do
							begin

								for j := 0 to 13 do
									begin

										if (Enemys[tek].coordinateX + j >=1) and (Enemys[tek].coordinateX + j <= ScreenWidth) then
											begin
												GotoXY(Enemys[tek].coordinateX + j, y);

												if Enemys[tek].coordinateX = 0 then
													write(Space)
												else
													write(FascistJet[13*k + j])
														
											end

									end;

								y := y + 1
							end;
					end;	

				// Вывод самолёта
				PrintJet(CoordinateX, CoordinateY);	
						
				// Обработчик столкновений самолёта с землёй или снарядами
				CollisionHandler(CoordinateX, CoordinateY, tek, columns[tek], Enemys)
			end;
	end;

var
	columns: ColumnArray;
	Enemys: ArrOfEnemys;
	CoordinateX, CoordinateY: Byte;
	counter: Real;
	Shot: Boolean;
	
begin

	counter := 0;
	
	Randomize;
	ClrScr;
	
	InitializingArrayOfColumns(columns);  // Инициализация массива, чтобы избежать неопределённых значений его элементов 
	columns[ScreenWidth] := StartHeightOfPointInColumn; // Присваивание начального значения высоты первому столбику
	Initializing_CoordinateX_CoordinateY(CoordinateX, CoordinateY); // Инициализация начального положения самолёта на экране
	Shot := False;

	while True do // Основной цикл работы программы
		begin

			// Переприсваивание значений высот предыдущим столбцам из следующих
			MovePointsInArrays(columns, Enemys); 
	
			// Вывод на экран объектов игры (земля, самолёт, взрывы)
			if counter <> ScreenWidth then
				begin
					counter := counter + 0.5;
					//printMatMessage
					if counter = ScreenWidth then
						PrintBottomGroundAndJet(CoordinateX, CoordinateY); // Вывод "нижней части земли" и самолёта
				end	
			else 
				begin
					OutputScreen(columns, CoordinateX, CoordinateY, Enemys);
					// Генерация вражеских объектов
					GenerateEnemys(Enemys);
				end;

			// Обработка нажатия клавиш
			ProcessingOfPressingKeys(CoordinateX, CoordinateY);
		
			// Присваивание нового значения высоты первому столбцу
			columns[ScreenWidth] := RandomPointInColumn(columns[ScreenWidth - 1]);

			// Задержка вывода "картинки" в терминал
			Delay(Speed);
			
  	end
  	
end.
