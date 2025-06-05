extends Node2D

var is_turn: bool = true
var is_pulling: bool = false

func _physics_process(delta: float) -> void:
	if not is_turn: return
	var mouse_dist = get_local_mouse_position().length()
	
	if Input.is_action_just_pressed("click"):
		if mouse_dist < 85:
			is_pulling = true
	
	if Input.is_action_just_released("click") and is_pulling:
		is_pulling = false
		if mouse_dist > 85:
			flick_disc()

func flick_disc() -> void:
	var mouse_norm = get_local_mouse_position()
	var disc_vel = (mouse_norm.length() - 85) * 10
	disc_vel = max(disc_vel, 800)
	var disc_dir = mouse_norm.normalized() * -1
	SignalBus.create_disc.emit(global_position, disc_vel, disc_dir, false)
