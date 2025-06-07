extends "res://02_Source/02_Combat/Discs/disc.gd"

var despawn_timer: float = 1

func _physics_process(delta: float) -> void:
	# Calls parent physics process
	super._physics_process(delta)
	despawn_check(delta)
	pass

func despawn_check(delta: float) -> void:
	# If not moving, count down the despawn timer
	if !super.is_moving():
		despawn_timer -= delta
		# Maybe could have an animation of slowly sinking/dissolving here?
	else:
		# Else, reset it
		despawn_timer = 1
		return
	
	if despawn_timer <= 0:
		queue_free()
	return
