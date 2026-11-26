extends SceneTree

func _initialize() -> void:
    validar.call_deferred()

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
    jogador.position = Vector2(280, 456)
    doca.interact()
    await create_timer(1).timeout
    jogador.position = Vector2(610, 444)
    doca.interact()
    if not doca.connected_hose:
        quit(4)
        return
    doca.slider_a.value = 75
    doca._on_pump_pressed()
    await create_timer(6).timeout
    if not is_equal_approx(doca.current_volume, 100.0):
        quit(5)
        return
    doca._on_pump_pressed()
    if not root.get_node("GameManager").tutorial_done:
        quit(6)
        return
    print("ENTREGA_OK")
    quit()
