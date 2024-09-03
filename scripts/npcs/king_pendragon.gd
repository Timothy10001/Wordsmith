extends CharacterBody2D


func _ready():
	$NPC.dialogue_resource = load("res://assets/resources/dialogues/king_pendragon.dialogue")
	$AnimatedSprite2D/MarginContainer/TextureRect.visible = false

func _on_npc_player_entered():
	$AnimatedSprite2D/MarginContainer/TextureRect.visible = true

func _on_npc_player_left():
	$AnimatedSprite2D/MarginContainer/TextureRect.visible = false

