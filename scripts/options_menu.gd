class_name OptionsMenu
extends Control

@onready var MusicSlider = $MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/Music
@onready var SFXSlider = $MarginContainer/MarginContainer/HBoxContainer/VBoxContainer/SFX
@onready var PauseMusic = $PauseMusic
@onready var SFX = $SFX
@onready var text_edit = $MarginContainer/MarginContainer/VBoxContainer2/VBoxContainer/TextEdit
@onready var TTSOptions = $MarginContainer/MarginContainer/VBoxContainer2/VBoxContainer/TTSOptions
@onready var SpeakButton = $MarginContainer/MarginContainer/VBoxContainer2/VBoxContainer/SpeakButton

var main_menu_scene = load("res://scenes/main_menu.tscn")

var music_bus_index
var sfx_bus_index

func _process(_delta):
	if DisplayServer.tts_is_speaking():
		SpeakButton.disabled = true
	else:
		SpeakButton.disabled = false

func _ready():
	init_voices()
	init_sliders()
	#plays pause music
	if get_parent().name == "root":
		PauseMusic.stream = load("res://assets/sounds/music/pause_music.mp3")
		PauseMusic.play()

func init_voices():
	for voice in Global.Voices:
		TTSOptions.add_item(voice["name"])


func init_sliders():
	music_bus_index = AudioServer.get_bus_index("Music")
	sfx_bus_index = AudioServer.get_bus_index("SFX")
	
	MusicSlider.value = db_to_linear(AudioServer.get_bus_volume_db(music_bus_index))
	SFXSlider.value = db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index))

func _on_music_value_changed(value):
	if music_bus_index:
		AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(value))


func _on_music_drag_ended(_value_changed):
	MusicSlider.release_focus()


func _on_sfx_value_changed(value):
	if sfx_bus_index:
		AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(value))


func _on_sfx_drag_ended(_value_changed):
	SFX.play()
	SFXSlider.release_focus()


func _on_speak_button_pressed():
	var text = ""
	if text_edit.text == "":
		text = text_edit.placeholder_text
	else:
		text = text_edit.text
	var VoiceID = TTSOptions.get_selected_id()
	if text:
		DisplayServer.tts_speak(text, Global.Voices[VoiceID]["id"])


func _on_back_button_pressed():
	Input.action_press("back_to_pause_menu")
	await get_tree().create_timer(0.1).timeout
	Input.action_release("back_to_pause_menu")
	if get_parent().name == "root":
		PauseMusic.stop()
		PauseMusic.stream = null
		get_tree().change_scene_to_packed(main_menu_scene)
