extends Area2D

@export var new_room_index: int = 0
@export var collision: CollisionShape2D
@export_enum("up","down", "left", "right") var direction: String
@export var new_area: String
@export var openable: bool
@export var dialogue_resource: DialogueResource

var entered: bool = false
var player

var next_position: Vector2

func _on_body_entered(body):
	if body is Player:
		Global.interactable_entered.emit()
		entered = true
		player = body



func _on_body_exited(body):
	if body is Player:
		entered = false
		player = body
		Global.interactable_exited.emit()

func _process(delta):
	if entered and openable:
		if Input.is_action_just_pressed("interact"):
			match direction:
				"up":
					next_position.x = player.position.x
					next_position.y = player.position.y - 16
				"down":
					next_position.x = player.position.x
					next_position.y = player.position.y + 16
				"left":
					next_position.x = player.position.x - 32
					next_position.y = player.position.y
				"right":
					next_position.x = player.position.x + 32
					next_position.y = player.position.y
			Global.enter_new_area.emit(new_area, new_room_index)
			Global.enter_new_room.emit(new_room_index, next_position, direction)
	elif entered and !openable:
		if Input.is_action_just_pressed("interact"):
			Global.start_interactable_dialogue.emit(dialogue_resource)
