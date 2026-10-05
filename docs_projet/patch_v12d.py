# LE 31 — patch v12d : monstre « réaliste » étape 1 — peau texturée (albedo+normal+rough), sous-surface, grognement & reniflement 3D
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

# ---------------------------------------------------------------- matériau peau texturé
rep("""    var skin := StandardMaterial3D.new()
    skin.albedo_color = Color(0.56, 0.51, 0.45)
    skin.roughness = 0.62
    skin.rim_enabled = true
    skin.rim = 0.7
    skin.rim_tint = 0.6
    skin.cull_mode = StandardMaterial3D.CULL_DISABLED""",
"""    # v12.2 : peau réaliste = texture cadavérique + normal map + rugosité + sous-surface (SSS)
    var skin := StandardMaterial3D.new()
    skin.albedo_color = Color(0.62, 0.57, 0.52)
    skin.albedo_texture = load("res://assets/tex/skin_albedo.png")
    skin.normal_enabled = true
    skin.normal_texture = load("res://assets/tex/skin_normal.png")
    skin.normal_scale = 0.9
    skin.roughness_texture = load("res://assets/tex/skin_rough.png")
    skin.roughness = 1.0
    skin.uv1_scale = Vector3(2.2, 2.2, 1.0)
    skin.subsurf_scatter_enabled = true
    skin.subsurf_scatter_strength = 0.22
    skin.rim_enabled = true
    skin.rim = 0.7
    skin.rim_tint = 0.6
    skin.cull_mode = StandardMaterial3D.CULL_DISABLED""")

rep("""    var rags := StandardMaterial3D.new()
    rags.albedo_color = Color(0.055, 0.05, 0.065)
    rags.roughness = 0.92
    rags.cull_mode = StandardMaterial3D.CULL_DISABLED""",
"""    var rags := StandardMaterial3D.new()
    rags.albedo_color = Color(0.055, 0.05, 0.065)
    rags.normal_enabled = true
    rags.normal_texture = load("res://assets/tex/skin_normal.png")
    rags.normal_scale = 1.6
    rags.uv1_scale = Vector3(3.4, 3.4, 1.0)
    rags.roughness = 0.94
    rags.cull_mode = StandardMaterial3D.CULL_DISABLED""")

rep("""    var bone := StandardMaterial3D.new()
    bone.albedo_color = Color(0.70, 0.66, 0.58)
    bone.roughness = 0.45""",
"""    var bone := StandardMaterial3D.new()
    bone.albedo_color = Color(0.70, 0.66, 0.58)
    bone.roughness = 0.45
    bone.normal_enabled = true
    bone.normal_texture = load("res://assets/tex/skin_normal.png")
    bone.normal_scale = 0.5
    bone.uv1_scale = Vector3(4.0, 4.0, 1.0)""")

# ---------------------------------------------------------------- timers + joueurs 3D (growl / sniff)
rep("""var ent_breath: AudioStreamPlayer3D = null""",
"""var ent_breath: AudioStreamPlayer3D = null
var ent_growl: AudioStreamPlayer3D = null
var ent_sniff: AudioStreamPlayer3D = null
var growl_t := 1.5
var sniff_t := 2.0""")

rep("""    ent_breath = AudioStreamPlayer3D.new()
    ent_breath.stream = load("res://assets/audio/breath.wav")
    ent_breath.volume_db = -22.0
    ent_breath.unit_size = 6.0
    ent_breath.max_distance = 16.0
    ent_breath.position = Vector3(0, 1.9, 0)
    nd.add_child(ent_breath)
    return nd""",
"""    ent_breath = AudioStreamPlayer3D.new()
    ent_breath.stream = load("res://assets/audio/breath.wav")
    ent_breath.volume_db = -22.0
    ent_breath.unit_size = 6.0
    ent_breath.max_distance = 16.0
    ent_breath.position = Vector3(0, 1.9, 0)
    nd.add_child(ent_breath)
    # v12.2 : grognement (chasse) et reniflement (proximité) — on la PISTE au son
    ent_growl = AudioStreamPlayer3D.new()
    ent_growl.stream = load("res://assets/audio/growl.wav")
    ent_growl.volume_db = -8.0
    ent_growl.unit_size = 9.0
    ent_growl.max_distance = 26.0
    ent_growl.position = Vector3(0, 1.7, 0)
    nd.add_child(ent_growl)
    ent_sniff = AudioStreamPlayer3D.new()
    ent_sniff.stream = load("res://assets/audio/sniff.wav")
    ent_sniff.volume_db = -10.0
    ent_sniff.unit_size = 5.0
    ent_sniff.max_distance = 14.0
    ent_sniff.position = Vector3(0, 1.9, -0.2)
    nd.add_child(ent_sniff)
    return nd""")

# ---------------------------------------------------------------- pilotage dans la boucle de l'entité
rep("""        if ent_breath != null and is_instance_valid(ent_breath):
            if not ent_breath.playing:
                ent_breath.play()
            ent_breath.volume_db = (-9.0 if entity_mode == 2 else (-16.0 if entity_mode == 1 else -22.0))
            ent_breath.pitch_scale = 1.30 if entity_mode == 2 else (1.12 if entity_mode == 1 else 1.0)""",
"""        if ent_breath != null and is_instance_valid(ent_breath):
            if not ent_breath.playing:
                ent_breath.play()
            ent_breath.volume_db = (-9.0 if entity_mode == 2 else (-16.0 if entity_mode == 1 else -22.0))
            ent_breath.pitch_scale = 1.30 if entity_mode == 2 else (1.12 if entity_mode == 1 else 1.0)
        var dend := Vector2(entity.position.x, entity.position.z).distance_to(p2z)
        if ent_growl != null and is_instance_valid(ent_growl):
            if entity_mode == 2:
                growl_t -= d
                if growl_t <= 0.0 and not ent_growl.playing:
                    ent_growl.play()
                    growl_t = rng.randf_range(3.2, 6.0)
            else:
                growl_t = minf(growl_t, 0.8)
        if ent_sniff != null and is_instance_valid(ent_sniff) and dend < 5.5 and entity_mode >= 1:
            sniff_t -= d
            if sniff_t <= 0.0 and not ent_sniff.playing:
                ent_sniff.play()
                sniff_t = rng.randf_range(2.4, 5.5)
        else:
            sniff_t = minf(sniff_t, 1.6)""")

# ---------------------------------------------------------------- respawn : couper les nouveaux sons
rep("""        if entity != null and is_instance_valid(entity):
            if ent_breath != null and is_instance_valid(ent_breath):
                ent_breath.stop()
            entity.queue_free()
        entity = null
        ent_breath = null
        _spawn_chaser()""",
"""        if entity != null and is_instance_valid(entity):
            for pp3 in [ent_breath, ent_growl, ent_sniff]:
                if pp3 != null and is_instance_valid(pp3):
                    pp3.stop()
            entity.queue_free()
        entity = null
        ent_breath = null
        ent_growl = null
        ent_sniff = null
        growl_t = 1.5
        sniff_t = 2.0
        _spawn_chaser()""")

assert src != orig
io.open(P, "w", encoding="utf-8").write(src)
print("PATCH v12d OK — lignes:", len(src.split("\n")), "(avant", len(orig.split("\n")), ")")
