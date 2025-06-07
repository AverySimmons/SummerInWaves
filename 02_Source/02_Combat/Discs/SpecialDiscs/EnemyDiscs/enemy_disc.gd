extends "res://02_Source/02_Combat/Discs/disc.gd"

var despawn_timer: float = 2
var is_in_ring: bool = false	

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	pass

func despawn(delta: float) -> void:
	if $PlayspaceCheck.has_overlapping_areas():
		pass
	return
