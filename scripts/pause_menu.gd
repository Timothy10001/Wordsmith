extends CanvasLayer

var player_resource = load("res://assets/resources/Player.tres")
@onready var health = $TextureRect/MarginContainer/StatsContainer/Health
@onready var mana = $TextureRect/MarginContainer/StatsContainer/Mana
@onready var strength = $TextureRect/MarginContainer/StatsContainer/Strength
@onready var armor = $TextureRect/MarginContainer/StatsContainer/Armor
@onready var level = $TextureRect/MarginContainer/StatsContainer/Level
@onready var experience = $TextureRect/MarginContainer/StatsContainer/Experience
@onready var PauseMusic = $PauseMusic

func _ready():
	PauseMusic.stream = load("res://assets/sounds/music/pause_music.mp3")
	PauseMusic.play()


func _process(_delta):
	if State.current_area == "lobby":
		$TextureRect/MarginContainer/ButtonContainer/ExitToLobbyButton.visible = false
	else:
		$TextureRect/MarginContainer/ButtonContainer/ExitToLobbyButton.visible = true
	health.text = "%s/%s" % [player_resource.health, player_resource.max_health]
	mana.text = "%s/%s" % [player_resource.mana, player_resource.max_mana]
	strength.text = "%s" % player_resource.strength
	armor.text = "%s" % player_resource.initial_armor
	level.text = "%s" % player_resource.level
	experience.text = "%s/%s" % [player_resource.experience, player_resource.experience_required]

func _on_resume_button_pressed():
	Input.action_press("resume")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("resume")


func _on_options_button_pressed():
	Input.action_press("options")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("options")


func _on_items_button_pressed():
	Input.action_press("show_inventory")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("show_inventory")


func _on_exit_to_lobby_button_pressed():
	State.was_in_mission = true
	PauseMusic.stop()
	Global.back_to_lobby.emit()


func _on_save_and_exit_button_pressed():
	Input.action_press("show_confirmation")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("show_confirmation")
	
