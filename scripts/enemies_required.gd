extends CanvasLayer

@onready var texture_rect = $MarginContainer/HBoxContainer/TextureRect
@onready var label = $MarginContainer/HBoxContainer/Label
# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if State.current_area != "lobby":
		match State.current_mission:
			0:
				texture_rect.texture = null
				label.text = ""
			1:
				texture_rect.texture = load("res://assets/art/characters/npc/portraits/rat.png")
				label.text = "s to be taught: %s" % State.current_mission_enemy_count
			2:
				texture_rect.texture = load("res://assets/art/characters/npc/portraits/deer.png")
				label.text = "s to be taught: %s" % State.current_mission_enemy_count
	else:
		queue_free()
