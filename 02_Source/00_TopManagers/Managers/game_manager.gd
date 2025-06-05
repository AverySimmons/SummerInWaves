extends Node2D

var is_combat: bool = false

var combat_scene = preload("res://02_Source/02_Combat/CombatManager/combat_manager.tscn")

@onready var overworld_level = $Level
@onready var combat_level = null

func _ready() -> void:
	SignalBus.switch_game.connect(switch_scenes)

func switch_scenes() -> void:
	if is_combat:
		# maybe configure overworld before adding it back
		call_deferred("add_child", overworld_level)
		combat_level.call_deferred("queue_free")
	
	else:
		call_deferred("remove_child", overworld_level)
		combat_level = combat_scene.instantiate()
		add_child(combat_level)
	
	is_combat = not is_combat
