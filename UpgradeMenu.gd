extends Control

var btn_speed: Button
var btn_valve: Button
var btn_helper: Button
var label_credits: Label

func _ready():
	btn_speed = $Panel/VBox/SpeedUpgrade/BuyButton
	btn_valve = $Panel/VBox/ValveUpgrade/BuyButton
	btn_helper = $Panel/VBox/HelperUpgrade/BuyButton
	label_credits = $CreditsLabel
	
	btn_speed.pressed.connect(_on_speed_pressed)
	btn_valve.pressed.connect(_on_valve_pressed)
	btn_helper.pressed.connect(_on_helper_pressed)
	$BackButton.pressed.connect(_on_back_pressed)
	$PlayButton.pressed.connect(_on_play_pressed)
	
	update_ui()

func update_ui():
	label_credits.text = "Créditos Disponíveis: %d" % GameManager.credits
	
	# Speed upgrade UI
	if GameManager.upgrade_pump_speed >= 3:
		btn_speed.text = "MÁXIMO"
		btn_speed.disabled = true
	else:
		var cost = (GameManager.upgrade_pump_speed + 1) * 500
		btn_speed.text = "Comprar (Lvl %d) - %d C" % [GameManager.upgrade_pump_speed + 1, cost]
		btn_speed.disabled = GameManager.credits < cost
		
	# Valve upgrade UI
	if GameManager.upgrade_auto_valve:
		btn_valve.text = "ADQUIRIDO"
		btn_valve.disabled = true
	else:
		var cost = 800
		btn_valve.text = "Comprar - %d C" % cost
		btn_valve.disabled = GameManager.credits < cost
		
	# Helper HUD upgrade UI
	if GameManager.upgrade_helper_hud:
		btn_helper.text = "ADQUIRIDO"
		btn_helper.disabled = true
	else:
		var cost = 400
		btn_helper.text = "Comprar - %d C" % cost
		btn_helper.disabled = GameManager.credits < cost

func _on_speed_pressed():
	var cost = (GameManager.upgrade_pump_speed + 1) * 500
	if GameManager.credits >= cost and GameManager.upgrade_pump_speed < 3:
		GameManager.credits -= cost
		GameManager.upgrade_pump_speed += 1
		if has_node("/root/SoundManager"):
			SoundManager.play_success()
		update_ui()

func _on_valve_pressed():
	var cost = 800
	if GameManager.credits >= cost and not GameManager.upgrade_auto_valve:
		GameManager.credits -= cost
		GameManager.upgrade_auto_valve = true
		if has_node("/root/SoundManager"):
			SoundManager.play_success()
		update_ui()

func _on_helper_pressed():
	var cost = 400
	if GameManager.credits >= cost and not GameManager.upgrade_helper_hud:
		GameManager.credits -= cost
		GameManager.upgrade_helper_hud = true
		if has_node("/root/SoundManager"):
			SoundManager.play_success()
		update_ui()

func _on_back_pressed():
	if has_node("/root/SoundManager"):
		SoundManager.play_click()
	get_tree().change_scene_to_file("res://MainMenu.tscn")

func _on_play_pressed():
	if has_node("/root/SoundManager"):
		SoundManager.play_click()
	get_tree().change_scene_to_file("res://Gameplay.tscn")
