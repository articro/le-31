# LE 31 — patch v12a : flèche supprimée · lampe dosée · escalier débloqué (volée reculée + déclencheurs larges) · maison élargie (couloir 2,4 → 4,0 m)
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

# =====================================================================
# 1) FLÈCHE AU SOL : suppression totale (création + suivi) et textes
# =====================================================================
rep("""    ma.emission_energy = 1.2
    ma.cull_mode = StandardMaterial3D.CULL_DISABLED
    ghost_arrow = _quad(Vector2(0.8, 0.8), ma)
    dyn.add_child(ghost_arrow)""",
"""    ma.cull_mode = StandardMaterial3D.CULL_DISABLED
    # v12 : la flèche qui suivait le joueur est SUPPRIMÉE (demande utilisateur)
    ghost_arrow = null""")

rep("""    if ghost_arrow != null and is_instance_valid(ghost_arrow):
        ghost_arrow.visible = hud_on
        var dirv := (exit_pos - p2z).normalized()
        var gp := p2z + dirv * 1.7
        var d_exit := (exit_pos - p2z).length()
        ghost_arrow.position = Vector3(gp.x, 0.025, gp.y)
        ghost_arrow.rotation = Vector3(0.0, atan2(dirv.x, dirv.y), 0.0)
        ghost_arrow.material_override.emission_energy = (0.75 + sin(run_time * 4.0) * 0.2) * clampf(d_exit / 4.0, 0.0, 1.0)""",
"""    pass  # v12 : plus de flèche au sol""")

# plus de toast "suis la flèche"
rep("""    if not f_arrow:
        f_arrow = true
        _toast(tt("toast_arrow"), 7.0)""",
"""    if not f_arrow:
        f_arrow = true
        _toast(tt("toast_arrow"), 7.0)  # v12 : rappel clé dorée, plus de flèche""")

rep('"toast_arrow": "Suis la flèche orange au sol : elle montre le chemin (1er tour uniquement).",',
    '"toast_arrow": "Trouve la clé dorée : elle brille quelque part dans la maison.",')
rep('"toast_arrow": "Follow the orange arrow on the floor: it shows the way (first lap only).",',
    '"toast_arrow": "Find the golden key: it glows somewhere in the house.",')
rep('"obj_short": "suis la flèche au sol vers la porte EST · sortie VERROUILLÉE : trouve la clé dorée · marche doucement · E = bonbon · F = piège collant",',
    '"obj_short": "porte EST VERROUILLÉE : trouve la clé dorée · marche doucement · C = s\'accroupir · E = bonbon · F = piège collant",')
rep('"obj_short": "nothing changed → walk through · changed → turn back · 5 → exit",',
    '"obj_short": "EAST door LOCKED: find the golden key · walk softly · C = crouch · E = candy · F = sticky trap",')

# =====================================================================
# 2) LAMPE TORCHE : moins puissante (demande utilisateur)
# =====================================================================
rep("""    headlamp.light_color = Color(1.0, 0.86, 0.66)
    headlamp.light_energy = 9.0
    headlamp.spot_range = 18.0
    headlamp.spot_angle = 50.0""",
"""    headlamp.light_color = Color(1.0, 0.88, 0.70)
    headlamp.light_energy = 4.6      # v12 : 9.0 -> 4.6 (trop puissante)
    headlamp.spot_range = 13.0       # v12 : 18 -> 13 (elle portait trop loin)
    headlamp.spot_angle = 42.0       # v12 : 50 -> 42 (faisceau plus serré)""")
rep("    dust.amount = 90", "    dust.amount = 55")

# =====================================================================
# 3) ESCALIER : volée reculée de 1,2 m (base enfin accessible) + déclencheurs
#    larges et sans condition de direction (cause du blocage in-game)
# =====================================================================
rep("        var scz := 13.6 - st * 0.2146", "        var scz := 12.4 - st * 0.2146")
rep("""    var ramp := _box(Vector3(1.2, 0.16, ramp_len), woodm)
    ramp.position = Vector3(1.5, 1.49, 11.12)""",
"""    var ramp := _box(Vector3(1.2, 0.16, ramp_len), woodm)
    ramp.position = Vector3(1.5, 1.49, 9.92)""")
rep("""        rail.position = Vector3(rx, 1.49 + 0.42, 11.12)""",
    """        rail.position = Vector3(rx, 1.49 + 0.42, 9.92)""")
# trémie du plafond reculée d'autant
rep("""    for sp in [Vector3(0.4, 2.9, 7.0), Vector3(11.1, 2.9, 7.0), Vector3(1.5, 2.9, 4.15), Vector3(1.5, 2.9, 11.6)]:""",
    """    for sp in [Vector3(0.4, 2.9, 7.0), Vector3(11.1, 2.9, 7.0), Vector3(1.5, 2.9, 3.45), Vector3(1.5, 2.9, 11.05)]:""")
rep("""        var sd2 := 14.0 if sp.z == 7.0 else (8.3 if sp.z < 7 else 4.8)""",
    """        var sd2 := 14.0 if sp.z == 7.0 else (6.9 if sp.z < 7 else 5.9)""")
# terrain quantifié (bots/entité)
rep("""        var idx := int(floor((13.7 - p.y) / 0.2146))""",
    """        var idx := int(floor((12.4 - p.y) / 0.2146))""")
rep("const RAMP_RECT := [Vector2(0.9, 8.5), Vector2(2.1, 13.7)]",
    "const RAMP_RECT := [Vector2(0.9, 7.4), Vector2(2.1, 12.5)]")
# nœuds IA : pied de rampe reculé, palier haut ajusté
rep("Vector2(1.5, 13.2)]", "Vector2(1.5, 12.9)]")
rep("Vector2(1.5, 7.6)", "Vector2(1.5, 7.5)", 2)
# déclencheurs : zones larges, sans mv, avec cooldown anti-rebond
rep("""    if stair_t < 0.0:
        if pp2.x > 0.9 and pp2.x < 2.1 and pp2.y > 13.1 and pp2.y < 13.85 and mv.z < -0.1 and player.position.y < 1.0:
            stair_t = 0.0
            stair_dir = 1
        elif pp2.x > 0.9 and pp2.x < 2.1 and pp2.y > 8.35 and pp2.y < 9.1 and mv.z > 0.1 and player.position.y > 2.0:
            stair_t = 1.0
            stair_dir = -1""",
"""    stair_cd = maxf(0.0, stair_cd - d)
    if stair_t < 0.0 and stair_cd <= 0.0:
        # v12 : zones larges + AUCUNE condition de direction (l'ancienne exigeait mv.z et la base
        # de la volée était collée au mur sud -> escalier impossible à déclencher en jeu)
        if pp2.x > 0.65 and pp2.x < 2.4 and pp2.y > 12.4 and pp2.y < 13.95 and player.position.y < 1.0:
            stair_t = 0.0
            stair_dir = 1
            _toast("ESCALIER → ÉTAGE (2,5 s)", 2.0)
        elif pp2.x > 0.65 and pp2.x < 2.4 and pp2.y > 6.6 and pp2.y < 8.3 and player.position.y > 2.0:
            stair_t = 1.0
            stair_dir = -1
            _toast("ESCALIER → REZ-DE-CHAUSSÉE (2,5 s)", 2.0)""")
rep("""        if (ascend and stair_t >= 1.0) or (not ascend and stair_t <= 0.0):
            stair_t = -1.0""",
"""        if (ascend and stair_t >= 1.0) or (not ascend and stair_t <= 0.0):
            stair_t = -1.0
            stair_cd = 1.0""")
rep("        player.position = Vector3(1.5, t * 2.98, lerpf(13.55, 8.55, t))",
    "        player.position = Vector3(1.5, t * 2.98, lerpf(12.45, 7.5, t))")
rep("var stair_t := -1.0", "var stair_t := -1.0\nvar stair_cd := 0.0")

# =====================================================================
# 4) MAISON ÉLARGIE : couloir z 5,8-8,2 (2,4 m) -> z 5,0-9,0 (4,0 m)
# =====================================================================
# sols
rep("    _room_floor(0, 5.8, 20, 8.2, fw)", "    _room_floor(0, 5.0, 20, 9.0, fw)")
rep("    _room_floor(0, 0, 7, 5.8, fw)", "    _room_floor(0, 0, 7, 5.0, fw)")
rep("    _room_floor(7, 0, 13, 5.8, tilem)", "    _room_floor(7, 0, 13, 5.0, tilem)")
rep("    _room_floor(13, 0, 20, 5.8, tilem)", "    _room_floor(13, 0, 20, 5.0, tilem)")
rep("    _room_floor(0, 8.2, 6, 14, tilem)", "    _room_floor(0, 9.0, 6, 14, tilem)")
rep("    _room_floor(6, 8.2, 10, 14, fw)", "    _room_floor(6, 9.0, 10, 14, fw)")
rep("    _room_floor(10, 8.2, 15, 14, fw)", "    _room_floor(10, 9.0, 15, 14, fw)")
rep("    _room_floor(15, 8.2, 20, 14, fw)", "    _room_floor(15, 9.0, 20, 14, fw)")
# murs nord (5,8 -> 5,0)
rep("""    # mur nord intérieur z=5.8 (3 portes larges 1.6 m)
    _wall_seg(0, 5.8, 2.75, 5.8)
    _wall_seg(4.35, 5.8, 9.25, 5.8)
    _wall_seg(10.85, 5.8, 15.75, 5.8)
    _wall_seg(17.35, 5.8, 20, 5.8)""",
"""    # mur nord intérieur z=5.0 (3 portes larges 1.6 m)
    _wall_seg(0, 5.0, 2.75, 5.0)
    _wall_seg(4.35, 5.0, 9.25, 5.0)
    _wall_seg(10.85, 5.0, 15.75, 5.0)
    _wall_seg(17.35, 5.0, 20, 5.0)""")
# murs sud (8,2 -> 9,0)
rep("""    # mur sud intérieur z=8.2 (4 portes larges 1.6 m)
    _wall_seg(0, 8.2, 2.25, 8.2)
    _wall_seg(3.85, 8.2, 7.25, 8.2)
    _wall_seg(8.85, 8.2, 11.75, 8.2)
    _wall_seg(13.35, 8.2, 16.75, 8.2)
    _wall_seg(18.35, 8.2, 20, 8.2)""",
"""    # mur sud intérieur z=9.0 (4 portes larges 1.6 m)
    _wall_seg(0, 9.0, 2.25, 9.0)
    _wall_seg(3.85, 9.0, 7.25, 9.0)
    _wall_seg(8.85, 9.0, 11.75, 9.0)
    _wall_seg(13.35, 9.0, 16.75, 9.0)
    _wall_seg(18.35, 9.0, 20, 9.0)""")
# piliers
rep("Vector2(0, 5.8), Vector2(20, 5.8), Vector2(0, 8.2), Vector2(20, 8.2),",
    "Vector2(0, 5.0), Vector2(20, 5.0), Vector2(0, 9.0), Vector2(20, 9.0),")
rep("Vector2(7, 5.8), Vector2(13, 5.8),", "Vector2(7, 5.0), Vector2(13, 5.0),")
rep("Vector2(6, 8.2), Vector2(10, 8.2), Vector2(15, 8.2)]", "Vector2(6, 9.0), Vector2(10, 9.0), Vector2(15, 9.0)]")
# cloisons verticales
rep("    _wall_seg(7, 0, 7, 5.8)", "    _wall_seg(7, 0, 7, 5.0)")
rep("    _wall_seg(13, 0, 13, 5.8)", "    _wall_seg(13, 0, 13, 5.0)")
rep("    _wall_seg(6, 8.2, 6, 14)", "    _wall_seg(6, 9.0, 6, 14)")
rep("    _wall_seg(10, 8.2, 10, 14)", "    _wall_seg(10, 9.0, 10, 14)")
rep("    _wall_seg(15, 8.2, 15, 14)", "    _wall_seg(15, 9.0, 15, 14)")
# portes
rep('    _door_panel(Vector2(3.55, 5.8), 1.0)', '    _door_panel(Vector2(3.55, 5.0), 1.0)')
rep('    _door_panel(Vector2(10.05, 5.8), -1.0)', '    _door_panel(Vector2(10.05, 5.0), -1.0)')
rep('    _door_panel(Vector2(16.55, 5.8), 1.0)', '    _door_panel(Vector2(16.55, 5.0), 1.0)')
rep('    _door_panel(Vector2(3.05, 8.2), -1.0)', '    _door_panel(Vector2(3.05, 9.0), -1.0)')
rep('    _door_panel(Vector2(8.05, 8.2), 1.0)', '    _door_panel(Vector2(8.05, 9.0), 1.0)')
rep('    _door_panel(Vector2(17.55, 8.2), 1.0)', '    _door_panel(Vector2(17.55, 9.0), 1.0)')
rep("    c1d.position = Vector3(12.55, 1.05, 8.2)", "    c1d.position = Vector3(12.55, 1.05, 9.0)")
rep("    ch1_col.position = Vector3(12.55, 1.05, 8.2)", "    ch1_col.position = Vector3(12.55, 1.05, 9.0)")
rep("    c1k.position = Vector3(13.1, 1.05, 8.27)", "    c1k.position = Vector3(13.1, 1.05, 9.07)")
# waypoints BFS des portes
rep("""        3: return Vector2(3.55, 5.8)
        104: return Vector2(10.05, 5.8)
        205: return Vector2(16.55, 5.8)
        6: return Vector2(3.05, 8.2)
        107: return Vector2(8.05, 8.2)
        108: return Vector2(12.55, 8.2)
        209: return Vector2(17.55, 8.2)""",
"""        3: return Vector2(3.55, 5.0)
        104: return Vector2(10.05, 5.0)
        205: return Vector2(16.55, 5.0)
        6: return Vector2(3.05, 9.0)
        107: return Vector2(8.05, 9.0)
        108: return Vector2(12.55, 9.0)
        209: return Vector2(17.55, 9.0)""")
# affiches sur les murs du couloir
rep("for pp in [[Vector2(5.0, 5.75), 0], [Vector2(14.0, 8.25), PI], [Vector2(9.95, 0.05), 0]]:",
    "for pp in [[Vector2(5.0, 4.93), 0], [Vector2(14.0, 9.07), PI], [Vector2(9.95, 0.05), 0]]:")
# meubles qui dépassaient dans les nouveaux emplacements de murs
rep("    _furn(Vector3(2.2, 0.8, 0.9), Vector3(2.0, 0.4, 4.6), cloth)", "    _furn(Vector3(2.2, 0.8, 0.9), Vector3(2.0, 0.4, 4.3), cloth)")
rep("dyn.add_child(_make_pumpkin(Vector3(11.2, 0, 9.2), 0.6))", "dyn.add_child(_make_pumpkin(Vector3(11.2, 0, 9.9), 0.6))")
# spots devenus hors-jeu
rep("const KEY_SPOTS_A := [Vector3(16.9, 0, 3.4), Vector3(3.9, 0, 3.4), Vector3(9.8, 0, 8.9), Vector3(15.8, 2.98, 3.0)]",
    "const KEY_SPOTS_A := [Vector3(16.9, 0, 3.4), Vector3(3.9, 0, 3.4), Vector3(9.8, 0, 7.2), Vector3(15.8, 2.98, 3.0)]")
rep("const HIDE_SPOTS := [Vector3(8.0, 0, 12.6), Vector3(15.8, 0, 9.0), Vector3(3.0, 0, 9.0), Vector3(18.8, 2.98, 2.2)]",
    "const HIDE_SPOTS := [Vector3(8.0, 0, 12.6), Vector3(15.8, 0, 9.7), Vector3(3.0, 0, 9.9), Vector3(18.8, 2.98, 2.2)]")

assert src != orig
io.open(P, "w", encoding="utf-8").write(src)
print("PATCH v12a OK — lignes:", len(src.split("\n")), "(avant", len(orig.split("\n")), ")")
