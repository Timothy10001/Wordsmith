extends CharacterBody2D

func _ready():
	$Sprite2D/MarginContainer/TextureRect.visible = false

func _process(_delta):
	if visible:
		$CollisionShape2D.disabled = false
	else:
		$CollisionShape2D.disabled = true

func _on_npc_player_entered():
	$Sprite2D/MarginContainer/TextureRect.visible = true

func _on_npc_player_left():
	$Sprite2D/MarginContainer/TextureRect.visible = false

