extends SceneTree

func _initialize() -> void:
    verificar.call_deferred()

func verificar() -> void:
    if change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene")) != OK:
        quit(1)
        return
    await scene_changed
    var doca = current_scene
    if doca.gate != "forecast" or not doca.radar.visible or doca.training:
        quit(2)
        return
    doca.close_gate.pressed.emit()
    await create_timer(2.3).timeout
    if doca.gate != "closed" or doca.weather.shutter < 0.99:
        quit(3)
        return
    await create_timer(4.2).timeout
    if doca.gate != "protected" or doca.dust_zones != 0:
        quit(4)
        return
    var repetir = InputEventKey.new()
    repetir.keycode = KEY_F5
    repetir.pressed = true
    doca._input(repetir)
    await scene_changed
    doca = current_scene
    if not doca.radar.visible or doca.gate != "forecast":
        quit(5)
        return
    doca.allow_landing.pressed.emit()
    await process_frame
    if doca.gate != "exposed" or doca.dust_zones != 7 or doca.weather.shutter > 0.01:
        quit(6)
        return
    print("TEMPESTADE_OK")
    quit()
