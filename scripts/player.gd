extends CharacterBody2D
class_name Player

@export var CharacterResource: PlayerResource
@export var inventory: Inventory

@onready var health_component = $HealthComponent
@onready var skill_component = $SkillComponent
@onready var mana_component = $ManaComponent
@onready var speed_component = $SpeedComponent
@onready var level_component = $LevelComponent
@onready var camera = $Camera2D

var current_stun_duration: int = 0
var current_miss_duration: int = 0
var current_damage_duration: int = 0

const SPEED = 125.0
var current_direction = "none"
var is_moving = false

func _ready():
	#limits camera to size of tilemap
	if !Global.in_battle and get_parent() is TileMap:
		var tilemap_rect = get_parent().get_used_rect()
		var tilemap_size = get_parent().tile_set.tile_size
		camera.limit_left = tilemap_rect.position.x * tilemap_size.x
		camera.limit_right = tilemap_rect.end.x * tilemap_size.x
		camera.limit_top = tilemap_rect.position.y * tilemap_size.y
		camera.limit_bottom = tilemap_rect.end.y * tilemap_size.y
		
		play_animation()


func _physics_process(_delta):
	player_movement(_delta)
# PLAYER MOVEMENT ON OVERWORLD
func player_movement(_delta):
	if Input.is_action_pressed("ui_right"):
		is_moving = true
		play_animation()
		current_direction = "right"
		velocity.x = SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		is_moving = true
		play_animation()
		current_direction = "left"
		velocity.x = -SPEED
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		is_moving = true
		play_animation()
		current_direction = "down"
		velocity.x = 0
		velocity.y = SPEED
	elif Input.is_action_pressed("ui_up"):
		is_moving = true
		play_animation()
		current_direction = "up"
		velocity.x = 0
		velocity.y = -SPEED
	else:
		play_animation()
		is_moving = false
		current_direction = "none"
		velocity.x = 0
		velocity.y = 0
	move_and_slide()

func play_animation():
	var direction = current_direction
	var animation = $AnimatedSprite2D
	if is_moving:
		match direction:
			"right":
				animation.flip_h = true
				animation.play("walk_left")
			"left":
				animation.flip_h = false
				animation.play("walk_left")
			"up":
				animation.play("walk_up")
			"down":
				animation.play("walk_down")
			"none":
				animation.play("idle_down")
	elif !is_moving:
		match direction:
			"right":
				animation.flip_h = true
				animation.play("idle_left")
			"left":
				animation.flip_h = false
				animation.play("idle_left")
			"up":
				animation.play("idle_up")
			"down":
				animation.play("idle_down")
			"none":
				animation.play("idle_down")
	
	
