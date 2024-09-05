extends Node

#add player stats and inventory
var saved_data = {
	"area": "lobby",
	"room": 0,
	"current mission": 0,
	"tutorial status": "not done",
	"player position": Vector2(-8, -54)
}

const BATTLE_BALLOON = preload("res://assets/dialogue balloons/battle dialogue/battle_balloon.tscn")
const BALLOON = preload("res://assets/dialogue balloons/balloon.tscn")

@onready var Rooms: Node2D = $Rooms

var player_instance
var controls_instance
var dialogue_resource: DialogueResource

func _ready():
	connect_signals()
	start()
	
	


#<-TO BE CHANGED->#
func connect_signals():
	Global.get_mission.connect(_get_mission)
	Global.confirm_mission.connect(_on_confirm_mission)
	#for areas
	Global.enter_new_area.connect(_on_enter_new_area)
	Global.enter_new_room.connect(_on_enter_new_room)
	#for the battle transitions
	Global.start_battle.connect(_on_start_battle)
	Global.end_battle.connect(_on_end_battle)
	

#create rooms in a different scene?
const controls_scene: PackedScene = preload("res://scenes/controls.tscn")
const player_scene: PackedScene = preload("res://scenes/player.tscn")

const transition_scene: PackedScene = preload("res://scenes/transition.tscn")
const mission_scene: PackedScene = preload("res://scenes/mission.tscn")

var current_area: Array[PackedScene]

func start() -> void:
	# TO BE CHANGED
	State.current_area = saved_data["area"]
	State.current_room = saved_data["room"]
	State.current_mission = saved_data["current mission"]
	State.tutorial_status = saved_data["tutorial status"]
	State.player_position = saved_data["player position"]
	
	Global.enter_new_area.emit(State.current_area, State.current_room)
	Global.enter_new_room.emit(State.current_room, State.player_position)
	
	
	#DUNNO WHAT TO DO HERE YET
	#Rooms.get_child(0).get_node("NPCs/Mr Cheese").visible = false
	#Rooms.get_child(0).get_node("NPCs/Mr Cheese").process_mode = Node.PROCESS_MODE_DISABLED
	




func get_current_area(_area):
	current_area = []
	for room in Global.area_list[_area]:
		current_area.append(load(room))

func _on_enter_new_area(_area: String, _room_index: int):
	State.current_area = _area
	State.current_room = _room_index
	
	get_current_area(_area)
	

func _on_enter_new_room(_new_room_index: int, _player_position: Vector2):
	Rooms.remove_child(Rooms.get_child(0))
	
	controls_instance = controls_scene.instantiate()
	
	add_child(controls_instance)
	
	Rooms.add_child(current_area[_new_room_index].instantiate())
	
	player_instance = player_scene.instantiate()
	player_instance.position = _player_position 
	Rooms.get_child(0).get_node("TileMap").add_child(player_instance)



func _get_mission():
	remove_child(controls_instance)
	remove_child(player_instance)
	var mission_instance = mission_scene.instantiate()
	add_child(mission_instance)
	mission_instance.MissionTitle.text = mission_instance.mission_title_list[State.current_mission]
	mission_instance.MissionDescription.text = mission_instance.mission_description_list[State.current_mission]


func _on_confirm_mission():
	# do transition
	var transition_instance = transition_scene.instantiate()
	add_child(transition_instance)
	transition_instance.iris_transition()
	await Global.transition_finished
	#load new area after transition
	match State.current_mission:
		1:
			Global.enter_new_area.emit("mission 1", 0)
			Global.enter_new_room.emit(0, Vector2(-88, -24))


const battle_scene: PackedScene = preload("res://scenes/battle.tscn")

func _on_start_battle(party: Array, enemies: Array, background_texture_path: String, _type: String):
	
	#initialize battle data
	
	var party_array: Array[PackedScene] = []
	var enemy_array: Array[PackedScene] = []
	for player in party:
		party_array.append(load(player))
	for enemy in enemies:
		enemy_array.append(load(enemy))
	
	#ADD BATTLE SCENE
	var battle_instance = battle_scene.instantiate()
	
	var transition_instance = transition_scene.instantiate()
	add_child(transition_instance)
	
	transition_instance.iris_transition()
	await Global.transition_finished
	
	#DISABLE PLAYER MOVEMENT
	player_instance.process_mode = Node.PROCESS_MODE_DISABLED
	player_instance.visible = false
	remove_child(controls_instance)
	#remove player input
	$CanvasLayer.add_child(battle_instance)
	battle_instance.set_battle_data(party_array, enemy_array, background_texture_path, _type)
	

func _on_end_battle(state, _type: String):
	var transition_instance = transition_scene.instantiate()
	#dialogue balloon for this shit
	dialogue_resource = load("res://assets/resources/dialogues/battle.dialogue")
	
	if state == "Win":
		var balloon = BATTLE_BALLOON.instantiate()
		add_child(balloon)
		balloon.start(dialogue_resource, "win")
	elif state == "Lose":
		var balloon = BATTLE_BALLOON.instantiate()
		add_child(balloon)
		balloon.start(dialogue_resource, "lose")
	
	await Global.dialogue_ended
	add_child(transition_instance)
	
	transition_instance.fade_transition()
	await Global.transition_finished
	
	$CanvasLayer.get_node("Battle").queue_free()
	
	#ENABLE PLAYER MOVEMENT
	player_instance.process_mode = Node.PROCESS_MODE_INHERIT
	player_instance.visible = true
	controls_instance = controls_scene.instantiate()
	add_child(controls_instance)
	
	#TO BE CHANGED#
	if _type == "tutorial":
		dialogue_resource = load("res://assets/resources/dialogues/king_pendragon.dialogue")
		var balloon = BALLOON.instantiate()
		add_child(balloon)
		balloon.start(dialogue_resource, "start")
		

