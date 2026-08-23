extends Control

var _time := 0.0
var _dimension := 0
var _streaks: Array[Dictionary] = []
var mood := "fractured_ruins"

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	for i in 34:
		_streaks.append({"p":Vector2(randf()*1152,randf()*648),"s":randf_range(20,80),"a":randf_range(0.08,0.28)})
	DimensionManager.dimension_changed.connect(_on_dimension)
	_on_dimension(DimensionManager.current_dimension)

func _on_dimension(value: int) -> void:
	_dimension = value; queue_redraw()

func set_mood(value: String) -> void:
	mood = value; queue_redraw()

func _process(delta: float) -> void:
	_time += delta
	if _dimension == DimensionManager.Dimension.BREEZE:
		for line in _streaks:
			line.p.x += line.s*delta
			if line.p.x > size.x+100: line.p.x = -100; line.p.y = randf()*size.y
	queue_redraw()

func _draw() -> void:
	var variation := float(abs(mood.hash()) % 9) / 100.0
	var top := Color.from_hsv(0.61+variation,0.62,0.30) if _dimension == 0 else Color.from_hsv(0.50+variation*.2,0.82,0.48)
	var bottom := Color("090d26") if _dimension == 0 else Color("092f48")
	draw_rect(Rect2(Vector2.ZERO,size),bottom,true)
	for i in 12:
		var t := float(i)/12.0
		draw_rect(Rect2(0,t*size.y,size.x,size.y/12+1),bottom.lerp(top,1.0-t),true)
	# Distant fractured towers
	for i in 18:
		var x := i*75.0-fmod(_time*(3 if _dimension else 0.3),75.0)
		var h := 80.0 + sin(i*2.1)*50.0
		draw_colored_polygon(PackedVector2Array([Vector2(x,size.y),Vector2(x+8,size.y-h),Vector2(x+42,size.y-h-18),Vector2(x+62,size.y)]),Color(0.03,0.07,0.16,0.65))
	for line in _streaks:
		var alpha: float = float(line.a) if _dimension == 1 else float(line.a)*0.15
		draw_line(Vector2(line.p), Vector2(line.p)+Vector2(float(line.s),0),Color(0.5,1,0.95,alpha),1.5)
	# Fracture in the sky
	draw_polyline(PackedVector2Array([Vector2(size.x*.72,0),Vector2(size.x*.69,100),Vector2(size.x*.73,170),Vector2(size.x*.68,255)]),Color(0.55,0.4,1,0.28),3)
