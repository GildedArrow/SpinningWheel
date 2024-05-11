Global scrollwheelspeed:Double = GetIniDouble("options.ini", "scrollwheel sensitivity")

Type ScrollBar
	Field yoffset:Double
	
	Method Update()
		Self.yoffset :+ MouseZ()*scrollwheelspeed
	EndMethod
EndType

Type Button
	Field pos:Vec
	Field size:Vec
	Field clicked, hovering
	Field text:String
	Field visible
	Field active
	Field basecolor:color3
	Field textcolor:color3
	Field bar:scrollbar
	
	Method New(pos:Vec, size:Vec, text:String)
		Self.pos = pos
		Self.size = size
		Self.text = text
		Self.basecolor = New color3(128,128,128)
		Self.textcolor = New color3(255,255,255)
		Self.visible = True
		Self.active = True
		
		If Self.size = New vec(0,0) Then
			Self.size = New vec(10+TextWidth(Self.text), 10+TextHeight(Self.text))
		EndIf
	EndMethod
	
	Method draw()
		If Not Self.visible Then Return
		
		If Not Self.beinghovered() Then
			SetColor Self.basecolor
		Else
			If Self.active Then SetColor Self.basecolor*0.5 Else SetColor Self.basecolor
		EndIf
		
		If Not Self.bar Then
			DrawRect2 Self.pos, Self.size
		
			SetColor Self.textcolor
			DrawText Self.text, Float(Self.pos.x+(Self.size.x-TextWidth(Self.text))/2), Float(Self.pos.y+(Self.size.y-TextHeight(Self.text))/2)
		Else
			DrawRect2 Self.pos + New vec(0,Self.bar.yoffset), Self.size
		
			SetColor Self.textcolor
			DrawText Self.text, Float(Self.pos.x+(Self.size.x-TextWidth(Self.text))/2), Float(Self.bar.yoffset)+Float(Self.pos.y+(Self.size.y-TextHeight(Self.text))/2)			
		EndIf
	EndMethod
	
	Method update()
		Self.clicked = False
		If Not Self.active Then Return
		
		If Self.BeingHovered() Then
			If MouseHit(1) Then
				Self.clicked = True
			EndIf
		EndIf
	EndMethod
	
	Method BeingHovered()
		Local mx = MouseX()
		Local my = MouseY()
		
		Return (mx>Self.pos.x) And (my>Self.pos.y) And (mx<Self.pos.x+Self.size.x) And (my<Self.pos.y+Self.size.y)
	EndMethod
EndType

Function DrawRect2(pos:vec, size:vec)
	DrawRect Float(pos.x), Float(pos.y), Float(size.x), Float(size.y)
EndFunction