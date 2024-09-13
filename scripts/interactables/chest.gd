extends Area2D


@export var collision: CollisionShape2D
@export var dialogue_resource: DialogueResource
@export var inventory: Inventory

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
