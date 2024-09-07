extends Area2D



@export var Collision: CollisionShape2D
var player_position: Vector2
var entered: bool = false

func _on_body_entered(body):
	if body is Player:
		Global.interactable_entered.emit()
		Global.player_rest_start.emit()
		entered = true
		player_position = body.position

func _on_body_exited(body):
	if body is Player:
		entered = false
		Global.interactable_exited.emit()
		Global.player_rest_end.emit()

