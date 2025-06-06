extends Node2D

var is_turn: bool = true
var is_pulling: bool = false
var pull_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	$Indicator.visible = false

func _physics_process(delta: float) -> void:
	if not is_turn: return
	var mouse_dist = get_local_mouse_position().length()
	
	if Input.is_action_just_pressed("click"):
		if mouse_dist > 315:
			is_pulling = true
			pull_pos = get_global_mouse_position()
			$Indicator.visible = true
	
	if Input.is_action_just_released("click") and is_pulling:
		is_pulling = false
		$Indicator.visible = false
		if get_global_mouse_position().distance_to(pull_pos) > 5:
			flick_disc()
	
	if is_pulling:
		var rot_ang = get_global_mouse_position().direction_to(pull_pos).angle()
		$Indicator.global_position = pull_pos - Vector2(0, 20).rotated(rot_ang)
		$Indicator.rotation = rot_ang
		var pull_dist = get_global_mouse_position().distance_to(pull_pos)
		pull_dist = clamp(pull_dist, 40, 120)
		$Indicator.size.x = pull_dist
		$Indicator.material.set_shader_parameter("sizex", pull_dist)

func flick_disc() -> void:
	var mouse_norm = get_global_mouse_position() - pull_pos
	var disc_speed = 500 + min(mouse_norm.length(), 120) * 15
	var disc_vel = mouse_norm.normalized() * disc_speed * -1
	SignalBus.create_disc.emit(pull_pos, disc_vel, false)
