extends Control

@onready var start_button: Button = $Interface/MainPanel/StartButton
@onready var station_status_label: Label = $Interface/StatusPanel/StationStatus
@onready var stats_label: Label = $Interface/StatusPanel/Stats
@onready var tutorial_overlay: Control = $TutorialOverlay
@onready var reset_overlay: Control = $ResetOverlay

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	$Interface/MainPanel/UpgradeButton.pressed.connect(_on_upgrade_pressed)
	$Interface/MainPanel/TutorialButton.pressed.connect(_on_tutorial_pressed)
	$Interface/ResetButton.pressed.connect(_on_reset_pressed)
	$Interface/ExitButton.pressed.connect(_on_exit_pressed)
	$TutorialOverlay/Card/CloseButton.pressed.connect(_on_tutorial_close_pressed)
	$ResetOverlay/Card/CancelButton.pressed.connect(_on_reset_cancel_pressed)
	$ResetOverlay/Card/ConfirmButton.pressed.connect(_on_reset_confirm_pressed)

	for button in [
		start_button,
		$Interface/MainPanel/UpgradeButton,
		$Interface/MainPanel/TutorialButton,
		$Interface/ResetButton,
		$Interface/ExitButton,
		$TutorialOverlay/Card/CloseButton,
		$ResetOverlay/Card/CancelButton,
		$ResetOverlay/Card/ConfirmButton
	]:
		button.mouse_entered.connect(_on_button_hover)

	tutorial_overlay.hide()
	reset_overlay.hide()
	refresh_station_data()
	start_button.grab_focus()

func refresh_station_data() -> void:
	station_status_label.text = "%s\n%d CR disponíveis  •  Reputação %d%%\n%d módulos instalados" % [
		GameManager.get_rank_name(),
		GameManager.credits,
		int(GameManager.reputation * 100.0),
		GameManager.get_installed_upgrades()
	]

	if GameManager.total_served > 0:
		start_button.text = "CONTINUAR OPERAÇÕES   >"
	else:
		start_button.text = "INICIAR TURNO   >"

	stats_label.text = "ATENDIMENTOS   %d\nSUCESSOS        %d\nFALHAS          %d\nMELHOR SEQUÊNCIA  %d\n\nÚltimo registro: %s" % [
		GameManager.total_served,
		GameManager.total_success,
		GameManager.total_failed,
		GameManager.best_streak,
		GameManager.last_result
	]

func _on_start_pressed() -> void:
	_play_click()
	get_tree().change_scene_to_file("res://Gameplay.tscn")

func _on_upgrade_pressed() -> void:
	_play_click()
	get_tree().change_scene_to_file("res://UpgradeMenu.tscn")

func _on_tutorial_pressed() -> void:
	_play_click()
	tutorial_overlay.show()
	$TutorialOverlay/Card/CloseButton.grab_focus()

func _on_tutorial_close_pressed() -> void:
	_play_click()
	tutorial_overlay.hide()
	start_button.grab_focus()

func _on_reset_pressed() -> void:
	_play_click()
	reset_overlay.show()
	$ResetOverlay/Card/CancelButton.grab_focus()

func _on_reset_cancel_pressed() -> void:
	_play_click()
	reset_overlay.hide()
	start_button.grab_focus()

func _on_reset_confirm_pressed() -> void:
	_play_click()
	GameManager.reset_game()
	reset_overlay.hide()
	refresh_station_data()
	start_button.grab_focus()

func _on_exit_pressed() -> void:
	_play_click()
	get_tree().quit()

func _on_button_hover() -> void:
	if has_node("/root/SoundManager"):
		SoundManager.play_click()

func _play_click() -> void:
	if has_node("/root/SoundManager"):
		SoundManager.play_click()
