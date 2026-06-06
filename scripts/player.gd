extends CharacterBody2D

# ==========================================================
# تجميع وتنسيق خصائص اللاعب في مجموعات (Inspector Groups)
# ==========================================================

@export_group("خصائص اللاعب الأساسية", "base_")
## السرعة العادية للمشي والجري
@export var base_speed: float = 200.0
## قوة القفز (قيمة سالبة للصعود لأعلى)
@export var base_jump_velocity: float = -300.0
## أقصى سرعة أفقية مسموح بها للاعب
@export var base_max_velocity: float = 150.0
## قوة دفع الصناديق والأجسام الفيزيائية
@export var base_push_force: float = 100.0
## قيمة الجاذبية المؤثرة على اللاعب
@export var base_gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

@export_group("إعدادات الهجوم المظلم", "dark_attack_")
## تفعيل أو إلغاء مهارة إطلاق الكرة المظلمة
@export var dark_attack_enable: bool = true
## ملف مشهد الكرة المظلمة tscn
@export var dark_attack_scene = preload("res://scenes/dark_ball.tscn")
## الوقت المستغرق لإعادة شحن ضربة الكرة المظلمة (Cooldown)
@export var dark_attack_cooldown: float = 0.5

@export_group("إعدادات أثر الشبح", "ghost_trail_")
## تفعيل أو إلغاء ظهور أطياف الشبح أثناء الاندفاع
@export var ghost_trail_enable: bool = true
## لون طيف الشبح الخلفي
@export var ghost_trail_color: Color = Color(0.1, 0.1, 0.2, 0.6)
## وقت إعادة شحن اندفاع الشبح
@export var ghost_trail_cooldown: float = 0.5

@export_group("تفعيل وإبطال القدرات التلقائية", "ability_")
## تفعيل أو إلغاء مهارة الاندفاع المظلم (Dash) بالكامل
@export var ability_enable_dark_dash: bool = true
## تفعيل أو إلغاء خاصية تلاشي واختفاء اللاعب عند التوقف
@export var ability_enable_shadow_disappear: bool = true

@export_group("إعدادات الشحن والاندفاع المظلم", "dash_")
## ملف مشهد الصاعقة المظلمة tscn
const DARK_LIGHTNING_SCENE = preload("res://scenes/Lightning.tscn")
## سرعة انطلاق الاندفاع (الـ Dash)
@export var dash_speed: float = 800.0
## وقت إعادة شحن الاندفاع المظلم بعد استخدامه
@export var dash_cooldown: float = 0.6
## تفعيل أو إلغاء ميزة التحميل (الشحن) قبل الاندفاع
@export var dash_enable_charging: bool = true
## أقصى مدة يمكن للاعب شحن الضربة فيها (بالثواني)
@export var dash_max_charge_time: float = 2.0  
## الحد الأدنى لوقت الضغط على الزر ليتم احتسابه كشحن
@export var dash_min_charge_time: float = 0.15  

@export_group("إعدادات تلاشي الظل المفقود", "shadow_")
## الوقت المستغرق بالثواني ليختفي اللاعب تماماً ويموت عند التوقف أو الشحن
@export var shadow_time_to_disappear: float = 3.5

@export_group("إعدادات بقايا الشبح", "ghost_remnant_")
## تفعيل أو إلغاء ترك نسخة شبحية مكان موت اللاعب
@export var ghost_remnant_enable: bool = true
## قوة جاذبية الشبح المتروك لجذب اللاعب (تعمل فقط عند دخول منطقة الشبح)
@export var ghost_remnant_gravity_strength: float = 10.0
## مدة بقاء الشبح في الخريطة بالثواني قبل أن يختفي تلقائياً
@export var ghost_remnant_lifespan: float = 5.0

# ==========================================================
# المتغيرات الداخلية (مخفية عن الـ Inspector)
# ==========================================================
var dir_p = 1
var is_floor = false
var can_attack: bool = true
var can_ghost_dash: bool = true
var can_dash: bool = true
var is_dashing: bool = false
var inactivity_timer: float = 0.0
var is_disappearing: bool = false
var fade_tween: Tween = null 
var is_charging_dash: bool = false
var charge_time: float = 0.0
var charge_power: float = 1.0 

# متغيرات نظام بقايا الشبح
var is_ghost_active: bool = false
var is_player_inside_ghost: bool = false
var ghost_timer: float = 0.0

static var last_ghost_position: Vector2 = Vector2.ZERO
static var is_ghost_waiting: bool = false

@onready var ghost_area: Area2D = $Area2D
@onready var sprite = $AnimatedSprite2D
@onready var coyote_timer = $"Cayout time"
@onready var jump_sound: AudioStreamPlayer2D = $Jumpsound
@onready var particles: CPUParticles2D = $CPUParticles2D2
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var g: AudioStreamPlayer2D = $g
@onready var die_s: AudioStreamPlayer2D = $die_s
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var joystik: Area2D = $ui_control/control/Joystik
@onready var camera: Camera2D = $Camera2D

func _ready() -> void:
	LanguageManager.apply_translations(self)
	inactivity_timer = shadow_time_to_disappear
	
	if not InputMap.has_action("shoot_lightning"):
		InputMap.add_action("shoot_lightning")
		
	if is_instance_valid(ghost_area):
		# ربط دوال دخول وخروج اللاعب من منطقة الشبح
		if not ghost_area.body_entered.is_connected(_on_ghost_area_body_entered):
			ghost_area.body_entered.connect(_on_ghost_area_body_entered)
		if not ghost_area.body_exited.is_connected(_on_ghost_area_body_exited):
			ghost_area.body_exited.connect(_on_ghost_area_body_exited)
			
		# حل الجلتش الأساسي: منع ظهور الشبح نهائياً عند تحميل اللعبة لأول مرة
		if ghost_remnant_enable and is_ghost_waiting and last_ghost_position != Vector2.ZERO:
			ghost_area.top_level = true 
			ghost_area.global_position = last_ghost_position
			ghost_area.visible = true
			ghost_area.monitoring = true
			ghost_area.monitorable = true
			is_ghost_active = true
			ghost_timer = ghost_remnant_lifespan # بدء مؤقت بقاء الشبح
		else:
			# إخفاء وتعطيل الشبح تماماً عند البداية لتجنب ظهور السبرايت مع اللاعب
			ghost_area.visible = false
			ghost_area.monitoring = false
			ghost_area.monitorable = false
			is_ghost_active = false
			is_player_inside_ghost = false

func _physics_process(delta):
	if Input.is_action_just_pressed("dark_attack") and can_attack and dark_attack_enable:
		launch_dark_attack()
	
	if ability_enable_dark_dash and can_dash:
		if dash_enable_charging:
			if Input.is_action_just_pressed("shoot_lightning"):
				is_charging_dash = true
				charge_time = 0.0
				charge_power = 1.0
				
			if Input.is_action_pressed("shoot_lightning") and is_charging_dash:
				charge_time += delta
				charge_power = 1.0 + (clamp(charge_time, 0.0, dash_max_charge_time) / dash_max_charge_time) * 2.0
				if sprite.material and sprite.material is ShaderMaterial:
					sprite.material.set_shader_parameter("charge_amount", clamp(charge_time / dash_max_charge_time, 0.0, 1.0))

			if Input.is_action_just_released("shoot_lightning") and is_charging_dash:
				is_charging_dash = false
				if charge_time >= dash_min_charge_time:
					custom_dash_call(charge_power)
				else:
					custom_dash_call(1.0)
		else:
			if Input.is_action_just_pressed("shoot_lightning"):
				custom_dash_call(1.0)

	if Input.is_action_just_pressed("dash_ghost_mode") and can_ghost_dash and ghost_trail_enable:
		custom_ghost_dash_call()
		
	if is_on_wall() and not is_on_floor():
		velocity.x = 0
	if Gm.is_open(Gm.MAX_LVL) and Gm.data_save["total"] == 36:
		sprite.modulate = Color(10,10,10,1)
		
	up_direction = Vector2.UP if dir_p == 1 else Vector2.DOWN
	
	if not is_on_floor() and not is_dashing:
		velocity.y += base_gravity * delta * dir_p
	else:
		is_floor = true
		
	var joy_direction = joystik.get_velo()
	
	if not is_dashing:
		if is_on_floor() and abs(joy_direction.y) > abs(joy_direction.x) * 2:
			velocity.x = move_toward(velocity.x, 0, base_speed) 
		else:
			if joy_direction.x:
				velocity.x = joy_direction.x * base_speed
			else:
				velocity.x = move_toward(velocity.x, 0, base_speed)
		
		if joy_direction.x > 0:
			sprite.flip_h = false
		elif joy_direction.x < 0:
			sprite.flip_h = true

	if Input.is_action_just_pressed("g") and is_floor == true and not is_dashing:
		g.play()
		dir_p *= -1
		is_floor = false
		
	if dir_p == 1:
		sprite.flip_v = false
		collision_shape_2d.position.y = 4.27
		particles.position.y = 17
		particles.gravity.y = -40
	else:
		sprite.flip_v = true
		collision_shape_2d.position.y = -4.333
		particles.position.y = -17
		particles.gravity.y = 40
		
	update_animations()
	
	var was_on_floor = is_on_floor()

	if is_on_floor() and abs(joy_direction.y) > 0.5:
		var target_offset_y = joy_direction.y * 30.0
		camera.offset.y = lerp(camera.offset.y, target_offset_y, 5.0 * delta)
	else:
		camera.offset.y = lerp(camera.offset.y, 0.0, 5.0 * delta)
		
	# ----------------------------------------------------
	# تحديث نظام الشبح: السحب الفيزيائي + نظام مدة البقاء
	# ----------------------------------------------------
	if is_ghost_active and is_instance_valid(ghost_area):
		# 1. نظام مؤقت مدة بقاء الشبح (Lifetime)
		ghost_timer -= delta
		if ghost_timer <= 0.0:
			collect_ghost_remnant() # إخفاء الشبح وتدميره عند انتهاء الوقت
			
		# 2. نظام السحب الفيزيائي (يعمل فقط وحصرياً عند دخول الـ Area2D)
		elif is_player_inside_ghost and ghost_remnant_gravity_strength > 0:
			var direction_to_ghost = global_position.direction_to(ghost_area.global_position)
			velocity += direction_to_ghost * ghost_remnant_gravity_strength * delta * 100
	# ----------------------------------------------------
		
	move_and_slide() 
	var is_on_floor_now = is_on_floor()
	
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor_now or not coyote_timer.is_stopped():
			velocity.y = base_jump_velocity * dir_p
			jump_sound.play()
			particles.emitting = true

	if was_on_floor and not is_on_floor_now and (velocity.y * dir_p) >= 0:
		coyote_timer.start()

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collision_box = collision.get_collider()
		if collision_box.is_in_group("box") and abs(collision_box.get_linear_velocity().x) < base_max_velocity:
			collision_box.apply_central_impulse(collision.get_normal() * -base_push_force)

	if ability_enable_shadow_disappear:
		custom_disappear_call(delta)

func update_animations():
	if not is_on_floor():
		var relative_velocity_y = velocity.y * dir_p
		if relative_velocity_y < -100:
			sprite.play("jump_rise")
			sprite.offset.y = 2 if dir_p == 1 else -2 
		elif relative_velocity_y > 100:
			sprite.play("fall")
			sprite.offset.y = 0 
		else:
			sprite.play("jump_airborn")
			sprite.offset.y = 4 if dir_p == 1 else -4 
	else:
		if velocity.x != 0:
			sprite.play("run")
		else:
			sprite.play("idle")
		sprite.offset.y = 0

func die():
	if ghost_remnant_enable and is_instance_valid(ghost_area) and not is_ghost_waiting:
		last_ghost_position = global_position
		is_ghost_waiting = true

	set_physics_process(false) 
	if is_instance_valid(collision_shape_2d):
		collision_shape_2d.queue_free()
		
	if sprite.sprite_frames.has_animation("die"):
		cpu_particles_2d.emitting = true
		sprite.play("die")
		die_s.play()
		
	await sprite.animation_finished
	$ui_control.show_death_screen()

func camera_change():
	set_process(false)
	set_physics_process(false)
	$ui_control/PauseMenu.hide()
	$ui_control/death_screen.hide()
	$ui_control/control.hide()
	$AnimationPlayer.play("camer")
	await $AnimationPlayer.animation_finished
	hide()

func custom_dash_call(p_charge_power: float):
	is_dashing = true
	can_dash = false
	
	if sprite.material and sprite.material is ShaderMaterial:
		sprite.material.set_shader_parameter("charge_amount", 0.0)
	
	var dash_dir = 1.0
	if sprite.flip_h:
		dash_dir = -1.0
		
	var start_position = global_position
	velocity.x = dash_dir * dash_speed
	velocity.y = 0 
	
	await get_tree().create_timer(0.12).timeout
	
	var end_position = global_position
	is_dashing = false
	velocity.x = 0
	
	if DARK_LIGHTNING_SCENE:
		var lightning = DARK_LIGHTNING_SCENE.instantiate()
		get_parent().add_child(lightning)
		if lightning.has_method("spawn_dark_bolt"):
			lightning.spawn_dark_bolt(start_position, end_position, p_charge_power)
	
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true

func custom_disappear_call(delta):
	var joy_direction = joystik.get_velo()
	
	var is_player_actually_moving = abs(velocity.x) > 5.0 or abs(velocity.y) > 5.0
	var is_moving_by_joystick = abs(joy_direction.x) > 0.1 or abs(joy_direction.y) > 0.1
	
	if not is_moving_by_joystick and not is_player_actually_moving and not is_dashing:
		if not is_disappearing:
			is_disappearing = true
			if fade_tween: fade_tween.kill()
			fade_tween = create_tween()
			fade_tween.tween_property(sprite, "modulate:a", 0.0, shadow_time_to_disappear)
			fade_tween.tween_callback(die) 
	else:
		if is_disappearing:
			is_disappearing = false
			if fade_tween: fade_tween.kill()
			sprite.modulate.a = 1.0

# عند دخول اللاعب إلى منطقة تصادم الشبح الـ Area2D
func _on_ghost_area_body_entered(body: Node2D):
	if is_ghost_active and (body == self or body.name == "player"):
		is_player_inside_ghost = true
		# إذا لم تكن هناك قوة جذب، يتم تجميع الشبح فوراً بمجرد اللمس العادي
		if ghost_remnant_gravity_strength <= 0:
			collect_ghost_remnant()

# عند خروج اللاعب من منطقة تصادم الشبح الـ Area2D
func _on_ghost_area_body_exited(body: Node2D):
	if is_ghost_active and (body == self or body.name == "player"):
		is_player_inside_ghost = false

func collect_ghost_remnant():
	is_ghost_active = false
	is_ghost_waiting = false
	is_player_inside_ghost = false
	last_ghost_position = Vector2.ZERO
	
	if is_instance_valid(ghost_area):
		ghost_area.visible = false
		ghost_area.monitoring = false 
		ghost_area.monitorable = false

func spawn_dash_ghost():
	if not ghost_trail_enable or not is_instance_valid(sprite): return
	
	var ghost: AnimatedSprite2D = AnimatedSprite2D.new()
	ghost.sprite_frames = sprite.sprite_frames
	ghost.animation = sprite.animation
	ghost.frame = sprite.frame
	ghost.flip_h = sprite.flip_h
	ghost.flip_v = sprite.flip_v
	ghost.offset = sprite.offset
	
	ghost.global_position = global_position
	ghost.modulate = ghost_trail_color
	
	get_parent().add_child(ghost)
	
	var tween = create_tween()
	tween.tween_property(ghost, "modulate:a", 0.0, 0.25)
	tween.tween_callback(ghost.queue_free)

func custom_ghost_dash_call():
	is_dashing = true
	can_ghost_dash = false
	
	var dash_dir = 1.0
	if sprite.flip_h:
		dash_dir = -1.0
		
	velocity.x = dash_dir * dash_speed
	velocity.y = 0 
	
	spawn_dash_ghost()
	await get_tree().create_timer(0.04).timeout
	spawn_dash_ghost()
	await get_tree().create_timer(0.04).timeout
	spawn_dash_ghost()
	await get_tree().create_timer(0.04).timeout
	
	is_dashing = false
	velocity.x = 0
	
	await get_tree().create_timer(ghost_trail_cooldown).timeout
	can_ghost_dash = true

func launch_dark_attack() -> void:
	if not dark_attack_enable or not dark_attack_scene: return
	
	can_attack = false
	var ball = dark_attack_scene.instantiate()
	
	var attack_dir = Vector2.RIGHT
	if sprite.flip_h:
		attack_dir = Vector2.LEFT
		
	ball.global_position = global_position
	ball.direction = attack_dir
	
	get_parent().add_child(ball)
	
	await get_tree().create_timer(dark_attack_cooldown).timeout
	can_attack = true
