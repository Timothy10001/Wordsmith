extends CanvasLayer

@onready var Progress = $MarginContainer/ProgressBar
@onready var ProgressLabel = $MarginContainer/ProgressBar/percentage_label
var main_scene = "res://scenes/main.tscn"
var loading_status = 0
var progress = []

func _ready():
	ResourceLoader.load_threaded_request(main_scene)

func _process(delta):
	loading_status = ResourceLoader.load_threaded_get_status(main_scene, progress)
	Progress.value = progress[0]
	ProgressLabel.text = "[center]" + str(floor(progress[0] * 100)) + "%"
	if loading_status == ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().create_timer(1.5).timeout
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(main_scene))
	


