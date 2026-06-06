extends Camera2D

# متغيرات الاهتزاز
var shake_amount = 0.0
var default_offset = Vector2.ZERO

# متغيرات الـ Zoom الأسطوري
var target_zoom = Vector2(1.0, 1.0) # الـ Zoom المستهدف الذي نريد الوصول له
var zoom_speed = 5.0 # سرعة سلاسة الحركة (كلما زادت كانت الحركة أسرع)

func _ready():
	default_offset = offset
	# حفظ الـ Zoom الحالي للكاميرا كـ Zoom افتراضي
	target_zoom = zoom

func _process(delta):
	# 1. التحكم في سلاسة الـ Zoom (هنا السحر السينمائي)
	zoom = zoom.lerp(target_zoom, zoom_speed * delta)
	
	# 2. التحكم في الاهتزاز العشوائي
	if shake_amount > 0:
		offset.x = default_offset.x + randf_range(-shake_amount, shake_amount)
		offset.y = default_offset.y + randf_range(-shake_amount, shake_amount)
		shake_amount = move_toward(shake_amount, 0.0, delta * 10.0) 
	else:
		offset = default_offset

# دالة لتشغيل الاهتزاز والـ Zoom معاً بصورة فخمة
func trigger_boss_entrance(shake_intensity: float, zoom_in_factor: float, duration_before_return: float):
	# 1. تشغيل الاهتزاز
	shake_amount = shake_intensity
	
	# 2. عمل زووم تقريب قوي فجأة (مثلاً 1.5 أو 1.8 حسب رغبتك)
	target_zoom = Vector2(zoom_in_factor, zoom_in_factor)
	
	# زووم سريع جداً في البداية ليعطي صدمة بصرية
	zoom_speed = 15.0 
	
	# 3. الانتظار قليلاً ثم إرجاع الكاميرا لوضعها الطبيعي ببطء وبشكل ناعم
	await get_tree().create_timer(duration_before_return).timeout
	
	target_zoom = Vector2(1.0, 1.0) # العودة للحجم الطبيعي
	zoom_speed = 3.0 # العودة ببطء شديد ليعطي تأثيراً درامياً فخماً
