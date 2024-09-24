extends CharacterBody2D

func _ready():
	$AnimatedSprite2D/MarginContainer/TextureRect.visible = false

func _on_npc_player_entered():
	$AnimatedSprite2D/MarginContainer/TextureRect.visible = true

func _on_npc_player_left():
	$AnimatedSprite2D/MarginContainer/TextureRect.visible = false

