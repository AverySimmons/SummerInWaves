extends Node2D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Debug"):
		SignalBus.switch_game.emit(true)
