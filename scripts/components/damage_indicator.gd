extends Node2D
@onready var animation_player = $AnimationPlayer
@onready var SFX = $SFX
var damage_animation
func _ready():
	if get_parent().has_node("AnimationPlayer"):
		damage_animation = get_parent().get_node("AnimationPlayer")
	else:
		damage_animation = null

func display_damage_number(value: int, type: String):
	match type:
		"damage":
			$LabelContainer/Label.add_theme_color_override("font_color", Color("ffffff"))
			if value == 0:
				$LabelContainer/Label.text = "MISS!"
			else:
				if damage_animation:
					damage_animation.play("shake")
				play_sfx()
				$LabelContainer/Label.text = "-" + str(value)
		"heal":
			$LabelContainer/Label.add_theme_color_override("font_color", Color("83e04c"))
			$LabelContainer/Label.text = "+" + str(value)
		"mana":
			$LabelContainer/Label.add_theme_color_override("font_color", Color("3898ff"))
			if value >= 0:
				$LabelContainer/Label.text = "+" + str(value)
			else:
				$LabelContainer/Label.text = "-" + str(value)
	
	animation_player.play("Rise and Fade")

func play_sfx():
	var target = get_parent().CharacterResource.name
	if target == "Wordsmith":
		pass
	else:
		if !SFX.stream == load("res://assets/sounds/sfx/damage_enemy.wav"):
			SFX.stream = load("res://assets/sounds/sfx/damage_enemy.wav")
	SFX.play()
