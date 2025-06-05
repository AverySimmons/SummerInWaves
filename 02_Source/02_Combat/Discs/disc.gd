class_name Disc
extends Area2D
# Generic class for discs. Contains 

const FRICTION_COEFFICIENT = 100
const ROTATIONAL_FRICTION = 1

var is_enemy: bool
var sprite
var velocity: Vector2 = Vector2(400, 0)
var friction: Vector2

var mass: float = 1
var radius: float = 10
var center_of_mass: Vector2 = position
@onready var inertia: float = 1/2 * mass * radius**2
var rotational_velocity: float

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	# Velocity
	position += velocity * delta
	center_of_mass = position
	
	rotation += rotational_velocity
	
	friction = FRICTION_COEFFICIENT * velocity.normalized()
	velocity.x = move_toward(velocity.x, 0, friction.x*delta)
	velocity.y = move_toward(velocity.y, 0, friction.y*delta)
	rotational_velocity = move_toward(rotational_velocity, 0, ROTATIONAL_FRICTION*delta)
	
	# Momentum
	if has_overlapping_areas():
		instigate_collision()
		return
	pass


func instigate_collision() -> void:
	var overlapping_discs = get_overlapping_areas()
	if overlapping_discs.size() == 1:
		# Single collision
		var other_disc: Disc = overlapping_discs[0]
		if other_disc.velocity.x + other_disc.velocity.y > velocity.x + velocity.y:
			return
		instigate_single_collision(other_disc)
	else:
		# Multiple collision
		pass
	return

func instigate_single_collision(other_disc: Disc) -> void:
	var collision_point: Vector2 = find_collision_point(other_disc)
	var vector_from_center_of_mass: Vector2 = collision_point - center_of_mass
	var collision_normal: Vector2 = vector_from_center_of_mass.normalized()
	var collision_tangent: Vector2 = Vector2(-collision_normal.y, collision_normal.x)
	var lever_arm: Vector2 = -(radius * collision_normal)
	var other_disc_lever_arm: Vector2 = other_disc.radius * collision_normal
	var impact_velocity: Vector2 = get_velocity_at_point_of_impact(vector_from_center_of_mass) - other_disc.get_velocity_at_point_of_impact(vector_from_center_of_mass)
	var normal_speed: float = impact_velocity.x * collision_normal.x + impact_velocity.y * collision_normal.y
	var tangent_speed: float = impact_velocity.x * collision_tangent.x + impact_velocity.y * collision_tangent.y
	var normal_impulse: float = calculate_normal_impulse(normal_speed, other_disc)
	var tangential_impulse: float = calculate_tangential_impulse(tangent_speed, other_disc, lever_arm, other_disc_lever_arm, collision_tangent)
	
	apply_linear_impulse(normal_impulse, tangential_impulse, collision_normal, collision_tangent)
	other_disc.apply_linear_impulse(normal_impulse, tangential_impulse, collision_normal, collision_tangent)
	
	apply_rotational_impulse(lever_arm, normal_impulse, tangential_impulse, collision_normal, collision_tangent)
	other_disc.apply_rotational_impulse(other_disc_lever_arm, normal_impulse, tangential_impulse, collision_normal, collision_tangent)
	return

func apply_linear_impulse(normal_impulse: float, tangential_impulse: float, collision_normal: Vector2, collision_tangent: Vector2) -> void:
	var change_in_linear_velocity: Vector2 = -1/mass * ((normal_impulse * collision_normal) + (tangential_impulse * collision_tangent))
	velocity += change_in_linear_velocity
	return

func apply_rotational_impulse(lever_arm: Vector2, normal_impulse: float, tangential_impulse: float, collision_normal: Vector2,
							  collision_tangent: Vector2) -> void:
	var impulse: Vector2 = normal_impulse * collision_normal + tangential_impulse * collision_tangent
	var change_in_rotational_velocity: float = -(lever_arm.cross(impulse))/inertia
	rotational_velocity += change_in_rotational_velocity
	return

func calculate_tangential_impulse(tangent_speed: float, other_disc: Disc, lever_arm: Vector2, 
								  other_disc_lever_arm: Vector2, collision_tangent: Vector2) -> float:
	var effective_mass: float = 1/(1/mass + 1/other_disc.mass + (lever_arm.dot(collision_tangent)**2)/inertia 
								   + (other_disc_lever_arm.dot(collision_tangent)**2)/inertia)
	return -(effective_mass*tangent_speed)

func calculate_normal_impulse(normal_speed: float, other_disc: Disc) -> float:
	var effective_mass: float = 1/(1/mass + 1/other_disc.mass)
	return effective_mass * 2 * normal_speed
	
func find_collision_point(other_disc: Disc) -> Vector2:
	var vector_to_other_disc = (other_disc.center_of_mass - center_of_mass).normalized()
	return center_of_mass * vector_to_other_disc * radius

func get_velocity_at_point_of_impact(vector_from_center_of_mass: Vector2) -> Vector2:
	var rotational_velocity_at_point: Vector2 = rotational_velocity * Vector2(-vector_from_center_of_mass.y, vector_from_center_of_mass.x)
	return velocity + rotational_velocity_at_point

func is_moving() -> bool:
	return velocity.x != 0 || velocity.y != 0
