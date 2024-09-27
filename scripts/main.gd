extends Node

#STATES

var current_area_name: String = "lobby"
var current_room: int = 0
var current_mission: int = 0
var tutorial_status: String = "not done"
var player_position: Vector2 = Vector2(0,0)
var current_direction: String = "up"

var initial_position: Vector2 = Vector2(0, 0)

var current_mission_enemy_count: int = 0
var current_mission_enemy_required: int = 0

var briefed_by_mr_cheese: bool = false
var unlocked_key_house: bool = false
var briefed_by_principal_ronnie: bool = false

var music_position = 0

const BATTLE_BALLOON = preload("res://assets/dialogue balloons/battle dialogue/battle_balloon.tscn")
const BALLOON = preload("res://assets/dialogue balloons/balloon.tscn")

@onready var Rooms: Node2D = $Rooms
@onready var Controls: Node2D = $Controls

var player_instance
var controls_instance
var pause_instance
var mission_instance
var backpack_instance
var confirmation_instance
var dialogue_resource: DialogueResource

func _ready():
	connect_signals()
	start()
	#continue_game()
	cutscene_camera.enabled = false

func _process(_delta):
	current_mission = State.current_mission
	briefed_by_mr_cheese = State.briefed_by_mr_cheese
	unlocked_key_house = State.unlocked_key_house
	briefed_by_principal_ronnie = State.briefed_by_principal_ronnie
	
	if current_area_name == "lobby" and current_room == 0:
		if has_node("Rooms/Throne Room"):
			var npc_node = Rooms.get_child(0).get_node("NPCs")
			npc_node.get_node("Mr Cheese").visible = false
			npc_node.get_node("Snowman").visible = false
			npc_node.get_node("PrincipalRonnie").visible = false
			if current_mission >= 1:
				npc_node.get_node("Mr Cheese").visible = true
			if current_mission >= 2:
				npc_node.get_node("Snowman").visible = true
			if current_mission >= 3:
				npc_node.get_node("PrincipalRonnie").visible = true
	
	if current_area_name == "mission 3 - classroom" and current_room == 4:
		if has_node("Rooms/Outside"):
			var npc_node = Rooms.get_child(0).get_node("NPCs")
			npc_node.get_node("TeacherJoy").visible = false
			npc_node.get_node("TeacherGigi").visible = false
			npc_node.get_node("TeacherAries").visible = false
			npc_node.get_node("TeacherKen").visible = false
			if removed_enemies.size() > 0:
				for enemy_names in removed_enemies:
					match enemy_names:
						"TeacherJoy":
							npc_node.get_node("TeacherJoy").visible = true
						"TeacherGigi":
							npc_node.get_node("TeacherGigi").visible = true
						"TeacherAries":
							npc_node.get_node("TeacherAries").visible = false
						"TeacherKen":
							npc_node.get_node("TeacherKen").visible = false
	
	if State.current_area == "mission 1 - house":
		State.unlocked_key_house = true
	if Input.is_action_just_pressed("pause"):
		music_position = Music.get_playback_position()
		Music.stop()
		GameStateService.on_scene_transitioning()
		GameStateService.save_game_state(Global.SAVE_FILE)
		pause_instance = pause_scene.instantiate()
		add_child(pause_instance)
		get_tree().paused = true
	if Input.is_action_just_pressed("resume"):
		Music.play()
		Music.seek(music_position)
		print("unpaused")
		get_tree().paused = false
		remove_child(pause_instance)
		if $CanvasLayer.get_child_count() > 0:
			for i in range($CanvasLayer.get_child_count()):
				$CanvasLayer.get_child(0).queue_free()
		backpack_instance = null
		pause_instance = null
		confirmation_instance = null
	if Input.is_action_just_pressed("show_inventory"):
		pause_instance.visible = false
		if $CanvasLayer.get_child_count() == 0:
			backpack_instance = backpack_scene.instantiate()
			$CanvasLayer.add_child(backpack_instance)
		else:
			backpack_instance.visible = true
	if Input.is_action_just_pressed("show_confirmation"):
		pause_instance.visible = false
		if $CanvasLayer.get_child_count() == 0:
			confirmation_instance = confirmation_scene.instantiate()
			$CanvasLayer.add_child(confirmation_instance)
		else:
			confirmation_instance.visible = true
	if Input.is_action_just_pressed("back_to_pause_menu"):
		pause_instance.visible = true
		if backpack_instance:
			backpack_instance.visible = false
		if confirmation_instance:
			confirmation_instance.visible = false

#<-TO BE CHANGED->#
func connect_signals():
	Global.back_to_lobby.connect(_on_back_to_lobby)
	
	Global.get_mission.connect(_get_mission)
	Global.confirm_mission.connect(_on_confirm_mission)
	Global.cancel_mission.connect(_on_cancel_mission)
	Global.redo_mission.connect(_on_redo_mission)
	#for areas
	Global.enter_new_area.connect(_on_enter_new_area)
	Global.enter_new_room.connect(_on_enter_new_room)
	#for the battle transitions
	Global.start_battle.connect(_on_start_battle)
	Global.end_battle.connect(_on_end_battle)
	#for interactables with dialogue
	Global.start_npc_dialogue.connect(_on_start_npc_dialogue)
	Global.start_interactable_dialogue.connect(_on_start_interactable_dialogue)
	Global.start_sleep.connect(_on_start_sleep)
	Global.end_sleep.connect(_on_end_sleep)
	
	Global.cutscene_start.connect(_on_cutscene_start)
	Global.stop_cutscene.connect(stop_cutscene)
	Global.add_mission_rewards.connect(_on_add_mission_rewards)
	
	Global.play_battle_music.connect(play_battle_music)
	Global.play_sfx.connect(play_sfx)
	Global.end_credits.connect(_on_end_credits)


#create rooms in a different scene?
#const controls_scene: PackedScene = preload("res://scenes/controls.tscn")
const player_scene: PackedScene = preload("res://scenes/player.tscn")
const pause_scene: PackedScene = preload("res://scenes/pause_menu.tscn")
const backpack_scene: PackedScene = preload("res://scenes/backpack_ui.tscn")
const confirmation_scene: PackedScene = preload("res://scenes/exit_confirmation.tscn")
const transition_scene: PackedScene = preload("res://scenes/transition.tscn")
const mission_scene: PackedScene = preload("res://scenes/mission.tscn")

var current_area: Array[PackedScene]

func start() -> void:
	# TO BE CHANGED
	#GameStateService.new_game()
	State.current_area = current_area_name
	State.current_room = current_room
	State.current_mission = current_mission
	State.tutorial_status  = tutorial_status
	State.player_position = player_position
	State.current_direction = current_direction
	State.current_mission_enemy_count = current_mission_enemy_count
	State.current_mission_enemy_required = current_mission_enemy_required
	Global.enter_new_area.emit(State.current_area, State.current_room)
	Global.enter_new_room.emit(State.current_room, State.player_position, State.current_direction)
	
	if Global.Voices:
		Global.TTS_available = true
	else:
		Global.TTS_available = false


func continue_game():
	pass
	#var scene := GameStateService.load_game_state(Global.SAVE_FILE)
	#get_tree().change_scene_to_file(scene)

func enable_player_process():
	player_instance.process_mode = Node.PROCESS_MODE_INHERIT

func disable_player_process():
	player_instance.process_mode = Node.PROCESS_MODE_DISABLED


func add_iris_transition():
	var transition_instance = transition_scene.instantiate()
	add_child(transition_instance)
	Global.play_sfx.emit("iris_transition")
	transition_instance.iris_transition()

func add_controls():
	if Controls.get_child_count() == 0:
		var controls_scene: PackedScene = load("res://scenes/controls.tscn")
		controls_instance = controls_scene.instantiate()
		Controls.add_child(controls_instance)
		var enemy_required_scene: PackedScene = load("res://scenes/enemies_required.tscn")
		enemy_required_instance = enemy_required_scene.instantiate()
		Controls.add_child(enemy_required_instance)

func remove_controls():
	for i in range(Controls.get_child_count()):
		Controls.get_child(i).queue_free()

func get_current_area(_area):
	GameStateService.on_scene_transitioning()
	current_area.clear()
	for room in Global.area_list[_area]:
		current_area.append(load(room))


func _on_enter_new_area(_area: String, _room_index: int):
	State.current_area = _area
	State.current_room = _room_index
	current_area_name = _area
	current_room = _room_index
	play_area_music()
	get_current_area(_area)
	

func init_current_room():
	GameStateService.on_scene_transitioning()
	#print(GameStateService._game_state)
	if current_area_name != "mission 2 - highway" and current_room == 0:
		cutscene_extras.get_node("TruckBoss").visible = false
	
	if Rooms.get_child_count() > 0:
		for i in range(Rooms.get_child_count()):
			Rooms.remove_child(Rooms.get_child(0))
		
	if !Global.cutscene_playing:
		add_controls()
	
	Rooms.add_child(current_area[State.current_room].instantiate())
	
	if Rooms.get_child(0).has_node("Enemies"):
		init_current_enemies(Rooms.get_child(0).get_node("Enemies"))
	
	player_instance = player_scene.instantiate()
	player_instance.position = State.player_position
	player_instance.current_direction = State.current_direction
	Global.enemy_battle_active = true
	
	Rooms.get_child(0).get_node("TileMap").add_child(player_instance)
	print(current_room)
	if current_area_name == "mission 2 - highway" and current_room == 1:
		player_instance.visible = false
	else:
		player_instance.visible = true

var removed_enemies: Array[String]

func init_current_enemies(enemy_node: Node2D):
	for enemy_index in range(enemy_node.get_child_count()):
		if !removed_enemies.is_empty():
			for i in range(removed_enemies.size()):
				if enemy_node.get_child(enemy_index).name == removed_enemies[i]:
					enemy_node.get_child(enemy_index).queue_free()

func _on_enter_new_room(_new_room_index: int, _player_position: Vector2, _direction: String):
	State.current_room = _new_room_index
	current_room = _new_room_index
	State.player_position = _player_position
	State.current_direction = _direction
	call_deferred("init_current_room")


func _get_mission():
	remove_controls()
	get_tree().paused = true
	
	mission_instance = mission_scene.instantiate()
	$CanvasLayer.add_child(mission_instance)
	
	mission_instance.MissionTitle.text = mission_instance.mission_title_list[State.current_mission]
	mission_instance.MissionDescription.text = mission_instance.mission_description_list[State.current_mission]

func _on_redo_mission(mission: int):
	remove_controls()
	get_tree().paused = true
	
	mission_instance = mission_scene.instantiate()
	$CanvasLayer.add_child(mission_instance)
	
	mission_instance.MissionTitle.text = mission_instance.mission_title_list[mission]
	mission_instance.MissionDescription.text = mission_instance.mission_description_list[mission]
	State.current_mission = mission

#const enemy_required_scene: PackedScene = preload("res://scenes/enemies_required.tscn")
var enemy_required_instance


func _on_confirm_mission():
	# do transition
	
	$CanvasLayer.get_child(0).queue_free()
	call_deferred("add_iris_transition")
	await Global.transition_finished
	get_tree().paused = false
	#load new area after transition
	match State.current_mission:
		1:
			Global.enter_new_area.emit("mission 1 - outside", 0)
			Global.enter_new_room.emit(0, Vector2(-224, -16), "down")
			initial_position = Vector2(-224, -16)
			removed_enemies.clear()
			# 14
			current_mission_enemy_count = 14
			current_mission_enemy_required = 14
			State.current_mission_enemy_count = current_mission_enemy_count
			State.current_mission_enemy_required = current_mission_enemy_required
		2:
			Global.enter_new_area.emit("mission 2 - outside", 0)
			Global.enter_new_room.emit(0, Vector2(0, 0), "down")
			initial_position = Vector2(0, 0)
			removed_enemies.clear()
			current_mission_enemy_count = 6
			current_mission_enemy_required = 6
			State.current_mission_enemy_count = current_mission_enemy_count
			State.current_mission_enemy_required = current_mission_enemy_required
		3:
			Global.enter_new_area.emit("mission 3 - outside", 0)
			Global.enter_new_room.emit(0, Vector2(0, 0), "down")
			initial_position = Vector2(0, 0)
			removed_enemies.clear()
			current_mission_enemy_count = 16
			current_mission_enemy_required = 16
			State.current_mission_enemy_count = current_mission_enemy_count
			State.current_mission_enemy_required = current_mission_enemy_required

func _on_cancel_mission():
	if $CanvasLayer.get_child_count() > 0:
		$CanvasLayer.get_child(0).queue_free()
	get_tree().paused = false
	add_controls()


const battle_scene: PackedScene = preload("res://scenes/battle.tscn")

func _on_start_battle(party: Array, enemies: Array, background_texture_path: String, _type: String, _enemy_node: Node2D):
	
	#DISABLE PLAYER MOVEMENT
	remove_controls()
	player_instance.visible = false
	Global.enemy_battle_active = false
	get_tree().paused = true
	
	
	call_deferred("add_iris_transition")
	await Global.transition_finished
	
	#ADD BATTLE SCENE
	var battle_instance = battle_scene.instantiate()
	$CanvasLayer.add_child(battle_instance)
	
	#initialize battle data
	Global.in_battle = true
	var party_array: Array[PackedScene] = []
	var enemy_array: Array[PackedScene] = []
	for player in party:
		party_array.append(load(player))
	for enemy in enemies:
		enemy_array.append(load(enemy))
	
	battle_instance.set_battle_data(party_array, enemy_array, background_texture_path, _type, _enemy_node)


func _on_end_battle(state, _type: String, experience_gained: int, loot: Inventory, _enemy_node: Node2D):
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
		if current_mission != 2 and _type != "boss_battle":
			Global.cutscene_start.emit("mission_2_boss_cutscene_part_1")
		else:
			player_instance.CharacterResource.health = int(player_instance.CharacterResource.max_health * 0.75)
			Global.enter_new_room.emit(State.current_room, initial_position, State.current_direction)
	
	await Global.dialogue_ended
	play_area_music()
	add_child(transition_instance)
	
	transition_instance.fade_transition()
	await Global.transition_finished
	
	$CanvasLayer.remove_child($CanvasLayer.get_child(0))
	
	#ENABLE PLAYER MOVEMENT
	Global.in_battle = false
	get_tree().paused = false
	player_instance.visible = true
	
	if state == "Win" and _type == "battle":
		if _enemy_node:
			#removes enemy
			removed_enemies.append(_enemy_node.name)
			current_mission_enemy_count -= 1
			if current_mission_enemy_count < 0:
				current_mission_enemy_count = 0
			State.current_mission_enemy_count = current_mission_enemy_count
			var tween = get_tree().create_tween()
			tween.tween_property(_enemy_node, "modulate", Color("fff", 0.0), 1)
			await tween.finished
			_enemy_node.queue_free()
		if experience_gained > 0:
			
			Global.experience = experience_gained
			
			var balloon = BATTLE_BALLOON.instantiate()
			add_child(balloon)
			balloon.start(dialogue_resource, "exp_gained")
			await Global.dialogue_ended
			
			player_instance.level_component.gain_experience(experience_gained)
		if loot.items[0] != null:
			add_loot(loot)
	
	
	#TO BE CHANGED#
	if _type == "tutorial" and State.current_room == 0:
		dialogue_resource = load("res://assets/resources/dialogues/king_pendragon.dialogue")
		var balloon = BALLOON.instantiate()
		add_child(balloon)
		balloon.start(dialogue_resource, "start")
		Global.enemy_battle_active = true
		return
	
	if state == "Win" and _type == "boss_battle":
		Global.enemy_battle_active = true
		match current_mission:
			1:
				Global.cutscene_start.emit("mission_1_ending_cutscene")
			2:
				go_to_mission_2_end()
		return
	
	if state == "Win" and _type == "car_in_house_battle":
		#removes enemy
		removed_enemies.append("CarInHouse")
		current_mission_enemy_count -= 1
		if current_mission_enemy_count < 0:
			current_mission_enemy_count = 0
		State.current_mission_enemy_count = current_mission_enemy_count
		Global.remove_car_in_house.emit()
	
	if State.current_mission_enemy_count == 0 and State.current_mission == 2:
		Global.cutscene_start.emit("mission_2_boss_cutscene_part_1")
	
	
	if current_mission == 3 and State.current_mission_enemy_count == 0:
		var overlay = load("res://scenes/go_to_principal_ronnie.tscn")
		var overlay_instance
		overlay_instance = overlay.instantiate()
		add_child(overlay_instance)
		#print("do end credits")
	
	add_controls()
	#enable enemy battle areas after 1.5 seconds
	await get_tree().create_timer(1.5).timeout
	Global.enemy_battle_active = true



func add_loot(inventory: Inventory):
	var player_inventory = player_instance.inventory
	if inventory.items:
		for slot in inventory.items:
			#if a slot in the chest exists
			if slot:
				#if the player has the same item as the chest
				if player_inventory.search_inventory(slot.item.name):
					var item_index = player_inventory.search_inventory(slot.item.name)
					#if the chest item can fully merge with the player's item
					if player_inventory.items[item_index].can_fully_merge_with(slot):
						
						set_interactable_dialogue(slot, "loot_get")
						await Global.dialogue_ended
						
						player_inventory.items[item_index].fully_merge_with(slot)
						player_inventory.inventory_updated.emit(player_inventory)
						inventory.remove_item(slot.item.name)
					else:
						#the chest item is added onto another slot if it cannot fully merge
						set_interactable_dialogue(slot, "loot_get")
						await Global.dialogue_ended
						
						player_inventory.add_item(slot)
						inventory.remove_item(slot.item.name)
				else:
					#the chest item is added onto another slot if it's a new item
					set_interactable_dialogue(slot, "loot_get")
					await Global.dialogue_ended
					
					player_inventory.add_item(slot)
					inventory.remove_item(slot.item.name)
			else:
				break
	else:
		return

func _on_add_mission_rewards(inventory_path: String):
	var inventory = load(inventory_path)
	var player_inventory = player_instance.inventory
	if inventory.items:
		for slot in inventory.items:
			#if a slot in the chest exists
			if slot:
				#if the player has the same item as the chest
				if player_inventory.search_inventory(slot.item.name):
					var item_index = player_inventory.search_inventory(slot.item.name)
					#if the chest item can fully merge with the player's item
					if player_inventory.items[item_index].can_fully_merge_with(slot):
						
						set_interactable_dialogue(slot, "loot_get")
						await Global.dialogue_ended
						
						player_inventory.items[item_index].fully_merge_with(slot)
						player_inventory.inventory_updated.emit(player_inventory)
						inventory.remove_item(slot.item.name)
					else:
						#the chest item is added onto another slot if it cannot fully merge
						set_interactable_dialogue(slot, "loot_get")
						await Global.dialogue_ended
						
						player_inventory.add_item(slot)
						inventory.remove_item(slot.item.name)
				else:
					#the chest item is added onto another slot if it's a new item
					set_interactable_dialogue(slot, "loot_get")
					await Global.dialogue_ended
					
					player_inventory.add_item(slot)
					inventory.remove_item(slot.item.name)
			else:
				break
	else:
		return
	await Global.dialogue_ended
	stop_cutscene()
	Global.back_to_lobby.emit()
	State.current_mission += 1

func set_interactable_dialogue(slot: InventorySlot, title: String):
	Global.item_name = slot.item.name
	Global.item_quantity = slot.quantity
	Global.start_interactable_dialogue.emit(load("res://assets/resources/dialogues/interactables/chest.dialogue"), title)

func _on_start_interactable_dialogue(_dialogue_resource: DialogueResource, title: String):
	var balloon = BALLOON.instantiate()
	add_child(balloon)
	balloon.start(_dialogue_resource, title)
	await Global.dialogue_ended

func _on_start_npc_dialogue(dialogue_path: String, title: String):
	dialogue_resource = load(dialogue_path)
	var balloon = BALLOON.instantiate()
	add_child(balloon)
	balloon.start(dialogue_resource, title)

func _on_start_sleep():
	player_instance.visible = false
	get_tree().paused = true
	remove_controls()
	
	player_instance.CharacterResource.health = player_instance.CharacterResource.max_health
	player_instance.CharacterResource.mana = player_instance.CharacterResource.max_mana
	
	#ADD HEALTH AND MANA
	var transition_instance = transition_scene.instantiate()
	add_child(transition_instance)
	transition_instance.sleep_transition()
	await Global.transition_finished
	
	Global.end_sleep.emit()


func _on_end_sleep():
	get_tree().paused = false
	add_controls()
	player_instance.visible = true

func _on_back_to_lobby():
	# do transition
	remove_controls()
	get_tree().paused = true
	
	call_deferred("add_iris_transition")
	await Global.transition_finished
	
	Global.enter_new_area.emit("lobby", 0)
	Global.enter_new_room.emit(0, Vector2(0,0), "down")
	
	add_controls()
	get_tree().paused = false

const CUTSCENE_BARS = preload("res://scenes/cutscene_bars.tscn")
var cutscene_bars_instance

@onready var animation_player = $Cutscenes/AnimationPlayer
@onready var cutscene_camera = $Cutscenes/CutsceneCamera
@onready var cutscene_extras = $Cutscenes/CutsceneExtras

var current_cutscene_area: String
var current_cutscene_player_position: Vector2
var current_cutscene_room: int

func _on_cutscene_start(cutscene: String):
	current_cutscene_room = current_room
	current_cutscene_area = current_area_name
	current_cutscene_player_position = State.player_position
	
	cutscene_bars_instance = CUTSCENE_BARS.instantiate()
	add_child(cutscene_bars_instance)
	
	Global.cutscene_playing = true
	cutscene_camera.enabled = true
	
	remove_controls()
	
	match cutscene:
		"mission_1_starting_cutscene":
			animation_player.play(cutscene)
		"mission_1_ending_cutscene":
			Global.enter_new_area.emit("mission 1 - outside", 0)
			Global.enter_new_room.emit(0, Vector2(75, -82), "up")
			animation_player.play(cutscene)
		"mission_2_boss_cutscene_part_1":
			animation_player.play(cutscene)
		"mission_2_boss_cutscene_part_2":
			animation_player.play(cutscene)
		"mission_2_boss_cutscene_part_3":
			animation_player.play(cutscene)
		"mission_2_boss_highway":
			animation_player.play(cutscene)


func start_cutscene_dialogue(cutscene: String):
	remove_controls()
	match cutscene:
		"mission_1_starting_cutscene":
			dialogue_resource = load("res://assets/resources/dialogues/mr_cheese.dialogue")
			Global.start_interactable_dialogue.emit(dialogue_resource, "start")
		"mission_1_ending_cutscene":
			dialogue_resource = load("res://assets/resources/dialogues/mission_1_ending.dialogue")
			Global.start_interactable_dialogue.emit(dialogue_resource, "start")
			Rooms.get_child(0).get_node("CutsceneExtras").visible = true


func start_cutscene_custom_dialogue(cutscene: String, title: String):
	remove_controls()
	match cutscene:
		"mission_2_boss_cutscene":
			dialogue_resource = load("res://assets/resources/dialogues/snowman.dialogue")
			Global.start_interactable_dialogue.emit(dialogue_resource, title)
			cutscene_extras.get_node("TruckBoss").visible = true
		"mission_2_boss_help":
			dialogue_resource = load("res://assets/resources/dialogues/driving_instructor.dialogue")
			Global.start_interactable_dialogue.emit(dialogue_resource, title)
		"mission_2_boss_highway":
			dialogue_resource = load("res://assets/resources/dialogues/driving_instructor.dialogue")
			Global.start_interactable_dialogue.emit(dialogue_resource, title)

func go_to_mission_2_boss():
	add_iris_transition()
	await Global.transition_finished
	Global.enter_new_area.emit("mission 2 - highway", 1)
	Global.enter_new_room.emit(1, Vector2(0, 0), "up")

func go_to_mission_2_end():
	Global.enter_new_area.emit("mission 2 - highway", 0)
	Global.enter_new_room.emit(0, Vector2(0, 0), "up")
	State.current_mission += 1
	Global.cutscene_playing = false
	animation_player.stop()
	cutscene_camera.enabled = false

func stop_cutscene():
	Global.cutscene_playing = false
	animation_player.stop()
	cutscene_camera.enabled = false
	Global.cutscene_ended.emit()
	Global.enter_new_area.emit(current_cutscene_area, current_cutscene_room)
	Global.enter_new_room.emit(current_cutscene_room, current_cutscene_player_position, current_direction)


#AUDIO STUFF

@onready var Music = $Music
func play_area_music():
	if Music.playing:
		Music.stop()
	match current_area_name:
		"lobby":
			if !Music.stream == load("res://assets/sounds/music/lobby.mp3"):
				Music.stream = load("res://assets/sounds/music/lobby.mp3")
		"mission 1 - outside":
			if !Music.stream == load("res://assets/sounds/music/mission 1 - outside.mp3"):
				Music.stream = load("res://assets/sounds/music/mission 1 - outside.mp3")
		"mission 1 - den":
			if !Music.stream == load("res://assets/sounds/music/mission 1 - den.mp3"):
				Music.stream = load("res://assets/sounds/music/mission 1 - den.mp3")
		"mission 1 - house":
			if !Music.stream == load("res://assets/sounds/music/mission 1 - house.mp3"):
				Music.stream = load("res://assets/sounds/music/mission 1 - house.mp3")
		"mission 1 - tavern":
			if !Music.stream == load("res://assets/sounds/music/mission 1 - tavern.mp3"):
				Music.stream = load("res://assets/sounds/music/mission 1 - tavern.mp3")
		_:
			pass
	Music.play()

@onready var SFX = $SFX
func play_sfx(_name: String):
	match _name:
		"great":
			if !SFX.stream == load("res://assets/sounds/sfx/great.wav"):
				SFX.stream = load("res://assets/sounds/sfx/great.wav")
		"good_job":
			if !SFX.stream == load("res://assets/sounds/sfx/good_job.wav"):
				SFX.stream = load("res://assets/sounds/sfx/good_job.wav")
		"awesome":
			if !SFX.stream == load("res://assets/sounds/sfx/awesome.wav"):
				SFX.stream = load("res://assets/sounds/sfx/awesome.wav")
		"amazing":
			if !SFX.stream == load("res://assets/sounds/sfx/amazing.wav"):
				SFX.stream = load("res://assets/sounds/sfx/amazing.wav")
		"Notebook":
			if !SFX.stream == load("res://assets/sounds/sfx/notebook.wav"):
				SFX.stream = load("res://assets/sounds/sfx/notebook.wav")
		"Snowball":
			if !SFX.stream == load("res://assets/sounds/sfx/snowball.wav"):
				SFX.stream = load("res://assets/sounds/sfx/snowball.wav")
		"Marker":
			if !SFX.stream == load("res://assets/sounds/sfx/marker.wav"):
				SFX.stream = load("res://assets/sounds/sfx/marker.wav")
		"Teaching Stick":
			if !SFX.stream == load("res://assets/sounds/sfx/teaching_stick.wav"):
				SFX.stream = load("res://assets/sounds/sfx/teaching_stick.wav")
		"Bouncy Ball":
			if !SFX.stream == load("res://assets/sounds/sfx/bouncing_ball.wav"):
				SFX.stream = load("res://assets/sounds/sfx/bouncing_ball.wav")
		"button_click":
			if !SFX.stream == load("res://assets/sounds/sfx/button_click.wav"):
				SFX.stream = load("res://assets/sounds/sfx/button_click.wav")
		"heal":
			if !SFX.stream == load("res://assets/sounds/sfx/heal.wav"):
				SFX.stream = load("res://assets/sounds/sfx/heal.wav")
		"add_mana":
			if !SFX.stream == load("res://assets/sounds/sfx/add_mana.wav"):
				SFX.stream = load("res://assets/sounds/sfx/add_mana.wav")
		"iris_transition":
			if !SFX.stream == load("res://assets/sounds/sfx/iris_transition.wav"):
				SFX.stream = load("res://assets/sounds/sfx/iris_transition.wav")
	SFX.play()

func play_battle_music(enemy: String):
	if Music.playing:
		Music.stop()
	match enemy:
		"Dummy":
			if !Music.stream == load("res://assets/sounds/music/dummy_battle.mp3"):
				Music.stream = load("res://assets/sounds/music/dummy_battle.mp3")
		"Rat":
			if !Music.stream == load("res://assets/sounds/music/rat_battle.mp3"):
				Music.stream = load("res://assets/sounds/music/rat_battle.mp3")
		_:
			pass
	await get_tree().create_timer(1.5).timeout
	Music.play()

func _on_end_credits():
	var end_credits = load("res://scenes/end_credits.tscn")
	get_tree().change_scene_to_packed(end_credits)
