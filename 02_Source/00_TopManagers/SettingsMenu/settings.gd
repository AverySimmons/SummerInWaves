extends CanvasLayer

func _on_resume_mouse_entered() -> void:
	$MenuClick.play()

func _on_resume_button_up() -> void:
	$MenuClickLow.play()
	SignalBus.settings_resumed.emit()

func _on_exit_mouse_entered() -> void:
	$MenuClick.play()

func _on_exit_button_up() -> void:
	$MenuClickLow.play()
	await get_tree().create_timer(0.1).timeout
	get_tree().quit()
