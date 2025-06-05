class_name NPC
extends Area2D

var talked_to = false

@export var dialogic_scene: String = ""

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Debug"):
		talk()

func talk():
	Dialogic.start(dialogic_scene)
