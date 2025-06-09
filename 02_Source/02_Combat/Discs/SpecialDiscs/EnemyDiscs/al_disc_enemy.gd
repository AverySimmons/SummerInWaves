extends EnemyDisc

const CENTER_OF_RING = Vector2(640, 360)
const AL_SPECIAL_MOVE_TIMER_LOWER = 4
const AL_SPECIAL_MOVE_TIMER_UPPER = 7

# Strength of Al's charge. 1 means velocity would be exactly the length from the special disc to the center.
@export var strength_of_charge: float = 2.4
@export var min_charge_speed: float = 700
var charge_direction_random_x_subtractimator: float = 100
var charge_direction_random_y_subtractimator: float = charge_direction_random_x_subtractimator*(9/16)

var charge_dir: Vector2
var charge_speed: float

func _ready() -> void:
	super._ready()
	# Make it 2x heavier? Up to you guys
	$RedCircle.offset = Vector2(0, 0)
	mass = mass*2
	special_move_timer = randf_range(AL_SPECIAL_MOVE_TIMER_LOWER, AL_SPECIAL_MOVE_TIMER_UPPER)
	
	await get_tree().create_timer(2).timeout
	get_new_point()
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	$IndicatorTrans.global_rotation = charge_dir.angle()
	var charge_len = (1. - clamp(special_move_timer / (AL_SPECIAL_MOVE_TIMER_LOWER - 2), 0, 1)) * 145
	$IndicatorTrans/Indicator.size.x = charge_len
	$IndicatorTrans/Indicator.material.set_shader_parameter("sizex", charge_len)
	
	special_move_timer -= delta
	if special_move_timer <= 0:
		charge_to_center_ability()
		special_move_timer = randf_range(AL_SPECIAL_MOVE_TIMER_LOWER, AL_SPECIAL_MOVE_TIMER_UPPER)
	pass

func get_new_point():
	var near_center: Vector2 = Vector2(randf_range(CENTER_OF_RING.x-charge_direction_random_x_subtractimator,
										CENTER_OF_RING.x+charge_direction_random_x_subtractimator),
										randf_range(CENTER_OF_RING.y-charge_direction_random_y_subtractimator,
										CENTER_OF_RING.y+charge_direction_random_y_subtractimator))
	var vector_to_center: Vector2 = near_center - center_of_mass
	var direction_to_center: Vector2 = vector_to_center.normalized()
	var speed: float = max(vector_to_center.length()*(strength_of_charge), min_charge_speed)
	charge_dir = direction_to_center
	charge_speed = speed

func charge_to_center_ability() -> void:
	# Charge visuals maybe?
	#sound
	$AlEnemyCharge.play()
	
	velocity = charge_speed * charge_dir
	await get_tree().create_timer(1.5).timeout
	get_new_point()
	return
