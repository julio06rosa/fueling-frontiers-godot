extends "res://UpgradeMenu.gd"

var statuses: Array[Label] = []
var metrics: Array[Label] = []
var feedback: Label
var balance_before: int = 0

func box(bg: String, edge: String) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(bg)
	style.border_color = Color(edge)
	style.set_border_width_all(1)
	style.set_corner_radius_all(12)
	return style

func label_at(parent: Node, text_value: String, rect: Rect2, font_size: int, color: String = "e3edf5") -> Label:
	var label := Label.new()
	label.text = text_value
	label.position = rect.position
	label.size = rect.size
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color(color))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(label)
	return label

func button_at(parent: Node, title: String, rect: Rect2) -> Button:
	var button := Button.new()
	button.text = title
	button.position = rect.position
	button.size = rect.size
	button.add_theme_font_size_override("font_size", 17)
	button.add_theme_stylebox_override("normal", box("194850", "347783"))
	button.add_theme_stylebox_override("hover", box("27626a", "79d6db"))
	button.add_theme_stylebox_override("pressed", box("103039", "4dadb7"))
	button.add_theme_stylebox_override("disabled", box("172535", "304052"))
	button.add_theme_stylebox_override("focus", box("255660", "b3f4f0"))
	button.add_theme_color_override("font_disabled_color", Color("8399aa"))
	parent.add_child(button)
	return button

func _ready():
	# Reutiliza as compras originais; somente a apresentação é substituída.
	for child in get_children():
		if child is CanvasItem:
			child.hide()
	var backdrop := ColorRect.new()
	backdrop.color = Color("0b1422")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)
	var layout := Control.new()
	add_child(layout)
	layout.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	layout.position -= Vector2(560, 350)
	layout.size = Vector2(1120, 700)
	label_at(layout, "MARS STATION  /  ENGENHARIA", Rect2(0, 30, 700, 25), 14, "68c6c7")
	label_at(layout, "Oficina de melhorias", Rect2(0, 66, 750, 56), 38)
	label_at(layout, "Prepare a estação para o próximo atendimento.", Rect2(0, 123, 750, 30), 18, "8da5b9")
	label_credits = label_at(layout, "", Rect2(770, 84, 350, 50), 21, "8ce2c7")
	label_credits.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	var names := ["Bomba de alta vazão", "Válvula automática", "Sensor holográfico"]
	var tags := ["01 / DESEMPENHO", "02 / SEGURANÇA", "03 / ASSISTÊNCIA"]
	var descriptions := ["Mais combustível por segundo. Cada nível adiciona 20 UF/s à vazão da bomba.", "Encerra o abastecimento ao atingir o volume pedido. A mistura continua sob seu controle.", "Mostra as porcentagens ideais dos componentes no manifesto de carga."]
	var buttons: Array[Button] = []
	for index in range(3):
		var card := Panel.new()
		card.position = Vector2(index * 380, 190)
		card.size = Vector2(360, 360)
		card.add_theme_stylebox_override("panel", box("112135", "2b435a"))
		layout.add_child(card)
		label_at(card, tags[index], Rect2(24, 24, 312, 24), 13, "63c5cc")
		label_at(card, names[index], Rect2(24, 62, 312, 34), 24)
		var description := label_at(card, descriptions[index], Rect2(24, 112, 312, 90), 17, "a5b8c9")
		description.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		metrics.append(label_at(card, "", Rect2(24, 215, 312, 30), 20, "e6d09a"))
		statuses.append(label_at(card, "", Rect2(24, 254, 312, 24), 14, "89a4bb"))
		buttons.append(button_at(card, "", Rect2(24, 297, 312, 43)))
	btn_speed = buttons[0]
	btn_valve = buttons[1]
	btn_helper = buttons[2]
	btn_speed.pressed.connect(_on_speed_pressed)
	btn_valve.pressed.connect(_on_valve_pressed)
	btn_helper.pressed.connect(_on_helper_pressed)
	var back := button_at(layout, "Voltar ao menu", Rect2(0, 620, 215, 48))
	back.pressed.connect(_on_back_pressed)
	var play := button_at(layout, "Ir para o hangar  >", Rect2(865, 620, 255, 48))
	play.pressed.connect(_on_play_pressed)
	feedback = label_at(layout, "As melhorias ficam disponíveis imediatamente após a compra.", Rect2(0, 572, 1120, 30), 16, "8da5b9")
	balance_before = GameManager.credits
	update_ui()
	play.grab_focus()

func update_ui():
	super.update_ui()
	if statuses.is_empty():
		return
	label_credits.text = "%d CR  /  DISPONÍVEL" % GameManager.credits
	var level: int = GameManager.upgrade_pump_speed
	metrics[0].text = "%.0f UF/s  >  %.0f UF/s" % [GameManager.get_flow_rate(), GameManager.get_flow_rate() + 20.0] if level < 3 else "100 UF/s / capacidade máxima"
	metrics[1].text = "Corte automático de volume"
	metrics[2].text = "Proporção ideal no painel"
	var owned := [level >= 3, GameManager.upgrade_auto_valve, GameManager.upgrade_helper_hud]
	var costs := [(level + 1) * 500, 800, 400]
	var buttons := [btn_speed, btn_valve, btn_helper]
	for index in range(3):
		if owned[index]:
			buttons[index].text = "NÍVEL MÁXIMO" if index == 0 else "INSTALADO"
			statuses[index].text = "Nível 3 de 3 concluído" if index == 0 else "Pronto para uso no hangar"
			statuses[index].modulate = Color("85e2bd")
		else:
			buttons[index].text = "Melhorar / %d CR" % costs[index] if index == 0 else "Instalar / %d CR" % costs[index]
			statuses[index].text = "Nível %d de 3" % level if index == 0 else "Módulo disponível"
			statuses[index].modulate = Color.WHITE
			if GameManager.credits < costs[index]:
				statuses[index].text += " / faltam %d CR" % (costs[index] - GameManager.credits)
	if GameManager.credits < balance_before:
		feedback.text = "Melhoria instalada! Seu equipamento já está atualizado."
		feedback.modulate = Color("85e2bd")
	balance_before = GameManager.credits
