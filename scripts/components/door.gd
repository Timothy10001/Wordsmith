extends Area2D

@export var new_room_index: int = 0
@export_enum("up","down", "left", "right") var direction: String

var next_position: Vector2

func _on_body_entered(body):
	if body is Player:
		match direction:
			"up":
				next_position.x = body.position.x
				next_position.y = body.position.y - 16
			"down":
				next_position.x = body.position.x
				next_position.y = body.position.y + 16
			"left":
				next_position.x = body.position.x - 32
				next_position.y = body.position.y
			"right":
				next_position.x = body.position.x + 32
				next_position.y = body.position.y
			
		Global.enter_new_room.emit(new_room_index, next_position, direction)
