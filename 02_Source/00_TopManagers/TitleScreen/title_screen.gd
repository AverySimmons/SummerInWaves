extends Node2D

func _on_texture_button_button_up() -> void:
	$MenuClickLow.play()
	SignalBus.start_game.emit()


func _on_texture_button_mouse_entered() -> void:
	$MenuClick.play()
