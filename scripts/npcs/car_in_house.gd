extends CharacterBody2D

func _ready():
	Global.remove_car_in_house.connect(_on_remove_car_in_house)
	$AnimatedSprite2D/MarginContainer/TextureRect.visible = false

func _on_npc_player_entered():
	$AnimatedSprite2D/MarginContainer/TextureRect.visible = true

func _on_npc_player_left():
	$AnimatedSprite2D/MarginContainer/TextureRect.visible = false

func _on_remove_car_in_house():
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color("fff", 0.0), 1)
	await tween.finished
	queue_free()
