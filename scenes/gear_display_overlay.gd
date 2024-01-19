extends Control

const GEAR_TO_SPARK_RATIO = [0.0, 0.1, 0.2, 0.3, 0.5, 1.0]

@export var charge_beam_flipbook: Array[Texture2D] = []

@onready var gear_control: Control = %GearControl
@onready var sparks: GPUParticles2D = %Sparks
@onready var sparks_material: ParticleProcessMaterial = sparks.process_material
@onready var gear_label: Label = %GearLabel

@onready var frame: NinePatchRect = %Frame
@onready var divider_1: NinePatchRect = %Divider1
@onready var meter_container: MarginContainer = $MeterContainer
@onready var xp_bar: NinePatchRect = $MeterContainer/XPContainer/Control/XPBar
@onready var lock_container: Control = %LockContainer
@onready var lock_1: TextureRect = %Lock1
@onready var break_1: GPUParticles2D = %Break1
@onready var beam: TextureRect = %Beam
@onready var beam_head: TextureRect = %BeamHead

var _locks: Array[Control] = []
var _breaks: Array[GPUParticles2D] = []

var _last_gear := -1

var _beam_anim_frame := 0

var _sparks_hue: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	(func ():
		
		# setup dividers
		divider_1.position.x = roundf(frame.size.x / 5.0) - 16.0
		for i: int in range(2, 5):
			var divider := divider_1.duplicate()
			divider.name = "Divider%s" % i
			frame.add_child(divider)
			divider.position.x = roundf(i * frame.size.x / 5.0) - 16.0
		
		# setup locks
		lock_1.position.x = roundf(lock_container.size.x / 5.0) - 16.0
		_locks.append(lock_1)
		break_1.position.x = lock_1.position.x + 16.0
		_breaks.append(break_1)
		for i: int in range(2, 6):
			var lock := lock_1.duplicate()
			_locks.append(lock)
			lock.name = "Lock%s" % i
			lock_container.add_child(lock)
			lock.position.x = roundf(i * lock_container.size.x / 5.0) - 16.0
			if i == 5:
				lock.position.x -= 2
			var break_ = break_1.duplicate()
			_breaks.append(break_)
			break_.name = "Break%s" % i
			lock_container.add_child(break_)
			break_.position.x = lock.position.x + 16.0
		
		
		Globals.stat_changed.connect(_on_stat_changed)
		_on_stat_changed()
	).call_deferred()
	

func _process(delta: float) -> void:
	if _last_gear == -1:
		return
	
	if gear_control.visible and _last_gear == 5:
		_sparks_hue = wrapf(_sparks_hue + delta, 0.0, 1.0)
		sparks_material.color = Color.from_ok_hsl(_sparks_hue, 1.0, 0.8)
	

func _on_stat_changed() -> void:
	var gear := clampi(Globals.current_gear, 0, 5)
	if gear != _last_gear:
		gear_control.visible = gear != 0
		if gear_control.visible:
			gear_control.position.x = gear_control.get_parent().size.x * gear / 5.0 - 16.0
			sparks.amount_ratio = GEAR_TO_SPARK_RATIO[gear]
			sparks.trail_lifetime = lerpf(0.1, 0.2, gear / 5.0)
			sparks.restart()
			var l := lerpf(1.0, 0.88, (gear - 1) / 4.0)
			sparks_material.color = Color.from_ok_hsl(0.2, 1.0, l)
			gear_label.text = str(gear)
		_last_gear = gear
	
	# xp bar
	xp_bar.size.x = xp_bar.get_parent().size.x * Globals.ball_power_max / 5.0
	
	# locks
	for i: int in range(1, 6):
		var locked := i > Globals.current_max_gear
		if _locks[i - 1].visible and not locked:
			_breaks[i - 1].emitting = true
		_locks[i - 1].visible = locked
	
	# beam
	if is_zero_approx(Globals.ball_power):
		beam.visible = false
		beam_head.visible = false
	else:
		beam.visible = true
		beam_head.visible = true
		beam.size.x = beam.get_parent().size.x * Globals.ball_power / 5.0
		beam_head.position.x = beam.size.x - 1


func _on_beam_anim_timer_timeout() -> void:
	if charge_beam_flipbook.is_empty():
		return
	
	_beam_anim_frame = (_beam_anim_frame + 1) % charge_beam_flipbook.size()
	beam.texture = charge_beam_flipbook[_beam_anim_frame]
