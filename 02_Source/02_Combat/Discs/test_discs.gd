extends Node2D

var DiscScene = preload("res://02_Source/02_Combat/Discs/disc.tscn")
var AlDiscScene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/al_disc_enemy.tscn")
var ElmDiscScene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/elm_disc_enemy.tscn")
var PeriDiscScene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/periwinkle_disc_enemy.tscn")

var Disc1: Disc = DiscScene.instantiate()
var Disc2: Disc = DiscScene.instantiate()
var Disc3: EnemyDisc = AlDiscScene.instantiate()
var Disc4: EnemyDisc = ElmDiscScene.instantiate()
var Disc5: EnemyDisc = PeriDiscScene.instantiate()

var timer: float = 7

func _ready() -> void:
	Disc1.position.x += 630
	Disc1.position.y += 160
	Disc1.rotational_velocity = 0
	Disc1.velocity = Vector2(0, 0)
	Disc2.velocity = Vector2(0, 0)
	Disc2.position.x += 870
	Disc2.position.y += 220
	Disc1.mass = 10
	add_child(Disc1)
	add_child(Disc2)
	
	# Elm Test
	Disc4.position.x += 750
	Disc4.position.y += 200
	add_child(Disc4)
	# Al Test
	Disc3.position.x
	Disc3.position.y
	add_child(Disc3)
	# Periwinkle Test
	Disc5.position.x += 500
	Disc5.position.y += 200
	add_child(Disc5)
	pass

func _physics_process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		Disc1.velocity = (Disc5.position - Disc1.position).normalized() * 1000
		timer = 7
	pass
