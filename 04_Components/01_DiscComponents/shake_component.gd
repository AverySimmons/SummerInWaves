extends Node2D

@export var accelerable_shake_intensity: float = 2.0
@export var baseline_shake_intensity: float = 1.0
var actual_shake_intensity

var target_node = null
@export var shaking_time: float = 3.5

func _ready():
	target_node = get_parent()
	pass

func _process(delta: float) -> void:
	var timer_difference: float = shaking_time-target_node.special_move_timer
	if timer_difference >= 0:
		target_node.get_node("Sprite2D").global_position = target_node.global_position
		if target_node.has_node("RedCircle"):
			target_node.get_node("RedCircle").global_position = target_node.global_position
			
		actual_shake_intensity = baseline_shake_intensity + (accelerable_shake_intensity * (shaking_time+timer_difference))
		var shake_offset: Vector2 = Vector2(randf_range(-actual_shake_intensity, actual_shake_intensity),
											randf_range(-actual_shake_intensity, actual_shake_intensity))
		target_node.get_node("Sprite2D").position += shake_offset
		if target_node.has_node("RedCircle"):
			target_node.get_node("RedCircle").position += shake_offset
	else:
		target_node.get_node("Sprite2D").global_position = target_node.global_position
		if target_node.has_node("RedCircle"):
			target_node.get_node("RedCircle").global_position = target_node.global_position
	pass
