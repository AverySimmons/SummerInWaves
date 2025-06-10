extends Node2D

func enter_from_combat():
	$AnimationPlayer.play("enter_from_combat")
	$AnimationPlayer.seek(0, true)
