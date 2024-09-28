extends CanvasLayer

@onready var iris = $Iris
@onready var fade = $Fade
@onready var animation_player = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready():
	iris.visible = false
	fade.visible = false
	$Label.visible = false


func iris_transition():
	iris.visible = true
	animation_player.play("Fade To Black")

func fade_transition():
	animation_player.play("Fade In")
	fade.visible = true

func sleep_transition():
	animation_player.play("Sleep Fade In")
	fade.visible = true
	$Label.visible = true

func _on_animation_player_animation_finished(anim_name):

	match anim_name:
		"Fade To Black":
			animation_player.play("Fade From Black")
			Global.transition_finished.emit()
		"Fade From Black":
			iris.visible = false
			queue_free()
		"Fade In":
			animation_player.play("Fade Out")
			Global.transition_finished.emit()
		"Fade Out":
			fade.visible = false
			queue_free()
		"Sleep Fade In":
			animation_player.play("Sleep Fade Out")
		"Sleep Fade Out":
			Global.transition_finished.emit()
			fade.visible = false
			$Label.visible = false
			queue_free()

