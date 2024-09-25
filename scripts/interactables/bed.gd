extends Area2D



@export var Collision: CollisionShape2D
@export var bed_sprite: Sprite2D
@export var sleeping_sprite: Sprite2D


var player
var entered: bool = false

func _ready():
	bed_sprite.visible = true
	sleeping_sprite.visible = false
	Global.end_sleep.connect(_on_end_sleep)

func _on_body_entered(body):
	if body is Player:
		Global.interactable_entered.emit()
		entered = true
		player = body

func _on_body_exited(body):
	if body is Player:
		entered = false
		Global.interactable_exited.emit()
		player = body

func _on_end_sleep():
	bed_sprite.visible = true
	sleeping_sprite.visible = false

func _process(_delta):
	if entered:
		if Input.is_action_just_pressed("interact"):
			Global.start_sleep.emit()
			bed_sprite.visible = false
			sleeping_sprite.visible = true

