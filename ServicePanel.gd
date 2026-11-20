extends Control

signal changed
signal finished
signal closed

enum Phase { INSPECT, WORK, READY }
const RINGS := [16, 20, 24]
const PALE := Color("#e3ebe9")
const METAL := Color("#94a9ac")
const DARK := Color("#15262e")
const BRASS := Color("#efb471")
const GOOD := Color("#82d5ac")
const OIL := Color("#ca823f")
const RUBBER := Color("#bf7560")

var kind := ""
var target := 8
var amount := 0
var ring := 0
var phase := Phase.INSPECT
var dose := 1
var feedback := ""
var failed_fit := false
var display_level := 0.0
var transfer: Tween
var clock := 0.0
var controls: Array[Button] = []

func _ready() -> void:
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP
	for i in range(4):
		var button := Button.new()
		button.position = Vector2(278 + i * 186, 523)
		button.size = Vector2(173, 45)
		button.add_theme_font_size_override("font_size",16)
		button.pressed.connect(operate.bind(i))
		add_child(button)
		controls.append(button)
	hide()

func present(job: String, spec: int, level: int, selection: int, saved_phase: int, saved_dose: int) -> void:
	kind = job
	target = spec
	amount = level
	ring = selection
	phase = clampi(saved_phase, Phase.INSPECT, Phase.READY) as Phase
	dose = clampi(saved_dose, 1, 12)
	feedback = ""
	failed_fit = false
	display_level = amount
	if transfer:
		transfer.kill()
	clock = 0
	show()
	refresh(true)

func refresh(focus := false) -> void:
	var actions: Array
	if phase == Phase.READY:
		actions = ["", "", "Fechar escotilha", ""]
	elif phase == Phase.INSPECT:
		actions = ["", "", "Acoplar dosador" if kind == "oil" else "Retirar anel rompido", "Voltar à doca"]
	elif kind == "oil":
		actions = ["− 250 mL", "+ 250 mL", "Recolher óleo" if amount > target else "Transferir óleo", "Voltar à doca"]
	else:
		actions = ["‹ Anel anterior", "Próximo anel ›", "Testar encaixe", "Voltar à doca"]
	for i in range(4):
		controls[i].visible = actions[i] != ""
		controls[i].text = actions[i]
		controls[i].disabled = false
	if phase == Phase.WORK and kind == "oil":
		controls[0].disabled = dose <= 1
		controls[1].disabled = dose >= 12
	if focus:
		controls[2].grab_focus()
	queue_redraw()

func operate(index: int) -> void:
	if not visible or not controls[index].visible or controls[index].disabled:
		return
	if index == 3:
		closed.emit()
		return
	if phase == Phase.READY:
		finished.emit()
		return
	var before := phase
	feedback = ""
	failed_fit = false
	if phase == Phase.INSPECT:
		phase = Phase.READY if kind == "oil" and amount == target else Phase.WORK
	elif kind == "oil":
		if index == 2:
			transfer_oil()
		else:
			dose = clampi(dose + (1 if index == 1 else -1), 1, 12)
	elif index != 2:
		ring = posmod(ring + (1 if index == 1 else -1), RINGS.size())
	elif RINGS[ring] == target * 2:
		phase = Phase.READY
	else:
		failed_fit = true
		feedback = "Sobra uma fresta. Experimente um anel maior." if RINGS[ring] < target * 2 else "A borda dobra para fora do sulco. Experimente um anel menor."
	SoundManager.play_click()
	changed.emit()
	refresh(before != phase)

func transfer_oil() -> void:
	var next := amount - dose if amount > target else amount + dose
	if next < 0 or next > 12:
		feedback = "Essa dose excede o volume disponível. Reduza a dose do dosador."
		return
	amount = next
	if transfer:
		transfer.kill()
	transfer = create_tween()
	transfer.tween_property(self, "display_level", float(amount), 0.45)
	if amount == target:
		phase = Phase.READY
	else:
		feedback = "Óleo abaixo da marca. Ajuste a dose restante." if amount < target else "Óleo acima da marca. Use o dosador para recolher o excesso."

func _process(delta: float) -> void:
	if visible:
		clock += delta
		queue_redraw()

func label_at(x: int, y: int, words: String, px: int, tint := PALE) -> void:
	draw_string(ThemeDB.fallback_font,Vector2(x,y),words,HORIZONTAL_ALIGNMENT_LEFT,-1,px,tint)

func litres(steps: int) -> String:
	return ("%.2f L" % (steps * 0.25)).replace(".", ",")

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO,size),Color("#09121ae6"))
	draw_rect(Rect2(251,121,778,477),DARK)
	draw_rect(Rect2(251,121,778,477),METAL,false,2)
	for x in [261,1018]:
		for y in [131,587]:
			draw_circle(Vector2(x,y),3,METAL)
	label_at(278,157,"MOTOR AUXILIAR   /   ESCOTILHA DE INSPEÇÃO",14,METAL)
	label_at(278,202,"Reservatório de óleo" if kind == "oil" else "Vedação do retorno de óleo",30)
	var heading: String = ["Inspeção","Reposição" if kind == "oil" else "Bancada","Concluído"][phase]
	label_at(865,157,heading,16,GOOD if phase == Phase.READY else BRASS)
	if kind == "oil":
		draw_reservoir()
	else:
		draw_coupling()
	draw_line(Vector2(278,451),Vector2(1000,451),Color("#41565d"),1)
	var hint := ""
	if phase == Phase.INSPECT:
		hint = "Acople o dosador à entrada para ajustar o nível de óleo." if kind == "oil" else "Retire o anel rachado para medir o sulco e instalar outro."
	elif phase == Phase.WORK:
		hint = "Escolha quanto transferir. Cada passo do dosador vale 250 mL." if kind == "oil" else "Leia os dois lados do sulco na régua. A diferença é o diâmetro do anel."
	else:
		hint = "Feche a escotilha para a equipe liberar o abastecimento."
	label_at(278,494,feedback if feedback != "" else hint,17,BRASS if feedback != "" else PALE)

func draw_reservoir() -> void:
	var base_y := 389
	draw_rect(Rect2(345,237,106,160),METAL)
	draw_rect(Rect2(351,243,94,146),Color("#0a1920"))
	var h := display_level * 12.0
	if h > 0:
		draw_rect(Rect2(351,base_y-h,94,h),OIL)
		draw_line(Vector2(351,base_y-h),Vector2(445,base_y-h),BRASS,2)
	for n in range(13):
		draw_line(Vector2(428 if n%4 == 0 else 436,base_y-n*12),Vector2(445,base_y-n*12),PALE,1)
	for n in range(4):
		label_at(303,394-n*48,"%d L" % n,13,METAL)
	var mark := base_y-target*12
	draw_line(Vector2(342,mark),Vector2(458,mark),GOOD,3)
	draw_colored_polygon(PackedVector2Array([Vector2(457,mark),Vector2(469,mark-6),Vector2(469,mark+6)]),GOOD)
	draw_rect(Rect2(377,223,42,14),Color("#566b73"))
	if phase == Phase.WORK:
		draw_polyline(PackedVector2Array([Vector2(397,222),Vector2(397,215),Vector2(502,215),Vector2(502,252)]),METAL,5,true)
		draw_rect(Rect2(486,250,33,94),Color("#37484d"))
		draw_rect(Rect2(491,338-dose*6,23,dose*6),OIL)
		for n in range(7):
			draw_line(Vector2(506,338-n*12),Vector2(517,338-n*12),PALE,1)
	label_at(315,429,"Visor do cárter",17,METAL)
	label_at(565,262,"Nível no visor     " + litres(amount),24)
	label_at(565,300,"Marca de serviço     " + litres(target),19,GOOD)
	if phase == Phase.INSPECT:
		label_at(565,354,"Óleo fora da marca de partida.",19,BRASS)
		label_at(565,388,"O óleo lubrifica o motor auxiliar.",17)
		label_at(565,412,"O sensor só libera a partida na marca.",17)
	elif phase == Phase.WORK:
		label_at(565,354,"Dose selecionada     %d mL" % (dose*250),22,BRASS)
		label_at(565,390,"1 L equivale a 1.000 mL.",17)
	else:
		label_at(565,361,"Nível correto. Lubrificação liberada.",20,GOOD)

func draw_coupling() -> void:
	var c := Vector2(428,320)
	var radius := target * 4.0
	draw_rect(Rect2(284,306,230,28),Color("#455960"))
	draw_circle(c,radius+25,METAL,true,-1,true)
	draw_circle(c,radius+13,Color("#293b40"),true,-1,true)
	draw_arc(c,radius,0,TAU,64,Color("#0b191e"),9,true)
	draw_circle(c,radius-6,Color("#68777a"),true,-1,true)
	for i in range(4):
		draw_circle(c+Vector2.from_angle(PI/4+i*PI/2)*(radius+18),3,DARK)
	if phase == Phase.INSPECT:
		draw_arc(c,radius,0.89,TAU+0.67,64,RUBBER,7,true)
		var leak := c + Vector2.from_angle(0.78)*radius
		var drip := fmod(clock,1.2)/1.2
		draw_line(leak,leak+Vector2(1,12),OIL,3,true)
		draw_circle(leak+Vector2(1,15+drip*20),3,Color(OIL,1-drip),true,-1,true)
		label_at(569,275,"Retorno com vazamento",24,BRASS)
		label_at(569,322,"O óleo escapa pela fenda no anel.",19)
		label_at(569,356,"Com o retorno aberto, o motor",18)
		label_at(569,383,"perde óleo quando entra em operação.",18)
	elif phase == Phase.WORK:
		var left := int(c.x-radius)
		var right := int(c.x+radius)
		draw_rect(Rect2(left-20,389,right-left+40,16),METAL)
		for x in range(left-20,right+21,4):
			draw_line(Vector2(x,390),Vector2(x,399 if (x-left)%20==0 else 394),DARK,1)
		for x in [left,right]:
			draw_line(Vector2(x,c.y),Vector2(x,404),BRASS,1.5)
		# The two contact points sit on a ruler graduated in millimetres.
		label_at(left-16,425,"5 mm",14,BRASS)
		label_at(right-18,425,"%d mm" % (5+target*2),14,BRASS)
		var sample := c if failed_fit else Vector2(612,323)
		draw_arc(sample,RINGS[ring]*2.0,0,TAU,64,RUBBER,7,true)
		label_at(701,288,"Anel de reposição",21,METAL)
		label_at(701,336,"Ø %d mm" % RINGS[ring],30)
		label_at(701,378,"Escolha o diâmetro",17)
		label_at(701,403,"que cabe no sulco.",17)
	else:
		draw_arc(c,radius,0,TAU,64,RUBBER,7,true)
		label_at(569,295,"Anel assentado no sulco",24,GOOD)
		label_at(569,337,"A conexão passou no teste de vedação.",18)
		label_at(569,377,"O retorno do óleo está seco.",18)
