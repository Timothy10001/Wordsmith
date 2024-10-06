class_name SavedGame
extends Resource

@export var current_area_name: String 
@export var current_room: int 
@export var current_mission: int 
@export var tutorial_status: String
@export var player_position: Vector2 
@export var current_direction: String

@export var initial_position: Vector2

@export var current_mission_enemy_count: int
@export var current_mission_enemy_required: int

@export var briefed_by_mr_cheese: bool
@export var unlocked_key_house: bool
@export var briefed_by_principal_ronnie: bool
@export var unlocked_igloo: bool


@export var removed_enemies: Array[String]

@export var mission_1_done: bool
@export var mission_2_done: bool
@export var mission_3_done: bool

@export var world_inventory: Dictionary

@export var was_in_mission: bool
