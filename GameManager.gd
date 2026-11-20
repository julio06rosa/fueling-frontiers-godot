extends Node

const SAVE_PATH: String = "user://mars_playtest.cfg"

var credits: int = 0
var reputation: float = 0.5

# Upgrades
var upgrade_pump_speed: int = 0
var upgrade_auto_valve: bool = false
var upgrade_helper_hud: bool = false

# Estatísticas persistentes da estação.
var total_served: int = 0
var total_success: int = 0
var total_failed: int = 0
var best_streak: int = 0
var lifetime_credits: int = 0
var last_result: String = "Nenhum atendimento registrado"

const SHIFT_SIZE := 6
var tutorial_done := false
var active_service: Dictionary = {}
var shift_number := 1
var shift_served := 0
var shift_success := 0
var shift_precise := 0
var shift_net := 0
var shift_streak := 0
var shift_rep_start := 0.5
var mission_count := 0
var decorations := 0

func goal() -> int:
	return mini(shift_number + 2, 5)

func mission_goal() -> int:
	return 2 if shift_number % 3 != 0 else 3

func mission_label() -> String:
	match shift_number % 3:
		1: return "notas A ou S"
		2: return "cargueiros aprovados"
		_: return "acertos seguidos"

func next_shift() -> void:
	if shift_served < SHIFT_SIZE:
		return
	shift_number += 1
	clear_shift()
	save_game()

func clear_shift() -> void:
	shift_served = 0
	shift_success = 0
	shift_precise = 0
	shift_net = 0
	shift_streak = 0
	shift_rep_start = reputation
	mission_count = 0
	active_service = {}

func record_service(delta_credits: int) -> void:
	active_service = {}
	shift_served += 1
	shift_net += delta_credits
	if shift_served == SHIFT_SIZE:
		if shift_success >= goal():
			credits += 150
			shift_net += 150
			lifetime_credits += 150
		if mission_count >= mission_goal():
			decorations += 1
			credits += 100
			shift_net += 100
			lifetime_credits += 100

var weather_demo := false
var pump_demo := false
var mechanic := 0
var service_preview := ""

func _ready() -> void:
	pump_demo = "--prever-bomba" in OS.get_cmdline_user_args()
	weather_demo = "--prever-tempestade" in OS.get_cmdline_user_args() or "--simular-operacoes" in OS.get_cmdline_user_args()
	for job in ["oil", "seal"]:
		if ("--servico-" + job) in OS.get_cmdline_user_args():
			service_preview = job
			pump_demo = true
			tutorial_done = true
			shift_served = 2
	if pump_demo or weather_demo:
		var prefs := ConfigFile.new()
		if prefs.load(SAVE_PATH) == OK:
			mechanic = clampi(int(prefs.get_value("crew", "mechanic", 0)), 0, 2)
	if weather_demo:
		tutorial_done = true
		shift_served = 1
	elif not pump_demo:
		load_game()

func start_weather_demo() -> void:
	weather_demo = true
	reset_game()
	tutorial_done = true
	shift_served = 1

func leave_weather_demo() -> void:
	if weather_demo:
		reset_game()
		weather_demo = false
		if not pump_demo:
			load_game()

func reset_game() -> void:
	credits = 0
	reputation = 0.5
	upgrade_pump_speed = 0
	upgrade_auto_valve = false
	upgrade_helper_hud = false
	total_served = 0
	total_success = 0
	total_failed = 0
	best_streak = 0
	lifetime_credits = 0
	last_result = "Novo turno iniciado"
	tutorial_done = false
	shift_number = 1
	decorations = 0
	clear_shift()
	save_game()

func get_flow_rate() -> float:
	return 40.0 + (upgrade_pump_speed * 20.0)

func get_rank_name() -> String:
	if reputation >= 0.90:
		return "COMANDANTE DE DOCA"
	if reputation >= 0.75:
		return "ESPECIALISTA ORBITAL"
	if reputation >= 0.60:
		return "OPERADOR SÊNIOR"
	if reputation >= 0.40:
		return "ENGENHEIRO DE TURNO"
	if reputation >= 0.20:
		return "OPERADOR EM ALERTA"
	return "LICENÇA CRÍTICA"

func get_installed_upgrades() -> int:
	return upgrade_pump_speed + int(upgrade_auto_valve) + int(upgrade_helper_hud)

func register_success(streak: int, earned: int, grade: String) -> void:
	total_served += 1
	total_success += 1
	shift_success += 1
	shift_streak = streak
	if grade in ["S", "A"]:
		shift_precise += 1
	match shift_number % 3:
		1: mission_count = shift_precise
		2:
			if (shift_served + shift_number - 1) % 3 == 0:
				mission_count += 1
		0: mission_count = maxi(mission_count, streak)
	record_service(earned)
	best_streak = maxi(best_streak, streak)
	lifetime_credits += maxi(0, earned)
	last_result = "Atendimento concluído com sucesso"
	save_game()

func register_failure(reason: String, delta_credits: int) -> void:
	total_served += 1
	total_failed += 1
	shift_streak = 0
	record_service(delta_credits)
	last_result = reason
	save_game()

func save_game() -> void:
	if weather_demo or pump_demo:
		return
	var config: ConfigFile = ConfigFile.new()
	config.set_value("crew", "mechanic", mechanic)
	config.set_value("economy", "credits", credits)
	config.set_value("economy", "reputation", reputation)
	config.set_value("upgrades", "pump_speed", upgrade_pump_speed)
	config.set_value("upgrades", "auto_valve", upgrade_auto_valve)
	config.set_value("upgrades", "helper_hud", upgrade_helper_hud)
	config.set_value("stats", "total_served", total_served)
	config.set_value("stats", "total_success", total_success)
	config.set_value("stats", "total_failed", total_failed)
	config.set_value("stats", "best_streak", best_streak)
	config.set_value("stats", "lifetime_credits", lifetime_credits)
	config.set_value("stats", "last_result", last_result)
	config.set_value("trial", "tutorial", tutorial_done)
	config.set_value("trial", "mission", mission_count)
	config.set_value("trial", "active", active_service)
	config.set_value("trial", "shift", [shift_number, shift_served, shift_success, shift_precise, shift_net, shift_streak, shift_rep_start, decorations])
	config.save(SAVE_PATH)

func load_game() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(SAVE_PATH)
	if err != OK:
		return
	mechanic = clampi(int(config.get_value("crew", "mechanic", 0)), 0, 2)
	credits = int(config.get_value("economy", "credits", 0))
	reputation = clampf(float(config.get_value("economy", "reputation", 0.5)), 0.0, 1.0)
	upgrade_pump_speed = clampi(int(config.get_value("upgrades", "pump_speed", 0)), 0, 3)
	upgrade_auto_valve = bool(config.get_value("upgrades", "auto_valve", false))
	upgrade_helper_hud = bool(config.get_value("upgrades", "helper_hud", false))
	total_served = maxi(0, int(config.get_value("stats", "total_served", 0)))
	total_success = maxi(0, int(config.get_value("stats", "total_success", 0)))
	total_failed = maxi(0, int(config.get_value("stats", "total_failed", 0)))
	best_streak = maxi(0, int(config.get_value("stats", "best_streak", 0)))
	lifetime_credits = maxi(0, int(config.get_value("stats", "lifetime_credits", 0)))
	last_result = str(config.get_value("stats", "last_result", "Nenhum atendimento registrado"))

	mission_count = int(config.get_value("trial", "mission", 0))
	tutorial_done = bool(config.get_value("trial", "tutorial", false))
	active_service = config.get_value("trial", "active", {})
	var fields: Array = config.get_value("trial", "shift", [])
	if fields.size() == 8:
		shift_number = fields[0]
		shift_served = fields[1]
		shift_success = fields[2]
		shift_precise = fields[3]
		shift_net = fields[4]
		shift_streak = fields[5]
		shift_rep_start = fields[6]
		decorations = fields[7]
