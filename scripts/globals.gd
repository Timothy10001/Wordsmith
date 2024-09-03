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

signal enter_new_room

signal enter_new_area
signal update_area

signal dialogue_active
signal dialogue_ended

signal overlay_active
signal overlay_inactive

signal mic_pressed
signal mic_released

#for npc dialogue font
var npc_class = ""

#item and skill description for battle dialogue
var skill_description: String
var item_description: String

var skill_check_passed: bool = false

var current_player_position: Vector2




