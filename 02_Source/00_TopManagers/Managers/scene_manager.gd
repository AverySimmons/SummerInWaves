extends Node2D

var game_manager_scene: PackedScene = preload("res://02_Source/00_TopManagers/Managers/game_manager.tscn")
var settings_scene: PackedScene = preload("res://02_Source/00_TopManagers/SettingsMenu/settings.tscn")
var end_screen: PackedScene = preload("res://02_Source/01_Overworld/EndScreen/end_scene.tscn")
var in_dialogue_pause: bool = false
var currently_paused: bool = false

var game_started = false
var combat_music_playing = false

var pause_animation = false

var end
var game

#start with title screen as a child. when play button is pressed, emit a signal
#scene manager will switch to game manager. it adds in game manager and deletes the title
func _ready() -> void:
	load("res://03_DialogicAssets/Styles/primary_style.tres").prepare()
	Dialogic.preload_timeline("res://03_DialogicAssets/Timelines/empty_timeline.dtl")
	SignalBus.start_game.connect(play_start_game_anim)
	SignalBus.dialogue_pause.connect(dialogue_pause_switch)
	Dialogic.signal_event.connect(check_dialogue_pause_switch)
	SignalBus.switch_game.connect(switch_game_state)
	Dialogic.signal_event.connect(dialogic_signal)
	SignalBus.settings_resumed.connect(pause_game)
	SignalBus.game_complete.connect(finish_game)

func finish_game():
	get_tree().paused = true
	$AnimationPlayer.play("complete_game")

func swap_to_end():
	game.queue_free()
	end = end_screen.instantiate()
	add_child(end)

func quit_game():
	get_tree().quit()

func play_start_game_anim():
	if not game_started:
		$AnimationPlayer.play("start_game")
		game_started = true

func dialogic_signal(arg):
	if arg == 'switch to combat':
		switch_game_state(false)

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
	
	$MusicPlayer.play("start_overworld")
	game = new_game_manager

func check_dialogue_pause_switch(arg: String) -> void:
	if arg == "unpause combat":
		dialogue_pause_switch()

func dialogue_pause_switch() -> void:
	#This function should never get called while currently_paused from settings
	#pauses the tree and switches in_dialogue_pause bool
	if not in_dialogue_pause:
		get_tree().paused = true
		in_dialogue_pause = true
	else: #if in dialogue pause already
		get_tree().paused = false
		in_dialogue_pause = false

func switch_game_state(win):
	if combat_music_playing:
		$MusicPlayer.play("overworld_music")
	else:
		$MusicPlayer.play("combat_music")
	
	combat_music_playing = not combat_music_playing

func pause_game() -> void:
	if pause_animation: return
	pause_animation = true
	#logic when in dialogue pause
	#if currently_paused:
		#bring up the settings as normal. get_tree().paused will be true even though we still need to pause
	
	#basic logic when not in dialogue pause
	if currently_paused:
		
		var t = create_tween()
		t.tween_property($Settings, "offset", Vector2(0, 720), 0.2)
		await t.finished
		
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
		new_settings.offset = Vector2(0, 720)
		add_child(new_settings)
		
		currently_paused = true
		
		var t = create_tween()
		t.tween_property(new_settings, "offset", Vector2(0,0), 0.2)
	
	pause_animation = false
