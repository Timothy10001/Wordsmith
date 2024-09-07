extends Node

signal start_game
signal save_game

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
signal update_area

signal dialogue_active
signal dialogue_ended

signal overlay_active
signal overlay_inactive

signal interactable_entered
signal interactable_exited
signal start_interactable_dialogue

signal mic_pressed
signal mic_released

signal player_rest_start
signal player_rest_end

#for npc dialogue font
var npc_class = ""

#item and skill description for battle dialogue
var skill_description: String
var item_description: String

var skill_check_passed: bool = false

var in_battle: bool = false

"""
MISSION 1 - OUTSIDE INDEX
0 = main
1 - 3 = north
4 - ? = east
"""


var area_list = {
	"lobby" : ["res://scenes/areas/lobby/rooms/throne_room.tscn"],
	"mission 1 - outside": ["res://scenes/areas/mission 1/rooms/outside.tscn", "res://scenes/areas/mission 1/rooms/north_001.tscn", "res://scenes/areas/mission 1/rooms/north_002.tscn", "res://scenes/areas/mission 1/rooms/north_003.tscn", "res://scenes/areas/mission 1/rooms/east_001.tscn", "res://scenes/areas/mission 1/rooms/east_002.tscn"],
	"mission 1 - tavern": ["res://scenes/areas/mission 1/rooms/tavern_001.tscn", "res://scenes/areas/mission 1/rooms/tavern_002.tscn", "res://scenes/areas/mission 1/rooms/tavern_003.tscn", "res://scenes/areas/mission 1/rooms/tavern_004.tscn"],
	"mission 1 - den": [],
	"mission 1 - house": ["res://scenes/areas/mission 1/rooms/house.tscn"]
}




