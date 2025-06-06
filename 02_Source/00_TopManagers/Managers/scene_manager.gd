extends Node2D

var game_manager_scene: PackedScene = preload("res://02_Source/00_TopManagers/Managers/game_manager.tscn")
var settings_scene: PackedScene = preload("res://02_Source/00_TopManagers/SettingsMenu/settings.tscn")
var in_dialogue_pause: bool = false
var currently_paused: bool = false

#start with title screen as a child. when play button is pressed, emit a signal
#scene manager will switch to game manager. it adds in game manager and deletes the title
func _ready() -> void:
	load("res://03_DialogicAssets/Styles/primary_style.tres").prepare()
	Dialogic.preload_timeline("res://03_DialogicAssets/Timelines/empty_timeline.dtl")
	SignalBus.start_game.connect(start_game)
	SignalBus.dialogue_pause.connect(dialogue_pause_switch)
	Dialogic.timeline_ended.connect(dialogue_pause_switch)

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		pause_game()
	#debug testing for dialogue pause
	if not currently_paused:
		if Input.is_action_just_pressed("ui_text_newline"):
			dialogue_pause_switch()

func start_game() -> void:
	var new_game_manager = game_manager_scene.instantiate()
	
	add_child(new_game_manager)
	
	$TitleScreen.queue_free()

func dialogue_pause_switch() -> void:
	#This function should never get called while currently_paused from settings
	#pauses the tree and switches in_dialogue_pause bool
	if not in_dialogue_pause:
		get_tree().paused = true
		in_dialogue_pause = true
	else: #if in dialogue pause already
		get_tree().paused = false
		in_dialogue_pause = false
	
func pause_game() -> void:
	
	#logic when in dialogue pause
	#if currently_paused:
		#bring up the settings as normal. get_tree().paused will be true even though we still need to pause
	
	#basic logic when not in dialogue pause
	if currently_paused:
		#unpause the game
		if not in_dialogue_pause: #in-combat dialogue is not up
			get_tree().paused = false
		#remove settings screen
		$Settings.queue_free()
		
		currently_paused = false
	else: #not currently paused
		#pause the game
		get_tree().paused = true
		#bring up settings screen
		var new_settings = settings_scene.instantiate()
		add_child(new_settings)
		
		currently_paused = true
		
		
