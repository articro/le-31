# LE 31 — patch v12c : panne de courant (blackout) + respiration 3D de l'entité + finitions
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

# ---------------------------------------------------------------- vars
rep("var stair_cd := 0.0",
"""var stair_cd := 0.0
var blackout_t := 0.0
var blackout_cd := 55.0
var blackout_on := false
var ent_breath: AudioStreamPlayer3D = null""")

# ---------------------------------------------------------------- reset à chaque run
rep("""    scare_rect.modulate = Color(1, 1, 1, 1)
    scare_rect.visible = false
    flash_rect.visible = false
    crouch = false""",
"""    scare_rect.modulate = Color(1, 1, 1, 1)
    scare_rect.visible = false
    flash_rect.visible = false
    crouch = false
    blackout_on = false
    blackout_t = 0.0
    blackout_cd = 55.0""")

# ---------------------------------------------------------------- blackout dans _process
rep("""    if flicker_idx < 0 and rng.randf() < d * 0.06:""",
"""    # v12.1 : PANNE DE COURANT — les lampes s'éteignent quelques secondes (jamais en mode bot/audit)
    if dbg == "" and state == "play":
        if blackout_on:
            blackout_t -= d
            if blackout_t <= 0.0:
                blackout_on = false
                blackout_cd = rng.randf_range(50.0, 95.0)
                for lp5 in lamps:
                    if lp5[3]:
                        lp5[0].visible = true
                        lp5[1].emission_energy = 5.0
                if env != null:
                    env.ambient_light_energy = 0.30
                _toast(tt("blackout_end"), 2.5)
                play("creak", -10.0, 1.4)
        else:
            blackout_cd -= d
            if blackout_cd <= 0.0:
                blackout_on = true
                blackout_t = rng.randf_range(7.0, 12.0)
                for lp6 in lamps:
                    if lp6[3]:
                        lp6[0].visible = false
                        lp6[1].emission_energy = 0.0
                if env != null:
                    env.ambient_light_energy = 0.12
                flicker_idx = -1
                play("sting", -6.0)
                play("wind", -4.0)
                _toast(tt("blackout_on"), 3.5)
                alert_t = maxf(alert_t, 0.6)
    if flicker_idx < 0 and rng.randf() < d * 0.06:""")

# ---------------------------------------------------------------- textes
rep('"crouch_on": "Accroupi : tu fais presque aucun bruit (C pour te relever)",',
"""\"crouch_on\": \"Accroupi : tu fais presque aucun bruit (C pour te relever)\",
        \"blackout_on\": \"PANNE DE COURANT — la maison est noire. Reste à la lampe torche.\",
        \"blackout_end\": \"Le courant revient…\", """)

rep('"crouch_on": "Crouching: you make almost no sound (C to stand up)",',
"""\"crouch_on\": \"Crouching: you make almost no sound (C to stand up)\",
        \"blackout_on\": \"POWER CUT — the house is dark. Stay on your flashlight.\",
        \"blackout_end\": \"The power comes back…\", """)

# ---------------------------------------------------------------- respiration 3D de l'entité
rep("""    var aura := OmniLight3D.new()
    aura.light_color = Color(0.72, 0.68, 0.62)
    aura.light_energy = 0.30
    aura.omni_range = 1.9
    aura.position = Vector3(0, 1.5, 0)
    nd.add_child(aura)
    return nd""",
"""    var aura := OmniLight3D.new()
    aura.light_color = Color(0.72, 0.68, 0.62)
    aura.light_energy = 0.30
    aura.omni_range = 1.9
    aura.position = Vector3(0, 1.5, 0)
    nd.add_child(aura)
    # v12.1 : respiration en 3D — on l'ENTEND respirer avant de la voir (indice de proximité)
    ent_breath = AudioStreamPlayer3D.new()
    ent_breath.stream = load("res://assets/audio/breath.wav")
    ent_breath.volume_db = -22.0
    ent_breath.unit_size = 6.0
    ent_breath.max_distance = 16.0
    ent_breath.position = Vector3(0, 1.9, 0)
    nd.add_child(ent_breath)
    return nd""")

# pilotage de la respiration dans la boucle entité
rep("""        entity.position.y = lerpf(entity.position.y, _terrain_y(Vector2(entity.position.x, entity.position.z), ent_level), minf(1.0, 7.0 * d))""",
"""        if ent_breath != null and is_instance_valid(ent_breath):
            if not ent_breath.playing:
                ent_breath.play()
            ent_breath.volume_db = (-9.0 if entity_mode == 2 else (-16.0 if entity_mode == 1 else -22.0))
            ent_breath.pitch_scale = 1.30 if entity_mode == 2 else (1.12 if entity_mode == 1 else 1.0)
        entity.position.y = lerpf(entity.position.y, _terrain_y(Vector2(entity.position.x, entity.position.z), ent_level), minf(1.0, 7.0 * d))""")

# si l'entité disparaît, plus de souffle (respawn)
rep("""        if entity != null and is_instance_valid(entity):
            entity.queue_free()
        entity = null
        _spawn_chaser()""",
"""        if entity != null and is_instance_valid(entity):
            if ent_breath != null and is_instance_valid(ent_breath):
                ent_breath.stop()
            entity.queue_free()
        entity = null
        ent_breath = null
        _spawn_chaser()""")

assert src != orig
io.open(P, "w", encoding="utf-8").write(src)
print("PATCH v12c OK — lignes:", len(src.split("\n")), "(avant", len(orig.split("\n")), ")")
