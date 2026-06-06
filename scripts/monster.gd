extends CharacterBody2D
@onready var timer: Timer = $Timer
@onready var die_: AudioStreamPlayer2D = $die_
@onready var director: RayCast2D = $director
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
# هذ المتغير لازم يكون في كل حاجة حاب نبدل لها الجاذبية
@export var dir_g=1
var dir_m=1
# متغيرا استطاعة الاستدار
var can_turn=false
const  SPEED=50
func _physics_process(delta: float) -> void:
	up_direction = Vector2.UP if dir_g == 1 else Vector2.DOWN
	# جاذبية 
	if not is_on_floor():
		velocity+=get_gravity()*delta*dir_g
	# حركة االوحش يمين ويسار
	velocity.x=SPEED*dir_m
	#تغير اتجاه الراي كاست بحسب المتغير التجاه
	if dir_m==1:
		animated_sprite_2d.flip_h=false
		director.target_position.x=8
	else:
		animated_sprite_2d.flip_h=true
		director.target_position.x=-8
	# تحديد الوضع جاذبية فوق او تحت على الانميشن
	if dir_g==1:
		animated_sprite_2d.flip_v=false
		director.target_position.y=18
	else:
		animated_sprite_2d.flip_v=true
		director.target_position.y=-18
	if dir_m>0:
		animated_sprite_2d.play("walk")
	move()
	move_and_slide()

func move():
	if is_on_floor():
		if (is_on_wall() or !director.is_colliding()) and can_turn:
			dir_m *= -1
			can_turn = false
		if !is_on_wall():
			can_turn = true
	pass
func die():
	$Timer.start()
	die_.play()
	set_physics_process(false) 
	animated_sprite_2d.visible = false  
	$CPUParticles2D.emitting = true
func _on_timer_timeout() -> void:
	queue_free()
	pass # Replace with function body.




func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("die") and body.name!="monster":
		body.die()
		die()
