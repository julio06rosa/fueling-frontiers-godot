extends Node2D

enum ShipState { APPROACHING, WAITING, REFUELING, DEPARTING }

var current_state = ShipState.APPROACHING
var ship_pos = Vector2(640, -100)
var ship_target_pos = Vector2(640, 320)
var ship_velocity = Vector2.ZERO
var ship_scale = 1.0

# Ship details
var ship_name: String = ""
var ship_origin: String = ""
var comp_a_name: String = "Plasma-X"
var comp_b_name: String = "Hidrogênio-Y"
var ratio_a: int = 1
var ratio_b: int = 1
var target_volume: float = 200.0
var max_time: float = 45.0
var time_left: float = 45.0

# Refueling state
var current_volume: float = 0.0
var slider_a_val: float = 50.0 # 0% to 100%
var is_pump_on: bool = false
var fuel_color: Color = Color(0.12, 0.66, 0.63) # Teal default

# Hangar state
var credits_label: Label
var rep_label: Label
var hud_panel: Panel
var valve_panel: Panel
var aria_label: Label
var pump_btn: Button
var slider_a: HSlider
var label_a: Label
var label_b: Label
var tank_progress: ProgressBar
var status_label: Label

# Particles
var stars: CPUParticles2D
var thrusters: CPUParticles2D

func _ready():
	# Reference nodes
	credits_label = $CanvasLayer/TopHUD/HBox/CreditsLabel
	rep_label = $CanvasLayer/TopHUD/HBox/ReputationLabel
	hud_panel = $CanvasLayer/HUDPanel
	valve_panel = $CanvasLayer/ValvePanel
	aria_label = $CanvasLayer/AriaPanel/AriaLabel
	pump_btn = $CanvasLayer/ValvePanel/PumpButton
	slider_a = $CanvasLayer/ValvePanel/SliderA
	label_a = $CanvasLayer/ValvePanel/LabelA
	label_b = $CanvasLayer/ValvePanel/LabelB
	tank_progress = $CanvasLayer/HUDPanel/ProgressBar
	status_label = $CanvasLayer/StatusLabel
	stars = $Stars
	thrusters = $Thrusters
	
	# Connect signals
	slider_a.value_changed.connect(_on_slider_a_changed)
	pump_btn.pressed.connect(_on_pump_pressed)
	$CanvasLayer/TopHUD/MenuButton.pressed.connect(_on_menu_pressed)
	
	# Set slider
	slider_a.value = 50
	_on_slider_a_changed(50)
	
	# Initialize HUD
	update_hud_counters()
	
	# Spawn first ship
	spawn_new_ship()

func _process(delta):
	# Starfield speed matches state
	if current_state == ShipState.APPROACHING or current_state == ShipState.DEPARTING:
		stars.gravity = Vector2(-150, 0)
	else:
		stars.gravity = Vector2(-15, 0)
		
	match current_state:
		ShipState.APPROACHING:
			ship_pos = ship_pos.lerp(ship_target_pos, delta * 3.0)
			thrusters.position = ship_pos + Vector2(0, 40)
			thrusters.emitting = true
			if ship_pos.distance_to(ship_target_pos) < 5.0:
				ship_pos = ship_target_pos
				current_state = ShipState.WAITING
				thrusters.emitting = false
				aria_talk("Nave %s (%s) atracada. Requisitos: %.1f UF de %s. Proporção: %d %s para %d %s." % [
					ship_name, ship_origin, target_volume, comp_a_name + "/" + comp_b_name, ratio_a, comp_a_name, ratio_b, comp_b_name
				])
				
		ShipState.WAITING, ShipState.REFUELING:
			# Update patience timer
			time_left -= delta
			if time_left <= 0.0:
				time_left = 0.0
				ship_failed("Tempo esgotado! A nave partiu sem pagar.")
			
			# Low patience warning
			if time_left < 15.0 and current_state == ShipState.WAITING:
				aria_talk("Atenção, Engenheiro Zorome! O tempo de espera da nave está acabando!")
				
			if current_state == ShipState.REFUELING:
				# Refueling logic
				var flow = GameManager.get_flow_rate() * delta
				current_volume += flow
				tank_progress.value = current_volume
				
				# Check auto shutoff valve upgrade
				if GameManager.upgrade_auto_valve and current_volume >= target_volume:
					current_volume = target_volume
					_on_pump_pressed() # Stop pump
					
				if current_volume >= target_volume * 1.15:
					# Massive overflow failure
					_on_pump_pressed() # Auto stop on danger limit
					ship_failed("TRANSBORDAMENTO! O tanque explodiu e danificou a nave.")
					
		ShipState.DEPARTING:
			ship_pos = ship_pos.lerp(Vector2(1400, 320), delta * 2.0)
			thrusters.position = ship_pos + Vector2(-60, 0)
			thrusters.emitting = true
			if ship_pos.x > 1300:
				spawn_new_ship()
				
	# Update labels
	$CanvasLayer/TimerLabel.text = "Tempo Restante: %.1fs" % time_left
	if current_state == ShipState.APPROACHING:
		$CanvasLayer/TimerLabel.text = "Aproximação da Nave..."
	elif current_state == ShipState.DEPARTING:
		$CanvasLayer/TimerLabel.text = "Nave Partindo..."
		
	# Redraw to update ship position
	queue_redraw()

func _draw():
	# Draw Hangar floor / ceiling lines (Sci-fi industrial)
	draw_line(Vector2(0, 480), Vector2(1280, 480), Color(0.15, 0.25, 0.35), 4)
	draw_line(Vector2(0, 100), Vector2(1280, 100), Color(0.15, 0.25, 0.35), 4)
	
	# Draw background hangar columns
	for i in range(5):
		var x = 150 + i * 240
		draw_rect(Rect2(x, 100, 20, 380), Color(0.08, 0.12, 0.2, 0.5), true)
		
	# Draw piping connecting Valve Panel (which is around bottom center/right) to Docking Bay (center)
	# Draw background pipe
	draw_rect(Rect2(300, 460, 340, 15), Color(0.1, 0.15, 0.25), true)
	draw_rect(Rect2(630, 340, 15, 135), Color(0.1, 0.15, 0.25), true)
	
	# Draw liquid flow inside pipe if pump is active
	if is_pump_on:
		var pulse = wrapf(Time.get_ticks_msec() * 0.005, 0, 1)
		draw_rect(Rect2(300, 463, 340, 9), Color(fuel_color.r, fuel_color.g, fuel_color.b, 0.3), true)
		draw_rect(Rect2(633, 340, 9, 135), Color(fuel_color.r, fuel_color.g, fuel_color.b, 0.3), true)
		# Flow particles/dashed lines inside
		for j in range(10):
			var offset = (j * 34) + (pulse * 34)
			draw_circle(Vector2(300 + offset, 467), 3, fuel_color)
			var y_offset = (j * 13) + (pulse * 13)
			draw_circle(Vector2(637, 460 - y_offset), 3, fuel_color)
			
	# Draw the spaceship at ship_pos
	if current_state != ShipState.DEPARTING or ship_pos.x < 1300:
		draw_spaceship(ship_pos)

func draw_spaceship(pos: Vector2):
	# Procedural Spaceship drawing
	var color_hull = Color(0.5, 0.55, 0.6)
	var color_wing = Color(0.35, 0.4, 0.45)
	var color_cockpit = Color(0.1, 0.7, 0.9, 0.8)
	
	if ship_origin == "Marte":
		color_hull = Color(0.75, 0.3, 0.2)
		color_wing = Color(0.5, 0.2, 0.15)
	elif ship_origin == "Júpiter":
		color_hull = Color(0.65, 0.55, 0.4)
		color_wing = Color(0.45, 0.35, 0.25)
	elif ship_origin == "Terra":
		color_hull = Color(0.3, 0.5, 0.7)
		color_wing = Color(0.2, 0.35, 0.5)
		
	# Draw thruster fire if moving
	if current_state == ShipState.APPROACHING or current_state == ShipState.DEPARTING:
		var size = randf_range(15.0, 30.0)
		draw_circle(pos + Vector2(-60, 0), size, Color(1, 0.5, 0))
		draw_circle(pos + Vector2(-60, 0), size * 0.6, Color(1, 0.9, 0))

	# Wings
	var wing_poly = PackedVector2Array([
		pos + Vector2(-30, -10),
		pos + Vector2(-50, -40),
		pos + Vector2(0, -15),
		pos + Vector2(10, 0),
		pos + Vector2(0, 15),
		pos + Vector2(-50, 40),
		pos + Vector2(-30, 10)
	])
	draw_polygon(wing_poly, [color_wing])

	# Cockpit/Body
	var hull_poly = PackedVector2Array([
		pos + Vector2(-60, -15),
		pos + Vector2(-50, -20),
		pos + Vector2(20, -15),
		pos + Vector2(60, 0),
		pos + Vector2(20, 15),
		pos + Vector2(-50, 20),
		pos + Vector2(-60, 15)
	])
	draw_polygon(hull_poly, [color_hull])

	# Glass visor
	var glass_poly = PackedVector2Array([
		pos + Vector2(10, -8),
		pos + Vector2(35, 0),
		pos + Vector2(10, 8),
		pos + Vector2(5, 0)
	])
	draw_polygon(glass_poly, [color_cockpit])
	
	# Fuel Cap highlight
	draw_circle(pos + Vector2(0, 0), 6, Color(0.85, 0.41, 0.18))
	draw_circle(pos + Vector2(0, 0), 4, Color(0.1, 0.1, 0.1))

func spawn_new_ship():
	current_state = ShipState.APPROACHING
	ship_pos = Vector2(-200, 320) # Começa da esquerda voando
	ship_target_pos = Vector2(640, 320)
	
	# Randomize ship properties
	var names = ["MR-118", "JC-774", "EX-201", "TR-990", "PX-505", "Z-100"]
	ship_name = names[randi() % names.size()]
	
	var origins = ["Marte", "Júpiter", "Terra", "Desconhecida"]
	ship_origin = origins[randi() % origins.size()]
	
	var comps = [
		["Plasma-X", "Hidrogênio-Y"],
		["Plasmio", "Hidrolit"],
		["Hidrogênio-Y", "Oxidante-Z"],
		["Plasma-X", "Oxidante-Z"]
	]
	var selected_comps = comps[randi() % comps.size()]
	comp_a_name = selected_comps[0]
	comp_b_name = selected_comps[1]
	
	# Ratios
	var ratios = [[1,1], [2,1], [3,1], [4,1], [3,2], [1,3]]
	var r = ratios[randi() % ratios.size()]
	ratio_a = r[0]
	ratio_b = r[1]
	
	var volumes = [100.0, 150.0, 200.0, 250.0, 300.0]
	target_volume = volumes[randi() % volumes.size()]
	
	max_time = randf_range(40.0, 65.0)
	time_left = max_time
	
	# Reset refueling progress
	current_volume = 0.0
	is_pump_on = false
	pump_btn.text = "Ativar Bomba"
	tank_progress.max_value = target_volume
	tank_progress.value = 0.0
	status_label.text = ""
	
	if has_node("/root/SoundManager"):
		SoundManager.play_landing()
		SoundManager.set_pump_active(false)
		
	# Update labels
	update_ship_hud()

func update_ship_hud():
	$CanvasLayer/HUDPanel/ShipNameLabel.text = "Nave: %s" % ship_name
	$CanvasLayer/HUDPanel/OriginLabel.text = "Origem: %s" % ship_origin
	$CanvasLayer/HUDPanel/FuelFormulaLabel.text = "Fórmula: %d %s : %d %s" % [ratio_a, comp_a_name, ratio_b, comp_b_name]
	$CanvasLayer/HUDPanel/VolumeLabel.text = "Volume: %.1f UF" % target_volume
	
	# Calculate target percentage
	var total_parts = float(ratio_a + ratio_b)
	var target_pct_a = (float(ratio_a) / total_parts) * 100.0
	
	if GameManager.upgrade_helper_hud:
		$CanvasLayer/HUDPanel/TargetHelperLabel.text = "Meta: %.1f%% %s / %.1f%% %s" % [
			target_pct_a, comp_a_name, 100.0 - target_pct_a, comp_b_name
		]
	else:
		$CanvasLayer/HUDPanel/TargetHelperLabel.text = "Calcule a proporção correta!"
		
	_on_slider_a_changed(slider_a.value)

func _on_slider_a_changed(value):
	slider_a_val = value
	var val_b = 100.0 - value
	
	label_a.text = "%s: %d%%" % [comp_a_name, int(value)]
	label_b.text = "%s: %d%%" % [comp_b_name, int(val_b)]
	
	# Update fuel color based on ratio correctness
	var total_parts = float(ratio_a + ratio_b)
	var target_pct_a = (float(ratio_a) / total_parts) * 100.0
	
	# Check distance to target
	var diff = abs(value - target_pct_a)
	
	if diff <= 2.0:
		# Correct ratio: Teal/Green fuel
		fuel_color = Color(0.12, 0.66, 0.63) # Teal
		$CanvasLayer/ValvePanel/RatioFeedbackLabel.text = "Mistura Estável"
		$CanvasLayer/ValvePanel/RatioFeedbackLabel.add_theme_color_override("font_color", Color(0.12, 0.66, 0.63))
	else:
		# Incorrect ratio: Dissonant Purple
		fuel_color = Color(0.68, 0.15, 0.61) # Purple
		$CanvasLayer/ValvePanel/RatioFeedbackLabel.text = "Mistura Instável!"
		$CanvasLayer/ValvePanel/RatioFeedbackLabel.add_theme_color_override("font_color", Color(0.85, 0.25, 0.25))

func _on_pump_pressed():
	if current_state == ShipState.APPROACHING or current_state == ShipState.DEPARTING:
		return
		
	is_pump_on = !is_pump_on
	if is_pump_on:
		current_state = ShipState.REFUELING
		pump_btn.text = "Parar Bomba"
		aria_talk("Bomba ativada. Injetando combustível no tanque...")
		if has_node("Player"):
			$Player.play_anim("interact")
		if has_node("/root/SoundManager"):
			SoundManager.set_pump_active(true)
			# Set pitch based on upgrade speed
			SoundManager.pump_pitch = 100.0 + (GameManager.upgrade_pump_speed * 30.0)
	else:
		current_state = ShipState.WAITING
		pump_btn.text = "Ativar Bomba"
		aria_talk("Bomba desligada. Verificando o reabastecimento...")
		if has_node("Player"):
			$Player.play_anim("interact")
		if has_node("/root/SoundManager"):
			SoundManager.set_pump_active(false)
		
		# Validate immediately when pump is turned off
		validate_refuel()

func validate_refuel():
	# Calculate target percentage
	var total_parts = float(ratio_a + ratio_b)
	var target_pct_a = (float(ratio_a) / total_parts) * 100.0
	
	var pct_diff = abs(slider_a_val - target_pct_a)
	var vol_diff = abs(current_volume - target_volume)
	
	var is_ratio_ok = pct_diff <= 2.0
	var is_volume_ok = vol_diff <= target_volume * 0.03 # 3% tolerance
	
	if is_ratio_ok and is_volume_ok:
		# Success! Perfect refuel
		var earned = int(target_volume * 2.0)
		# speed bonus
		if time_left > max_time * 0.5:
			earned += 100
			
		GameManager.credits += earned
		GameManager.reputation = clamp(GameManager.reputation + 0.05, 0.0, 1.0)
		status_label.text = "ABASTECIMENTO PERFEITO!\n+%d Créditos | +5%% Reputação" % earned
		status_label.add_theme_color_override("font_color", Color(0.12, 0.8, 0.5))
		
		aria_talk("Excepcional, Zorome! Mistura exata e volume perfeito. O capitão está muito satisfeito!")
		if has_node("Player"):
			$Player.play_anim("celebrate")
		if has_node("/root/SoundManager"):
			SoundManager.play_success()
			
		ship_depart()
	else:
		# Failure cases
		var penalty_credits = 150
		GameManager.credits = max(0, GameManager.credits - penalty_credits)
		GameManager.reputation = clamp(GameManager.reputation - 0.08, 0.0, 1.0)
		
		var error_msg = ""
		if not is_ratio_ok and not is_volume_ok:
			error_msg = "Mistura errada e Volume incorreto!"
		elif not is_ratio_ok:
			error_msg = "MISTURA INCORRETA!\nComponentes químicos instáveis. Combustível rejeitado."
		elif current_volume < target_volume:
			error_msg = "VOLUME INSUFICIENTE!\nO tanque não foi completamente preenchido."
		else:
			error_msg = "TRANSBORDAMENTO!\nVolume acima do limite de segurança."
			
		status_label.text = "%s\n-%d Créditos | -8%% Reputação" % [error_msg, penalty_credits]
		status_label.add_theme_color_override("font_color", Color(0.85, 0.25, 0.25))
		
		aria_talk("Erro no reabastecimento. A nave recusou o combustível. Tivemos prejuízo!")
		if has_node("Player"):
			$Player.play_anim("sad")
		if has_node("/root/SoundManager"):
			SoundManager.play_failure()
			
		ship_depart()

func ship_failed(reason: String):
	is_pump_on = false
	if has_node("Player"):
		$Player.play_anim("sad")
	if has_node("/root/SoundManager"):
		SoundManager.set_pump_active(false)
		SoundManager.play_failure()
		
	GameManager.reputation = clamp(GameManager.reputation - 0.1, 0.0, 1.0)
	GameManager.credits = max(0, GameManager.credits - 200)
	
	status_label.text = "FALHA: %s\n-200 Créditos | -10%% Reputação" % reason
	status_label.add_theme_color_override("font_color", Color(0.85, 0.25, 0.25))
	
	ship_depart()

func ship_depart():
	current_state = ShipState.DEPARTING
	update_hud_counters()

func spawn_particles():
	pass

func aria_talk(text: String):
	aria_label.text = "ARIA: " + text

func update_hud_counters():
	credits_label.text = "Créditos: %d" % GameManager.credits
	rep_label.text = "Reputação: %d%%" % int(GameManager.reputation * 100.0)

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://MainMenu.tscn")
