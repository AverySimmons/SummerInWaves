class_name Disc
extends Area2D
# Generic class for discs. Contains 

const FRICTION_COEFFICIENT = 800
const ROTATIONAL_FRICTION = 6

var textures = [
	preload("res://01_Assets/01_Sprites/button_sprites/al_evil_button.png"),
	preload("res://01_Assets/01_Sprites/button_sprites/periwinkle_evil_button.png"),
	preload("res://01_Assets/01_Sprites/button_sprites/elm_evil_button.png"),
	preload("res://01_Assets/01_Sprites/button_sprites/prin_evil_button.png")
]

var removing = false
var sprite_index = 0
var has_entered_ring = false

var is_enemy: bool
@export var velocity: Vector2 = Vector2(0, 0)
var friction: Vector2
var collision_cooldown: float
@export var max_velocity: float = 800

@export var mass: float = 4
@onready var radius: float = $CollisionShape2D.shape.radius
var center_of_mass: Vector2 = position
@onready var inertia: float = 0.5 * mass * radius*radius
@export var rotational_velocity: float
var timer: float

func _ready() -> void:
	if sprite_index != -1:
		$Sprite2D.texture = textures[sprite_index]
	pass

func _physics_process(delta: float) -> void:
	var vel_dir = velocity.rotated(-rotation + PI / 2)
	if vel_dir == Vector2.ZERO: vel_dir = Vector2.RIGHT
	$Sprite2D.material.set_shader_parameter("direction", vel_dir)
	var vel_str = 1 + clamp(velocity.length() / (4000 / 0.3), 0, 0.3)
	$Sprite2D.material.set_shader_parameter("strength", vel_str)
	
	if collision_cooldown > 0:
		collision_cooldown -= delta
	
	#if timer >= 2:
		#print(position)
		#timer = 0
	#timer += delta
	# Velocity
	if velocity.length() > max_velocity:
		velocity = velocity.normalized() * max_velocity
	
	position += velocity * delta
	center_of_mass = position
	rotation += rotational_velocity * delta
	
	if velocity.length() > 0.001:
		friction = abs(FRICTION_COEFFICIENT * velocity.normalized())
	else:
		friction = Vector2(0, 0)
	velocity.x = move_toward(velocity.x, 0, friction.x*delta)
	velocity.y = move_toward(velocity.y, 0, friction.y*delta)
	
	rotational_velocity = move_toward(rotational_velocity, 0, ROTATIONAL_FRICTION*delta)
	
	if removing: return
	
	# Momentum
	if collision_cooldown <= 0 && has_overlapping_areas():
		#sound call
		disc_collision_sound(velocity)
		
		instigate_collision()
		collision_cooldown = 0.1
		return
	pass


func remove_disc():
	if removing: return
	$DiscPoof.play()
	monitorable = false
	monitoring = false
	removing = true
	SignalBus.disc_removed.emit(self is EnemyDisc)
	var t = create_tween()
	t.tween_property($Sprite2D, "scale", $Sprite2D.scale * 1.3, 0.075)
	t.tween_property($Sprite2D, "scale", Vector2.ZERO, 0.2)
	await t.finished
	queue_free()

func instigate_collision() -> void:
	var overlapping_discs = get_overlapping_areas()
	if overlapping_discs.size() == 1:
		# Single collision
		var other_disc: Disc = overlapping_discs[0]
		
		if other_disc is not Disc:
			return
		
		if get_instance_id() > other_disc.get_instance_id():
			return
		instigate_single_collision(other_disc)
	else:
		# Multiple collision
		#for other_disc in overlapping_discs:
			#if other_disc.get_instance_id() > get_instance_id():
				#return
		for other_disc in overlapping_discs:
			instigate_single_collision(other_disc)
		pass
	return

func instigate_single_collision(other_disc: Disc) -> void:
	#print('Disc A Position:', global_position)
	#print('Disc B Position:', other_disc.global_position)
	#print('Disc A Velocity:', velocity)
	#print('Disc B Velocity:', other_disc.velocity)
	#print('Disc A Radius:', radius)
	#print('Disc B Radius:', other_disc.radius)
	#print('Disc A Mass:', mass)
	#print('Disc B Mass:', other_disc.mass)
	#print('Disc A Center of Mass', center_of_mass)
	#print('Disc B Center of Mass', other_disc.center_of_mass)
	#print('Disc A Rotational Velocity', rotational_velocity)
	#print('Disc B Rotational Velocity', other_disc.rotational_velocity)
	radius = $CollisionShape2D.shape.radius
	fix_penetration(other_disc)
	var collision_point: Vector2 = find_collision_point(other_disc)
	var vector_from_center_of_mass: Vector2 = collision_point - center_of_mass
	var collision_normal: Vector2 = vector_from_center_of_mass.normalized()
	var collision_tangent: Vector2 = Vector2(-collision_normal.y, collision_normal.x)
	var lever_arm: Vector2 = collision_point - center_of_mass
	var other_disc_lever_arm: Vector2 = collision_point - other_disc.center_of_mass
	var impact_velocity: Vector2 = get_velocity_at_point_of_impact(lever_arm) - other_disc.get_velocity_at_point_of_impact(vector_from_center_of_mass)
	var normal_speed: float = impact_velocity.x * collision_normal.x + impact_velocity.y * collision_normal.y
	var tangent_speed: float = impact_velocity.x * collision_tangent.x + impact_velocity.y * collision_tangent.y
	var normal_impulse: float = calculate_normal_impulse(normal_speed, other_disc)
	var tangential_impulse: float = calculate_tangential_impulse(tangent_speed, other_disc, lever_arm, other_disc_lever_arm, collision_tangent, normal_impulse)
	#print('Collision Point: ', collision_point)
	#print('Vector from Center of Mass: ', vector_from_center_of_mass)
	#print('Collision Normal: ', collision_normal)
	#print('Collision Tangent: ', collision_tangent)
	#print('Lever Arm: ', lever_arm)
	#print('Other Disc Lever Arm: ', other_disc_lever_arm)
	#print('Impact Velocity: ', impact_velocity)
	#print('Normal Speed: ', normal_speed)
	#print('Tangent Speed: ', tangent_speed)
	#print('Normal Impulse: ', normal_impulse)
	#print('Tangential Impulse: ', tangential_impulse)
	
	apply_linear_impulse(normal_impulse, tangential_impulse, collision_normal, collision_tangent)
	other_disc.apply_linear_impulse(-normal_impulse, -tangential_impulse, collision_normal, collision_tangent)
	
	apply_rotational_impulse(lever_arm, normal_impulse, tangential_impulse, collision_normal, collision_tangent)
	other_disc.apply_rotational_impulse(other_disc_lever_arm, normal_impulse, tangential_impulse, collision_normal, collision_tangent)
	#print("Final Velocity A:", velocity)
	#print("Final Velocity B:", other_disc.velocity)
	#print("Rotational velocity A:", rotational_velocity)
	#print("Rotational velocity B:", other_disc.rotational_velocity)
	# print(position)
	return

func fix_penetration(other_disc: Disc) -> void:
	var distance_between_centers: Vector2 = other_disc.center_of_mass - center_of_mass
	var distance_penetrated: float = (radius+other_disc.radius) - distance_between_centers.length()
	
	if distance_penetrated <= 0:
		return
	
	var normal: Vector2 = distance_between_centers.normalized()
	position -= 0.5 * distance_penetrated * normal
	other_disc.position += 0.5 * distance_penetrated * normal
	return

func apply_linear_impulse(normal_impulse: float, tangential_impulse: float, collision_normal: Vector2, collision_tangent: Vector2) -> void:
	var change_in_linear_velocity: Vector2 = 1/mass * ((normal_impulse * collision_normal) + (tangential_impulse * collision_tangent))
	velocity += change_in_linear_velocity
	return

func apply_rotational_impulse(lever_arm: Vector2, normal_impulse: float, tangential_impulse: float, collision_normal: Vector2,
							  collision_tangent: Vector2) -> void:
	var impulse: Vector2 = normal_impulse * collision_normal + tangential_impulse * collision_tangent
	var change_in_rotational_velocity: float = -(lever_arm.cross(impulse))/inertia
	rotational_velocity += change_in_rotational_velocity
	return

func calculate_tangential_impulse(tangent_speed: float, other_disc: Disc, lever_arm: Vector2, 
								  other_disc_lever_arm: Vector2, collision_tangent: Vector2, normal_impulse: float) -> float:
	var effective_mass: float = 1/(1/mass + 1/other_disc.mass + (lever_arm.dot(collision_tangent)**2)/inertia
								   + (other_disc_lever_arm.dot(collision_tangent)**2)/other_disc.inertia)
	var raw_tangential_impulse = -effective_mass * tangent_speed
	var max_friction_impulse = 0.1 * abs(normal_impulse)
	return clamp(raw_tangential_impulse, -max_friction_impulse, max_friction_impulse)

func calculate_normal_impulse(normal_speed: float, other_disc: Disc) -> float:
	if normal_speed <= 0:
		return 0
	var effective_mass: float = 1/(1/mass + 1/other_disc.mass)
	return -(effective_mass * 2 * normal_speed)
	
func find_collision_point(other_disc: Disc) -> Vector2:
	# print(position)
	var direction = (other_disc.center_of_mass - center_of_mass).normalized()
	return center_of_mass + direction * radius

func get_velocity_at_point_of_impact(vector_from_center_of_mass: Vector2) -> Vector2:
	# print(position)
	var tangent_dir = Vector2(-vector_from_center_of_mass.y, vector_from_center_of_mass.x).normalized()
	var rotational_velocity_at_point = tangent_dir * rotational_velocity * vector_from_center_of_mass.length()
	return velocity + rotational_velocity_at_point

func is_moving() -> bool:
	return velocity.length() > 5


func _on_playspace_check_area_entered(area: Area2D) -> void:
	has_entered_ring = true
	
func disc_collision_sound(velocity: Vector2) -> void:
	var speed: float = velocity.length()
	var min_volume: float = -20
	var min_speed: float = 0
	var max_speed = 1500
	var volume = lerp(min_volume, 0.0, clamp((speed - min_speed) / (max_speed - min_speed), 0.0, 1.0))

	$CollisionSound.volume_db = volume
	$CollisionSound.pitch_scale = 1 + randf_range(-0.1, 0.1)
	$CollisionSound.stop()
	$CollisionSound.play()
	return
