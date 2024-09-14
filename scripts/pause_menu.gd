extends CanvasLayer

var player_resource = load("res://assets/resources/Player.tres")
@onready var health = $TextureRect/MarginContainer/StatsContainer/Health
@onready var mana = $TextureRect/MarginContainer/StatsContainer/Mana
@onready var strength = $TextureRect/MarginContainer/StatsContainer/Strength
@onready var level = $TextureRect/MarginContainer/StatsContainer/Level
@onready var experience = $TextureRect/MarginContainer/StatsContainer/Experience


func _ready():
	health.text = "%s/%s" % [player_resource.health, player_resource.max_health]

func _on_resume_button_pressed():
	Input.action_press("resume")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("resume")


func _on_options_button_pressed():
	pass # Replace with function body.


func _on_items_button_pressed():
	Input.action_press("show_inventory")
	await get_tree().create_timer(0.05).timeout
	Input.action_release("show_inventory")


func _on_exit_to_lobby_button_pressed():
	pass # Replace with function body.


func _on_exit_game_button_pressed():
	pass # Replace with function body.
