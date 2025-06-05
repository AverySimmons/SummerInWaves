extends Node2D

var is_turn: bool = true
var is_pulling: bool = false
var pull_pos: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	if not is_turn: return
	var mouse_dist = get_local_mouse_position().length()
	
	if Input.is_action_just_pressed("click"):
		if mouse_dist > 315:
			is_pulling = true
			pull_pos = get_global_mouse_position()
	
	if Input.is_action_just_released("click") and is_pulling:
		is_pulling = false
		flick_disc()

func flick_disc() -> void:
	var mouse_norm = get_global_mouse_position() - pull_pos
	var disc_vel = 300 + mouse_norm.length() * 5
	disc_vel = clamp(disc_vel, 300, 2000)
	var disc_dir = mouse_norm.normalized() * -1
	SignalBus.create_disc.emit(pull_pos, disc_vel, disc_dir, false)
