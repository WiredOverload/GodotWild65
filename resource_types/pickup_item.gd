class_name PickupItem
extends Resource

enum Type {
	WALK_SPEED,
	CHARGE_SPEED,
}

static var COLOR_GREEN = Color.from_ok_hsl(140.0/360.0, 1.0, 0.4)
static var COLOR_BLUE = Color.from_ok_hsl(260.0/360.0, 1.0, 0.4)
static var COLOR_YELLOW = Color.from_ok_hsl(110.0/360.0, 1.0, 0.4)
static var COLOR_PURPLE = Color.from_ok_hsl(315.0/360.0, 1.0, 0.4)

@export var type: Type
@export var stat_value: float

func display_name() -> String:
	match type:
		Type.WALK_SPEED:
			return "Walk Speed %+d%%" % stat_value
		Type.CHARGE_SPEED:
			return "Charge Speed %+d%%" % stat_value
	assert(false)
	return "Unknown"


func display_color() -> Color:
	match type:
		Type.WALK_SPEED:
			return COLOR_GREEN
		Type.CHARGE_SPEED:
			return COLOR_BLUE
	assert(false)
	return Color.MAGENTA
