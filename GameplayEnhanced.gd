extends "res://Gameplay.gd"

# Camada de produto: apresentação, contratos, qualidade de vida e estatísticas.
var arrivals: int = 0
var streak: int = 0
var successes: int = 0
var special_contract: bool = false
@onready var extension_hud: Label = $CanvasLayer/ExtensionHUD
@onready var flight_label: Label = $CanvasLayer/FlightLabel
@onready var shortcut_label: Label = $CanvasLayer/ShortcutLabel
@onready var rank_label: Label = $CanvasLayer/TopHUD/RankLabel
var milestone: int = 0
var animation_time: float = 0.0
var ship_visual
var gameplay_paused: bool = false
var pause_overlay: Control
var pump_was_active_before_pause: bool = false
var service_started_msec: int = 0

func _ready() -> void:
	super._ready()
	ship_visual = preload("res://ShipVisual.gd").new()
	add_child(ship_visual)
	apply_presentation()
	build_pause_overlay()
	refresh_rank()

func spawn_new_ship() -> void:
	super.spawn_new_ship()
	arrivals += 1
	milestone = 0
	service_started_msec = Time.get_ticks_msec()
	# Contratos especiais entram como picos de dificuldade e recompensa.
	special_contract = successes >= 3 and arrivals % 3 == 0
	if special_contract:
		var advanced_ratios: Array[Vector2i] = [Vector2i(5, 2), Vector2i(2, 5), Vector2i(5, 3), Vector2i(3, 5)]
		var selected: Vector2i = advanced_ratios[randi() % advanced_ratios.size()]
		ratio_a = selected.x
		ratio_b = selected.y
		ship_name += " / ELITE"
		update_ship_hud()
	refresh_extension_hud()

func refresh_extension_hud() -> void:
	if not is_instance_valid(extension_hud):
		return
	var contract_name: String = "CONTRATO REGULAR"
	if special_contract:
		contract_name = "CONTRATO ELITE | BÔNUS +150"
	extension_hud.text = "%s\nAtendimento %d | Sequência: %d\nConcluídos neste turno: %d" % [contract_name, arrivals, streak, successes]
	extension_hud.modulate = Color(1.0, 0.78, 0.35) if special_contract else Color(0.5, 0.88, 0.9)

func refresh_rank() -> void:
	if is_instance_valid(rank_label):
		rank_label.text = "%s  •  %d%%" % [GameManager.get_rank_name(), int(GameManager.reputation * 100.0)]

func _process(delta: float) -> void:
	if gameplay_paused:
		return

	super._process(delta)
	animation_time += delta
	if is_instance_valid(ship_visual):
		ship_visual.position = ship_pos + Vector2(0, sin(animation_time * 1.8) * 2.5)
		ship_visual.origin = ship_origin
		ship_visual.moving = current_state == ShipState.APPROACHING or current_state == ShipState.DEPARTING
		ship_visual.pumping = is_pump_on
		ship_visual.elite = special_contract
		ship_visual.fill = current_volume / target_volume
		ship_visual.rotation = sin(animation_time * 1.5) * 0.012
		thrusters.emitting = false

	var active: bool = current_state == ShipState.WAITING or current_state == ShipState.REFUELING
	if active:
		var fill: float = current_volume / target_volume
		var alert: String = "Ajuste a mistura e acompanhe o tanque."
		if fill >= 0.95:
			alert = "95% OU MAIS: prepare-se para parar a bomba!"
		elif fill >= 0.5:
			alert = "Metade do tanque preenchida. Monitore o volume."
		flight_label.text = "Tanque: %.1f / %.1f UF\n%s" % [current_volume, target_volume, alert]
		flight_label.modulate = Color(1.0, 0.7, 0.25) if fill >= 0.95 else Color(0.7, 0.88, 1.0)
		var next_milestone: int = 2 if fill >= 0.95 else (1 if fill >= 0.5 else 0)
		if next_milestone > milestone:
			milestone = next_milestone
			aria_talk(alert)
		if time_left < 15.0:
			$CanvasLayer/TimerLabel.modulate = Color(1.0, 0.45 + 0.2 * sin(animation_time * 7.0), 0.35)
		else:
			$CanvasLayer/TimerLabel.modulate = Color.WHITE
	else:
		$CanvasLayer/TimerLabel.modulate = Color.WHITE
		flight_label.modulate = Color(0.7, 0.88, 1.0)
		flight_label.text = "Preparando o próximo atendimento..." if current_state == ShipState.DEPARTING else "Nave em aproximação | Confira o manifesto"

func validate_refuel() -> void:
	var target_pct: float = float(ratio_a) / float(ratio_a + ratio_b) * 100.0
	var ratio_error: float = abs(slider_a_val - target_pct)
	var volume_error_pct: float = abs(current_volume - target_volume) / target_volume * 100.0
	var successful: bool = ratio_error <= 2.0 and volume_error_pct <= 3.0
	var credits_before: int = GameManager.credits
	var elapsed_seconds: float = float(Time.get_ticks_msec() - service_started_msec) / 1000.0

	super.validate_refuel()

	if successful:
		streak += 1
		successes += 1
		var bonus: int = mini(streak - 1, 5) * 25
		if special_contract:
			bonus += 150
		if bonus > 0:
			GameManager.credits += bonus
			status_label.text += "\nBônus de contrato/sequência: +%d CR" % bonus
			update_hud_counters()

		var grade: String = performance_grade(ratio_error, volume_error_pct)
		status_label.text += "\nClassificação %s  •  mistura ±%.1f%%  •  volume ±%.1f%%  •  %.1fs" % [grade, ratio_error, volume_error_pct, elapsed_seconds]
		var earned_total: int = maxi(0, GameManager.credits - credits_before)
		GameManager.register_success(streak, earned_total)
	else:
		streak = 0
		status_label.text += "\nDiagnóstico  •  mistura ±%.1f%%  •  volume ±%.1f%%  •  %.1fs" % [ratio_error, volume_error_pct, elapsed_seconds]
		GameManager.register_failure("Reabastecimento recusado")

	refresh_extension_hud()
	refresh_rank()

func performance_grade(ratio_error: float, volume_error_pct: float) -> String:
	if ratio_error <= 0.35 and volume_error_pct <= 0.60:
		return "S"
	if ratio_error <= 0.80 and volume_error_pct <= 1.25:
		return "A"
	if ratio_error <= 1.40 and volume_error_pct <= 2.10:
		return "B"
	return "C"

func ship_failed(reason: String) -> void:
	streak = 0
	super.ship_failed(reason)
	GameManager.register_failure(reason)
	refresh_extension_hud()
	refresh_rank()

func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	if event.keycode == KEY_ESCAPE:
		toggle_pause()
		get_viewport().set_input_as_handled()
		return

	if gameplay_paused:
		return

	if event.keycode == KEY_SPACE:
		if current_state == ShipState.WAITING or current_state == ShipState.REFUELING:
			_on_pump_pressed()
			get_viewport().set_input_as_handled()
	elif event.keycode == KEY_Q or event.keycode == KEY_E:
		var direction: float = -1.0 if event.keycode == KEY_Q else 1.0
		var step: float = 5.0 if event.shift_pressed else 1.0
		slider_a.value = clampf(slider_a.value + direction * step, slider_a.min_value, slider_a.max_value)
		get_viewport().set_input_as_handled()

func _on_menu_pressed() -> void:
	toggle_pause()

func toggle_pause() -> void:
	gameplay_paused = not gameplay_paused
	pause_overlay.visible = gameplay_paused
	if has_node("Player"):
		$Player.process_mode = Node.PROCESS_MODE_DISABLED if gameplay_paused else Node.PROCESS_MODE_INHERIT

	if gameplay_paused:
		pump_was_active_before_pause = is_pump_on
		if has_node("/root/SoundManager"):
			SoundManager.set_pump_active(false)
		update_pause_text()
	else:
		if has_node("/root/SoundManager"):
			SoundManager.set_pump_active(pump_was_active_before_pause and is_pump_on)

func build_pause_overlay() -> void:
	pause_overlay = Control.new()
	pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	pause_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_overlay.hide()
	$CanvasLayer.add_child(pause_overlay)

	var shade: ColorRect = ColorRect.new()
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shade.color = Color(0.01, 0.02, 0.035, 0.88)
	shade.mouse_filter = Control.MOUSE_FILTER_STOP
	pause_overlay.add_child(shade)

	var panel: Panel = Panel.new()
	panel.size = Vector2(500, 420)
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.position -= panel.size / 2.0
	panel.add_theme_stylebox_override("panel", ui_style(Color("101e2c"), Color("416176"), 14))
	pause_overlay.add_child(panel)

	var kicker: Label = pause_label(panel, "SISTEMA DE DOCA", Rect2(34, 28, 430, 25), 13, Color("65d7d2"))
	kicker.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var title: Label = pause_label(panel, "OPERAÇÃO PAUSADA", Rect2(34, 60, 430, 42), 28, Color("eef4f6"))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var info: Label = pause_label(panel, "", Rect2(48, 122, 404, 98), 15, Color("a9bbc7"))
	info.name = "Info"
	info.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	info.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var resume: Button = pause_button(panel, "CONTINUAR TURNO", Rect2(60, 246, 380, 48), true)
	resume.pressed.connect(toggle_pause)
	var upgrades: Button = pause_button(panel, "Oficina de upgrades", Rect2(60, 304, 185, 44))
	upgrades.pressed.connect(_pause_to_upgrades)
	var menu: Button = pause_button(panel, "Menu principal", Rect2(255, 304, 185, 44))
	menu.pressed.connect(_pause_to_menu)
	var hint: Label = pause_label(panel, "ESC também continua a operação", Rect2(60, 366, 380, 24), 12, Color("738b9c"))
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func pause_label(parent: Node, text_value: String, rect: Rect2, font_size: int, color: Color) -> Label:
	var label: Label = Label.new()
	label.text = text_value
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func pause_button(parent: Node, title: String, rect: Rect2, primary: bool = false) -> Button:
	var button: Button = Button.new()
	button.text = title
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", 17)
	var bg: Color = Color("1b4f56") if primary else Color("183245")
	var border: Color = Color("67d9d4") if primary else Color("35556a")
	button.add_theme_stylebox_override("normal", ui_style(bg, border, 8))
	button.add_theme_stylebox_override("hover", ui_style(Color("27656b") if primary else Color("23526a"), Color("8ce6e2"), 8))
	button.add_theme_stylebox_override("pressed", ui_style(Color("133a42"), Color("58b9bd"), 8))
	button.add_theme_stylebox_override("focus", ui_style(Color(0, 0, 0, 0), Color("c5ffff"), 8))
	parent.add_child(button)
	return button

func update_pause_text() -> void:
	if not is_instance_valid(pause_overlay):
		return
	var info: Node = pause_overlay.get_node_or_null("Panel/Info")
	if info == null:
		# O Panel é criado diretamente como filho depois do ColorRect.
		for child in pause_overlay.get_children():
			if child is Panel:
				info = child.get_node_or_null("Info")
				break
	if info != null:
		info.text = "%s\nCréditos: %d  •  Reputação: %d%%\nSequência atual: %d  •  Sucessos no turno: %d" % [GameManager.get_rank_name(), GameManager.credits, int(GameManager.reputation * 100.0), streak, successes]

func _pause_to_upgrades() -> void:
	if has_node("/root/SoundManager"):
		SoundManager.set_pump_active(false)
	GameManager.save_game()
	get_tree().change_scene_to_file("res://UpgradeMenu.tscn")

func _pause_to_menu() -> void:
	if has_node("/root/SoundManager"):
		SoundManager.set_pump_active(false)
	GameManager.save_game()
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _draw() -> void:
	super._draw()
	for index in range(7):
		var brightness: float = 0.35 + 0.25 * sin(animation_time * 3.0 - float(index))
		draw_rect(Rect2(410 + index * 65, 440, 22, 4), Color(0.2, 0.85, 0.85, brightness))
	draw_colored_polygon(PackedVector2Array([Vector2(420, 405), Vector2(835, 405), Vector2(880, 465), Vector2(390, 465)]), Color(0.08, 0.16, 0.23, 0.8))
	draw_polyline(PackedVector2Array([Vector2(440, 411), Vector2(819, 411), Vector2(849, 455)]), Color(0.24, 0.46, 0.52, 0.6), 2.0, true)
	for i in range(8):
		draw_line(Vector2(420 + i * 54, 449), Vector2(430 + i * 54, 439), Color(0.73, 0.55, 0.27, 0.65), 3.0, true)
	if is_pump_on:
		var connector: PackedVector2Array = PackedVector2Array([Vector2(637, 465), Vector2(656, 424), Vector2(657, 376), ship_pos + Vector2(0, 22)])
		draw_polyline(connector, Color("162333"), 12.0, true)
		draw_polyline(connector, Color(fuel_color, 0.65), 5.0, true)
		var scan_y: float = 242.0 + fmod(animation_time * 46.0, 145.0)
		draw_line(Vector2(505, scan_y), Vector2(769, scan_y), Color(0.3, 0.9, 0.85, 0.1), 2.0, true)

func draw_spaceship(_pos: Vector2) -> void:
	pass

func ui_style(background: Color, border: Color, radius: int = 10) -> StyleBoxFlat:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.2)
	style.shadow_size = 5
	return style

func apply_presentation() -> void:
	for panel in [hud_panel, valve_panel, $CanvasLayer/AriaPanel]:
		panel.add_theme_stylebox_override("panel", ui_style(Color("101f31"), Color("2a465c")))
	$CanvasLayer/TopHUD.add_theme_stylebox_override("panel", ui_style(Color("101d2c"), Color("294151"), 0))
	for button in [pump_btn, $CanvasLayer/TopHUD/MenuButton]:
		button.add_theme_stylebox_override("normal", ui_style(Color("19484f"), Color("367781"), 7))
		button.add_theme_stylebox_override("hover", ui_style(Color("24636a"), Color("7bd4d8"), 7))
		button.add_theme_stylebox_override("pressed", ui_style(Color("102e35"), Color("59a5ae"), 7))
		button.add_theme_stylebox_override("focus", ui_style(Color(0, 0, 0, 0), Color("bcffff"), 7))
	tank_progress.add_theme_stylebox_override("background", ui_style(Color("091321"), Color("294355"), 6))
	tank_progress.add_theme_stylebox_override("fill", ui_style(Color("36b8ad"), Color("71e0cc"), 6))
	$CanvasLayer/HUDPanel/Title.text = "01 / MANIFESTO DE CARGA"
	$CanvasLayer/ValvePanel/Title.text = "02 / MISTURADOR QUÍMICO"
	$CanvasLayer/TopHUD/MenuButton.text = "Pausar / Menu"
	status_label.add_theme_font_size_override("font_size", 22)
	status_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	status_label.position = Vector2(350, 338)
	status_label.size = Vector2(580, 142)
	extension_hud.add_theme_font_size_override("font_size", 16)
