extends Node2D

@onready var typing_sound : AudioStreamPlayer2D = $history_en/AudioStreamPlayer2D
@onready var history_en_la: RichTextLabel = $history_en
var history_en = "     Complete your mission towards your grave.
 Your mission is death. 
You strongly desire death. Help yourself to 
die in your grave
. Search for your grave.
 You must also gather 38 souls with you to open 
the grave and be freed from the curse of immortality."
var first_time = true
@onready var history_ar_la: RichTextLabel = $history_ar
var history_ar = "أكمل مهمتك نحو قبرك.
 مهمتك هي الموت. أنت ترغب بشدة في الموت.
 ساعد نفسك على الموت في قبرك.
 ابحث عن قبرك. 
يجب عليك أيضًا جمع 38 نفسًا معك لفتح القبر والتحرر من 
لعنة الخلود. "

var has = false

var can = false # هذا المتغير هو المفتاح، لن يصبح true إلا بعد انتهاء الكتابة

@export var title_speed = 0.05
@export var paragraph_speed = 0.05


@export var main_menu_scene: PackedScene  
@onready var level_holder = $Node2D
@onready var shatter_layer = $CanvasLayer
@onready var camera = $Camera2D

func _ready() -> void:
	# إخفاء الأزرار في البداية لضمان عدم الضغط المبكر
	if $Touch: $Touch.hide()
	if $Touch2: $Touch2.hide()
	
	# إعداد الصوت
	if typing_sound:
		typing_sound.volume_db = -12
		if typing_sound.stream:
			typing_sound.stream.loop = true
			
	# تشغيل المنطق بناءً على اللغة
	if LanguageManager.current_lang == 0:
		history_en_la.bbcode_enabled = true
		history_en_la.visible_characters = 0
		await write_paragraph_en() # ينتظر هنا حتى تنتهي الدالة تماماً
		if $Touch: $Touch.show()
		can = true # الآن فقط يُسمح بالانتقال
	
	elif LanguageManager.current_lang == 1:
		history_ar_la.bbcode_enabled = true
		history_ar_la.visible_characters = 0
		await write_paragraph() # ينتظر هنا حتى تنتهي الدالة تماماً
		if $Touch2: $Touch2.show()
		can = true # الآن فقط يُسمح بالانتقال

func _input(event):
	# إذا تم الانتقال مسبقاً (has) أو لم تنتهِ الكتابة بعد (can == false) لا تفعل شيئاً
	if has or not can:
		return
		
	# التحقق من الضغط (كيبورد أو لمس شاشة)
	if event.is_action_pressed("ui_accept") or (event is InputEventScreenTouch and event.pressed):
		has = true
		start_intro_transition()

func write_paragraph_en():
	await get_tree().create_timer(1.0).timeout
	history_en_la.text = history_en
	var total = history_en.length()
	
	if typing_sound: typing_sound.play()
	
	for i in range(1, total + 1):
		history_en_la.visible_characters = i
		var current_char = history_en[i-1]
		
		# إذا كانت نقطة أو فاصلة، انتظر وقتاً أطول قليلاً (0.4 ثانية)
		if current_char in [".", "!", "؟", "،", ","]:
			if typing_sound: typing_sound.stream_paused = true
			await get_tree().create_timer(0.4).timeout
			if typing_sound: typing_sound.stream_paused = false
		else:
			await get_tree().create_timer(paragraph_speed).timeout
	
	if typing_sound: typing_sound.stop()
	return true

func write_paragraph():
	await get_tree().create_timer(1.0).timeout
	history_ar_la.text = history_ar
	var total = history_ar.length()
	
	if typing_sound: typing_sound.play()
	
	for i in range(1, total + 1):
		history_ar_la.visible_characters = i
		var current_char = history_ar[i-1]
		
		if current_char in [".", "!", "؟", "،", ","]:
			if typing_sound: typing_sound.stream_paused = true
			await get_tree().create_timer(0.4).timeout
			if typing_sound: typing_sound.stream_paused = false
		else:
			await get_tree().create_timer(paragraph_speed).timeout
	
	if typing_sound: typing_sound.stop()
	return true

func start_intro_transition():
	# تجنب التكرار
	can = false 
	
	var screenshot = get_viewport().get_texture().get_image()
	var texture = ImageTexture.create_from_image(screenshot)
	
	var tween = create_tween()
	for i in range(10):
		var rand_offset = Vector2(randf_range(-10, 10), randf_range(-10, 10))
		tween.tween_property(camera, "offset", rand_offset, 0.04)
	tween.tween_property(camera, "offset", Vector2.ZERO, 0.04)
	
	await tween.finished
	$FOG8BACK.hide()
	$Sprite2D.hide()
	$history_en.hide()
	$history_ar.hide()
	history_ar_la.hide()
	if $Touch: $Touch.hide()
	if $Touch2: $Touch2.hide()
	
	create_shatter_effect(texture)
	
	await get_tree().create_timer(2).timeout 
	# تغيير المشهد
	Trnsitionlayer.get_tree().change_scene_to_file("res://scenes/main_select.tscn")

func create_shatter_effect(tex: Texture2D):
	var screen_size = get_viewport().get_visible_rect().size
	var points : PackedVector2Array = []
	points.append_array([Vector2.ZERO, Vector2(screen_size.x, 0), screen_size, Vector2(0, screen_size.y)])
	for i in range(40):
		points.append(Vector2(randf_range(0, screen_size.x), randf_range(0, screen_size.y)))
	
	var triangles = Geometry2D.triangulate_delaunay(points)
	
	for i in range(0, triangles.size(), 3):
		var p1 = points[triangles[i]]
		var p2 = points[triangles[i+1]]
		var p3 = points[triangles[i+2]]
		var center = (p1 + p2 + p3) / 3.0
		
		var piece = RigidBody2D.new()
		var poly = Polygon2D.new()
		var triangle_points = PackedVector2Array([p1 - center, p2 - center, p3 - center])
		poly.polygon = triangle_points
		poly.texture = tex
		poly.texture_offset = center
		
		piece.add_child(poly)
		piece.position = center
		shatter_layer.add_child(piece)
		piece.apply_central_impulse(Vector2(randf_range(-500, 500), randf_range(-200, 500)))
		
		var p_tween = create_tween()
		p_tween.tween_property(piece, "modulate:a", 0.0, 1.5).set_delay(1.0)
		p_tween.finished.connect(piece.queue_free)

	await get_tree().create_timer(2.1).timeout
	self.queue_free()
