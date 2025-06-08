extends EnemyDisc

const PERI_SPECIAL_MOVE_TIMER_LOWER = 4
const PERI_SPECIAL_MOVE_TIMER_UPPER = 7
const WALL_TIME = 3

var mass_increase: float = 10000
var wall_timer: float = 0
var normal_mass: float
var stored_velocity: Vector2

func _ready() -> void:
	super._ready()
	normal_mass = mass
	special_move_timer = randf_range(PERI_SPECIAL_MOVE_TIMER_LOWER, PERI_SPECIAL_MOVE_TIMER_UPPER)
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	special_move_timer -= delta
	if special_move_timer <= 0:
		mass = mass * mass_increase
		
		stored_velocity = velocity
		velocity = Vector2(0, 0)
		
		wall_timer = WALL_TIME
		special_move_timer = randf_range(PERI_SPECIAL_MOVE_TIMER_LOWER, PERI_SPECIAL_MOVE_TIMER_UPPER)
	
	
	var wall_timer_was_positive: bool = wall_timer > 0
	if wall_timer >= 0:
		rotational_velocity = 0
		wall_timer -= delta
	
	# After ability done
	if wall_timer_was_positive && wall_timer <= 0:
		mass = normal_mass
		velocity = stored_velocity
		
	pass
