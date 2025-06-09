extends EnemyDisc

const ELM_SPECIAL_MOVE_TIMER_LOWER = 9
const ELM_SPECIAL_MOVE_TIMER_UPPER = 13
const GRAVITATION_TIME = 3

# Controls acceleration of pull. 1.0 would mean all sucked in discs receive idk yet tbh
var strength_of_pull: float = 1.0
var mass_increase: float = 3.0
var gravitation_timer: float = 0
var normal_mass: float

func _ready() -> void:
	super._ready()
	normal_mass = mass
	special_move_timer = randf_range(ELM_SPECIAL_MOVE_TIMER_LOWER, ELM_SPECIAL_MOVE_TIMER_UPPER)
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	special_move_timer -= delta
	if special_move_timer <= 0:
		mass = mass * mass_increase
		gravitation_timer = GRAVITATION_TIME
		special_move_timer = randf_range(ELM_SPECIAL_MOVE_TIMER_LOWER, ELM_SPECIAL_MOVE_TIMER_UPPER)
		$GravityPull/AnimationPlayer.play("gravity_pull")
		#sound
		$ElmGravPull.play()
	
	if gravitation_timer >= 0:
		gravity_ability(delta)
		gravitation_timer -= delta
	else:
		mass = normal_mass
		$GravityPull/AnimationPlayer.play("RESET")
		#sound
		$ElmGravPull.stop()
	pass

func gravity_ability(delta: float) -> void:
	# Gravity wave visuals maybe
	#
	#
	var discs_in_gravity = $GravityRing.get_overlapping_areas()
	for disc in discs_in_gravity:
		var direction_from_other_disc: Vector2 = (position - disc.position).normalized()
		disc.velocity += 1000 * direction_from_other_disc * strength_of_pull * delta
	return
