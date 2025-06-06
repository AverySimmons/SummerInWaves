extends Node2D

var game_manager_scene: PackedScene = preload("res://02_Source/00_TopManagers/Managers/game_manager.tscn")
var settings_scene: PackedScene = preload("res://02_Source/00_TopManagers/SettingsMenu/settings.tscn")

var dialogic_style = preload("res://03_DialogicStyles/dialogic_style.tres")

#start with title screen as a child. when play button is pressed, emit a signal
#scene manager will switch to game manager. it adds in game manager and deletes the title
func _ready() -> void:
	dialogic_style.prepare()
	Dialogic.preload_timeline("res://03_DialogicStyles/test_timeline.dtl")
	Dialogic.start("empty_timeline")
	SignalBus.start_game.connect(start_game)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		pause_game()

func start_game() -> void:
	var new_game_manager = game_manager_scene.instantiate()
	
	add_child(new_game_manager)
	
	$TitleScreen.queue_free()
	
	
func pause_game() -> void:
	if get_tree().paused:
		#unpause the game
		get_tree().paused = false
		#remove settings screen
		$Settings.queue_free()
	else:
		#pause the game
		get_tree().paused = true
		#bring up settings screen
		var new_settings = settings_scene.instantiate()
		add_child(new_settings)
		
		
