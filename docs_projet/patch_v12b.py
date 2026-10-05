# LE 31 — patch v12b : screamer (image + secousse + flash + son couché) · monstre détaillé (genoux, chevilles, orteils, côtes, vertèbres, clavicules, cheveux) · accroupissement (C) · 5 notes à collecter
import io

P = "/home/user/hantise/scripts/main.gd"
src = io.open(P, encoding="utf-8").read()
orig = src

def T(s):
    out = []
    for line in s.split("\n"):
        n = len(line) - len(line.lstrip(" "))
        out.append("\t" * (n // 4) + line.lstrip(" "))
    return "\n".join(out)

def rep(old, new, n=1):
    global src
    o, w = T(old), T(new)
    c = src.count(o)
    assert c == n, "MATCH=%d attendu=%d :: %s" % (c, n, o[:80])
    src = src.replace(o, w)

# ============================================================ 1) TEXTES i18n
rep('"toast_arrow": "Trouve la clé dorée : elle brille quelque part dans la maison.",',
"""\"toast_arrow\": \"Trouve la clé dorée : elle brille quelque part dans la maison.\",
        \"crouch_on\": \"Accroupi : tu fais presque aucun bruit (C pour te relever)\",
        \"crouch_off\": \"Debout\",
        \"notes\": \"NOTES %d/5\",
        \"note_1\": \"NOTE 1/5 : « 31 octobre 1997. Elle est revenue. Ne cours pas : elle entend le sol. »\",
        \"note_2\": \"NOTE 2/5 : « Le sucre l'attire. J'en ai collé partout dans la cuisine. »\",
        \"note_3\": \"NOTE 3/5 : « La clé dorée change de place chaque nuit. Je l'ai vue à l'étage. »\",
        \"note_4\": \"NOTE 4/5 : « Si tu l'entends renifler, accroupis-toi. Elle ne voit rien du tout. »\",
        \"note_5\": \"NOTE 5/5 : « Si tu lis ceci, on se retrouve dehors. Cours. »\",""")
rep('"toast_arrow": "Find the golden key: it glows somewhere in the house.",',
"""\"toast_arrow\": \"Find the golden key: it glows somewhere in the house.\",
        \"crouch_on\": \"Crouching: you make almost no sound (C to stand up)\",
        \"crouch_off\": \"Standing\",
        \"notes\": \"NOTES %d/5\",
        \"note_1\": \"NOTE 1/5: \\\"October 31, 1997. She is back. Don't run: she hears the floor.\\\"\",
        \"note_2\": \"NOTE 2/5: \\\"Sugar lures her. I glued it all over the kitchen.\\\"\",
        \"note_3\": \"NOTE 3/5: \\\"The golden key moves every night. I saw it upstairs.\\\"\",
        \"note_4\": \"NOTE 4/5: \\\"If you hear her sniffing, crouch. She sees nothing at all.\\\"\",
        \"note_5\": \"NOTE 5/5: \\\"If you read this, meet me outside. Run.\\\"\",""")

# ============================================================ 2) VARIABLES
rep("var scare_rect: TextureRect",
"""var scare_rect: TextureRect
var flash_rect: ColorRect
var scare_t := 0.0
var crouch := false
var notes_found := 0
var taken_notes := [false, false, false, false, false]
var note_meshes: Array = []""")
rep("const HIDE_SPOTS :=",
"""const NOTE_SPOTS := [Vector3(4.7, 0, 13.3), Vector3(2.2, 0, 2.2), Vector3(11.0, 0, 2.0), Vector3(9.0, 0, 12.6), Vector3(15.6, 2.98, 3.4)]
const HIDE_SPOTS :=""")

# ============================================================ 3) SCREAMER
rep("""    scare_rect = TextureRect.new()
    scare_rect.texture = load("res://assets/tex/face.png")
    scare_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    scare_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    scare_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    scare_rect.visible = false
    scare_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    cl.add_child(scare_rect)""",
"""    scare_rect = TextureRect.new()
    scare_rect.texture = load("res://assets/tex/screamer.png")
    scare_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    scare_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
    scare_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
    scare_rect.visible = false
    scare_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    cl.add_child(scare_rect)
    flash_rect = ColorRect.new()
    flash_rect.color = Color(0.9, 0.06, 0.06, 0.0)
    flash_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
    flash_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
    flash_rect.visible = false
    cl.add_child(flash_rect)""")

rep("""    play("scare", 0.0)
    scare_rect.visible = true""",
"""    play("scare", 3.0)
    play("scare", -1.0, 0.78)
    play("sting", -1.0)
    scare_rect.visible = true
    scare_rect.move_to_front()
    flash_rect.visible = true
    flash_rect.move_to_front()
    scare_t = 0.001
    flash_rect.color = Color(0.95, 0.05, 0.05, 0.55)""")
rep("        tw.tween_interval(0.75)", "        tw.tween_interval(1.6)")
rep("""            scare_rect.visible = false
            end_ctl.visible = true""",
"""            scare_rect.visible = false
            flash_rect.visible = false
            scare_t = 0.0
            end_ctl.visible = true""")
rep("    tw2.tween_interval(0.55)", "    tw2.tween_interval(0.95)")
rep("""        scare_rect.visible = false
        _respawn_at(spawn_pos)""",
"""        scare_rect.visible = false
        flash_rect.visible = false
        scare_rect.position = Vector2.ZERO
        scare_rect.scale = Vector2.ONE
        scare_t = 0.0
        crouch = false
        _respawn_at(spawn_pos)""")

# animation du screamer (secousse + zoom + flash rouge)
rep("    pass  # v12 : plus de flèche au sol",
"""    if scare_t > 0.0:
        scare_t += d
        var sk := clampf(scare_t / 0.6, 0.0, 1.0)
        var amp := 30.0 * (1.0 - sk) + 3.0
        scare_rect.position = Vector2(randf_range(-amp, amp), randf_range(-amp, amp))
        scare_rect.pivot_offset = scare_rect.size * 0.5
        var zk := lerpf(1.3, 1.0, sk)
        scare_rect.scale = Vector2(zk, zk)
        flash_rect.color = Color(0.95, 0.05, 0.05, maxf(0.0, 0.5 - scare_t * 1.5))
        flash_rect.visible = flash_rect.color.a > 0.01
        if scare_t > 1.15:
            scare_t = 0.0
            flash_rect.visible = false""")

# ============================================================ 4) MONSTRE : détails
rep("""        var foot := MeshInstance3D.new()
        var fm2 := BoxMesh.new()
        fm2.size = Vector3(0.085, 0.05, 0.15)
        foot.mesh = fm2
        foot.material_override = skin
        foot.position = Vector3(0, -1.01, -0.06)
        legp.add_child(foot)
        nd.add_child(legp)""",
"""        var knee := MeshInstance3D.new()
        var km2 := SphereMesh.new()
        km2.radius = 0.058
        km2.height = 0.116
        knee.mesh = km2
        knee.material_override = skin
        knee.position = Vector3(0, -0.50, 0.01)
        legp.add_child(knee)
        var ankle := MeshInstance3D.new()
        var am2 := SphereMesh.new()
        am2.radius = 0.038
        am2.height = 0.076
        ankle.mesh = am2
        ankle.material_override = skin
        ankle.position = Vector3(0, -0.965, 0.02)
        legp.add_child(ankle)
        var foot := MeshInstance3D.new()
        var fm2 := BoxMesh.new()
        fm2.size = Vector3(0.075, 0.045, 0.12)
        foot.mesh = fm2
        foot.material_override = skin
        foot.position = Vector3(0, -1.012, -0.045)
        legp.add_child(foot)
        for tz in range(4):
            var toe := MeshInstance3D.new()
            var tzm := CapsuleMesh.new()
            tzm.radius = 0.011
            tzm.height = 0.055
            toe.mesh = tzm
            toe.material_override = skin
            toe.position = Vector3(-0.024 + tz * 0.016, -1.03, -0.112)
            toe.rotation.x = PI / 2
            legp.add_child(toe)
        nd.add_child(legp)""")

rep("""    hump.scale = Vector3(1.15, 0.85, 1.0)
    hump.position = Vector3(0, 1.88, 0.11)
    nd.add_child(hump)""",
"""    hump.scale = Vector3(1.15, 0.85, 1.0)
    hump.position = Vector3(0, 1.88, 0.11)
    nd.add_child(hump)
    for rb in range(5):
        var rib := MeshInstance3D.new()
        var rbm := CapsuleMesh.new()
        rbm.radius = 0.016
        rbm.height = 0.30 - rb * 0.02
        rib.mesh = rbm
        rib.material_override = skin
        rib.position = Vector3(0, 1.60 + rb * 0.085, -0.125 + rb * 0.012)
        rib.rotation = Vector3(PI / 2, 0, 0)
        rib.scale = Vector3(1.0, 1.0, 0.55)
        nd.add_child(rib)
    for sk2 in range(6):
        var spin := MeshInstance3D.new()
        var skm := SphereMesh.new()
        skm.radius = 0.022
        skm.height = 0.044
        spin.mesh = skm
        spin.material_override = skin
        spin.position = Vector3(0, 1.50 + sk2 * 0.10, 0.105 + sk2 * 0.008)
        nd.add_child(spin)
    for cb in [-1.0, 1.0]:
        var clb := MeshInstance3D.new()
        var clm := CapsuleMesh.new()
        clm.radius = 0.016
        clm.height = 0.22
        clb.mesh = clm
        clb.material_override = skin
        clb.position = Vector3(cb * 0.13, 1.90, -0.06)
        clb.rotation = Vector3(0, 0, PI / 2 - cb * 0.35)
        nd.add_child(clb)
        var tendon := MeshInstance3D.new()
        var tdm := CapsuleMesh.new()
        tdm.radius = 0.015
        tdm.height = 0.16
        tendon.mesh = tdm
        tendon.material_override = skin
        tendon.position = Vector3(cb * 0.05, 2.02, -0.03)
        tendon.rotation = Vector3(0.1, 0, cb * 0.18)
        nd.add_child(tendon)""")

rep("""    skull.scale = Vector3(0.95, 1.05, 1.05)
    head.add_child(skull)""",
"""    skull.scale = Vector3(0.95, 1.05, 1.05)
    head.add_child(skull)
    for hx in range(7):
        var hair := MeshInstance3D.new()
        var hm2 := BoxMesh.new()
        hm2.size = Vector3(0.008, 0.10 + 0.05 * float(hx % 3), 0.008)
        hair.mesh = hm2
        hair.material_override = bone
        hair.position = Vector3(-0.055 + hx * 0.018, 0.155, -0.03 + 0.012 * float(hx % 2))
        hair.rotation = Vector3(-0.25 - 0.1 * float(hx % 2), 0, 0.1 * float(hx % 3 - 1))
        head.add_child(hair)""")

# ============================================================ 5) ACCROUPI (C)
rep("""            if ev.keycode == KEY_G:""",
"""            if ev.keycode == KEY_C:
                crouch = not crouch
                _toast(tt("crouch_on") if crouch else tt("crouch_off"), 1.8)
            if ev.keycode == KEY_G:""")
rep("    var want_sprint := Input.is_key_pressed(KEY_SHIFT) and stamina > 0.05",
    "    var want_sprint := Input.is_key_pressed(KEY_SHIFT) and stamina > 0.05 and not crouch")
rep("        mv = mv.normalized() * (5.6 if want_sprint else 3.4)",
    "        mv = mv.normalized() * (1.7 if crouch else (5.6 if want_sprint else 3.4))")
rep("""            play("step", -12.0, randf_range(0.9, 1.1))""",
    """            play("step", -19.0 if crouch else -12.0, randf_range(0.9, 1.1))""")
rep("    cam.position = Vector3(0, EYE + sin(bob) * 0.035, 0)",
    "    cam.position = Vector3(0, EYE - (0.42 if crouch else 0.0) + sin(bob) * 0.035, 0)")
rep("""        target_noise = 1.0 if want_sprint else 0.18""",
    """        target_noise = 1.0 if want_sprint else (0.07 if crouch else 0.18)""")

# ============================================================ 6) NOTES (5)
rep("""        candy_meshes.append(cm)""",
"""        candy_meshes.append(cm)
    # v12 : 5 notes à trouver (lore)
    note_meshes.clear()
    var paperm := _simple(Color(0.90, 0.88, 0.80), 0.55)
    for ni in range(NOTE_SPOTS.size()):
        var npp := _box(Vector3(0.24, 0.012, 0.32), paperm)
        npp.position = Vector3(NOTE_SPOTS[ni].x, NOTE_SPOTS[ni].y + 0.02, NOTE_SPOTS[ni].z)
        npp.rotation = Vector3(0, 0.4 * float(ni), 0)
        world.add_child(npp)
        note_meshes.append(npp)""")
rep("""    if key_mesh_e != null and is_instance_valid(key_mesh_e) and key_mesh_e.visible:""",
"""    for ni2 in range(NOTE_SPOTS.size()):
        if taken_notes[ni2]:
            continue
        if absf(player.position.y - NOTE_SPOTS[ni2].y) > 1.4:
            continue
        if Vector2(NOTE_SPOTS[ni2].x, NOTE_SPOTS[ni2].z).distance_to(p2z) < 0.95:
            taken_notes[ni2] = true
            notes_found += 1
            if ni2 < note_meshes.size() and is_instance_valid(note_meshes[ni2]):
                note_meshes[ni2].queue_free()
            play("whisper", -6.0)
            _toast(tt("note_%d" % (ni2 + 1)), 6.5)
            alert_t = maxf(alert_t, 1.0)
    if key_mesh_e != null and is_instance_valid(key_mesh_e) and key_mesh_e.visible:""")
rep("""    hud_lbl.text = tt("progress") % int((exit_pos - Vector2(player.position.x, player.position.z)).length())""",
"""    hud_lbl.text = tt("progress") % int((exit_pos - Vector2(player.position.x, player.position.z)).length()) + "  ·  " + (tt("notes") % notes_found)""")

assert src != orig
io.open(P, "w", encoding="utf-8").write(src)
print("PATCH v12b OK — lignes:", len(src.split("\n")), "(avant", len(orig.split("\n")), ")")
