extends RigidBody2D
@export var dir_g=1
func _physics_process(_delta: float) -> void:
	gravity_scale=dir_g
