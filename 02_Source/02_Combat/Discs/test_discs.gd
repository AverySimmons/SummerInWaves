extends Node2D

var DiscScene = preload("res://02_Source/02_Combat/Discs/disc.tscn")
@onready var cam = $Camera2D

var Disc1: Disc = DiscScene.instantiate()
var Disc2: Disc = DiscScene.instantiate()

func _ready() -> void:
	Disc1.position.x += 200
	Disc1.position.y += 200
	Disc1.rotational_velocity = 0
	Disc2.velocity = Vector2(0, 0)
	Disc2.position.x += 800
	Disc2.position.y += 200
	Disc2.velocity = Vector2(-6000, 0)
	add_child(Disc1)
	add_child(Disc2)
	pass
