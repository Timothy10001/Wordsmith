extends Area2D

signal player_entered
signal player_left

const BALLOON = preload("res://assets/dialogue balloons/balloon.tscn")

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"
@export var touch_screen_button: TouchScreenButton
@export var collision_shape: CollisionShape2D



func _ready():
	touch_screen_button.visible = false
	Global.dialogue_ended.connect(_on_dialogue_ended)

var has_entered = false

func _on_body_entered(body):
	if body is Player:
		has_entered = true
		#touch_screen_button.visible = true
		print("player has entered")
		player_entered.emit()
		Global.interactable_entered.emit()


func _on_body_exited(body):
	if body is Player:
		#touch_screen_button.visible = false
		has_entered = false
		print("player has left")
		player_left.emit()
		Global.interactable_exited.emit()

func _process(_delta):
	if !Global.enemy_battle_active:
		collision_shape.disabled = true
	else:
		collision_shape.disabled = false
	if get_parent().visible:
		collision_shape.disabled = false
	else:
		collision_shape.disabled = true
	if has_entered:
		if Input.is_action_just_pressed("interact"):
			#touch_screen_button.visible = false
			action()

func action() -> void:
	var balloon: Node = BALLOON.instantiate()
	get_tree().current_scene.add_child(balloon)
	balloon.start(dialogue_resource, dialogue_start)

func _on_dialogue_ended():
	touch_screen_button.visible = false
