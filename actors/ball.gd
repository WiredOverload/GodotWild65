class_name Ball
extends CharacterBody3D

const MAX_BOUNCES := 10

enum State {
	HELD,
	MOVING,
}

var current_speed = 15.0

var state: State = State.MOVING

var held_marker: Node3D

var is_held: bool:
	get: return state == State.HELD

func _physics_process(delta: float) -> void:
	match state:
		State.HELD:
			position = held_marker.global_position
			return
		State.MOVING:
			var motion := velocity * delta
			var collision := move_and_collide(motion)
			var bounce_count := 0
			while collision:
				var normal := collision.get_normal()
				normal = Vector3(normal.x, 0, normal.z).normalized()
				Gameplay.instance.screen_shake_vel(-Vector2(normal.x, normal.z).normalized() * velocity.length())
				velocity = velocity.bounce(normal)
				motion = collision.get_remainder().bounce(normal)
				if collision.get_collider().is_in_group("Enemy"):
					collision.get_collider().hit(1)
				bounce_count += 1
				if bounce_count >= MAX_BOUNCES:
					break
				collision = move_and_collide(motion)

func grab(marker: Node3D) -> void:
	state = State.HELD
	held_marker = marker

func throw(vel: Vector3) -> void:
	state = State.MOVING
	current_speed = vel.length()
	velocity = vel
