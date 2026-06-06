@tool
extends Line2D

@export_category("Flash Customize")
## اختر لون الوميض (الأساسي أو أي لون تحبه وسيقوم الكود بوضعه بنمط RAW مضيء تلقائياً)
@export var flash_color: Color = Color(1.0, 0.9, 0.2, 1.0)
## قوة توهج وإشعاع اللون (كلما رفعته زاد السحر والإضاءة مع الـ WorldEnvironment)
@export var glow_intensity: float = 3.5
## سمك الخط الابتدائي قبل التلاشي (تم تصغيره ليصبح أنحف وأكثر احترافية بطلبك)
@export var start_width: float = 5.0
## مدة بقاء الفلاش في الشاشة (يتلاشى ببطء وبشكل ناعم)
@export var lifetime: float = 0.32

@export_category("Camera Shake")
## قوة اهتزاز الكاميرا الخفيفة جداً والناعمة عند الانطلاق
@export var shake_amount: float = 2.5

# متغيرات داخلية لحفظ نقاط الانطلاق والوصول للحركة الديناميكية
var start_point: Vector2
var end_point: Vector2
var timer: float = 0.0
var is_active: bool = false
var camera_ref: Camera2D = null
var current_power: float = 1.0 # لحفظ القوة الحالية للشحن

func _ready():
	# ضبط زوايا وأطراف حادة ومستقيمة تماماً مثل لقطات الأنمي والألعاب الاحترافية
	joint_mode = 1 # Miter
	begin_cap_mode = 2 # Square
	end_cap_mode = 2 # Square

func _process(delta):
	if not is_active: return
	
	timer -= delta
	if timer <= 0:
		# إعادة الكاميرا لوضعها الأصلي قبل حذف التأثير
		if is_instance_valid(camera_ref):
			camera_ref.offset = Vector2.ZERO
		clear_points()
		queue_free()
	else:
		# 1. تلاشي تدريجي ببطء ونعومة للشفافية والسمك معاً
		var progress = timer / lifetime
		modulate.a = progress
		
		# جعل السمك يعتمد على سمك البداية المضروب في قوة الشحن
		width = (start_width * current_power) * progress
		
		# 2. توليد الخط الرئيسي والخطوط الفرعية الصغيرة تلقائياً في كل إطار
		generate_lightning_with_branches(start_point, end_point, progress)
		
		# 3. اهتزاز الكاميرا الخفيف الذي يتلاشى مع وقت الفلاش
		if is_instance_valid(camera_ref):
			var current_shake = shake_amount * progress
			camera_ref.offset = Vector2(randf_range(-current_shake, current_shake), randf_range(-current_shake, current_shake))

## الدالة الرئيسية المعدلة التي يستدعيها اللاعب عند رفع إصبعه عن زر الـ Dash
func spawn_dark_bolt(start_pos: Vector2, end_pos: Vector2, charge_power: float = 1.0):
	start_point = start_pos
	end_point = end_pos
	timer = lifetime
	is_active = true
	
	# جعل الصاعقة أضعف قليلاً بحسب طلبك (مثلاً نأخذ 75% فقط من قوة الشحن الكلية للتحكم بالحجم)
	current_power = charge_power * 0.75
	
	# تطبيق اللون المضيء بحقن الـ RAW برمجياً ليشع فوراً
	default_color = flash_color * glow_intensity
	
	# البحث عن الكاميرا لعمل الاهتزاز الخفيف تلقائياً
	camera_ref = get_tree().current_scene.find_child("Camera2D", true, false)
	if not camera_ref:
		var player = get_tree().current_scene.find_child("CharacterBody2D", true, false)
		if player and player.has_node("Camera2D"):
			camera_ref = player.get_node("Camera2D")
			
	generate_lightning_with_branches(start_point, end_point, 1.0)
	
	# استدعاء الشرط المخفي لضرب الوحوش مستقبلاً بناءً على القوة الكاملة للشحن
	check_hidden_enemy_damage(start_pos, end_pos, charge_power)

## خوارزمية رسم الخط الرئيسي والخطوط والتشعبات الفرعية الصغيرة
func generate_lightning_with_branches(p_start: Vector2, p_end: Vector2, progress: float):
	clear_points()
	
	var distance = p_start.distance_to(p_end)
	var direction = (p_end - p_start).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)
	
	# تقسيم ذكي وحاد ومتباعد ليعطي شكل الزيجزاج الصاعق
	var segments = clamp(int(distance / 35.0), 5, 12)
	add_point(p_start)
	
	var side = 1.0
	var points_list: Array[Vector2] = [p_start]
	
	# بناء الخط الرئيسي
	for i in range(1, segments):
		var prog = float(i) / float(segments)
		var base_point = p_start + direction * (prog * distance)
		
		# تعرج حاد يتغير في كل إطار لأنميشن الطاقة النباضة (يتأثر بنسبة ضئيلة بالقوة ليعطي مدى أوسع)
		var jag_offset = randf_range(12.0, 24.0) * side * sin(prog * PI) * (1.0 + (current_power * 0.1))
		var final_point = base_point + perpendicular * jag_offset
		
		add_point(final_point)
		points_list.append(final_point)
		side *= -1.0
		
	add_point(p_end)
	points_list.append(p_end)
	
	queue_redraw()

func _draw():
	if not is_active or points.size() < 3: return
	
	var progress = timer / lifetime
	# جعل الخطوط الفرعية تتأثر بقوة الشحن الحالية وتتلاشى معها
	var branch_width = ((start_width * current_power) * 0.4) * progress
	
	# نمر على نقاط الخط الرئيسي ونصنع تشعبات عشوائية صغيرة
	for i in range(1, points.size() - 1):
		if randf() < 0.4:
			var branch_start = points[i]
			
			var random_dir = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
			var branch_length = randf_range(15.0, 35.0) * progress
			
			var branch_mid = branch_start + random_dir * (branch_length * 0.5) + Vector2(randf_range(-5, 5), randf_range(-5, 5))
			var branch_end = branch_mid + random_dir.rotated(randf_range(-0.5, 0.5)) * (branch_length * 0.5)
			
			draw_line(branch_start, branch_mid, default_color, branch_width)
			draw_line(branch_mid, branch_end, default_color, branch_width)

# =====================================================================
# --- الشرط المخفي لإلحاق الضرر بالوحوش مستقبلاً عند تفعيلهم ---
# =====================================================================
func check_hidden_enemy_damage(start: Vector2, end: Vector2, power: float):
	var space_state = get_world_2d().direct_space_state
	# إطلاق شعاع فحص يطابق تماماً خط الاندفاع والصاعقة
	var query = PhysicsRayQueryParameters2D.create(start, end)
	query.collide_with_areas = true
	query.collide_with_bodies = true
	
	var result = space_state.intersect_ray(query)
	
	# إذا اصطدم الشعاع بشيء ما في طريقة
	if result and result.has("collider"):
		var enemy = result["collider"]
		
		# الشرط المخفي: إذا كان الجسم المصاب ينتمي لمجموعة الوحوش أو يمتلك دالة استقبال ضرر
		if enemy.is_in_group("enemies") or enemy.has_method("take_damage"):
			var base_damage = 20.0
			var final_damage = base_damage * power # تزداد الضربة طردياً مع قوة شحن اللاعب
			
			enemy.take_damage(final_damage)
			print("🎯 الشرط المخفي تفرع! تم ضرب العدو بضرر مشحون قيمته: ", final_damage)
