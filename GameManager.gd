extends Node

var credits: int = 1000
var reputation: float = 0.5 # 50%

# Upgrades
var upgrade_pump_speed: int = 0
var upgrade_auto_valve: bool = false
var upgrade_helper_hud: bool = false

func reset_game():
	credits = 1000
	reputation = 0.5
	upgrade_pump_speed = 0
	upgrade_auto_valve = false
	upgrade_helper_hud = false

func get_flow_rate() -> float:
	# Base flow is 40 UF/sec, each upgrade increases it by 20
	return 40.0 + (upgrade_pump_speed * 20.0)
