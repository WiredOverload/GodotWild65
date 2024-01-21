class_name PickupItem
extends Resource

enum Type {
	WALK_SPEED,
	CHARGE_SPEED,
	MAX_HEALTH,
	SPIN_SLOWMO,
	DAMAGE_BONUS,
	SPEED_RETENTION,
	XP_BONUS,
}

static var COLOR_RED = Color.from_ok_hsl(25.0/360.0, 1.0, 0.4)
static var COLOR_ORANGE = Color.from_ok_hsl(55.0/360.0, 1.0, 0.4)
static var COLOR_YELLOW = Color.from_ok_hsl(110.0/360.0, 1.0, 0.4)
static var COLOR_GREEN = Color.from_ok_hsl(140.0/360.0, 1.0, 0.4)
static var COLOR_AQUA = Color.from_ok_hsl(200.0/360.0, 1.0, 0.4)
static var COLOR_BLUE = Color.from_ok_hsl(260.0/360.0, 1.0, 0.4)
static var COLOR_PURPLE = Color.from_ok_hsl(315.0/360.0, 1.0, 0.4)


@export var type: Type
@export var stat_value: float

func display_name() -> String:
	match type:
		Type.WALK_SPEED:
			return "Walk Speed %+d%%" % stat_value
		Type.CHARGE_SPEED:
			return "Charge Speed %+d%%" % stat_value
		Type.MAX_HEALTH:
			return "Max Health %+d" % stat_value
		Type.SPIN_SLOWMO:
			return "Max Speed SlowMo %+d%%" % stat_value
		Type.DAMAGE_BONUS:
			return "Damage %+d%%" % stat_value
		Type.SPEED_RETENTION:
			return "Bounce Efficiency %+d%%" % stat_value
		Type.XP_BONUS:
			return "XP %+d%%" % stat_value
	assert(false)
	return "Unknown"


func display_color() -> Color:
	match type:
		Type.WALK_SPEED:
			return COLOR_GREEN
		Type.CHARGE_SPEED:
			return COLOR_BLUE
		Type.MAX_HEALTH:
			return COLOR_RED
		Type.SPIN_SLOWMO:
			return COLOR_AQUA
		Type.DAMAGE_BONUS:
			return COLOR_ORANGE
		Type.SPEED_RETENTION:
			return COLOR_YELLOW
		Type.XP_BONUS:
			return COLOR_PURPLE
	assert(false)
	return Color.MAGENTA
