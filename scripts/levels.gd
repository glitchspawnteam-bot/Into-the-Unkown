extends Node2D


@export var level_id: String 
var collected=[]
var coins_collected = 0
func _ready() -> void:
	
		

	showed()
	level_id=self.name
	if Gm.data_save["levels"][level_id]["coins"]!=0:
		coins_collected = Gm.data_save["levels"][level_id]["coins"]
	else:
		coins_collected=0
func _on_coin_collected(coin_id):
	coins_collected += 1
	collected.append(coin_id)
	# تحديث واجهة المستخدم (UI) هنا
func _on_level_finished():
	Gm.complete_level(level_id, coins_collected,collected)

func showed():
	if level_id=="20":
		
		var animated_sprite_2d: AnimatedSprite2D = $player/AnimatedSprite2D
		var animation_player: AnimationPlayer = $player/AnimationPlayer
		Music.switch()
		animation_player.play("die")
		animated_sprite_2d.play("animation run")
		await animation_player.animation_finished
		animated_sprite_2d.play("die")
		await  animated_sprite_2d.animation_finished
		$player/AnimationPlayer.play("boss_intro")
		$world/Camera2D.trigger_boss_entrance(25.0,3.5,3)
		
		await  get_tree().create_timer(5.5).timeout
		if LanguageManager.current_lang==0:
			Gm.come=true
			TrnBack2.change_scean("coming soon!!","res://scenes/main_select.tscn")
		else:
			TrnBack2.change_scean("قريبا!!","res://scenes/main_select.tscn")
