extends Node2D
#contains enemeny and player managers, level art, area 2ds to detect closeness to middle, node2d to hold the discs
#function: current score, have a function that spawns a disc at given location, velocity-position-team.
#needs to know who's turn it is
#also contain the enemy AI
var is_turn: bool = false #player's turn
var player_score: int = 0
var opponent_score: int = 0
var ring2_points: int = 1
var ring1_points: int = 2
var disc_scene: PackedScene = preload("res://02_Source/02_Combat/Discs/disc.tscn")
var released_disc: bool = false
var enemy_shoot_timer: float = 0

#use area 2d circles to determine points. use a .velocity and .enemy
#will use get_overlapping_areas function

func _ready() -> void:
	SignalBus.create_disc.connect(spawn_disc)
	

#score calculation
func round_score():
	#lists from overlapping area
	var discs_list_r1 = $Ring1.get_overlapping_areas()
	var discs_list_r2 = $Ring2.get_overlapping_areas()
	#ring 2 discs, outer ring
	for disc in discs_list_r2: 
		if disc.is_enemy:
			opponent_score += ring2_points
		else:
			player_score += ring2_points
	#ring 1 discs, inner ring
	for disc in discs_list_r1:
		if disc.is_enemy:
			opponent_score += ring1_points
		else:
			player_score += ring2_points
			
#spawning discs
func spawn_disc(pos: Vector2, velocity: Vector2, is_enemy: bool):
	#create an instance of a disc scene. created outside of the scene tree
	var new_disc: Disc = disc_scene.instantiate()
	
	#give the disc values
	new_disc.position = pos
	new_disc.velocity = velocity
	new_disc.is_enemy = is_enemy
	
	#add as a child to Discs
	$Discs.add_child(new_disc)
	
	released_disc = true

	

#every frame
func _physics_process(delta: float) -> void:
	
	if released_disc: #if we released the disc then we check to change turns
		#switching turns
		var discs_list = $Discs.get_children() #check the outmost ring
		#determine if any discs are still moving
		var all_discs_stopped = true
		for disc in discs_list:
			if disc.is_moving(): #if disc is still moving
				all_discs_stopped = false
				break
		
		if all_discs_stopped == true:
			is_turn = not is_turn
			released_disc = false 
	
	if Input.is_action_just_pressed("Debug"):
		SignalBus.switch_game.emit(true)
	if Input.is_action_just_pressed("talk"):
		SignalBus.dialogue_pause.emit()
		
	#enemy spawning discs
	#0, 0 in the top left
	enemy_shoot_timer += delta
	
	var enemy_shoot_pos = Vector2(100, 100)
	var enemy_shoot_vel = enemy_shoot_pos.direction_to(Vector2(640, 360)) * 1100
	if enemy_shoot_timer >= 1:
		spawn_disc(enemy_shoot_pos, enemy_shoot_vel, true)
		enemy_shoot_timer = 0
		
	
	
	
