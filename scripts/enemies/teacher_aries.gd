extends TextureRect


@onready var health_component = $HealthComponent
@onready var skill_component = $SkillComponent
@onready var speed_component = $SpeedComponent
@onready var select_button = $TextureButton
@export var CharacterResource: Enemy

var current_stun_duration: int = 0
var current_miss_duration: int = 0
var current_damage_duration: int = 0
