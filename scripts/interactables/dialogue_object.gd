extends Area2D

@export var Collision: CollisionShape2D
@export var dialogue_resource: DialogueResource
@export var title: String

var entered: bool = false
var player

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

func _process(_delta):
	if entered:
		if Input.is_action_just_pressed("interact"):
			Global.start_interactable_dialogue.emit(dialogue_resource, title)
