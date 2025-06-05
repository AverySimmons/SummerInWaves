class_name Disc
extends Area2D

const MOMENTUM_TRANSFERED = .6
const FRICTION = 100
const GRAVITY = 9.8

var velocity: float = 400
var is_enemy: bool
var sprite
var direction: Vector2 = Vector2(1, 0)

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Velocity
	position += velocity * direction.normalized() * delta
	velocity = move_toward(velocity, 0, FRICTION*delta)
	
	# Momentum
	if has_overlapping_areas():
		return
	else:
		var overlapping
	pass


func is_moving() -> bool:
	return velocity != 0
