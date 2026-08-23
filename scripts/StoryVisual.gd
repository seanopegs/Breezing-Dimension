extends Control

var _time:=0.0
var mood:="before_the_fracture"

func _ready()->void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

func _process(delta:float)->void:_time+=delta;queue_redraw()

func set_mood(value:String)->void:mood=value;queue_redraw()

func _draw()->void:
	var hue_shift:=float(abs(mood.hash())%11)/100.0
	var mood_color:=Color.from_hsv(0.60+hue_shift,0.72,0.22)
	draw_rect(Rect2(Vector2.ZERO,size),Color("080e25"),true)
	for i in 12:
		var y:=i*size.y/12.0;draw_rect(Rect2(0,y,size.x,size.y/12+1),Color("080e25").lerp(mood_color,float(11-i)/18.0),true)
	# Core rings and fractured skyline.
	var core:=Vector2(size.x*.5,size.y*.42)
	for r in [58.0,92.0,130.0]:draw_arc(core,r,_time*.08,-_time*.08+TAU,64,Color(0.4,1,0.94,0.08),2)
	draw_circle(core,18+sin(_time*2)*3,Color(0.55,0.45,1,0.28))
	for i in 14:
		var x:=i*90.0;var h:=70+sin(i*2.3)*55;draw_colored_polygon(PackedVector2Array([Vector2(x,size.y),Vector2(x+15,size.y-h),Vector2(x+45,size.y-h-20),Vector2(x+70,size.y)]),Color("050a1b"))
	for i in 14:
		var p:=Vector2(fmod(i*191.0+_time*24,size.x+100)-50,fmod(i*73.0,size.y*.75));draw_line(p,p+Vector2(22,0),Color(0.45,1,0.95,0.18),2)
