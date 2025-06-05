class_name NPC
extends Area2D

var talked_to = false

@export var dialogic_scene: String = ""

func talk():
	Dialogic.start(dialogic_scene)
