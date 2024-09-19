extends CharacterBody2D

enum STATE {
	IDLE,
	CHOOSE_DIRECTION,
	MOVE,
	CHASE
}

@export var enemy_name: String
@export var enemy_battle_scene: PackedScene
@export var sprite: AnimatedSprite2D
@export var detection_area: float = 0
@export var enemy_collision: CollisionShape2D
@export var speed: float

@onready var timer = $Timer

var enemy_state = STATE.IDLE
var direction = Vector2.DOWN
var player = null

func _ready():
	randomize()
	$DetectionArea/CollisionShape2D.shape.radius = detection_area
	Global.end_battle.connect(_on_end_battle)


func _physics_process(delta):
	if enemy_state == STATE.CHASE:
		var direction_to_player = player.global_position - global_position
		
		var x_abs = abs(direction_to_player.x)
		var y_abs = abs(direction_to_player.y)
		
		if x_abs > y_abs:
			direction = Vector2(sign(direction_to_player.x), 0)
		else:
			direction = Vector2(0, sign(direction_to_player.y))
		
		var movement = direction * speed * delta
		move_and_collide(movement)
		#position += (player.position - position).normalized() * speed * delta
		#move_and_collide(Vector2(0,0))


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
		match enemy_state:
			STATE.IDLE:
				pass
			STATE.CHOOSE_DIRECTION:
				direction = randomize_array([Vector2.RIGHT, Vector2.UP, Vector2.DOWN, Vector2.LEFT])
			STATE.MOVE:
				move(delta)
			_:
				pass

func move(delta):
	velocity = direction * speed
	move_and_slide()

func randomize_array(array: Array):
	array.shuffle()
	return array.front()

func _on_detection_area_body_entered(body):
	if body is Player:
		player = body
		enemy_state = STATE.CHASE

func _on_detection_area_body_exited(body):
	if body is Player:
		player = null
		enemy_state = STATE.IDLE

func _on_timer_timeout():
	if enemy_state != STATE.CHASE:
		timer.wait_time = randomize_array([0.5, 1.0, 1.5])
		enemy_state = randomize_array([STATE.IDLE, STATE.CHOOSE_DIRECTION, STATE.MOVE])

func _on_end_battle(state, _type: String):
	if state == "Win":
		queue_free()
	elif state == "Lose":
		pass



