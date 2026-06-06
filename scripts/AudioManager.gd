extends Node

var bus_music = "music"
var bus_sfx = "sfx"
const SAVE_PATH = "user://settings.cfg"

func _ready() -> void:
	# ننتظر قليلاً للتأكد من استقرار المحرك ثم نحمل
	await get_tree().process_frame
	load_settings()

func set_volume(bus_name: String, value: float):
	var bus_index = AudioServer.get_bus_index(bus_name)
	if bus_index != -1:
		if value <= 0.05:
			AudioServer.set_bus_mute(bus_index, true)
			AudioServer.set_bus_volume_db(bus_index, -80)
		else:
			AudioServer.set_bus_mute(bus_index, false)
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(value))
		
		print("AudioManager: تم تغيير مستوى ", bus_name, " إلى القيمة: ", value)
		save_settings()

func save_settings():
	var config = ConfigFile.new()
	var m_idx = AudioServer.get_bus_index(bus_music)
	var s_idx = AudioServer.get_bus_index(bus_sfx)
	
	var m_v = db_to_linear(AudioServer.get_bus_volume_db(m_idx))
	var s_v = db_to_linear(AudioServer.get_bus_volume_db(s_idx))
	
	# إذا كان مكتوم، نحفظ صفر صريح
	if AudioServer.is_bus_mute(m_idx): m_v = 0.0
	if AudioServer.is_bus_mute(s_idx): s_v = 0.0

	config.set_value("audio", "music_val", m_v)
	config.set_value("audio", "sfx_val", s_v)
	config.save(SAVE_PATH)
	print("AudioManager: تم حفظ القيم في الملف -> Music:", m_v, " SFX:", s_v)

func load_settings():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	if err == OK:
		var m_val = config.get_value("audio", "music_val", 0.8)
		var s_val = config.get_value("audio", "sfx_val", 0.8)
		print("AudioManager: تم تحميل القيم من الملف -> Music:", m_val, " SFX:", s_val)
		
		# تطبيق القيم بصمت (بدون إعادة استدعاء الحفظ لتجنب التكرار)
		apply_load(bus_music, m_val)
		apply_load(bus_sfx, s_val)
	else:
		print("AudioManager: لا يوجد ملف حفظ، تم استخدام الافتراضي.")

# دالة مساعدة للتحميل فقط
func apply_load(bus_name, value):
	var idx = AudioServer.get_bus_index(bus_name)
	if value <= 0.05:
		AudioServer.set_bus_mute(idx, true)
	else:
		AudioServer.set_bus_mute(idx, false)
		AudioServer.set_bus_volume_db(idx, linear_to_db(value))
