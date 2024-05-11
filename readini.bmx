Function GetIniResolution:Int[](url:String)
	Local size:String[] = GetIniString(url, "resolution").split(",")
	Local res:Int[] = New Int[2]
	
	res[0] = Int(size[0])
	res[1] = Int(size[1])
	 
	Return res
EndFunction

Function RemoveBrackets:String(s:String)
	Return s.Replace("[","").Replace("]","")
EndFunction

Function RemoveParenthesis:String(s:String)
	Return s.Replace("(","").Replace(")","")
EndFunction

Function GetIniFloat:Float(url:String, name:String)
	Return Float(GetIniString(url, name))
EndFunction

Function GetIniDouble:Double(url:String, name:String)
	Return Double(GetIniString(url, name))
EndFunction

Function GetIniInt:Int(url:String, name:String)
	Return Int(GetIniString(url, name))
EndFunction

Function GetIniString:String(url:String, name:String)
	Local stream:TStream = OpenStream(url)
	
	Local str:String
	
	While Not Eof(stream)
		Local line:String = ReadLine(stream)
		If Len(Trim(line)) >= 2 And Left(Trim(line),2) = "//" Then Continue
		If Len(Trim(line)) = 0 Then Continue
		If Trim(Lower(RemoveBrackets(line))).split("//")[0].Replace(" ","") <> Lower(name).Replace(" ","") Then Continue
		
		str = Trim(ReadLine(stream)).split("//")[0]
		
		Exit
	Wend
	
	CloseStream stream
	
	Return str
EndFunction
