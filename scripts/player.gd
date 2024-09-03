extends CharacterBody2D
class_name Player

@export var CharacterResource: PlayerResource
@onready var health_component = $HealthComponent
@onready var skill_component = $SkillComponent
@onready var mana_component = $ManaComponent
@onready var speed_component = $SpeedComponent

const SPEED = 100.0
var current_direction = "none"
var is_moving = false

func _ready():
	$AnimatedSprite2D.play("idle")

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
				animation.flip_h = false
				animation.play("run")
			"left":
				animation.flip_h = true
				animation.play("run")
			"up":
				animation.play("idle")
			"down":
				animation.play("idle")
			"none":
				animation.play("idle")
	elif !is_moving:
		animation.play("idle")
	
	
