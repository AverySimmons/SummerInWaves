extends Node2D

var game_manager_scene: PackedScene = preload("res://02_Source/00_TopManagers/Managers/game_manager.tscn")
#start with title screen as a child. when play button is pressed, emit a signal
#scene manager will switch to game manager. it adds in game manager and deletes the title
func _ready() -> void:
	SignalBus.start_game.connect(start_game)

func start_game() -> void:
	var new_game_manager = game_manager_scene.instantiate()
	
	add_child(new_game_manager)
	
	$TitleScreen.queue_free()
