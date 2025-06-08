extends CharacterBody2D

const ACC = 4000
const TURN_ACC = 8000
const IDLE_DEACC = 6000
const MAX_SPEED = 175

@export var talking = false

var facing_dir = ""

func _physics_process(delta: float) -> void:
	
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	if Dialogic.current_timeline:
		input_dir = Vector2.ZERO
	
	if input_dir != Vector2.ZERO or facing_dir:
		if input_dir == Vector2.ZERO:
			$AnimationPlayer.play(facing_dir + "_idle")
			facing_dir = ""
		else:
			var input_ang = input_dir.angle()
			var new_facing_dir = facing_dir
			if input_ang < PI / 4 - 0.01 and input_ang > -PI / 4 + 0.01:
				new_facing_dir = "right"
			elif input_ang < 3 * PI / 4 + 0.01 and input_ang > PI / 4 - 0.01:
				new_facing_dir = "down"
			elif input_ang < -PI / 4 + 0.01 and input_ang > -3 * PI / 4 - 0.01:
				new_facing_dir = "up"
			else:
				new_facing_dir = "left"
			
			if new_facing_dir != facing_dir:
				$AnimationPlayer.play(new_facing_dir + "_walk")
				facing_dir = new_facing_dir
	
	
	var cur_acc = ACC 
	if input_dir.dot(velocity) > 0:
		cur_acc = TURN_ACC
	if input_dir == Vector2.ZERO:
		cur_acc = IDLE_DEACC
	
	velocity = velocity.move_toward(input_dir * MAX_SPEED, cur_acc * delta)
	
	move_and_slide()
	
	if Input.is_action_just_pressed("talk"):
		var areas = $InteractBox.get_overlapping_areas()
		if not areas: return
		
		var npc: NPC = areas[0]
		npc.talk()
