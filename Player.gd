extends CharacterBody2D

const SPEED = 250.0

var walk_cycle: float = 0.0
var step_timer: float = 0.0
var facing_right: bool = true

# Animation states: "idle", "walk", "interact", "celebrate", "sad"
var current_anim: String = "idle"
var anim_timer: float = 0.0

func play_anim(anim_name: String):
	current_anim = anim_name
	if anim_name == "interact":
		anim_timer = 0.6
	elif anim_name == "celebrate":
		anim_timer = 1.5
	elif anim_name == "sad":
		anim_timer = 1.5
	else:
		anim_timer = 0.0
	queue_redraw()

func _draw():
	var flip = 1.0 if facing_right else -1.0
	
	# Determine angles based on current animation
	var leg_angle = 0.0
	var arm_back_angle = 0.1
	var arm_front_angle = -0.1
	
	if current_anim == "walk":
		leg_angle = sin(walk_cycle) * 0.5
		arm_back_angle = sin(walk_cycle) * 0.4
		arm_front_angle = -sin(walk_cycle) * 0.4
	elif current_anim == "interact":
		# Point arm forward
		arm_front_angle = -1.5 * flip
		arm_back_angle = 0.1 * flip
	elif current_anim == "celebrate":
		# Both arms raised in the air
		arm_front_angle = -2.5 * flip
		arm_back_angle = -2.2 * flip
		# Body bounce
		draw_set_transform(Vector2(0, -2 + sin(walk_cycle * 2.0) * 2), 0, Vector2.ONE)
	elif current_anim == "sad":
		# Front arm on head/face, back arm slouched
		arm_front_angle = -2.9 * flip
		arm_back_angle = 0.4 * flip
		# Head slouched
		draw_set_transform(Vector2(0, 2), 0, Vector2.ONE)
	
	# Back leg
	draw_leg(-6 * flip, leg_angle)
	# Back arm
	draw_arm(-11 * flip, arm_back_angle)
	
	# Backpack (dark brown)
	draw_rect(Rect2(-16 * flip - 3, -40, 8, 22), Color(0.3, 0.2, 0.15), true)
	
	# Body (orange engineering suit)
	draw_rect(Rect2(-10, -38, 20, 25), Color(0.85, 0.41, 0.18), true)
	# Belt (dark blue)
	draw_rect(Rect2(-10.5, -18, 21, 5), Color(0.1, 0.18, 0.28), true)
	
	# Head (skin beige)
	draw_circle(Vector2(0, -48), 9, Color(0.98, 0.82, 0.72))
	
	# Hair (brown)
	draw_circle(Vector2(0, -52), 9, Color(0.4, 0.25, 0.15))
	draw_rect(Rect2(-9, -54, 18, 5), Color(0.4, 0.25, 0.15), true)
	
	# Face detail / eye
	var eye_x = 4 * flip
	draw_circle(Vector2(eye_x, -48), 1.5, Color(0.1, 0.1, 0.1))
	
	# Front leg
	draw_leg(6 * flip, -leg_angle)
	# Front arm
	draw_arm(11 * flip, arm_front_angle)
	
	# Reset transform in case body bounce was applied
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func draw_leg(x_offset: float, angle: float):
	draw_set_transform(Vector2(x_offset, -15), angle, Vector2.ONE)
	# Pants leg
	draw_rect(Rect2(-3, 0, 6, 12), Color(0.15, 0.25, 0.35), true)
	# Boot
	draw_rect(Rect2(-4, 12, 8, 4), Color(0.1, 0.1, 0.1), true)
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func draw_arm(x_offset: float, angle: float):
	draw_set_transform(Vector2(x_offset, -32), angle, Vector2.ONE)
	# Sleeve (orange)
	draw_rect(Rect2(-2.5, 0, 5, 12), Color(0.85, 0.41, 0.18), true)
	# Hand (skin beige)
	draw_circle(Vector2(0, 13.5), 2.5, Color(0.98, 0.82, 0.72))
	draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

func _physics_process(delta):
	# Handle temporary animations timers
	if anim_timer > 0.0:
		anim_timer -= delta
		if anim_timer <= 0.0:
			current_anim = "idle"
			
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction * SPEED
	
	move_and_slide()
	
	if velocity.x > 0:
		facing_right = true
	elif velocity.x < 0:
		facing_right = false
		
	if velocity.length() > 0:
		walk_cycle += delta * 12.0
		step_timer += delta
		
		# Only override with walk animation if no high priority animation is playing
		if anim_timer <= 0.0:
			current_anim = "walk"
			
		if step_timer >= 0.35:
			step_timer = 0.0
			if has_node("/root/SoundManager"):
				SoundManager.play_step()
	else:
		walk_cycle = 0.0
		step_timer = 0.0
		if anim_timer <= 0.0:
			current_anim = "idle"
			
	# Animate bounce during celebration even if static
	if current_anim == "celebrate":
		walk_cycle += delta * 15.0
		
	queue_redraw()

