extends Area2D
@export var coin_id:String
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready() -> void:
	coin_id=self.name
	if Gm.data_save["levels"][get_tree().current_scene.level_id]["collected"].has(coin_id):
		queue_free()
	else:
		get_tree().current_scene.coins_collected = 0
func _on_body_entered(body: Node2D) -> void:
	if body.name=="player":
		$collect.play()
		$CollisionShape2D.queue_free()
		get_tree().current_scene._on_coin_collected(coin_id)
		fade()
func fade():
		var tween=create_tween()
		tween.tween_property(self,"position",position+Vector2(0,-20),0.2)
		tween.tween_property(self,"modulate:a",0.0,0.5)
		tween.tween_callback(self.queue_free)
