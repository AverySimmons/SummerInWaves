extends AllyDisc

const AL_SPECIAL_MOVE_TIMER_LOWER = 6
const AL_SPECIAL_MOVE_TIMER_UPPER = 8
const ABILITY_MASS_INCREASE_TIME = 3

var ability_mass_increase: int = 10000
var ability_mass_increase_timer: float = 0
var regular_mass_increase: float = 2
var original_mass: float
# Velocity that it is set to
var strength_of_charge: int = 1300
var target: EnemyDisc

var is_charging: bool = false
var charge_dir: Vector2

func _ready() -> void:
	super._ready()
	# Prepare mass
	mass = mass * regular_mass_increase
	original_mass = mass
	
	special_move_timer = randf_range(AL_SPECIAL_MOVE_TIMER_LOWER, AL_SPECIAL_MOVE_TIMER_UPPER)
	# Setting target
	target = find_target()
	pass

func _process(delta: float) -> void:
	if target:
		$Target.global_position = target.global_position
		$Target.visible = true
	else:
		$Target.visible = false

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	var endpoint = global_position + charge_dir 
	if not is_charging:
		if target: endpoint = target.global_position
		else: endpoint = Vector2(640, 360)
	
	$IndicatorTrans.global_rotation = global_position.angle_to_point(endpoint)
	var charge_len = (1. - clamp(special_move_timer / (AL_SPECIAL_MOVE_TIMER_LOWER - 2), 0, 1)) * 200
	$IndicatorTrans/Indicator.size.x = charge_len
	$IndicatorTrans/Indicator.material.set_shader_parameter("sizex", charge_len)
	
	
	if is_charging:
		if $PlayspaceCheck.has_overlapping_areas():
			velocity = charge_dir * strength_of_charge
		return
	
	# If target despawned, find a new target
	if (target == null):
		target = find_target()
	
	special_move_timer -= delta
	if special_move_timer <= 0 && target != null:
		charge_to_target()
		special_move_timer = randf_range(AL_SPECIAL_MOVE_TIMER_LOWER, AL_SPECIAL_MOVE_TIMER_UPPER)
		ability_mass_increase_timer = ABILITY_MASS_INCREASE_TIME
		mass = mass * ability_mass_increase
	
	var mass_timer_was_positive: bool = ability_mass_increase_timer > 0
	if ability_mass_increase_timer > 0:
		ability_mass_increase_timer -= delta
	
	# After ability done
	if mass_timer_was_positive && ability_mass_increase_timer <= 0:
		mass = original_mass
	pass


func charge_to_target() -> void:
	# Visuals maybe? For the charge
	#sound
	$AlChargeSound.play()
	
	charge_dir = (target.position - position).normalized()
	is_charging = true
	
	return

func find_target() -> EnemyDisc:
	var enemy_discs: Array[Disc] = GameData.combat_manager.enemy_live_discs()
	# Exception handling
	if (enemy_discs.size() == 0):
		return null
	
	var target_index: int = randi_range(0, enemy_discs.size()-1)
	var target_disc = enemy_discs[target_index]
	# Visual stuff? Marking the target_disc?
	#
	#
	return target_disc
