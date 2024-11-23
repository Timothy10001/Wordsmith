extends Control

signal tutorial_cutscene_ended


#export variables
var enemies: Array[PackedScene]
var enemy_node: Node2D
var party: Array[PackedScene]
var dialogue_resource: DialogueResource
var battle_type: String
var end_battle_emitted: bool = false
var is_tutorial_skill_check: bool = false


"""
• init
	- clean up past battle data
	- spawn characters
		> add units in global as a list
	- set up ui
• start turn
• wait (input from ai and player)
• process input info (do all attacks and shit)
• checkFinish -> Win (Enemy = 0), Lose (PlayerHealth = 0), End Turn (Loop back to start)
"""
#dialogue balloon for battle
const BALLOON = preload("res://assets/dialogue balloons/battle dialogue/battle_balloon.tscn")


enum STATE{
	INIT,
	START_TURN,
	WAIT,
	PROCESS,
	CHECK_FINISH,
	WIN,
	LOSE,
	END_TURN
}
var battle_state = STATE.INIT

var paper_overlays = [
	"res://assets/art/backgrounds/paper_overlay_001.png",
	"res://assets/art/backgrounds/paper_overlay_002.png",
	"res://assets/art/backgrounds/paper_overlay_003.png",
	"res://assets/art/backgrounds/paper_overlay_004.png"
]

#combine all units (players and enemies) into one array
var unit_list = []
#the unit doing a turn
var selected_unit
var selected_enemy

var total_enemy_experience: int
var total_enemy_loot: Inventory


var turn = 0
var turn_count = 0
var round_count = 0
var all_units_finished: bool = true

var current_user
var current_action
var current_target
var is_skill_check_required: bool

#AUDIO shit

var bus_layout: AudioBusLayout = load("res://default_bus_layout.tres")



#random list of backgrounds
@onready var background = $Background

#health bars
@onready var PlayerHealthBar = [$VBoxContainer2/BottomContainer/MainContainer/CharacterContainer/CharacterPanel/CharacterStats/VBoxContainer/PlayerHealth, $VBoxContainer2/BottomContainer/RightContainer/CharacterPanel2/CharacterStats/VBoxContainer/PlayerHealth]
@onready var PlayerManaBar = [$VBoxContainer2/BottomContainer/MainContainer/CharacterContainer/CharacterPanel/CharacterStats/VBoxContainer/PlayerMana, $VBoxContainer2/BottomContainer/RightContainer/CharacterPanel2/CharacterStats/VBoxContainer/PlayerMana]
@onready var PlayerHealthLabel = [$VBoxContainer2/BottomContainer/MainContainer/CharacterContainer/CharacterPanel/CharacterStats/VBoxContainer/PlayerHealth/PlayerHealthLabel, $VBoxContainer2/BottomContainer/RightContainer/CharacterPanel2/CharacterStats/VBoxContainer/PlayerHealth/PlayerHealthLabel]
@onready var PlayerManaLabel = [$VBoxContainer2/BottomContainer/MainContainer/CharacterContainer/CharacterPanel/CharacterStats/VBoxContainer/PlayerMana/PlayerManaLabel, $VBoxContainer2/BottomContainer/RightContainer/CharacterPanel2/CharacterStats/VBoxContainer/PlayerMana/PlayerManaLabel]

@onready var EnemyHealthBar = $VBoxContainer/HBoxContainer/EnemyPanel/HBoxContainer/EnemyHealth
@onready var EnemyHealthLabel = $VBoxContainer/HBoxContainer/EnemyPanel/HBoxContainer/EnemyHealth/EnemyHealthLabel


#containers
@onready var EnemyContainer = $VBoxContainer/EnemyContainer
@onready var EnemyPanel = $VBoxContainer/HBoxContainer/EnemyPanel

@onready var MainContainer = $VBoxContainer2/BottomContainer/MainContainer
@onready var CharacterContainer = $VBoxContainer2/BottomContainer/MainContainer/CharacterContainer
@onready var SkillsContainer = $VBoxContainer2/BottomContainer/MainContainer/SkillsContainer
@onready var ItemGrid = $VBoxContainer2/BottomContainer/MainContainer/ItemContainer/ScrollContainer/ItemGrid
@onready var ItemContainer = $VBoxContainer2/BottomContainer/MainContainer/ItemContainer

#left container has teach, skills, items, and guard
@onready var LeftContainer = $VBoxContainer2/BottomContainer/LeftContainer
@onready var RightContainer = $VBoxContainer2/BottomContainer/RightContainer

@onready var RightCharacterPanel = $VBoxContainer2/BottomContainer/RightContainer/CharacterPanel2
#contains cancel and execute attack
@onready var RightButtonContainer = $VBoxContainer2/BottomContainer/RightContainer/ButtonContainer


@onready var FlashCardsButton = $"VBoxContainer2/BottomContainer/MainContainer/SkillsContainer/Flash Cards"
@onready var IdentifyButton = $VBoxContainer2/BottomContainer/MainContainer/SkillsContainer/Identify
@onready var StoryTimeButton = $"VBoxContainer2/BottomContainer/MainContainer/SkillsContainer/Story Time"
@onready var ReviewButton = $VBoxContainer2/BottomContainer/MainContainer/SkillsContainer/Review
@onready var ExecuteButton = $VBoxContainer2/BottomContainer/RightContainer/ButtonContainer/Panel/VBoxContainer/Execute

#for skill check
@onready var SkillCheck = $SkillCheck
@onready var PaperOverlay = $SkillCheck/PaperOverlay
@onready var SkillIllustration = $SkillCheck/PaperOverlay/SkillIllustration
@onready var MicButton = $SkillCheck/PaperOverlay/Panel/HBoxContainer/VBoxContainer/MicButton
@onready var ReadButton = $SkillCheck/PaperOverlay/Panel/HBoxContainer/VBoxContainer/ReadButton
@onready var SkipButton = $SkillCheck/PaperOverlay/Panel/MarginContainer/SkipButton

#enemy data
@onready var EnemyName = $VBoxContainer/HBoxContainer/EnemyPanel/VBoxContainer/EnemyName
@onready var EnemyStatusEffect = $VBoxContainer/HBoxContainer/EnemyPanel/VBoxContainer/EnemyStatusEffectContainer/EnemyStatusEffect

# ONLY FOR DEBUGGING
# ~~~~~~~~~~~~~~~~~~~~~~~~~
func _ready():
	$VBoxContainer.pivot_offset.x = $VBoxContainer.size.x / 2
	$VBoxContainer.pivot_offset.y = $VBoxContainer.size.y / 2
	Global.play_tutorial_cutscene.connect(play_tutorial_cutscene)
	Global.end_tutorial_cutscene.connect(end_tutorial_cutscene)
	connect_signals()
	dialogue_resource = load("res://assets/resources/dialogues/battle.dialogue")

# ~~~~~~~~~~~~~~~~~~~~~

func connect_signals():
	Global.unit_is_dead.connect(self._on_unit_is_dead)
	Global.execute.connect(self._on_execute)
	Global.start_skill_check.connect(self._on_start_skill_check)
	Global.end_skill_check.connect(self._on_end_skill_check)
	inventory_data.connect("inventory_interacted", _on_inventory_interacted)


func _process(_delta):
	#manages states
	if is_STT_processing:
		
		MicButton.visible = false
		ReadButton.visible = false
		SkipButton.visible = false
		
	else:
		MicButton.visible = true
		ReadButton.visible = true
		SkipButton.visible = true
	
	"""
	if DisplayServer.tts_is_speaking():
		MicButton.visible = false
		ReadButton.visible = false
		SkipButton.visible = false
	else:
		MicButton.visible = true
		ReadButton.visible = true
		SkipButton.visible = true
	"""
	match(battle_state):
		STATE.INIT:
			#initialize battle values and progress bars
			skill_check_stats.clear()
			show_default_container()
			unit_list.append(get_player_data())
			unit_list.append_array(get_enemy_data())
			set_player_progress_bar_value(get_player_data())
			battle_state = STATE.START_TURN
			#print("INIT PHASE")
		STATE.START_TURN:
			#start the turn of either enemy or player
			for unit in unit_list:
				if unit["is_turn_finished"] == false:
					all_units_finished = false
					break
				all_units_finished = true
			
			if all_units_finished:
				for unit in unit_list:
					unit["is_turn_finished"] = false
			#get turn queue is on start turn just in case the player or an enemy does a skill that affects speed
			get_turn_queue()
			#the unit that does the turn first
			get_selected_unit()
			#checks if current unit is dead or unable to act
			check_if_selected_unit_is_dead()
			check_if_selected_unit_is_stunned()
			
			#check unit's current status effect
			check_selected_unit_status_effect()
			check_mana_cost()
			
			#show UI if player's turn
			if selected_unit["type"] == "Player" and !selected_unit["is_turn_finished"]:
				show_default_container()
			if State.tutorial_status == "not done" and battle_type == "tutorial":
				start_tutorial_cutscene()
			battle_state = STATE.WAIT
		STATE.WAIT:
			if State.tutorial_status == "not done" and battle_type == "tutorial":
				await tutorial_cutscene_ended
			else:
				pass
			#wait for player input
			#print("WAIT PHASE")
			if selected_unit["is_turn_finished"] and selected_unit["type"] == "Player":
				battle_state = STATE.PROCESS
			
			if selected_unit["type"] == "Enemy":
				Global.execute.emit()
			
			await Global.execute
			battle_state = STATE.PROCESS
		STATE.PROCESS:
			#process all animations and turns
			update_unit_data()
			update_enemy_panel_data()
			update_player_progress_bar_value()
			#after the dialogue for the skill is over, check finish
			await Global.dialogue_ended
			battle_state = STATE.CHECK_FINISH
		STATE.CHECK_FINISH:
			#check for completion or do another loop
			var player_count = 0
			var enemy_count = 0
			for unit in unit_list:
				if unit["type"] == "Player":
					player_count += 1
				if unit["type"] == "Enemy":
					enemy_count += 1
			if player_count == 0:
				battle_state = STATE.LOSE
			elif enemy_count == 0:
				battle_state = STATE.WIN
			else:
				battle_state = STATE.END_TURN
			#print("CHECK FINISH PHASE")
		STATE.END_TURN:
			#do another loop
			turn_count += 1
			turn += 1
			if turn > len(unit_list) - 1:
				turn = 0
				round_count += 1
			#print("END TURN PHASE")
			battle_state = STATE.START_TURN
		STATE.WIN:
			#exit battle scene
			set_player_resource_data()
			if !end_battle_emitted:
				end_battle_emitted = true
				Global.end_battle.emit("Win", battle_type, total_enemy_experience, total_enemy_loot, enemy_node, skill_check_stats)
				await Global.end_battle
			battle_state = null
		STATE.LOSE:
			#enter game over
			print("lost")
			if !end_battle_emitted:
				end_battle_emitted = true
				Global.end_battle.emit("Lose", battle_type, total_enemy_experience, total_enemy_loot, enemy_node, skill_check_stats)
				await Global.end_battle
			battle_state = null


#clear past battle data
func clear_battle_data():
	if !party.is_empty():
		party.clear()
	if !enemies.is_empty():
		enemies.clear()

#INITIALIZATIONS
func set_battle_data(_party: Array[PackedScene], _enemies: Array[PackedScene], _background_texture_path: String, _type: String, _enemy_node: Node2D):
	party.append_array(_party)
	enemies.append_array(_enemies)
	background.texture = load(_background_texture_path)
	battle_type = _type
	if _enemy_node:
		enemy_node = _enemy_node


func start_tutorial_cutscene():
	animation_player.play("tutorial_part_1")

func play_tutorial_cutscene(cutscene: String):
	animation_player.play(cutscene)

func end_tutorial_cutscene():
	State.tutorial_status = "done"
	tutorial_cutscene_ended.emit()

func start_battle_dialogue(title: String):
	var balloon = BALLOON.instantiate()
	get_tree().root.add_child(balloon)
	balloon.start(dialogue_resource, title)

func show_default_container():
	if selected_unit:
		selected_unit["resource"].armor = selected_unit["resource"].initial_armor
	MainContainer.visible = true
	CharacterContainer.visible = true
	SkillsContainer.visible = false
	ItemContainer.visible = false
	LeftContainer.visible = true
	RightContainer.visible = false
	RightButtonContainer.visible = false
	RightCharacterPanel.visible = false
	EnemyPanel.visible = true
	SkillCheck.visible = false
	for unit in unit_list:
		if unit.has("select_button"):
			selected_enemy = unit
			set_enemy_panel_data(unit["name"], unit["health"], unit["max_health"])
			break
	for unit in unit_list:
		if unit.has("select_button"):
			unit["select_button"].visible = false
			

# get unit data
func get_player_data():
	for player in party:
		var player_instance = player.instantiate()
		$VBoxContainer2/BottomContainer/MainContainer/CharacterContainer/CharacterPanel/VBoxContainer.add_child(player_instance)
		var player_data = {
			"instance": player_instance,
			"name": player_instance.CharacterResource.name,
			"type": "Player",
			"resource": player_instance.CharacterResource,
			"health": player_instance.health_component.health,
			"max_health": player_instance.health_component.MAX_HEALTH,
			"health_component": player_instance.health_component,
			"mana": player_instance.mana_component.mana,
			"max_mana": player_instance.mana_component.MAX_MANA,
			"mana_component": player_instance.mana_component,
			"speed": player_instance.speed_component.speed,
			"speed_component": player_instance.speed_component,
			"skill_component": player_instance.skill_component,
			"is_turn_finished": false
		}
		player_instance.get_node("CollisionShape2D").visible = false
		player_instance.get_node("AnimatedSprite2D").visible = false
		player_instance.get_node("Camera2D").visible = false
		player_instance.set_process(false)
		return player_data

func get_enemy_data():
	var enemy_list = []
	for enemy in enemies:
		#spawn enemies from export variable
		var enemy_instance = enemy.instantiate()
		# adds enemy sprite
		EnemyContainer.add_child(enemy_instance)
		total_enemy_experience += enemy_instance.CharacterResource.experience
		total_enemy_loot = Inventory.new()
		total_enemy_loot.items.resize(10)
		if enemy_instance.CharacterResource.inventory != null:
			for slot in enemy_instance.CharacterResource.inventory.items:
				total_enemy_loot.add_item(slot)
		var enemy_data = {
			"instance": enemy_instance,
			"name": enemy_instance.CharacterResource.name,
			"type": "Enemy",
			"resource": enemy_instance.CharacterResource,
			"health": enemy_instance.health_component.health,
			"max_health": enemy_instance.health_component.MAX_HEALTH,
			"health_component": enemy_instance.health_component,
			"speed": enemy_instance.speed_component.speed,
			"speed_component": enemy_instance.speed_component,
			"select_button": enemy_instance.select_button,
			"skill_component": enemy_instance.skill_component,
			#skill names only
			"skills": enemy_instance.skill_component.skill_list,
			"is_turn_finished": false
		}
		enemy_list.push_back(enemy_data)
	return enemy_list


#display health and mana bars
func set_player_progress_bar_value(player_data):
	for i in len(PlayerHealthBar):
		#for main and right container health and mana bars to be consistent
		PlayerHealthBar[i].max_value = player_data["max_health"]
		PlayerManaBar[i].max_value = player_data["max_mana"]
		PlayerHealthBar[i].value = player_data["health"]
		PlayerManaBar[i].value = player_data["mana"]
		PlayerHealthLabel[i].text = "%d/%d" % [player_data["health"], player_data["max_health"]]
		PlayerManaLabel[i].text = "%d/%d" % [player_data["mana"], player_data["max_mana"]]
	#selected enemy's healthbar

func update_player_progress_bar_value():
	for unit in unit_list:
		if unit["type"] == "Player":
			for i in len(PlayerHealthBar):
			#for main and right container health and mana bars to be consistent
				PlayerHealthBar[i].value = unit["health"]
				PlayerManaBar[i].value = unit["mana"]
				PlayerHealthLabel[i].text = "%d/%d" % [unit["health"], unit["max_health"]]
				PlayerManaLabel[i].text = "%d/%d" % [unit["mana"], unit["max_mana"]]

func set_enemy_panel_data(enemy_name, health, max_health):
	EnemyName.text = enemy_name
	EnemyHealthBar.max_value = max_health
	EnemyHealthBar.value = health
	EnemyHealthLabel.text = "%d/%d" % [health, max_health]

func update_enemy_panel_data():
	for unit in unit_list:
		if unit["type"] == "Enemy":
			EnemyHealthBar.value = unit["health"]
			EnemyHealthLabel.text = "%d/%d" % [unit["health"], unit["max_health"]]
#--------------------------------------#


# GAME LOGIC
#when execute is pressed check if selected_unit is alive, and it's turn is not yet finished
func _on_execute():
	if selected_unit["is_turn_finished"] and is_instance_valid(selected_unit["instance"]):
		return
	if selected_unit["is_turn_finished"] == false and is_instance_valid(selected_unit["instance"]):
		if selected_unit["type"] == "Player":
			if current_action == "Use Item":
				ItemContainer.visible = false
				CharacterContainer.visible = true
				if selected_inventory_slot.item.target == "player":
					inventory_data.use_item(selected_inventory_slot_index, selected_unit["instance"])
					var balloon = BALLOON.instantiate()
					get_tree().root.add_child(balloon)
					balloon.start(dialogue_resource, "use_item")
					#change is turn finished to true
					selected_unit["is_turn_finished"] = true
				elif selected_inventory_slot.item.target == "enemy":
					inventory_data.use_item(selected_inventory_slot_index, selected_enemy["instance"])
					var balloon = BALLOON.instantiate()
					get_tree().root.add_child(balloon)
					balloon.start(dialogue_resource, "use_item")
					#change is turn finished to true
					play_item_animation(selected_inventory_slot.item.name)
					await animation_player.animation_finished
					selected_unit["is_turn_finished"] = true
			else:
				if is_skill_check_required:
					#await skill check before starting the actions
					Global.start_skill_check.emit()
					await Global.end_skill_check
					start_action(current_action, selected_enemy, selected_unit["skill_component"], selected_enemy["instance"], selected_unit)
				else:
					start_action(current_action, selected_enemy, selected_unit["skill_component"], selected_enemy["instance"], selected_unit)
		if selected_unit["type"] == "Enemy":
			for unit in unit_list:
				if unit["type"] == "Player":
					start_action(selected_unit["resource"].enemy_AI(selected_unit["skills"], selected_unit, unit["instance"]), unit_list[0], selected_unit["skill_component"], unit_list[0]["instance"], selected_unit)

#action is the name of the skill
#sorry for the shitty arrangement
func start_action(action, target, user_skill_component, target_instance, user):
	#perform the skill
	user_skill_component.use_skill(action, target, user_skill_component, target_instance, user)
	
	#do dialogue for skill description
	var balloon = BALLOON.instantiate()
	get_tree().root.add_child(balloon)
	balloon.start(dialogue_resource, "use_skill")
	
	#change is turn finished to true
	selected_unit["is_turn_finished"] = true

func stunned_dialogue(_unit):
	if _unit["type"] == "Player":
		#change is turn finished to true
		selected_unit["is_turn_finished"] = true
		var balloon = BALLOON.instantiate()
		get_tree().root.add_child(balloon)
		balloon.start(dialogue_resource, "player_stunned")
		
	else:
			#change is turn finished to true
		selected_unit["is_turn_finished"] = true
		var balloon = BALLOON.instantiate()
		get_tree().root.add_child(balloon)
		balloon.start(dialogue_resource, "enemy_stunned")
	battle_state = STATE.CHECK_FINISH

func get_turn_queue():
	#add turn queue based on speed
	unit_list.sort_custom(func(a,b): return a["speed"] > b["speed"])

func get_selected_unit():
	for unit in unit_list:
		if unit["is_turn_finished"] == false:
			selected_unit = unit
			break


func update_unit_data():
	for unit in unit_list:
		if is_instance_valid(unit["instance"]):
			unit["health"] = unit["instance"].health_component.health
			unit["speed"] = unit["instance"].speed_component.speed
			if unit["type"] == "Player":
				unit["mana"] = unit["instance"].mana_component.mana
		


func _on_unit_is_dead(instance):
	for unit in unit_list:
		if unit["instance"] == instance:
			if unit["type"] == "Player":
				update_unit_data()
				update_player_progress_bar_value()
			unit_list.erase(unit)

func check_if_selected_unit_is_dead():
	if !is_instance_valid(selected_unit["instance"]):
		battle_state = STATE.CHECK_FINISH
		
func check_if_selected_unit_is_stunned():
	if is_instance_valid(selected_unit["instance"]):
		if selected_unit["instance"].current_stun_duration > 0:
			if selected_unit["type"] == "Player":
				selected_unit["instance"].current_stun_duration -= 1
				stunned_dialogue(selected_unit)
			else:
				selected_unit["instance"].current_stun_duration -= 1
				stunned_dialogue(selected_unit)
		else:
			selected_unit["is_turn_finished"] = false

func check_selected_unit_status_effect():
	if is_instance_valid(selected_unit["instance"]):
		if selected_unit["instance"].current_miss_duration > 0:
			selected_unit["instance"].current_miss_duration -= 1
		if selected_unit["instance"].current_damage_duration > 0:
			selected_unit["instance"].current_damage_duration -= 1

func check_mana_cost():
	for unit in unit_list:
		if unit["type"] == "Player":
			if unit["mana"] < 20:
				FlashCardsButton.disabled = true
				IdentifyButton.disabled = true
				StoryTimeButton.disabled = true
				ReviewButton.disabled = true
			elif unit["mana"] < 22:
				FlashCardsButton.disabled = false
				IdentifyButton.disabled = true
				StoryTimeButton.disabled = true
				ReviewButton.disabled = false
			elif unit["mana"] < 25:
				FlashCardsButton.disabled = false
				IdentifyButton.disabled = false
				StoryTimeButton.disabled = true
				ReviewButton.disabled = false
			else:
				FlashCardsButton.disabled = false
				IdentifyButton.disabled = false
				StoryTimeButton.disabled = false
				ReviewButton.disabled = false

#SET PLAYER DATA AFTER END OF BATTLE:
func set_player_resource_data():
	for unit in unit_list:
		if unit["type"] == "Player":
			unit["resource"].health = unit["health"]
			unit["resource"].mana = unit["mana"]


#--------------------------------------#


#UI RELATED TASKS
func show_skills():
	show_enemy_selection()
	LeftContainer.visible = false
	CharacterContainer.visible = false
	SkillsContainer.visible = true
	ItemContainer.visible = false
	RightContainer.visible = true
	RightButtonContainer.visible = true
	$VBoxContainer2/BottomContainer/RightContainer/ButtonContainer/Panel/VBoxContainer/Execute.visible = false
	RightCharacterPanel.visible = false
	IdentifyButton.visible = false
	StoryTimeButton.visible = false
	ReviewButton.visible = false
	if State.level >= 2:
		IdentifyButton.visible = true
	if State.level >= 4:
		StoryTimeButton.visible = true
	if State.level >= 6:
		ReviewButton.visible = true

func show_items():
	show_enemy_selection()
	LeftContainer.visible = false
	CharacterContainer.visible = false
	ItemContainer.visible = true
	ItemGrid.visible = true
	RightContainer.visible = true
	RightButtonContainer.visible = true
	$VBoxContainer2/BottomContainer/RightContainer/ButtonContainer/Panel/VBoxContainer/Execute.visible = true
	RightCharacterPanel.visible = false
	

func show_enemy_selection():
	#select enemy pressed by player
	for unit in unit_list:
		if unit.has("select_button"):
			unit["select_button"].visible = true
			if !unit["select_button"].is_connected("pressed", self._on_select_pressed):
				unit["select_button"].pressed.connect(self._on_select_pressed.bind(unit["select_button"]))
	
	#select the fastest enemy by default
	for unit in unit_list:
		if unit.has("select_button"):
			selected_enemy = unit
			set_enemy_panel_data(unit["name"], unit["health"], unit["max_health"])
			break


func show_end_turn():
	show_enemy_selection()
	#show the end turn 
	LeftContainer.visible = false
	SkillsContainer.visible = false
	ItemContainer.visible = false
	CharacterContainer.visible = true
	RightContainer.visible = true
	RightButtonContainer.visible = true
	RightCharacterPanel.visible = false
	$VBoxContainer2/BottomContainer/RightContainer/ButtonContainer/Panel/VBoxContainer/Execute.visible = true
	EnemyPanel.visible = true
	
#-----------------------------------#

#PLAYER ACTIONS
func _on_teach_pressed():
	Global.play_sfx.emit("button_click")
	show_end_turn()
	current_action = "Basic Attack"
	is_skill_check_required = false
	#ADD BIT OF MANA TO PLAYER AND DO BASIC ATTACK


func _on_skills_pressed():
	Global.play_sfx.emit("button_click")
	show_skills()

# ITEM GRID
func _on_items_pressed():
	Global.play_sfx.emit("button_click")
	show_items()
	ExecuteButton.visible = false
	current_action = "Use Item"
	populate_item_grid(inventory_data)

var inventory_slot_scene: PackedScene = load("res://scenes/inventory_slot.tscn")
@onready var inventory_data = load("res://assets/resources/player_inventory.tres")

var selected_inventory_slot: InventorySlot
var selected_inventory_slot_index: int

var inventory_slots: Array[PanelContainer]

func _on_inventory_interacted(inventory: Inventory, index: int, type: String):
	if type == "select":
		Global.play_sfx.emit("button_click")
		#set selected slot data
		selected_inventory_slot = inventory.selected_slot_data(index)
		selected_inventory_slot_index = index
		ExecuteButton.visible = true
		#highlight selected slot
		update_selected_slot()


func update_selected_slot():
	#highlights selected slot
	for i in inventory_slots.size():
		if i == selected_inventory_slot_index:
			inventory_slots[i].selected = true
		else:
			inventory_slots[i].selected = false



func populate_item_grid(inventory: Inventory) -> void:
	#remove current children so that it will be automatically updated
	for child in ItemGrid.get_children():
		ItemGrid.remove_child(child)
		inventory_slots.clear()
		
		
	for inventory_slot in inventory.items:
		#add all inventory slots
		var inventory_slot_instance = inventory_slot_scene.instantiate()
		ItemGrid.add_child(inventory_slot_instance)
		inventory_slot_instance.visible = false
		inventory_slot_instance.connect("inventory_slot_selected", inventory._on_inventory_slot_selected)
		inventory_slots.append(inventory_slot_instance)
		if inventory_slot != null and inventory_slot.item.type != "accessory":
			#if inventory slot isn't null, add slot
			inventory_slot_instance.visible = true
			#adds slot's data
			inventory_slot_instance.set_inventory_slot_data(inventory_slot.item, inventory_slot.quantity)

@onready var ItemSprite = $MarginContainer/ItemSprite

func play_item_animation(_name: String):
	animation_player.play("play_item_animation")
	ItemSprite.play(_name)
	Global.play_sfx.emit(_name)

func _on_guard_pressed():
	Global.play_sfx.emit("button_click")
	show_end_turn()
	current_action = "Guard"
	#ADD BIT OF MANA TO PLAYER AND ADD DAMAGE REDUCTION


func _on_execute_pressed():
	#UI stuff
	RightContainer.visible = false
	RightButtonContainer.visible = false
	RightCharacterPanel.visible = false
	EnemyPanel.visible = false
	
	#start turns
	Global.execute.emit()


func _on_cancel_pressed():
	Global.play_sfx.emit("button_click")
	show_default_container()
	current_action = ""

#----------------------------#
#WORDSMITH SKILLS
func _on_flash_cards_pressed():
	Global.play_sfx.emit("button_click")
	show_end_turn()
	current_action = "Flash Cards"
	is_skill_check_required = true
	

func _on_identify_pressed():
	Global.play_sfx.emit("button_click")
	show_end_turn()
	current_action = "Identify"
	is_skill_check_required = true


func _on_story_time_pressed():
	Global.play_sfx.emit("button_click")
	show_end_turn() 
	current_action = "Story Time"
	is_skill_check_required = true


func _on_review_pressed():
	Global.play_sfx.emit("button_click")
	show_end_turn()
	current_action = "Review"
	is_skill_check_required = false

#---------------------------------------#

func _on_select_pressed(button):
	Global.play_sfx.emit("button_click")
	for unit in unit_list:
		if unit.has("select_button"):
			if unit["select_button"] == button:
				selected_enemy = unit
				set_enemy_panel_data(unit["name"], unit["health"], unit["max_health"])
	EnemyPanel.visible = true


#SPEECH TO TEXT

var current_word: String
@onready var CurrentWord = $SkillCheck/PaperOverlay/WordContainer/CurrentWord
@onready var ProcessingLabel = $SkillCheck/MarginContainer/Processing
@onready var CurrentSentence = $SkillCheck/PaperOverlay/WordContainer/CurrentSentence

#skill check
func _on_start_skill_check():
	SkillCheck.visible = true
	$SkillCheck/PaperOverlay/Panel/MarginContainer.visible = true
	ProcessingLabel.visible = false
	TryAgain.visible = false
	SkillIllustration.visible = false
	CurrentSentence.visible = false
	CurrentWord.visible = false
	
	TryAgain.text = ""
	CurrentWord.text = ""
	CurrentSentence.text = ""
	
	if Global.TTS_available:
		ReadButton.visible = true
	else:
		ReadButton.visible = false
	
	ProcessingLabel.visible = false
	PaperOverlay.texture = load(paper_overlays.pick_random())
	
	
	
	#randomize()
	#var random_index
	var index
	match current_action:
		"Flash Cards":
			PaperOverlay.texture = null
			index = current_word_index_selector(SkillCheckWords.flash_cards["words"])
			#random_index = randi_range(0, SkillCheckWords.flash_cards["words"].size() - 1)
			current_word = SkillCheckWords.flash_cards["words"][index]
			SkillIllustration.texture = load(SkillCheckWords.flash_cards["illustration"][index])
			SkillIllustration.visible = true
			CurrentWord.size_flags_horizontal = SIZE_SHRINK_CENTER
			CurrentWord.size_flags_vertical = SIZE_SHRINK_END
			CurrentWord.text = current_word
			CurrentWord.visible = true
		"Identify":
			PaperOverlay.texture = null
			index = current_word_index_selector(SkillCheckWords.flash_cards["words"])
			#random_index = randi_range(0, SkillCheckWords.identify["words"].size() - 1)
			current_word = SkillCheckWords.flash_cards["words"][index]
			CurrentWord.size_flags_horizontal = SIZE_SHRINK_CENTER
			CurrentWord.size_flags_vertical = SIZE_SHRINK_END
			CurrentWord.text = blank_text(current_word)
			CurrentWord.visible = true
			SkillIllustration.texture = load(SkillCheckWords.identify["illustration"][index])
			SkillIllustration.visible = true
		"Story Time":
			PaperOverlay.texture = null
			#random_index = randi_range(0, SkillCheckWords.story_time["words"].size() - 1)
			index = current_word_index_selector(SkillCheckWords.story_time["words"])
			current_word = SkillCheckWords.story_time["words"][index]
			CurrentSentence.text = SkillCheckWords.story_time["sentences"][index]
			CurrentSentence.visible = true
			SkillIllustration.texture = load(SkillCheckWords.story_time["illustration"][index])
			SkillIllustration.visible = true
	
	print(current_word)


var skipped_words = []

func get_skipped_words():
	skipped_words.clear()
	if State.skill_check_stats.size() > 0:
		for word_state in State.skill_check_stats:
			if word_state[2] == false:
				skipped_words.append(word_state[0])
	if skill_check_stats.size() > 0:
		for word_state in skill_check_stats:
			if word_state[2] == false:
				skipped_words.append(word_state[0])

func current_word_index_selector(skill_check_words: Array):
	get_skipped_words()
	for player in party:
		var player_instance = player.instantiate()
		var letter_count = 3
		var chosen_indexes = []
		
		if player_instance.CharacterResource.level <= 3:
			letter_count = 3
		elif player_instance.CharacterResource.level > 3 and player_instance.CharacterResource.level <= 6:
			letter_count = 5
		elif player_instance.CharacterResource.level > 6 and player_instance.CharacterResource.level <= 9:
			letter_count = 6
		else:
			letter_count = 10
		
		for index in skill_check_words.size():
			
			if len(skill_check_words[index]) <= letter_count:
				chosen_indexes.append(index)
			else:
				continue
			if skill_check_words[index] == get_most_skipped_word():
				randomize()
				var chance = randi_range(1, 100)
				if chance <= 75:
					print("returning most skipped")
					return index
				else:
					chosen_indexes.append(index)
		
		randomize()
		return chosen_indexes.pick_random()


func search_array(array: Array, value):
	for index in array.size():
		if value == array[index]:
			return index
	return null

func get_most_skipped_word():
	var frequency_dict = {}
	var max_frequency = 0
	var most_frequent_skipped_word = null
	
	for word in skipped_words:
		frequency_dict[word] = frequency_dict.get(word, 0) + 1
		if frequency_dict[word] > max_frequency:
			max_frequency = frequency_dict[word]
			most_frequent_skipped_word = word
	
	return most_frequent_skipped_word

func blank_text(text: String):
	var result = ""
	for i in text.length():
		result += "_ "
	return result


func _on_end_skill_check():
	SkillCheck.visible = false
	ProcessingLabel.visible = false

var completed_text := ""


@onready var speech_to_text: SpeechToText = $SpeechToText

func _on_mic_button_button_up():
	is_STT_processing = true
	
	MicButton.visible = false
	ReadButton.visible = false
	SkipButton.visible = false
	
	await get_tree().create_timer(1.5).timeout
	speech_to_text.stop_recording()
	ProcessingLabel.visible = true
	animation_player.play("processing")
	print("Timer Stopped!")
	await speech_to_text.STT_response_generated
	check_if_skill_check_passed()

var is_STT_processing: bool = false

func _on_mic_button_button_down():
	
	ReadButton.visible = false
	SkipButton.visible = false
	TryAgain.visible = false
	completed_text = ""
	speech_to_text.start_recording()
	


func _on_skip_button_pressed():
	TryAgain.visible = false
	skill_check_stats.append([current_word, current_action, false])
	Global.skill_check_passed = false
	Global.end_skill_check.emit()

func _on_speech_to_text_stt_response_generated(response):
	completed_text = response

var try_again_text = ["Please try again.", "Try again, you can do it!", "You can do it one more time!", "Try again, you got this!"]

var skill_check_passed_array = ["amazing", "good_job", "awesome", "great"]
@onready var skill_check_passed_sprite = $Animations/SkillCheckPassedSprite

#WORD STATE == [current word, skill, passed]

var skill_check_stats = []

func check_if_skill_check_passed():
	
	ProcessingLabel.visible = false
	animation_player.stop()
	if !is_tutorial_skill_check:
		print("Completed Text: " + str(completed_text))
		if current_word in completed_text or current_word.to_lower() in completed_text or current_word.to_upper() in completed_text:
			Global.skill_check_passed = true
			SkillCheck.visible = false
			ProcessingLabel.visible = false
			skill_check_stats.append([current_word, current_action, true])
			randomize()
			var skill_check_index = randi_range(0, 3)
			skill_check_passed_sprite.play(skill_check_passed_array[skill_check_index])
			animation_player.play("skill_check_passed")
			await get_tree().create_timer(0.3).timeout
			Global.play_sfx.emit(skill_check_passed_array[skill_check_index])
			await animation_player.animation_finished
			MicButton.visible = true
			ReadButton.visible = true
			SkipButton.visible = true
			is_STT_processing = false
			Global.end_skill_check.emit()
		else:
			TryAgain.text = try_again_text.pick_random()
			TryAgain.visible = true
			is_STT_processing = false
			MicButton.visible = true
			ReadButton.visible = true
			SkipButton.visible = true
	else:
		current_word = "Apple"
		if current_word in completed_text or current_word.to_lower() in completed_text or current_word.to_upper() in completed_text:
			Global.skill_check_passed = true
			SkillCheck.visible = false
			ProcessingLabel.visible = false
			randomize()
			var skill_check_index = randi_range(0, 3)
			skill_check_passed_sprite.play(skill_check_passed_array[skill_check_index])
			animation_player.play("skill_check_passed")
			await get_tree().create_timer(0.3).timeout
			Global.play_sfx.emit(skill_check_passed_array[skill_check_index])
			await animation_player.animation_finished
			MicButton.visible = true
			ReadButton.visible = true
			SkipButton.visible = true
			is_STT_processing = false
			Global.play_tutorial_cutscene.emit("tutorial_part_5_5")
			is_tutorial_skill_check = false
			current_word = ""
		else:
			TryAgain.text = try_again_text.pick_random()
			TryAgain.visible = true
			is_STT_processing = false
			MicButton.visible = true
			ReadButton.visible = true
			SkipButton.visible = true

@onready var TryAgain = $SkillCheck/MarginContainer/TryAgain

func _on_read_button_pressed():
	TryAgain.visible = false
	DisplayServer.tts_speak(current_word, Global.Voices[Global.VoiceID]["id"])
	#await !DisplayServer.tts_is_speaking()

# ANIMATION STUFF
@onready var animation_player = $AnimationPlayer


func set_tutorial_skill_check():
	is_tutorial_skill_check = true
