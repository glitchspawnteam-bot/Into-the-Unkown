extends CharacterBody2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var dir_g=1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var is_floor=is_grav(dir_g)
	if !is_floor:
		velocity+=get_gravity()*delta*dir_g
	if dir_g==1:
		sprite_2d.flip_v=false
		collision_shape_2d.position.y=3.25
	else:
		sprite_2d.flip_v=true
		collision_shape_2d.position.y=-3.25
	move_and_slide()




func _on_die_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("die"):
		body.die()
	pass
# البحث عن هل هو في الجاذبية الصحيحة لتصحيح التجاه
func is_grav(g):
	if is_on_floor() and g==1:
		return true
	elif is_on_ceiling() and g==-1:
		return true
	else:
		return false
