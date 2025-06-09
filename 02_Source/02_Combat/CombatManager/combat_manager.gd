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
var about_to_shoot_special = false
var about_to_shoot_special_ind = 0

var combat_won = false

var player_disc_scene: PackedScene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/player_disc.tscn")
var enemy_disc_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/enemy_disc.tscn")

var enemy_al_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/al_disc_enemy.tscn")
var enemy_peri_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/periwinkle_disc_enemy.tscn")
var enemy_elm_scene = preload("res://02_Source/02_Combat/Discs/SpecialDiscs/EnemyDiscs/elm_disc_enemy.tscn")

var ally_scenes = [
	preload("res://02_Source/02_Combat/Discs/SpecialDiscs/AllyDiscs/al_ally_disc.tscn"),
	preload("res://02_Source/02_Combat/Discs/SpecialDiscs/AllyDiscs/periwinkle_ally_disc.tscn"),
	preload("res://02_Source/02_Combat/Discs/SpecialDiscs/AllyDiscs/elm_ally_disc.tscn")
]

var ally_discs = [
	null,
	null,
	null
]

var ally_timers = [
	16,
	10,
	4
]

var ally_next_angles = [
	randf_range(0, TAU),
	randf_range(0, TAU),
	randf_range(0, TAU)
]

@onready var ally_hands = [
	$Hands/Hand,
	$Hands/Hand2,
	$Hands/Hand3
]

var ally_hand_shot = [
	false,
	false,
	false
]

var enemy_normal_count = 0

var released_disc: bool = false

var enemy_shoot_timer: float = 0
var enemy_move_timer: float = 0
var center = Vector2(640, 360)

var rotation_angle: float = 0
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
var enemy_normal_num = 0
var enemy_sprite_index = 0

var flinch_timer = 0

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
	SignalBus.disc_removed.connect(disc_removed)
	fight_num = GameData.kids_defeated
	
	for i in 3:
		ally_hands[i].sprite_index = i + 1
		ally_hands[i].disc_sprite_index = i + 5
		ally_hands[i].modulate.a = 0
	
	
	match fight_num:
		0:
			enemy_flinch = 0
			enemy_max_rot_vel = 0
			enemy_shoot_rate = 99999
			enemy_shoot_speed_mod = 0
			enemy_starting_discs = 8
			enemy_rot_acc = 0
			enemy_special_discs = [enemy_elm_scene]
			enemy_normal_count = 1000
			enemy_normal_num = 1000
			enemy_sprite_index = 3
			$HealthBar.material.set_shader_parameter("color", Color("00dfe3"))
		1:
			enemy_flinch = 1
			enemy_max_rot_vel = PI / 2
			enemy_shoot_rate = 3
			enemy_shoot_speed_mod = 600
			enemy_starting_discs = 4
			enemy_rot_acc = enemy_max_rot_vel
			enemy_special_discs = [enemy_al_scene]
			ally_special_discs = 0
			enemy_normal_num = 3
			enemy_sprite_index = 0
			$HealthBar.material.set_shader_parameter("color", Color("fa5eff"))
		2:
			enemy_flinch = 0.8
			enemy_max_rot_vel = PI / 2
			enemy_shoot_rate = 2
			enemy_shoot_speed_mod = 700
			enemy_starting_discs = 4
			enemy_rot_acc = enemy_max_rot_vel
			enemy_special_discs = [enemy_peri_scene]
			ally_special_discs = 1
			enemy_normal_num = 3
			enemy_sprite_index = 1
			$HealthBar.material.set_shader_parameter("color", Color("a95eff"))
		3:
			enemy_flinch = 0.6
			enemy_max_rot_vel = 1.5 * PI / 2
			enemy_shoot_rate = 1.5
			enemy_shoot_speed_mod = 800
			enemy_starting_discs = 4
			enemy_rot_acc = enemy_max_rot_vel
			enemy_special_discs = [enemy_elm_scene]
			ally_special_discs = 2
			enemy_normal_num = 3
			enemy_sprite_index = 2
			$HealthBar.material.set_shader_parameter("color", Color("66e600"))
		4:
			enemy_flinch = 0.4
			enemy_max_rot_vel = 1.5 * PI / 2
			enemy_shoot_rate = 1.25
			enemy_shoot_speed_mod = 800
			enemy_starting_discs = 5
			enemy_rot_acc = enemy_max_rot_vel
			enemy_special_discs = [enemy_al_scene, enemy_peri_scene, enemy_elm_scene]
			ally_special_discs = 3
			enemy_normal_num = 3
			enemy_sprite_index = 3
			$HealthBar.material.set_shader_parameter("color", Color("00dfe3"))
	
	$EnemyShootPos.sprite_index = enemy_sprite_index + 1
	choose_next_disc()
	
	await get_tree().create_timer(0.5).timeout
	
	spawn_starting_discs()
	
	await get_tree().create_timer(3).timeout
	
	if fight_num != 0:
		#sound effect
		$HandSpawn.play()
		
		var t = create_tween()
		t.tween_property($EnemyShootPos, "modulate", Color(1,1,1,1), 0.5)

func spawn_starting_discs():
	var angle = PI / 2
	for i in enemy_starting_discs:
		angle += TAU / enemy_starting_discs
		var dir_vect = Vector2.from_angle(angle)
		var new_disc: EnemyDisc = spawn_disc(center + dir_vect * 2000, \
			Vector2.ZERO, enemy_sprite_index, enemy_disc_scene, 30, 3)
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

func disc_removed(is_enemy):
	if is_enemy:
		enemy_disc_destroyed()

func choose_next_disc():
	about_to_shoot_special = enemy_normal_count == 0
	if about_to_shoot_special and fight_num == 4:
		var ind = randi_range(0, 2)
		$EnemyShootPos.disc_sprite_index = ind + 1
		about_to_shoot_special_ind = ind
	
	else:
		$EnemyShootPos.disc_sprite_index = enemy_sprite_index + 1
	
	if enemy_normal_count == 0:
		enemy_normal_count = enemy_normal_num
	else:
		enemy_normal_count -= 1

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

func _process(delta: float) -> void:
	var t = create_tween()
	t.tween_property($HealthBar, "material:shader_parameter/fill_percent", \
		1 - len(enemy_live_discs()) / 10.0, 0.4)

func start_combat():
	if fight_num == 0:
		Dialogic.start("summer_tutorial").process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		SignalBus.dialogue_pause.emit()
	if fight_num == 2:
		Dialogic.start("albert_tutorial").process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		SignalBus.dialogue_pause.emit()

#every frame
func _physics_process(delta: float) -> void:
	
	enemy_shoot_rate += delta / 120
	
	var enemy_shoot_pos = center + Vector2(350, 0).rotated(rotation_angle) #starting vector rotated
	$EnemyShootPos.position = enemy_shoot_pos
	
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
	
	if flinch_timer == 0:
		if fight_num != 0:
			$EnemyShootPos.modulate = Color(1,1,1,1)
		enemy_action(delta)
	ally_action(delta)
	
	#checking for victory
	if win_game_timer >= 0.1:
		combat_win_lose(true)
		
	#checking for loss
	if lose_game_timer >= 0.5:
		combat_win_lose(false)
	
	#timers
	enemy_shoot_timer += delta
	enemy_move_timer -= delta
	flinch_timer -= delta
	flinch_timer = max(0, flinch_timer)
	
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
	if fight_num == 0: return
	flinch_timer += enemy_flinch
	$EnemyShootPos.modulate = Color(0.4,0.4,0.4,0.4)

func ally_action(delta):
	for i in range(ally_special_discs):
		if ally_discs[i]: continue
		
		if ally_timers[i] <= 0:
			ally_timers[i] = randf_range(5, 8)
			var spawn_pos = center + Vector2(400, 0).rotated(ally_next_angles[i])
			ally_next_angles[i] = randf_range(0, TAU)
			var vel = spawn_pos.direction_to(center) * 700
			ally_discs[i] = spawn_disc(spawn_pos, vel, -1, ally_scenes[i], TAU, 4)
			ally_hand_shot[i] = false
			ally_hands[i].let_go()
			var t = create_tween()
			t.tween_property(ally_hands[i], "modulate", Color(1,1,1,0), 0.5)
		
		else:
			ally_timers[i] -= delta
			if not ally_hand_shot[i] and ally_timers[i] < 1:
				#sound effect
				$HandSpawn.play()
				
				ally_hand_shot[i] = true
				ally_hands[i].position = center + Vector2(400, 0).rotated(ally_next_angles[i])
				ally_hands[i].pull_back(1)
				var t = create_tween()
				t.tween_property(ally_hands[i], "modulate", Color(1,1,1,1), 0.3)

func enemy_action(delta):
	if enemy_move_timer <= 0:
		enemy_move_dir = randf_range(-1, 1)
		enemy_move_timer = randf_range(0.5, 2)
	
	enemy_rot_velocity += enemy_rot_acc * enemy_move_dir
	enemy_rot_velocity = clamp(enemy_rot_velocity, -enemy_max_rot_vel, enemy_max_rot_vel)
	
	#enemy spawning discs
	rotation_angle += enemy_rot_velocity * delta
	
	if enemy_shoot_timer >= enemy_shoot_rate:
		shoot_disc()
	
	elif enemy_shoot_timer > enemy_shoot_rate - 0.35:
		$EnemyShootPos.pull_back(1 if about_to_shoot_special else 0.7)

func shoot_disc():
	var enemy_shoot_pos = $EnemyShootPos.position
	var rand_rot = randf_range(-0.2, 0.2)
	var enemy_shoot_vel = enemy_shoot_pos.direction_to(center).rotated(rand_rot)
	enemy_shoot_vel *=  enemy_shoot_speed_mod
	
	var disc_type
	var sprite_ind
	if not about_to_shoot_special:
		disc_type = enemy_disc_scene
		sprite_ind = enemy_sprite_index
	else:
		disc_type = enemy_special_discs[about_to_shoot_special_ind]
		sprite_ind = -1
	
	spawn_disc(enemy_shoot_pos, enemy_shoot_vel, sprite_ind, disc_type, default_rotation, 3)
	$EnemyShootPos.let_go()
	enemy_shoot_timer = 0
	choose_next_disc()

func combat_win_lose(is_win):
	if prin_phase2 and is_win: return
	if fight_num == 0 and is_win and not prin_phase2:
		prin_phase2 = true
		await get_tree().create_timer(1).timeout
		#sound effect
		$HandSpawn.play()
		
		var t = create_tween()
		t.tween_property($EnemyShootPos, "modulate", Color(1,1,1,1), 0.5)
		await t.finished
		await get_tree().create_timer(1).timeout
		Dialogic.start("prin_tutorial").process_mode = Node.PROCESS_MODE_ALWAYS
		Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
		SignalBus.dialogue_pause.emit()
		enemy_flinch = 0.1
		enemy_max_rot_vel = 1.5 * PI / 2
		enemy_shoot_rate = 0.75
		enemy_shoot_speed_mod = 800
		enemy_starting_discs = 4
		enemy_rot_acc = 2 * PI
		return
	combat_won = is_win
	if is_win:
		for d in enemy_live_discs():
			d.remove_disc()
	else:
		for d in enemy_live_discs():
			d.velocity = Vector2.ZERO
			d.removing = true
	$AnimationPlayer.play("exit")

func combat_exit():
	SignalBus.switch_game.emit(combat_won)
