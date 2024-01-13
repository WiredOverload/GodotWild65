extends CharacterBody3D

enum State {
	NEUTRAL,
	THROWING,
	CATCHING
}

var move_speed: float = 5.0
var move_speed_throwing: float = 1.0

@export var ball: Ball

var state: State = State.NEUTRAL: set = set_state

var throw_speed: float = 0.0
var max_throw_speed: float = 20.0

var throw_accel: float = 10.0

@onready var ball_held_position: Marker3D = %BallHeldPosition
@onready var catch_area: Area3D = %CatchArea
@onready var catcher: CSGBox3D = %Catcher
@onready var spin_spark_particles: GPUParticles3D = %SpinSparkParticles

@onready var hold_distance: float = Vector3(ball_held_position.position.x, 0, ball_held_position.position.z).length()

func _ready() -> void:
	assert(ball)
	ball.grab(ball_held_position)
	deactivate_catcher()

func _process(delta: float) -> void:
	match state:
		State.NEUTRAL:
			if Input.is_action_just_pressed("action"):
				if ball.is_held:
					state = State.THROWING
				else:
					state = State.CATCHING
		State.THROWING:
			if Input.is_action_pressed("action"):
				throw_speed = clampf(throw_speed + delta * throw_accel, 0.0, max_throw_speed)
				if not spin_spark_particles.emitting and is_equal_approx(throw_speed, max_throw_speed):
					spin_spark_particles.restart()
				if spin_spark_particles.emitting and not is_equal_approx(throw_speed, max_throw_speed):
					spin_spark_particles.emitting = false
			else:
				ball.throw(throw_speed * basis.x)
				throw_speed = 0.0
				state = State.NEUTRAL
		State.CATCHING:
			if Input.is_action_pressed("action"):
				var ob := catch_area.get_overlapping_bodies()
				assert(ob.size() < 2)
				if ob.size() == 1:
					assert(ob[0] == ball)
					state = State.THROWING
					throw_speed = ball.current_speed
					ball.grab(ball_held_position)
			else:
				state = State.NEUTRAL

func set_state(v: State) -> void:
	# exiting state
	match state:
		State.CATCHING:
			deactivate_catcher()
		State.THROWING:
			spin_spark_particles.emitting = false
	
	state = v
	
	# entering state
	match state:
		State.CATCHING:
			activate_catcher()

func _physics_process(delta: float) -> void:
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := Vector3(input_dir.x, 0, input_dir.y).normalized()
	
	match state:
		State.NEUTRAL, State.CATCHING:
			if direction:
				velocity.x = direction.x * move_speed
				velocity.z = direction.z * move_speed
			else:
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
			
			rotation.y = Vector3.MODEL_FRONT.signed_angle_to(direction, Vector3.UP)
			
			move_and_slide()
		State.THROWING:
			rotation.y += delta * throw_speed / hold_distance
			ball.global_position = ball_held_position.global_position
			
			if direction:
				velocity.x = direction.x * move_speed_throwing
				velocity.z = direction.z * move_speed_throwing
			else:
				velocity.x = move_toward(velocity.x, 0, move_speed)
				velocity.z = move_toward(velocity.z, 0, move_speed)
			
			move_and_slide()

func activate_catcher() -> void:
	catch_area.monitoring = true
	catcher.visible = true

func deactivate_catcher() -> void:
	catch_area.monitoring = false
	catcher.visible = false