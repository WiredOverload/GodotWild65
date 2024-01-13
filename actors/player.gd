extends CharacterBody3D

enum State {
	NEUTRAL,
	THROWING,
}

const SPEED = 5.0

@export var ball: Ball

var state: State = State.NEUTRAL

var throw_speed: float = 0.0

var throw_accel: float = 10.0

@onready var ball_held_position: Marker3D = %BallHeldPosition

func _ready() -> void:
	assert(ball)
	ball.grab(ball_held_position)

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("throw"):
		state = State.THROWING
		ball.grab(ball_held_position)
	if Input.is_action_just_released("throw"):
		state = State.NEUTRAL
		ball.throw(throw_speed * basis.x)
	
	if Input.is_action_pressed("throw"):
		throw_speed += delta * throw_accel

func _physics_process(delta: float) -> void:
	match state:
		State.NEUTRAL:
			var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
			var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)
			
			rotation.y = Vector3.MODEL_FRONT.signed_angle_to(direction, Vector3.UP)
			
			move_and_slide()
		
		State.THROWING:
			rotation.y += throw_speed
			ball.global_position = ball_held_position.global_position
