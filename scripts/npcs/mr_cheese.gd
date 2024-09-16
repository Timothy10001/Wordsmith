extends CharacterBody2D


func _ready():
	$NPC.dialogue_resource = load("res://assets/resources/dialogues/mr_cheese.dialogue")
	$Sprite2D/MarginContainer/TextureRect.visible = false

func _on_npc_player_entered():
	$Sprite2D/MarginContainer/TextureRect.visible = true

func _on_npc_player_left():
	$Sprite2D/MarginContainer/TextureRect.visible = false
