extends Node2D

var is_combat: bool = false

var combat_scene = preload("res://02_Source/02_Combat/CombatManager/combat_manager.tscn")

@onready var overworld_level = $Level
@onready var combat_level = null

func _ready() -> void:
	SignalBus.switch_game.connect(switch_scenes)
	Dialogic.signal_event.connect(dialogic_signal)

func dialogic_signal(arg):
	if arg == 'switch to combat':
		switch_scenes(false)

func switch_scenes(win: bool) -> void:
	if is_combat:
		# maybe configure overworld before adding it back
		
		Dialogic.VAR.set_variable("fight_won", win)
		
		match GameData.kids_defeated:
			0:
				Dialogic.start("post_prin_first")
			1:
				Dialogic.start("post_albert")
			2:
				Dialogic.start("post_periwinkle")
			3:
				Dialogic.start("post_elm")
			4:
				Dialogic.start("post_prin_last")
		
		if win or GameData.kids_defeated == 0:
			GameData.kids_defeated += 1
		
		overworld_level.enter_from_combat()
		call_deferred("add_child", overworld_level)
		combat_level.call_deferred("queue_free")
	
	else:
		call_deferred("remove_child", overworld_level)
		combat_level = combat_scene.instantiate()
		add_child(combat_level)
	
	is_combat = not is_combat
