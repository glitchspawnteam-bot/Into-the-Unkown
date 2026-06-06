extends Area2D

@onready var big_circle = $Bigcircle
@onready var small_circle = $Record
@onready var max_distance = $CollisionShape2D.shape.radius

var touched = false
var touch_index = -1 

func _input(event):
	# نستخدم ScreenTouch للتعرف على بداية ونهاية اللمس
	if event is InputEventScreenTouch:
		if event.pressed:
			
			var distance = event.position.distance_to(global_position)
			# نتحقق أن اللمسة داخل الدائرة وأن الجويستيك غير مشغول بإصبع آخر
			if distance <= max_distance and touch_index == -1:
				touched = true
				touch_index = event.index
				_update_joystick_position(event.position)
		elif event.index == touch_index:
			
			# عندما يرفع الإصبع المسؤول عن الجويستيك يده
			touched = false
			touch_index = -1
			small_circle.position = Vector2.ZERO

	# نستخدم ScreenDrag لملاحقة حركة الإصبع بدقة
	if event is InputEventScreenDrag:
		
		if event.index == touch_index:
			_update_joystick_position(event.position)

func _update_joystick_position(pos):
	var dir = (pos - global_position)
	small_circle.position = dir.limit_length(max_distance)

func get_velo() -> Vector2:
	return small_circle.position / max_distance
