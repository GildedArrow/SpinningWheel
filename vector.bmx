Type Vec
	Field x:Double
	Field y:Double
	
	Method New(x:Double = 0, y:Double = 0)
		Self.x = x
		Self.y = y
	EndMethod
	
	Method Dot:Double(b:Vec)
		Return Self.x*b.x + Self.y*b.y
	EndMethod

	Method Normal:Vec()
		Local mag:Double = Self.magnitude()
		
		Return New Vec(Self.x/mag, Self.y/mag)
	EndMethod
	
	Method Magnitude:Double()
		Return Sqr(Self.x*Self.x + Self.y*Self.y)
	EndMethod
	
	Method Perp:Vec()
		Return New Vec(Self.y, -Self.x)
	EndMethod
	
	Method Operator+:Vec(b:Vec)
		Local sumx:Double = Self.x + b.x
		Local sumy:Double = Self.y + b.y
		
		Return New Vec(sumx, sumy)
	EndMethod
	
	Method Operator-:Vec(b:Vec)
		Local dx:Double = Self.x - b.x
		Local dy:Double = Self.y - b.y
		
		Return New Vec(dx, dy)
	EndMethod
	
	Method Operator*:Vec(b:Double)
		Local px:Double = Self.x * b
		Local py:Double = Self.y * b
		
		Return New Vec(px, py)
	EndMethod
	
	Method Operator/:Vec(b:Double)
		Local qx:Double = Self.x / b
		Local qy:Double = Self.y / b
		
		Return New Vec(qx, qy)	
	EndMethod
	
	Method Operator=:Int(b:Vec)
		Return (Self.x = b.x) And (Self.y = b.y)
	EndMethod
EndType