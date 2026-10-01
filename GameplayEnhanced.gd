extends "res://Gameplay.gd"

# Camada adicional: mantém o script e os parâmetros originais intactos.
var arrivals: int = 0
var streak: int = 0
var successes: int = 0
var special_contract: bool = false
var extension_hud: Label
var flight_label: Label
var milestone: int = 0
var animation_time: float = 0.0
var ship_visual

func _ready():
	extension_hud = Label.new()
	extension_hud.position = Vector2(410, 110)
	extension_hud.size = Vector2(460, 90)
	extension_hud.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	extension_hud.add_theme_font_size_override("font_size", 18)
	extension_hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer.add_child(extension_hud)
	flight_label = Label.new()
	flight_label.position = Vector2(400, 490)
	flight_label.size = Vector2(480, 75)
	flight_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	flight_label.add_theme_font_size_override("font_size", 17)
	flight_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer.add_child(flight_label)
	super._ready()
	ship_visual = preload("res://ShipVisual.gd").new()
	add_child(ship_visual)
	apply_presentation()

func spawn_new_ship():
	super.spawn_new_ship()
	arrivals += 1
	milestone = 0
	# Contratos especiais só aparecem após três atendimentos bem-sucedidos.
	special_contract = successes >= 3 and arrivals % 3 == 0
	if special_contract:
		var advanced_ratios = [Vector2i(5, 2), Vector2i(2, 5), Vector2i(5, 3), Vector2i(3, 5)]
		var selected: Vector2i = advanced_ratios[randi() % advanced_ratios.size()]
		ratio_a = selected.x
		ratio_b = selected.y
		ship_name += " / ELITE"
		update_ship_hud()
	refresh_extension_hud()

func refresh_extension_hud():
	if not is_instance_valid(extension_hud):
		return
	var contract_name: String = "CONTRATO REGULAR"
	if special_contract:
		contract_name = "CONTRATO ELITE | BÔNUS +150"
	extension_hud.text = "%s\nAtendimento %d | Sequência: %d\nConcluídos: %d" % [contract_name, arrivals, streak, successes]
	extension_hud.modulate = Color(1.0, 0.78, 0.35) if special_contract else Color(0.5, 0.88, 0.9)

func _process(delta):
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
		# As chamas detalhadas substituem as partículas desalinhadas antigas.
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

func validate_refuel():
	# Usa exatamente os critérios originais de sucesso.
	var target_pct: float = float(ratio_a) / float(ratio_a + ratio_b) * 100.0
	var successful: bool = abs(slider_a_val - target_pct) <= 2.0 and abs(current_volume - target_volume) <= target_volume * 0.03
	super.validate_refuel()
	if successful:
		streak += 1
		successes += 1
		var bonus: int = mini(streak - 1, 5) * 25
		if special_contract:
			bonus += 150
		if bonus > 0:
			GameManager.credits += bonus
			status_label.text += "\nBônus de contrato/sequência: +%d" % bonus
			update_hud_counters()
	else:
		streak = 0
	refresh_extension_hud()

func ship_failed(reason: String):
	streak = 0
	super.ship_failed(reason)
	refresh_extension_hud()

func _draw():
	super._draw()
	# Sinalização animada da pista sem novos assets ou configurações.
	for index in range(7):
		var brightness: float = 0.35 + 0.25 * sin(animation_time * 3.0 - float(index))
		draw_rect(Rect2(410 + index * 65, 440, 22, 4), Color(0.2, 0.85, 0.85, brightness))
	# Plataforma com perspectiva e marcação de acoplamento.
	draw_colored_polygon(PackedVector2Array([Vector2(420, 405), Vector2(835, 405), Vector2(880, 465), Vector2(390, 465)]), Color(0.08, 0.16, 0.23, 0.8))
	draw_polyline(PackedVector2Array([Vector2(440, 411), Vector2(819, 411), Vector2(849, 455)]), Color(0.24, 0.46, 0.52, 0.6), 2.0, true)
	for i in range(8):
		draw_line(Vector2(420 + i * 54, 449), Vector2(430 + i * 54, 439), Color(0.73, 0.55, 0.27, 0.65), 3.0, true)
	# Conexão flexível segue o movimento da nave durante o abastecimento.
	if is_pump_on:
		var connector := PackedVector2Array([Vector2(637, 465), Vector2(656, 424), Vector2(657, 376), ship_pos + Vector2(0, 22)])
		draw_polyline(connector, Color("162333"), 12.0, true)
		draw_polyline(connector, Color(fuel_color, 0.65), 5.0, true)
		var scan_y: float = 242.0 + fmod(animation_time * 46.0, 145.0)
		draw_line(Vector2(505, scan_y), Vector2(769, scan_y), Color(0.3, 0.9, 0.85, 0.1), 2.0, true)

func draw_spaceship(_pos: Vector2):
	# ShipVisual desenha a nave detalhada no lugar da silhueta original.
	pass

func ui_style(background: Color, border: Color, radius: int = 10) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	style.set_corner_radius_all(radius)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.2)
	style.shadow_size = 5
	return style

func apply_presentation():
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
	status_label.add_theme_font_size_override("font_size", 25)
	# Resultado ocupa a faixa inferior e deixa a nave visível.
	status_label.set_anchors_preset(Control.PRESET_TOP_LEFT)
	status_label.position = Vector2(380, 350)
	status_label.size = Vector2(520, 125)
	extension_hud.add_theme_font_size_override("font_size", 16)
	var dock_title := Label.new()
	dock_title.text = "MARS STATION   /   DOCA 01"
	dock_title.position = Vector2(450, 70)
	dock_title.size = Vector2(380, 25)
	dock_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dock_title.add_theme_font_size_override("font_size", 15)
	dock_title.modulate = Color("7797ac")
	dock_title.mouse_filter = Control.MOUSE_FILTER_IGNORE
	$CanvasLayer.add_child(dock_title)
