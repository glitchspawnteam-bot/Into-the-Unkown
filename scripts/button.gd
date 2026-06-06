extends Button

@export var level_num=1

func _ready() -> void:
	level_num=int(self.text)



func _process(delta: float) -> void:
	var unlocked = Gm.data_save["un_locked"]
	var data = Gm.data_save["levels"][str(level_num)]
	var coins = Gm.data_save["levels"][str(level_num)]["coins"]
	if Gm.is_open(level_num):
		if level_num!=20:
			if level_num==unlocked and coins==0:
				set_button_color(Color("3a3a40"))
				return
			elif  level_num<unlocked and coins==2:
				set_button_color(Color("2e8b57"))
				return
			elif  level_num<unlocked and coins!=2:
				set_button_color(Color("556b2f"))
				return
			else:
				set_button_color(Color("1c1c1e"))
				return
		else:
			set_button_color(Color("242b0aff"))

func _on_pressed() -> void:
	print(level_num)
	if Gm.is_open(level_num):
		add_theme_font_override("font",LanguageManager.get_font())
		if LanguageManager.current_lang==0:
			Trnsitionlayer.change_scean(level_num,"go to your grave")
		else:
			Trnsitionlayer.change_scean(level_num,"اذهب إلى قبرك")
func set_button_color(color: Color):
	var style = get_theme_stylebox("normal").duplicate()
	if style is StyleBoxFlat:
		style.bg_color = color
		add_theme_stylebox_override("normal", style)
