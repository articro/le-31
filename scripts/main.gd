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
var lang := "fr"


const TR := {
	"fr": {
		"title": "LE 31",
		"sub": "une nuit dans la maison hantée",
		"cam_rec": "CAMÉSCOPE",
		"cam_batt": "BATT %d%%",
		"cam_rewind": "\u25c0\u25c0 REMBOBINAGE \u2014 elle t'a entendu",
		"cam_low": "PAS ASSEZ DE BATTERIE POUR REMBOBINER",
		"cam_empty": "BATTERIE VIDE \u2014 le caméscope s'éteint",
		"cam_pile": "PILE +%d%%",
		"cam_pick": "[R] rembobiner  \u00b7  [PILES] recharger le caméscope",
		"heard": "ELLE A ENTENDU QUELQUE CHOSE. Elle arrive.",
		"hide_warn": "NE BOUGE PLUS. Elle est juste à côté.",
		"hide_busted": "ELLE T'A ENTENDU BOUGER !",
		"play": "ENTRER",
		"warn": "casque recommandé — ne joue pas dans le noir… ou si.",
		"controls": "ZQSD / WASD / flèches : marcher · MAJ : courir (endurance !) · SOURIS : regarder · CLIC DROIT ou T : CAMÉSCOPE (voir dans le noir) · R : REMBOBINER 20 s (batterie + ça l'attire) · G : lampe torche · E : lancer un bonbon (diversion) · F : sucre collant (ralentit) · V : grain VHS · ÉCHAP : pause",
		"rules_tip": "Lis la pancarte. Obéis.",
		"exit_lbl": "SORTIE",
		"progress": "SORTIE : %d m",
		"obj_heart": "ELLE EST AVEUGLE. Elle entend ton cœur. Traverse la maison jusqu'à la porte de sortie.",
		"hint_listen": "Elle t'entend : marche doucement, ou arrete-toi pour calmer ton c\u0153ur.",
		"arch_closed": "Refuge ferme derriere toi. Elle ne passera pas.",
		"graze": "Le bonbon Caramel t'arrache a ses griffes !",
		"noise_lbl": "BRUIT",
		"dead3": "Elle t'a repris. La maison te garde.",
		"win": "TU ES SORTI·E",
		"win_sub": "Tu es dehors. L'air frais de la nuit emplit tes poumons. Tu as survécu au 31.",
		"dead": "RATTRAPÉ·E",
		"dead_sub": "Il fallait répondre. Ou fuir plus vite.",
		"replay": "REJOUER",
		"loops": "prises : %d   bonbons : %d",
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
		"how_1": "1. La maison est SOMBRE : ta lampe torche (G) est ta meilleure amie. La sortie est à l'EST — mais elle est VERROUILLÉE : trouve la clé dorée (position différente à chaque partie).",
		"how_2": "2. ELLE est aveugle mais entend tes pas, et elle MARCHE et COURT comme une bête. Courir = du bruit = elle te traque. Le plancher grince par endroits.",
		"how_3": "3. Bonbons (5) : E = diversion, F = piège de sucre collant qui la ralentit. Une 2e clé ouvre la chambre verrouillée (bonbon + placard à l'intérieur).",
		"how_4": "4. 4 CACHETTES où elle ne peut rien : placards (chambres, garage) et renfoncement de l'escalier. L'escalier raide du garage monte à l'ÉTAGE : une pièce de plus à fouiller — elle entend mal à travers le plancher.",
		"how_5": "5. Si elle te touche : tu te réveilles à l'entrée (3 points d'apparition aléatoires). 3 prises = c'est fini. Sors vivant.",
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
		"toast_arrow": "Trouve la clé dorée : elle brille quelque part dans la maison.",
		"crouch_on": "Accroupi : tu fais presque aucun bruit (C pour te relever)",
		"blackout_on": "PANNE DE COURANT — la maison est noire. Reste à la lampe torche.",
		"blackout_end": "Le courant revient…", 
		"crouch_off": "Debout",
		"notes": "NOTES %d/5",
		"note_1": "NOTE 1/5 : « 31 octobre 1997. Elle est revenue. Ne cours pas : elle entend le sol. »",
		"note_2": "NOTE 2/5 : « Le sucre l'attire. J'en ai collé partout dans la cuisine. »",
		"note_3": "NOTE 3/5 : « La clé dorée change de place chaque nuit. Je l'ai vue à l'étage. »",
		"note_4": "NOTE 4/5 : « Si tu l'entends renifler, accroupis-toi. Elle ne voit rien du tout. »",
		"note_5": "NOTE 5/5 : « Si tu lis ceci, on se retrouve dehors. Cours. »",
		"obj_short": "porte EST VERROUILLÉE : trouve la clé dorée · marche doucement · C = s'accroupir · E = bonbon · F = piège collant",
		"how_go": "C'EST PARTI",
		"candy_title": "BONBON MAUDIT GAGNÉ — choisis : ",
		"candy_got": "Tu gardes : %s",
		"candy_throw": "Bonbon lancé ! ELLE s'arrête…",
		"candy_pickup": "Bonbon ramassé ! E = le lancer pour faire diversion. F = piège collant.",
		"locked": "VERROUILLÉE. Il faut la clé dorée… elle brille quelque part dans la maison.",
		"unlocked": "Chambre déverrouillée.",
		"key_pick_e": "CLÉ DE SORTIE ! La porte Est s'ouvre.",
		"key_pick_c": "Clé de la chambre… la porte verrouillée du couloir Sud t'attend.",
		"hidden_t": "Tu es caché. Elle ne peut rien contre toi ici. Ressors quand c'est calme.",
		"glue_set": "Sucre collant posé ! Elle y restera engluée quelques secondes.",
		"key_e_s": "clé sortie ✓",
		"key_c_s": "clé chambre ✓",
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
		"sub": "one night in the haunted house",
		"cam_rec": "CAMCORDER",
		"cam_batt": "BATT %d%%",
		"cam_rewind": "\u25c0\u25c0 REWINDING \u2014 she heard you",
		"cam_low": "NOT ENOUGH BATTERY TO REWIND",
		"cam_empty": "BATTERY DEAD \u2014 the camcorder shuts off",
		"cam_pile": "BATTERY +%d%%",
		"cam_pick": "[R] rewind  \u00b7  [BATTERIES] recharge the camcorder",
		"heard": "SHE HEARD SOMETHING. She is coming.",
		"hide_warn": "DO NOT MOVE. She is right next to you.",
		"hide_busted": "SHE HEARD YOU MOVE!",
		"play": "ENTER",
		"warn": "headphones recommended — don't play in the dark… actually, do.",
		"controls": "WASD / ZQSD / arrows: walk · SHIFT: run (stamina!) · MOUSE: look · RIGHT CLICK or T: CAMCORDER (see in the dark) · R: REWIND 20 s (battery + it draws her) · G: flashlight · E: throw candy (decoy) · F: sticky sugar (slows her) · V: VHS grain · ESC: pause",
		"rules_tip": "Read the sign. Obey.",
		"exit_lbl": "EXIT",
		"progress": "EXIT: %d m",
		"obj_heart": "SHE IS BLIND. She hears your heart. Cross the house to the exit door.",
		"hint_listen": "She hears you: walk slowly, or stop to calm your heart.",
		"arch_closed": "Safe room sealed behind you. She cannot follow.",
		"graze": "The Caramel candy tears you from her grasp!",
		"noise_lbl": "NOISE",
		"dead3": "She took you back. The house keeps you.",
		"win": "YOU GOT OUT",
		"win_sub": "You are outside. The cool night air fills your lungs. You survived the 31st.",
		"dead": "CAUGHT",
		"dead_sub": "You should have answered. Or run faster.",
		"replay": "REPLAY",
		"loops": "caught: %d   candies: %d",
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
		"how_1": "1. The house is DARK: your flashlight (G) is your best friend. The exit is EAST — but it's LOCKED: find the golden key (new spot every run).",
		"how_2": "2. SHE is blind but hears your steps, and she WALKS and RUNS like a beast. Sprint = noise = she hunts you. Some floorboards creak.",
		"how_3": "3. Candies (5): E = decoy, F = sticky sugar trap that slows her down. A 2nd key opens the locked bedroom (candy + wardrobe inside).",
		"how_4": "4. 4 HIDING SPOTS where she can't reach you: wardrobes (bedrooms, garage) and the stair nook. The steep garage stairs climb to the UPSTAIRS: one more room to search — she hears you badly through the floor.",
		"how_5": "5. If she touches you: you wake at the entrance (3 random spawn points). 3 catches = game over. Get out alive.",
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
		"toast_arrow": "Find the golden key: it glows somewhere in the house.",
		"crouch_on": "Crouching: you make almost no sound (C to stand up)",
		"blackout_on": "POWER CUT — the house is dark. Stay on your flashlight.",
		"blackout_end": "The power comes back…", 
		"crouch_off": "Standing",
		"notes": "NOTES %d/5",
		"note_1": "NOTE 1/5: \"October 31, 1997. She is back. Don't run: she hears the floor.\"",
		"note_2": "NOTE 2/5: \"Sugar lures her. I glued it all over the kitchen.\"",
		"note_3": "NOTE 3/5: \"The golden key moves every night. I saw it upstairs.\"",
		"note_4": "NOTE 4/5: \"If you hear her sniffing, crouch. She sees nothing at all.\"",
		"note_5": "NOTE 5/5: \"If you read this, meet me outside. Run.\"",
		"obj_short": "EAST door LOCKED: find the golden key · walk softly · C = crouch · E = candy · F = sticky trap",
		"how_go": "LET'S GO",
		"candy_title": "CURSED CANDY EARNED — pick: ",
		"candy_got": "You keep: %s",
		"candy_throw": "Candy thrown! SHE stops…",
		"candy_pickup": "Candy picked up! E = throw it as a decoy. F = sticky trap.",
		"locked": "LOCKED. You need the golden key… it glows somewhere in the house.",
		"unlocked": "Bedroom unlocked.",
		"key_pick_e": "EXIT KEY! The East door will open.",
		"key_pick_c": "Bedroom key… the locked door on the South corridor awaits.",
		"hidden_t": "You are hidden. She can't reach you here. Leave when it's quiet.",
		"glue_set": "Sticky sugar deployed! She'll be slowed to a crawl.",
		"key_e_s": "exit key ✓",
		"key_c_s": "room key ✓",
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
var flash_rect: ColorRect
var scare_t := 0.0
var crouch := false
var notes_found := 0
var taken_notes := [false, false, false, false, false]
var note_meshes: Array = []
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
var progress := 0
var section := 0
var noise := 0.0
var bait_t := -1.0
var bait_timer := 0.0
var alert_t := 0.0
var entity_mode := 0
var patrol_dir := 1.0
var graze := 0
var catches := 0
var arch_closed := [false, false, false]
var creak_planks: Array = []
var arch_nodes: Array = []
var plank_nodes: Array = []

func _ensure_music() -> void:
	if music_pl == null:
		music_pl = AudioStreamPlayer.new()
		music_pl.playback_type = AudioServer.PLAYBACK_TYPE_STREAM
		add_child(music_pl)
		music_pl.stream = load("res://assets/audio/music.wav")
		music_pl.stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		music_pl.volume_db = -4.0 + linear_to_db(maxf(vol_music, 0.001))


# ---------------------------------------------------------------- nodes ----

# ---------------------------------------------------------------- state ----
var mistakes := 0
var loops := 0
var anomaly := ""
var chasing := false
var locked := false
var whisper_timer := 0.0
var rng := RandomNumberGenerator.new()
var dbg := ""
var intro_t := 0.0
var run_time := 0.0
var flicker_idx := -1
var flicker_t := 0.0
var ent_phase := 0.0
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
# ================= v14 : CAMERA A (camescope Hi8) =================
const CAM_SHADER := """
shader_type canvas_item;
uniform sampler2D screen_tex : hint_screen_texture, filter_linear;
uniform float fade := 1.0;
uniform float vig := 0.92;
uniform float grain := 0.09;
uniform float scan := 0.10;
uniform float glitch := 0.0;
uniform vec3 tint := vec3(0.60, 1.00, 0.68);
float h21(vec2 p) { return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453); }
void fragment() {
	vec2 uv = SCREEN_UV;
	float jit = (h21(vec2(floor(uv.y * 200.0), floor(TIME * 22.0))) - 0.5) * glitch * 0.06;
	uv.x += jit;
	vec3 orig = texture(screen_tex, SCREEN_UV).rgb;
	vec3 c = texture(screen_tex, uv).rgb;
	float l = dot(c, vec3(0.299, 0.587, 0.114));
	c = mix(c, vec3(l), 0.55);
	c *= tint;
	float n = h21(uv * vec2(1280.0, 720.0) + vec2(TIME * 91.0, TIME * 57.0));
	c += (n - 0.5) * (grain + glitch * 0.40);
	float sl = sin(uv.y * 640.0 + TIME * 2.0) * 0.5 + 0.5;
	c *= 1.0 - sl * scan;
	vec2 dv = uv - vec2(0.5);
	dv.x *= 1.30;
	float v = smoothstep(0.78, 0.20, length(dv));
	c *= mix(0.10, 1.0, v);
	COLOR = vec4(mix(orig, c, fade), 1.0);
}
"""
# ================= v15 : monstre a 6 parties (T-pose, bras animes) =================
var ent_model_kind := 2        # 2 = v17 (10 parties) · 1 = v15 (6) · 0 = v13 (4)
var ent_prev_phase := 0.0
var ent_anim_dbg := 0
var ent_step: AudioStreamPlayer3D = null
var ent_spawn_delay := 75.0    # v17 : elle dort tant que tu n'as pas touche a une note (ou 75 s)
var creek_sfx_t := 6.0
# ================= v16 : laisse d'ecoute + discipline de cachette =================
var heard_pos := Vector2.ZERO
var heard_lvl := 0
var heard_t := 0.0
var heard_cd := 0.0
var hide_warn_cd := 0.0
var hide_busted := false
var dbg_m2_i := 0
var cam_held := false          # clic droit maintenu
var cam_sticky := false        # T (bascule)
var cam_raised := false
var cam_grade := 0.0
var battery := 100.0
var battery_charges := 0
var rewinding := 0.0
var rewind_cd := 0.0
var rewind_pos := Vector3.ZERO
var lowbatt_t := 1.5
var trail: Array = []
var trail_t := 0.0
var trail_mi: MeshInstance3D = null
var ent_marker: MeshInstance3D = null
var cam_overlay: ColorRect = null
var cam_lbl: Label = null
var batt_bg: ColorRect = null
var batt_fill: ColorRect = null
var sfx_click: AudioStreamPlayer = null
var sfx_tape: AudioStreamPlayer = null
var sfx_lowbatt: AudioStreamPlayer = null
var piles: Array = []
var dbg_cam_i := 0
var dust: GPUParticles3D = null
var candies := {}
var pocket := 1
var candy_offer := []
var candy_timer := 0.0
var mirror_timer := 0.0
var entity_stun := 0.0
var pocket_lbl: Label = null
var noise_bg: ColorRect = null
var noise_fill: ColorRect = null
var noise_lbl: Label = null
var poster_base := "poster_a"
var wind_pl: AudioStreamPlayer = null
var house_pl: AudioStreamPlayer = null
var tension_pl: AudioStreamPlayer = null
var music_pl: AudioStreamPlayer = null
const CANDY_IDS := ["miroir", "reglisse", "caramel", "sucre"]
const AUDIT_LIST := ["poster", "pumpkin", "light", "figure", "rules", "door", "whisper", "stain", "flip", "flicker", "cross", "extradoor", "chase"]


func _ready() -> void:
	var seed_ovr := -1
	for a in OS.get_cmdline_args():
		if a.begins_with("--dbg"):
			dbg = a.split("=")[1] if "=" in a else "smart"
		if a.begins_with("--seed="):
			seed_ovr = int(a.split("=")[1])
	rng.seed = seed_ovr if seed_ovr >= 0 else hash("le31") % 99991
	_load_settings()
	_build_world()
	_build_player()
	_build_ui()
	_build_vhs()
	_build_reverb()
	_ensure_music()
	music_pl.play()
	_apply_volumes()
	state = "title"
	if dbg == "" and not how_seen:
		howto_ctl.visible = true
	if dbg != "":
			_start("fr")
			_begin_run()
	

# ============================================================ chemin ======

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
	if set_name == "wall":
		m.albedo_color = Color(0.60, 0.56, 0.53)
	elif set_name == "ceil":
		m.albedo_color = Color(0.85, 0.83, 0.80)
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

func _collider_box(sz: Vector3, at: Vector3) -> void:
	var b := StaticBody3D.new()
	var c := CollisionShape3D.new()
	var bm: BoxShape3D = BoxShape3D.new()
	bm.size = sz
	c.shape = bm
	b.add_child(c)
	b.position = at
	world.add_child(b)



func _build_world() -> void:
	world = Node3D.new()
	add_child(world)
	dyn = Node3D.new()
	world.add_child(dyn)
	env = Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.006, 0.006, 0.008)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.40, 0.33, 0.30)
	env.ambient_light_energy = 0.30
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
	# Preset SÛR auto : SDFGI + fog volumétrique sont instables sur pilotes Intel/Arc (et logiciels)
	var gpu_n := RenderingServer.get_video_adapter_name().to_lower()
	if gpu_n.contains("intel") or gpu_n.contains("arc") or gpu_n.contains("llvmpipe") or gpu_n.contains("lavapipe"):
		quality_high = false
		env.sdfgi_enabled = false
		env.volumetric_fog_enabled = false
	var we := WorldEnvironment.new()
	we.environment = env
	world.add_child(we)

# ================================================== MAISON (plan v9) ======
const H_W := 20.0
const H_D := 14.0
const WALL_H := 2.9
const WALL_T := 0.3
var spawn_pos := Vector2(1.2, 7.0)
var exit_pos := Vector2(19.7, 7.0)
const NODES := [Vector2(2, 7), Vector2(10, 7), Vector2(17.5, 7), Vector2(3.5, 3), Vector2(10, 2.8), Vector2(16.5, 3), Vector2(4.5, 9.3), Vector2(8, 11), Vector2(12.5, 11), Vector2(17.5, 11), Vector2(1.5, 7.5), Vector2(9.0, 5.0), Vector2(16.0, 7.0), Vector2(1.5, 12.9)]
const EDGES := [[0, 1], [1, 2], [0, 3], [1, 4], [2, 5], [0, 6], [1, 7], [1, 8], [2, 9], [6, 13], [13, 10], [10, 11], [10, 12]]
const NODE_LVL := [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1, 1, 1, 0]
const LEVEL_Y := [0.0, 2.98]
const RAMP_RECT := [Vector2(0.9, 7.4), Vector2(2.1, 12.5)]
const CANDY_SPOTS := [Vector3(9.5, 0, 3.5), Vector3(2.2, 0, 1.2), Vector3(14, 0, 13), Vector3(1.2, 0, 12.5), Vector3(16.2, 2.98, 11.5)]
const CREEK_ZONES := [Vector3(5.5, 6.1, 0.6), Vector3(12.0, 7.9, 0.6), Vector3(10.3, 4.4, 0.6), Vector3(2.6, 2.2, 0.6), Vector3(13.4, 12.2, 0.6)]
var creek_cd := [0.0, 0.0, 0.0, 0.0, 0.0]
var candy_taken := [false, false, false, false, false]
var candy_meshes: Array = []
var entity_node := 6
var entity_target := 6
var entity_target_pos := Vector2(8, 11)
var entity_path: Array = []
var entity_path_from := -1
var entity_path_to := -1
var bait_pos := Vector2(8, 7)
var chase_t := 0.0
var graze_cd := 0.0
var has_key_exit := false
var has_key_ch1 := false
var key_exit_pos := Vector2(16.9, 3.4)
var key_exit_lvl := 0
var key_exit_y := 0.0
var key_ch1_pos := Vector2(2.6, 7.4)
var key_ch1_lvl := 0
var key_ch1_y := 0.0
var key_mesh_e: Node3D = null
var key_mesh_c: Node3D = null
var hidden := false
var lock_cd := 0.0
var ch1_locked := true
var ch1_door_node: Node3D = null
var ch1_col: StaticBody3D = null
var glue_zones: Array = []
var ent_glued := false
var hide_cd := 0.0
var dbg_had_key := false
var player_level := 0
var ent_level := 0
var entity_target_lvl := 0
var bait_level := 0
var bot_level := 0
var dbg_stuck_t := 0.0
var dbg_move_frames := 0
var stair_t := -1.0
var stair_cd := 0.0
var blackout_t := 0.0
var blackout_cd := 55.0
var blackout_on := false
var ent_breath: AudioStreamPlayer3D = null
var ent_growl: AudioStreamPlayer3D = null
var ent_sniff: AudioStreamPlayer3D = null
var growl_t := 1.5
var sniff_t := 2.0
var stair_dir := 1
var dbg_move_dir := Vector2.ZERO
var dbg_last_pos := Vector2.ZERO
var dbg_jdir := 1.0
const KEY_SPOTS_A := [Vector3(16.9, 0, 3.4), Vector3(3.9, 0, 3.4), Vector3(9.8, 0, 7.2), Vector3(15.8, 2.98, 3.0)]
const KEY_SPOTS_B := [Vector3(2.6, 0, 7.4), Vector3(11.2, 0, 2.4), Vector3(17.9, 0, 7.4), Vector3(6.5, 2.98, 2.5)]
const NOTE_SPOTS := [Vector3(4.7, 0, 13.3), Vector3(2.2, 0, 2.2), Vector3(11.0, 0, 2.0), Vector3(9.0, 0, 12.6), Vector3(15.6, 2.98, 3.4)]
const HIDE_SPOTS := [Vector3(8.0, 0, 12.6), Vector3(15.8, 0, 9.7), Vector3(3.0, 0, 9.9), Vector3(18.8, 2.98, 2.2)]
const SPAWN_POINTS := [Vector2(1.2, 7.0), Vector2(2.0, 2.0), Vector2(11.5, 2.2)]
var dbg_path: Array = []
var shot_i := 0
var shot_frames := 0
var dbg_done_path := false


func _node_of(p: Vector2, lvl := -1) -> int:
	var best := 0
	var bd := 1e9
	for i in range(NODES.size()):
		if lvl >= 0 and NODE_LVL[i] != lvl:
			continue
		var dd: float = (NODES[i] - p).length()
		if dd < bd:
			bd = dd
			best = i
	if lvl >= 0 and NODE_LVL[best] != lvl:
		best = 10 if lvl == 1 else 1
	return best


func _terrain_y(p: Vector2, lvl: int) -> float:
	if p.x >= RAMP_RECT[0].x and p.x <= RAMP_RECT[1].x and p.y >= RAMP_RECT[0].y and p.y <= RAMP_RECT[1].y:
		var idx := int(floor((12.4 - p.y) / 0.2146))
		return clampf(idx * 0.124, 0.0, 2.98)
	return LEVEL_Y[lvl]


func _bfs_path(a: int, b: int) -> Array:
	if a == b:
		return [b]
	var prev := {}
	var seen := {a: true}
	var q := [a]
	while q.size():
		var cur: int = q.pop_front()
		for e in EDGES:
			var nx := -1
			if e[0] == cur:
				nx = e[1]
			elif e[1] == cur:
				nx = e[0]
			if nx >= 0 and not seen.has(nx):
				seen[nx] = true
				prev[nx] = cur
				q.append(nx)
				if nx == b:
					var path := [b]
					var c := b
					while c != a:
						c = prev[c]
						path.push_front(c)
					return path
	return [b]


func _wall_seg(x1: float, z1: float, x2: float, z2: float) -> void:
	var dx := x2 - x1
	var dz := z2 - z1
	var ln := Vector2(dx, dz).length()
	if ln < 0.01:
		return
	var cx := (x1 + x2) / 2.0
	var cz := (z1 + z2) / 2.0
	var ang := atan2(dz, dx)
	var m := _pbr("wall")
	# v11 : BOÎTE (l'ancien quad était invisible d'un côté selon l'ordre des points -> murs qui disparaissent)
	var wb := _box(Vector3(ln + WALL_T, WALL_H, WALL_T), m)
	wb.position = Vector3(cx, WALL_H / 2.0, cz)
	wb.rotation = Vector3(0, -ang, 0)
	world.add_child(wb)
	var col := StaticBody3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(ln + WALL_T, WALL_H, WALL_T)
	var cs := CollisionShape3D.new()
	cs.shape = bs
	col.add_child(cs)
	col.position = Vector3(cx, WALL_H / 2.0, cz)
	col.rotation = Vector3(0, -ang, 0)
	world.add_child(col)

func _room_floor(x1: float, z1: float, x2: float, z2: float, mat: StandardMaterial3D) -> void:
	# v11 : dalle BOÎTE. L'ancien quad tourné (PI/2,0,PI/2) avait une normale VERTICALE
	# (-1,0,0) -> sol invisible de dessus + mur fantôme vertical au centre de chaque pièce.
	var sl := _box(Vector3(x2 - x1, 0.10, z2 - z1), mat)
	sl.position = Vector3((x1 + x2) / 2.0, -0.05, (z1 + z2) / 2.0)
	world.add_child(sl)


func _furn(sz: Vector3, at: Vector3, m: StandardMaterial3D, rot_y := 0.0, rot_x := 0.0) -> MeshInstance3D:
	var b := _box(sz, m)
	b.position = at
	b.rotation = Vector3(rot_x, rot_y, 0)
	world.add_child(b)
	var col := StaticBody3D.new()
	var bs := BoxShape3D.new()
	bs.size = sz
	var cs := CollisionShape3D.new()
	cs.shape = bs
	col.add_child(cs)
	col.position = at
	col.rotation = Vector3(rot_x, rot_y, 0)
	world.add_child(col)
	return b


func _door_panel(at: Vector2, side: float) -> void:
	var wood := _pbr("door")
	var b := _box(Vector3(0.9, 2.1, 0.07), wood)
	var hinge := Vector2(at.x + side * 0.72, at.y)
	var th := 1.52 * (1.0 if side > 0 else -1.0)
	b.position = Vector3(hinge.x + cos(th) * 0.45, 1.05, hinge.y - sin(th) * 0.45)
	b.rotation = Vector3(0, th, 0)
	world.add_child(b)
	var col := StaticBody3D.new()
	var cs := CollisionShape3D.new()
	var bs := BoxShape3D.new()
	bs.size = Vector3(0.9, 2.1, 0.09)
	cs.shape = bs
	col.add_child(cs)
	col.position = b.position
	col.rotation = Vector3(0, th, 0)
	world.add_child(col)
	var fr := _simple(Color(0.13, 0.09, 0.06), 0.55)
	for sd in [-1, 1]:
		var j2 := _box(Vector3(0.10, 2.3, 0.10), fr)
		j2.position = Vector3(at.x + 0.78 * sd, 1.15, at.y)
		world.add_child(j2)
		var jc := StaticBody3D.new()
		var jcs := CollisionShape3D.new()
		var jbs := BoxShape3D.new()
		jbs.size = Vector3(0.10, 2.3, 0.10)
		jcs.shape = jbs
		jc.add_child(jcs)
		jc.position = j2.position
		world.add_child(jc)
	var poig := _simple(Color(0.35, 0.3, 0.2), 0.3, 0.8)
	var pg := _box(Vector3(0.03, 0.12, 0.03), poig)
	pg.position = Vector3(b.position.x - cos(th) * 0.38 * 0.9, 1.05, b.position.z + sin(th) * 0.38 * 0.9)
	world.add_child(pg)

func _build_house() -> void:
	var fw := _pbr("floor")
	fw.normal_enabled = false
	var tilem := _pixel("res://assets/tex/tile.png")
	tilem.roughness = 0.35
	# sols
	_room_floor(0, 5.0, 20, 9.0, fw)
	_room_floor(0, 0, 7, 5.0, fw)
	_room_floor(7, 0, 13, 5.0, tilem)
	_room_floor(13, 0, 20, 5.0, tilem)
	_room_floor(0, 9.0, 6, 14, tilem)
	_room_floor(6, 9.0, 10, 14, fw)
	_room_floor(10, 9.0, 15, 14, fw)
	_room_floor(15, 9.0, 20, 14, fw)
# plafond : assuré par la dalle de l'étage (boîtes 2.82-2.98), trémie de l'escalier laissée ouverte.
# (l'ancien quad de plafond était un mur fantôme vertical qui coupait la maison en deux)
	# murs extérieurs (ouverture sortie est z 6.4-7.6)
	_wall_seg(0, 0, 20, 0)
	_wall_seg(0, 14, 20, 14)
	_wall_seg(0, 0, 0, 14)
	_wall_seg(20, 0, 20, 6.2)
	_wall_seg(20, 7.8, 20, 14)
	# mur nord intérieur z=5.0 (3 portes larges 1.6 m)
	_wall_seg(0, 5.0, 2.75, 5.0)
	_wall_seg(4.35, 5.0, 9.25, 5.0)
	_wall_seg(10.85, 5.0, 15.75, 5.0)
	_wall_seg(17.35, 5.0, 20, 5.0)
	# mur sud intérieur z=9.0 (4 portes larges 1.6 m)
	_wall_seg(0, 9.0, 2.25, 9.0)
	_wall_seg(3.85, 9.0, 7.25, 9.0)
	_wall_seg(8.85, 9.0, 11.75, 9.0)
	_wall_seg(13.35, 9.0, 16.75, 9.0)
	_wall_seg(18.35, 9.0, 20, 9.0)
	# piliers de jonction : plus aucun trou aux raccords
	for jp in [Vector2(0, 0), Vector2(20, 0), Vector2(0, 14), Vector2(20, 14), Vector2(0, 5.0), Vector2(20, 5.0), Vector2(0, 9.0), Vector2(20, 9.0), Vector2(7, 0), Vector2(13, 0), Vector2(7, 5.0), Vector2(13, 5.0), Vector2(6, 14), Vector2(10, 14), Vector2(15, 14), Vector2(6, 9.0), Vector2(10, 9.0), Vector2(15, 9.0)]:
		var pil := _box(Vector3(0.42, WALL_H, 0.42), _pbr("wall"))
		pil.position = Vector3(jp.x, WALL_H / 2.0, jp.y)
		world.add_child(pil)
		var pcol := StaticBody3D.new()
		var pcs := CollisionShape3D.new()
		var pbs := BoxShape3D.new()
		pbs.size = Vector3(0.42, WALL_H, 0.42)
		pcs.shape = pbs
		pcol.add_child(pcs)
		pcol.position = Vector3(jp.x, WALL_H / 2.0, jp.y)
		world.add_child(pcol)
	# cloisons
	_wall_seg(7, 0, 7, 5.0)
	_wall_seg(13, 0, 13, 5.0)
	_wall_seg(6, 9.0, 6, 14)
	_wall_seg(10, 9.0, 10, 14)
	_wall_seg(15, 9.0, 15, 14)
	# panneaux de porte entrebâillés (solides) dans chaque ouverture
	_door_panel(Vector2(3.55, 5.0), 1.0)
	_door_panel(Vector2(10.05, 5.0), -1.0)
	_door_panel(Vector2(16.55, 5.0), 1.0)
	_door_panel(Vector2(3.05, 9.0), -1.0)
	_door_panel(Vector2(8.05, 9.0), 1.0)
	var c1d := _box(Vector3(1.6, 2.1, 0.09), _pbr("door"))
	c1d.position = Vector3(12.55, 1.05, 9.0)
	world.add_child(c1d)
	ch1_door_node = c1d
	ch1_col = StaticBody3D.new()
	var c1cs := CollisionShape3D.new()
	var c1bs := BoxShape3D.new()
	c1bs.size = Vector3(1.6, 2.1, 0.12)
	c1cs.shape = c1bs
	ch1_col.add_child(c1cs)
	ch1_col.position = Vector3(12.55, 1.05, 9.0)
	world.add_child(ch1_col)
	var c1k := _box(Vector3(0.06, 0.06, 0.03), _simple(Color(0.5, 0.4, 0.15), 0.3, 0.9))
	c1k.position = Vector3(13.1, 1.05, 9.07)
	world.add_child(c1k)
	_door_panel(Vector2(17.55, 9.0), 1.0)
	# meubles salon
	var woodm := _pbr("door")
	var cloth := _simple(Color(0.25, 0.12, 0.10), 0.9)
	_furn(Vector3(2.2, 0.8, 0.9), Vector3(2.0, 0.4, 4.3), cloth)
	_furn(Vector3(1.4, 0.5, 0.8), Vector3(4.3, 0.25, 2.6), woodm)
	_furn(Vector3(0.5, 1.8, 3.0), Vector3(0.45, 0.9, 2.6), woodm)
	# cuisine
	_furn(Vector3(5.2, 0.9, 0.8), Vector3(10.0, 0.45, 0.7), tilem)
	_furn(Vector3(0.8, 1.8, 0.8), Vector3(12.4, 0.9, 0.7), _simple(Color(0.7, 0.7, 0.72), 0.3, 0.6))
	_furn(Vector3(1.6, 0.75, 1.0), Vector3(9.5, 0.38, 3.5), woodm)
	# salle de bains
	_furn(Vector3(1.7, 0.6, 0.8), Vector3(18.6, 0.3, 1.0), _simple(Color(0.85, 0.85, 0.88), 0.15))
	_furn(Vector3(0.6, 0.8, 0.5), Vector3(14.0, 0.4, 0.55), _simple(Color(0.85, 0.85, 0.88), 0.15))
	_furn(Vector3(0.5, 0.75, 0.55), Vector3(16.2, 0.38, 0.5), _simple(Color(0.8, 0.8, 0.82), 0.2))
	# garage : voiture + étagère
	_furn(Vector3(4.2, 1.1, 2.0), Vector3(4.25, 0.65, 11.6), _simple(Color(0.16, 0.035, 0.03), 0.35, 0.5))
	_furn(Vector3(2.3, 0.65, 1.7), Vector3(4.0, 1.5, 11.6), _simple(Color(0.14, 0.03, 0.028), 0.3, 0.5))
	_furn(Vector3(2.1, 0.5, 1.6), Vector3(4.05, 1.42, 11.6), _simple(Color(0.02, 0.02, 0.025), 0.1, 0.1))
	for wz in [10.3, 12.9]:
		for wx in [2.9, 5.5]:
			_furn(Vector3(0.7, 0.7, 0.25), Vector3(wx, 0.35, wz), _simple(Color(0.05, 0.05, 0.05), 0.8))
	_furn(Vector3(0.5, 2.0, 3.4), Vector3(6.0, 1.0, 11.5), woodm)
	# escalier du garage -> ÉTAGE (rampe physique + marches déco)
	var ramp_len := sqrt(5.15 * 5.15 + 2.98 * 2.98)
	var ramp_ang := atan2(2.98, 5.15)
	var ramp := _box(Vector3(1.2, 0.16, ramp_len), woodm)
	ramp.position = Vector3(1.5, 1.49, 9.92)
	ramp.rotation = Vector3(ramp_ang, 0, 0)
	world.add_child(ramp)
	for st in range(24):
		var scz := 12.4 - st * 0.2146
		var scy := (st + 1) * 0.124 - 0.062
		_furn(Vector3(1.2, 0.124, 0.26), Vector3(1.5, scy, scz), woodm)
	for rx in [0.92, 2.08]:
		var rail := _box(Vector3(0.06, 0.5, ramp_len), woodm)
		rail.position = Vector3(rx, 1.49 + 0.42, 9.92)
		rail.rotation = Vector3(ramp_ang, 0, 0)
		world.add_child(rail)
	# dalle de l'étage (trémie au-dessus de la rampe) + murs hauts + toit
	var slabm := _pbr("ceil")
	for sp in [Vector3(0.4, 2.9, 7.0), Vector3(11.1, 2.9, 7.0), Vector3(1.5, 2.9, 3.45), Vector3(1.5, 2.9, 11.05)]:
		var sw := 0.8 if sp.x < 1 else (17.8 if sp.x > 10 else 1.4)
		var sd2 := 14.0 if sp.z == 7.0 else (6.9 if sp.z < 7 else 5.9)
		var sl := _box(Vector3(sw, 0.16, sd2), slabm)
		sl.position = Vector3(sp.x, sp.y, sp.z)
		world.add_child(sl)
		_furn(Vector3(sw, 0.16, sd2), sp, slabm)
	var upw := _pbr("wall")
	for uw in [Vector3(20.0, 2.22, 0.3), Vector3(20.0, 2.22, 0.3), Vector3(0.3, 2.22, 14.0), Vector3(0.3, 2.22, 14.0)]:
		pass
	var uw1 := _box(Vector3(20.6, 2.22, 0.3), upw)
	uw1.position = Vector3(10.0, 4.09, 0.0)
	world.add_child(uw1)
	_furn(Vector3(20.6, 2.22, 0.3), Vector3(10.0, 4.09, 0.0), upw)
	var uw2 := _box(Vector3(20.6, 2.22, 0.3), upw)
	uw2.position = Vector3(10.0, 4.09, 14.0)
	world.add_child(uw2)
	_furn(Vector3(20.6, 2.22, 0.3), Vector3(10.0, 4.09, 14.0), upw)
	var uw3 := _box(Vector3(0.3, 2.22, 14.6), upw)
	uw3.position = Vector3(0.0, 4.09, 7.0)
	world.add_child(uw3)
	_furn(Vector3(0.3, 2.22, 14.6), Vector3(0.0, 4.09, 7.0), upw)
	var uw4 := _box(Vector3(0.3, 2.22, 14.6), upw)
	uw4.position = Vector3(20.0, 4.09, 7.0)
	world.add_child(uw4)
	_furn(Vector3(0.3, 2.22, 14.6), Vector3(20.0, 4.09, 7.0), upw)
	var roof := _box(Vector3(20.6, 0.2, 14.6), _pbr("ceil"))
	roof.position = Vector3(10.0, 5.3, 7.0)
	world.add_child(roof)
	# cloison de l'étage (porte au centre) + linteau
	var pw1 := _box(Vector3(0.2, 2.22, 5.9), upw)
	pw1.position = Vector3(12.5, 4.09, 3.25)
	world.add_child(pw1)
	_furn(Vector3(0.2, 2.22, 5.9), Vector3(12.5, 4.09, 3.25), upw)
	var pw2 := _box(Vector3(0.2, 2.22, 5.9), upw)
	pw2.position = Vector3(12.5, 4.09, 10.75)
	world.add_child(pw2)
	_furn(Vector3(0.2, 2.22, 5.9), Vector3(12.5, 4.09, 10.75), upw)
	var pw3 := _box(Vector3(0.2, 0.4, 1.6), upw)
	pw3.position = Vector3(12.5, 5.0, 7.0)
	world.add_child(pw3)
	_furn(Vector3(0.2, 0.4, 1.6), Vector3(12.5, 5.0, 7.0), upw)
	# props étage : matelas, cartons, lit, tapis, fenêtre lumineuse
	_furn(Vector3(2.2, 0.3, 1.6), Vector3(8.5, 3.13, 3.1), cloth)
	for ub in [Vector3(2.2, 3.2, 12.6), Vector3(2.7, 3.2, 13.1), Vector3(2.45, 3.65, 12.85)]:
		_furn(Vector3(0.5, 0.5, 0.5), ub, _simple(Color(0.35, 0.26, 0.16), 0.8))
	_furn(Vector3(2.0, 0.6, 1.6), Vector3(17.5, 3.28, 12.6), cloth)
	var urug := _quad(Vector2(2.2, 1.6), _simple(Color(0.12, 0.08, 0.14), 0.9))
	urug.rotation = Vector3(0, 0, 0)
	urug.position = Vector3(16.0, 3.0, 7.0)
	world.add_child(urug)
	var uwin := _quad(Vector2(1.4, 1.0), _emissive(Color(0.35, 0.42, 0.6), 1.1, ""))
	uwin.rotation = Vector3(PI / 2, 0, 0)
	uwin.position = Vector3(8.0, 4.2, 0.16)
	world.add_child(uwin)
	# lampes de l'étage (une allumée, une morte) + placard-cachette haut
	for ul in [Vector2(8.0, 7.0), Vector2(16.0, 7.0)]:
		var uli := OmniLight3D.new()
		uli.light_color = Color(1.0, 0.8, 0.55)
		uli.light_energy = 5.0 if ul.x < 10 else 0.0
		uli.omni_range = 8.0
		uli.position = Vector3(ul.x, 4.6, ul.y)
		uli.shadow_enabled = false
		world.add_child(uli)
		var ubm := _emissive(Color(1.0, 0.9, 0.7), 4.0 if ul.x < 10 else 0.0, "")
		var ubu := MeshInstance3D.new()
		var usm := SphereMesh.new()
		usm.radius = 0.07
		usm.height = 0.14
		ubu.mesh = usm
		ubu.material_override = ubm
		ubu.position = Vector3(ul.x, 4.6, ul.y)
		world.add_child(ubu)
		lamps.append([uli, ubm, ubu, ul.x < 10])
	for hd in [Vector3(-0.55, 0, 0), Vector3(0.55, 0, 0), Vector3(0, 0, -0.55)]:
		var hw := _box(Vector3(0.08 if hd.x != 0 else 1.2, 2.0, 1.2 if hd.x != 0 else 0.08), _pbr("wall"))
		hw.position = Vector3(18.8 + hd.x, 3.98, 2.2 + hd.z)
		world.add_child(hw)
	var uht := _box(Vector3(1.2, 0.08, 1.2), _pbr("wall"))
	uht.position = Vector3(18.8, 4.98, 2.2)
	world.add_child(uht)
	# chambre 1
	_furn(Vector3(2.0, 0.6, 1.6), Vector3(12.5, 0.3, 12.6), cloth)
	_furn(Vector3(0.6, 2.0, 1.2), Vector3(10.5, 1.0, 10.0), woodm)
	_furn(Vector3(0.5, 0.55, 0.5), Vector3(14.2, 0.28, 13.4), woodm)
	# chambre 2
	_furn(Vector3(2.0, 0.6, 1.6), Vector3(17.5, 0.3, 12.6), cloth)
	_furn(Vector3(1.2, 0.75, 0.6), Vector3(19.2, 0.38, 9.3), woodm)
	# lampes
	var lit_ids := [1, 4, 7]
	var li2 := 0
	for lp in [Vector2(5, 7), Vector2(10, 7), Vector2(15, 7), Vector2(3.5, 3), Vector2(10, 3), Vector2(16.5, 3), Vector2(3, 11), Vector2(8, 11), Vector2(12.5, 11), Vector2(17.5, 11)]:
		world.add_child(_make_lamp(Vector3(lp.x, 0, lp.y), li2 in lit_ids))
		li2 += 1
	# porte de sortie (panneau fermé + panneau EXIT lumineux)
	exit_door = Node3D.new()
	exit_door.position = Vector3(exit_pos.x + 0.2, 0, exit_pos.y)
	var eq := _quad(Vector2(1.15, 2.2), _emissive(Color(1, 0.85, 0.55), 0.5, "res://assets/tex/exit.png"))
	eq.rotation = Vector3(PI / 2, 0, PI / 2)
	eq.position = Vector3(0, 1.1, 0)
	exit_door.add_child(eq)
	var el := OmniLight3D.new()
	el.light_color = Color(1.0, 0.8, 0.5)
	el.light_energy = 3.0
	el.omni_range = 5.0
	el.position = Vector3(-0.4, 1.6, 0)
	exit_door.add_child(el)
	world.add_child(exit_door)
	var exit_col := StaticBody3D.new()
	var ebs := BoxShape3D.new()
	ebs.size = Vector3(0.3, WALL_H, 1.2)
	var ecs := CollisionShape3D.new()
	ecs.shape = ebs
	exit_col.add_child(ecs)
	exit_col.position = Vector3(20.0, WALL_H / 2.0, 7.0)
	world.add_child(exit_col)
	# cachettes : placard ch2, alcôve garage (sous escalier = renfoncement naturel)
	var plankm := _pbr("wall")
	for hp in [Vector2(15.8, 9.0), Vector2(3.0, 9.0)]:
		for hd in [Vector3(-0.55, 0, 0), Vector3(0.55, 0, 0), Vector3(0, 0, -0.55)]:
			var hw := _box(Vector3(0.08 if hd.x != 0 else 1.2, 2.0, 1.2 if hd.x != 0 else 0.08), plankm)
			hw.position = Vector3(hp.x + hd.x, 1.0, hp.y + hd.z)
			world.add_child(hw)
		var ht := _box(Vector3(1.2, 0.08, 1.2), plankm)
		ht.position = Vector3(hp.x, 2.0, hp.y)
		world.add_child(ht)
	# détails : tapis, cartons, toiles d'araignée, citrouilles
	var rug1 := _quad(Vector2(2.6, 1.8), _simple(Color(0.22, 0.06, 0.06), 0.9))
	rug1.rotation = Vector3(0, 0.1, 0)
	rug1.position = Vector3(3.5, 0.02, 2.8)
	world.add_child(rug1)
	var rug2 := _quad(Vector2(1.8, 1.3), _simple(Color(0.10, 0.10, 0.16), 0.9))
	rug2.rotation = Vector3(0, 0, 0)
	rug2.position = Vector3(17.5, 0.02, 11.4)
	world.add_child(rug2)
	var cartm := _simple(Color(0.35, 0.26, 0.16), 0.8)
	for bx in [Vector3(5.2, 0.25, 9.6), Vector3(5.7, 0.25, 10.3), Vector3(5.45, 0.72, 9.95)]:
		var cb := _box(Vector3(0.5, 0.5, 0.5), cartm)
		cb.position = bx
		cb.rotation = Vector3(0, rng.randf() * 0.8, 0)
		world.add_child(cb)
	_furn(Vector3(0.5, 0.5, 0.5), Vector3(5.2, 0.25, 9.6), cartm)
	_furn(Vector3(0.5, 0.5, 0.5), Vector3(5.7, 0.25, 10.3), cartm)
	_furn(Vector3(0.5, 0.5, 0.5), Vector3(5.45, 0.72, 9.95), cartm)
	for cw in [Vector3(0.4, 2.55, 0.4), Vector3(19.6, 2.55, 0.4), Vector3(0.4, 2.55, 13.6), Vector3(19.6, 2.55, 13.6)]:
		var webm := _simple(Color(0.7, 0.7, 0.68), 0.9)
		webm.transparency_mode = 1
		webm.albedo_color = Color(0.7, 0.7, 0.68, 0.25)
		var web := _quad(Vector2(0.7, 0.7), webm)
		web.rotation = Vector3(PI / 2, 0, PI / 4)
		web.position = cw
		world.add_child(web)
	dyn.add_child(_make_pumpkin(Vector3(4.8, 0, 1.8), 0.7))
	dyn.add_child(_make_pumpkin(Vector3(11.2, 0, 9.9), 0.6))
	dyn.add_child(_make_pumpkin(Vector3(18.2, 0, 10.8), 0.8))
	# lattes fatiguées (zones qui grincent) : visibles au sol
	var dark_plank := _simple(Color(0.10, 0.062, 0.04), 0.9)
	for cz in CREEK_ZONES:
		for k3 in range(3):
			var pl := _quad(Vector2(0.30, 1.15), dark_plank)
			pl.rotation = Vector3(0, 0.35 * (k3 - 1), 0)
			pl.position = Vector3(cz.x + 0.34 * (k3 - 1), 0.014, cz.y + 0.1 * (k3 - 1))
			world.add_child(pl)
	# bonbons posés dans la maison
	candy_meshes.clear()
	for ci in range(CANDY_SPOTS.size()):
		var cm := _box(Vector3(0.12, 0.09, 0.12), _emissive(Color(0.9, 0.3, 0.5), 1.6, ""))
		cm.position = Vector3(CANDY_SPOTS[ci].x, CANDY_SPOTS[ci].y + 0.95, CANDY_SPOTS[ci].z)
		world.add_child(cm)
		candy_meshes.append(cm)
	# v12 : 5 notes à trouver (lore)
	note_meshes.clear()
	var paperm := _simple(Color(0.90, 0.88, 0.80), 0.55)
	for ni in range(NOTE_SPOTS.size()):
		var npp := _box(Vector3(0.24, 0.012, 0.32), paperm)
		npp.position = Vector3(NOTE_SPOTS[ni].x, NOTE_SPOTS[ni].y + 0.02, NOTE_SPOTS[ni].z)
		npp.rotation = Vector3(0, 0.4 * float(ni), 0)
		world.add_child(npp)
		note_meshes.append(npp)
	# affiches
	for pp in [[Vector2(5.0, 4.93), 0], [Vector2(14.0, 9.07), PI], [Vector2(9.95, 0.05), 0]]:
		var po := _make_poster_xy(pp[0], pp[1])
		world.add_child(po)


func _make_poster_xy(at: Vector2, ry: float) -> Node3D:
	var nd := Node3D.new()
	var frame := _box(Vector3(1.06, 1.56, 0.05), _simple(Color(0.12, 0.08, 0.06), 0.5))
	nd.add_child(frame)
	var q := _quad(Vector2(0.95, 1.42), _pixel("res://assets/tex/%s.png" % poster_base))
	q.position = Vector3(0, 0, 0.035)
	q.name = "Art"
	nd.add_child(q)
	nd.rotation = Vector3(0, ry, 0)
	nd.position = Vector3(at.x, 1.62, at.y)
	return nd


func _make_lamp(at: Vector3, lit := true) -> Node3D:
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
	lamps.append([li, bulb_mat, n, lit])
	if not lit:
		li.light_energy = 0.0
		bulb_mat.emission_energy = 0.0
	return n


# ============================================================ props 3D ====
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
	# v15 : monstre T-pose a 6 parties (bras animes) par defaut ; v13 en repli ; --dbg=model1 force la v13.
	if dbg != "nomodel" and dbg != "model1" and ent_model_kind == 2 and ResourceLoader.exists("res://assets/models/monstre3_body.obj"):
		var md3 := _build_entity_model3()
		if md3 != null:
			return md3
	if dbg != "nomodel" and dbg != "model1" and ent_model_kind >= 1 and ResourceLoader.exists("res://assets/models/monstre2_body.obj"):
		var md2 := _build_entity_model2()
		if md2 != null:
			return md2
	# v13 : si le modele sculpte (TRELLIS) est present, on l'utilise ; sinon repli procedural.
	if dbg != "nomodel" and ResourceLoader.exists("res://assets/models/monstre_body.obj"):
		var md := _build_entity_model()
		if md != null:
			return md
	# « ELLE » v11 : grande silhouette voûtée 2,3 m, bras très longs tombant sous les genoux,
	# tête aveugle enfoncée entre les épaules, mâchoire fendue, mains osseuses, loques.
	if dbg != "":
		print("DBG entity=PROCEDURAL")
	var nd := Node3D.new()
	# v12.2 : peau réaliste = texture cadavérique + normal map + rugosité + sous-surface (SSS)
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
	skin.cull_mode = StandardMaterial3D.CULL_DISABLED
	var rags := StandardMaterial3D.new()
	rags.albedo_color = Color(0.055, 0.05, 0.065)
	rags.normal_enabled = true
	rags.normal_texture = load("res://assets/tex/skin_normal.png")
	rags.normal_scale = 1.6
	rags.uv1_scale = Vector3(3.4, 3.4, 1.0)
	rags.roughness = 0.94
	rags.cull_mode = StandardMaterial3D.CULL_DISABLED
	var bone := StandardMaterial3D.new()
	bone.albedo_color = Color(0.70, 0.66, 0.58)
	bone.roughness = 0.45
	bone.normal_enabled = true
	bone.normal_texture = load("res://assets/tex/skin_normal.png")
	bone.normal_scale = 0.5
	bone.uv1_scale = Vector3(4.0, 4.0, 1.0)
	var black := StandardMaterial3D.new()
	black.albedo_color = Color(0.02, 0.02, 0.025)
	black.roughness = 0.2
	for si in range(2):
		var sx := -0.13 if si == 0 else 0.13
		var legp := Node3D.new()
		legp.name = "LegL" if si == 0 else "LegR"
		legp.position = Vector3(sx, 1.06, 0)
		var thigh := MeshInstance3D.new()
		var tm2 := CapsuleMesh.new()
		tm2.radius = 0.055
		tm2.height = 0.50
		thigh.mesh = tm2
		thigh.material_override = skin
		thigh.position = Vector3(0, -0.25, 0)
		legp.add_child(thigh)
		var shin := MeshInstance3D.new()
		var sm2 := CapsuleMesh.new()
		sm2.radius = 0.043
		sm2.height = 0.50
		shin.mesh = sm2
		shin.material_override = skin
		shin.position = Vector3(0, -0.74, 0.03)
		shin.rotation.x = 0.10
		legp.add_child(shin)
		var knee := MeshInstance3D.new()
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
		nd.add_child(legp)
	var pelvis := MeshInstance3D.new()
	var pvm := CylinderMesh.new()
	pvm.top_radius = 0.15
	pvm.bottom_radius = 0.14
	pvm.height = 0.24
	pelvis.mesh = pvm
	pelvis.material_override = skin
	pelvis.position = Vector3(0, 1.10, 0)
	nd.add_child(pelvis)
	var belly := MeshInstance3D.new()
	var bvm := CapsuleMesh.new()
	bvm.radius = 0.125
	bvm.height = 0.42
	belly.mesh = bvm
	belly.material_override = skin
	belly.position = Vector3(0, 1.34, 0.01)
	nd.add_child(belly)
	var chest := MeshInstance3D.new()
	var cvm := CylinderMesh.new()
	cvm.top_radius = 0.27
	cvm.bottom_radius = 0.15
	cvm.height = 0.56
	chest.mesh = cvm
	chest.material_override = skin
	chest.position = Vector3(0, 1.74, -0.03)
	chest.rotation.x = -0.24
	nd.add_child(chest)
	var vest := MeshInstance3D.new()
	var vvm := CylinderMesh.new()
	vvm.top_radius = 0.285
	vvm.bottom_radius = 0.165
	vvm.height = 0.50
	vest.mesh = vvm
	vest.material_override = rags
	vest.position = Vector3(0, 1.74, -0.03)
	vest.rotation.x = -0.24
	nd.add_child(vest)
	var hump := MeshInstance3D.new()
	var hvm := SphereMesh.new()
	hvm.radius = 0.15
	hvm.height = 0.30
	hump.mesh = hvm
	hump.material_override = skin
	hump.scale = Vector3(1.15, 0.85, 1.0)
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
		nd.add_child(tendon)
	for sxs in [-1.0, 1.0]:
		var sh := MeshInstance3D.new()
		var shm := SphereMesh.new()
		shm.radius = 0.085
		shm.height = 0.17
		sh.mesh = shm
		sh.material_override = skin
		sh.position = Vector3(sxs * 0.245, 1.93, -0.04)
		nd.add_child(sh)
	for sx2 in [-1.0, 1.0]:
		var arm := Node3D.new()
		arm.name = "ArmL" if sx2 < 0 else "ArmR"
		arm.position = Vector3(sx2 * 0.28, 1.96, -0.02)
		var upper := MeshInstance3D.new()
		var um := CapsuleMesh.new()
		um.radius = 0.047
		um.height = 0.62
		upper.mesh = um
		upper.material_override = skin
		upper.position = Vector3(0, -0.31, 0)
		arm.add_child(upper)
		var fore := Node3D.new()
		fore.name = "Fore"
		fore.position = Vector3(0, -0.62, 0)
		var lower := MeshInstance3D.new()
		var lom := CapsuleMesh.new()
		lom.radius = 0.038
		lom.height = 0.66
		lower.mesh = lom
		lower.material_override = skin
		lower.position = Vector3(0, -0.33, 0)
		fore.add_child(lower)
		var hand := _make_hand_v2(sx2, bone)
		hand.position = Vector3(0, -0.70, 0)
		fore.add_child(hand)
		arm.add_child(fore)
		nd.add_child(arm)
	var drap := MeshInstance3D.new()
	var drap0 := BoxMesh.new()
	drap0.size = Vector3(0.60, 0.24, 0.03)
	drap.mesh = drap0
	drap.material_override = rags
	drap.position = Vector3(0, 1.97, 0.10)
	drap.rotation.x = 0.25
	nd.add_child(drap)
	var head := Node3D.new()
	head.name = "Head"
	head.position = Vector3(0, 2.22, -0.15)
	var skull := MeshInstance3D.new()
	var sm := SphereMesh.new()
	sm.radius = 0.155
	sm.height = 0.31
	skull.mesh = sm
	skull.material_override = skin
	skull.scale = Vector3(0.95, 1.05, 1.05)
	head.add_child(skull)
	for hx in range(7):
		var hair := MeshInstance3D.new()
		var hm2 := BoxMesh.new()
		hm2.size = Vector3(0.008, 0.10 + 0.05 * float(hx % 3), 0.008)
		hair.mesh = hm2
		hair.material_override = bone
		hair.position = Vector3(-0.055 + hx * 0.018, 0.155, -0.03 + 0.012 * float(hx % 2))
		hair.rotation = Vector3(-0.25 - 0.1 * float(hx % 2), 0, 0.1 * float(hx % 3 - 1))
		head.add_child(hair)
	var brow := MeshInstance3D.new()
	var browm := BoxMesh.new()
	browm.size = Vector3(0.24, 0.045, 0.055)
	brow.mesh = browm
	brow.material_override = skin
	brow.position = Vector3(0, 0.055, -0.10)
	head.add_child(brow)
	var jaw := MeshInstance3D.new()
	var jawm := BoxMesh.new()
	jawm.size = Vector3(0.17, 0.07, 0.13)
	jaw.mesh = jawm
	jaw.material_override = skin
	jaw.position = Vector3(0, -0.115, -0.06)
	head.add_child(jaw)
	for ex in [-0.058, 0.058]:
		var eye := MeshInstance3D.new()
		var em := BoxMesh.new()
		em.size = Vector3(0.052, 0.014, 0.012)
		eye.mesh = em
		eye.material_override = black
		eye.position = Vector3(ex, 0.005, -0.135)
		eye.rotation.z = 0.18 * signf(ex)
		head.add_child(eye)
	var mouth := MeshInstance3D.new()
	var mm := BoxMesh.new()
	mm.size = Vector3(0.022, 0.15, 0.02)
	mouth.mesh = mm
	mouth.material_override = black
	mouth.position = Vector3(0, -0.075, -0.128)
	head.add_child(mouth)
	for ti in range(5):
		var tooth := MeshInstance3D.new()
		var tmm := BoxMesh.new()
		tmm.size = Vector3(0.008, 0.02, 0.006)
		tooth.mesh = tmm
		tooth.material_override = bone
		tooth.position = Vector3(-0.012 if ti % 2 == 0 else 0.012, -0.03 - ti * 0.026, -0.138)
		head.add_child(tooth)
	nd.add_child(head)
	for sr in [-1.0, 1.0]:
		var shrag := MeshInstance3D.new()
		var srgm := BoxMesh.new()
		srgm.size = Vector3(0.20, 0.42, 0.02)
		shrag.mesh = srgm
		shrag.material_override = rags
		shrag.position = Vector3(sr * 0.235, 1.80, 0.06)
		shrag.rotation = Vector3(0.06, sr * 0.5, sr * 0.10)
		nd.add_child(shrag)
	for rq in range(7):
		var ang := TAU * float(rq) / 7.0
		var rag := MeshInstance3D.new()
		var rgm := BoxMesh.new()
		rgm.size = Vector3(0.18, 0.62 + 0.09 * float(rq % 3), 0.02)
		rag.mesh = rgm
		rag.material_override = rags
		rag.position = Vector3(cos(ang) * 0.15, 1.02 - 0.03 * float(rq % 2), sin(ang) * 0.13)
		rag.rotation = Vector3(0.06 * float(rq % 3) - 0.06, -ang, 0.05)
		nd.add_child(rag)
	var aura := OmniLight3D.new()
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
	return nd

func _build_entity_model() -> Node3D:
	# v13 : « ELLE » sculptee par IA (TRELLIS), decoupee en 4 parties animables.
	# Pivots : hanches y=0.94, cou y=2.15 (bakes dans les .obj), hauteur 2,35 m, visage vers -Z.
	var body_mesh = load("res://assets/models/monstre_body.obj")
	var head_mesh = load("res://assets/models/monstre_head.obj")
	var legl_mesh = load("res://assets/models/monstre_legL.obj")
	var legr_mesh = load("res://assets/models/monstre_legR.obj")
	if body_mesh == null or head_mesh == null or legl_mesh == null or legr_mesh == null:
		return null
	if dbg != "":
		print("DBG entity=MODEL3D (TRELLIS)")
	var m := StandardMaterial3D.new()
	m.albedo_texture = load("res://assets/models/monstre_tex.png")
	m.albedo_color = Color(0.66, 0.64, 0.62)
	m.roughness = 0.72
	m.metallic = 0.0
	m.subsurf_scatter_enabled = true
	m.subsurf_scatter_strength = 0.16
	m.rim_enabled = true
	m.rim = 0.55
	m.rim_tint = 0.6
	m.cull_mode = StandardMaterial3D.CULL_DISABLED
	var nd := Node3D.new()
	var HIP := 0.94
	var NECK := 2.15
	var body := MeshInstance3D.new()
	body.name = "Body"
	body.mesh = body_mesh
	body.material_override = m
	body.position = Vector3(0, HIP, 0)
	nd.add_child(body)
	for pr in [["LegL", legl_mesh], ["LegR", legr_mesh]]:
		var lp := Node3D.new()
		lp.name = pr[0]
		lp.position = Vector3(0, HIP, 0)
		var mi := MeshInstance3D.new()
		mi.mesh = pr[1]
		mi.material_override = m
		lp.add_child(mi)
		nd.add_child(lp)
	var hd := Node3D.new()
	hd.name = "Head"
	hd.position = Vector3(0, NECK, 0)
	var hm := MeshInstance3D.new()
	hm.mesh = head_mesh
	hm.material_override = m
	hd.add_child(hm)
	nd.add_child(hd)
	var aura := OmniLight3D.new()
	aura.light_color = Color(0.72, 0.68, 0.62)
	aura.light_energy = 0.30
	aura.omni_range = 1.9
	aura.position = Vector3(0, 1.5, 0)
	nd.add_child(aura)
	ent_breath = AudioStreamPlayer3D.new()
	ent_breath.stream = load("res://assets/audio/breath.wav")
	ent_breath.volume_db = -22.0
	ent_breath.unit_size = 6.0
	ent_breath.max_distance = 16.0
	ent_breath.position = Vector3(0, 1.9, 0)
	nd.add_child(ent_breath)
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
	return nd


func _make_hand_v2(side: float, bone: StandardMaterial3D) -> Node3D:
	var h := Node3D.new()
	var palm := MeshInstance3D.new()
	var pm := BoxMesh.new()
	pm.size = Vector3(0.075, 0.095, 0.024)
	palm.mesh = pm
	palm.material_override = bone
	palm.position = Vector3(0, -0.05, 0)
	h.add_child(palm)
	var lengths: Array = [0.052, 0.040, 0.030]
	for fi in range(4):
		var fx := -0.027 + fi * 0.018
		var py := -0.10
		for ph in range(3):
			var seg := MeshInstance3D.new()
			var cm := CapsuleMesh.new()
			cm.radius = 0.008 - ph * 0.0012
			cm.height = lengths[ph]
			seg.mesh = cm
			seg.material_override = bone
			seg.position = Vector3(fx + 0.004 * ph, py - lengths[ph] / 2.0, 0.004 * ph)
			seg.rotation.x = 0.09 + 0.16 * ph
			h.add_child(seg)
			py -= lengths[ph] * 0.93
	var thumb := MeshInstance3D.new()
	var tcm := CapsuleMesh.new()
	tcm.radius = 0.009
	tcm.height = 0.06
	thumb.mesh = tcm
	thumb.material_override = bone
	thumb.position = Vector3(side * 0.048, -0.05, 0.008)
	thumb.rotation.z = side * 0.9
	h.add_child(thumb)
	return h


# ============================================================ dessin boucle

# ============================================================ dessin boucle
func _draw_loop() -> void:
	for c in dyn.get_children():
		c.queue_free()
	posters.clear()
	doors.clear()
	lamps.clear()
	candy_meshes.clear()
	if entity != null and entity.get_parent() == world:
		entity.queue_free()
	entity = null
	exit_door = null
	flicker_idx = -1
	cross_state = 0
	_build_house()
	var ma := StandardMaterial3D.new()
	ma.albedo_texture = load("res://assets/tex/arrow.png")
	ma.texture_filter = 1
	ma.transparency_mode = 1
	ma.emission_enabled = true
	ma.emission = Color(1.0, 0.55, 0.15)
	ma.emission_texture = ma.albedo_texture
	ma.cull_mode = StandardMaterial3D.CULL_DISABLED
	# v12 : la flèche qui suivait le joueur est SUPPRIMÉE (demande utilisateur)
	ghost_arrow = null
	var gold := _emissive(Color(1.0, 0.8, 0.2), 2.2, "")
	var krm := TorusMesh.new()
	krm.inner_radius = 0.03
	krm.outer_radius = 0.05
	key_mesh_e = _key_model(gold)
	key_mesh_e.position = Vector3(key_exit_pos.x, key_exit_y + 0.14, key_exit_pos.y)
	dyn.add_child(key_mesh_e)
	key_mesh_c = _key_model(gold)
	key_mesh_c.position = Vector3(key_ch1_pos.x, key_ch1_y + 0.14, key_ch1_pos.y)
	dyn.add_child(key_mesh_c)


func _apply_anomaly() -> void:
	pass


func _neighbors(i: int) -> Array:
	var out := []
	for e in EDGES:
		if e[0] == i:
			out.append(e[1])
		elif e[1] == i:
			out.append(e[0])
	return out


func _edge_door(a: int, b: int) -> Vector2:
	var k := mini(a, b) * 100 + maxi(a, b)
	match k:
		3: return Vector2(3.55, 5.0)
		104: return Vector2(10.05, 5.0)
		205: return Vector2(16.55, 5.0)
		6: return Vector2(3.05, 9.0)
		107: return Vector2(8.05, 9.0)
		108: return Vector2(12.55, 9.0)
		209: return Vector2(17.55, 9.0)
	return Vector2(-1, -1)


func _bfs_pts(a: int, b: int) -> Array:
	var nodes := _bfs_path(a, b)
	var pts := []
	for i2 in range(nodes.size()):
		if i2 > 0:
			var dd := _edge_door(nodes[i2 - 1], nodes[i2])
			if dd.x >= 0:
				pts.append(dd)
		pts.append(NODES[nodes[i2]])
	return pts


func _move_entity_toward(target2: Vector2, spd: float, d: float, tlvl := -1) -> void:
	if ent_glued:
		spd *= 0.4
	var e2 := Vector2(entity.position.x, entity.position.z)
	var en := _node_of(e2, ent_level)
	var tn := _node_of(target2, tlvl if tlvl >= 0 else ent_level)
	ent_level = NODE_LVL[tn]
	var goal := target2
	if en != tn:
		if entity_path.is_empty() or entity_path_from != en or entity_path_to != tn:
			entity_path = _bfs_pts(en, tn)
			entity_path_from = en
			entity_path_to = tn
		if entity_path.size() > 0:
			goal = entity_path[0]
			if (goal - e2).length() < 0.5:
				entity_path.pop_front()
				if entity_path.size() > 0:
					goal = entity_path[0]
				else:
					goal = target2
	else:
		entity_path.clear()
	var dirv := (target2 - e2) if en == tn else (goal - e2)
	if dirv.length() > 0.01:
		dirv = dirv.normalized()
		entity.position = Vector3(e2.x + dirv.x * spd * d, 0, e2.y + dirv.y * spd * d)
		# v13 : orientation luee (le modele 3D regarde vers -Z, comme la version procedurale)
		if entity_mode != 2:
			entity.rotation.y = lerp_angle(entity.rotation.y, atan2(-dirv.x, -dirv.y), minf(1.0, 3.6 * d))


func _spawn_chaser() -> void:
	if entity != null and is_instance_valid(entity):
		return
	entity = _make_entity()
	var p2 := Vector2(player.position.x, player.position.z)
	# v17 : elle apparait LE PLUS LOIN possible du joueur (demande utilisateur)
	var cands: Array = []
	for i3 in range(3, NODES.size()):
		if NODE_LVL[i3] == 0:
			var dd: float = (NODES[i3] - p2).length()
			if (NODES[i3] - exit_pos).length() > 5.0:
				cands.append([dd, i3])
	cands.sort_custom(func(a, b): return a[0] > b[0])
	var opts := []
	for c in cands.slice(0, mini(3, cands.size())):
		opts.append(c[1])
	if opts.is_empty():
		opts = [6]
	entity_node = opts[rng.randi_range(0, opts.size() - 1)]
	if dbg != "":
		print("DBG spawn node=%d dist_joueur=%.1f (candidats=%s)" % [entity_node, (NODES[entity_node] - p2).length(), str(opts)])
	entity_target = entity_node
	entity.position = Vector3(NODES[entity_node].x, 0, NODES[entity_node].y)
	world.add_child(entity)
	entity_mode = 0


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
	headlamp.light_color = Color(1.0, 0.88, 0.70)
	headlamp.light_energy = 4.6      # v12 : 9.0 -> 4.6 (trop puissante)
	headlamp.spot_range = 13.0       # v12 : 18 -> 13 (elle portait trop loin)
	headlamp.spot_angle = 42.0       # v12 : 50 -> 42 (faisceau plus serré)
	headlamp.shadow_enabled = false
	headlamp.position = Vector3(0, -0.05, 0)
	cam.add_child(headlamp)
	sfx_click = AudioStreamPlayer.new()
	sfx_click.stream = load("res://assets/audio/cam_click.wav")
	sfx_click.volume_db = -7.0
	add_child(sfx_click)
	sfx_tape = AudioStreamPlayer.new()
	sfx_tape.stream = load("res://assets/audio/tape_rewind.wav")
	sfx_tape.volume_db = -3.0
	add_child(sfx_tape)
	sfx_lowbatt = AudioStreamPlayer.new()
	sfx_lowbatt.stream = load("res://assets/audio/lowbatt.wav")
	sfx_lowbatt.volume_db = -9.0
	add_child(sfx_lowbatt)
	dust = GPUParticles3D.new()
	dust.amount = 55
	dust.lifetime = 6.0
	var pm := ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(1.3, 1.0, 2.2)
	pm.spread = 180.0
	pm.direction = Vector3(0, 0, 0)
	pm.initial_velocity_min = 0.02
	pm.initial_velocity_max = 0.07
	pm.gravity = Vector3(0, 0, 0)
	pm.scale_min = 0.4
	pm.scale_max = 0.9
	var dsm := StandardMaterial3D.new()
	dsm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	dsm.albedo_color = Color(1.0, 0.97, 0.9, 0.30)
	dsm.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	var qm := QuadMesh.new()
	qm.size = Vector2(0.011, 0.011)
	qm.material = dsm
	dust.draw_pass_1 = qm
	dust.process_material = pm
	dust.position = Vector3(0, 0, -2.2)
	cam.add_child(dust)
	_respawn()


func _respawn_at(p: Vector2) -> void:
	player.position = Vector3(p.x, 0, p.y)
	dbg_path = []
	dbg_done_path = false
	dbg_stuck_t = 0.0


func _respawn() -> void:
	_respawn_at(spawn_pos)
	yaw = 1.5708


# ============================================================ audio =======

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
	banner_lbl.anchor_left = 0.08
	banner_lbl.anchor_right = 0.92
	banner_lbl.anchor_top = 0.12
	banner_lbl.anchor_bottom = 0.12
	banner_lbl.offset_left = 0
	banner_lbl.offset_right = 0
	banner_lbl.offset_top = 0
	banner_lbl.offset_bottom = 90
	banner_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
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
	# ---- v14 : viseur du camescope (sous les autres elements HUD) ----
	var cr := ColorRect.new()
	cr.set_anchors_preset(Control.PRESET_FULL_RECT)
	cr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var csh := Shader.new()
	csh.code = CAM_SHADER
	var csm := ShaderMaterial.new()
	csm.shader = csh
	cr.material = csm
	cr.visible = false
	ui.add_child(cr)
	ui.move_child(cr, 0)
	cam_overlay = cr
	cam_lbl = Label.new()
	cam_lbl.position = Vector2(16, 38)
	cam_lbl.size = Vector2(700, 26)
	cam_lbl.add_theme_font_size_override("font_size", 17)
	cam_lbl.add_theme_color_override("font_color", Color(0.55, 1.0, 0.62))
	cam_lbl.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.95))
	cam_lbl.add_theme_constant_override("outline_size", 5)
	cam_lbl.visible = false
	ui.add_child(cam_lbl)
	batt_bg = ColorRect.new()
	batt_bg.position = Vector2(12, 658)
	batt_bg.size = Vector2(164, 10)
	batt_bg.color = Color(0, 0, 0, 0.5)
	ui.add_child(batt_bg)
	batt_fill = ColorRect.new()
	batt_fill.position = Vector2(14, 660)
	batt_fill.size = Vector2(160, 6)
	batt_fill.color = Color(0.30, 0.85, 0.42, 0.85)
	ui.add_child(batt_fill)
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
	noise_bg = ColorRect.new()
	noise_bg.position = Vector2(12, 674)
	noise_bg.size = Vector2(164, 10)
	noise_bg.color = Color(0, 0, 0, 0.5)
	ui.add_child(noise_bg)
	noise_fill = ColorRect.new()
	noise_fill.position = Vector2(14, 676)
	noise_fill.size = Vector2(0, 6)
	noise_fill.color = Color(0.85, 0.18, 0.12, 0.85)
	ui.add_child(noise_fill)
	noise_lbl = Label.new()
	noise_lbl.position = Vector2(180, 668)
	noise_lbl.text = tt("noise_lbl")
	noise_lbl.add_theme_color_override("font_color", Color(0.85, 0.3, 0.22))
	ui.add_child(noise_lbl)
	hud_nodes = [hud_lbl, hint_lbl, ts_lbl, banner_lbl, toast_lbl, cap_lbl, obj_lbl, osd_lbl, stam_bg, stam_fill, pocket_lbl, noise_bg, noise_fill, noise_lbl, cam_lbl, batt_bg, batt_fill]
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
	var vtag := Label.new()
	vtag.name = "Ver"
	vtag.text = "v17 DEMARCHE"
	vtag.position = Vector2(1180, 690)
	vtag.size = Vector2(180, 24)
	vtag.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	vtag.add_theme_font_size_override("font_size", 14)
	vtag.add_theme_color_override("font_color", Color(0.85, 0.45, 0.12))
	vtag.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	vtag.add_theme_constant_override("outline_size", 6)
	title_ctl.add_child(vtag)
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
		tension_pl.volume_db = -6.0 + linear_to_db(maxf(vol_music, 0.001))
	if music_pl != null:
		music_pl.volume_db = -4.0 + linear_to_db(maxf(vol_music, 0.001))


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
	cl.add_child(flash_rect)
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
	scare_rect.modulate = Color(1, 1, 1, 1)
	scare_rect.visible = false
	flash_rect.visible = false
	crouch = false
	blackout_on = false
	blackout_t = 0.0
	blackout_cd = 55.0
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
		entity = null
	spawn_pos = SPAWN_POINTS[rng.randi_range(0, SPAWN_POINTS.size() - 1)]
	has_key_exit = false
	has_key_ch1 = false
	ch1_locked = true
	hidden = false
	lock_cd = 0.0
	glue_zones.clear()
	var ka: Vector3 = KEY_SPOTS_A[rng.randi_range(0, KEY_SPOTS_A.size() - 1)]
	key_exit_pos = Vector2(ka.x, ka.z)
	key_exit_lvl = 1 if ka.y > 1.0 else 0
	key_exit_y = ka.y
	var kb: Vector3 = KEY_SPOTS_B[rng.randi_range(0, KEY_SPOTS_B.size() - 1)]
	key_ch1_pos = Vector2(kb.x, kb.z)
	key_ch1_lvl = 1 if kb.y > 1.0 else 0
	key_ch1_y = kb.y
	bot_level = 0
	ent_level = 0
	dbg_had_key = false
	state = "play"
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	f_first_anom = false
	f_exit = false
	anom_timer = 0.0
	candies = {}
	pocket = 1
	noise = 0.0
	bait_timer = 0.0
	# ---- v14 : camescope & piles ----
	battery = 100.0
	battery_charges = 0
	cam_sticky = false
	cam_held = false
	cam_raised = false
	cam_grade = 0.0
	rewinding = 0.0
	rewind_cd = 0.0
	lowbatt_t = 1.5
	heard_t = 0.0
	heard_cd = 0.0
	ent_prev_phase = 0.0
	creek_sfx_t = 6.0
	hide_warn_cd = 0.0
	hide_busted = false
	trail.clear()
	trail_t = 0.0
	for pi2 in range(piles.size()):
		if is_instance_valid(piles[pi2][1]):
			piles[pi2][1].queue_free()
	piles.clear()
	for sp in NOTE_SPOTS:
		_spawn_pile(Vector3(sp.x + 0.45, sp.y + 0.02, sp.z + 0.35))
	if cam_overlay != null:
		cam_overlay.visible = false
	if cam_lbl != null:
		cam_lbl.visible = false
	graze_cd = 0.0
	candy_taken = [false, false, false, false, false]
	creek_cd = [0.0, 0.0, 0.0, 0.0, 0.0]
	entity_mode = 0
	chase_t = 0.0
	_draw_loop()
	_spawn_chaser()
	poster_base = ["poster_a", "poster_c"][rng.randi_range(0, 1)]
	candy_offer = []
	candy_timer = 0.0
	entity_stun = 0.0
	stamina = 1.0
	_respawn()
	_roll_anomaly()
	_banner(tt("obj_heart"), 9.0)
	obj_lbl.text = tt("obj_short")
	obj_lbl.visible = hud_on
	if not f_arrow:
		f_arrow = true
		_toast(tt("toast_arrow"), 7.0)  # v12 : rappel clé dorée, plus de flèche
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
	_ensure_music()
	if not music_pl.playing:
		music_pl.play()
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
	if music_pl != null:
		music_pl.stop()


func _roll_anomaly() -> void:
	chasing = false
	anom_timer = 0.0
	anomaly = ""
func _evaluate_pass() -> void:
	pass


func _evaluate_return() -> void:
	pass


func _mistake() -> void:
	pass


func _blackout(reroll: bool) -> void:
	pass


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


func _caught() -> void:
	catches += 1
	if dbg != "":
		print("DIAG caught player=", Vector2(player.position.x, player.position.z), " ent=", Vector2(entity.position.x, entity.position.z), " mode=", entity_mode, " noise=", noise, " chase_t=", chase_t, " ent_node=", entity_target, " t=", run_time)
	if dbg != "":
		print("EVT CAUGHT n=", catches)
	play("scare", 3.0)
	play("scare", -1.0, 0.78)
	play("sting", -1.0)
	scare_rect.visible = true
	scare_rect.move_to_front()
	flash_rect.visible = true
	flash_rect.move_to_front()
	scare_t = 0.001
	flash_rect.color = Color(0.95, 0.05, 0.05, 0.55)
	if catches >= 3:
		state = "dead"
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		var tw := create_tween()
		tw.tween_interval(1.6)
		tw.tween_callback(func():
			flash_rect.visible = false
			scare_t = 0.0
			scare_rect.position = Vector2.ZERO
			scare_rect.scale = Vector2.ONE
			# v12 : le screamer reste en FOND de l'écran de fin (assombri), comme dans les jeux d'horreur
			scare_rect.modulate = Color(1, 1, 1, 0.26)
			scare_rect.visible = true
			end_ctl.visible = true
			end_ctl.get_node("Title").text = tt("dead")
			end_ctl.get_node("Title").add_theme_color_override("font_color", Color(0.85, 0.15, 0.12))
			end_ctl.get_node("Sub").text = tt("dead3")
			end_ctl.get_node("Stats").text = tt("loops") % [catches, section]
			end_ctl.get_node("Replay").text = tt("replay"))
		return
	locked = true
	var tw2 := create_tween()
	tw2.tween_interval(0.95)
	tw2.tween_callback(func():
		scare_rect.visible = false
		scare_rect.modulate = Color(1, 1, 1, 1)
		flash_rect.visible = false
		scare_rect.position = Vector2.ZERO
		scare_rect.scale = Vector2.ONE
		scare_t = 0.0
		crouch = false
		_respawn_at(spawn_pos)
		yaw = 1.5708
		entity_mode = 0
		alert_t = 0.0
		chase_t = 0.0
		if entity != null and is_instance_valid(entity):
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
		_spawn_chaser()
		noise = 0.0
		stamina = maxf(stamina, 0.6)
		locked = false)


func _win() -> void:
	if dbg != "":
		print("EVT WIN catches=", catches)
	state = "win"
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if drone_pl != null:
		drone_pl.stop()
	if wind_pl != null:
		wind_pl.stop()
	if house_pl != null:
		house_pl.stop()
	if music_pl != null:
		music_pl.stop()
	if tension_pl != null:
		tension_pl.stop()
	play("chime", -3.0)
	locked = true
	hud_on = false
	var dirw := (Vector3(exit_pos.x, 0, exit_pos.y) - player.position).normalized()
	var tw := create_tween()
	tw.tween_property(player, "position", player.position + dirw * 1.6, 2.2).set_trans(Tween.TRANS_SINE)
	tw.parallel().tween_property(fade, "color", Color(1.0, 0.93, 0.82, 1.0), 2.4)
	tw.tween_interval(0.5)
	tw.tween_callback(func():
		locked = false
		end_ctl.visible = true
		end_ctl.get_node("Title").text = tt("win")
		end_ctl.get_node("Title").add_theme_color_override("font_color", Color(0.95, 0.72, 0.3))
		end_ctl.get_node("Sub").text = tt("win_sub")
		end_ctl.get_node("Stats").text = tt("loops") % [catches, pocket]
		end_ctl.get_node("Replay").text = tt("replay")
		fade.color = Color(0, 0, 0, 0))


# ============================================================ input =======# ============================================================ input =======
func _unhandled_input(ev: InputEvent) -> void:
	if ev is InputEventMouseMotion and state == "play" and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		yaw -= ev.relative.x * 0.0022 * mouse_sens
		pitch = clampf(pitch - ev.relative.y * 0.0021 * mouse_sens, -1.1, 1.1)
	if ev is InputEventMouseButton and state == "play":
		if ev.button_index == MOUSE_BUTTON_RIGHT:
			cam_held = ev.pressed
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
			if ev.keycode == KEY_E and pocket > 0:
				pocket -= 1
				bait_pos = Vector2(player.position.x, player.position.z) + Vector2(-sin(yaw), -cos(yaw)) * 2.5
				bait_timer = 4.0
				bait_level = player_level
				play("creak", -6.0, 1.3)
				_toast(tt("candy_throw"), 3.0)
				_toast(tt("candy_throw"), 3.0)
			if ev.keycode == KEY_F and pocket > 0:
				pocket -= 1
				var gpos := Vector2(player.position.x, player.position.z) + Vector2(-sin(yaw), -cos(yaw)) * 2.0
				var gmat := _simple(Color(0.9, 0.2, 0.55), 0.8)
				gmat.transparency_mode = 1
				gmat.albedo_color = Color(0.9, 0.2, 0.55, 0.22)
				var gm := _quad(Vector2(3.2, 3.2), gmat)
				gm.rotation = Vector3(0, 0, 0)
				gm.position = Vector3(gpos.x, 0.03, gpos.y)
				dyn.add_child(gm)
				glue_zones.append([gpos, 8.0, gm])
				play("step", -10.0, 0.5)
				_toast(tt("glue_set"), 2.5)
			if ev.keycode == KEY_V:
				vhs.visible = not vhs.visible
				vhs_visible_pref = vhs.visible
				options_ctl.get_node("Cvhs").button_pressed = vhs.visible
				_save_settings()
			if ev.keycode == KEY_C:
				crouch = not crouch
				_toast(tt("crouch_on") if crouch else tt("crouch_off"), 1.8)
			if ev.keycode == KEY_G:
				headlamp_on = not headlamp_on
			if ev.keycode == KEY_T:
				cam_sticky = not cam_sticky
				if cam_sticky and battery <= 0.0:
					cam_sticky = false
					_toast(tt("cam_empty"), 3.0)
			if ev.keycode == KEY_F3:
				ent_model_kind = (ent_model_kind + 2) % 3
				var kp := Vector3.ZERO
				var km := entity_mode
				if entity != null and is_instance_valid(entity):
					kp = entity.position
					entity.queue_free()
				entity = null
				_spawn_chaser()
				if entity != null and is_instance_valid(entity):
					entity.position = kp
					entity_mode = km
				var kn := "v13 QUATRE PARTIES"
				if ent_model_kind == 1:
					kn = "v15 SIX PARTIES"
				elif ent_model_kind == 2:
					kn = "v17 DIX PARTIES (genoux + coudes)"
				_toast("MONSTRE : %s" % kn, 2.5)
			if ev.keycode == KEY_R:
				_do_rewind()
				headlamp.visible = headlamp_on
				dust.emitting = headlamp_on
				play("creak", -14.0, 1.6)
			if ev.keycode == KEY_F1:
				hud_on = not hud_on
				for n in hud_nodes:
					n.visible = hud_on
				if not hud_on:
					banner_lbl.visible = false
					toast_lbl.visible = false
					cap_lbl.visible = false
			if ev.keycode == KEY_F2:
				_toggle_quality()
				_toast("QUALITE " + ("HAUTE" if quality_high else "BASSE") + "  (SDFGI/fog/glow)", 2.4)
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
	if dbg == "audit":
		_dbg_audit(d)
	if dbg == "cam":
		_dbg_cam(d)
	if dbg == "m2":
		_dbg_m2(d)
		return
	if dbg == "shot":
		_dbg_shot(d)
		return
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
		yaw = sin(title_cam_t * 0.10) * 0.6
		pitch = -0.04
		player.rotation = Vector3(0, yaw, 0)
		cam.rotation = Vector3(pitch, 0, 0)
		cam.position = Vector3(0, EYE, 0)
		player.position = Vector3(10.0 + sin(title_cam_t * 0.11) * 4.0, 0, 7.0 + cos(title_cam_t * 0.07) * 0.8)
		return
	if state != "play":
		return
	if locked:
		return
	if dbg != "" and dbg != "audit":
		_dbg_walk(d)
	run_time += d
	var secs := int(run_time) + 23 * 3600 + 41 * 60
	var dat := "31 OCT 1997" if lang == "fr" else "OCT 31 1997"
	var rec := "● " if fmod(run_time, 1.4) < 0.7 else "  "
	ts_lbl.text = "%s%s %02d:%02d:%02d" % [rec, dat, (secs / 3600) % 24, (secs / 60) % 60, secs % 60]
	# v12.1 : PANNE DE COURANT — les lampes s'éteignent quelques secondes (jamais en mode bot/audit)
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
	if flicker_idx < 0 and rng.randf() < d * 0.06:
		var lits := []
		for k4 in range(lamps.size()):
			if lamps[k4][3]:
				lits.append(k4)
		if lits.size():
			flicker_idx = lits[rng.randi_range(0, lits.size() - 1)]
			flicker_t = 1.2
	if flicker_idx >= 0:
		flicker_t -= d
		if flicker_t <= 0.0:
			lamps[flicker_idx][0].visible = true
			lamps[flicker_idx][1].emission_energy = 5.0
			flicker_idx = -1
		else:
			var lp = lamps[flicker_idx]
			if lp[3]:
				var on := fmod(run_time * 7.3, 1.0) > 0.25 and fmod(run_time * 3.1, 1.0) > 0.1
				lp[0].visible = on
				lp[1].emission_energy = 5.0 if on else 0.0
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
	var want_sprint := Input.is_key_pressed(KEY_SHIFT) and stamina > 0.05 and not crouch
	if dbg_move_frames > 0:
		mv = Vector3(dbg_move_dir.x, 0, dbg_move_dir.y)
		dbg_move_frames -= 1
	if mv.length_squared() > 0.01:
		if want_sprint:
			stamina = maxf(0.0, stamina - d * (0.11 if candies.get("sucre", false) else 0.22))
		else:
			stamina = minf(1.0, stamina + d * 0.16)
		mv = mv.normalized() * (1.7 if crouch else (5.6 if want_sprint else 3.4))
		cam.fov = lerpf(cam.fov, 78.0 + (5.0 if want_sprint else 0.0) + (1.5 if stamina < 0.2 else 0.0), 0.1)
		player.velocity = Vector3(mv.x, 0, mv.z)
		bob += d * (9.5 if want_sprint else 6.5)
		if fmod(bob, TAU) < d * (9.5 if want_sprint else 6.5):
			play("step", -19.0 if crouch else -12.0, randf_range(0.9, 1.1))
	else:
		player.velocity = Vector3.ZERO
		bob = move_toward(bob, round(bob / TAU) * TAU, d * 4)
		stamina = minf(1.0, stamina + d * 0.22)
	player.rotation = Vector3(0, yaw, 0)
	var skip_move := false
	var pp2 := Vector2(player.position.x, player.position.z)
	stair_cd = maxf(0.0, stair_cd - d)
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
			_toast("ESCALIER → REZ-DE-CHAUSSÉE (2,5 s)", 2.0)
	if stair_t >= 0.0:
		var ascend := stair_dir > 0
		if ascend:
			stair_t += d / 2.5
		else:
			stair_t -= d / 2.5
		var t := clampf(stair_t, 0.0, 1.0)
		player.position = Vector3(1.5, t * 2.98, lerpf(12.45, 7.5, t))
		player.velocity = Vector3.ZERO
		if (ascend and stair_t >= 1.0) or (not ascend and stair_t <= 0.0):
			stair_t = -1.0
			stair_cd = 1.0
		skip_move = true
		mv = Vector3.ZERO
	if not skip_move:
		var pb2 := Vector2(player.position.x, player.position.z)
		player.move_and_slide()
	if stamina < 0.5:
		breath_timer -= d
		if breath_timer <= 0.0:
			breath_timer = 0.7 + stamina
			play("breath", -8.0)
	if stamina < 0.25 and fmod(run_time, 1.3) < d:
		play("heart", -6.0)
	stam_fill.size.x = 160.0 * stamina
	dust.emitting = headlamp_on and state == "play"
	if tension_pl != null:
		if chasing and not tension_pl.playing:
			tension_pl.play()
		elif not chasing and tension_pl.playing:
			tension_pl.stop()
	if hands != null:
		hands.position = Vector3(cos(bob * 0.5) * 0.012, -0.36 + sin(bob) * 0.018 + (0.03 if stamina < 0.2 else 0.0), -0.55)
		hands.rotation.z = sin(bob * 0.5) * 0.02
	cam.rotation = Vector3(pitch, 0, 0)
	cam.position = Vector3(0, EYE - (0.42 if crouch else 0.0) + sin(bob) * 0.035, 0)
	var target_noise := 0.03
	if mv.length_squared() > 0.01:
		target_noise = 1.0 if want_sprint else (0.07 if crouch else 0.18)
	if stamina < 0.5:
		target_noise += 0.35
	if stamina < 0.25:
		target_noise += 0.25
	if candies.get("sucre", false):
		target_noise *= 0.7
	noise = lerpf(noise, target_noise, 0.15)
	# --- v17 : lattes de plancher qui grincent quand tu marches (demande utilisateur) ---
	creek_sfx_t -= d
	if creek_sfx_t <= 0.0 and mv.length_squared() > 0.01 and player_level == 0:
		var sprinting := want_sprint and stamina > 0.05
		creek_sfx_t = rng.randf_range(2.5, 5.5) if sprinting else rng.randf_range(6.0, 13.0)
		if rng.randf() < (0.8 if sprinting else 0.55):
			play("creak", -2.0, rng.randf_range(0.85, 1.18))
			noise = maxf(noise, 0.45 if sprinting else 0.30)
	var p2z := Vector2(player.position.x, player.position.z)
	player_level = 1 if player.position.y > 1.6 else 0
	for zi in range(CREEK_ZONES.size()):
		creek_cd[zi] = maxf(0.0, creek_cd[zi] - d)
		if creek_cd[zi] <= 0.0 and player_level == 0 and (Vector2(CREEK_ZONES[zi].x, CREEK_ZONES[zi].y) - p2z).length() < CREEK_ZONES[zi].z:
			creek_cd[zi] = 3.0
			play("creak", -2.0, 0.85)
			noise = maxf(noise, 1.0)
	for ci in range(CANDY_SPOTS.size()):
		if not candy_taken[ci] and (Vector2(CANDY_SPOTS[ci].x, CANDY_SPOTS[ci].z) - p2z).length() < 0.9 and player_level == (1 if CANDY_SPOTS[ci].y > 1.0 else 0):
			candy_taken[ci] = true
			pocket = mini(3, pocket + 1)
			if ci < candy_meshes.size() and is_instance_valid(candy_meshes[ci]):
				candy_meshes[ci].queue_free()
			play("chime", -6.0)
			_toast(tt("candy_pickup"), 3.0)
			alert_t = maxf(alert_t, 1.5)
	for ni2 in range(NOTE_SPOTS.size()):
		if taken_notes[ni2]:
			continue
		if absf(player.position.y - NOTE_SPOTS[ni2].y) > 1.4:
			continue
		if Vector2(NOTE_SPOTS[ni2].x, NOTE_SPOTS[ni2].z).distance_to(p2z) < 0.95:
			taken_notes[ni2] = true
			notes_found += 1
			if ni2 < note_meshes.size() and is_instance_valid(note_meshes[ni2]):
				note_meshes[ni2].queue_free()
			play("paper", -4.0)
			play("whisper", -8.0)
			_toast(tt("note_%d" % (ni2 + 1)), 6.5)
			alert_t = maxf(alert_t, 1.0)
	if key_mesh_e != null and is_instance_valid(key_mesh_e) and key_mesh_e.visible:
		if p2z.distance_to(key_exit_pos) < 0.9 and player_level == key_exit_lvl:
			has_key_exit = true
			key_mesh_e.visible = false
			play("key_jingle", -3.0)
			_toast(tt("key_pick_e"), 3.5)
	if key_mesh_c != null and is_instance_valid(key_mesh_c) and key_mesh_c.visible:
		if p2z.distance_to(key_ch1_pos) < 0.9 and player_level == key_ch1_lvl:
			has_key_ch1 = true
			key_mesh_c.visible = false
			play("key_jingle", -3.0)
			_toast(tt("key_pick_c"), 3.5)
	var dexit: float = (exit_pos - p2z).length()
	if dexit < 1.4:
		if has_key_exit:
			_win()
			return
		if lock_cd <= 0.0:
			lock_cd = 2.5
			_toast(tt("locked"), 3.0)
			play("creak", -4.0, 0.6)
	if ch1_locked and has_key_ch1:
		var d1v := Vector2(player.position.x - 12.55, player.position.z - 8.2)
		if d1v.length() < 1.3:
			ch1_locked = false
			if ch1_col != null and is_instance_valid(ch1_col):
				ch1_col.queue_free()
				ch1_col = null
			if ch1_door_node != null and is_instance_valid(ch1_door_node):
				ch1_door_node.queue_free()
				ch1_door_node = null
			_toast(tt("unlocked"), 3.0)
			play("chime", -8.0)
	hidden = false
	for hs in HIDE_SPOTS:
		var hl := 1 if hs.y > 1.0 else 0
		if p2z.distance_to(Vector2(hs.x, hs.z)) < 0.8 and player_level == hl:
			hidden = true
			if hide_cd <= 0.0:
				hide_cd = 4.0
				_toast(tt("hidden_t"), 3.0)
			# --- v16 : cachee ne veut pas dire sauvee — ne bouge pas ---
			var de := 0.0
			if entity != null and is_instance_valid(entity):
				de = Vector2(entity.position.x, entity.position.z).distance_to(p2z)
			if de < 4.5 and player_level == ent_level and not hide_busted:
				if hide_warn_cd <= 0.0:
					hide_warn_cd = 8.0
					_toast(tt("hide_warn"), 3.0)
					play("heart", -5.0)
				if player.velocity.length() > 0.30:
					hide_busted = true
					hidden = false
					entity_mode = 2
					chase_t = 0.0
					play("scare", -3.0)
					_toast(tt("hide_busted"), 3.0)
	for gi in range(glue_zones.size() - 1, -1, -1):
		glue_zones[gi][1] -= d
		if glue_zones[gi][1] <= 0.0:
			if is_instance_valid(glue_zones[gi][2]):
				glue_zones[gi][2].queue_free()
			glue_zones.remove_at(gi)
	pocket_lbl.text = tt("pocket") % pocket + ("  ·  " + tt("key_e_s") if has_key_exit else "") + ("  ·  " + tt("key_c_s") if has_key_ch1 else "")
	if entity == null or not is_instance_valid(entity):
		_spawn_chaser()
	var epos2 := Vector2(entity.position.x, entity.position.z)
	var dist: float = (epos2 - p2z).length()
	ent_glued = false
	for gz in glue_zones:
		if gz[1] > 0.0 and (gz[0] - epos2).length() < 1.6:
			ent_glued = true
	if hidden and entity_mode != 0:
		entity_mode = 0
		entity_target = _node_of(epos2, ent_level)
	var hear_r := noise * 14.0
	if _ent_asleep():
		# v17 : dormance — elle reste invisible et immobile loin dans la maison (demande utilisateur)
		hear_r = 0.0
		bait_timer = 0.0
		heard_t = 0.0
		entity_mode = 0
		entity_target = entity_node
		entity.position = Vector3(NODES[entity_node].x, _terrain_y(NODES[entity_node], ent_level), NODES[entity_node].y)
		entity.visible = false
	elif not entity.visible:
		# REVEIL : elle repart du point le plus eloigne de toi (demande utilisateur : « plus loin dans la map »)
		var best_n := entity_node
		var best_d := -1.0
		for i5 in range(3, NODES.size()):
			if NODE_LVL[i5] == 0 and (NODES[i5] - exit_pos).length() > 5.0:
				var d5: float = (NODES[i5] - p2z).length()
				if d5 > best_d:
					best_d = d5
					best_n = i5
		entity_node = best_n
		ent_level = 0
		entity.position = Vector3(NODES[entity_node].x, _terrain_y(NODES[entity_node], 0), NODES[entity_node].y)
		entity_path.clear()
		entity.visible = true
		play("sting", -9.0)
		play("growl", -14.0)
		if dbg != "":
			print("DBG envol t=%.1f dist=%.1f" % [run_time, best_d])
	if hidden:
		hear_r = 0.0
	if player_level != ent_level:
		hear_r *= 0.25
	if dbg == "smart" or dbg == "blind":
		hear_r = 0.0
	# --- v16 : laisse d'ecoute — un bruit fort la fait venir de loin ---
	if heard_cd > 0.0:
		heard_cd -= d
	if noise > 0.85 and heard_cd <= 0.0 and not hidden:
		# elle entend A TRAVERS les murs et les etages : elle sait ou tu es passe
		heard_pos = p2z
		heard_lvl = player_level
		heard_t = 6.0
		heard_cd = 6.0
		if dist > 4.0:
			play("growl", -12.0)
			_toast(tt("heard"), 2.6)
		if dbg != "":
			print("DBG heard_event pos=%s lvl=%d dist=%.1f mode=%d" % [str(p2z), player_level, dist, entity_mode])
	if bait_timer > 0.0:
		bait_timer -= d
		entity_mode = 1
		_move_entity_toward(bait_pos, 2.6, d, bait_level)
		if (bait_pos - epos2).length() < 0.8:
			bait_timer = 0.0
	elif entity_stun > 0.0:
		entity_stun -= d
	elif entity_mode == 2:
		chase_t += d
		var spd := 4.3 if candies.get("reglisse", false) else 3.6
		if player_level != ent_level:
			var pth := _bfs_path(_node_of(epos2, ent_level), _node_of(p2z, player_level))
			if pth.size() > 1:
				var mid: Vector2 = NODES[pth[1]]
				_move_entity_toward(mid, spd, d, NODE_LVL[pth[1]])
			else:
				_move_entity_toward(p2z, spd, d, player_level)
		else:
			_move_entity_toward(p2z, spd, d, player_level)
		if chase_t > 6.0 and noise < 0.35:
			entity_mode = 0
			chase_t = 0.0
			entity_target = _node_of(epos2, ent_level)
	elif heard_t > 0.0 and not hidden:
		# v16 : elle sait OU tu as fait du bruit et elle y va (etage compris)
		heard_t -= d
		entity_mode = 1
		_move_entity_toward(heard_pos, 2.5, d, heard_lvl)
		if (heard_pos - epos2).length() < 0.9:
			heard_t = 0.0
			entity_target = _node_of(epos2, ent_level)
			if dbg != "":
				print("DBG heard_arrived t=%.1f" % run_time)
	elif dist < hear_r:
		if noise > 0.6 and dist < 6.0:
			entity_mode = 2
			chase_t = 0.0
		elif entity_mode != 2:
			entity_mode = 1
		alert_t = 4.0
		entity_target_pos = p2z
		entity_target_lvl = player_level
		_move_entity_toward(p2z, 3.6 if entity_mode == 2 else 2.2, d, player_level)
	else:
		if entity_mode == 1:
			_move_entity_toward(entity_target_pos, 2.2, d)
			alert_t -= d
			if (entity_target_pos - epos2).length() < 0.8 or alert_t <= 0.0:
				entity_mode = 0
				entity_target = _node_of(epos2, ent_level)
		elif entity_mode == 2:
			entity_mode = 0
			entity_target = _node_of(epos2, ent_level)
		else:
			var tgt: Vector2 = NODES[entity_target]
			if (tgt - epos2).length() < 0.5:
				var nb := _neighbors(entity_target)
				var pool := []
				for cand in nb:
					if cand != 1:
						pool.append(cand)
				if pool.is_empty():
					pool = nb.duplicate()
				var pick: int = pool[rng.randi_range(0, pool.size() - 1)]
				if (NODES[pick] - exit_pos).length() < 3.5 and (p2z - epos2).length() > 8.0 and pool.size() > 1:
					for alt in pool:
						if (NODES[alt] - exit_pos).length() >= 3.5:
							pick = alt
							break
				entity_target = pick
				tgt = NODES[entity_target]
			_move_entity_toward(tgt, 0.0 if _ent_asleep() else 1.15, d, NODE_LVL[entity_target])
	epos2 = Vector2(entity.position.x, entity.position.z)
	dist = (epos2 - p2z).length()
	entity.visible = true
	graze_cd = maxf(0.0, graze_cd - d)
	lock_cd = maxf(0.0, lock_cd - d)
	hide_cd = maxf(0.0, hide_cd - d)
	if dist < 0.85 and absf(player.position.y - entity.position.y) < 1.2 and not hidden and dbg != "smart" and graze_cd <= 0.0:
		if candies.get("caramel", false) and graze == 0:
			graze = 1
			entity_mode = 0
			entity_target = _node_of(epos2, ent_level)
			play("sting", -6.0)
			_toast(tt("graze"), 4.0)
		elif entity_mode == 2:
			_caught()
			return
		else:
			entity_mode = 2
			chase_t = 0.0
			entity_stun = 1.0
			graze_cd = 2.0
			play("sting", -7.0)
	if dist < 9.0 and fmod(run_time, 1.3) < d:
		play("whisper", -18.0 + dist)
	if entity_mode == 2:
		if fmod(Time.get_ticks_msec() / 1000.0, 1.4) < d:
			play("heart", -4.0)
		hint_lbl.text = tt("hint_run")
	elif noise > 0.6:
		hint_lbl.text = tt("hint_listen")
	else:
		hint_lbl.text = tt("hint_move") if run_time < 6.0 else ""
	if ghost_arrow != null and is_instance_valid(ghost_arrow):
		ghost_arrow.visible = hud_on
	# v15 : les cles tournent lentement sur elles-memes (elles attirent l'oeil dans le noir)
	if key_mesh_e != null and is_instance_valid(key_mesh_e):
		key_mesh_e.rotation.y = run_time * 0.7
	if key_mesh_c != null and is_instance_valid(key_mesh_c):
		key_mesh_c.rotation.y = run_time * 0.7
	if entity != null and is_instance_valid(entity) and entity.visible:
		var sp2 := 1.0 + entity_mode * 1.2
		var tt2 := run_time * sp2
		var mv2 := epos2 - p2z
		if entity_mode == 2 and mv2.length_squared() > 0.01:
			entity.rotation.y = atan2(-mv2.x, -mv2.y)
		elif entity_path.size() > 0 or mv2.length_squared() > 0.01:
			var facedir := (epos2 - Vector2(entity.position.x, entity.position.z))
			if facedir.length_squared() < 0.00001:
				facedir = mv2
		var headn := entity.get_node_or_null("Head")
		if headn != null:
			headn.rotation.z = sin(tt2 * 7.3) * 0.07
			headn.rotation.x = sin(tt2 * 3.1) * 0.05 - 0.12 - (0.22 if entity_mode == 2 else 0.0)
			if entity_mode == 2 and fmod(run_time, 2.7) < 0.1:
				headn.rotation.z = 0.6
				headn.rotation.x = -0.4
		for an in ["ArmL", "ArmR"]:
			var armn := entity.get_node_or_null(an)
			if armn != null:
				var sgn := -1.0 if an == "ArmL" else 1.0
				var sw := sin(tt2 * 5.0 + (0.0 if sgn > 0 else PI)) * (0.45 if entity_mode == 2 else 0.15)
				if ent_model_kind == 1:
					# v15 : les bras du modele T-pose pendent le long du corps et balancent en marchant
					armn.rotation.x = (-0.90 if entity_mode == 2 else sin(ent_phase + (PI if sgn > 0 else 0.0)) * (0.40 if entity_mode == 1 else 0.22)) + sin(tt2 * 11.0) * 0.02
					armn.rotation.z = -sgn * (0.22 if entity_mode == 2 else 0.528) + sin(tt2 * 6.1) * 0.04
				else:
					armn.rotation.x = (-1.15 if entity_mode == 2 else sin(ent_phase + (PI if sgn > 0 else 0.0)) * 0.3) + sw * 0.25 + sin(tt2 * 11.0) * 0.02
					armn.rotation.z = sgn * ((0.75 if entity_mode == 2 else 0.10) + sin(tt2 * 6.1) * 0.05)
				var foren := armn.get_node_or_null("Fore")
				if foren != null:
					foren.rotation.x = (-0.5 if entity_mode == 2 else -0.08) + sin(tt2 * 5.7 + sgn) * 0.08
		if ent_model_kind == 2:
			_anim_entity3(d, tt2, p2z)
		if ent_breath != null and is_instance_valid(ent_breath):
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
			sniff_t = minf(sniff_t, 1.6)
		entity.position.y = lerpf(entity.position.y, _terrain_y(Vector2(entity.position.x, entity.position.z), ent_level), minf(1.0, 7.0 * d))
		entity.position.y += absf(sin(tt2 * 4.4)) * (0.055 if entity_mode == 2 else 0.012)
		ent_phase += d * (6.5 if entity_mode == 2 else 2.2)
		for ln2 in ["LegL", "LegR"]:
			var legn := entity.get_node_or_null(ln2)
			if legn != null:
				legn.rotation.x = sin(ent_phase + (0.0 if ln2 == "LegL" else PI)) * (0.8 if entity_mode == 2 else 0.35)
		entity.rotation.x = 0.14 if entity_mode == 2 else 0.04
	_cam_update(d)
	if scare_t > 0.0:
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
			flash_rect.visible = false
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
			play("whisper", -16.0)
	if candy_timer > 0.0:
		candy_timer -= d
		if candy_timer <= 0.0:
			candy_offer = []
	pocket_lbl.text = tt("pocket") % pocket
	if false:
			play("whisper", -6.0)
	elif mistakes >= 2 and rng.randf() < d * 0.03:
		play("whisper", -18.0)
	hud_lbl.text = tt("progress") % int((exit_pos - Vector2(player.position.x, player.position.z)).length()) + "  ·  " + (tt("notes") % notes_found)
	if noise_fill != null:
		noise_fill.size.x = 160.0 * clampf(noise, 0.0, 1.0)


# ============================================================ debug =======
func _dbg_shot(d: float) -> void:
	if shot_i == 0 and shot_frames == 0 and env != null:
		env.sdfgi_enabled = false
		env.volumetric_fog_enabled = false
		env.glow_enabled = false
		get_viewport().msaa_3d = Viewport.MSAA_DISABLED
		get_viewport().scaling_3d_mode = Viewport.SCALING_3D_MODE_BILINEAR
	shot_frames += 1
	var poses := [
		[Vector3(1.8, 0, 7), -PI / 2, ""],
		[Vector3(4.2, 0, 3.2), PI * 0.75, ""],
		[Vector3(10.2, 0, 4.0), PI, ""],
		[Vector3(12.2, 0, 7), -PI / 2, "monster"],
		[Vector3(1.6, 3.1, 6.0), -PI / 2, ""],
		[Vector3(17.2, 0, 7), -PI / 2, "exit"],
	]
	if shot_i >= poses.size():
		get_tree().quit(0)
		return
	var pose: Array = poses[shot_i]
	player.position = pose[0]
	yaw = pose[1]
	pitch = -0.02
	player.rotation = Vector3(0, yaw, 0)
	cam.rotation = Vector3(pitch, 0, 0)
	cam.position = Vector3(0, EYE, 0)
	headlamp.visible = true
	headlamp_on = true
	dust.emitting = true
	if pose[2] == "monster" and entity != null and is_instance_valid(entity):
		entity.visible = true
		entity.position = Vector3(15.0, 0, 7.1)
		entity.rotation.y = atan2(-(player.position.x - entity.position.x), -(player.position.z - entity.position.z))
		var hl := entity.get_node_or_null("Head")
		if hl != null:
			hl.rotation.z = 0.35
			hl.rotation.x = -0.25
		for an in ["ArmL", "ArmR"]:
			var armn := entity.get_node_or_null(an)
			if armn != null:
				armn.rotation.x = -1.7
				armn.rotation.z = (-1.0 if an == "ArmL" else 1.0) * 0.45
				var fn := armn.get_node_or_null("Fore")
				if fn != null:
					fn.rotation.x = -0.6
	if shot_frames == 70:
		DirAccess.make_dir_recursive_absolute("/tmp/le31_shots")
		var img := get_viewport().get_texture().get_image()
		img.save_png("/tmp/le31_shots/shot%d.png" % shot_i)
		print("SHOT ", shot_i, " saved")
	if shot_frames >= 72:
		shot_i += 1
		shot_frames = 0


func _dbg_walk(d: float) -> void:
	var p2 := Vector2(player.position.x, player.position.z)
	var final_goal := exit_pos if has_key_exit else key_exit_pos
	var final_lvl := 0 if has_key_exit else key_exit_lvl
	if not has_key_exit and key_exit_lvl == 1:
		final_goal = Vector2(1.5, 13.4)
		final_lvl = 0
		if (final_goal - p2).length() < 0.8:
			has_key_exit = true
			if key_mesh_e != null and is_instance_valid(key_mesh_e):
				key_mesh_e.visible = false
	if has_key_exit != dbg_had_key:
		dbg_had_key = has_key_exit
		dbg_path = _bfs_path(_node_of(p2, bot_level), _node_of(final_goal, final_lvl))
	if dbg_path.is_empty() and not dbg_done_path:
		dbg_path = _bfs_path(_node_of(spawn_pos, bot_level), _node_of(final_goal, final_lvl))
		dbg_done_path = true
	var goal: Vector2 = final_goal
	var goal_lvl := final_lvl
	if dbg_path.size() > 1:
		goal = NODES[dbg_path[1]]
		goal_lvl = NODE_LVL[dbg_path[1]]
		if (goal - p2).length() < 0.5:
			dbg_path.pop_front()
			if dbg_path.size() > 1:
				goal = NODES[dbg_path[1]]
				goal_lvl = NODE_LVL[dbg_path[1]]
	bot_level = goal_lvl
	var spd := 3.4
	noise = 1.0
	if dbg == "smart":
		spd = 3.6
		noise = 0.05
	if dbg == "quiet":
		spd = 3.5
		noise = 0.14
	if dbg == "blind":
		spd = 3.4
	var dirv := goal - p2
	if dirv.length() > 0.01:
		dirv = dirv.normalized()
		yaw = atan2(-dirv.x, -dirv.y)
	dbg_stuck_t += d
	if (p2 - dbg_last_pos).length() > 0.3:
		dbg_stuck_t = 0.0
		dbg_jdir = 1.0 if rng.randf() < 0.5 else -1.0
	dbg_last_pos = p2
	if dbg_stuck_t > 1.2 and dirv.length() > 0.01:
		var perp := Vector2(-dirv.y, dirv.x) * dbg_jdir
		var nudge := 1.1 if dbg_stuck_t < 3.0 else 2.4
		player.position = Vector3(p2.x + perp.x * nudge, _terrain_y(p2 + perp * nudge, bot_level), p2.y + perp.y * nudge)
		dbg_stuck_t = 0.0
		dbg_jdir = -dbg_jdir
		p2 = Vector2(player.position.x, player.position.z)
	var np2 := p2 + dirv * (spd * d)
	player.position = Vector3(np2.x, _terrain_y(np2, bot_level), np2.y)
	stamina = 1.0


func _dbg_audit(d: float) -> void:
	audit_timer -= d
	if audit_timer > 0.0:
		return
	audit_timer = 0.7
	var fail := ""
	match audit_i:
		0:
			if _bfs_path(_node_of(spawn_pos), _node_of(exit_pos)).size() < 2:
				fail = "bfs"
			var nb := 0
			for c in world.get_children():
				if c is StaticBody3D:
					nb += 1
			print("DBG bodies=", nb)
			if nb < 40:
				fail = "solid"
		1:
			ent_spawn_delay = 0.0
			_begin_run()
			player.position = Vector3(CANDY_SPOTS[0].x, 0, CANDY_SPOTS[0].z)
		2:
			if pocket < 2 or not candy_taken[0]:
				fail = "candy"
			creek_cd[0] = 0.0
			player.position = Vector3(CREEK_ZONES[0].x, 0, CREEK_ZONES[0].y)
		3:
			if creek_cd[0] <= 0.0:
				fail = "creak"
			noise = 1.0
			if entity != null and is_instance_valid(entity):
				entity.position = Vector3(player.position.x + 4.5, 0, player.position.z)
				entity_mode = 0
				entity_path.clear()
		4:
			if entity_mode < 1 and catches < 1:
				fail = "hear"
			pocket = 1
			bait_pos = Vector2(player.position.x + 3.0, player.position.z)
			bait_timer = 4.0
			entity_mode = 0
		5:
			if entity_mode != 1:
				fail = "bait"
			bait_timer = 0.0
			var door_pts := [[Vector3(3.55, 0, 6.8), Vector3(0, 0, -1)], [Vector3(10.05, 0, 6.8), Vector3(0, 0, -1)], [Vector3(16.55, 0, 6.8), Vector3(0, 0, -1)], [Vector3(3.05, 0, 7.2), Vector3(0, 0, 1)], [Vector3(8.05, 0, 7.2), Vector3(0, 0, 1)], [Vector3(17.55, 0, 7.2), Vector3(0, 0, 1)]]
			for dp in door_pts:
				player.global_position = dp[0]
				var crossed := false
				for k5 in range(70):
					player.velocity = dp[1] * 3.4
					player.move_and_slide()
					if dp[1].dot(player.global_position - dp[0]) > 0.9:
						crossed = true
				if not crossed:
					fail = "doors"
					print("DOOR BLOCKED ", dp[0])
			player.global_position = Vector3(1.5, 0.3, 13.5)
			player.velocity = Vector3.ZERO
			if entity != null and is_instance_valid(entity):
				entity_stun = 999.0
			dbg_move_frames = 420
			dbg_move_dir = Vector2(0, -1)
		6:
			if dbg_move_frames > 0:
				return
			if player.global_position.y < 2.4 or player.global_position.z > 9.4:
				fail = "stairs"
				print("STAIRS BLOCKED ", player.global_position)
			if _bfs_path(_node_of(Vector2(1.5, 7.5), 1), _node_of(exit_pos, 0)).size() < 2:
				fail = "upbfs"
			dbg_move_frames = 0
			has_key_exit = true
			player.position = Vector3(exit_pos.x - 0.8, 0, exit_pos.y)
		7:
			if state != "win":
				fail = "win"
			else:
				print("AUDIT ALL OK")
				get_tree().quit(0)
	if fail != "":
		print("AUDIT FAIL step=", audit_i, " ", fail)
		get_tree().quit(1)
	audit_i += 1


# ============================================================ v14 : CAMERA A =====
func _spawn_pile(pv: Vector3) -> void:
	var mi := MeshInstance3D.new()
	var bm := BoxMesh.new()
	bm.size = Vector3(0.05, 0.10, 0.03)
	mi.mesh = bm
	var mm := StandardMaterial3D.new()
	mm.albedo_color = Color(0.25, 0.90, 0.35)
	mm.emission_enabled = true
	mm.emission = Color(0.18, 0.85, 0.28)
	mm.emission_energy_multiplier = 2.4
	mi.material_override = mm
	mi.position = pv + Vector3(0, 0.07, 0)
	mi.rotation.y = rng.randf() * TAU
	world.add_child(mi)
	var li := OmniLight3D.new()
	li.light_color = Color(0.30, 1.0, 0.40)
	li.light_energy = 0.35
	li.omni_range = 1.3
	li.position = Vector3(0, 0.16, 0)
	mi.add_child(li)
	piles.append([pv, mi, false])


func _do_rewind() -> void:
	if state != "play" or rewinding > 0.0 or rewind_cd > 0.0:
		return
	if battery < 12.0:
		_toast(tt("cam_low"), 2.5)
		play("creak", -10.0, 0.8)
		return
	battery = maxf(0.0, battery - 9.0)
	rewind_cd = 7.0
	rewinding = 1.5
	if entity != null and is_instance_valid(entity):
		rewind_pos = entity.position
	if sfx_tape != null:
		sfx_tape.play()
	# le bruit du rembobinage l'attire
	bait_pos = Vector2(player.position.x, player.position.z)
	bait_timer = 3.5
	bait_level = player_level
	_toast(tt("cam_rewind"), 2.2)


func _update_trail() -> void:
	if trail.size() < 2:
		return
	if trail_mi == null or not is_instance_valid(trail_mi):
		trail_mi = MeshInstance3D.new()
		trail_mi.mesh = ImmediateMesh.new()
		var tm := StandardMaterial3D.new()
		tm.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
		tm.albedo_color = Color(0.35, 1.0, 0.45)
		tm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		tm.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
		tm.no_depth_test = true
		trail_mi.material_override = tm
		world.add_child(trail_mi)
	var im := trail_mi.mesh as ImmediateMesh
	im.clear_surfaces()
	im.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for e in trail:
		var p: Vector3 = e[1]
		im.surface_add_vertex(Vector3(p.x, p.y + 0.10, p.z))
	im.surface_end()
	trail_mi.visible = true


func _cam_update(d: float) -> void:
	if cam_overlay == null or state != "play":
		if cam_overlay != null:
			cam_overlay.visible = false
		if cam_lbl != null:
			cam_lbl.visible = false
		return
	# --- lever / baisser ---
	if battery <= 0.0:
		cam_held = false
		cam_sticky = false
	var want := (cam_held or cam_sticky) and battery > 0.0 and rewinding <= 0.0
	if want != cam_raised:
		cam_raised = want
		if sfx_click != null:
			sfx_click.play()
	cam_grade = move_toward(cam_grade, 1.0 if cam_raised else 0.0, d * 4.5)
	# --- batterie ---
	if cam_raised:
		battery = maxf(0.0, battery - d * 0.62)
		if battery <= 0.0:
			cam_raised = false
			cam_sticky = false
			_toast(tt("cam_empty"), 3.2)
			if sfx_click != null:
				sfx_click.play()
	if battery < 20.0:
		lowbatt_t -= d
		if lowbatt_t <= 0.0 and sfx_lowbatt != null:
			sfx_lowbatt.play()
			lowbatt_t = 7.0
	else:
		lowbatt_t = 1.5
	# --- piles ---
	for p in piles:
		if p[2]:
			continue
		var pv: Vector3 = p[0]
		if absf(player.position.y - pv.y) < 1.6 and Vector2(player.position.x - pv.x, player.position.z - pv.z).length() < 1.5:
			p[2] = true
			if is_instance_valid(p[1]):
				p[1].visible = false
			battery = minf(100.0, battery + 35.0)
			battery_charges += 1
			_toast(tt("cam_pile") % 35, 2.4)
			play("chime", -5.0)
	# --- trainee de la creature (20 s) ---
	trail_t -= d
	if trail_t <= 0.0:
		trail_t = 0.1
		if entity != null and is_instance_valid(entity):
			trail.append([run_time, entity.position])
			while trail.size() > 210:
				trail.pop_front()
	if rewind_cd > 0.0:
		rewind_cd -= d
	# --- rembobinage : elle est gelee, on voit ou elle est passee ---
	if rewinding > 0.0:
		rewinding -= d
		_update_trail()
		if entity != null and is_instance_valid(entity):
			entity.position = rewind_pos
			entity_mode = 0
		if rewinding <= 0.0 and trail_mi != null and is_instance_valid(trail_mi):
			trail_mi.visible = false
	elif trail_mi != null and is_instance_valid(trail_mi):
		trail_mi.visible = false
	# --- marqueur rouge sur elle, visible au viseur ---
	if entity != null and is_instance_valid(entity):
		if ent_marker == null or not is_instance_valid(ent_marker) or ent_marker.get_parent() != entity:
			ent_marker = MeshInstance3D.new()
			var sm2 := SphereMesh.new()
			sm2.radius = 0.13
			sm2.height = 0.26
			ent_marker.mesh = sm2
			var mc := StandardMaterial3D.new()
			mc.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
			mc.albedo_color = Color(1.0, 0.22, 0.16, 0.75)
			mc.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
			mc.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
			mc.no_depth_test = true
			ent_marker.material_override = mc
			ent_marker.position = Vector3(0, 2.45, 0)
			entity.add_child(ent_marker)
		ent_marker.visible = cam_raised
	# --- HUD du viseur ---
	cam_overlay.visible = cam_grade > 0.04
	if cam_overlay.material is ShaderMaterial:
		var sm := cam_overlay.material as ShaderMaterial
		sm.set_shader_parameter("fade", cam_grade)
		sm.set_shader_parameter("vig", 0.92)
		sm.set_shader_parameter("grain", 0.09 + (0.10 if battery < 20.0 else 0.0) + (0.40 if rewinding > 0.0 else 0.0))
		sm.set_shader_parameter("scan", 0.10)
		sm.set_shader_parameter("glitch", (1.0 if rewinding > 0.0 else 0.0) + (0.30 if battery < 12.0 else 0.0))
	cam_lbl.visible = cam_grade > 0.04 and hud_on
	if cam_lbl.visible:
		var rec := "\u25cf" if int(Time.get_ticks_msec() / 600) % 2 == 0 else " "
		var ts := 23 * 3600 + 10 * 60 + int(run_time)
		var hh := int(ts / 3600) % 24
		var mi2 := int(ts / 60) % 60
		var ss2 := ts % 60
		cam_lbl.text = "%s REC   HI8   31 OCT 1997   %02d:%02d:%02d   [ %s ]" % [rec, hh, mi2, ss2, tt("cam_batt") % int(battery)]
	if batt_fill != null:
		batt_fill.size.x = 160.0 * clampf(battery / 100.0, 0.0, 1.0)
		batt_fill.color = Color(0.85, 0.20, 0.15, 0.9) if battery < 20.0 else Color(0.30, 0.85, 0.42, 0.85)


func _dbg_cam(d: float) -> void:
	if state != "play":
		return
	if dbg_cam_i == 0 and run_time > 4.0:
		dbg_cam_i = 1
		cam_sticky = true
		print("DBG cam=raise piles=", piles.size(), " batt=", snappedf(battery, 0.1))
	elif dbg_cam_i == 1 and run_time > 7.0:
		dbg_cam_i = 2
		print("DBG cam=raised overlay=", cam_overlay.visible, " grade=", snappedf(cam_grade, 0.01), " batt=", snappedf(battery, 0.1))
		_do_rewind()
	elif dbg_cam_i == 2 and run_time > 8.0:
		dbg_cam_i = 3
		print("DBG cam=rewind rew=", snappedf(rewinding, 0.01), " trail=", trail.size(), " batt=", snappedf(battery, 0.1))
	elif dbg_cam_i == 3 and run_time > 11.0:
		dbg_cam_i = 4
		print("DBG cam=done batt=", snappedf(battery, 0.1), " cd=", snappedf(rewind_cd, 0.1), " pile0=", piles[0][0] if piles.size() > 0 else "none")
		cam_sticky = false
	elif dbg_cam_i == 4 and run_time > 13.0:
		print("DBG cam=OK")
		get_tree().quit(0)


# ======================================================= v15 : monstre 6 parties ====
func _key_model(mat: StandardMaterial3D) -> Node3D:
	# vraie cle : tige + anneau + panneton + deux dents
	var n := Node3D.new()
	var shaft := MeshInstance3D.new()
	var cm := CylinderMesh.new()
	cm.top_radius = 0.006
	cm.bottom_radius = 0.006
	cm.height = 0.135
	cm.radial_segments = 10
	shaft.mesh = cm
	shaft.material_override = mat
	shaft.rotation = Vector3(0, 0, PI / 2)
	n.add_child(shaft)
	var bow := MeshInstance3D.new()
	var tm := TorusMesh.new()
	tm.inner_radius = 0.026
	tm.outer_radius = 0.045
	tm.ring_segments = 20
	bow.mesh = tm
	bow.material_override = mat
	bow.position = Vector3(-0.085, 0, 0)
	bow.rotation = Vector3(PI / 2, 0, 0)
	n.add_child(bow)
	for ti in range(2):
		var tooth := MeshInstance3D.new()
		var bx := BoxMesh.new()
		bx.size = Vector3(0.012, 0.024, 0.010)
		tooth.mesh = bx
		tooth.material_override = mat
		tooth.position = Vector3(0.028 + ti * 0.020, -0.015, 0)
		n.add_child(tooth)
	var far := MeshInstance3D.new()
	var fb := BoxMesh.new()
	fb.size = Vector3(0.040, 0.013, 0.010)
	far.mesh = fb
	far.material_override = mat
	far.position = Vector3(0.052, 0, 0)
	n.add_child(far)
	return n


func _build_entity_model2() -> Node3D:
	# v15 : monstre T-pose decoupe en 6 parties (bras separes -> ils bougent vraiment)
	var b2 = load("res://assets/models/monstre2_body.obj")
	var h2 = load("res://assets/models/monstre2_head.obj")
	var ll2 = load("res://assets/models/monstre2_legL.obj")
	var lr2 = load("res://assets/models/monstre2_legR.obj")
	var al2 = load("res://assets/models/monstre2_armL.obj")
	var ar2 = load("res://assets/models/monstre2_armR.obj")
	var tx2 = load("res://assets/models/monstre2_tex.png")
	if b2 == null or h2 == null or ll2 == null or lr2 == null or al2 == null or ar2 == null or tx2 == null:
		return null
	if dbg != "":
		print("DBG entity=MODEL3D TPOSE (6 parties, bras animes)")
	var m := StandardMaterial3D.new()
	m.albedo_texture = tx2
	m.albedo_color = Color(0.70, 0.68, 0.66)
	m.roughness = 0.74
	m.metallic = 0.0
	m.subsurf_scatter_enabled = true
	m.subsurf_scatter_strength = 0.14
	m.rim_enabled = true
	m.rim = 0.55
	m.rim_tint = 0.6
	m.cull_mode = StandardMaterial3D.CULL_DISABLED
	var nd := Node3D.new()
	var HIP := 0.94
	var NECK := 2.00
	var SHY := 1.88
	var SHX := 0.30
	var body := MeshInstance3D.new()
	body.name = "Body"
	body.mesh = b2
	body.material_override = m
	body.position = Vector3(0, HIP, 0)
	nd.add_child(body)
	for pr in [["LegR", lr2, -0.20], ["LegL", ll2, 0.20]]:
		var lp := Node3D.new()
		lp.name = pr[0]
		lp.position = Vector3(0, HIP, 0)
		lp.rotation = Vector3(0, 0, pr[2])
		var mi := MeshInstance3D.new()
		mi.mesh = pr[1]
		mi.material_override = m
		lp.add_child(mi)
		nd.add_child(lp)
	for pr2 in [["ArmR", ar2, SHX, -0.528], ["ArmL", al2, -SHX, 0.528]]:
		var ap := Node3D.new()
		ap.name = pr2[0]
		ap.position = Vector3(pr2[2], SHY, 0)
		ap.rotation = Vector3(0, 0, pr2[3])
		var mi2 := MeshInstance3D.new()
		mi2.mesh = pr2[1]
		mi2.material_override = m
		ap.add_child(mi2)
		nd.add_child(ap)
	var hd := Node3D.new()
	hd.name = "Head"
	hd.position = Vector3(0, NECK, 0)
	var hm := MeshInstance3D.new()
	hm.mesh = h2
	hm.material_override = m
	hd.add_child(hm)
	nd.add_child(hd)
	var aura := OmniLight3D.new()
	aura.light_color = Color(0.72, 0.68, 0.62)
	aura.light_energy = 0.30
	aura.omni_range = 1.9
	aura.position = Vector3(0, 1.5, 0)
	nd.add_child(aura)
	ent_breath = AudioStreamPlayer3D.new()
	ent_breath.stream = load("res://assets/audio/breath.wav")
	ent_breath.volume_db = -22.0
	ent_breath.unit_size = 6.0
	ent_breath.max_distance = 16.0
	ent_breath.position = Vector3(0, 1.9, 0)
	nd.add_child(ent_breath)
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
	return nd


func _dbg_m2(d: float) -> void:
	dbg_m2_i += 1
	if dbg_m2_i < 3:
		return
	var m := _build_entity_model2()
	if m == null:
		print("DBG m2=ECHEC")
		get_tree().quit(1)
		return
	var total := 0
	for c in m.get_children():
		if not (c is Node3D):
			continue
		var tris := 0
		if c is MeshInstance3D and c.mesh is ArrayMesh:
			var arr: Array = (c.mesh as ArrayMesh).surface_get_arrays(0)
			tris = (arr[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
		else:
			for cc in c.get_children():
				if cc is MeshInstance3D and cc.mesh is ArrayMesh:
					var a2: Array = (cc.mesh as ArrayMesh).surface_get_arrays(0)
					tris += (a2[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
		total += tris
		print("DBG m2 node=%-5s tri=%-6d pos=%s rot=%s" % [c.name, tris, c.position.snapped(Vector3(0.01, 0.01, 0.01)), c.rotation.snapped(Vector3(0.01, 0.01, 0.01))])
	print("DBG m2 total_tris=", total)
	# v17 : verifier aussi le modele a 10 parties
	var m3 := _build_entity_model3()
	if m3 == null:
		print("DBG m3=ECHEC")
		get_tree().quit(1)
		return
	var tot3 := 0
	for c3 in m3.get_children():
		if not (c3 is Node3D):
			continue
		var t3 := 0
		if c3 is MeshInstance3D and c3.mesh is ArrayMesh:
			t3 = ((c3.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
		else:
			for cc3 in c3.get_children():
				if cc3 is MeshInstance3D and cc3.mesh is ArrayMesh:
					t3 += ((cc3.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
				elif cc3 is Node3D:
					for cc4 in cc3.get_children():
						if cc4 is MeshInstance3D and cc4.mesh is ArrayMesh:
							t3 += ((cc4.mesh as ArrayMesh).surface_get_arrays(0)[Mesh.ARRAY_INDEX] as PackedInt32Array).size() / 3
		tot3 += t3
		print("DBG m3 node=%-11s tri=%-6d pos=%s rot=%s enfants=%d" % [c3.name, t3, c3.position.snapped(Vector3(0.01, 0.01, 0.01)), c3.rotation.snapped(Vector3(0.01, 0.01, 0.01)), c3.get_child_count()])
	print("DBG m3 total_tris=", tot3)
	print("DBG m3 OK")
	get_tree().quit(0)


# ============================================== v17 : monstre 10 parties (genoux+coudes) ==
func _build_entity_model3() -> Node3D:
	var b3 = load("res://assets/models/monstre3_body.obj")
	var h3 = load("res://assets/models/monstre3_head.obj")
	var aUr = load("res://assets/models/monstre3_armUR.obj")
	var aLr = load("res://assets/models/monstre3_armLR.obj")
	var aUl = load("res://assets/models/monstre3_armUL.obj")
	var aLl = load("res://assets/models/monstre3_armLL.obj")
	var tR = load("res://assets/models/monstre3_thighR.obj")
	var sR = load("res://assets/models/monstre3_shinR.obj")
	var tL = load("res://assets/models/monstre3_thighL.obj")
	var sL = load("res://assets/models/monstre3_shinL.obj")
	var tx3 = load("res://assets/models/monstre2_tex.png")
	for m0 in [b3, h3, aUr, aLr, aUl, aLl, tR, sR, tL, sL, tx3]:
		if m0 == null:
			return null
	if dbg != "":
		print("DBG entity=MODEL3D DIX PARTIES (genoux + coudes)")
	var m := StandardMaterial3D.new()
	m.albedo_texture = tx3
	m.albedo_color = Color(0.70, 0.68, 0.66)
	m.roughness = 0.74
	m.metallic = 0.0
	m.subsurf_scatter_enabled = true
	m.subsurf_scatter_strength = 0.14
	m.rim_enabled = true
	m.rim = 0.55
	m.rim_tint = 0.6
	m.cull_mode = StandardMaterial3D.CULL_DISABLED
	var nd := Node3D.new()
	var HIP := 0.94
	var NECK := 2.00
	var SHY := 1.88
	var SHX := 0.30
	var ELB := Vector3(0.32, -0.352, 0.0)
	var KNE := Vector3(0.373, -0.47, 0.0)
	var body := MeshInstance3D.new()
	body.name = "Body"
	body.mesh = b3
	body.material_override = m
	body.position = Vector3(0, HIP, 0)
	nd.add_child(body)
	# articulations visibles (cachent les coupes)
	for j in [[Vector3(0, 0, 0), 0.115], [Vector3(SHX, 0, 0), 0.085], [Vector3(-SHX, 0, 0), 0.085]]:
		var js := MeshInstance3D.new()
		var sm := SphereMesh.new()
		sm.radius = j[1]
		sm.height = j[1] * 2.0
		js.mesh = sm
		js.material_override = m
		js.position = j[0]
		body.add_child(js)
	# bras : epaule -> coude
	for pr in [["ArmUpperR", aUr, SHX, -0.528, ELB], ["ArmUpperL", aUl, -SHX, 0.528, Vector3(-ELB.x, ELB.y, 0)]]:
		var ap := Node3D.new()
		ap.name = pr[0]
		ap.position = Vector3(pr[2], SHY, 0)
		ap.rotation = Vector3(0, 0, pr[3])
		var mi := MeshInstance3D.new()
		mi.mesh = pr[1]
		mi.material_override = m
		ap.add_child(mi)
		var jo := MeshInstance3D.new()
		var jm := SphereMesh.new()
		jm.radius = 0.062
		jm.height = 0.124
		jo.mesh = jm
		jo.material_override = m
		jo.position = pr[4]
		ap.add_child(jo)
		var fp := Node3D.new()
		fp.name = "ArmLower"
		fp.position = pr[4]
		var mi2 := MeshInstance3D.new()
		mi2.mesh = (aLr if pr[0].ends_with("R") else aLl)
		mi2.material_override = m
		fp.add_child(mi2)
		ap.add_child(fp)
		nd.add_child(ap)
	# jambes : hanche -> genou
	for pr2 in [["ThighR", tR, -0.20, KNE], ["ThighL", tL, 0.20, Vector3(-KNE.x, KNE.y, 0)]]:
		var lp := Node3D.new()
		lp.name = pr2[0]
		lp.position = Vector3(0, HIP, 0)
		lp.rotation = Vector3(0, 0, pr2[2])
		var mi3 := MeshInstance3D.new()
		mi3.mesh = pr2[1]
		mi3.material_override = m
		lp.add_child(mi3)
		var jk := MeshInstance3D.new()
		var km := SphereMesh.new()
		km.radius = 0.078
		km.height = 0.156
		jk.mesh = km
		jk.material_override = m
		jk.position = pr2[3]
		lp.add_child(jk)
		var sp := Node3D.new()
		sp.name = "Shin"
		sp.position = pr2[3]
		var mi4 := MeshInstance3D.new()
		mi4.mesh = (sR if pr2[0].ends_with("R") else sL)
		mi4.material_override = m
		sp.add_child(mi4)
		lp.add_child(sp)
		nd.add_child(lp)
	var hd := Node3D.new()
	hd.name = "Head"
	hd.position = Vector3(0, NECK, 0)
	var hm := MeshInstance3D.new()
	hm.mesh = h3
	hm.material_override = m
	hd.add_child(hm)
	nd.add_child(hd)
	var aura := OmniLight3D.new()
	aura.light_color = Color(0.72, 0.68, 0.62)
	aura.light_energy = 0.30
	aura.omni_range = 1.9
	aura.position = Vector3(0, 1.5, 0)
	nd.add_child(aura)
	ent_breath = AudioStreamPlayer3D.new()
	ent_breath.stream = load("res://assets/audio/breath.wav")
	ent_breath.volume_db = -22.0
	ent_breath.unit_size = 6.0
	ent_breath.max_distance = 16.0
	ent_breath.position = Vector3(0, 1.9, 0)
	nd.add_child(ent_breath)
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
	ent_step = AudioStreamPlayer3D.new()
	ent_step.stream = load("res://assets/audio/mstep.wav")
	ent_step.volume_db = -8.0
	ent_step.unit_size = 7.0
	ent_step.max_distance = 22.0
	ent_step.position = Vector3(0, 0.15, 0)
	nd.add_child(ent_step)
	return nd


func _anim_entity3(d: float, tt2: float, p2z: Vector2) -> void:
	# marche a 10 parties : hanches, genoux, epaules, coudes, balancement du corps
	var bd := entity.get_node_or_null("Body")
	var hd := entity.get_node_or_null("Head")
	var auR := entity.get_node_or_null("ArmUpperR")
	var auL := entity.get_node_or_null("ArmUpperL")
	var thR := entity.get_node_or_null("ThighR")
	var thL := entity.get_node_or_null("ThighL")
	if bd == null or thR == null or thL == null:
		return
	var ch := entity_mode == 2
	var al := entity_mode == 1
	var amp := 0.78 if ch else (0.46 if al else 0.34)
	if dbg != "" and ent_anim_dbg < 3:
		ent_anim_dbg += 1
		print("DBG anim3 phase=%.2f mode=%d amp=%.2f attente" % [ent_phase, entity_mode, amp])
	var cad := 1.0
	if thR is Node3D and thL is Node3D:
		thR.rotation.x = sin(ent_phase) * amp
		thL.rotation.x = sin(ent_phase + PI) * amp
		var shR := thR.get_node_or_null("Shin")
		var shL := thL.get_node_or_null("Shin")
		if shR != null:
			shR.rotation.x = -maxf(0.0, sin(ent_phase + 0.75)) * (1.15 if ch else 0.72)
		if shL != null:
			shL.rotation.x = -maxf(0.0, sin(ent_phase + PI + 0.75)) * (1.15 if ch else 0.72)
	if auR != null and auL != null:
		var base := -1.05 if ch else -0.10
		auR.rotation.x = base + sin(ent_phase + PI) * (0.55 if ch else amp * 0.85)
		auL.rotation.x = base + sin(ent_phase) * (0.55 if ch else amp * 0.85)
		auR.rotation.z = -0.528 + (0.32 if ch else 0.0)
		auL.rotation.z = 0.528 - (0.32 if ch else 0.0)
		var flR := auR.get_node_or_null("ArmLower")
		var flL := auL.get_node_or_null("ArmLower")
		if flR != null:
			flR.rotation.x = (-0.95 if ch else -0.34) + sin(ent_phase + PI) * 0.18
		if flL != null:
			flL.rotation.x = (-0.95 if ch else -0.34) + sin(ent_phase) * 0.18
	# balancement + tanguage du corps
	bd.position.y = 0.94 + absf(sin(ent_phase)) * (0.055 if ch else 0.030) - (0.028 if ch else 0.015)
	bd.rotation.z = sin(ent_phase) * (0.075 if ch else 0.045)
	bd.rotation.y = sin(ent_phase * 0.5) * 0.05
	bd.rotation.x = (0.10 if ch else 0.02) + absf(sin(ent_phase * 2.0)) * 0.02
	# tete : elle te regarde quand elle te cherche ou te chasse
	if hd != null:
		var want := 0.0
		if entity_mode >= 1:
			var dirw := p2z - Vector2(entity.position.x, entity.position.z)
			if dirw.length_squared() > 0.01:
				want = wrapf(atan2(-dirw.x, -dirw.y) - entity.rotation.y, -PI, PI)
		hd.rotation.y = lerp_angle(hd.rotation.y, clampf(want, -0.9, 0.9), minf(1.0, 4.0 * d))
		hd.rotation.z = sin(tt2 * 7.3) * 0.05
		hd.rotation.x = sin(tt2 * 3.1) * 0.04 - 0.10 - (0.20 if ch else 0.0)
	# pas de la creature, synchronises sur l'animation
	if ent_step != null and is_instance_valid(ent_step):
		if floor(ent_phase / PI) != floor(ent_prev_phase / PI) and ent_phase > ent_prev_phase:
			if not ent_step.playing:
				ent_step.pitch_scale = 1.12 if ch else (1.0 if al else 0.9)
				ent_step.volume_db = -3.0 if ch else -11.0
				ent_step.play()
		ent_prev_phase = ent_phase
	else:
		ent_prev_phase = ent_phase


func _ent_asleep() -> bool:
	# elle dort tant que tu n'as pas touche a une note ET que les 75 premieres secondes ne sont pas passees
	return run_time < ent_spawn_delay and notes_found == 0
