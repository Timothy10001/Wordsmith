extends Resource
class_name Skill


@export var name: String
@export var description: String
@export_enum("ALL", "SINGLE") var target: String

@export var attack_damage: int
@export var heal_amount: int

@export var mana_amount: int
@export var mana_cost: int

@export var deals_damage: bool

@export var requires_skill_check: bool

@export_enum("none", "damage over time", "stun", "miss") var status_effect: String = "none"

@export var stun_duration: int = 0
@export var chance: int = 0
