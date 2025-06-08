class_name EnemyDisc
extends Disc

var despawn_timer: float = 1
var special_move_timer: float = 7

func _ready() -> void:
	is_enemy = true
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	despawn_check(delta)
	pass

func despawn_check(delta: float) -> void:
	# If not moving, count down the despawn timer
	var is_in_ring: bool = $PlayspaceCheck.has_overlapping_areas()
	if !is_in_ring && !super.is_moving():
		despawn_timer -= delta
		# Can maybe have a cool dissolve thing
	else:
		# Else, reset it
		despawn_timer = 1
		return
	
	if despawn_timer <= 0:
		# Despawn if timer counts down fully
		queue_free()
	return
