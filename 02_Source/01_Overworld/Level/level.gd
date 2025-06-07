extends Node2D

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Debug"):
		SignalBus.switch_game.emit(true)

func enter_from_combat():
	$AnimationPlayer.play("enter_from_combat")
	$AnimationPlayer.seek(0, true)
