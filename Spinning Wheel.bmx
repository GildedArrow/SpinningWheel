Include "readini.bmx"
Include "vector.bmx"
Include "button.bmx"

Global screenres:Int[] = GetIniResolution("options.ini")

Global w = screenres[0]
Global h = screenres[1]

AppTitle = "Spinning Wheel 1.0"

Graphics w,h

SeedRnd MilliSecs()

Global wheel_friction:Double = GetIniDouble("options.ini", "wheel friction")
Global wheel_speed:Double = GetIniDouble("options.ini", "wheel speed")
Global text_scale:Int = GetIniInt("options.ini", "font size")

Global num_clicks = 6
Global clicks:TSound[num_clicks]

For Local i = 0 To num_clicks-1
	clicks[i] = LoadSound("asset\click"+i+".wav")
Next

Global ding_sfx:TSound = LoadSound("asset\ding.wav")

Global textspacing:Int = GetIniInt("options.ini", "text spacing")
Global arial:TImageFont = LoadImageFont("ARIAL.TTF", text_scale, SMOOTHFONT)

SetImageFont arial

Include "wheel.bmx"

Type Color3
	Field r,g,b
	
	Method New(r = 0, g = 0, b = 0)
		Self.r = r
		Self.g = g
		Self.b = b
	EndMethod
	
	Method Operator*:Color3(s:Double)
		Local r:Double = Double(Self.r)*s
		Local g:Double = Double(Self.g)*s
		Local b:Double = Double(Self.b)*s
		
		Return New Color3(Int(r), Int(g), Int(b))
	EndMethod
EndType

Global COLOR_RED:Color3 = New color3(200,0,0)
Global COLOR_GREEN:Color3 = New color3(0,200,0)

Global spinner:wheel = New wheel("wheels\options_test.txt", New vec(w/2,h/2))
Global spinning = False
Global stopping = False
Global chosen_sector_content:String
Global old:String
Global arrow_point:vec = spinner.pos + New vec(spinner.r - 5, 0)
Global past_click = False

Global dt:Double = 1.0/60.0
Global fps
Global framecount
Global oldtime = MilliSecs()

Global spinbutton:button = New button(New vec(w/2, h/2 + spinner.r + 40), New vec(0,0), "Spin")
spinbutton.pos.x = w/2 - spinbutton.size.x/2

Global stopbutton:button = New button(New vec(w/2, spinbutton.pos.y+spinbutton.size.y+10), New vec(0,0), "Stop")
stopbutton.pos.x = w/2 - stopbutton.size.x/2
stopbutton.visible = False
stopbutton.active = False

Global refreshbutton:button = New button(New vec(10, 100), New vec(0,0), "Refresh List")
Global extent_top
Global extent_bottom

Global bar:scrollbar = New scrollbar

Global FileList:String[]
Global filebuttons:button[]
Global selected_index = 0

SetBlend ALPHABLEND
SetClsColor 32,32,32

refreshfilelist()

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
	
	If (KeyHit(KEY_SPACE) Or spinbutton.clicked) And Not spinning Then
		spinning = True
		spinner.spin(Rnd(0,360))
		spinbutton.visible = False
		spinbutton.active = False
		stopbutton.visible = True
		stopbutton.active = True
	EndIf
	
	If stopbutton.clicked Then
		stopping = True
		stopbutton.visible = False
		stopbutton.active = False
	EndIf
	
	If Abs(spinner.av) <= 1 And spinning Then
		spinning = False
		stopping = False
		spinner.av = 0
		chosen_sector_content = PointHoveringSector(spinner, arrow_point).content
		PlaySound(ding_sfx)
		spinbutton.visible = True
		spinbutton.active = True
		stopbutton.visible = False
		stopbutton.active = False
	EndIf
	
	If Not spinning Then
		bar.update()
	EndIf
	
	If refreshbutton.clicked Then
		RefreshFileList()
	EndIf
	
	SetColor 0,0,0
	SetLineWidth 5
	DrawLine Float(arrow_point.x), Float(arrow_point.y), Float(arrow_point.x + 30), Float(arrow_point.y)
	SetLineWidth 1
	
	spinbutton.update()
	stopbutton.update()
	refreshbutton.update()
	
	HandleFileList()
	DrawUi()
	DrawTip()

	FlushMouse()
	
	Flip
Wend
End

Function RefreshFileList()
	selected_index = -1
	Filelist:String[] = LoadDir("wheels")
	
	filebuttons = New button[filelist.length]
	
	filebuttons[0] = New button(New vec(10,refreshbutton.pos.y), New vec(10+TextWidth(filelist[0]),10+TextHeight(filelist[0])), filelist[0])
	filebuttons[0].pos.y = refreshbutton.pos.y+10+filebuttons[0].size.y
	filebuttons[0].bar = bar
	For Local i = 1 To filelist.length - 1
		filebuttons[i] = New button(New vec(10,filebuttons[i-1].pos.y+filebuttons[i-1].size.y+10), New vec(0,0), filelist[i])
		filebuttons[i].bar = bar
		
		If i = 0 Then
			extent_top = filebuttons[i].pos.y - bar.yoffset
		ElseIf i = filelist.length - 1 Then
			extent_bottom = filebuttons[i].pos.y+filebuttons[i].size.y - bar.yoffset*filelist.length
		EndIf
	Next
EndFunction

Function HandleFileList()
	For Local i = 0 To filelist.length - 1
		If spinning Then Continue
	
		If filebuttons[i].clicked And selected_index <> i Then
			selected_index = i
			
			spinner = New wheel("wheels\"+filelist[selected_index],New vec(w/2, h/2)) 
		EndIf
		
		Local c:Color3 = filebuttons[i].basecolor
		If i = selected_index Then
			filebuttons[i].basecolor = c*0.5
			filebuttons[i].active = False
		Else
			filebuttons[i].active = True
		EndIf
		
		filebuttons[i].draw()
		filebuttons[i].basecolor = c
		filebuttons[i].update()
	Next
	
	SetColor 32,32,32
	DrawRect 0,0,250,150
	
	refreshbutton.draw()
EndFunction

Function DrawUi()
	SetColor 255,255,255
	DrawText "FPS: "+fps,0,0
	DrawText "Chosen option: "+chosen_sector_content,w/2 - TextWidth("Chosen option: "+chosen_sector_content)/2,20
	
	spinbutton.draw()
	stopbutton.draw()
EndFunction

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
	
	temp[array.length] = sector
	
	Return temp
EndFunction

Function LoadSectors:Sector[](url:String)
	Local file:TStream = OpenStream(url)
	
	Local sectors:sector[]
	
	While Not Eof(file)
		Local raw:String = ReadLine(file)
		If Len(Trim(raw)) >= 2 And Left(Trim(raw),2) = "//" Then Continue
		If Len(Trim(raw)) = 0 Then Continue

		Local line:String[] = raw.split("//")[0].split(";")

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