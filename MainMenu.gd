extends Control

func _ready():
	$VBoxContainer/StartButton.grab_focus()
	
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/UpgradeButton.pressed.connect(_on_upgrade_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)
	
	for button in $VBoxContainer.get_children():
		if button is Button:
			button.mouse_entered.connect(_on_button_hover)

func _on_start_pressed():
	if has_node("/root/SoundManager"):
		SoundManager.play_click()
	get_tree().change_scene_to_file("res://Gameplay.tscn")

func _on_upgrade_pressed():
	if has_node("/root/SoundManager"):
		SoundManager.play_click()
	get_tree().change_scene_to_file("res://UpgradeMenu.tscn")

func _on_exit_pressed():
	if has_node("/root/SoundManager"):
		SoundManager.play_click()
	get_tree().quit()

func _on_button_hover():
	if has_node("/root/SoundManager"):
		SoundManager.play_click()
