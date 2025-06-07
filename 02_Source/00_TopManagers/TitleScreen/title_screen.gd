extends Node2D

func _on_texture_button_button_up() -> void:
	SignalBus.start_game.emit()
