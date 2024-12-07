class_name PossessableNPC
extends NPC

@export var possessable_outline_color: Color = Color(0, 200, 255)
var is_possessed: bool = false

var will_resume_navigation: bool = false
var already_possessed: bool = false

func _ready():
	super._ready()
	
	var shader_duplicate = sprite_2d.material.duplicate()
	sprite_2d.material = shader_duplicate
	sprite_2d.material.set_shader_parameter("number_of_images", Vector2(sprite_2d.hframes, sprite_2d.vframes))
	
	hide_possession_effect()

func _physics_process(delta):
	if (is_possessed):
		if (player.is_input_active):
			handle_input(delta)
		
		handle_player_movement(delta)
	else:
		handle_npc_movement(delta)
	
	handle_animation()

func handle_player_movement(delta: float):
	if (not is_on_floor()):
		velocity.y += GRAVITY * delta
		
		if (ground_ray_cast.is_colliding()):
			position.y += 1
	
	var true_speed = SPEED
	if (Input.is_action_pressed("sprint")):
		true_speed *= SPRINT_MULTIPLIER
	
	var direction = 0
	if (player.is_input_active):
		direction = Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * true_speed, true_speed / 8)
	else:
		velocity.x = move_toward(velocity.x, 0, true_speed / 8)
	
	move_and_slide()

func handle_input(delta: float):
	#if (Input.is_action_just_pressed("jump") and is_on_floor()):
		#jump()
	pass


func become_possessed():
	is_possessed = true
	disable_interactable()
	inventory.visible = true
	clear_navigation_agent_connections()
	update_current_location()
	
	if (is_navigating):
		will_resume_navigation = true
	
	already_possessed = true

func become_unpossessed():
	is_possessed = false
	interactable_area.enable()
	inventory.visible = false
	update_current_location()
	
	if (will_resume_navigation):
		navigate_to(end_target_position)
		will_resume_navigation = false

func on_player_interacted():
	dialogue_emitter.show_dialogue(current_dialogue_title)

func show_possession_effect():
	if (not player.is_possessing and not already_possessed):
		sprite_2d.material.set_shader_parameter("color", possessable_outline_color)

func hide_possession_effect():
	sprite_2d.material.set_shader_parameter("color", OUTLINE_COLOUR)
