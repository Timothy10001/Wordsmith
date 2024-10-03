extends Node

var level: int

var current_room
var current_area
var player_position
var current_direction

var current_mission_enemy_count: int
var current_mission_enemy_required: int


#mission 0 is tutorial
var tutorial_status: String = "not done"
var current_mission: int = 0

#mission 1 shit
var briefed_by_mr_cheese: bool = false
var unlocked_key_house: bool = false

var unlocked_igloo: bool = false

var briefed_by_principal_ronnie: bool = false


var mission_1_done: bool = false
var mission_2_done: bool = false
var mission_3_done: bool = false
