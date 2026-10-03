# =============================================================
#  LE 31 — boucle d'anomalies Halloween
#  Rendu Forward+ : PBR 2K, brouillard volumétrique, SDFGI, glow
#  Sortie cible : avant le 31 octobre 2026
# =============================================================
extends Node3D

# ---------------------------------------------------------------- const ----
const GOAL := 5
const CORR_HALF := 1.35
const EYE := 1.62
const PTS := [Vector2(0, 0), Vector2(12, 0), Vector2(12, 7), Vector2(0, 7)]
var SEG_LEN := []
var PERIM := 0.0

# ---------------------------------------------------------------- i18n ----
var lang := "fr"
const TR := {
	"fr": {
		"title": "LE 31",
		"sub": "une boucle d'Halloween",
		"play": "ENTRER",
		"warn": "casque recommandé — ne joue pas dans le noir… ou si.",
		"controls": "ZQSD / WASD / flèches : marcher · MAJ : courir (endurance !) · SOURIS : regarder · G : lampe torche · E : lancer un bonbon · V : grain VHS · ÉCHAP : pause",
		"rules_tip": "Lis la pancarte. Obéis.",
		"exit_lbl": "SORTIE",
		"progress": "SORTIE : %d/%d",
		"win": "TU ES SORTI·E",
		"win_sub": "La maison te laissera partir… cette fois.",
		"dead": "RATTRAPÉ·E",
		"dead_sub": "Il fallait répondre. Ou fuir plus vite.",
		"replay": "REJOUER",
		"loops": "boucles : %d   erreurs : %d",
		"hint_run": "COURS. RETOURNE AU DÉPART.",
		"intro1": "31 octobre 1997.",
		"intro2": "La maison des Harper devait être vide.",
		"intro3": "Elle ne l'est pas.",
		"skip": "CLIC ou ESPACE pour entrer",
		"pause_t": "PAUSE",
		"resume": "REPRENDRE",
		"restart": "RECOMMENCER",
		"title_btn": "TITRE",
		"credit": "…il a gardé ton bonbon.",
		"menu_play": "JOUER",
		"menu_how": "COMMENT JOUER",
		"menu_opt": "OPTIONS",
		"menu_quit": "QUITTER",
		"how_title": "COMMENT JOUER",
		"how_1": "1. Le couloir boucle. Le traverser entièrement = +1 vers la sortie (5 nécessaires).",
		"how_2": "2. À chaque tour, quelque chose PEUT changer : affiche, lumière, silhouette, porte, pancarte, son…",
		"how_3": "3. Quelque chose a changé ? Fais DEMI-TOUR jusqu'au départ. Rien changé ? Traverse.",
		"how_4": "4. Te tromper remet le compteur à zéro. 3 erreurs = IL se met à courir.",
		"how_5": "5. 5 tours propres : la porte SORTIE s'ouvre. Entre.",
		"obj_banner": "BUT : traverse si rien n'a changé · demi-tour si changé · 5 tours = sortie",
		"hint_move": "ZQSD / WASD + SOURIS pour regarder · MAJ pour courir",
		"toast_plus1": "BIEN. Rien n'avait changé. +1",
		"toast_seen": "BIEN VU. Quelque chose avait changé.",
		"toast_miss_change": "RATÉ : quelque chose AVAIT changé. Compteur à zéro.",
		"toast_miss_nothing": "RATÉ : rien n'avait changé, il fallait traverser. Compteur à zéro.",
		"banner_first_anom": "OBSERVE… si quelque chose a changé : DEMI-TOUR.",
		"banner_exit": "LA SORTIE EST OUVERTE. TROUVE-LA.",
		"toast_reveal": "C'ÉTAIT : %s",
		"an_poster": "une affiche changée",
		"an_pumpkin": "une citrouille apparue",
		"an_light": "une lampe morte",
		"an_figure": "une silhouette immobile",
		"an_rules": "la pancarte modifiée",
		"an_door": "une porte ouverte",
		"an_whisper": "des chuchotements",
		"an_stain": "une tache au sol",
		"an_flip": "une affiche retournée",
		"an_flicker": "une lampe qui grésille",
		"an_cross": "une silhouette qui traverse",
		"an_extradoor": "une porte en plus",
		"an_chase": "LUI",
		"cap_whisper": "[chuchotements]",
		"cap_creak": "[grincement]",
		"cap_heart": "[ton cœur]",
		"cap_sting": "[un cri étouffé]",
		"opt_title": "OPTIONS",
		"opt_master": "Volume général",
		"opt_music": "Ambiance / musique",
		"opt_sfx": "Effets sonores",
		"opt_sens": "Sensibilité souris",
		"opt_qual": "Qualité haute",
		"opt_vhs": "Grain VHS",
		"opt_back": "RETOUR",
		"back": "RETOUR",
		"toast_arrow": "Suis la flèche orange au sol : elle montre le chemin (1er tour uniquement).",
		"obj_short": "rien changé → traverse · changé → demi-tour · 5 → sortie",
		"how_go": "C'EST PARTI",
		"candy_title": "BONBON MAUDIT GAGNÉ — choisis : ",
		"candy_got": "Tu gardes : %s",
		"candy_throw": "Bonbon lancé ! IL s'arrête…",
		"pocket": "bonbons : %d",
		"cd_miroir_n": "Miroir",
		"cd_miroir_d": "un murmure te prévient si quelque chose a changé",
		"cd_reglisse_n": "Réglisse",
		"cd_reglisse_d": "IL court moins vite pendant la poursuite",
		"cd_caramel_n": "Caramel",
		"cd_caramel_d": "une erreur de plus avant qu'IL ne coure",
		"cd_sucre_n": "Sucre d'orge",
		"cd_sucre_d": "ton endurance fond deux fois moins vite",
	},
	"en": {
		"title": "OCT 31",
		"sub": "a Halloween loop",
		"play": "ENTER",
		"warn": "headphones recommended — don't play in the dark… actually, do.",
		"controls": "WASD / ZQSD / arrows: walk · SHIFT: run (stamina!) · MOUSE: look · G: flashlight · E: throw candy · V: VHS grain · ESC: pause",
		"rules_tip": "Read the sign. Obey.",
		"exit_lbl": "EXIT",
		"progress": "EXIT: %d/%d",
		"win": "YOU GOT OUT",
		"win_sub": "The house lets you leave… this time.",
		"dead": "CAUGHT",
		"dead_sub": "You should have answered. Or run faster.",
		"replay": "REPLAY",
		"loops": "loops: %d   mistakes: %d",
		"hint_run": "RUN. GET BACK TO THE START.",
		"intro1": "October 31, 1997.",
		"intro2": "The Harper house was supposed to be empty.",
		"intro3": "It isn't.",
		"skip": "CLICK or SPACE to enter",
		"pause_t": "PAUSED",
		"resume": "RESUME",
		"restart": "RESTART",
		"title_btn": "TITLE",
		"credit": "…he kept your candy.",
		"menu_play": "PLAY",
		"menu_how": "HOW TO PLAY",
		"menu_opt": "OPTIONS",
		"menu_quit": "QUIT",
		"how_title": "HOW TO PLAY",
		"how_1": "1. The hallway loops. Walking it fully = +1 toward the exit (5 needed).",
		"how_2": "2. Each lap, something MAY change: poster, light, silhouette, door, sign, sound…",
		"how_3": "3. Something changed? TURN BACK to the start. Nothing changed? Walk through.",
		"how_4": "4. Getting it wrong resets the counter. 3 mistakes = IT starts running.",
		"how_5": "5. 5 clean laps: the EXIT door opens. Enter it.",
		"obj_banner": "GOAL: walk through if nothing changed · turn back if something did · 5 laps = exit",
		"hint_move": "WASD / ZQSD + MOUSE to look · SHIFT to run",
		"toast_plus1": "GOOD. Nothing had changed. +1",
		"toast_seen": "WELL SPOTTED. Something had changed.",
		"toast_miss_change": "MISSED: something HAD changed. Counter reset.",
		"toast_miss_nothing": "MISSED: nothing had changed, you had to walk through. Counter reset.",
		"banner_first_anom": "WATCH… if something changed: TURN BACK.",
		"banner_exit": "THE EXIT IS OPEN. FIND IT.",
		"toast_reveal": "IT WAS: %s",
		"an_poster": "a changed poster",
		"an_pumpkin": "an appeared pumpkin",
		"an_light": "a dead lamp",
		"an_figure": "a standing silhouette",
		"an_rules": "the altered sign",
		"an_door": "an open door",
		"an_whisper": "whispers",
		"an_stain": "a floor stain",
		"an_flip": "an upside-down poster",
		"an_flicker": "a flickering lamp",
		"an_cross": "a crossing silhouette",
		"an_extradoor": "an extra door",
		"an_chase": "HIM",
		"cap_whisper": "[whispers]",
		"cap_creak": "[creaking]",
		"cap_heart": "[your heart]",
		"cap_sting": "[a muffled cry]",
		"opt_title": "OPTIONS",
		"opt_master": "Master volume",
		"opt_music": "Ambience / music",
		"opt_sfx": "Sound effects",
		"opt_sens": "Mouse sensitivity",
		"opt_qual": "High quality",
		"opt_vhs": "VHS grain",
		"opt_back": "BACK",
		"back": "BACK",
		"toast_arrow": "Follow the orange arrow on the floor: it shows the way (first lap only).",
		"obj_short": "nothing changed → walk through · changed → turn back · 5 → exit",
		"how_go": "LET'S GO",
		"candy_title": "CURSED CANDY EARNED — pick: ",
		"candy_got": "You keep: %s",
		"candy_throw": "Candy thrown! IT stops…",
		"pocket": "candies: %d",
		"cd_miroir_n": "Mirror",
		"cd_miroir_d": "a whisper warns you when something changed",
		"cd_reglisse_n": "Licorice",
		"cd_reglisse_d": "IT runs slower during the chase",
		"cd_caramel_n": "Caramel",
		"cd_caramel_d": "one extra mistake before IT runs",
		"cd_sucre_n": "Candy cane",
		"cd_sucre_d": "your stamina drains twice as slow",
	},
}


func tt(s: String) -> String:
	return TR[lang].get(s, s)


# ---------------------------------------------------------------- nodes ----
var player: Node3D
var cam: Camera3D
var world: Node3D
var dyn: Node3D
var entity: Node3D = null
var exit_door: Node3D = null
var ui: CanvasLayer
var vhs: ColorRect
var fade: ColorRect
var scare_rect: TextureRect
var title_ctl: Control
var end_ctl: Control
var pause_ctl: Control
var intro_ctl: Control
var hud_lbl: Label
var hint_lbl: Label
var ts_lbl: Label
var lamps: Array = []          # [OmniLight3D, bulb_material, fixture_node]
var posters: Array = []        # Node3D
var doors: Array = []          # Node3D
var rules_sign: Node3D = null
var env: Environment = null

# ---------------------------------------------------------------- state ----
var state := "title"
var yaw := 0.0
var pitch := 0.0
var bob := 0.0
var prev_t := 0.0
var far_reached := false
var progress := 0
var mistakes := 0
var loops := 0
var anomaly := ""
var chasing := false
var entity_t := 0.0
var locked := false
var whisper_timer := 0.0
var rng := RandomNumberGenerator.new()
var dbg := ""
var dbg_t := 2.0
var intro_t := 0.0
var run_time := 0.0
var flicker_idx := -1
var cross_state := 0
var cross_lat := 0.0
var audit_i := 0
var audit_timer := 0.0
var quality_high := true
var vhs_visible_pref := true
var vol_master := 0.9
var vol_music := 0.8
var vol_sfx := 0.9
var mouse_sens := 1.0
var howto_ctl: Control = null
var options_ctl: Control = null
var banner_lbl: Label = null
var banner_timer := 0.0
var toast_lbl: Label = null
var toast_timer := 0.0
var cap_lbl: Label = null
var cap_timer := 0.0
var ghost_arrow: MeshInstance3D = null
var hud_on := true
var hud_nodes: Array = []
var f_first_anom := false
var f_exit := false
var anom_timer := 0.0
var title_cam_t := 3.0
var obj_lbl: Label = null
var osd_lbl: Label = null
var how_seen := false
var f_arrow := false
var stamina := 1.0
var breath_timer := 0.0
var stam_bg: ColorRect = null
var stam_fill: ColorRect = null
var hands: Node3D = null
var headlamp: SpotLight3D = null
var headlamp_on := true
var candies := {}
var pocket := 1
var candy_offer := []
var candy_timer := 0.0
var mirror_timer := 0.0
var entity_stun := 0.0
var pocket_lbl: Label = null
var poster_base := "poster_a"
var wind_pl: AudioStreamPlayer = null
var house_pl: AudioStreamPlayer = null
var tension_pl: AudioStreamPlayer = null
const CANDY_IDS := ["miroir", "reglisse", "caramel", "sucre"]
const AUDIT_LIST := ["poster", "pumpkin", "light", "figure", "rules", "door", "whisper", "stain", "flip", "flicker", "cross", "extradoor", "chase"]


func _ready() -> void:
	for a in OS.get_cmdline_args():
		if a.begins_with("--dbg"):
			dbg = a.split("=")[1] if "=" in a else "smart"
	rng.seed = hash("le31") % 99991
	_compute_path()
	_load_settings()
	_build_world()
	_build_player()
	_build_ui()
	_build_vhs()
	_build_reverb()
	state = "title"
	if dbg == "" and not how_seen:
		howto_ctl.visible = true
	if dbg != "":
		_start("fr")
		_begin_run()


# ============================================================ chemin ======
func _compute_path() -> void:
	PERIM = 0.0
	SEG_LEN.clear()
	for i in PTS.size():
		var l: float = (PTS[(i + 1) % PTS.size()] - PTS[i]).length()
		SEG_LEN.append(l)
		PERIM += l


func _t_to_pos(t: float) -> Vector2:
	t = fmod(t, PERIM)
	if t < 0:
		t += PERIM
	for i in PTS.size():
		if t <= SEG_LEN[i]:
			var a: Vector2 = PTS[i]
			var b: Vector2 = PTS[(i + 1) % PTS.size()]
			return a.lerp(b, t / SEG_LEN[i])
		t -= SEG_LEN[i]
	return PTS[0]


func _pos_to_t(p: Vector2) -> float:
	var best := 0.0
	var bd := 1e9
	var acc := 0.0
	for i in PTS.size():
		var a: Vector2 = PTS[i]
		var b: Vector2 = PTS[(i + 1) % PTS.size()]
		var ab := b - a
		var u := clampf((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
		var d := (p - (a + ab * u)).length()
		if d < bd:
			bd = d
			best = acc + u * SEG_LEN[i]
		acc += SEG_LEN[i]
	return best


func _ang_at(t: float) -> float:
	var c := _t_to_pos(t)
	var c2 := _t_to_pos(t + 0.5)
	return atan2(c2.y - c.y, c2.x - c.x)


func _right_at(t: float) -> Vector3:
	var a := _ang_at(t)
	return Vector3(-sin(a), 0, -cos(a))


# ============================================================ matières ====
func _pbr(set_name: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load("res://assets/pbr/%s_albedo.png" % set_name)
	m.normal_enabled = true
	m.normal_texture = load("res://assets/pbr/%s_normal.png" % set_name)
	m.roughness = 1.0
	m.roughness_texture = load("res://assets/pbr/%s_rough.png" % set_name)
	m.ao_enabled = true
	m.ao_texture = load("res://assets/pbr/%s_ao.png" % set_name)
	m.albedo_color = Color(1.6, 1.55, 1.5)
	m.cull_mode = StandardMaterial3D.CULL_DISABLED
	return m


func _simple(col: Color, rough := 0.7, metal := 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = col
	m.roughness = rough
	m.metallic = metal
	m.cull_mode = StandardMaterial3D.CULL_DISABLED
	return m


func _emissive(col: Color, energy := 2.0, tex := "") -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	if tex != "":
		m.albedo_texture = load(tex)
	m.albedo_color = col
	m.emission_enabled = true
	m.emission = col
	m.emission_energy = energy
	if tex != "":
		m.emission_texture = m.albedo_texture
	m.cull_mode = StandardMaterial3D.CULL_DISABLED
	return m


func _pixel(tex: String) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_texture = load(tex)
	m.texture_filter = 1
	m.roughness = 0.85
	m.cull_mode = StandardMaterial3D.CULL_DISABLED
	return m


func _quad(sz: Vector2, m: StandardMaterial3D) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var q := PlaneMesh.new()
	q.size = sz
	mi.mesh = q
	mi.material_override = m
	return mi


func _box(sz: Vector3, m: StandardMaterial3D) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	var b := BoxMesh.new()
	b.size = sz
	mi.mesh = b
	mi.material_override = m
	return mi


# ============================================================ monde =======
func _build_world() -> void:
	world = Node3D.new()
	add_child(world)
	var wood_trim := _simple(Color(0.16, 0.10, 0.07), 0.55)
	var t := 0.0
	while t < PERIM - 0.01:
		var step := minf(2.0, PERIM - t)
		var c := _t_to_pos(t + step / 2.0)
		var ang := _ang_at(t + step / 2.0)
		var pos3 := Vector3(c.x, 0, c.y)
		var right := _right_at(t + step / 2.0)
		var fm := _pbr("floor")
		fm.normal_enabled = false
		var f := _quad(Vector2(step, CORR_HALF * 2 + 0.3), fm)
		f.rotation = Vector3(PI / 2, ang, 0)
		f.position = pos3
		world.add_child(f)
		var ce := _quad(Vector2(step, CORR_HALF * 2 + 0.3), _pbr("ceil"))
		ce.rotation = Vector3(PI / 2, ang, 0)
		ce.position = pos3 + Vector3(0, 2.9, 0)
		world.add_child(ce)
		for s in [-1, 1]:
			var w := _quad(Vector2(step, 2.9), _pbr("wall"))
			w.rotation = Vector3(PI / 2, ang, 0)
			w.position = pos3 + right * (s * (CORR_HALF + 0.15)) + Vector3(0, 1.45, 0)
			world.add_child(w)
			# plinthe
			var bb := _box(Vector3(step, 0.14, 0.04), wood_trim)
			bb.rotation = Vector3(0, -ang, 0)
			bb.position = pos3 + right * (s * (CORR_HALF + 0.12)) + Vector3(0, 0.07, 0)
			world.add_child(bb)
		# poutre de plafond
		var beam := _box(Vector3(0.14, 0.16, CORR_HALF * 2 + 0.3), wood_trim)
		beam.rotation = Vector3(0, -ang, 0)
		beam.position = pos3 + Vector3(0, 2.82, 0)
		world.add_child(beam)
		t += step
	# joints d'angle : scelle les 4 coins (extérieur + intérieur)
	for i in PTS.size():
		var P: Vector2 = PTS[i]
		var Pp: Vector2 = PTS[(i - 1 + PTS.size()) % PTS.size()]
		var Pn: Vector2 = PTS[(i + 1) % PTS.size()]
		var d_in := (P - Pp).normalized()
		var d_out := (Pn - P).normalized()
		var a_in := atan2(d_in.y, d_in.x)
		var a_out := atan2(d_out.y, d_out.x)
		var r_in := Vector3(-d_in.y, 0, -d_in.x)
		var r_out := Vector3(-d_out.y, 0, -d_out.x)
		for sd in [-1, 1]:
			var off: float = sd * (CORR_HALF + 0.16)
			var q1 := _quad(Vector2(1.56, 2.9), _pbr("wall"))
			q1.rotation = Vector3(PI / 2, a_in, 0)
			q1.position = Vector3(P.x, 1.45, P.y) + Vector3(d_in.x, 0, d_in.y) * 0.75 + r_in * off
			world.add_child(q1)
			var q2 := _quad(Vector2(1.56, 2.9), _pbr("wall"))
			q2.rotation = Vector3(PI / 2, a_out, 0)
			q2.position = Vector3(P.x, 1.45, P.y) - Vector3(d_out.x, 0, d_out.y) * 0.75 + r_out * off
			world.add_child(q2)
	# collision réelle : 4 murs extérieurs + bloc intérieur (plus JAMAIS traversable)
	_collider_box(Vector3(17.0, 3.0, 0.6), Vector3(6, 1.5, -1.8))
	_collider_box(Vector3(17.0, 3.0, 0.6), Vector3(6, 1.5, 8.8))
	_collider_box(Vector3(0.6, 3.0, 11.6), Vector3(-1.8, 1.5, 3.5))
	_collider_box(Vector3(0.6, 3.0, 11.6), Vector3(13.8, 1.5, 3.5))
	_collider_box(Vector3(9.0, 3.0, 4.0), Vector3(6, 1.5, 3.5))
	# lampes suspendues tous les 6 m
	t = 3.0
	while t < PERIM:
		var c := _t_to_pos(t)
		world.add_child(_make_lamp(Vector3(c.x, 0, c.y)))
		t += 6.0
	dyn = Node3D.new()
	world.add_child(dyn)
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.006, 0.006, 0.008)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.40, 0.33, 0.30)
	env.ambient_light_energy = 0.55
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.35
	env.glow_enabled = true
	env.glow_intensity = 0.4
	env.glow_bloom = 0.06
	env.sdfgi_enabled = true
	env.volumetric_fog_enabled = true
	env.volumetric_fog_density = 0.016
	env.volumetric_fog_albedo = Color(0.55, 0.45, 0.4)
	env.volumetric_fog_anisotropy = 0.45
	var we := WorldEnvironment.new()
	we.environment = env
	world.add_child(we)


func _collider_box(sz: Vector3, at: Vector3) -> void:
	var b := StaticBody3D.new()
	var c := CollisionShape3D.new()
	var bm: BoxShape3D = BoxShape3D.new()
	bm.size = sz
	c.shape = bm
	b.add_child(c)
	b.position = at
	world.add_child(b)


func _make_lamp(at: Vector3) -> Node3D:
	var n := Node3D.new()
	n.position = at
	var cord := _box(Vector3(0.02, 0.4, 0.02), _simple(Color(0.05, 0.05, 0.05), 0.6))
	cord.position = Vector3(0, 2.7, 0)
	n.add_child(cord)
	var shade := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.10
	cm.bottom_radius = 0.26
	cm.height = 0.20
	shade.mesh = cm
	shade.material_override = _simple(Color(0.10, 0.08, 0.07), 0.4, 0.6)
	shade.position = Vector3(0, 2.44, 0)
	n.add_child(shade)
	var bulb_mat := _emissive(Color(1.0, 0.72, 0.42), 5.0)
	var bulb := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.055
	sm.height = 0.11
	bulb.mesh = sm
	bulb.material_override = bulb_mat
	bulb.position = Vector3(0, 2.36, 0)
	n.add_child(bulb)
	var li := OmniLight3D.new()
	li.light_color = Color(1.0, 0.72, 0.44)
	li.light_energy = 5.2
	li.omni_range = 9.5
	li.shadow_enabled = true
	li.position = Vector3(0, 2.34, 0)
	n.add_child(li)
	lamps.append([li, bulb_mat, n])
	return n


# ============================================================ props 3D ====
func _place_on_wall(nd: Node3D, t: float, side: int, h: float) -> void:
	var c := _t_to_pos(t)
	var ang := _ang_at(t)
	var right := _right_at(t)
	nd.rotation = Vector3(0, -ang + (PI if side < 0 else 0), 0)
	nd.position = Vector3(c.x, h, c.y) + right * (side * (CORR_HALF + 0.12))
	dyn.add_child(nd)


func _make_poster(t: float, side: int) -> Node3D:
	var nd := Node3D.new()
	var frame := _box(Vector3(1.06, 1.56, 0.05), _simple(Color(0.12, 0.08, 0.06), 0.5))
	nd.add_child(frame)
	var q := _quad(Vector2(0.95, 1.42), _pixel("res://assets/tex/%s.png" % poster_base))
	q.position = Vector3(0, 0, 0.035)
	q.rotation = Vector3(0, 0, 0)
	q.name = "Art"
	nd.add_child(q)
	_place_on_wall(nd, t, side, 1.62)
	return nd


func _make_door(t: float, side: int) -> Node3D:
	var nd := Node3D.new()
	var wood := _pbr("door")
	var slab := _box(Vector3(1.02, 2.12, 0.07), wood)
	slab.position = Vector3(0, 0, 0)
	slab.name = "Slab"
	nd.add_child(slab)
	var fr := _simple(Color(0.13, 0.09, 0.06), 0.55)
	for s in [-1, 1]:
		var j := _box(Vector3(0.10, 2.3, 0.10), fr)
		j.position = Vector3(s * 0.56, 0.09, 0)
		nd.add_child(j)
	var top := _box(Vector3(1.22, 0.10, 0.10), fr)
	top.position = Vector3(0, 1.19, 0)
	nd.add_child(top)
	var knob := MeshInstance3D.new()
	var ks := SphereMesh.new()
	ks.radius = 0.045
	ks.height = 0.09
	knob.mesh = ks
	knob.material_override = _simple(Color(0.65, 0.5, 0.2), 0.25, 1.0)
	knob.position = Vector3(0.38, -0.1, 0.06)
	nd.add_child(knob)
	# version ouverte : trou noir + yeux
	var open_n := Node3D.new()
	open_n.name = "Open"
	open_n.visible = false
	var dark := _quad(Vector2(1.02, 2.12), _simple(Color(0.01, 0.01, 0.012), 0.95))
	open_n.add_child(dark)
	for s in [-1, 1]:
		var eye := MeshInstance3D.new()
		var es := SphereMesh.new()
		es.radius = 0.022
		es.height = 0.044
		eye.mesh = es
		eye.material_override = _emissive(Color(0.95, 0.95, 0.88), 2.5)
		eye.position = Vector3(s * 0.09, 0.35, 0.05)
		open_n.add_child(eye)
	nd.add_child(open_n)
	_place_on_wall(nd, t, side, 1.06)
	return nd


func _make_sign(t: float, side: int) -> Node3D:
	var nd := Node3D.new()
	var board := _box(Vector3(1.15, 0.9, 0.05), _simple(Color(0.55, 0.48, 0.36), 0.8))
	nd.add_child(board)
	var q := _quad(Vector2(1.05, 0.8), _pixel("res://assets/tex/rules_%s.png" % lang))
	q.position = Vector3(0, 0, 0.032)
	q.name = "Art"
	nd.add_child(q)
	var fr := _simple(Color(0.13, 0.09, 0.06), 0.55)
	for s in [-1, 1]:
		var j := _box(Vector3(0.06, 1.0, 0.07), fr)
		j.position = Vector3(s * 0.58, 0, 0)
		nd.add_child(j)
	_place_on_wall(nd, t, side, 1.55)
	return nd


func _make_pumpkin(at: Vector3, scale := 1.0) -> Node3D:
	var nd := Node3D.new()
	nd.position = at
	var st := SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	var RINGS := 14
	var SEGS := 20
	var verts := []
	for i in range(RINGS + 1):
		var lat := PI * i / float(RINGS)
		var row := []
		for j in range(SEGS):
			var lon := TAU * j / float(SEGS)
			var r := pow(sin(lat), 0.72) * (0.30 + 0.045 * cos(lon * 8.0)) * scale
			var y := cos(lat) * 0.26 * scale
			row.append(Vector3(cos(lon) * r, y, sin(lon) * r))
		verts.append(row)
	for i in range(RINGS):
		for j in range(SEGS):
			var a: Vector3 = verts[i][j]
			var b: Vector3 = verts[i][(j + 1) % SEGS]
			var c: Vector3 = verts[i + 1][(j + 1) % SEGS]
			var d2: Vector3 = verts[i + 1][j]
			st.add_vertex(a)
			st.add_vertex(b)
			st.add_vertex(c)
			st.add_vertex(a)
			st.add_vertex(c)
			st.add_vertex(d2)
	st.generate_normals()
	var mesh := st.commit()
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var pm := StandardMaterial3D.new()
	pm.albedo_color = Color(0.78, 0.30, 0.05)
	pm.roughness = 0.42
	pm.cull_mode = StandardMaterial3D.CULL_DISABLED
	mi.material_override = pm
	mi.position = Vector3(0, 0.26 * scale, 0)
	nd.add_child(mi)
	var stem := MeshInstance3D.new()
	var scm := CylinderMesh.new()
	scm.top_radius = 0.025 * scale
	scm.bottom_radius = 0.04 * scale
	scm.height = 0.14 * scale
	stem.mesh = scm
	stem.material_override = _simple(Color(0.20, 0.28, 0.10), 0.7)
	stem.position = Vector3(0, 0.55 * scale, 0)
	nd.add_child(stem)
	# visage émissif
	var face := _emissive(Color(1.0, 0.62, 0.15), 3.5)
	for s in [-1, 1]:
		var e := _quad(Vector2(0.09 * scale, 0.07 * scale), face)
		e.position = Vector3(s * 0.10 * scale, 0.32 * scale, 0.27 * scale)
		e.rotation = Vector3(0.35, 0, s * 0.3)
		nd.add_child(e)
	var mo := _quad(Vector2(0.16 * scale, 0.06 * scale), face)
	mo.position = Vector3(0, 0.18 * scale, 0.28 * scale)
	mo.rotation = Vector3(0.3, 0, 0)
	nd.add_child(mo)
	var gl := OmniLight3D.new()
	gl.light_color = Color(1.0, 0.55, 0.15)
	gl.light_energy = 1.1
	gl.omni_range = 2.6
	gl.position = Vector3(0, 0.35 * scale, 0.15 * scale)
	nd.add_child(gl)
	return nd


func _make_entity() -> Node3D:
	var nd := Node3D.new()
	var body_mat := StandardMaterial3D.new()
	body_mat.albedo_color = Color(0.05, 0.045, 0.06)
	body_mat.roughness = 0.95
	body_mat.rim_enabled = true
	body_mat.rim_tint = 0.55
	body_mat.cull_mode = StandardMaterial3D.CULL_DISABLED
	var body := MeshInstance3D.new()
	var cm := CapsuleMesh.new()
	cm.radius = 0.30
	cm.height = 1.55
	body.mesh = cm
	body.material_override = body_mat
	body.position = Vector3(0, 0.85, 0)
	body.scale = Vector3(1.0, 1.0, 0.55)
	nd.add_child(body)
	var head := MeshInstance3D.new()
	var hm := SphereMesh.new()
	hm.radius = 0.17
	hm.height = 0.34
	head.mesh = hm
	head.material_override = body_mat
	head.position = Vector3(0, 1.72, 0)
	head.scale = Vector3(1.0, 1.25, 0.9)
	nd.add_child(head)
	for s in [-1, 1]:
		var eye := MeshInstance3D.new()
		var es := SphereMesh.new()
		es.radius = 0.020
		es.height = 0.04
		eye.mesh = es
		eye.material_override = _emissive(Color(0.96, 0.96, 0.9), 3.0)
		eye.position = Vector3(s * 0.065, 1.76, 0.14)
		nd.add_child(eye)
	return nd


# ============================================================ dessin boucle
func _draw_loop() -> void:
	for c in dyn.get_children():
		c.queue_free()
	posters.clear()
	doors.clear()
	for lp in lamps:
		lp[0].visible = true
		lp[1].emission_energy = 5.0
	if entity != null and entity.get_parent() == world:
		entity.queue_free()
	entity = null
	exit_door = null
	flicker_idx = -1
	cross_state = 0
	rules_sign = _make_sign(1.5, -1)
	var t := 5.0
	var i := 0
	while t < PERIM - 2:
		posters.append(_make_poster(t, 1 if i % 2 == 0 else -1))
		t += 6.0
		i += 1
	for dt in [6.0, 16.0, 26.0, 33.0]:
		doors.append(_make_door(dt, -1))
	var c0 := _t_to_pos(0.5)
	dyn.add_child(_make_pumpkin(Vector3(c0.x, 0, c0.y) + _right_at(0.5) * 0.9, 1.0))
	var c1 := _t_to_pos(19.0)
	dyn.add_child(_make_pumpkin(Vector3(c1.x, 0, c1.y) - _right_at(19.0) * 0.9, 0.8))
	if ghost_arrow != null and is_instance_valid(ghost_arrow):
		ghost_arrow.queue_free()
	ghost_arrow = null
	if loops == 0:
		var ma := StandardMaterial3D.new()
		ma.albedo_texture = load("res://assets/tex/arrow.png")
		ma.texture_filter = 1
		ma.transparency_mode = 1
		ma.emission_enabled = true
		ma.emission = Color(1.0, 0.55, 0.15)
		ma.emission_texture = ma.albedo_texture
		ma.emission_energy = 2.6
		ma.cull_mode = StandardMaterial3D.CULL_DISABLED
		ghost_arrow = _quad(Vector2(0.9, 0.9), ma)
		dyn.add_child(ghost_arrow)
	if progress >= GOAL:
		exit_door = Node3D.new()
		var eq := _quad(Vector2(1.15, 2.2), _emissive(Color(1, 0.85, 0.55), 2.2, "res://assets/tex/exit.png"))
		exit_door.add_child(eq)
		var el := OmniLight3D.new()
		el.light_color = Color(1.0, 0.8, 0.5)
		el.light_energy = 2.0
		el.omni_range = 4.0
		el.position = Vector3(0, 0, 0.4)
		exit_door.add_child(el)
		var bm := MeshInstance3D.new()
		var cy := CylinderMesh.new()
		cy.top_radius = 0.10
		cy.bottom_radius = 0.18
		cy.height = 3.0
		bm.mesh = cy
		bm.material_override = _emissive(Color(1.0, 0.8, 0.5), 1.4)
		bm.position = Vector3(0, 0.5, 0.35)
		exit_door.add_child(bm)
		_place_on_wall(exit_door, 4.0, 1, 1.1)
	_apply_anomaly()


func _apply_anomaly() -> void:
	match anomaly:
		"poster":
			if posters.size():
				var p = posters[rng.randi_range(0, posters.size() - 1)]
				p.get_node("Art").material_override = _pixel("res://assets/tex/poster_b.png")
		"pumpkin":
			var t := rng.randf_range(10, PERIM - 6)
			var c := _t_to_pos(t)
			dyn.add_child(_make_pumpkin(Vector3(c.x, 0, c.y) + _right_at(t) * rng.randf_range(-0.7, 0.7), 0.9))
		"light":
			var lp = lamps[rng.randi_range(1, lamps.size() - 1)]
			lp[0].visible = false
			lp[1].emission_energy = 0.0
		"figure":
			entity = _make_entity()
			var t := fmod(_pos_to_t(Vector2(player.position.x, player.position.z)) + 14.0, PERIM)
			var c := _t_to_pos(t)
			entity.position = Vector3(c.x, 0, c.y)
			world.add_child(entity)
		"rules":
			if rules_sign:
				rules_sign.get_node("Art").material_override = _pixel("res://assets/tex/rulesbad_%s.png" % lang)
		"door":
			if doors.size():
				var dn = doors[rng.randi_range(0, doors.size() - 1)]
				dn.get_node("Slab").visible = false
				dn.get_node("Open").visible = true
		"stain":
			var t := rng.randf_range(8, PERIM - 4)
			var c := _t_to_pos(t)
			var m := StandardMaterial3D.new()
			m.albedo_texture = load("res://assets/tex/stain.png")
			m.transparency_mode = 1
			m.roughness = 0.35
			var mi := _quad(Vector2(1.3, 0.9), m)
			mi.rotation = Vector3(PI / 2, rng.randf_range(0, TAU), 0)
			mi.position = Vector3(c.x, 0.015, c.y)
			dyn.add_child(mi)
		"flip":
			if posters.size():
				posters[rng.randi_range(0, posters.size() - 1)].rotate_object_local(Vector3(0, 0, 1), PI)
		"flicker":
			flicker_idx = rng.randi_range(1, lamps.size() - 1)
		"cross":
			cross_state = 1
			cross_lat = -1.25
		"extradoor":
			_make_door([10.5, 21.0, 30.0][rng.randi_range(0, 2)], -1)
		"chase":
			chasing = true
			entity_t = fmod(_pos_to_t(Vector2(player.position.x, player.position.z)) + 18.0, PERIM)
			_spawn_chaser()


func _spawn_chaser() -> void:
	if entity != null:
		return
	entity = _make_entity()
	var c := _t_to_pos(entity_t)
	entity.position = Vector3(c.x, 0, c.y)
	world.add_child(entity)


# ============================================================ joueur ======
func _build_player() -> void:
	player = CharacterBody3D.new()
	var pcol := CollisionShape3D.new()
	var cap: CapsuleShape3D = CapsuleShape3D.new()
	cap.radius = 0.3
	cap.height = 1.5
	pcol.shape = cap
	pcol.position = Vector3(0, 0.8, 0)
	player.add_child(pcol)
	add_child(player)
	cam = Camera3D.new()
	cam.position = Vector3(0, EYE, 0)
	cam.fov = 78
	player.add_child(cam)
	headlamp = SpotLight3D.new()
	headlamp.light_color = Color(1.0, 0.86, 0.66)
	headlamp.light_energy = 1.7
	headlamp.spot_range = 10.0
	headlamp.spot_angle = 58.0
	headlamp.shadow_enabled = false
	headlamp.position = Vector3(0, -0.05, 0)
	cam.add_child(headlamp)
	hands = Node3D.new()
	hands.position = Vector3(0, -0.36, -0.55)
	cam.add_child(hands)
	var sleeve := _simple(Color(0.12, 0.10, 0.14), 0.8)
	var skin := _simple(Color(0.72, 0.55, 0.45), 0.6)
	for s2 in [-1, 1]:
		var arm := _box(Vector3(0.075, 0.075, 0.34), sleeve)
		arm.position = Vector3(s2 * 0.26, -0.06, 0.10)
		arm.rotation = Vector3(-0.35, s2 * 0.18, 0)
		hands.add_child(arm)
		var hd := _box(Vector3(0.062, 0.085, 0.11), skin)
		hd.position = Vector3(s2 * 0.24, -0.02, -0.10)
		hd.rotation = Vector3(-0.5, s2 * 0.15, 0)
		hands.add_child(hd)
	_respawn()


func _respawn() -> void:
	player.position = Vector3(2.0, 0, 0.0)
	yaw = 0.0
	pitch = 0.0
	prev_t = _pos_to_t(Vector2(2, 0))
	far_reached = false


# ============================================================ audio =======
var players: Array = []
var drone_pl: AudioStreamPlayer = null


func _mk_player(vol := 0.0) -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
	p.volume_db = vol
	add_child(p)
	players.append(p)
	return p


func play(p: String, vol := 0.0, pit := 1.0) -> void:
	var pl: AudioStreamPlayer = null
	for q in players:
		if not q.playing:
			pl = q
			break
	if pl == null:
		pl = _mk_player()
	pl.volume_db = vol + linear_to_db(maxf(vol_sfx, 0.001))
	pl.pitch_scale = pit
	pl.stream = load("res://assets/audio/%s.wav" % p)
	pl.play()
	if p in ["whisper", "creak", "heart", "sting"]:
		_caption(tt("cap_" + p))


func _build_reverb() -> void:
	var rev := AudioEffectReverb.new()
	rev.room_size = 0.62
	rev.damping = 0.42
	rev.wet = 0.22
	rev.dry = 1.0
	AudioServer.add_bus_effect(0, rev, -1)


# ============================================================ UI ==========
func _build_ui() -> void:
	ui = CanvasLayer.new()
	add_child(ui)
	hud_lbl = Label.new()
	hud_lbl.position = Vector2(10, 8)
	hud_lbl.add_theme_font_size_override("font_size", 16)
	hud_lbl.add_theme_color_override("font_color", Color(0.9, 0.75, 0.5, 0.85))
	hud_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	hud_lbl.add_theme_constant_override("outline_size", 4)
	ui.add_child(hud_lbl)
	hint_lbl = Label.new()
	hint_lbl.position = Vector2(0, 660)
	hint_lbl.size = Vector2(1280, 30)
	hint_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint_lbl.add_theme_font_size_override("font_size", 17)
	hint_lbl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.9, 0.9))
	hint_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	hint_lbl.add_theme_constant_override("outline_size", 4)
	ui.add_child(hint_lbl)
	ts_lbl = Label.new()
	ts_lbl.position = Vector2(940, 8)
	ts_lbl.size = Vector2(330, 20)
	ts_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	ts_lbl.add_theme_font_size_override("font_size", 15)
	ts_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.92, 0.8))
	ts_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	ts_lbl.add_theme_constant_override("outline_size", 3)
	ts_lbl.visible = false
	ui.add_child(ts_lbl)
	banner_lbl = Label.new()
	banner_lbl.position = Vector2(0, 96)
	banner_lbl.size = Vector2(1280, 40)
	banner_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	banner_lbl.add_theme_font_size_override("font_size", 26)
	banner_lbl.add_theme_color_override("font_color", Color(0.95, 0.8, 0.45, 0.95))
	banner_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	banner_lbl.add_theme_constant_override("outline_size", 5)
	banner_lbl.visible = false
	ui.add_child(banner_lbl)
	toast_lbl = Label.new()
	toast_lbl.position = Vector2(640, 596)
	toast_lbl.size = Vector2(630, 30)
	toast_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	toast_lbl.add_theme_font_size_override("font_size", 15)
	toast_lbl.add_theme_color_override("font_color", Color(0.8, 0.85, 0.9, 0.9))
	toast_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	toast_lbl.add_theme_constant_override("outline_size", 3)
	toast_lbl.visible = false
	ui.add_child(toast_lbl)
	cap_lbl = Label.new()
	cap_lbl.position = Vector2(12, 620)
	cap_lbl.size = Vector2(500, 26)
	cap_lbl.add_theme_font_size_override("font_size", 15)
	cap_lbl.add_theme_color_override("font_color", Color(0.72, 0.72, 0.8, 0.85))
	cap_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	cap_lbl.add_theme_constant_override("outline_size", 3)
	cap_lbl.visible = false
	ui.add_child(cap_lbl)
	obj_lbl = Label.new()
	obj_lbl.position = Vector2(0, 40)
	obj_lbl.size = Vector2(1280, 22)
	obj_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	obj_lbl.add_theme_font_size_override("font_size", 14)
	obj_lbl.add_theme_color_override("font_color", Color(0.85, 0.8, 0.7, 0.62))
	obj_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.85))
	obj_lbl.add_theme_constant_override("outline_size", 3)
	ui.add_child(obj_lbl)
	osd_lbl = Label.new()
	osd_lbl.position = Vector2(12, 8)
	osd_lbl.add_theme_font_size_override("font_size", 14)
	osd_lbl.add_theme_color_override("font_color", Color(0.9, 0.9, 0.92, 0.75))
	osd_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	osd_lbl.add_theme_constant_override("outline_size", 3)
	osd_lbl.text = "▶ PLAY"
	ui.add_child(osd_lbl)
	pocket_lbl = Label.new()
	pocket_lbl.position = Vector2(12, 664)
	pocket_lbl.add_theme_font_size_override("font_size", 14)
	pocket_lbl.add_theme_color_override("font_color", Color(0.95, 0.7, 0.3, 0.85))
	pocket_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	pocket_lbl.add_theme_constant_override("outline_size", 3)
	ui.add_child(pocket_lbl)
	stam_bg = ColorRect.new()
	stam_bg.position = Vector2(12, 690)
	stam_bg.size = Vector2(164, 10)
	stam_bg.color = Color(0, 0, 0, 0.5)
	ui.add_child(stam_bg)
	stam_fill = ColorRect.new()
	stam_fill.position = Vector2(14, 692)
	stam_fill.size = Vector2(160, 6)
	stam_fill.color = Color(0.85, 0.6, 0.3, 0.8)
	ui.add_child(stam_fill)
	hud_nodes = [hud_lbl, hint_lbl, ts_lbl, banner_lbl, toast_lbl, cap_lbl, obj_lbl, osd_lbl, stam_bg, stam_fill, pocket_lbl]
	# menu principal : le couloir vit derrière (caméra qui dérive)
	title_ctl = Control.new()
	title_ctl.set_anchors_preset(Control.PRESET_FULL_RECT)
	ui.add_child(title_ctl)
	var bg := ColorRect.new()
	bg.color = Color(0.01, 0.008, 0.012, 0.55)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	title_ctl.add_child(bg)
	var panel := ColorRect.new()
	panel.color = Color(0.015, 0.012, 0.018, 0.78)
	panel.position = Vector2(420, 120)
	panel.size = Vector2(440, 480)
	title_ctl.add_child(panel)
	var tl := Label.new()
	tl.name = "Logo"
	tl.position = Vector2(420, 140)
	tl.size = Vector2(440, 110)
	tl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	tl.add_theme_font_size_override("font_size", 84)
	tl.add_theme_color_override("font_color", Color(0.95, 0.55, 0.15))
	tl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	tl.add_theme_constant_override("outline_size", 10)
	title_ctl.add_child(tl)
	var sb := Label.new()
	sb.name = "Sub"
	sb.position = Vector2(420, 252)
	sb.size = Vector2(440, 26)
	sb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sb.add_theme_font_size_override("font_size", 17)
	sb.add_theme_color_override("font_color", Color(0.72, 0.72, 0.8))
	title_ctl.add_child(sb)
	var lbtn := Button.new()
	lbtn.name = "LangBtn"
	lbtn.position = Vector2(790, 128)
	lbtn.size = Vector2(60, 26)
	lbtn.add_theme_font_size_override("font_size", 13)
	lbtn.pressed.connect(func():
		lang = "en" if lang == "fr" else "fr"
		_refresh_menu())
	title_ctl.add_child(lbtn)
	var names := ["Play", "How", "Opt", "Quit"]
	for i in 4:
		var b := Button.new()
		b.name = names[i]
		b.position = Vector2(470, 300 + i * 66)
		b.size = Vector2(340, 54)
		b.add_theme_font_size_override("font_size", 22)
		title_ctl.add_child(b)
	title_ctl.get_node("Play").pressed.connect(func(): _start(lang))
	title_ctl.get_node("How").pressed.connect(func():
		title_ctl.visible = false
		howto_ctl.visible = true)
	title_ctl.get_node("Opt").pressed.connect(func():
		title_ctl.visible = false
		options_ctl.visible = true)
	title_ctl.get_node("Quit").pressed.connect(func(): get_tree().quit())
	var wn := Label.new()
	wn.name = "Warn"
	wn.position = Vector2(0, 686)
	wn.size = Vector2(1280, 24)
	wn.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	wn.add_theme_font_size_override("font_size", 14)
	wn.add_theme_color_override("font_color", Color(0.75, 0.3, 0.25))
	title_ctl.add_child(wn)
	# écran COMMENT JOUER
	howto_ctl = Control.new()
	howto_ctl.set_anchors_preset(Control.PRESET_FULL_RECT)
	howto_ctl.visible = false
	ui.add_child(howto_ctl)
	var hbg := ColorRect.new()
	hbg.color = Color(0.012, 0.01, 0.014, 0.94)
	hbg.set_anchors_preset(Control.PRESET_FULL_RECT)
	howto_ctl.add_child(hbg)
	var htl := Label.new()
	htl.name = "Title"
	htl.position = Vector2(0, 60)
	htl.size = Vector2(1280, 50)
	htl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	htl.add_theme_font_size_override("font_size", 34)
	htl.add_theme_color_override("font_color", Color(0.95, 0.6, 0.2))
	htl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	htl.add_theme_constant_override("outline_size", 6)
	howto_ctl.add_child(htl)
	for i in 5:
		var hl := Label.new()
		hl.name = "R%d" % (i + 1)
		hl.position = Vector2(240, 140 + i * 52)
		hl.size = Vector2(800, 46)
		hl.add_theme_font_size_override("font_size", 17)
		hl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.88))
		hl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		howto_ctl.add_child(hl)
	var hctl := Label.new()
	hctl.name = "Ctl"
	hctl.position = Vector2(240, 430)
	hctl.size = Vector2(800, 60)
	hctl.add_theme_font_size_override("font_size", 15)
	hctl.add_theme_color_override("font_color", Color(0.6, 0.6, 0.68))
	hctl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	howto_ctl.add_child(hctl)
	var hback := Button.new()
	hback.name = "Back"
	hback.position = Vector2(420, 560)
	hback.size = Vector2(200, 44)
	hback.add_theme_font_size_override("font_size", 18)
	hback.pressed.connect(func():
		how_seen = true
		_save_settings()
		howto_ctl.visible = false
		title_ctl.visible = true)
	howto_ctl.add_child(hback)

	# écran OPTIONS
	options_ctl = Control.new()
	options_ctl.set_anchors_preset(Control.PRESET_FULL_RECT)
	options_ctl.visible = false
	ui.add_child(options_ctl)
	var obg := ColorRect.new()
	obg.color = Color(0.012, 0.01, 0.014, 0.94)
	obg.set_anchors_preset(Control.PRESET_FULL_RECT)
	options_ctl.add_child(obg)
	var otl := Label.new()
	otl.name = "Title"
	otl.position = Vector2(0, 50)
	otl.size = Vector2(1280, 44)
	otl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	otl.add_theme_font_size_override("font_size", 30)
	otl.add_theme_color_override("font_color", Color(0.95, 0.6, 0.2))
	options_ctl.add_child(otl)
	var rows := [["master", vol_master], ["music", vol_music], ["sfx", vol_sfx], ["sens", mouse_sens]]
	for i in 4:
		var lb := Label.new()
		lb.name = "L" + rows[i][0]
		lb.position = Vector2(380, 130 + i * 62)
		lb.size = Vector2(300, 26)
		lb.add_theme_font_size_override("font_size", 16)
		lb.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
		options_ctl.add_child(lb)
		var sl := HSlider.new()
		sl.name = "S" + rows[i][0]
		sl.position = Vector2(700, 130 + i * 62)
		sl.size = Vector2(260, 26)
		sl.min_value = 0.0
		sl.max_value = 1.0 if i < 3 else 2.0
		sl.step = 0.05
		sl.value = rows[i][1]
		var key: String = rows[i][0]
		sl.value_changed.connect(func(v): _set_setting(key, v))
		options_ctl.add_child(sl)
	var tgl := [["qual", quality_high], ["vhs", vhs_visible_pref]]
	for i in 2:
		var cb := CheckButton.new()
		cb.name = "C" + tgl[i][0]
		cb.position = Vector2(700, 380 + i * 46)
		cb.size = Vector2(120, 36)
		cb.button_pressed = tgl[i][1]
		var key: String = tgl[i][0]
		cb.toggled.connect(func(on): _set_setting(key, on))
		options_ctl.add_child(cb)
		var cl := Label.new()
		cl.name = "LC" + tgl[i][0]
		cl.position = Vector2(380, 386 + i * 46)
		cl.size = Vector2(300, 26)
		cl.add_theme_font_size_override("font_size", 16)
		cl.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85))
		options_ctl.add_child(cl)
	var oback := Button.new()
	oback.name = "Back"
	oback.position = Vector2(540, 560)
	oback.size = Vector2(200, 44)
	oback.add_theme_font_size_override("font_size", 18)
	oback.pressed.connect(func():
		options_ctl.visible = false
		title_ctl.visible = true)
	options_ctl.add_child(oback)
	_refresh_menu()
	# intro
	intro_ctl = Control.new()
	intro_ctl.set_anchors_preset(Control.PRESET_FULL_RECT)
	intro_ctl.visible = false
	ui.add_child(intro_ctl)
	var ibg := ColorRect.new()
	ibg.color = Color(0.01, 0.01, 0.012, 1)
	ibg.set_anchors_preset(Control.PRESET_FULL_RECT)
	intro_ctl.add_child(ibg)
	var itl := Label.new()
	itl.name = "Txt"
	itl.position = Vector2(140, 250)
	itl.size = Vector2(1000, 200)
	itl.add_theme_font_size_override("font_size", 26)
	itl.add_theme_color_override("font_color", Color(0.85, 0.85, 0.88))
	intro_ctl.add_child(itl)
	var isk := Label.new()
	isk.name = "Skip"
	isk.position = Vector2(0, 660)
	isk.size = Vector2(1280, 24)
	isk.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	isk.add_theme_font_size_override("font_size", 14)
	isk.add_theme_color_override("font_color", Color(0.5, 0.5, 0.55))
	intro_ctl.add_child(isk)
	# pause
	pause_ctl = Control.new()
	pause_ctl.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_ctl.visible = false
	ui.add_child(pause_ctl)
	var pbg := ColorRect.new()
	pbg.color = Color(0.01, 0.01, 0.012, 0.85)
	pbg.set_anchors_preset(Control.PRESET_FULL_RECT)
	pause_ctl.add_child(pbg)
	var ptl := Label.new()
	ptl.name = "Title"
	ptl.position = Vector2(0, 200)
	ptl.size = Vector2(1280, 50)
	ptl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ptl.add_theme_font_size_override("font_size", 40)
	ptl.add_theme_color_override("font_color", Color(0.9, 0.6, 0.2))
	pause_ctl.add_child(ptl)
	for i in 3:
		var pb := Button.new()
		pb.name = ["Resume", "Restart", "ToTitle"][i]
		pb.position = Vector2(540, 290 + i * 60)
		pb.size = Vector2(200, 44)
		pb.add_theme_font_size_override("font_size", 18)
		pause_ctl.add_child(pb)
	pause_ctl.get_node("Resume").pressed.connect(func(): _resume())
	pause_ctl.get_node("Restart").pressed.connect(func(): _begin_run())
	pause_ctl.get_node("ToTitle").pressed.connect(func(): _to_title())
	# fin
	end_ctl = Control.new()
	end_ctl.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_ctl.visible = false
	ui.add_child(end_ctl)
	var ebg := ColorRect.new()
	ebg.color = Color(0.01, 0.01, 0.012, 0.95)
	ebg.set_anchors_preset(Control.PRESET_FULL_RECT)
	end_ctl.add_child(ebg)
	var etl := Label.new()
	etl.name = "Title"
	etl.position = Vector2(0, 240)
	etl.size = Vector2(1280, 70)
	etl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	etl.add_theme_font_size_override("font_size", 56)
	etl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	etl.add_theme_constant_override("outline_size", 8)
	end_ctl.add_child(etl)
	var esb := Label.new()
	esb.name = "Sub"
	esb.position = Vector2(0, 340)
	esb.size = Vector2(1280, 40)
	esb.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	esb.add_theme_font_size_override("font_size", 18)
	esb.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75))
	end_ctl.add_child(esb)
	var est := Label.new()
	est.name = "Stats"
	est.position = Vector2(0, 390)
	est.size = Vector2(1280, 30)
	est.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	est.add_theme_font_size_override("font_size", 16)
	est.add_theme_color_override("font_color", Color(0.55, 0.55, 0.6))
	end_ctl.add_child(est)
	var eb := Button.new()
	eb.name = "Replay"
	eb.position = Vector2(540, 450)
	eb.size = Vector2(200, 44)
	eb.add_theme_font_size_override("font_size", 18)
	eb.pressed.connect(func(): _start(lang))
	end_ctl.add_child(eb)


func _refresh_menu() -> void:
	title_ctl.get_node("Logo").text = tt("title")
	title_ctl.get_node("Sub").text = tt("sub")
	title_ctl.get_node("LangBtn").text = "EN" if lang == "fr" else "FR"
	title_ctl.get_node("Play").text = tt("menu_play")
	title_ctl.get_node("How").text = tt("menu_how")
	title_ctl.get_node("Opt").text = tt("menu_opt")
	title_ctl.get_node("Quit").text = tt("menu_quit")
	title_ctl.get_node("Warn").text = tt("warn")
	howto_ctl.get_node("Title").text = tt("how_title")
	for i in 5:
		howto_ctl.get_node("R%d" % (i + 1)).text = tt("how_%d" % (i + 1))
	howto_ctl.get_node("Ctl").text = tt("controls")
	howto_ctl.get_node("Back").text = tt("back")
	options_ctl.get_node("Title").text = tt("opt_title")
	options_ctl.get_node("Lmaster").text = tt("opt_master")
	options_ctl.get_node("Lmusic").text = tt("opt_music")
	options_ctl.get_node("Lsfx").text = tt("opt_sfx")
	options_ctl.get_node("Lsens").text = tt("opt_sens")
	options_ctl.get_node("LCqual").text = tt("opt_qual")
	options_ctl.get_node("LCvhs").text = tt("opt_vhs")
	options_ctl.get_node("Back").text = tt("opt_back")


func _set_setting(k: String, v: float) -> void:
	match k:
		"master":
			vol_master = v
		"music":
			vol_music = v
		"sfx":
			vol_sfx = v
		"sens":
			mouse_sens = v
		"qual":
			if bool(v) != quality_high:
				_toggle_quality()
			options_ctl.get_node("Cqual").button_pressed = quality_high
		"vhs":
			vhs_visible_pref = bool(v)
			vhs.visible = vhs_visible_pref
	_apply_volumes()
	_save_settings()


func _apply_volumes() -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(vol_master, 0.001)))
	if drone_pl != null:
		drone_pl.volume_db = -8.0 + linear_to_db(maxf(vol_music, 0.001))
	if wind_pl != null:
		wind_pl.volume_db = -15.0 + linear_to_db(maxf(vol_music, 0.001))
	if house_pl != null:
		house_pl.volume_db = -12.0 + linear_to_db(maxf(vol_sfx, 0.001))
	if tension_pl != null:
		tension_pl.volume_db = -6.0 + linear_to_db(maxf(vol_music, 0.001)) + linear_to_db(maxf(vol_music, 0.001))


func _save_settings() -> void:
	var cf := ConfigFile.new()
	cf.set_value("s", "lang", lang)
	cf.set_value("s", "master", vol_master)
	cf.set_value("s", "music", vol_music)
	cf.set_value("s", "sfx", vol_sfx)
	cf.set_value("s", "sens", mouse_sens)
	cf.set_value("s", "qual", quality_high)
	cf.set_value("s", "vhs", vhs_visible_pref)
	cf.set_value("s", "how", how_seen)
	cf.save("user://le31.cfg")


func _load_settings() -> void:
	var cf := ConfigFile.new()
	if cf.load("user://le31.cfg") == OK:
		lang = cf.get_value("s", "lang", "fr")
		vol_master = cf.get_value("s", "master", 0.9)
		vol_music = cf.get_value("s", "music", 0.8)
		vol_sfx = cf.get_value("s", "sfx", 0.9)
		mouse_sens = cf.get_value("s", "sens", 1.0)
		quality_high = cf.get_value("s", "qual", true)
		vhs_visible_pref = cf.get_value("s", "vhs", true)
		how_seen = cf.get_value("s", "how", false)
	AudioServer.set_bus_volume_db(0, linear_to_db(maxf(vol_master, 0.001)))


func _banner(text: String, dur: float) -> void:
	banner_lbl.text = text
	banner_timer = dur
	banner_lbl.visible = hud_on


func _toast(text: String, dur := 3.5) -> void:
	toast_lbl.text = text
	toast_timer = dur
	toast_lbl.visible = hud_on


func _caption(text: String) -> void:
	cap_lbl.text = text
	cap_timer = 2.5
	cap_lbl.visible = hud_on


func _build_vhs() -> void:
	var cl := CanvasLayer.new()
	cl.layer = 5
	add_child(cl)
	vhs = ColorRect.new()
	vhs.set_anchors_preset(Control.PRESET_FULL_RECT)
	vhs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
render_mode blend_mul;
uniform float time;
float hash(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
void fragment() {
	vec2 uv = UV;
	float t8 = floor(time * 8.0);
	// déchirure horizontale aléatoire
	float tear_band = step(0.965, hash(vec2(floor(uv.y * 30.0), floor(time * 6.0))));
	float slip = step(0.94, hash(vec2(t8, 7.0)));
	uv.x += (hash(vec2(t8, 1.0)) - 0.5) * 0.09 * slip * tear_band;
	// glissement vertical occasionnel (vertical hold)
	float vslip = step(0.985, hash(vec2(floor(time * 2.0), 5.0)));
	uv.y = fract(uv.y + vslip * 0.06 * hash(vec2(floor(uv.y * 3.0), t8)));
	float scan = 0.96 + 0.04 * sin(uv.y * 900.0 + time * 8.0);
	float inter = 0.985 + 0.015 * sin(uv.y * 1800.0);
	float n = hash(uv * vec2(960.0, 540.0) + floor(time * 12.0));
	float vig = smoothstep(1.25, 0.5, length(uv - 0.5) * 1.3);
	float track = step(0.99, hash(vec2(floor(time * 3.0), 7.0))) * step(hash(vec2(uv.y, floor(time * 3.0))), 0.03);
	float bar = 0.03 * smoothstep(0.1, 0.0, abs(fract(time * 0.07) - uv.y));
	vec3 col = vec3(scan * inter) * (0.95 + 0.05 * n) * vig + bar + track * 0.15;
	// franges chromatiques sur les déchirures
	col.r *= 1.0 + 0.35 * tear_band * slip;
	col.b *= 1.0 - 0.30 * tear_band * slip;
	col.g *= 1.0 + 0.10 * slip;
	COLOR = vec4(col, 1.0);
}
"""
	var sm := ShaderMaterial.new()
	sm.shader = sh
	vhs.material = sm
	cl.add_child(vhs)
	fade = ColorRect.new()
	fade.color = Color(0, 0, 0, 0)
	fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(fade)
	scare_rect = TextureRect.new()
	scare_rect.texture = load("res://assets/tex/scare.png")
	scare_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	scare_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	scare_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	scare_rect.visible = false
	scare_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	cl.add_child(scare_rect)
	vhs.visible = vhs_visible_pref


# ============================================================ flux ========
func _start(lg: String) -> void:
	lang = lg
	title_ctl.visible = false
	howto_ctl.visible = false
	end_ctl.visible = false
	pause_ctl.visible = false
	intro_ctl.visible = true
	intro_ctl.get_node("Skip").text = tt("skip")
	intro_t = 0.0
	state = "intro"


func _begin_run() -> void:
	intro_ctl.visible = false
	pause_ctl.visible = false
	end_ctl.visible = false
	ts_lbl.visible = true
	run_time = 0.0
	progress = 0
	mistakes = 0
	loops = 0
	anomaly = ""
	chasing = false
	if entity != null:
		entity.queue_free()
		entity = null
	state = "play"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	f_first_anom = false
	f_exit = false
	anom_timer = 0.0
	candies = {}
	pocket = 1
	poster_base = ["poster_a", "poster_c"][rng.randi_range(0, 1)]
	candy_offer = []
	candy_timer = 0.0
	entity_stun = 0.0
	stamina = 1.0
	_respawn()
	_roll_anomaly()
	_draw_loop()
	_banner(tt("obj_banner"), 10.0)
	obj_lbl.text = tt("obj_short")
	obj_lbl.visible = hud_on
	if not f_arrow:
		f_arrow = true
		_toast(tt("toast_arrow"), 7.0)
	if dbg != "":
		print("EVT start lang=", lang)
	hint_lbl.text = tt("rules_tip")
	if drone_pl == null:
		drone_pl = AudioStreamPlayer.new()
		drone_pl.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		drone_pl.volume_db = -8.0
		add_child(drone_pl)
		drone_pl.stream = load("res://assets/audio/drone.wav")
		if drone_pl.stream:
			drone_pl.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	drone_pl.play()
	if wind_pl == null:
		wind_pl = AudioStreamPlayer.new()
		wind_pl.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(wind_pl)
		wind_pl.stream = load("res://assets/audio/wind.wav")
		wind_pl.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	if house_pl == null:
		house_pl = AudioStreamPlayer.new()
		house_pl.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(house_pl)
		house_pl.stream = load("res://assets/audio/house.wav")
		house_pl.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	if tension_pl == null:
		tension_pl = AudioStreamPlayer.new()
		tension_pl.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(tension_pl)
		tension_pl.stream = load("res://assets/audio/tension.wav")
		tension_pl.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	_apply_volumes()
	wind_pl.play()
	house_pl.play()


func _resume() -> void:
	pause_ctl.visible = false
	state = "play"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _to_title() -> void:
	pause_ctl.visible = false
	end_ctl.visible = false
	ts_lbl.visible = false
	title_ctl.visible = true
	state = "title"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if drone_pl != null:
		drone_pl.stop()
	if wind_pl != null:
		wind_pl.stop()
	if house_pl != null:
		house_pl.stop()
	if tension_pl != null:
		tension_pl.stop()


func _roll_anomaly() -> void:
	chasing = false
	anom_timer = 0.0
	if loops == 0:
		anomaly = ""
		return
	var thr := 4 if candies.get("caramel", false) else 3
	if mistakes >= thr and rng.randf() < 0.45:
		anomaly = "chase"
	elif rng.randf() < clampf(0.55 + loops * 0.03, 0.55, 0.85):
		anomaly = ["poster", "pumpkin", "light", "figure", "rules", "door", "whisper", "stain", "flip", "flicker", "cross", "extradoor"][rng.randi_range(0, 11)]
	else:
		anomaly = ""
	if anomaly == "whisper":
		whisper_timer = rng.randf_range(2.0, 6.0)


func _evaluate_pass() -> void:
	loops += 1
	if dbg != "":
		print("EVT pass loops=", loops, " anomaly=", anomaly, " chasing=", chasing, " progress=", progress)
	if chasing or anomaly != "":
		_mistake()
		return
	progress += 1
	pocket = mini(3, pocket + 1)
	play("chime", -6.0)
	_toast(tt("toast_plus1"), 2.5)
	_offer_candy()
	far_reached = false
	if progress >= GOAL and not f_exit:
		f_exit = true
		_banner(tt("banner_exit"), 8.0)
	_roll_anomaly()
	_draw_loop()
	if progress >= GOAL:
		play("creak", -4.0)


func _offer_candy() -> void:
	var left := []
	for cid in CANDY_IDS:
		if not candies.get(cid, false):
			left.append(cid)
	if left.is_empty():
		return
	left.shuffle()
	candy_offer = left.slice(0, mini(2, left.size()))
	candy_timer = 9.0
	var txt := tt("candy_title")
	for i in candy_offer.size():
		txt += "[%d] %s : %s   " % [i + 1, tt("cd_%s_n" % candy_offer[i]), tt("cd_%s_d" % candy_offer[i])]
	_banner(txt, 9.0)


func _evaluate_return() -> void:
	if dbg != "":
		print("EVT return anomaly=", anomaly, " chasing=", chasing)
	if chasing:
		chasing = false
		mistakes = 0
		anomaly = ""
		if entity != null:
			entity.queue_free()
			entity = null
		play("chime", -6.0)
		_blackout(false)
		return
	if anomaly != "":
		var was := anomaly
		anomaly = ""
		play("chime", -10.0)
		_toast(tt("toast_seen") + " " + tt("toast_reveal") % tt("an_" + was), 4.5)
		_roll_anomaly()
		_draw_loop()
	else:
		_mistake()
	far_reached = false


func _mistake() -> void:
	if dbg != "":
		print("EVT mistake n=", mistakes + 1, " was anomaly=", anomaly, " chasing=", chasing)
	var was := "chase" if chasing else anomaly
	if was != "":
		_toast(tt("toast_miss_change") + " " + tt("toast_reveal") % tt("an_" + was), 5.0)
	else:
		_toast(tt("toast_miss_nothing"), 5.0)
	mistakes += 1
	progress = 0
	anomaly = ""
	chasing = false
	if entity != null:
		entity.queue_free()
		entity = null
	play("sting", -3.0)
	_blackout(true)


func _blackout(reroll: bool) -> void:
	locked = true
	var tw := create_tween()
	tw.tween_property(fade, "color", Color(0, 0, 0, 1), 0.28)
	tw.tween_callback(func():
		_respawn()
		if reroll:
			_roll_anomaly()
		_draw_loop())
	tw.tween_interval(0.25)
	tw.tween_property(fade, "color", Color(0, 0, 0, 0), 0.4)
	tw.tween_callback(func(): locked = false)


func _caught() -> void:
	if dbg != "":
		print("EVT CAUGHT")
	state = "dead"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	scare_rect.visible = true
	play("scare", 0.0)
	var tw := create_tween()
	tw.tween_interval(0.75)
	tw.tween_callback(func():
		scare_rect.visible = false
		end_ctl.visible = true
		end_ctl.get_node("Title").text = tt("dead")
		end_ctl.get_node("Title").add_theme_color_override("font_color", Color(0.85, 0.15, 0.12))
		end_ctl.get_node("Sub").text = tt("dead_sub")
		end_ctl.get_node("Stats").text = tt("loops") % [loops, mistakes]
		end_ctl.get_node("Replay").text = tt("replay"))


func _win() -> void:
	if dbg != "":
		print("EVT WIN loops=", loops, " mistakes=", mistakes)
	state = "win"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	play("chime", -3.0)
	end_ctl.visible = true
	end_ctl.get_node("Title").text = tt("win")
	end_ctl.get_node("Title").add_theme_color_override("font_color", Color(0.95, 0.6, 0.2))
	end_ctl.get_node("Sub").text = tt("win_sub")
	end_ctl.get_node("Stats").text = tt("loops") % [loops, mistakes]
	end_ctl.get_node("Replay").text = tt("replay")
	get_tree().create_timer(2.5).timeout.connect(func():
		if state == "win":
			end_ctl.get_node("Sub").text = tt("win_sub") + "\n" + tt("credit"))


# ============================================================ input =======
func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventMouseMotion and state == "play" and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= ev.relative.x * 0.0022 * mouse_sens
		pitch = clampf(pitch - ev.relative.y * 0.0021 * mouse_sens, -1.1, 1.1)
	if ev is InputEventKey and ev.pressed:
		if ev.keycode == KEY_ESCAPE and state == "play":
			_do_pause()
			return
		if state == "intro" and (ev.keycode == KEY_SPACE or ev.keycode == KEY_ENTER):
			_begin_run()
			return
		if state == "play":
			if candy_offer.size() > 0 and (ev.keycode == KEY_1 or ev.keycode == KEY_2):
				var idx := 0 if ev.keycode == KEY_1 else 1
				if idx < candy_offer.size():
					var cid: String = candy_offer[idx]
					candies[cid] = true
					_toast(tt("candy_got") % tt("cd_%s_n" % cid), 4.0)
					play("chime", -4.0)
				candy_offer = []
				candy_timer = 0.0
				return
			if ev.keycode == KEY_E and chasing and pocket > 0:
				pocket -= 1
				entity_stun = 2.5
				play("creak", -6.0)
				_toast(tt("candy_throw"), 3.0)
			if ev.keycode == KEY_V:
				vhs.visible = not vhs.visible
				vhs_visible_pref = vhs.visible
				options_ctl.get_node("Cvhs").button_pressed = vhs.visible
				_save_settings()
			if ev.keycode == KEY_G:
				headlamp_on = not headlamp_on
				headlamp.visible = headlamp_on
				play("creak", -14.0, 1.6)
			if ev.keycode == KEY_F1:
				hud_on = not hud_on
				for n in hud_nodes:
					n.visible = hud_on
				if not hud_on:
					banner_lbl.visible = false
					toast_lbl.visible = false
					cap_lbl.visible = false
	if ev is InputEventMouseButton and ev.pressed and state == "intro":
		_begin_run()
		return
	if ev is InputEventMouseButton and ev.pressed and state == "play" and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_OUT and state == "play":
		_do_pause()


func _do_pause() -> void:
	state = "pause"
	pause_ctl.visible = true
	pause_ctl.get_node("Title").text = tt("pause_t")
	pause_ctl.get_node("Resume").text = tt("resume")
	pause_ctl.get_node("Restart").text = tt("restart")
	pause_ctl.get_node("ToTitle").text = tt("title_btn")
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _toggle_quality() -> void:
	quality_high = not quality_high
	env.volumetric_fog_enabled = quality_high
	env.sdfgi_enabled = quality_high
	env.glow_enabled = quality_high
	for lp in lamps:
		lp[0].shadow_enabled = quality_high


# ============================================================ process =====
func _process(d: float) -> void:
	if vhs.material:
		vhs.material.set_shader_parameter("time", Time.get_ticks_msec() / 1000.0)
	if state == "intro":
		intro_t += d
		var full := tt("intro1") + "\n\n" + tt("intro2") + "\n\n" + tt("intro3")
		var n := int(intro_t / 0.035)
		intro_ctl.get_node("Txt").text = full.substr(0, n)
		if intro_t > 7.0:
			_begin_run()
		return
	if state == "title":
		title_cam_t += d * 0.5
		var cp := _t_to_pos(title_cam_t)
		player.position = Vector3(cp.x, 0, cp.y)
		yaw = sin(title_cam_t * 0.10) * 0.6
		pitch = -0.04
		player.rotation = Vector3(0, yaw, 0)
		cam.rotation = Vector3(pitch, 0, 0)
		cam.position = Vector3(0, EYE, 0)
		return
	if state != "play":
		return
	if locked:
		return
	if dbg == "audit":
		_dbg_audit(d)
		return
	if dbg != "":
		_dbg_walk(d)
	run_time += d
	var secs := int(run_time) + 23 * 3600 + 41 * 60
	var dat := "31 OCT 1997" if lang == "fr" else "OCT 31 1997"
	var rec := "● " if fmod(run_time, 1.4) < 0.7 else "  "
	ts_lbl.text = "%s%s %02d:%02d:%02d" % [rec, dat, (secs / 3600) % 24, (secs / 60) % 60, secs % 60]
	if flicker_idx >= 0:
		var lp = lamps[flicker_idx]
		var on := fmod(run_time * 7.3, 1.0) > 0.25 and fmod(run_time * 3.1, 1.0) > 0.1
		lp[0].visible = on
		lp[1].emission_energy = 5.0 if on else 0.0
	if cross_state == 1:
		var pt0 := _pos_to_t(Vector2(player.position.x, player.position.z))
		if pt0 > 12.0 and pt0 < 26.0:
			cross_state = 2
			entity = _make_entity()
			world.add_child(entity)
	if cross_state == 2 and entity != null and not chasing:
		cross_lat += d * 0.75
		var cc := _t_to_pos(19.0)
		entity.position = Vector3(cc.x, 0, cc.y) + _right_at(19.0) * cross_lat
		entity.look_at(Vector3(player.position.x, 0, player.position.z), Vector3.UP)
		if cross_lat > 1.3:
			entity.visible = false
			cross_state = 3
	# déplacement
	var fwd := Vector3(-sin(yaw), 0, -cos(yaw))
	var rgt := Vector3(-fwd.z, 0, fwd.x)
	var mv := Vector3.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_Z) or Input.is_key_pressed(KEY_UP):
		mv += fwd
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		mv -= fwd
	if Input.is_key_pressed(KEY_D):
		mv += rgt
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_Q):
		mv -= rgt
	if Input.is_key_pressed(KEY_LEFT):
		yaw += 1.8 * d
	if Input.is_key_pressed(KEY_RIGHT):
		yaw -= 1.8 * d
	var want_sprint := Input.is_key_pressed(KEY_SHIFT) and stamina > 0.05
	if mv.length_squared() > 0.01:
		if want_sprint:
			stamina = maxf(0.0, stamina - d * (0.11 if candies.get("sucre", false) else 0.22))
		else:
			stamina = minf(1.0, stamina + d * 0.16)
		mv = mv.normalized() * (5.6 if want_sprint else 3.4)
		player.velocity = Vector3(mv.x, 0, mv.z)
		bob += d * (9.5 if want_sprint else 6.5)
		if fmod(bob, TAU) < d * (9.5 if want_sprint else 6.5):
			play("step", -12.0, randf_range(0.9, 1.1))
	else:
		player.velocity = Vector3.ZERO
		bob = move_toward(bob, round(bob / TAU) * TAU, d * 4)
		stamina = minf(1.0, stamina + d * 0.22)
	player.rotation = Vector3(0, yaw, 0)
	player.move_and_slide()
	if stamina < 0.5:
		breath_timer -= d
		if breath_timer <= 0.0:
			breath_timer = 0.7 + stamina
			play("breath", -8.0)
	if stamina < 0.25 and fmod(run_time, 1.3) < d:
		play("heart", -6.0)
	stam_fill.size.x = 160.0 * stamina
	if tension_pl != null:
		if chasing and not tension_pl.playing:
			tension_pl.play()
		elif not chasing and tension_pl.playing:
			tension_pl.stop()
	if hands != null:
		hands.position = Vector3(cos(bob * 0.5) * 0.012, -0.36 + sin(bob) * 0.018 + (0.03 if stamina < 0.2 else 0.0), -0.55)
		hands.rotation.z = sin(bob * 0.5) * 0.02
	var p2 := Vector2(player.position.x, player.position.z)
	var t := _pos_to_t(p2)
	cam.rotation = Vector3(pitch, 0, 0)
	cam.position = Vector3(0, EYE + sin(bob) * 0.035, 0)
	var prev := prev_t
	prev_t = t
	if t > 12.0:
		far_reached = true
	if prev > PERIM - 4.0 and t < 4.0:
		_evaluate_pass()
	elif t < 2.2 and far_reached:
		_evaluate_return()
	if exit_door != null and (Vector2(player.position.x, player.position.z) - Vector2(exit_door.position.x, exit_door.position.z)).length() < 1.5:
		_win()
		return
	if entity != null and not chasing and cross_state == 0:
		if (player.position - entity.position).length() < 6.0:
			entity.visible = false
	if entity != null and (chasing or cross_state == 2):
		entity.look_at(Vector3(player.position.x, entity.position.y, player.position.z), Vector3.UP)
	if chasing:
		if entity == null:
			_spawn_chaser()
		var pt := _pos_to_t(Vector2(player.position.x, player.position.z))
		var dif := fmod(pt - entity_t + PERIM, PERIM)
		if dif > PERIM / 2:
			dif -= PERIM
		if entity_stun > 0.0:
			entity_stun -= d
		else:
			var cspeed := 1.7 if candies.get("reglisse", false) else 2.3
			entity_t = fmod(entity_t + clampf(dif, -cspeed * d, cspeed * d), PERIM)
		var ec := _t_to_pos(entity_t)
		if entity != null:
			entity.position = Vector3(ec.x, 0, ec.y)
			entity.visible = true
		if absf(dif) < 1.1:
			_caught()
			return
		if fmod(Time.get_ticks_msec() / 1000.0, 1.4) < d:
			play("heart", -4.0)
		hint_lbl.text = tt("hint_run")
	elif anomaly != "":
		hint_lbl.text = tt("rules_tip") if loops == 0 else ""
	else:
		hint_lbl.text = tt("hint_move") if run_time < 8.0 else ("" if progress < GOAL else ">> " + tt("exit_lbl") + " <<")
	if anomaly != "" and not chasing and not f_first_anom:
		anom_timer += d
		if anom_timer > 6.0:
			_banner(tt("banner_first_anom"), 6.0)
			f_first_anom = true
	if ghost_arrow != null and is_instance_valid(ghost_arrow):
		ghost_arrow.visible = loops == 0 and hud_on
		var tg := fmod(t + 2.6, PERIM)
		var cg := _t_to_pos(tg)
		ghost_arrow.position = Vector3(cg.x, 0.03, cg.y)
		ghost_arrow.rotation = Vector3(PI / 2, _ang_at(tg), PI / 4)
		ghost_arrow.material_override.emission_energy = 1.6 + sin(run_time * 5.0) * 0.8
	osd_lbl.visible = hud_on and fmod(run_time, 1.6) < 0.95
	if banner_timer > 0.0:
		banner_timer -= d
		if banner_timer <= 0.0:
			banner_lbl.visible = false
	if toast_timer > 0.0:
		toast_timer -= d
		if toast_timer <= 0.0:
			toast_lbl.visible = false
	if cap_timer > 0.0:
		cap_timer -= d
		if cap_timer <= 0.0:
			cap_lbl.visible = false
	if candies.get("miroir", false) and anomaly != "" and not chasing:
		mirror_timer -= d
		if mirror_timer <= 0.0:
			mirror_timer = 5.0
			play("whisper", -16.0)
	if candy_timer > 0.0:
		candy_timer -= d
		if candy_timer <= 0.0:
			candy_offer = []
	pocket_lbl.text = tt("pocket") % pocket
	if anomaly == "whisper":
		whisper_timer -= d
		if whisper_timer <= 0.0:
			whisper_timer = rng.randf_range(3.0, 7.0)
			play("whisper", -6.0)
	elif mistakes >= 2 and rng.randf() < d * 0.03:
		play("whisper", -14.0)
	hud_lbl.text = tt("progress") % [progress, GOAL]


# ============================================================ debug =======
func _dbg_walk(d: float) -> void:
	if chasing:
		dbg_t -= 20.0 * d
	elif anomaly != "" and dbg == "smart":
		dbg_t -= 10.0 * d
	else:
		dbg_t += 12.0 * d
	var c := _t_to_pos(dbg_t)
	player.position = Vector3(c.x, 0, c.y)


func _dbg_audit(d: float) -> void:
	if audit_i >= AUDIT_LIST.size():
		print("AUDIT ALL OK")
		get_tree().quit(0)
		return
	audit_timer -= d
	if audit_timer > 0.0:
		if AUDIT_LIST[audit_i - 1] == "cross":
			dbg_t = 15.0
			var c := _t_to_pos(dbg_t)
			player.position = Vector3(c.x, 0, c.y)
		return
	anomaly = AUDIT_LIST[audit_i]
	chasing = anomaly == "chase"
	_draw_loop()
	if chasing:
		chasing = true
		entity_t = 10.0
	dbg_t = 2.0
	var c := _t_to_pos(dbg_t)
	player.position = Vector3(c.x, 0, c.y)
	prev_t = dbg_t
	print("AUDIT ok ", anomaly)
	audit_timer = 1.2
	audit_i += 1
