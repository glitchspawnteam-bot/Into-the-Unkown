extends Node2D

@onready var paragraph = $Pargraphe
@onready var typing_sound = $Pargraphe/AudioStreamPlayer2D
@onready var title: RichTextLabel = $Title


var can = false
var has = false
var game_title = "Gravity_Fills"
var text_to_write = " Welcome to my game, thanks you for starting to play"
var text_to_write_ar = "مرحبًا بك في لعبتي، شكرًا لك على البدء في اللعب"

@export var title_speed = 0.05
@export var paragraph_speed = 0.05

var font_ar = preload("res://Fonts/arabic.ttf")
@onready var name_input = $CanvasLayer2/Panel/name_realy
var first_time=true
func _ready():
	var config = ConfigFile.new()
	if config.load("user://save.cfg") == OK:
		first_time = config.get_value("game", "seen_intro", false)
	
		if first_time==true:
			get_tree().change_scene_to_file("res://scenes/main_select.tscn")
			return
	$CanvasLayer2.show()
	
		
	
	LanguageManager.current_lang=-1
	name_input.text_direction = Control.TEXT_DIRECTION_AUTO
	$CanvasLayer2/Panel/eror.hide()
	# إعدادات أولية سريعة جداً لا تسبب لاق
	title.bbcode_enabled = true
	paragraph.bbcode_enabled = true
	title.text = ""
	paragraph.text = ""
	
	if typing_sound:
		typing_sound.volume_db = -12
		
	# إخفاء أزرار التالي في البداية
	if has_node("next"): $next.hide()
	if has_node("next_ar"): $next_ar.hide()
	
	# أهم سطر: السماح للمحرك برسم الواجهة أولاً ثم بدء المنطق
	await get_tree().process_frame
	
	# إذا كنت تريد إظهار قائمة اختيار اللغة فوراً:
	$CanvasLayer2/AnimationPlayer.play("sh")

func run():
	if not is_inside_tree(): return
	
	# بدء الإنترو (العنوان)
	await show_intro()
	
	# بدء كتابة الفقرة
	await write_paragraph()
	
	# ننتظر قليلاً ثم نُفعل إمكانية الضغط
	await get_tree().create_timer(0.5).timeout
	can = true
	
	# إظهار زر التالي بناءً على اللغة المختارة
	if LanguageManager.current_lang == 0:
		await get_tree().create_timer(1.5).timeout # قللت الوقت من 5 إلى 1.5 لسرعة الاستجابة
		if has_node("next"): $next.show()
	else:
		await get_tree().create_timer(1.5).timeout
		if has_node("next_ar"): $next_ar.show()

func show_intro():
	#bg.color = Color.BLACK
	title.text = game_title 
	title.visible_characters = 0
	
	var total = title.text.length()
	for i in range(1, total + 1):
		title.visible_characters = i
		title.modulate = Color(1,1,1,0.5)
		await get_tree().create_timer(title_speed).timeout
		title.modulate = Color(1,1,1,1)
	
	# تأثير الوميض (Glow) - قللت عدد التكرار والوقت لتقليل الانتظار
	for i in range(2): 
		title.modulate = Color(1,1,1,0.3)
		await get_tree().create_timer(0.2).timeout
		title.modulate = Color(1,1,1,1)
		await get_tree().create_timer(0.2).timeout
	
	await get_tree().create_timer(0.5).timeout
	return true

func write_paragraph():
	var current_text = ""
	
	if LanguageManager.current_lang == 0:
		paragraph.text = text_to_write
		current_text = text_to_write
	else:
		paragraph.add_theme_font_override("normal_font", font_ar)
		paragraph.text_direction = Control.TEXT_DIRECTION_RTL
		paragraph.text = text_to_write_ar
		current_text = text_to_write_ar

	paragraph.visible_characters = 0
	var total = current_text.length()
	
	await get_tree().create_timer(0.5).timeout
	
	if typing_sound:
		typing_sound.play()
	
	for i in range(1, total + 1):
		paragraph.visible_characters = i
		var current_char = current_text[i-1]
		
		# التوقف عند علامات الترقيم
		if current_char in [".", "!", "؟", "،", ","]:
			if typing_sound: typing_sound.stream_paused = true
			await get_tree().create_timer(0.3).timeout
			if typing_sound: typing_sound.stream_paused = false
		else:
			await get_tree().create_timer(paragraph_speed).timeout
	
	if typing_sound:
		typing_sound.stop()
	return true

# --- إشارات الأزرار ---

func _on_arabic_pressed() -> void:
	LanguageManager.current_lang = 1
	$CanvasLayer2/Panel/Arabic.modulate = Color(1, 1, 1, 1) 
	# جعل زر الإنجليزية باهت أو بلون مختلف (رمادي مثلاً)
	$CanvasLayer2/Panel/English.modulate = Color(0.5, 0.5, 0.5, 1) 
	$CanvasLayer2/Panel/eror.hide()

func _on_english_pressed() -> void:
	LanguageManager.current_lang = 0
	
	$CanvasLayer2/Panel/English.modulate = Color(1, 1, 1, 1)
	# جعل زر العربية باهت
	$CanvasLayer2/Panel/Arabic.modulate = Color(0.5, 0.5, 0.5, 1)
	$CanvasLayer2/Panel/eror.hide()

func _on_next_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/The History.tscn")

func _on_next_ar_pressed() -> void: # تأكد من ربط هذا الزر أيضاً
	get_tree().change_scene_to_file("res://scenes/The History.tscn")


func _on_save_pressed():
	var save = ConfigFile.new()
	save.set_value("game", "seen_intro", true)
	save.save("user://save.cfg")
	var name_text = $CanvasLayer2/Panel/name_realy.text.strip_edges()
	var error_label = $CanvasLayer2/Panel/eror # تأكد من اسم عقدة الخطأ عندك
	if LanguageManager.current_lang == -1:
		error_label.text = "اختر اللغة / Select Language"
		error_label.show()
		return # توقف هنا ولا تكمل الحفظ
	if name_text.length() < 3:
		error_label.text = "The name must be 3 letters or more"
		error_label.show()
		return # توقف هنا ولا تكمل الحفظ
	error_label.hide() # إخفاء رسالة الخطأ لأن كل شيء سليم
	LanguageManager.save_language(LanguageManager.current_lang)
	LanguageManager.save_player_name(name_text)
	LanguageManager.apply_translations(get_tree().current_scene)
	print("تم الحفظ بنجاح، استدعاء الدالة التالية...")
	_after_save_action()
func _after_save_action():
	$CanvasLayer2/Panel.hide()
	run()
	pass
	# الانتقال للمشهد التالي
	




# مسار عقدة الكتابة - تأكد أن الاسم مطابق لما عندك


func _on_name_realy_text_changed(new_text: String) -> void:
	# 1. حفظ مكان المؤشر الحالي
	var old_caret_pos = name_input.caret_column
	
	# 2. تنظيف النص (إبقاء English letters + Spaces فقط)
	var filtered_text = ""
	for letter in new_text:
		# التحقق من الحروف الإنجليزية الصغيرة والكبيرة والمسافة
		if (letter >= "a" and letter <= "z") or (letter >= "A" and letter <= "Z") or letter == " ":
			filtered_text += letter
	
	# 3. تحديث النص فقط إذا وجد حرف غير مسموح به
	if new_text != filtered_text:
		name_input.text = filtered_text
		# إرجاع المؤشر لمكانه (ناقص 1 لأننا منعنا حرفاً)
		name_input.caret_column = old_caret_pos - 1

# هذه الدالة تجعل أي ضغطة ماوس خارج الصندوق تلغي التركيز (Focus)
func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		var current_focus = get_viewport().gui_get_focus_owner()
		
		# إذا ضغطنا وكان هناك تركيز على صندوق النص
		if current_focus == name_input:
			# نتحقق هل الضغطة كانت خارج مساحة صندوق النص
			if not name_input.get_global_rect().has_point(event.global_position):
				name_input.release_focus()

# اختياري: إذا أردت تنفيذ شيء عند دخول أو خروج التركيز
func _on_name_realy_focus_entered() -> void:
	print("بدأ المستخدم الكتابة...")

func _on_name_realy_focus_exited() -> void:
	print("خرج المستخدم من صندوق النص.")
