extends Node

signal start_game
signal save_game

signal back_to_lobby

signal start_battle
signal end_battle
signal lost_battle
signal unit_is_dead

signal execute
signal start_skill_check
signal end_skill_check
signal all_turns_finished

signal transition
signal transition_finished

signal get_mission
signal confirm_mission
signal cancel_mission

signal enter_new_room(_new_room_index: int, _player_position: Vector2)

signal enter_new_area(_area: String, _room_index: int)

signal dialogue_active
signal dialogue_ended
signal start_npc_dialogue

signal overlay_active
signal overlay_inactive

signal interactable_entered
signal interactable_exited
signal start_interactable_dialogue

signal mic_pressed
signal mic_released

signal start_sleep
signal end_sleep

signal cutscene_start(cutscene: String)
var cutscene_playing: bool = false
signal cutscene_ended
signal stop_cutscene

signal add_mission_rewards(inventory_path: String)
signal drop_item(inventory_slot: InventorySlot)

var experience: int
#for npc dialogue font
var npc_class = ""

var chased: bool
var is_inside_detection_area: bool = false
#item and skill description for battle dialogue
var skill_description: String
var item_name: String
var item_quantity: int

var skill_check_passed: bool = false

var in_battle: bool = false

var Voices: Array[Dictionary] = DisplayServer.tts_get_voices()
var VoiceID: int = 0
var TTS_available: bool

var enemy_battle_active: bool = true
"""
MISSION 1 - OUTSIDE INDEX
0 = main
1 - 3 = north
4 - ? = east
"""


var area_list = {
	"lobby" : ["res://scenes/areas/lobby/rooms/throne_room.tscn", "res://scenes/areas/lobby/rooms/training_room.tscn"],
	"mission 1 - outside": ["res://scenes/areas/mission 1/rooms/outside.tscn", "res://scenes/areas/mission 1/rooms/north_001.tscn", "res://scenes/areas/mission 1/rooms/north_002.tscn", "res://scenes/areas/mission 1/rooms/north_003.tscn", "res://scenes/areas/mission 1/rooms/east_001.tscn", "res://scenes/areas/mission 1/rooms/east_002.tscn"],
	"mission 1 - tavern": ["res://scenes/areas/mission 1/rooms/tavern_001.tscn", "res://scenes/areas/mission 1/rooms/tavern_002.tscn", "res://scenes/areas/mission 1/rooms/tavern_003.tscn", "res://scenes/areas/mission 1/rooms/tavern_004.tscn"],
	"mission 1 - den": ["res://scenes/areas/mission 1/rooms/den_001.tscn", "res://scenes/areas/mission 1/rooms/den_002.tscn"],
	"mission 1 - house": ["res://scenes/areas/mission 1/rooms/house.tscn"],
	"mission 2 - outside": ["res://scenes/areas/mission 2/rooms/outside.tscn"],
	"mission 2 - house": ["res://scenes/areas/mission 2/rooms/house_001.tscn", "res://scenes/areas/mission 2/rooms/house_002.tscn"],
	"mission 2 - shed": ["res://scenes/areas/mission 2/rooms/shed.tscn"],
	"mission 2 - igloo": ["res://scenes/areas/mission 2/rooms/igloo_001.tscn", "res://scenes/areas/mission 2/rooms/igloo_002.tscn", "res://scenes/areas/mission 2/rooms/igloo_003.tscn"],
	"mission 2 - highway": ["res://scenes/areas/mission 2/rooms/highway.tscn", "res://scenes/areas/mission 2/rooms/highway_scrolling.tscn"],
	"mission 3 - outside": ["res://scenes/areas/mission 3/rooms/outside.tscn"],
	"mission 3 - school": ["res://scenes/areas/mission 3/rooms/school_001.tscn", "res://scenes/areas/mission 3/rooms/school_002.tscn"],
	"mission 3 - classroom": ["res://scenes/areas/mission 3/rooms/classroom_001.tscn", "res://scenes/areas/mission 3/rooms/classroom_002.tscn", "res://scenes/areas/mission 3/rooms/classroom_003.tscn", "res://scenes/areas/mission 3/rooms/classroom_004.tscn", "res://scenes/areas/mission 3/rooms/classroom_005.tscn"],
	"mission 3 - stock room": ["res://scenes/areas/mission 3/rooms/stock_room.tscn"]
}





