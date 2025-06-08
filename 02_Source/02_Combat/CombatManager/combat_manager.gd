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

var fight_num = 0

var combat_won = false

var player_disc_scene: PackedScene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/player_disc.tscn")
var enemy_disc_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/enemy_disc.tscn")

var enemy_al_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/al_disc_enemy.tscn")
var enemy_peri_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/periwinkle_disc_enemy.tscn")
var enemy_elm_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/elm_disc_enemy.tscn")

var ally_al_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/AllyDiscs/al_ally_disc.tscn")
var ally_peri_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/AllyDiscs/periwinkle_ally_disc.tscn")
var ally_elm_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/AllyDiscs/elm_ally_disc.tscn")

var al_disc: AllyDisc
var peri_disc: AllyDisc
var elm_disc: AllyDisc

var released_disc: bool = false

var enemy_shoot_timer: float = 0
var enemy_move_timer: float = 0
var center = Vector2(640, 360)

var rotation_angle: float = -PI / 2
var enemy_rot_velocity: float = 0
var default_rotation: float = 3
var win_game_timer: float = 0
var lose_game_timer: float = 0

var enemy_flinch = 0
var enemy_max_rot_vel = PI
var enemy_shoot_rate: float = 2 #this is how many seconds between shots. Smaller = faster
var enemy_shoot_speed_mod: float = 600 #bigger is faster
var enemy_starting_discs = 0
var enemy_rot_acc = 0
var enemy_move_dir = 0
var enemy_special_discs = []
var ally_special_discs = 0
var enemy_special_disc_chance = 0


var prin_phase2 = false

#var enemy_disc_count = 0
var loss_count = 10

@onready var player_controller = $PlayerController

@export var pause = false :
	set(value):
		if player_controller:
			player_controller.is_turn = not value
		pause = value

#use area 2d circles to determine points. use a .velocity and .enemy
#will use get_overlapping_areas function

func _ready() -> void:
	GameData.combat_manager = self
	SignalBus.create_disc.connect(spawn_disc)
	fight_num = GameData.kids_defeated
	
	match fight_num:
		0:
			enemy_flinch = 0
			enemy_max_rot_vel = 0
			enemy_shoot_rate = 99999
			enemy_shoot_speed_mod = 0
			enemy_starting_discs = 8
			enemy_rot_acc = 0
			enemy_special_discs = 0
			enemy_special_disc_chance = 0
		1:
			enemy_flinch = 0.5
			enemy_max_rot_vel = PI / 2
			enemy_shoot_rate = 3
			enemy_shoot_speed_mod = 600
			enemy_starting_discs = 4
			enemy_rot_acc = enemy_max_rot_vel
			enemy_special_discs = [enemy_al_scene]
			ally_special_discs = 0
			enemy_special_disc_chance = 0.3
		2:
			enemy_flinch = 0.35
			enemy_max_rot_vel = PI / 2
			enemy_shoot_rate = 2
			enemy_shoot_speed_mod = 700
			enemy_starting_discs = 3
			enemy_rot_acc = enemy_max_rot_vel
			enemy_special_discs = [enemy_peri_scene]
			ally_special_discs = 1
			enemy_special_disc_chance = 0.3
		3:
			enemy_flinch = 0.2
			enemy_max_rot_vel = 1.5 * PI / 2
			enemy_shoot_rate = 1.5
			enemy_shoot_speed_mod = 800
			enemy_starting_discs = 3
			enemy_rot_acc = enemy_max_rot_vel
			enemy_special_discs = [enemy_elm_scene]
			ally_special_discs = 2
			enemy_special_disc_chance = 0.3
		4:
			enemy_flinch = 0.1
			enemy_max_rot_vel = 1.5 * PI / 2
			enemy_shoot_rate = 0.75
			enemy_shoot_speed_mod = 800
			enemy_starting_discs = 4
			enemy_rot_acc = enemy_max_rot_vel
			enemy_special_discs = [enemy_al_scene, enemy_peri_scene, enemy_elm_scene]
			ally_special_discs = 2
			enemy_special_disc_chance = 0.5
	
	await get_tree().create_timer(0.5).timeout
	spawn_starting_discs()

func spawn_starting_discs():
	var angle = PI / 2
	for i in enemy_starting_discs:
		angle += TAU / enemy_starting_discs
		var dir_vect = Vector2.from_angle(angle)
		var new_disc: EnemyDisc = spawn_disc(center + dir_vect * 2000, \
			Vector2.ZERO, 0, enemy_disc_scene, 30, 3)
		new_disc.despawn_timer += 1.75
		var new_tween = create_tween().set_ease(Tween.EASE_IN)
		new_tween.tween_property(new_disc, "position", center + dir_vect * 160, 1.75)

#score calculation
func round_score():
	#lists from overlapping area
	var discs_list_r1 = $Ring1.get_overlapping_areas()
	var discs_list_r2 = $Ring2.get_overlapping_areas()
	#ring 2 discs, outer ring
	for disc in discs_list_r2: 
		if disc is EnemyDisc:
			opponent_score += ring2_points
		else:
			player_score += ring2_points
	#ring 1 discs, inner ring
	for disc in discs_list_r1:
		if disc is EnemyDisc:
			opponent_score += ring1_points
		else:
			player_score += ring2_points
			
func enemy_live_discs() -> Array[Disc]:
	var discs_list = $Ring2.get_overlapping_areas() #TEMP ring2
	var new_discs_list: Array[Disc] = []
	
	for disc in discs_list:
		if disc is EnemyDisc:
			new_discs_list.append(disc)
			
	return new_discs_list
	
func no_enemy_discs() -> bool:
	#return true if there are no enemy discs in the combat area
	if not enemy_live_discs():
		return true
	else: 
		return false

#spawning discs
func spawn_disc(pos: Vector2, velocity: Vector2, sprite_index: int, type: PackedScene, \
	spin: float, mass: float) -> Disc:
	#create an instance of a disc scene. created outside of the scene tree
	var new_disc: Disc = type.instantiate()
	
	#give the disc values
	new_disc.position = pos
	new_disc.velocity = velocity
	new_disc.sprite_index = sprite_index
	new_disc.rotational_velocity = spin
	new_disc.mass = mass
	
	#add as a child to Discs
	$Discs.add_child(new_disc)
	
	released_disc = true
	
	return new_disc

#every frame
func _physics_process(delta: float) -> void:
	
	#if released_disc: #if we released the disc then we check to change turns
		##switching turns
		#var discs_list = $Discs.get_children() #check the outmost ring
		##determine if any discs are still moving
		#var all_discs_stopped = true
		#for disc in discs_list:
			#if disc.is_moving(): #if disc is still moving
				#all_discs_stopped = false
				#break
		
		#if all_discs_stopped == true:
			#is_turn = not is_turn
			#released_disc = false 
	
	if pause: return
	
	enemy_action(delta)
	
	#checking for victory
	if win_game_timer >= 0.1:
		combat_win_lose(true)
		
	#checking for loss
	if lose_game_timer >= 0.5:
		combat_win_lose(false)
	
	#timers
	enemy_shoot_timer += delta
	enemy_move_timer -= delta
	
	if no_enemy_discs():
		win_game_timer += delta
	else:
		win_game_timer = 0
	
	#loss timer increment
	var enemy_disc_count = 0
	var enemy_disc_list = enemy_live_discs()
	for disc in enemy_disc_list:
		enemy_disc_count += 1
	
	if enemy_disc_count >= loss_count:
		lose_game_timer += delta
	else:
		lose_game_timer = 0

func enemy_disc_destroyed():
	enemy_shoot_timer -= enemy_flinch

func enemy_action(delta):
	if enemy_move_timer <= 0:
		enemy_move_dir = randi_range(-1, 1)
		enemy_move_timer = randf_range(0.5, 2)
	
	enemy_rot_velocity += enemy_rot_acc * enemy_move_dir
	enemy_rot_velocity = clamp(enemy_rot_velocity, -enemy_max_rot_vel, enemy_max_rot_vel)
	
	#enemy spawning discs
	rotation_angle += enemy_rot_velocity * delta
	
	#315 is the radius of the black inner circle
	var enemy_shoot_pos = center + Vector2(350, 0).rotated(rotation_angle) #starting vector rotated
	$EnemyShootPos.position = enemy_shoot_pos
	var rand_rot = randf_range(-0.2, 0.2)
	var enemy_shoot_vel = enemy_shoot_pos.direction_to(center).rotated(rand_rot)
	enemy_shoot_vel *=  enemy_shoot_speed_mod
	
	var is_special = randf_range(0, 1) < enemy_special_disc_chance
	
	var disc_type
	if not is_special:
		disc_type = enemy_disc_scene
	else:
		disc_type = enemy_special_discs.pick_random()
	
	if enemy_shoot_timer >= enemy_shoot_rate:
		spawn_disc(enemy_shoot_pos, enemy_shoot_vel, -1, disc_type, default_rotation, 3)
		enemy_shoot_timer = 0


func combat_win_lose(is_win):
	if prin_phase2 and is_win: return
	if fight_num == 0 and is_win and not prin_phase2:
		prin_phase2 = true
		await get_tree().create_timer(1).timeout
		enemy_flinch = 0.1
		enemy_max_rot_vel = 1.5 * PI / 2
		enemy_shoot_rate = 0.75
		enemy_shoot_speed_mod = 800
		enemy_starting_discs = 4
		enemy_rot_acc = 2 * PI
		return
	combat_won = is_win
	$AnimationPlayer.play("exit")

func combat_exit():
	SignalBus.switch_game.emit(combat_won)
