extends SceneTree

var jogo
var dados
var erros := 0

func _initialize():
    executar.call_deferred()

func conferir(ok: bool, detalhe: String):
    if not ok:
        erros += 1
        push_error(detalhe)

func preparar(treino := false):
    if current_scene:
        current_scene.free()
    dados.reset_game()
    dados.tutorial_done = not treino
    change_scene_to_file("res://Gameplay.tscn")
    await scene_changed
    jogo = current_scene
    jogo.set_process(false)
    jogo.current_state = jogo.ShipState.WAITING
    jogo.hose_state = jogo.Hose.LATCHED
    jogo.ratio_a = 3
    jogo.ratio_b = 1
    jogo.target_volume = 100

func dosar(porcentagem: float, volume: float):
    jogo.slider_a.value = porcentagem
    if not jogo.is_pump_on:
        jogo.pump_btn.pressed.emit()
    var fator := 0.45 if jogo.fine_flow or jogo.training else 1.0
    jogo._process(volume / (dados.get_flow_rate() * fator))

func executar():
    dados = root.get_node("GameManager")
    await preparar()
    dosar(25, 95)
    jogo.remember_service()
    dados.load_game()
    var gravado: Dictionary = dados.active_service.duplicate(true)
    jogo.restore_service(gravado)
    dosar(75, 5)
    jogo.pump_btn.pressed.emit()
    conferir(is_equal_approx(jogo.delivered_a_percent(), 27.5), "95 UF a 25% + 5 UF a 75%")
    conferir(dados.total_failed == 1 and dados.total_success == 0, "Correção tardia deveria falhar")
    await preparar()
    dosar(75, 100)
    jogo.slider_a.value = 25
    jogo.pump_btn.pressed.emit()
    conferir(dados.total_success == 1, "Ajustar o controle sem fluxo não altera o tanque")
    await preparar()
    dosar(50, 50)
    jogo.toggle_flow()
    dosar(100, 50)
    jogo.pump_btn.pressed.emit()
    conferir(dados.total_success == 1 and is_equal_approx(jogo.delivered_a_percent(),75.0), "Média deve usar volume, mesmo com vazões diferentes")
    await preparar()
    dados.upgrade_auto_valve = true
    dosar(75, 95)
    dosar(75, 12)
    conferir(dados.total_success == 1 and is_equal_approx(jogo.delivered_a_volume,75.0), "Válvula deve limitar ambos os volumes")
    await preparar(true)
    dosar(75, 5)
    dosar(25, 95)
    jogo.slider_a.value = 75
    jogo.pump_btn.pressed.emit()
    conferir(not dados.tutorial_done and jogo.current_volume == 0 and dados.total_failed == 0, "Treino permite repetir mistura incorreta")
    dosar(75, 100)
    jogo.pump_btn.pressed.emit()
    conferir(dados.tutorial_done, "Treino deve terminar após repetir corretamente")
    if erros == 0:
        print("MISTURA_OK")
    quit(1 if erros > 0 else 0)
