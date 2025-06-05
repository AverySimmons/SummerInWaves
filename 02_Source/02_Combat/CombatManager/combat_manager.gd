extends Node2D
#contains enemeny and player managers, level art, area 2ds to detect closeness to middle, node2d to hold the discs
#function: current score, have a function that spawns a disc at given location, velocity-position-team.
#needs to know who's turn it is
#also contain the enemy AI
var is_player_turn: bool = false
var player_score: integer = 0
var opponent_score: integer = 0
var ring2_points: integer = 1
var ring1_points: integer = 2
var disc_scene: string = ''

#use area 2d circles to determine points. use a .velocity and .enemy
#will use get_overlapping_areas function

#score calculation
func round_score():
	#lists from overlapping area
	var discs_list_r1 = get_overlapping_areas(Ring1)
	var discs_list_r2 = get_overlapping_areas(Ring2)
	#ring 2 discs, outer ring
	for disc in discs_list_r2: 
		if disc.is_enemy:
			opponent_score += ring2_points
		elif disc.is_player:
			player_score += ring2_points
	#ring 1 discs, inner ring
	for disc in discs_list_r1:
		if disc.is_enemy:
			opponent_score += ring1_points
		elif disc.is_player:
			player_score += ring2_points
			
#spawning discs
func spawn_disc(position: Vector2, velocity: float, direction: Vector2, team: string):
	
#every frame
func every_step():
	#switching turns
	var discs_list = get_overlapping_areas(Ring2) #check the outmost ring
	
	#determine if any discs are still moving
	var all_discs_stopped = true
	for disc in discs_list:
		if disc.is_moving: #if disc is still moving
			all_discs_stopped = false
			break
	
	if all_discs_stopped == true:
		is_player_turn = not is_player_turn
		
		
	
	
