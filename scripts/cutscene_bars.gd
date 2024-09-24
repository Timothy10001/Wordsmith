extends CanvasLayer


@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.play("cutscene_start")
	Global.cutscene_ended.connect(_on_cutscene_ended)

func _on_cutscene_ended():
	animation_player.play("cutscene_end")
	await animation_player.animation_finished
	queue_free()
