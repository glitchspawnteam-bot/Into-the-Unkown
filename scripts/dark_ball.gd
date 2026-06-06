extends Area2D

@export var speed: float = 400.0          
@export var pull_strength: float = 350.0  
## أقصى طول للذيل بالبكسل لضمان عدم حدوث لاق
@export var max_trail_length: int = 15

var direction: Vector2 = Vector2.RIGHT

# --- [ربط عقدة الذيل بالسكريبت] ---
@onready var trail: Line2D = $Line2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	# جعل الذيل مستقل الحركة في العالم لكي يمتد خلف القذيفة بشكل صحيح
	if is_instance_valid(trail):
		trail.top_level = true
		trail.clear_points()

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	
	# --- [تحديث نقاط الذيل تلقائياً أثناء الطيران] ---
	if is_instance_valid(trail):
		# إضافة موقع الكرة الحالي كأحدث نقطة في الذيل
		trail.add_point(global_position)
		# إذا زاد طول الذيل عن الحد المسموح، نحذف أقدم نقطة من الخلف
		if trail.get_point_count() > max_trail_length:
			trail.remove_point(0)

func _process(delta: float) -> void:
	for body in get_overlapping_bodies():
		if body.is_in_group("enemies") or body.is_in_group("enemy"):
			var pull_dir = (global_position - body.global_position).normalized()
			if "velocity" in body:
				body.velocity = pull_dir * pull_strength
			else:
				body.global_position = body.global_position.move_toward(global_position, pull_strength * delta)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("map") or body.name == "TileMap" or body is TileMap:
		# قبل تدمير المقذوف نقوم بتدمير الذيل معه لكي لا يترك بقعاً في الهواء
		if is_instance_valid(trail): trail.queue_free()
		queue_free()

# في حال اختفت القذيفة خارج الشاشة
func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	if is_instance_valid(trail): trail.queue_free()
	queue_free()

# احفظ المشهد الآن باسم DarkBall.tscn في مجلد scenes الخاص بك
