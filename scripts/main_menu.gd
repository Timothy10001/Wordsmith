class_name MainMenu
extends Control


@onready var start_button = $MarginContainer/HBoxContainer/VBoxContainer/Start_Button as Button
@onready var exit_button = $MarginContainer/HBoxContainer/VBoxContainer/Exit_Button as Button
@onready var options_button = $MarginContainer/HBoxContainer/VBoxContainer/Options_Button as Button
@onready var continue_button = $MarginContainer/HBoxContainer/VBoxContainer/Continue_Button as Button
@onready var margin_container = $MarginContainer as MarginContainer
@onready var credits_button = $MarginContainer/HBoxContainer/VBoxContainer/Credits_Button

@export var start_level = load("res://scenes/main_menu.tscn")
var loading_scene = load("res://scenes/loading_screen.tscn")
var options_scene = load("res://scenes/options_menu.tscn")
var credits_scene = load("res://assets/credits/scenes/end_credits/end_credits.tscn")
var start_confirmation_scene = load("res://scenes/start_confirmation.tscn")

func _ready():
	handle_connecting_signals()
	if FileAccess.file_exists(Global.SAVE_FILE):
		continue_button.visible = true
	else:
		continue_button.visible = false

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()

func on_start_pressed() -> void:
	$SFX.play()
	await $SFX.finished
	if FileAccess.file_exists(Global.SAVE_FILE):
		var start_confirmation_instance
		start_confirmation_instance = start_confirmation_scene.instantiate()
		start_button.visible = false
		continue_button.visible = false
		options_button.visible = false
		credits_button.visible = false
		exit_button.visible = false
		add_child(start_confirmation_instance)
		start_confirmation_instance.YesButton.pressed.connect(on_start_confirmation_yes)
		start_confirmation_instance.NoButton.pressed.connect(on_start_confirmation_no)
	else:
		get_tree().change_scene_to_packed(loading_scene)

func on_start_confirmation_yes() -> void:
	if FileAccess.file_exists(Global.SAVE_FILE):
		DirAccess.remove_absolute(Global.SAVE_FILE)
		DirAccess.remove_absolute(Global.STATS_SAVE_FILE)
		DirAccess.remove_absolute(Global.INVENTORY_SAVE_FILE)
	get_tree().change_scene_to_packed(loading_scene)

func on_start_confirmation_no() -> void:
	if has_node("StartConfirmation"):
		get_node("StartConfirmation").queue_free()
	start_button.visible = true
	continue_button.visible = true
	options_button.visible = true
	credits_button.visible = true
	exit_button.visible = true

func on_options_pressed() -> void:
	$SFX.play()
	await $SFX.finished
	get_tree().change_scene_to_packed(options_scene)

func on_continue_pressed() -> void:
	get_tree().change_scene_to_packed(loading_scene)

func on_credits_pressed() -> void:
	get_tree().change_scene_to_packed(credits_scene)

func on_exit_pressed() -> void:
	get_tree().quit()

func handle_connecting_signals() -> void:
	start_button.pressed.connect(on_start_pressed)
	options_button.pressed.connect(on_options_pressed)
	exit_button.pressed.connect(on_exit_pressed)
	continue_button.pressed.connect(on_continue_pressed)
	credits_button.pressed.connect(on_credits_pressed)










	
