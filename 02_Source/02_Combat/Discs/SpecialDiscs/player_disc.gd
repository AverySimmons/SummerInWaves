extends Disc

var despawn_timer_time: float = 1
var despawn_timer: float

func _ready() -> void:
	super._ready()
	despawn_timer = despawn_timer_time
	pass


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
		despawn_timer = despawn_timer_time
		return
	
	if despawn_timer <= 0:
		queue_free()
	return
