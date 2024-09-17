extends Area2D

@export var collision: CollisionShape2D
@export_enum("up","down", "left", "right") var direction: String
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
	if entered:
		if Input.is_action_just_pressed("interact"):
			Global.start_interactable_dialogue.emit(dialogue_resource, "start")


