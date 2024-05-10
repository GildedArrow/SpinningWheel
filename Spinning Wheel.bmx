Include "readini.bmx"
Include "vector.bmx"

Global screenres:Int[] = GetIniResolution("options.ini")

Global w = screenres[0]
Global h = screenres[1]

AppTitle = "Spinning Wheel 1.0"

Graphics w,h

SeedRnd MilliSecs()

Global wheel_friction:Double = GetIniDouble("options.ini", "wheel friction")
Global wheel_speed:Double = GetIniDouble("options.ini", "wheel speed")
Global text_scale:Double = GetIniDouble("options.ini", "text scale")

Global num_clicks = 6
Global clicks:TSound[num_clicks]

For Local i = 0 To num_clicks-1
	clicks[i] = LoadSound("asset\click"+i+".wav")
Next

Global ding_sfx:TSound = LoadSound("asset\ding.wav")

Global textspacing:Double = 10

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
		
		Self.sectors = LoadSectors("options.txt")
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
			
			drawsector(New vec(w/2, h/2), Self.r, Self.sectors[i].angle, Self.sectors[i].span_angle)

			offsetangle :+ Self.sectors[i].span_angle
		Next

		SetColor New color3(255,255,255)
		
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
		
		Self.av :* wheel_friction
		
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

Type color3
	Field r,g,b
	
	Method New(r = 0, g = 0, b = 0)
		Self.r = r
		Self.g = g
		Self.b = b
	EndMethod
EndType

Global spinner:wheel = New wheel("options.txt", New vec(w/2,h/2))
Global spinning = False
Global chosen_sector_content:String
Global old:String
Global arrow_point:vec = spinner.pos + New vec(spinner.r - 5, 0)
Global past_click = False

Global dt:Double = 1.0/60.0
Global fps
Global framecount
Global oldtime = MilliSecs()

SetBlend ALPHABLEND

SetClsColor 32,32,32
While Not KeyDown(KEY_ESCAPE)
	framecount :+ 1
	
	If MilliSecs() - oldtime >= 1000 Then
		fps = framecount
		framecount = 0
		dt = 1.0/Double(fps)
		oldtime = MilliSecs()
	EndIf
	
	Cls
	
	
	spinner.update()
	spinner.draw()
	
	If KeyHit(KEY_SPACE) And Not spinning Then
		spinning = True
		spinner.spin(Rnd(0,360))
	EndIf
	
	If Abs(spinner.av) <= 1 And spinning Then
		spinning = False
		spinner.av = 0
		chosen_sector_content = PointHoveringSector(spinner, arrow_point).content
		PlaySound(ding_sfx)
	EndIf
	
	DrawText "FPS: "+fps,0,0
	DrawText "Spinning = "+spinning,0,10
	DrawText "Chosen option: "+chosen_sector_content,w/2 - TextWidth("Chosen option: "+chosen_sector_content)/2,20
	
	SetColor 0,0,0
	SetLineWidth 5
	DrawLine Float(arrow_point.x), Float(arrow_point.y), Float(arrow_point.x + 30), Float(arrow_point.y)
	SetLineWidth 1
	
	DrawTip()
	
	Flip
Wend
End

Function Atan3:Double(y:Double,x:Double)
	Local a:Double = ATan2(y,x)
	
	Return((a + 360) Mod 360)
EndFunction

Function DrawTip()
	Local overlapsector:Sector = PointHoveringSector(spinner, New vec(MouseX(), MouseY()))
	
	If overlapsector Then
		Local text:String = overlapsector.content + " " + Int(100*(overlapsector.span_angle/360.0))+"%"
	
		SetColor 32,32,32
		SetAlpha 0.5
		DrawRect MouseX()+10, MouseY()+10, TextWidth(text), TextHeight(text)
		SetAlpha 1
		SetColor 255,255,255
		DrawText text,MouseX()+10,MouseY()+10
	EndIf
EndFunction

Function PointHoveringSector:Sector(spin:wheel, point:vec)
	Local origin:vec = spin.pos
	Local radius:Double = spin.r
	Local c:vec = point
	
	Local angleC:Double = ATan3(origin.y - c.y, origin.x - c.x)
	
	If (c - origin).magnitude() > radius Then Return
	
	For Local i = 0 To spin.size - 1
		Local a:vec = origin + New vec(radius*Cos(spin.sectors[i].angle),radius*Sin(spin.sectors[i].angle))
		Local b:vec = origin + New vec(radius*Cos(spin.sectors[i].angle+spin.sectors[i].span_angle),radius*Sin(spin.sectors[i].angle+spin.sectors[i].span_angle))
		
		Local angleA:Double = ATan3(origin.y - a.y, origin.x - a.x)
		Local angleB:Double = ATan3(origin.y - b.y, origin.x - b.x)
		
		If angleA < angleB Then
			If angleC >= angleA And angleC < angleB Then
				Return spin.sectors[i]
			EndIf
		Else
			If (angleC <= angleA And angleC < angleB) Or (angleC >= angleA And angleC > angleB) Then
				Return spin.sectors[i]
			EndIf
		EndIf
	Next
EndFunction

Function DrawCircle(pos:vec, radius:Double)
	DrawOval Float(pos.x - radius), Float(pos.y - radius), Float(radius)*2, Float(radius)*2
EndFunction

Function DrawSector(pos:vec, radius, sa:Double, ea:Double)
	For Local i:Double = 0 To ea Step 0.125
		DrawLine Float(pos.x), Float(pos.y), Float(pos.x + Cos(sa+i)*radius), Float(pos.y + Sin(sa+i)*radius)
	Next
EndFunction

Function PushSector:Sector[](Array:Sector[], sector:Sector)
	Local temp:Sector[] = New Sector[array.length+1]
	
	For Local i = 0 To array.length - 1
		temp[i] = array[i]
	Next
	
	temp[temp.length-1] = sector
	
	Return temp
EndFunction

Function LoadSectors:Sector[](url:String)
	Local file:TStream = OpenStream(url)
	
	Local sectors:sector[]
	
	While Not Eof(file)
		Local line:String[] = ReadLine(file).split(";")
		Local s:sector = New sector(line[0])
		
		Local temp:String[] = RemoveParenthesis(line[1]).split(",")
		
		Local color:color3
		
		If Int(temp[0]) = -1 Or Int(temp[1]) = -1 Or Int(temp[2]) = -1 Then
			color = New color3(Rand(255), Rand(255), Rand(255))
		Else
			color = New color3(Int(temp[0]), Int(temp[1]), Int(temp[2]))
		EndIf
		
		s.color = color
		s.fp = Double(line[2])
		
		sectors = PushSector(sectors, s)
	Wend
	
	CloseStream file
	
	Return sectors
EndFunction

Function DrawText2(t:String, x:Float, y:Float)
	DrawText t, x, y - TextHeight(t)/2
EndFunction

Function SetColor(color:color3)
	SetColor color.r, color.g, color.b
EndFunction