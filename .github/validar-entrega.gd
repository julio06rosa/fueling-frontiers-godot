extends SceneTree

func _initialize() -> void:
    validar.call_deferred()

func caminhar(acao: String, distancia: float, jogador: Node2D) -> void:
    var inicio := jogador.position
    Input.action_press(acao)
    for quadro in range(140):
        await physics_frame
        if inicio.distance_to(jogador.position) >= distancia:
            break
    Input.action_release(acao)
    await process_frame
    await process_frame

func tecla(doca: Node, codigo: Key) -> void:
    var evento := InputEventKey.new()
    evento.keycode = codigo
    evento.pressed = true
    doca._unhandled_input(evento)

func etapa(doca: Node, nome: String) -> bool:
    var balao = doca.tutorial_bubble
    var linhas: int = balao.message.get_line_count()
    var altura: int = linhas * balao.message.get_line_height() + (linhas - 1) * balao.message.get_theme_constant("line_spacing")
    if balao.visible and balao.current_step == nome and altura <= balao.card.size.y - balao.message.position.y - 5:
        return true
    push_error("Etapa esperada: %s, exibida: %s, posição: %s, altura: %d" % [nome, balao.current_step, doca.get_node("Player").position, altura])
    return false

func validar() -> void:
    if change_scene_to_file("res://MainMenu.tscn") != OK:
        quit(1)
        return
    await scene_changed
    current_scene.get_node("Interface/MainPanel/StartButton").pressed.emit()
    await scene_changed
    var doca = current_scene
    await create_timer(3).timeout
    if doca.name != "Gameplay" or not doca.training or not doca.tutorial_bubble.visible:
        quit(2)
        return
    for audio in [doca.weather.breeze, doca.weather.motor, doca.weather.seal]:
        if audio.stream == null or audio.stream.get_length() <= 0:
            quit(3)
            return
    var jogador = doca.get_node("Player")
    tecla(doca, KEY_SPACE)
    tecla(doca, KEY_F)
    if not etapa(doca, "walk") or doca.is_pump_on:
        quit(4)
        return
    var prazo: float = doca.time_left
    await caminhar("ui_right", 24, jogador)
    if not etapa(doca, "pump"):
        quit(5)
        return
    tecla(doca, KEY_F)
    await process_frame
    await process_frame
    if not etapa(doca, "carry"):
        quit(6)
        return
    await caminhar("ui_down", 30, jogador)
    await caminhar("ui_right", 340, jogador)
    await caminhar("ui_up", 46, jogador)
    if not etapa(doca, "socket"):
        quit(7)
        return
    tecla(doca, KEY_F)
    tecla(doca, KEY_SPACE)
    await process_frame
    await process_frame
    if not etapa(doca, "mixture") or doca.is_pump_on:
        quit(8)
        return
    for i in range(25):
        tecla(doca, KEY_E)
    await process_frame
    await process_frame
    if not etapa(doca, "start"):
        quit(9)
        return
    tecla(doca, KEY_SPACE)
    await create_timer(0.4).timeout
    if not etapa(doca, "tank"):
        quit(10)
        return
    tecla(doca, KEY_SPACE)
    await process_frame
    await process_frame
    if not etapa(doca, "start") or not doca.tutorial_bubble.message.text.contains("Faltam"):
        quit(12)
        return
    tecla(doca, KEY_SPACE)
    await create_timer(6).timeout
    if not etapa(doca, "stop") or not is_equal_approx(doca.current_volume, 100.0) or not is_equal_approx(prazo, doca.time_left):
        quit(11)
        return
    tecla(doca, KEY_SPACE)
    if not root.get_node("GameManager").tutorial_done:
        quit(6)
        return
    print("ENTREGA_OK")
    quit()
