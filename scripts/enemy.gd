extends CharacterBody2D

enum STATE {
	IDLE,
	CHOOSE_DIRECTION,
	MOVE,
	CHASE
}

@export var enemy_name: String
@export var enemy_battle_path: String
@export var sprite: AnimatedSprite2D
@export var detection_area: float = 0
@export var battle_area: float = 0
@export var enemy_collision: CollisionShape2D
@export var speed: float
@export var chases: bool

@onready var timer = $Timer
@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D

var enemy_state = STATE.IDLE
var direction = Vector2.DOWN
var player = null
var area_entered: bool = false


func _ready():
	randomize()
	$DetectionArea/CollisionShape2D.shape.radius = detection_area
	$BattleArea/CollisionShape2D.shape.radius = battle_area


func _physics_process(_delta):
	if enemy_state == STATE.CHASE:
		Global.chased = true
		navigation_agent.target_position = player.global_position
		if navigation_agent.is_navigation_finished():
			return
		var next_path_position = navigation_agent.get_next_path_position()
		
		direction = global_position.direction_to(next_path_position)
		
		var x_abs = abs(direction.x)
		var y_abs = abs(direction.y)
		
		if x_abs > y_abs:
			direction = Vector2(sign(direction.x), 0)
		else:
			direction = Vector2(0, sign(direction.y))
		
		velocity = direction * speed
		
		move_and_slide()


func _process(delta):
	if enemy_state == STATE.IDLE:
		sprite.play("idle")
	elif enemy_state == STATE.MOVE or enemy_state == STATE.CHASE:
		if direction.x == -1:
			sprite.play("run_left")
		if direction.x == 1:
			sprite.play("run_right")
		if direction.y == -1:
			sprite.play("run_up")
		if direction.y == 1:
			sprite.play("run_down")
	
	if enemy_state != STATE.CHASE:
		Global.chased = false
		match enemy_state:
			STATE.IDLE:
				pass
			STATE.CHOOSE_DIRECTION:
				direction = randomize_array([Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.LEFT])
			STATE.MOVE:
				move(delta)
			_:
				pass

func move(_delta):
	velocity = direction * speed
	move_and_slide()

func randomize_array(array: Array):
	array.shuffle()
	return array.front()

func _on_detection_area_body_entered(body):
	if body is Player:
		player = body
		if chases and not area_entered:
			enemy_state = STATE.CHASE

func _on_detection_area_body_exited(body):
	if body is Player:
		Global.chased = false
		player = null
		enemy_state = STATE.IDLE

func _on_detection_area_area_entered(area):
	if area.name == "DetectionArea":
		area_entered = true
		enemy_state = STATE.IDLE

func _on_detection_area_area_exited(area):
	if area.name == "DetectionArea":
		area_entered = false

func _on_timer_timeout():
	if enemy_state != STATE.CHASE:
		timer.wait_time = randomize_array([0.5, 0.75, 1.0])
		enemy_state = randomize_array([STATE.IDLE, STATE.CHOOSE_DIRECTION, STATE.MOVE])



func _on_battle_area_body_entered(body):
	if body is Player:
		enemy_state = STATE.IDLE
		Global.start_battle.emit(["res://scenes/player.tscn"], [enemy_battle_path], "res://assets/art/backgrounds/tutorial.png", "battle", self)






