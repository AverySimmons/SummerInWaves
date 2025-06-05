extends CharacterBody2D

const ACC = 2000
const TURN_ACC = 5000
const IDLE_DEACC = 4000
const MAX_SPEED = 300

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	var cur_acc = ACC 
	if input_dir.dot(velocity) > 0:
		cur_acc = TURN_ACC
	if input_dir == Vector2.ZERO:
		cur_acc = IDLE_DEACC
	
	velocity = velocity.move_toward(input_dir * MAX_SPEED, cur_acc * delta)
	
	move_and_slide()
