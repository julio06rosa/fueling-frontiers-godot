extends Control

@onready var start_button: Button = $Interface/MainPanel/StartButton
@onready var station_status_label: Label = $Interface/StatusPanel/StationStatus
@onready var stats_label: Label = $Interface/StatusPanel/Stats
@onready var last_result_label: Label = $Interface/StatusPanel/LastResult
@onready var tutorial_overlay: Control = $TutorialOverlay
@onready var reset_overlay: Control = $ResetOverlay

const Operator = preload("res://PlayerVisual.gd")

func build_crew_picker() -> void:
	var title := Label.new()
	title.text = "ESCOLHA SEU PERSONAGEM"
	title.position = Vector2(807, 72)
	title.add_theme_color_override("font_color", Color("#90dfd5"))
	$Interface.add_child(title)
	var group := ButtonGroup.new()
	for i in range(Operator.NAMES.size()):
		var button := Button.new()
		button.position = Vector2(807 + i * 140, 104)
		button.size = Vector2(132, 146)
		button.toggle_mode = true
		button.button_group = group
		button.accessibility_name = Operator.NAMES[i]
		button.add_theme_stylebox_override("normal", $Interface/MainPanel/UpgradeButton.get_theme_stylebox("normal"))
		button.add_theme_stylebox_override("pressed", start_button.get_theme_stylebox("normal"))
		$Interface.add_child(button)
		var portrait := Operator.new()
		portrait.portrait = i
		portrait.position = Vector2(65, 106)
		portrait.scale = Vector2.ONE * 1.25
		button.add_child(portrait)
		portrait.set_physics_process(false)
		var caption := Label.new()
		caption.text = Operator.NAMES[i]
		caption.position = Vector2(0,112)
		caption.size = Vector2(132,26)
		caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		caption.mouse_filter = Control.MOUSE_FILTER_IGNORE
		button.add_child(caption)
		button.button_pressed = i == GameManager.mechanic
		button.pressed.connect(select_mechanic.bind(i))

func select_mechanic(index: int) -> void:
	GameManager.mechanic = index
	GameManager.save_game()
	_play_click()

func _ready() -> void:
	build_crew_picker()
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

	if GameManager.shift_served >= GameManager.SHIFT_SIZE:
		start_button.text = "RELATÓRIO DO TURNO   >"
	elif not GameManager.tutorial_done:
		start_button.text = "FASE 1 • APRENDER A JOGAR   >"
	else:
		start_button.text = "CONTINUAR TURNO %d   >" % GameManager.shift_number

	stats_label.text = "ATENDIMENTOS   %d\nSUCESSOS        %d\nFALHAS          %d\nMELHOR SEQUÊNCIA  %d" % [
		GameManager.total_served,
		GameManager.total_success,
		GameManager.total_failed,
		GameManager.best_streak
	]
	last_result_label.text = GameManager.last_result

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
