extends CharacterBody2D

var speed = 250

func _physics_process(delta: float) -> void:
	var input_dir = Input.get_vector("left", "right", "up", "down")
	velocity = input_dir * speed
	move_and_slide()
