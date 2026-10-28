extends Node

const SAVE_PATH: String = "user://fueling_frontiers_save.cfg"

var credits: int = 1000
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

func _ready() -> void:
	load_game()

func reset_game() -> void:
	credits = 1000
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

func register_success(streak: int, earned: int) -> void:
	total_served += 1
	total_success += 1
	best_streak = maxi(best_streak, streak)
	lifetime_credits += maxi(0, earned)
	last_result = "Atendimento concluído com sucesso"
	save_game()

func register_failure(reason: String = "Falha operacional") -> void:
	total_served += 1
	total_failed += 1
	last_result = reason
	save_game()

func save_game() -> void:
	var config: ConfigFile = ConfigFile.new()
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
	config.save(SAVE_PATH)

func load_game() -> void:
	var config: ConfigFile = ConfigFile.new()
	var err: Error = config.load(SAVE_PATH)
	if err != OK:
		return
	credits = int(config.get_value("economy", "credits", 1000))
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
