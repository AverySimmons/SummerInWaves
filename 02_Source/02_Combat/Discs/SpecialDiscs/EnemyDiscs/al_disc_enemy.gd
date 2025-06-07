extends EnemyDisc

const CENTER_OF_RING = Vector2(640, 360)
const AL_SPECIAL_MOVE_TIMER = 7

# Strength of Al's charge. 10 means velocity would be exactly the length from the special disc to the center.
@export var strength_of_charge: float = 18
@export var min_charge_speed: float = 500

func _ready() -> void:
	super._ready()
	# Make it 2x heavier?
	mass = mass*2
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	special_move_timer -= delta
	if special_move_timer <= 0:
		charge_to_center_ability()
		special_move_timer = AL_SPECIAL_MOVE_TIMER
	pass


func charge_to_center_ability() -> void:
	var vector_to_center: Vector2 = CENTER_OF_RING - center_of_mass
	var direction_to_center: Vector2 = vector_to_center.normalized()
	var speed: float = max(vector_to_center.length()*(strength_of_charge/10), min_charge_speed)
	velocity = speed * direction_to_center
	print(velocity)
	return
