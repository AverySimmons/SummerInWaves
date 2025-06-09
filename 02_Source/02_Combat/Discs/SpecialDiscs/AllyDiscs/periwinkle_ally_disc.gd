extends AllyDisc

const PERI_SPECIAL_MOVE_TIMER_LOWER = 6
const PERI_SPECIAL_MOVE_TIMER_UPPER = 8

@export var fixed_bomb_strength: float = 600
@export var bomb_strength: float = 1.6

func _ready() -> void:
	super._ready()
	special_move_timer = randf_range(PERI_SPECIAL_MOVE_TIMER_LOWER, PERI_SPECIAL_MOVE_TIMER_UPPER)
	pass

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	special_move_timer -= delta
	if special_move_timer <= 0 and not removing:
		bomb()
	
	pass

func bomb() -> void:
	
	var discs_in_range = $Bomb.get_overlapping_areas()
	for disc in discs_in_range:
		if disc is Disc:
			var vector_from_bomb: Vector2 = disc.position - position
			var speed: float = (fixed_bomb_strength - vector_from_bomb.length()) * bomb_strength
			var direction_from_bomb: Vector2 = (vector_from_bomb).normalized()
			disc.velocity += direction_from_bomb * speed
	explode()
	return

func explode() -> void:
	#sound
	$PeriwinkleSplash.play()
	#print("I exploded")
	
	removing = true
	monitorable = false
	monitoring = false
	$Explosion/AnimationPlayer.play("boom")
	#await $Explosion/AnimationPlayer.animation_finished
	await $PeriwinkleSplash.finished
	
	queue_free()
	return
