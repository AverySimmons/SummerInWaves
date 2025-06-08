extends AllyDisc

const ELM_SPECIAL_MOVE_TIMER_LOWER = 6
const ELM_SPECIAL_MOVE_TIMER_UPPER = 8

@export var min_gravity_bomb_strength: float = 500
# Strength of gravity bomb. 1.0 means it'll add the exact distance from self (of node) to Elm to its velocity
@export var gravity_bomb_strength: float = 1.6

func _ready() -> void:
	super._ready()
	special_move_timer = randf_range(ELM_SPECIAL_MOVE_TIMER_LOWER, ELM_SPECIAL_MOVE_TIMER_UPPER)
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	special_move_timer -= delta
	if special_move_timer <= 0:
		gravity_bomb() #GRAVITY BOMB!!!!!!!!!!!!!!!!!!!!!!!!!!!! So cool
	
	pass

func gravity_bomb() -> void:
	#GRAVITY BOMB!!!!! Wow
	var discs_in_range = $GravityBomb.get_overlapping_areas()
	for disc in discs_in_range:
		if disc is Disc:
			var vector_to_elm: Vector2 = position - disc.position
			var speed: float = max((vector_to_elm * gravity_bomb_strength).length(), min_gravity_bomb_strength)
			disc.velocity += speed * vector_to_elm.normalized()
	explode() # EXPLODE!
	return

func explode() -> void:
	# Maybe a cool effect here? Idk
	queue_free()
	return
