extends Area2D



var body_in_zone=[]
var player_enside=false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("g") and player_enside :
		if len(body_in_zone)!=0:
			%CPUParticles2D.emitting=true
			for body in body_in_zone:
				body.dir_g*=-1


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("gravity") and !body_in_zone.has(body):
		body_in_zone.append(body)

func _on_body_exited(body: Node2D) -> void:
	if body_in_zone.has(body):
		body_in_zone.erase(body)
	pass # Replace with function body.


func _on_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name=="play":
		player_enside=true



func _on_area_shape_exited(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.name=="play":
		player_enside=false
