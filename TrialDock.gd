extends "res://GameplayEnhanced.gd"

const COUPLING := Vector2(348, 456)
const FILTER := Vector2(865, 456)
const CLASSES := ["Cargueiro", "Resgate", "Pesquisa"]
const Assembly = preload("res://FilterAssembly.gd")
var filter_art := Assembly.new()
var weather := preload("res://DockWeather.gd").new()
var bench := preload("res://FilterBench.gd").new()
var dust_zones := 0
var collar := 0
var weather_age := 0.0
var bench_clock := 0.0
var purge := 0.0
var purge_x := 0.0

const GUST_DURATION := 6.0
const DOOR_CLOSE_TIME := 1.8
const DOOR_OPEN_TIME := 1.6
var gate := ""
var gate_age := 0.0
var radar: Panel
var radar_title: Label
var radar_note: Label
var close_gate: Button
var allow_landing: Button
var repeat_alert: Button

var role := ""
var incident := ""
enum Hose { STOWED, HELD, LATCHED, RETURNING }
var hose_state := Hose.STOWED
var connected_hose: bool:
	get: return hose_state == Hose.LATCHED
var hose := preload("res://DockHose.gd").new()
var pump_bounds: Rect2
var return_from := Vector2.ZERO
var return_angle := 0.0
var reel_progress := 0.0
var repaired := false
var report_open := false
var save_clock := 0.0
var result_hold := 0.0
var result_notes := ""
var action_hint: Label
var flow_button: Button
var filter_bounds: Rect2
const HATCH := Vector2(727, 447)
var service := preload("res://ServicePanel.gd").new()
var job := ""
var spec := 8
var level := 0
var ring := 0
var serviced := false

func service_pending() -> bool:
	return job != "" and not serviced

func open_service() -> void:
	service.present(job, spec, level, ring)
	$Player.process_mode = Node.PROCESS_MODE_DISABLED
	SoundManager.play_click()

func record_adjustment() -> void:
	level = service.amount
	ring = service.ring
	remember_service()

func close_service() -> void:
	service.hide()
	$Player.process_mode = Node.PROCESS_MODE_INHERIT
	refresh_instruments()

func complete_service() -> void:
	serviced = true
	close_service()
	$Player.play_anim("interact")
	SoundManager.play_success()
	aria_talk("Escotilha travada. O circuito está liberado para abastecer.")
	remember_service()

func _ready() -> void:
	filter_bounds = machine_bounds($FilterBody)
	pump_bounds = machine_bounds($PumpBody)
	super._ready()
	add_child(hose)
	hose.pump.position = COUPLING
	ship_visual.position = ship_pos
	refresh_hose(0.0)
	add_child(weather)
	add_child(filter_art)
	filter_art.position = FILTER + Vector2(0,-24)
	filter_art.z_index = 2
	$CanvasLayer.add_child(service)
	service.closed.connect(close_service)
	service.finished.connect(complete_service)
	service.changed.connect(record_adjustment)
	$CanvasLayer.add_child(bench)
	bench.command.connect(maintain)
	action_hint = pause_label($CanvasLayer, "", Rect2(35, 350, 350, 62), 15, Color("9ce6d8"))
	action_hint.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	flow_button = pause_button($CanvasLayer, "", Rect2(902, 356, 347, 38))
	flow_button.pressed.connect(toggle_flow)
	for control in [pump_btn, slider_a, flow_button]:
		control.focus_mode = Control.FOCUS_NONE
	build_radar()
	$CanvasLayer.move_child(service, -1)
	$CanvasLayer.move_child(bench, -1)
	$CanvasLayer.move_child(pause_overlay, -1)
	shortcut_label.text = "Setas   andar     F   interagir     V   vazão     Esc   pausa"
	$CanvasLayer/DockTitle.text = "MARS STATION   /   DOCA EXPERIMENTAL"
	if GameManager.shift_served >= GameManager.SHIFT_SIZE:
		show_report()
	else:
		refresh_instruments()
		update_radar()

func spawn_new_ship() -> void:
	if GameManager.shift_served >= GameManager.SHIFT_SIZE:
		if is_instance_valid(action_hint):
			show_report()
		return
	arrivals = GameManager.shift_served
	successes = GameManager.shift_success
	streak = GameManager.shift_streak
	training = not GameManager.tutorial_done
	super.spawn_new_ship()
	hose_state = Hose.STOWED
	$Player.carrying_nozzle = false
	repaired = false
	fine_flow = false
	save_clock = 0.0
	service_clock = 0.0
	result_hold = 0.0
	result_notes = ""
	role = CLASSES[(GameManager.shift_served + GameManager.shift_number - 1) % CLASSES.size()]
	ratio_tolerance = 1.0 if role == "Pesquisa" else 2.0
	incident = ""
	match role:
		"Cargueiro":
			target_volume = 350.0
		"Resgate":
			target_volume = 150.0
			max_time = 30.0
		"Pesquisa":
			target_volume = 200.0
	if arrivals == 2:
		incident = "Filtro com poeira"
	elif arrivals == 5:
		incident = "Pressão oscilante"
	elif arrivals == 4:
		incident = "Entrega urgente"
		max_time = minf(max_time, 28.0)
	if training:
		role = "Treinamento"
		ship_name = "ARIA-01"
		ship_origin = "Marte"
		ratio_a = 3
		ratio_b = 1
		target_volume = 100.0
		ratio_tolerance = 2.0
		incident = ""
		special_contract = false
	requires_fine_finish = role == "Pesquisa"
	time_left = max_time
	dust_zones = 7 if incident == "Filtro com poeira" else 0
	collar = -2 if incident == "Pressão oscilante" else 0
	weather_age = 0.0
	gate = "forecast" if incident == "Filtro com poeira" else ""
	gate_age = 0.0
	if gate == "forecast":
		dust_zones = 0
	purge = 0.0
	job = ""
	serviced = false
	level = 0
	ring = 0
	var preview: String = GameManager.service_preview
	var slot := 3 if GameManager.shift_number % 2 == 1 else 6
	if not training and not GameManager.weather_demo and arrivals == slot:
		job = "oil" if GameManager.shift_number % 2 == 1 else "seal"
	if preview != "" and arrivals == 3:
		job = preview
	if job == "oil":
		spec = randi_range(6, 11)
		level = randi_range(1, 4)
	elif job == "seal":
		spec = [8, 10, 12].pick_random()
		ring = (service.RINGS.find(spec * 2) + 1) % service.RINGS.size()
	if not GameManager.active_service.is_empty():
		restore_service(GameManager.active_service)
	elif preview != "":
		$Player.position = HATCH
	elif GameManager.weather_demo:
		$Player.position = Vector2(filter_bounds.position.x - 19.0, FILTER.y)
	if current_state in [ShipState.WAITING,ShipState.REFUELING] and not training:
		aria_talk(contract_note())
	tank_progress.max_value = target_volume
	tank_progress.value = current_volume
	pump_btn.text = "Parar bomba" if is_pump_on else "Ativar bomba"
	update_ship_hud()
	refresh_extension_hud()
	if gate == "forecast":
		SoundManager.queue_sfx("alarm", 420.0, 0.35)
	update_radar()
	remember_service()

func refresh_extension_hud() -> void:
	if not is_instance_valid(extension_hud):
		return
	if training:
		extension_hud.text = "SIMULADOR DA ARIA\nTreino de abastecimento • 100 UF\nPratique antes do primeiro turno"
	else:
		var badge := "  •  ELITE" if special_contract else ""
		extension_hud.text = "TURNO %d   ·   NAVE %d/%d   ·   %s%s\nMeta  %d/%d aprovadas    |    Missão  %d/%d %s" % [GameManager.shift_number, arrivals, GameManager.SHIFT_SIZE, role.to_upper(), badge, GameManager.shift_success, GameManager.goal(), GameManager.mission_count, GameManager.mission_goal(), GameManager.mission_label()]
	extension_hud.modulate = Color("ffd089") if special_contract else Color("85dcd3")

func _process(delta: float) -> void:
	if gameplay_paused or report_open:
		return
	if gate in ["forecast", "closed"]:
		advance_front(delta)
		return
	if gate in ["exposed", "protected"] and gate_age < 4.0:
		gate_age += delta
		if gate_age >= 4.0:
			update_radar()
	weather.shutter = 1.0 - smoothstep(0.0, DOOR_OPEN_TIME, gate_age) if gate == "protected" else 0.0
	weather_age += delta
	bench_clock += delta
	purge = maxf(0.0,purge-delta*1.6)
	weather.advance(delta,weather_age,incident == "Filtro com poeira",false)
	sync_filter()
	if bench.visible or service.visible:
		return
	refresh_hose(delta)
	if current_state == ShipState.DEPARTING and result_hold > 0.0:
		result_hold -= delta
		return
	var previous = current_state
	flow_factor = 0.45 if fine_flow or training else 1.0
	if not repaired:
		if incident == "Filtro com poeira":
			var blocked := zone_deposits()
			flow_factor *= 1.0-0.15*(blocked.x+blocked.y+blocked.z)
		elif incident == "Pressão oscilante":
			flow_factor *= 1.0 + 0.5 * sin(service_clock * 2.0)
	super._process(delta)
	if report_open:
		return
	ship_visual.ship_class = role
	ship_visual.service_light = service_pending() and current_state == ShipState.WAITING
	if current_state == ShipState.WAITING or current_state == ShipState.REFUELING:
		if training:
			$CanvasLayer/TimerLabel.text = "Simulação • tempo livre"
			tutorial_prompt()
		elif previous == ShipState.APPROACHING:
			aria_talk(contract_note())
	if requires_fine_finish and current_state in [ShipState.WAITING, ShipState.REFUELING]:
		flight_label.text = "Pesquisa  ·  Finalize em vazão fina [V]\nTanque  %.1f / %.1f UF" % [current_volume, target_volume]
	if current_state == ShipState.DEPARTING:
		aria_talk(result_notes)
	refresh_instruments()
	save_clock += delta
	if save_clock >= 1.0:
		remember_service()
		save_clock = 0.0

func contract_note() -> String:
	var notes := {"Cargueiro": "Carga pesada. Use vazão rápida no início e fina na chegada.", "Resgate": "Equipe médica a bordo. Você tem 30 segundos ou menos.", "Pesquisa": "Amostra científica. Tolerância de 1 ponto percentual. Finalize em vazão fina (V)."}
	var message: String = notes.get(role, "")
	if service_pending():
		return "A luz âmbar indica manutenção. Vá até a escotilha sob o lado direito da nave e pressione F."
	if incident == "Entrega urgente":
		message += " A janela de partida fecha em 28 segundos."
	elif incident != "" and not repaired:
		message += " " + incident + ". Use F ao lado do filtro à direita para abrir a tampa."
	return message

func tutorial_prompt() -> void:
	var message: String
	if hose_state == Hose.STOWED:
		message = "1/4  Pegue o bico no suporte da bomba à esquerda. Aproxime-se com as setas e pressione F."
	elif hose_state == Hose.HELD:
		message = "2/4  Contorne a bomba pela frente (↓). Leve o bico até a entrada âmbar sob a nave e pressione F para travar."
	elif absf(slider_a_val - 75.0) > ratio_tolerance:
		message = "3/4  Leia o manifesto. São 3 partes de A em 4 partes no total. Ajuste A para 75% com o mouse ou Q/E."
	elif not is_pump_on:
		message = "4/4  Mistura pronta! Ligue a bomba com Espaço ou pelo botão. Observe o tanque e pare perto de 100 UF."
	else:
		message = "Acompanhe o tanque até 100 UF. Você pode parar e continuar." if current_volume < 97.0 else "Tanque cheio! Pressione Espaço ou Parar bomba para concluir o treino."
	aria_talk(message)

func refresh_instruments() -> void:
	if not is_instance_valid(action_hint):
		return
	var at_dock: bool = current_state in [ShipState.WAITING, ShipState.REFUELING]
	pump_btn.disabled = not at_dock or not connected_hose
	if is_pump_on:
		pump_btn.text = "Parar bomba"
	elif connected_hose:
		pump_btn.text = "Ativar bomba"
	elif at_dock:
		pump_btn.text = "Aguardando encaixe"
	else:
		pump_btn.text = "Bomba em espera"
	flow_button.text = "Treino • vazão assistida" if training else ("Vazão fina   [V]" if fine_flow else "Vazão rápida   [V]")
	flow_button.disabled = training or current_state == ShipState.DEPARTING
	if current_state == ShipState.DEPARTING:
		action_hint.text = ""
	elif at_dock and service_pending():
		pump_btn.disabled = true
		pump_btn.text = "Motor em manutenção"
		action_hint.text = "ESCOTILHA   ·   " + ("Óleo do motor" if job == "oil" else "Anel de vedação") + "\nF junto à luz âmbar, à direita da nave"
	elif hose_state == Hose.HELD:
		action_hint.text = "BOCAL DA NAVE   ·   Leve a mangueira\nF ao lado da entrada para travar o bico"
	elif not connected_hose:
		action_hint.text = "BOMBA   ·   Retire a mangueira\nF junto ao bico âmbar no suporte esquerdo"
	elif incident in ["Filtro com poeira", "Pressão oscilante"] and not repaired:
		action_hint.text = incident.to_upper() + "\nFiltro à direita  →   F para inspecionar"
	else:
		action_hint.text = "Mangueira conectada  •  Circuito pronto"
		if repaired:
			action_hint.text += "\nManutenção concluída"
		elif incident == "Entrega urgente":
			action_hint.text += "\nPrioridade • entrega urgente"

func toggle_flow() -> void:
	if gate in ["forecast", "closed"]:
		return
	if gameplay_paused or bench.visible or report_open or training or current_state == ShipState.DEPARTING:
		return
	fine_flow = not fine_flow
	refresh_instruments()
	remember_service()

func interact() -> void:
	if current_state != ShipState.WAITING and current_state != ShipState.REFUELING:
		return
	if service_pending() and $Player.position.distance_to(HATCH) <= 45.0:
		open_service()
		return
	if $Player.position.distance_to($Player.position.clamp(filter_bounds.position, filter_bounds.end)) <= 28.0:
		open_filter()
		return
	var by_rack: bool = $Player.hand_position().distance_to(rack_grip()) <= 30.0
	var by_ship: bool = hose.deployed > 0.94 and $Player.hand_position().distance_to(hose.socket) <= 42.0
	if hose_state == Hose.STOWED and by_rack:
		hose_state = Hose.HELD
		aria_talk("Bico na mão. Passe pela frente da bomba e leve a mangueira ao bocal iluminado sob a nave.")
	elif hose_state == Hose.HELD and by_ship:
		hose_state = Hose.LATCHED
		aria_talk("Encaixe travado. " + contract_note() if not training else "Encaixe travado. Ajuste a mistura.")
		SoundManager.queue_sfx("click",440.0,0.06)
	elif hose_state == Hose.HELD and by_rack:
		hose_state = Hose.STOWED
		aria_talk("Bico devolvido ao suporte.")
	elif hose_state == Hose.LATCHED and by_ship:
		if is_pump_on:
			aria_talk("A trava segura o bico enquanto há fluxo.")
			return
		hose_state = Hose.HELD
		aria_talk("Bico destravado.")
	else:
		return
	$Player.carrying_nozzle = hose_state == Hose.HELD
	refresh_hose(0.0)
	$Player.play_anim("interact")
	SoundManager.play_click()
	refresh_instruments()
	remember_service()

func zone_deposits() -> Vector3:
	var dense := smoothstep(0.0,4.0,weather_age)*0.76+0.24
	return dense*Vector3(float(dust_zones & 1),float((dust_zones >> 1)&1),float((dust_zones >> 2)&1))

func sync_filter() -> void:
	var broken := incident == "Pressão oscilante" and not repaired
	var grit := zone_deposits()
	filter_art.update_view(grit,broken,collar,bench_clock,purge,purge_x)
	if bench.visible:
		bench.drawing.update_view(grit,broken,collar,bench_clock,purge,purge_x)

func open_filter() -> void:
	if gameplay_paused or report_open or bench.visible:
		return
	bench.present(incident,repaired,dust_zones,collar)
	bench.dragging = false
	bench.last_zone = -1
	bench.show()
	if get_viewport().gui_get_focus_owner():
		get_viewport().gui_release_focus()
	$Player.process_mode = Node.PROCESS_MODE_DISABLED
	SoundManager.set_pump_active(false)
	SoundManager.play_click()
	sync_filter()

func maintain(action: String, part: int) -> void:
	if not bench.visible:
		return
	if action == "preview_fault" and GameManager.weather_demo and repaired and incident == "Filtro com poeira":
		maintain("close",0)
		GameManager.shift_served = 4
		GameManager.active_service = {}
		spawn_new_ship()
		return
	if action == "close":
		bench.hide()
		$Player.process_mode = Node.PROCESS_MODE_INHERIT
		SoundManager.set_pump_active(is_pump_on)
		return
	if repaired:
		return
	if incident == "Filtro com poeira" and action == "brush" and part >= 0 and part <= 2:
		if (dust_zones & (1 << part)) == 0:
			return
		dust_zones &= ~(1 << part)
		purge = 1.0
		purge_x = Assembly.CENTRES[part]
		repaired = dust_zones == 0
	elif incident == "Pressão oscilante" and action == "turn":
		collar = clampi(collar+signi(part),-3,3)
	elif incident == "Pressão oscilante" and action == "lock" and collar == 0:
		repaired = true
	else:
		return
	if repaired:
		aria_talk("Filtro pronto. A vazão selecionada foi restabelecida.")
		SoundManager.play_success()
	else:
		SoundManager.play_click()
	sync_filter()
	bench.present(incident,repaired,dust_zones,collar)
	refresh_instruments()
	remember_service()

func _input(event: InputEvent) -> void:
	if service.visible and event is InputEventKey:
		if event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
			close_service()
			get_viewport().set_input_as_handled()
		return
	if bench.visible and event is InputEventKey:
		if event.pressed and not event.echo:
			bench.keyboard(event.keycode)
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if report_open or bench.visible or service.visible:
		return
	if not gameplay_paused and event is InputEventKey and event.pressed and not event.echo:
		if GameManager.weather_demo and event.keycode == KEY_R:
			replay_forecast()
			get_viewport().set_input_as_handled()
			return
		if gate in ["forecast", "closed"] and event.keycode != KEY_ESCAPE:
			if event.keycode in [KEY_1, KEY_2]:
				choose_gate(event.keycode == KEY_1)
			get_viewport().set_input_as_handled()
			return
		if event.keycode == KEY_F or event.keycode == KEY_V:
			if event.keycode == KEY_F:
				interact()
			else:
				toggle_flow()
			get_viewport().set_input_as_handled()
			return
	super._unhandled_input(event)

func _on_pump_pressed() -> void:
	if gameplay_paused or report_open or bench.visible or service.visible:
		return
	if service_pending():
		aria_talk(contract_note())
		return
	if not is_pump_on and not connected_hose:
		aria_talk("Trave o bico na entrada da nave com F antes de ligar a bomba." if hose_state == Hose.HELD else "Retire o bico da bomba e leve a mangueira até a nave.")
		return
	if training and not is_pump_on and absf(slider_a_val - 75.0) > ratio_tolerance:
		tutorial_prompt()
		return
	super._on_pump_pressed()
	remember_service()

func validate_refuel() -> void:
	if training:
		if absf(slider_a_val - 75.0) > ratio_tolerance or current_volume < target_volume * 0.97:
			tutorial_prompt()
			return
		GameManager.tutorial_done = true
		GameManager.active_service = {}
		GameManager.save_game()
		result_notes = "Treino concluído. Agora começa seu turno com seis contratos."
		status_label.text = "TREINAMENTO CONCLUÍDO"
		status_label.add_theme_color_override("font_color", Color("86edd1"))
		SoundManager.play_success()
		$Player.play_anim("celebrate")
		ship_depart()
	else:
		var target_a := float(ratio_a) * 100.0 / (ratio_a + ratio_b)
		var mix_error := slider_a_val - target_a
		var extra := current_volume - target_volume
		super.validate_refuel()
		var mix_note := "Mistura dentro da faixa."
		if absf(mix_error) > ratio_tolerance:
			mix_note = "%s em excesso por %.1f pontos percentuais." % [comp_a_name if mix_error > 0 else comp_b_name, absf(mix_error)]
		var volume_note := "Volume dentro da faixa."
		if absf(extra) > target_volume * 0.03:
			volume_note = ("Sobraram %.1f UF." if extra > 0 else "Faltaram %.1f UF.") % absf(extra)
		result_notes = mix_note + " " + volume_note
		if requires_fine_finish and not fine_flow:
			result_notes += " A amostra exige vazão fina no fechamento."
		update_hud_counters()
	result_hold = 3.2
	aria_talk(result_notes)

func ship_failed(reason: String) -> void:
	if current_state not in [ShipState.WAITING, ShipState.REFUELING]:
		return
	super.ship_failed(reason)
	result_notes = "%s Entregue %.1f de %.1f UF." % [reason, current_volume, target_volume]
	result_hold = 3.2
	aria_talk(result_notes)

func toggle_pause() -> void:
	if report_open or bench.visible or service.visible:
		return
	super.toggle_pause()
	if gameplay_paused:
		weather.stop_audio()
		remember_service()

func remember_service() -> void:
	if report_open or current_state == ShipState.DEPARTING or GameManager.shift_served >= GameManager.SHIFT_SIZE:
		return
	GameManager.active_service = {
		"name": ship_name, "origin": ship_origin, "a": comp_a_name, "b": comp_b_name,
		"ratio_a": ratio_a, "ratio_b": ratio_b, "target": target_volume, "max_time": max_time,
		"time": time_left, "volume": current_volume, "mix": slider_a_val, "state": current_state,
		"ship_pos": ship_pos, "player": $Player.position, "hose": connected_hose, "carrying_nozzle": hose_state == Hose.HELD,
		"job": job, "spec": spec, "level": level, "ring": ring, "serviced": serviced,
		"gate": gate, "gate_age": gate_age,
		"grit": dust_zones, "collar": collar, "weather_age": weather_age,
		"repair": repaired, "fine": fine_flow, "elite": special_contract, "elapsed": service_clock
	}
	GameManager.save_game()

func machine_bounds(body: StaticBody2D) -> Rect2:
	var shape: CollisionShape2D = body.get_node("CollisionShape2D")
	return body.transform * (shape.transform * shape.shape.get_rect())

func restore_operator(saved: Vector2) -> Vector2:
	var deck: Rect2 = $Player.DECK
	var pos := saved.clamp(deck.position, deck.end)
	var feet: CollisionShape2D = $Player/CollisionShape2D
	var sole: Rect2 = feet.transform * feet.shape.get_rect()
	# Older saves can place the operator inside the new solid equipment.
	var bounds := filter_bounds
	var occupied := Rect2(pos + sole.position, sole.size)
	if pump_bounds.intersects(occupied):
		bounds = pump_bounds
	elif not filter_bounds.intersects(occupied):
		return pos
	var left := bounds.position.x - sole.end.x - 1.0
	var right := bounds.end.x - sole.position.x + 1.0
	var front := bounds.end.y - sole.position.y + 1.0
	if front - pos.y <= minf(pos.x - left, right - pos.x):
		return Vector2(pos.x, front)
	return Vector2(left if pos.x - left < right - pos.x else right, pos.y)

func restore_service(data: Dictionary) -> void:
	# Serviços já iniciados em versões anteriores continuam como foram contratados.
	job = data.get("job", "")
	spec = data.get("spec", 8)
	level = data.get("level", 0)
	ring = data.get("ring", 0)
	serviced = data.get("serviced", false)
	ship_name = data.name
	ship_origin = data.origin
	comp_a_name = data.a
	comp_b_name = data.b
	ratio_a = data.ratio_a
	ratio_b = data.ratio_b
	target_volume = data.target
	max_time = data.max_time
	time_left = data.time
	current_volume = data.volume
	slider_a.value = data.mix
	current_state = data.state
	is_pump_on = current_state == ShipState.REFUELING
	ship_pos = data.ship_pos
	$Player.position = restore_operator(data.player)
	hose_state = Hose.LATCHED if data.hose else (Hose.HELD if data.get("carrying_nozzle",false) else Hose.STOWED)
	$Player.carrying_nozzle = hose_state == Hose.HELD
	if current_state == ShipState.WAITING or is_pump_on:
		hose.deployed = 1.0
	if gate == "forecast":
		# Earlier versions saved this service after the dust had already entered.
		gate = data.get("gate", "exposed")
		gate_age = float(data.get("gate_age", 4.0))
		if gate == "protected":
			incident = ""
	repaired = data.repair
	dust_zones = int(data.get("grit",7 if gate == "exposed" and not repaired else dust_zones)) & 7
	collar = clampi(int(data.get("collar",0 if repaired else collar)),-3,3)
	weather_age = maxf(0.0,float(data.get("weather_age", data.elapsed)))
	fine_flow = data.fine
	special_contract = data.elite
	service_clock = data.elapsed
	SoundManager.set_pump_active(is_pump_on)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST and is_node_ready():
		remember_service()

func _exit_tree() -> void:
	if is_instance_valid(pump_btn):
		remember_service()

func show_report() -> void:
	if report_open:
		return
	report_open = true
	weather.stop_audio()
	GameManager.active_service = {}
	SoundManager.set_pump_active(false)
	$Player.process_mode = Node.PROCESS_MODE_DISABLED
	for item in $CanvasLayer.get_children():
		if item is Control:
			item.hide()
	var shade := ColorRect.new()
	shade.color = Color("0b1627f3")
	$CanvasLayer.add_child(shade)
	shade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := Panel.new()
	shade.add_child(panel)
	panel.add_theme_stylebox_override("panel", ui_style(Color("122538"), Color("437180"), 16))
	panel.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	panel.size = Vector2(680, 462)
	panel.position -= panel.size / 2.0
	var mint := Color("84e4d4")
	var pale := Color("ecf2f4")
	pause_label(panel, "MARS STATION     /     RELATÓRIO DE OPERAÇÕES", Rect2(34, 24, 610, 26), 15, mint)
	pause_label(panel, "Turno %02d encerrado" % GameManager.shift_number, Rect2(34, 55, 610, 52), 34, pale)
	var goal_met: bool = GameManager.shift_success >= GameManager.goal()
	var mission_met: bool = GameManager.mission_count >= GameManager.mission_goal()
	var data := "%d de %d naves aprovadas     ·     %d notas A ou S\nContratos e bônus  %+d CR     ·     Reputação  %d%% → %d%%" % [GameManager.shift_success, GameManager.SHIFT_SIZE, GameManager.shift_precise, GameManager.shift_net, roundi(GameManager.shift_rep_start * 100), roundi(GameManager.reputation * 100)]
	pause_label(panel, data, Rect2(34, 128, 618, 72), 20, pale)
	var goal_line := "Meta atingida   +150 CR" if goal_met else "Meta pendente   %d/%d aprovações" % [GameManager.shift_success, GameManager.goal()]
	pause_label(panel, goal_line, Rect2(34, 225, 615, 32), 19, mint)
	var mission := "Missão concluída   +100 CR e insígnia da doca" if mission_met else "Missão opcional   %d/%d %s" % [GameManager.mission_count, GameManager.mission_goal(), GameManager.mission_label()]
	pause_label(panel, mission, Rect2(34, 264, 615, 30), 18, Color("ffc47f"))
	var next := pause_button(panel, "Iniciar turno %d" % (GameManager.shift_number + 1), Rect2(34, 357, 272, 54), true)
	next.pressed.connect(_next_shift)
	var menu := pause_button(panel, "Voltar ao menu", Rect2(327, 357, 315, 54))
	menu.pressed.connect(_pause_to_menu)
	next.grab_focus()

func _next_shift() -> void:
	GameManager.next_shift()
	get_tree().reload_current_scene()

func _draw() -> void:
	super._draw()
	# Juntas de dilatação, grelha e balizadores embutidos na borda do cais.
	for i in range(12):
		var x := 20 + i * 112
		draw_line(Vector2(x+14,458),Vector2(x,478), Color("#314555"),1,true)
		draw_rect(Rect2(x,478,93,4), Color("#273b47"))
		for groove in range(8):
			draw_line(Vector2(x+4+groove*11,479),Vector2(x+9+groove*11,479),Color("#101b25"),2)
		draw_rect(Rect2(x+97,478,8,2), Color("#b09e75"))
	if service_pending() and current_state == ShipState.WAITING:
		var hatch := HATCH - Vector2(0,30)
		draw_line(ship_pos+Vector2(54,16),hatch, Color("#524d40"),4,true)
		draw_rect(Rect2(hatch-Vector2(15,7),Vector2(30,15)),Color("#1c303a"))
		draw_rect(Rect2(hatch-Vector2(12,5),Vector2(24,10)),Color("#bfa276"),false,1)
		draw_circle(hatch,3,Color("#ffbc64"))
		draw_string(ThemeDB.fallback_font,hatch+Vector2(-39,24),"ESCOTILHA",HORIZONTAL_ALIGNMENT_CENTER,78,11,Color("#ffcd89"))
	if is_instance_valid(action_hint) and action_hint.visible and not action_hint.text.is_empty():
		draw_rect(Rect2(29,350,355,48),Color(0.04,0.08,0.12,0.82))
	draw_string(ThemeDB.fallback_font,FILTER+Vector2(-60,17),"FILTRO",HORIZONTAL_ALIGNMENT_CENTER,120,12,Color("f6cb91"))
	# Backplate keeps contract targets readable as the ochre storm crosses the window.
	if is_instance_valid(extension_hud) and extension_hud.visible:
		draw_rect(Rect2(389,102,501,93),Color(0.04,0.08,0.12,0.76))
	# Cada nível da bomba instala um cilindro físico ao lado do engate.
	for index in range(GameManager.upgrade_pump_speed):
		var rect := Rect2(390 + index * 18, 425, 14, 32)
		draw_rect(rect, Color("2d5268"))
		draw_rect(Rect2(rect.position + Vector2(2, 5), Vector2(10, 5)), Color("84d5c8"))
	if GameManager.upgrade_auto_valve:
		draw_circle(Vector2(640, 445), 11, Color("293e52"))
		draw_arc(Vector2(640, 445), 9, 0, TAU, 18, Color("eeb171"), 3)
	if GameManager.upgrade_helper_hud:
		draw_line(Vector2(477, 442), Vector2(477, 416), Color("65939c"), 3)
		draw_colored_polygon(PackedVector2Array([Vector2(477, 396),Vector2(491, 406),Vector2(477, 416),Vector2(463, 406)]), Color("76e9d9"))
	for i in range(mini(GameManager.shift_number - 1, 6)):
		draw_rect(Rect2(416 + i * 84, 195, 32, 3), Color("76c7be"))
	for i in range(mini(GameManager.decorations, 6)):
		var p := Vector2(480 + i * 31, 202)
		draw_colored_polygon(PackedVector2Array([p, p + Vector2(19, 0), p + Vector2(19, 27), p + Vector2(9, 20), p + Vector2(0, 27)]), Color("dc9b55"))

func rack_grip() -> Vector2:
	return COUPLING + hose.Pump.HOLSTER

func refresh_hose(delta: float) -> void:
	var docked: bool = current_state in [ShipState.WAITING,ShipState.REFUELING]
	var hull: Vector2 = ship_visual.to_global(Vector2(0,22)) if is_instance_valid(ship_visual) else ship_pos+Vector2(0,22)
	hose.arm(hull,docked,delta)
	var grip := rack_grip()
	var angle := -1.18
	match hose_state:
		Hose.HELD:
			grip = $Player.hand_position()
			angle = -0.25 if $Player.facing_right else PI+0.25
		Hose.LATCHED:
			angle = -PI/2
			grip = hose.socket - Vector2.from_angle(angle)*hose.Nozzle.TIP
		Hose.RETURNING:
			reel_progress = minf(1.0,reel_progress + delta*1.35)
			var t := smoothstep(0.0,1.0,reel_progress)
			grip = return_from.lerp(grip,t) + Vector2(0,sin(t*PI)*17.0)
			angle = lerp_angle(return_angle,angle,t)
			if reel_progress >= 1.0:
				hose_state = Hose.STOWED
	var flow := GameManager.get_flow_rate()*flow_factor if is_pump_on and connected_hose else 0.0
	hose.update_hose(grip,angle,hose_state == Hose.HELD,connected_hose,hose_state == Hose.HELD,current_volume,flow,fuel_color,delta)

func ship_depart() -> void:
	if hose_state in [Hose.HELD,Hose.LATCHED]:
		return_from = hose.nozzle.position
		return_angle = hose.nozzle.rotation
		reel_progress = 0.0
		hose_state = Hose.RETURNING
		$Player.carrying_nozzle = false
	super.ship_depart()

func build_radar() -> void:
	radar = Panel.new()
	radar.position = Vector2(30, 557)
	radar.size = Vector2(1220, 140)
	radar.add_theme_stylebox_override("panel", ui_style(Color("182431"), Color("dfaa66"), 9))
	$CanvasLayer.add_child(radar)
	radar_title = pause_label(radar, "", Rect2(22, 8, 1160, 39), 25, Color("ffcd86"))
	radar_note = pause_label(radar, "", Rect2(22, 47, 1160, 32), 18, Color("e0ebec"))
	close_gate = pause_button(radar, "[1]  Fechar a doca", Rect2(22, 85, 286, 42), true)
	allow_landing = pause_button(radar, "[2]  Liberar o pouso", Rect2(324, 85, 286, 42))
	close_gate.pressed.connect(choose_gate.bind(true))
	allow_landing.pressed.connect(choose_gate.bind(false))
	repeat_alert = pause_button($CanvasLayer, "Repetir alerta   [R]", Rect2(30, 50, 240, 29))
	repeat_alert.pressed.connect(replay_forecast)
	for button in [close_gate, allow_landing, repeat_alert]:
		button.focus_mode = Control.FOCUS_NONE

func update_radar() -> void:
	if not is_instance_valid(radar) or report_open:
		return
	var pending := gate in ["forecast", "closed"]
	var showing := pending or (gate in ["exposed", "protected"] and gate_age < 4.0)
	radar.visible = showing
	close_gate.visible = gate == "forecast"
	allow_landing.visible = gate == "forecast"
	repeat_alert.visible = GameManager.weather_demo and gate != "forecast"
	for item in [hud_panel, valve_panel, flow_button, action_hint, flight_label, extension_hud, shortcut_label]:
		item.visible = not pending
	$CanvasLayer/AriaPanel.visible = not showing
	match gate:
		"forecast":
			radar_title.text = "Alerta de tempestade"
			radar_note.text = "Poeira se aproxima. Feche a doca para proteger o filtro ou deixe a nave pousar agora."
		"closed":
			radar_title.text = "Fechando a doca" if gate_age < DOOR_CLOSE_TIME else "Comporta fechada"
			radar_note.text = "A nave aguarda em órbita. A rajada passa em %d s." % ceili(maxf(0.0, GUST_DURATION - gate_age))
		"exposed":
			radar_title.text = "Pouso liberado na poeira"
			radar_note.text = "A poeira entrou no filtro. Quando a nave atracar, use F ao lado dele para limpar as grades."
		"protected":
			radar_title.text = "A tempestade passou"
			radar_note.text = "O filtro ficou limpo. Pouso autorizado."
	if pending:
		$CanvasLayer/TimerLabel.text = "Pouso em espera"

func choose_gate(protect: bool) -> void:
	if gameplay_paused or report_open or gate != "forecast":
		return
	gate_age = 0.0
	if protect:
		gate = "closed"
	else:
		gate = "exposed"
		dust_zones = 7
		weather_age = 4.0
		sync_filter()
	SoundManager.play_click()
	update_radar()
	remember_service()

func advance_front(delta: float) -> void:
	gate_age += delta
	# Hold the front on the horizon until the operator answers.
	var front := minf(gate_age + 1.0, 4.0)
	if gate == "closed":
		front = lerpf(5.0, 28.0, clampf(gate_age / GUST_DURATION, 0, 1))
		weather.shutter = smoothstep(0.0, DOOR_CLOSE_TIME, gate_age)
	weather.advance(delta, front, true, false)
	if gate == "closed" and gate_age >= GUST_DURATION:
		gate = "protected"
		gate_age = 0.0
		incident = ""
		remember_service()
	elif gate == "closed":
		save_clock += delta
		if save_clock >= 1.0:
			remember_service()
			save_clock = 0.0
	update_radar()
	queue_redraw()

func replay_forecast() -> void:
	if not GameManager.weather_demo or gameplay_paused or report_open or bench.visible:
		return
	GameManager.start_weather_demo()
	hose.deployed = 0.0
	weather.stop_audio()
	weather.last_closure = 0.0
	weather.shutter = 0.0
	weather.level = 0.0
	spawn_new_ship()
	ship_visual.position = ship_pos
	refresh_hose(0.0)
	sync_filter()

