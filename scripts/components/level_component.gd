extends Node2D

@export var CharacterResource: PlayerResource
var level

#level x value

var experience = 0
var experience_total = 0
var experience_required

func _process(_delta):
	State.level = CharacterResource.level
	CharacterResource.experience = experience
	CharacterResource.experience_required = experience_required

func _ready():
	level = CharacterResource.level
	CharacterResource.experience = experience
	experience_required = get_required_experience(level + 1)
	CharacterResource.experience_required = experience_required
	

func get_required_experience(_level):
	return round(pow(_level, 1.8) + _level * 4)

func gain_experience(amount):
	experience_total += amount
	experience += amount
	print(experience_required)
	while experience >= experience_required:
		experience -= experience_required
		level_up()

func level_up():
	level += 1
	CharacterResource.level = level
	CharacterResource.strength += 3
	CharacterResource.max_health += 15
	CharacterResource.max_mana += 15
	CharacterResource.initial_armor += 2
	
	Global.start_interactable_dialogue.emit(load("res://assets/resources/dialogues/level_up.dialogue"), "start")
	experience_required = get_required_experience(level + 1)
