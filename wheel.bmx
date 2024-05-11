'Wheel

Type wheel
	Field sectors:sector[]
	Field ReadOnly size
	Field ReadOnly sum_fp:Double
	Field ReadOnly num_def_p
	Field a:Double
	Field av:Double
	Field pos:Vec
	Field r
	
	Method New(optionsURL:String, pos:vec)
		Self.pos = pos
		
		Self.sectors = LoadSectors(optionsURL)
		Self.size = sectors.length
		Self.r = GetIniInt("options.ini", "wheel radius")
		
		For Local i = 0 To Self.size-1
			If Self.sectors[i].fp <= 0 Or Self.sectors[i].fp >= 1 Then
				Self.num_def_p :+ 1
				Continue
			EndIf
			
			Self.sum_fp :+ Self.sectors[i].fp
		Next
		
		For Local i = 0 To Self.size-1
			If Self.sectors[i].fp > 0 And Self.sectors[i].fp < 1 Then
				Self.sectors[i].span_angle = 360.0*Self.sectors[i].fp
			Else
				Self.sectors[i].span_angle = 360.0*((1.0 - Self.sum_fp)/Double(Self.num_def_p))
			EndIf
		Next
		
		Self.SortSectors()
	EndMethod
	
	Method draw()
		SetColor New color3(128,128,128)
		
		DrawCircle(Self.pos, Self.r+5)
		
		Local offsetangle:Double = 0
		For Local i = 0 To Self.size-1
			SetColor Self.sectors[i].color
			
			Self.sectors[i].angle = Self.a + offsetangle
			
			drawsector(Self.pos, Self.r, Self.sectors[i].angle, Self.sectors[i].span_angle)

			offsetangle :+ Self.sectors[i].span_angle
		Next

		SetColor New color3(255,255,255)
		
		DrawCircle(Self.pos, Self.r/12)
		
		If spinning Then
			chosen_sector_content = PointHoveringSector(spinner, arrow_point).content
			If old <> chosen_sector_content Then
				old = chosen_sector_content
				PlaySound(clicks[Rand(0,num_clicks-1)])
			EndIf
		EndIf
	EndMethod
	
	Method spin(initial_angle:Double = 0)
		Self.a = initial_angle
		Self.av = wheel_speed
	EndMethod
	
	Method update()
		Self.a :+ Self.av*dt
		
		If stopping Then Self.av :* wheel_friction
		
		If Self.a > 360 Then Self.a = 0
		If Self.a < 0 Then Self.a = 360
	EndMethod
	
	Method SortSectors()
		For Local i = 0 To Self.size - 1
			For Local j = 0 To Self.size - i - 2
				Local a:Double = Self.sectors[j].fp
				Local b:Double = Self.sectors[j+1].fp
				
				If a > b Then
					Local temp:sector = Self.sectors[j]
					
					Self.sectors[j] = Self.sectors[j+1]
					Self.sectors[j+1] = temp
				EndIf
			Next
		Next	
	EndMethod
EndType

Type sector
	Field content:String
	Field color:color3
	Field fp:Double
	Field span_angle:Double
	Field angle:Double
	
	Method New(content:String)
		Self.content = content
	EndMethod
EndType
