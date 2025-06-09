extends Node2D

var sprite_index = 0 :
	set(val):
		$Sprite2D.texture = sprites[val]
		if val == 1 or val == 2:
			$Sprite2D.position = Vector2(43, 114)
		else:
			$Sprite2D.position = Vector2(-57, 105)
		
		sprite_index = val

var disc_sprite_index = 0 :
	set(val):
		$Sprite2D2.texture = disc_sprites[val]
		disc_sprite_index = val

var sprites = [
	preload("res://01_Assets/01_Sprites/hand_sprites/summer_hand_spritesheet.png"),
	preload("res://01_Assets/01_Sprites/hand_sprites/albert_hand_spritesheet.png"),
	preload("res://01_Assets/01_Sprites/hand_sprites/periwinkle_hand_spritesheet.png"),
	preload("res://01_Assets/01_Sprites/hand_sprites/elm_hand_spritesheet.png"),
	preload("res://01_Assets/01_Sprites/hand_sprites/prin_hand_spritesheet.png")
]

var disc_sprites = [
	preload("res://01_Assets/01_Sprites/button_sprites/summer's_main_button.png"),
	preload("res://01_Assets/01_Sprites/button_sprites/al_evil_button.png"),
	preload("res://01_Assets/01_Sprites/button_sprites/periwinkle_evil_button.png"),
	preload("res://01_Assets/01_Sprites/button_sprites/elm_evil_button.png"),
	preload("res://01_Assets/01_Sprites/button_sprites/prin_evil_button.png")
]

func _process(delta: float) -> void:
	var center = Vector2(640, 360)
	rotation = global_position.angle_to_point(center) + PI / 2

func pull_back(s):
	$Sprite2D.frame = 1
	$Sprite2D2.visible = true
	$Sprite2D2.scale = Vector2(s, s)

func let_go():
	$Sprite2D.frame = 0
	$Sprite2D2.visible = false
