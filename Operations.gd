extends "res://TrialDock.gd"

const FIRST_ROSTER := ["cargo", "medical", "outbound", "drill", "scout", "return"]
const ROSTERS := [
	["outbound", "cargo", "medical", "drill", "scout", "return"],
	["drill", "outbound", "scout", "cargo", "medical", "return"],
	["cargo", "medical", "drill", "outbound", "scout", "return"]
]
const STOCK := 260.0
const RADIO_WINDOW := 5.0
var duty := ""
var radio_panel: Panel
var bulletin: Label
var decision_button: Button
var ops: Dictionary:
	get: return GameManager.operations

func _ready() -> void:
	GameManager.select_profile(true)
	super._ready()
	radio_panel = Panel.new()
	radio_panel.position = Vector2(30, 502)
	radio_panel.size = Vector2(1220, 70)
	radio_panel.add_theme_stylebox_override("panel", ui_style(Color("132638"), Color("416c77"), 8))
	$CanvasLayer.add_child(radio_panel)
	bulletin = pause_label(radio_panel, "", Rect2(16, 4, 811, 61), 17, Color("e2eeed"))
	bulletin.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	decision_button = pause_button(radio_panel, "", Rect2(835, 11, 367, 46), true)
	decision_button.focus_mode = Control.FOCUS_NONE
	decision_button.pressed.connect(take_decision)
	$CanvasLayer.move_child(bench, -1)
	$CanvasLayer.move_child(pause_overlay, -1)
	flight_label.position = Vector2(400, 473)
	flight_label.size = Vector2(480, 27)
	flight_label.clip_text = true
	$CanvasLayer/DockTitle.text = "MARS STATION   /   OPERAÇÕES"
	update_radio()

func prepare_operation() -> void:
	if not ops.has("roster"):
		ops.roster = FIRST_ROSTER.duplicate() if GameManager.shift_number == 1 else ROSTERS.pick_random().duplicate()
		ops.remaining = STOCK
		ops.window = -1.0
		ops.last = ""
	duty = ops.roster[GameManager.shift_served]
	supply_limit = float(ops.remaining) if duty == "scout" else INF
	incident = ""
	max_time = 55.0
	role = "Cargueiro"
	match duty:
		"cargo":
			ship_name = "TITÃ / Suprimentos"
			target_volume = 350.0
		"medical":
			if ops.get("admitted", false):
				role = "Resgate"
				ship_name = "MED-08 / Hospital orbital"
				target_volume = 80.0
				max_time = 30.0
			else:
				ship_name = "Pátio / Reposição"
				target_volume = 180.0
		"drill":
			ship_name = "BROCA / Comboio"
			target_volume = 150.0 if ops.get("ore", false) else 100.0
		"scout":
			ship_name = "VIGIA / Comboio"
			target_volume = maxf(1.0, floorf(ops.remaining))
			if ops.get("gate", "") == "open":
				incident = "Filtro com poeira"
		"outbound":
			role = "Pesquisa"
			ship_name = "ÍRIS-7 / Ida"
			target_volume = 220.0 if ops.get("deep", false) else 120.0
			max_time = 38.0 if ops.get("deep", false) else 55.0
		"return":
			if ops.get("launched", false):
				role = "Pesquisa"
				ship_name = "ÍRIS-7 / Retorno"
				target_volume = 90.0 if ops.get("deep", false) else 120.0
				max_time = 26.0 if ops.get("deep", false) else 45.0
			else:
				ship_name = "Pátio / Transporte local"
				target_volume = 150.0
	ratio_tolerance = 1.0 if role == "Pesquisa" else 2.0

func service_is_cargo() -> bool:
	return role == "Cargueiro"

func docked() -> bool:
	return current_state in [ShipState.WAITING, ShipState.REFUELING]

func _process(delta: float) -> void:
	if gameplay_paused or report_open or bench.visible:
		return
	if duty == "scout" and current_state == ShipState.APPROACHING:
		var gate: String = ops.get("gate", "")
		if gate in ["", "closed"]:
			ops.gate_clock = float(ops.get("gate_clock", 0.0)) + delta
			weather.advance(delta, ops.gate_clock, true, false)
			if gate == "" and ops.gate_clock >= 6.0:
				open_gate()
			elif gate == "closed" and ops.gate_clock >= 8.0:
				ops.gate = "clear"
				remember_service()
			aria_talk("Radar aponta uma frente de poeira. Confira o aviso antes de autorizar o pouso da Vigia.")
			ship_visual.position = ship_pos
			$CanvasLayer/TimerLabel.text = "Nave aguardando em órbita"
			save_clock += delta
			if save_clock >= 1.0:
				remember_service()
				save_clock = 0.0
			queue_redraw()
			update_radio()
			return
	if duty == "cargo" and docked():
		if ops.window < 0.0 and current_volume >= 110.0:
			ops.window = RADIO_WINDOW
			SoundManager.play_click()
		elif ops.window > 0.0:
			ops.window = maxf(0.0, ops.window - delta)
	super._process(delta)
	update_radio()

func open_gate() -> void:
	ops.gate = "open"
	incident = "Filtro com poeira"
	dust_zones = 7
	weather_age = maxf(2.0, float(ops.get("gate_clock", 0.0)))
	remember_service()

func can_release() -> bool:
	return docked() and ops.window > 0 and current_volume >= 110.0 and absf(slider_a_val - ratio_a * 100.0 / (ratio_a + ratio_b)) <= ratio_tolerance

func take_decision() -> void:
	if gameplay_paused or report_open or bench.visible:
		return
	match duty:
		"cargo":
			if not can_release():
				return
			var pay := floori(minf(current_volume, target_volume) * 1.1)
			is_pump_on = false
			SoundManager.set_pump_active(false)
			ops.admitted = true
			ops.last = "Pouso médico reservado. Carga parcial entregue por %d CR." % pay
			GameManager.credits += pay
			streak += 1
			successes += 1
			GameManager.register_success(streak, pay, "Parcial", true)
			result_notes = ops.last
			status_label.text = "DOCA LIBERADA   +%d CR" % pay
			status_label.add_theme_color_override("font_color", Color("86edd1"))
			result_hold = 3.2
			ship_depart()
			refresh_rank()
		"scout":
			if current_state != ShipState.APPROACHING:
				return
			if ops.get("gate", "") == "":
				ops.gate = "closed"
				ops.gate_clock = 0.0
			elif ops.gate == "closed":
				open_gate()
			else:
				return
		"drill", "outbound":
			if current_volume > 0.0 or is_pump_on or current_state == ShipState.DEPARTING:
				return
			if duty == "drill":
				ops.ore = not ops.get("ore", false)
			else:
				ops.deep = not ops.get("deep", false)
			prepare_operation()
			time_left = maxf(0.1, max_time - service_clock)
			tank_progress.max_value = target_volume
			update_ship_hud()
		_:
			return
	SoundManager.play_click()
	remember_service()
	update_radio()

func operation_result(approved: bool) -> int:
	var bonus := 0
	match duty:
		"cargo":
			ops.admitted = approved and ops.window > 0.0
			ops.last = "O resgate recebeu autorização para pousar." if ops.admitted else "O resgate desviou para outra estação."
		"medical":
			if ops.get("admitted", false):
				ops.saved_crew = approved
				ops.last = "Equipe a caminho do hospital." if approved else "Resgate transferido para a estação vizinha."
				bonus = 180 if approved else 0
			else:
				ops.last = "Atendimento local encerrado."
		"drill":
			ops.remaining = maxf(0.0, STOCK - current_volume)
			bonus = 120 if approved and ops.get("ore", false) else 0
			ops.last = "Restam %.1f UF para a Vigia." % ops.remaining
		"scout":
			var mapped: bool = approved and current_volume >= 145.0
			ops.mapped = mapped
			if mapped:
				GameManager.reputation = minf(1.0, GameManager.reputation + 0.04)
			bonus = 90 if approved and ops.get("gate", "") == "open" else 0
			ops.last = "Patrulha mapeou a cratera (+4% reputação)." if mapped else "Patrulha curta concluída." if approved else "Patrulha cancelada."
		"outbound":
			ops.launched = approved
			ops.last = "Íris-7 vai retornar com amostras." if approved else "Expedição cancelada. A vaga de retorno foi liberada."
		"return":
			if ops.get("launched", false):
				ops.delivered = approved
				bonus = (300 if ops.get("deep", false) else 100) if approved else 0
				ops.last = "Amostras entregues ao laboratório." if approved else "A janela de entrega das amostras fechou."
			else:
				ops.last = "Transporte local encerrado."
	if bonus > 0:
		ops.last += " Bônus +%d CR." % bonus
	return bonus

func operations_summary() -> String:
	var rescue := "atendido" if ops.get("saved_crew", false) else "transferido"
	var convoy := "patrulha longa" if ops.get("mapped", false) else "sem mapa da cratera"
	var science := "amostras entregues" if ops.get("delivered", false) else "sem amostras"
	return "Resgate %s   •   Comboio: %s\nFiltro %s   •   Íris-7: %s" % [rescue, convoy, "protegido" if ops.get("gate", "") == "clear" else "exposto", science]

func update_radio() -> void:
	if not is_instance_valid(radio_panel):
		return
	radio_panel.visible = not report_open
	if report_open:
		return
	var message := ""
	var choice := ""
	if current_state == ShipState.DEPARTING:
		message = ops.last
	else:
		match duty:
			"cargo":
				message = "CARGUEIRO  •  Contrato de 350 UF. A partir de 110 UF ele já consegue partir com a mistura correta."
				if ops.window > 0:
					message = "SOS MÉDICO  •  Janela de %.1f s. Libere a carga por %d CR ou tente completar as 350 UF antes do desvio." % [ops.window, floori(current_volume * 1.1)]
					choice = "Autorizar partida parcial   [R]"
				elif ops.window == 0:
					message = "O resgate desviou para outra estação. Conclua o contrato do cargueiro."
			"medical":
				message = "MED-08  •  A equipe pede 80 UF para chegar ao hospital. Bônus de resgate +180 CR." if ops.get("admitted", false) else "PÁTIO  •  Com o resgate em outra rota, entrou uma reposição local de 180 UF."
			"drill":
				message = "COMBOIO  •  260 UF para duas naves. Broca com 150 UF rende +120 CR. Vigia com 145 UF ou mais rende +4% de reputação."
				if current_volume == 0 and not is_pump_on:
					choice = "Broca %d → %d UF   [R]" % [target_volume, 100 if ops.get("ore", false) else 150]
			"scout":
				var gate: String = ops.get("gate", "")
				if gate == "":
					message = "RADAR  •  Poeira em %.1f s. Manter aberta libera o pouso na rajada e +90 CR por entrega, mas o filtro vai entupir." % maxf(0.0, 6.0 - float(ops.get("gate_clock", 0.0)))
					choice = "Fechar comportas   [R]"
				elif gate == "closed":
					message = "COMPORTAS FECHADAS  •  Vigia aguarda em órbita. Filtro protegido. Frente passa em %.1f s." % maxf(0.0, 8.0 - ops.gate_clock)
					choice = "Reabrir durante a rajada   [R]"
				else:
					message = "VIGIA  •  A reserva deixada pela Broca permite %.0f UF. " % target_volume
					message += "Pouso na poeira • filtro para limpar à direita." if gate == "open" and not repaired else "Doca liberada para abastecer."
			"outbound":
				message = "ÍRIS-7  •  Cratera próxima: 120 UF e retorno +100 CR. Polo: 220 UF, retorno com menos tempo e +300 CR. Finalize em vazão fina."
				if current_volume == 0 and not is_pump_on:
					choice = ("Polo → Cratera   [R]" if ops.get("deep", false) else "Cratera → Polo   [R]")
			"return":
				message = "ÍRIS-7 VOLTOU  •  Amostras do polo. Entregue 90 UF em 26 s e finalize em vazão fina." if ops.get("deep", false) else "ÍRIS-7 VOLTOU  •  Amostras da cratera. Entregue 120 UF em 45 s e finalize em vazão fina."
				if not ops.get("launched", false):
					message = "PÁTIO  •  A expedição foi cancelada na ida. Um transporte local ocupa a vaga da Íris-7."
	bulletin.text = message
	bulletin.size.x = 811 if choice != "" else 1184
	decision_button.text = choice
	decision_button.visible = choice != ""
	decision_button.disabled = duty == "cargo" and not can_release()
	if docked():
		flight_label.text = "Tanque   %.1f / %.0f UF%s" % [current_volume, target_volume, "   •   Finalize em vazão fina" if requires_fine_finish else ""]

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_R:
		take_decision()
		get_viewport().set_input_as_handled()
		return
	super._unhandled_input(event)

func _draw() -> void:
	super._draw()
	if duty == "scout" and ops.get("gate", "") == "closed" and current_state == ShipState.APPROACHING:
		var shut := smoothstep(0.0, 0.7, float(ops.get("gate_clock", 0.0)))
		for i in range(9):
			var size_x := 245.0 * shut
			for start_x in [395.0, 885.0 - size_x]:
				draw_rect(Rect2(start_x, 208 + i * 19, size_x, 18), Color("2e4753"))
				draw_line(Vector2(start_x, 209 + i * 19), Vector2(start_x + size_x, 209 + i * 19), Color("5c7780"))

