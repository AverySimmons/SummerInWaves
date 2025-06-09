extends Node2D

var is_turn: bool = false
var is_pulling: bool = false
var pull_pos: Vector2 = Vector2.ZERO

var cooldown_timer = 2
var cooldown_window = 1
var cd_sound_played = true

var player_disc_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/player_disc.tscn")

func _ready() -> void:
	$Indicator.visible = false

func _process(delta: float) -> void:
	$CooldownBar.material.set_shader_parameter("fill_percent", cooldown_timer / cooldown_window / 1.05)

func _physics_process(delta: float) -> void:
	if not is_turn: return
	var mouse_dist = get_local_mouse_position().length()
	
	if Input.is_action_just_pressed("click"):
		if mouse_dist > 315:
			$Indicator.visible = true
			is_pulling = true
			pull_pos = get_global_mouse_position()
			$Hand.pull_back(0.7)
			$Hand.global_position = pull_pos
			$Hand.rotation = pull_pos.angle_to_point(Vector2(640, 360)) + PI / 2
			var t = create_tween()
			t.tween_property($Hand, "modulate", Color(1,1,1,1), 0.1)
	
	if Input.is_action_just_released("click") and is_pulling:
		is_pulling = false
		$Indicator.visible = false
		if get_global_mouse_position().distance_to(pull_pos) > 5 and cooldown_timer > cooldown_window:
			flick_disc()
		elif get_global_mouse_position().distance_to(pull_pos) > 5:
			$NotReadyYet.play()
		
		$Hand.let_go()
		var t = create_tween()
		t.tween_property($Hand, "modulate", Color(1,1,1,0), 0.5)
	
	if is_pulling:
		var rot_ang = get_global_mouse_position().direction_to(pull_pos).angle()
		if pull_pos.distance_to(get_global_mouse_position()) > 10:
			$Hand.rotation = rot_ang + PI / 2
		$Indicator.global_position = pull_pos - Vector2(0, 20).rotated(rot_ang)
		$Indicator.rotation = rot_ang
		var pull_dist = get_global_mouse_position().distance_to(pull_pos)
		$Indicator.size.x = clamp(pull_dist, 40, 120)
		$Indicator.material.set_shader_parameter("sizex", min(pull_dist, 120))
	#sound effects
	if cooldown_timer > cooldown_window and not cd_sound_played:
		$CooldownReady.play()
		cd_sound_played = true
		
	
	cooldown_timer += delta

func flick_disc() -> void:
	var mouse_norm = get_global_mouse_position() - pull_pos
	var disc_speed = 500 + min(mouse_norm.length(), 120) * 15
	var disc_vel = mouse_norm.normalized() * disc_speed * -1
	SignalBus.create_disc.emit(pull_pos, disc_vel, -1, player_disc_scene, TAU, 1)
	cd_sound_played = false
	cooldown_timer = 0
