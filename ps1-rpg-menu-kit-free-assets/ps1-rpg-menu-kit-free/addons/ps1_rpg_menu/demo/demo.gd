extends Control
## A small RPG's menus, built from the kit: a title, a line of talk on the road, the main menu with
## the party, items, equipment, status, config and save screens, and a fight on turn gauges.
## The arrow keys and Enter (a pad's d-pad and A) drive it, Esc backs out, the mouse works too, and
## T changes the theme. What this copy of the kit lacks (themes, the fight, the equipment marks)
## is left out.

const Kit := preload("res://addons/ps1_rpg_menu/menu/kit.gd")
const MenuList := preload("res://addons/ps1_rpg_menu/menu/menu_list.gd")
const RpgWindow := preload("res://addons/ps1_rpg_menu/menu/rpg_window.gd")
const Gauge := preload("res://addons/ps1_rpg_menu/menu/gauge.gd")
const DialogueBox := preload("res://addons/ps1_rpg_menu/menu/dialogue_box.gd")
const KIT := "res://addons/ps1_rpg_menu/"
const ART := Vector2(426, 240)
const TALK: Array = [
	["MIRA", "The pass is clear at last. Past the ridge, the old road runs down to Windmere."],
	["ARLO", "Then we camp here tonight. Check the packs before the light goes."],
	["TESS", "Wait. Something is moving out in the long grass..."]]
const STATS: Array[String] = ["STR", "DEF", "MAG", "SPD", "LUCK"]
const SLOTS: Array[String] = ["WEAPON", "SHIELD", "HEAD", "BODY", "CHARM"]
## Each slot's choices: name, icon, and what it adds.
const GEAR := {
	"WEAPON": [["IRON EDGE", "blade", {"STR": 12}], ["STEEL EDGE", "blade", {"STR": 18, "SPD": -2}],
		["ASH STAFF", "staff", {"STR": 4, "MAG": 14}], ["THORN STAFF", "staff", {"MAG": 20, "DEF": -2}]],
	"SHIELD": [["OAK GUARD", "shield", {"DEF": 8}], ["TOWER GUARD", "shield", {"DEF": 14, "SPD": -3}]],
	"HEAD": [["LEATHER CAP", "helm", {"DEF": 4}], ["IRON HELM", "helm", {"DEF": 8, "SPD": -1}]],
	"BODY": [["CHAIN COAT", "armour", {"DEF": 12}], ["SCALE COAT", "armour", {"DEF": 16, "SPD": -2}],
		["SAGE ROBE", "armour", {"DEF": 6, "MAG": 6}]],
	"CHARM": [["MOON RING", "ring", {"MAG": 5, "LUCK": 3}], ["FOX CHARM", "charm", {"SPD": 6, "LUCK": 6}]]}
## name, MP, power (under 0 heals an ally)
const SPELLS: Array = [["FLARE", 8, 150], ["FROST", 8, 140], ["BOLT", 10, 170], ["MEND", 6, -120]]
## name, picture, HP, where it stands (its feet), its move
const ENEMIES: Array = [["WISP", "wisp", 260, Vector2(62, 136), "COLD LIGHT"],
	["SHADE", "shade", 380, Vector2(144, 140), "DUSK CLAW"], ["GOLEM", "golem", 520, Vector2(230, 140), "STONE FIST"]]
## The fight's party column, at the stage's right.
const CARDS_X := 292.0

## A store still: "" plays; title, field, menu, items, equip, status, config, save, battle or
## victory holds that screen; tour walks through them on its own.
@export var pose := ""
@export var theme_name := "ember"
## Scales the art up by whole numbers to fill the window's height, as a 240p game showed.
@export var pixel_scale := true

var stage: Control
## Over the stage, where the target pointer lives.
var overlay: Control
var backdrop: TextureRect
var hint: RpgWindow
var party: Array = []
var items: Array = []
var gold := 12480
var playtime := 4325.0
var files: Array = []
var brightness := 1.0
var opacity := 1.0
var text_speed := 40.0
var screen := ""
## Screen changes bump this, so a sequence still waiting from the last screen stops.
var gen := 0
var battle := {}
var _windows: Array[RpgWindow] = []
var _pick := ""
var _status_of := 0
var _targets: Array = []
var _target := 0
var _on_target: Callable
var _off_target: Callable
var _pointer: TextureRect
var _clock := 0.0


func _ready() -> void:
	get_viewport().canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	if pixel_scale:
		var window := get_tree().root
		window.content_scale_factor = 1.0
		window.content_scale_factor = maxf(1.0, floorf(window.get_visible_rect().size.y / ART.y))
	if not theme_name in Kit.themes():
		theme_name = Kit.themes()[0]
	theme = Kit.kit_theme(theme_name)
	backdrop = TextureRect.new()
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage = Control.new()
	stage.custom_minimum_size = ART
	stage.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(stage)
	overlay = Control.new()
	overlay.custom_minimum_size = ART
	overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	center.add_child(overlay)
	_pointer = TextureRect.new()
	_pointer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_pointer.hide()
	overlay.add_child(_pointer)
	_new_game()
	if pose == "" and Kit.themes().size() > 1:
		_hint()
	match pose:
		"", "title": show_title()
		"tour": tour()
		_: call("_pose_" + pose)


func _process(delta: float) -> void:
	_clock += delta
	if screen == "battle":
		_battle_tick(delta)
	if _pointer.visible:
		_place_pointer()


func _unhandled_input(e: InputEvent) -> void:
	var back: bool = e.is_action_pressed(&"ui_cancel") or (e is InputEventMouseButton and e.pressed
		and e.button_index == MOUSE_BUTTON_RIGHT)
	var go: bool = e.is_action_pressed(&"ui_accept") or (e is InputEventMouseButton and e.pressed
		and e.button_index == MOUSE_BUTTON_LEFT)
	if e is InputEventKey and e.pressed and not e.echo and e.keycode == KEY_T and pose == "":
		next_theme()
	elif screen == "target":
		_target_input(e, go, back)
	elif screen == "status":
		if back:
			Kit.play(self, "cancel")
			open_menu(2 if _has_equip() else 1)
		elif e.is_action_pressed(&"ui_right") or e.is_action_pressed(&"ui_left"):
			Kit.play(self, "cursor")
			open_status((_status_of + (1 if e.is_action_pressed(&"ui_right") else party.size() - 1)) % party.size())
	elif screen == "victory" and go:
		open_menu()
	else:
		return
	get_viewport().set_input_as_handled()


## The next installed theme, over every window.
func next_theme() -> void:
	var names := Kit.themes()
	theme_name = names[(names.find(theme_name) + 1) % names.size()]
	theme = Kit.kit_theme(theme_name)
	if hint:
		(hint.get_child(0) as Label).text = "T " + theme_name.to_upper()


# ---- the game ----

func _new_game() -> void:
	party = [
		{"name": "ARLO", "job": "BLADE", "lv": 12, "hp": 286, "max_hp": 312, "mp": 34, "max_mp": 48, "exp": 0.62,
			"next": 1240, "base": {"STR": 30, "DEF": 18, "MAG": 8, "SPD": 16, "LUCK": 9}, "speed": 0.42,
			"gear": {"WEAPON": 0, "SHIELD": 0, "HEAD": 0, "BODY": 0, "CHARM": -1}},
		{"name": "MIRA", "job": "SAGE", "lv": 11, "hp": 164, "max_hp": 198, "mp": 92, "max_mp": 110, "exp": 0.91,
			"next": 210, "base": {"STR": 12, "DEF": 10, "MAG": 28, "SPD": 14, "LUCK": 12}, "speed": 0.36,
			"gear": {"WEAPON": 2, "SHIELD": -1, "HEAD": 0, "BODY": 2, "CHARM": 0}},
		{"name": "TESS", "job": "SCOUT", "lv": 12, "hp": 52, "max_hp": 240, "mp": 20, "max_mp": 36, "exp": 0.35,
			"next": 1980, "base": {"STR": 22, "DEF": 12, "MAG": 10, "SPD": 26, "LUCK": 18}, "speed": 0.5,
			"gear": {"WEAPON": 0, "SHIELD": -1, "HEAD": 0, "BODY": 0, "CHARM": 1}}]
	items = []
	for it: Array in [["potion", "POTION", 12, "Restores 100 HP to one ally.", 100],
			["ether", "ETHER", 4, "Restores 40 MP to one ally.", -40],
			["elixir", "ELIXIR", 1, "Restores all HP and MP to one ally.", 999],
			["herb", "FIELD HERB", 9, "Restores 40 HP to one ally.", 40],
			["antidote", "ANTIDOTE", 6, "Cures poison.", 0], ["plume", "WAKE PLUME", 2, "Wakes a fallen ally.", 0],
			["bread", "TRAIL BREAD", 5, "A day's food for the road.", 0],
			["tent", "TENT", 2, "Rest the night at a camp.", 0],
			["gem", "STAR SHARD", 3, "Glows faintly. A smith would want it.", 0],
			["book", "OLD PRIMER", 1, "Notes on the first spells.", 0],
			["map", "ROAD MAP", 1, "The roads of the eastern march.", 0],
			["key", "GATE KEY", 1, "Opens the gate at Windmere.", 0]]:
		if Kit.icon(it[0]):
			items.append({"icon": it[0], "name": it[1], "count": it[2], "help": it[3], "heal": it[4]})
	files = [{"leader": "ARLO", "lv": 9, "place": "OLD MILL", "time": 2410.0, "gold": 6020}, null, null]


func _stat(m: Dictionary, stat: String, gear: Dictionary = {}) -> int:
	var total: int = m["base"][stat]
	var on: Dictionary = gear if not gear.is_empty() else m["gear"]
	for slot in SLOTS:
		var i: int = on[slot]
		if i >= 0:
			total += GEAR[slot][i][2].get(stat, 0)
	return total


func _has_equip() -> bool:
	return Kit.mark("up") != null


func _has_battle() -> bool:
	return ResourceLoader.exists(KIT + "demo/textures/battle.png")


static func thousands(n: int) -> String:
	var s := str(n)
	var out := ""
	while s.length() > 3:
		out = "," + s.right(3) + out
		s = s.left(s.length() - 3)
	return s + out


static func clock_text(seconds: float) -> String:
	return "%d:%02d" % [int(seconds) / 3600, int(seconds) / 60 % 60]


# ---- building blocks ----

func _clear(backdrop_name: String) -> void:
	gen += 1
	_pointer.hide()
	for c in stage.get_children():
		c.queue_free()
	_windows.clear()
	var path := KIT + "demo/textures/%s.png" % backdrop_name
	backdrop.texture = load(path) if ResourceLoader.exists(path) else null


## A window at `rect` in the 426x240 stage; a height of 0 fits its contents.
func win(rect: Rect2, title := "", parent: Node = null) -> RpgWindow:
	var w: RpgWindow = RpgWindow.new()
	w.position = rect.position
	w.size = rect.size
	w.title = title
	w.brightness = brightness
	w.opacity = opacity
	(parent if parent else stage).add_child(w)
	_windows.append(w)
	return w


func list(parent: Node, columns := 1, width := 0) -> MenuList:
	var l: MenuList = MenuList.new()
	l.columns = columns
	l.item_width = width
	parent.add_child(l)
	return l


func vbox(parent: Node, gap := 0) -> VBoxContainer:
	var b := VBoxContainer.new()
	b.add_theme_constant_override(&"separation", gap)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(b)
	return b


func hbox(parent: Node, gap := 4) -> HBoxContainer:
	var b := HBoxContainer.new()
	b.add_theme_constant_override(&"separation", gap)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(b)
	return b


func gauge(parent: Node, kind: String, value: float, top: float, width := 64, text := true) -> Gauge:
	var g: Gauge = Gauge.new()
	g.kind = kind
	g.max_value = top
	g.value = value
	g.width = width
	g.show_text = text
	parent.add_child(g)
	return g


func fixed(label: Label, width: float, align := HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	label.custom_minimum_size.x = width
	label.horizontal_alignment = align
	return label


func help_window(text := "") -> Label:
	return Kit.label(win(Rect2(6, 6, 414, 0)), text)


## The party side by side, a card each with level and gauges, as a list to pick one from.
func party_window(rect: Rect2) -> MenuList:
	var l := list(win(rect, "PARTY"), party.size())
	l.active = false
	l.idle_cursor = false
	var card := Vector2((rect.size.x - 20 - l.column_gap * (party.size() - 1)) / party.size(), 106)
	for m: Dictionary in party:
		var b := l.add_item("")
		b.custom_minimum_size = card
		var col := vbox(b, 2)
		col.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		col.offset_left = 6
		col.offset_right = -6
		col.alignment = BoxContainer.ALIGNMENT_CENTER
		var top := hbox(col, 6)
		Kit.label(top, m["name"], &"Hot")
		Kit.label(top, "LV %d" % m["lv"], &"Accent")
		Kit.label(col, m["job"], &"Dim")
		gauge(col, "hp", m["hp"], m["max_hp"], int(card.x) - 12)
		gauge(col, "mp", m["mp"], m["max_mp"], int(card.x) - 12)
		gauge(col, "exp", m["exp"] * 100.0, 100.0, int(card.x) - 12)
	return l


## A window of the party by name with HP, to pick one from. Returns its list.
func ally_picker(at: Vector2) -> MenuList:
	var w := win(Rect2(at, Vector2(170, 0)), "WHO?")
	w.pop_open(0.08, false)
	var l := list(w, 1, 148)
	for m: Dictionary in party:
		l.add_item(m["name"], null, "%d/%d" % [m["hp"], m["max_hp"]])
	for b in l.items:
		(b.get_child(0) as Label).offset_left = -100
	l.cancelled.connect(w.queue_free)
	return l


func _refresh_picker(l: MenuList) -> void:
	for k in party.size():
		(l.items[k].get_child(0) as Label).text = "%d/%d" % [party[k]["hp"], party[k]["max_hp"]]


## Heals party member `who` by an item or spell's power: HP, or MP if it's under 0, or both at 999.
## Returns what it restored.
func _heal(who: int, power: int) -> int:
	var m: Dictionary = party[who]
	if power < 0:
		var mp: int = m["mp"]
		m["mp"] = mini(m["max_mp"], mp - power)
		return m["mp"] - mp
	var hp: int = m["hp"]
	m["hp"] = mini(m["max_hp"], hp + power)
	if power >= 999:
		m["mp"] = m["max_mp"]
	return m["hp"] - hp


func _number(at: Vector2, amount: int, heal: bool) -> void:
	if ResourceLoader.exists(KIT + "menu/damage_number.gd"):
		load(KIT + "menu/damage_number.gd").pop(stage, at, amount, heal)
	else:
		Kit.play(self, "heal" if heal else "hit")


func _row_point(b: Control, right := 40.0) -> Vector2:
	return b.global_position - stage.global_position + Vector2(b.size.x - right, b.size.y / 2.0)


func _hint() -> void:
	hint = RpgWindow.new()
	hint.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(hint)
	hint.anchor_top = 1.0
	hint.anchor_bottom = 1.0
	hint.offset_left = 4
	hint.offset_top = -4
	hint.offset_bottom = -4
	hint.grow_vertical = Control.GROW_DIRECTION_BEGIN
	Kit.label(hint, "T " + theme_name.to_upper(), &"Dim")
	hint.gui_input.connect(func(e: InputEvent) -> void:
		if e is InputEventMouseButton and e.pressed:
			next_theme())


# ---- title and field ----

func show_title() -> void:
	_clear("title")
	screen = "title"
	var head := vbox(stage, 2)
	head.position = Vector2(0, 58)
	head.size = Vector2(ART.x, 0)
	fixed(Kit.label(head, "EMBERFALL", &"Big"), ART.x, HORIZONTAL_ALIGNMENT_CENTER)
	fixed(Kit.label(head, "THE ROAD TO WINDMERE", &"Dim"), ART.x, HORIZONTAL_ALIGNMENT_CENTER)
	var l := list(win(Rect2(160, 134, 106, 0)))
	l.set_items(["NEW GAME", "CONTINUE", "CONFIG"])
	l.chosen.connect(func(i: int) -> void:
		match i:
			0: show_field()
			1: open_save(true)
			2: open_config(true)
	)


func show_field(line := 0) -> DialogueBox:
	_clear("field")
	screen = "field"
	var box: DialogueBox = DialogueBox.new()
	box.position = Vector2(12, 166)
	box.size = Vector2(402, 0)
	box.speed = text_speed
	box.brightness = brightness
	box.opacity = opacity
	stage.add_child(box)
	_windows.append(box)
	var at := [line]
	box.say(TALK[line][1], TALK[line][0])
	box.advanced.connect(func() -> void:
		at[0] += 1
		if at[0] < TALK.size():
			box.say(TALK[at[0]][1], TALK[at[0]][0])
		elif _has_battle():
			start_battle()
		else:
			open_menu())
	return box


# ---- the main menu ----

func open_menu(index := 0) -> MenuList:
	_clear("field")
	screen = "menu"
	var entries: Array = ["ITEM", "EQUIP", "STATUS", "CONFIG", "SAVE"]
	if not _has_equip():
		entries.erase("EQUIP")
	if _has_battle():
		entries.append("FIGHT")
	var l := list(win(Rect2(6, 6, 414, 0)), entries.size())
	l.set_items(entries)
	l.select(index)
	var people := party_window(Rect2(6, 52, 414, 0))
	var foot := hbox(win(Rect2(6, 206, 414, 0)), 6)
	Kit.label(foot, "WINDMERE PASS")
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	foot.add_child(gap)
	Kit.picture(foot, Kit.icon("coin"))
	Kit.label(foot, thousands(gold) + " G")
	Kit.label(foot, " TIME", &"Accent")
	Kit.label(foot, clock_text(playtime))
	l.cancelled.connect(show_field.bind(TALK.size() - 1))
	l.chosen.connect(func(i: int) -> void:
		match entries[i]:
			"ITEM": open_items()
			"CONFIG": open_config()
			"SAVE": open_save()
			"FIGHT": start_battle()
			_:
				_pick = entries[i]
				l.active = false
				people.idle_cursor = true
				people.active = true
				people.select(0)
	)
	people.cancelled.connect(func() -> void:
		people.active = false
		people.idle_cursor = false
		l.active = true)
	people.chosen.connect(func(who: int) -> void:
		if _pick == "EQUIP":
			open_equip(who)
		else:
			open_status(who))
	return l


# ---- items ----

func open_items(index := 0) -> MenuList:
	_clear("field")
	screen = "items"
	var help := help_window()
	var l := list(win(Rect2(6, 46, 414, 0), "ITEMS"), 2, 188)
	_fill_items(l)
	l.moved.connect(func(i: int) -> void: help.text = items[i]["help"])
	l.select(index)
	help.text = items[l.index]["help"] if l.index < items.size() else ""
	l.cancelled.connect(open_menu.bind(0))
	l.chosen.connect(func(i: int) -> void:
		l.active = false
		var who := ally_picker(Vector2(236, 40))
		who.cancelled.connect(func() -> void: l.active = true)
		who.chosen.connect(func(k: int) -> void: _use_item(l, i, who, k)))
	return l


func _fill_items(l: MenuList) -> void:
	var entries: Array = []
	for it: Dictionary in items:
		entries.append({"text": it["name"], "icon": it["icon"], "right": str(it["count"]), "disabled": it["heal"] == 0})
	l.set_items(entries)


func _use_item(from: MenuList, i: int, picker: MenuList, who: int) -> void:
	var it: Dictionary = items[i]
	var got := _heal(who, it["heal"])
	_number(_row_point(picker.items[who], 34.0), got, true)
	_refresh_picker(picker)
	it["count"] -= 1
	if it["count"] <= 0:
		items.remove_at(i)
		picker.get_parent().queue_free()
		from.active = true
	var keep := mini(from.index, items.size() - 1)
	_fill_items(from)
	from.index = keep


# ---- equipment ----

func open_equip(who: int, slot := 0) -> void:
	_clear("field")
	screen = "equip"
	var m: Dictionary = party[who]
	var help := help_window("Choose what to change.")
	var gear_win := win(Rect2(6, 46, 214, 0), m["name"])
	var row := hbox(gear_win, 6)
	var names := vbox(row)
	for s in SLOTS:
		var n := Kit.label(names, s, &"Accent")
		n.custom_minimum_size = Vector2(52, 15)
		n.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	var slots := list(row, 1, 136)
	var stats_win := win(Rect2(226, 46, 194, 0), "STATS")
	var grid := GridContainer.new()
	grid.columns = 5
	grid.add_theme_constant_override(&"h_separation", 6)
	grid.add_theme_constant_override(&"v_separation", 2)
	stats_win.add_child(grid)
	var shown := {}
	for s in STATS:
		fixed(Kit.label(grid, s, &"Accent"), 36)
		shown[s] = [fixed(Kit.label(grid, ""), 22, HORIZONTAL_ALIGNMENT_RIGHT), Kit.label(grid, ">", &"Dim"),
			fixed(Kit.label(grid, ""), 22, HORIZONTAL_ALIGNMENT_RIGHT), Kit.picture(grid, null)]
	var choices := list(win(Rect2(6, 150, 414, 0), "CHANGE TO"), 2, 188)
	choices.active = false
	choices.idle_cursor = false

	var compare := func(trial: Dictionary) -> void:
		for s in STATS:
			var now := _stat(m, s)
			var then := _stat(m, s, trial)
			shown[s][0].text = str(now)
			shown[s][2].text = str(then)
			shown[s][2].theme_type_variation = &"Good" if then > now else (&"Bad" if then < now else &"")
			shown[s][3].texture = Kit.mark("up" if then > now else ("down" if then < now else "same"))
	var fill_slots := func() -> void:
		var entries: Array = []
		for s in SLOTS:
			var i: int = m["gear"][s]
			entries.append({"text": "-" if i < 0 else GEAR[s][i][0], "icon": null if i < 0 else GEAR[s][i][1]})
		var keep := slots.index
		slots.set_items(entries)
		slots.index = keep
	var describe := func(g: Array) -> String:
		var parts: PackedStringArray = []
		for s: String in g[2]:
			parts.append("%s %+d" % [s, g[2][s]])
		return g[0] + ": " + ", ".join(parts)
	fill_slots.call()
	compare.call(m["gear"])
	slots.select(slot)
	slots.cancelled.connect(open_menu.bind(1))
	slots.moved.connect(func(_i: int) -> void: compare.call(m["gear"]))
	slots.chosen.connect(func(i: int) -> void:
		var s := SLOTS[i]
		var entries: Array = []
		for g: Array in GEAR[s]:
			entries.append({"text": g[0], "icon": g[1]})
		choices.set_items(entries)
		slots.active = false
		choices.idle_cursor = true
		choices.active = true
		var now: int = m["gear"][s]
		choices.select(maxi(0, now))
		var trial: Dictionary = m["gear"].duplicate()
		trial[s] = choices.index
		compare.call(trial)
		help.text = describe.call(GEAR[s][choices.index]))
	choices.moved.connect(func(c: int) -> void:
		var s := SLOTS[slots.index]
		var trial: Dictionary = m["gear"].duplicate()
		trial[s] = c
		compare.call(trial)
		help.text = describe.call(GEAR[s][c]))
	var back := func() -> void:
		choices.set_items([])
		choices.active = false
		choices.idle_cursor = false
		slots.active = true
		compare.call(m["gear"])
		help.text = "Choose what to change."
	choices.cancelled.connect(back)
	choices.chosen.connect(func(c: int) -> void:
		m["gear"][SLOTS[slots.index]] = c
		Kit.play(self, "equip")
		fill_slots.call()
		back.call())


# ---- status ----

func open_status(who: int) -> void:
	_clear("field")
	screen = "status"
	_status_of = who
	var m: Dictionary = party[who]
	var w := win(Rect2(6, 20, 414, 0), m["name"])
	var cols := hbox(w, 18)
	var left := vbox(cols, 2)
	left.custom_minimum_size.x = 150
	var top := hbox(left, 8)
	Kit.label(top, "LV", &"Accent")
	Kit.label(top, str(m["lv"]), &"Big")
	Kit.label(left, m["job"], &"Dim")
	gauge(left, "hp", m["hp"], m["max_hp"], 140)
	gauge(left, "mp", m["mp"], m["max_mp"], 140)
	gauge(left, "exp", m["exp"] * 100.0, 100.0, 140)
	var nxt := hbox(left, 6)
	Kit.label(nxt, "NEXT LV", &"Dim")
	Kit.label(nxt, thousands(m["next"]))
	var state := hbox(left, 6)
	Kit.label(state, "STATE", &"Dim")
	Kit.label(state, "NORMAL", &"Good")
	var right := vbox(cols, 2)
	var grid := GridContainer.new()
	grid.columns = 4
	grid.add_theme_constant_override(&"h_separation", 10)
	right.add_child(grid)
	for s in STATS:
		fixed(Kit.label(grid, s, &"Accent"), 32)
		fixed(Kit.label(grid, str(_stat(m, s))), 24, HORIZONTAL_ALIGNMENT_RIGHT)
	right.add_child(HSeparator.new())
	for s in SLOTS:
		var i: int = m["gear"][s]
		var r := hbox(right, 4)
		r.custom_minimum_size.y = 13
		fixed(Kit.label(r, s, &"Dim"), 52)
		if i >= 0:
			Kit.picture(r, Kit.icon(GEAR[s][i][1]))
			Kit.label(r, GEAR[s][i][0])
		else:
			Kit.label(r, "-", &"Dim")
	var foot := hbox(win(Rect2(6, 206, 0, 0)), 6)
	Kit.label(foot, "< >", &"Accent")
	Kit.label(foot, "NEXT", &"Dim")


# ---- config ----

func open_config(from_title := false) -> MenuList:
	_clear("title" if from_title else "field")
	screen = "config"
	var w := win(Rect2(58, 20, 310, 0), "CONFIG")
	var l := list(w, 1, 286)
	var rows: Array = ["SOUND", "TEXT SPEED", "BRIGHTNESS", "TRANSLUCENT"]
	if Kit.themes().size() > 1:
		rows.push_front("WINDOW")
	var controls := {}
	for r: String in rows:
		var b := l.add_item(r)
		var right := hbox(b, 6)
		right.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
		right.offset_left = -150
		right.offset_right = -6
		right.alignment = BoxContainer.ALIGNMENT_END
		var c: Control
		match r:
			"WINDOW":
				c = Kit.label(right, "")
			"TRANSLUCENT":
				var box := CheckBox.new()
				box.focus_mode = Control.FOCUS_NONE
				box.button_pressed = opacity < 1.0
				box.toggled.connect(func(on: bool) -> void:
					opacity = 0.75 if on else 1.0
					_style_windows()
	)
				c = box
				right.add_child(box)
			_:
				var s := HSlider.new()
				s.focus_mode = Control.FOCUS_NONE
				s.custom_minimum_size.x = 90
				s.size_flags_vertical = Control.SIZE_SHRINK_CENTER
				right.add_child(s)
				var value := Kit.label(right, "")
				value.custom_minimum_size.x = 34
				value.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
				s.set_meta("value", value)
				c = s
		controls[r] = c
	var preview: DialogueBox = DialogueBox.new()
	preview.position = Vector2(58, 150)
	preview.size = Vector2(310, 0)
	preview.lines = 2
	preview.takes_input = false
	preview.speed = text_speed
	preview.brightness = brightness
	preview.opacity = opacity
	stage.add_child(preview)
	_windows.append(preview)

	var shown := func() -> void:
		if controls.has("WINDOW"):
			controls["WINDOW"].text = "< %s >" % theme_name.to_upper()
	var setup := func(r: String, s: HSlider, lo: float, hi: float, step: float, v: float, text: Callable) -> void:
		s.min_value = lo
		s.max_value = hi
		s.step = step
		s.value = v
		s.get_meta("value").text = text.call(v)
		s.value_changed.connect(func(x: float) -> void:
			s.get_meta("value").text = text.call(x)
			match r:
				"SOUND":
					Kit.volume_db = -80.0 if x <= -30.0 else x
				"TEXT SPEED":
					text_speed = 0.0 if x >= 90.0 else x
					preview.speed = text_speed
					preview.say("Windows, the cursor and the sounds follow these settings.", "MIRA")
				"BRIGHTNESS":
					brightness = x
					_style_windows()
	)
	setup.call("SOUND", controls["SOUND"], -30.0, 0.0, 6.0, maxf(-30.0, Kit.volume_db),
		func(x: float) -> String: return "OFF" if x <= -30.0 else "%d" % roundi((x + 30.0) / 6.0))
	setup.call("TEXT SPEED", controls["TEXT SPEED"], 10.0, 90.0, 10.0, 90.0 if text_speed == 0.0 else text_speed,
		func(x: float) -> String: return "ALL" if x >= 90.0 else "%d" % roundi(x / 10.0))
	setup.call("BRIGHTNESS", controls["BRIGHTNESS"], 0.5, 1.5, 0.1, brightness,
		func(x: float) -> String: return "%d%%" % roundi(x * 100.0))
	shown.call()
	preview.say("Windows, the cursor and the sounds follow these settings.", "MIRA")

	for i in l.items.size():
		var r: String = rows[i]
		l.items[i].gui_input.connect(func(e: InputEvent) -> void:
			var step := 0
			if e.is_action_pressed(&"ui_left", true):
				step = -1
			elif e.is_action_pressed(&"ui_right", true):
				step = 1
			if step == 0:
				return
			l.accept_event()
			Kit.play(self, "cursor")
			match r:
				"WINDOW":
					var names := Kit.themes()
					theme_name = names[(names.find(theme_name) + step + names.size()) % names.size()]
					theme = Kit.kit_theme(theme_name)
					shown.call()
				"TRANSLUCENT":
					controls[r].button_pressed = step > 0
				_:
					controls[r].value += step * controls[r].step
	)
	l.chosen.connect(func(i: int) -> void:
		var r: String = rows[i]
		if r == "TRANSLUCENT":
			controls[r].button_pressed = not controls[r].button_pressed
		elif r == "WINDOW":
			next_theme()
			shown.call())
	l.cancelled.connect(func() -> void:
		if from_title:
			show_title()
		else:
			open_menu(3 if _has_equip() else 2))
	return l


func _style_windows() -> void:
	for w in _windows:
		if is_instance_valid(w):
			w.brightness = brightness
			w.opacity = opacity


# ---- save ----

func open_save(loading := false) -> MenuList:
	_clear("title" if loading else "field")
	screen = "save"
	var help := help_window("Load which file?" if loading else "Save to which file?")
	var w := win(Rect2(36, 48, 354, 0), "LOAD" if loading else "SAVE")
	var l := list(w, 1, 0)
	_fill_files(l)
	l.select(0 if loading else 1)
	l.cancelled.connect(func() -> void:
		if loading:
			show_title()
		else:
			open_menu(4 if _has_equip() else 3))
	l.chosen.connect(func(i: int) -> void:
		if loading:
			if files[i] == null:
				Kit.play(self, "buzzer")
				return
			l.active = false
			help.text = "Loading..."
			var g := gen
			await get_tree().create_timer(0.6).timeout
			if g == gen:
				open_menu()
			return
		l.active = false
		var ask := list(win(Rect2(150, 150, 126, 0), "SAVE HERE?"), 2, 44)
		ask.set_items(["YES", "NO"])
		ask.cancelled.connect(func() -> void:
			ask.get_parent().queue_free()
			l.active = true)
		ask.chosen.connect(func(yes: int) -> void:
			ask.get_parent().queue_free()
			if yes != 0:
				l.active = true
				return
			_save_to(l, help, i)))
	return l


func _save_to(l: MenuList, help: Label, i: int) -> void:
	var g := gen
	help.text = "Saving. Don't switch off..."
	await get_tree().create_timer(0.8).timeout
	if g != gen:
		return
	files[i] = {"leader": party[0]["name"], "lv": party[0]["lv"], "place": "WINDMERE PASS", "time": playtime,
		"gold": gold}
	Kit.play(self, "save")
	help.text = "Saved to file %d." % (i + 1)
	_fill_files(l)
	l.active = true
	l.select(i)


func _fill_files(l: MenuList) -> void:
	var keep := l.index
	l.set_items([])
	for i in files.size():
		var f: Variant = files[i]
		var b := l.add_item("")
		b.custom_minimum_size = Vector2(330, 34)
		var row := hbox(b, 14)
		row.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		row.offset_left = 8
		var a := vbox(row)
		a.alignment = BoxContainer.ALIGNMENT_CENTER
		fixed(Kit.label(a, "FILE %d" % (i + 1), &"Accent"), 56)
		if f == null:
			Kit.label(a, "EMPTY", &"Dim")
			continue
		Kit.label(a, f["place"], &"Dim")
		var c := vbox(row)
		c.alignment = BoxContainer.ALIGNMENT_CENTER
		Kit.label(c, "%s  LV %d" % [f["leader"], f["lv"]])
		var d := hbox(c, 12)
		Kit.label(d, "TIME " + clock_text(f["time"]), &"Dim")
		Kit.label(d, thousands(f["gold"]) + " G", &"Dim")
	l.index = keep


# ---- the fight ----

func start_battle() -> void:
	_clear("battle")
	screen = "battle"
	battle = {"enemies": [], "turn": [], "acting": false, "bars": [], "hp": [], "menu": null, "windows": []}
	for e: Array in ENEMIES:
		var t := TextureRect.new()
		t.texture = load(KIT + "demo/textures/%s.png" % e[1])
		t.mouse_filter = Control.MOUSE_FILTER_STOP
		t.size = t.texture.get_size()
		t.position = (e[3] - Vector2(t.size.x / 2.0, t.size.y)).round()
		stage.add_child(t)
		var foe := {"name": e[0], "hp": e[2], "node": t, "move": e[4], "clock": randf_range(0.0, 0.4)}
		battle["enemies"].append(foe)
		t.mouse_entered.connect(func() -> void:
			if screen == "target" and foe in _targets and _targets.find(foe) != _target:
				_target = _targets.find(foe)
				Kit.play(self, "cursor"))
		t.gui_input.connect(func(ev: InputEvent) -> void:
			if screen == "target" and ev is InputEventMouseButton and ev.pressed and foe in _targets:
				_target = _targets.find(foe)
				_target_input(InputEventAction.new(), true, false))
	for k in party.size():
		var card := win(Rect2(CARDS_X, 16 + 86 * k, 128, 0), party[k]["name"])
		var rows := vbox(card, 1)
		var hp := _card_row(rows, "HP")
		var mp := _card_row(rows, "MP")
		var bar := gauge(rows, "turn", 0.0, 1.0, 108, false)
		battle["turn"].append(randf_range(0.2, 0.7))
		battle["bars"].append(bar)
		battle["hp"].append([hp, mp, card])
	_battle_numbers()


func _card_row(parent: Node, caption: String) -> Label:
	var r := hbox(parent, 0)
	fixed(Kit.label(r, caption, &"Accent"), 24)
	return fixed(Kit.label(r, ""), 84, HORIZONTAL_ALIGNMENT_RIGHT)


func _battle_numbers() -> void:
	for k in party.size():
		var m: Dictionary = party[k]
		var hp: Label = battle["hp"][k][0]
		hp.text = "%d/%4d" % [m["hp"], m["max_hp"]]
		hp.theme_type_variation = &"Low" if m["hp"] * 4 <= m["max_hp"] else &""
		battle["hp"][k][1].text = "%d/%4d" % [m["mp"], m["max_mp"]]


func _battle_tick(delta: float) -> void:
	if battle.is_empty() or battle["acting"]:
		return
	for k in party.size():
		battle["turn"][k] = minf(1.0, battle["turn"][k] + delta * party[k]["speed"])
		battle["bars"][k].value = battle["turn"][k]
	for k in party.size():
		if battle["turn"][k] >= 1.0:
			_command(k)
			return
	for foe: Dictionary in battle["enemies"]:
		if foe["hp"] > 0:
			foe["clock"] += delta * 0.16
			if foe["clock"] >= 1.0:
				foe["clock"] = 0.0
				_enemy_turn(foe)
				return


## Opens party member `k`'s commands; the gauges wait meanwhile.
func _command(k: int, index := 0) -> MenuList:
	battle["acting"] = true
	var w := _battle_window(Rect2(6, 0, 0, 0), party[k]["name"])
	w.pop_open()
	var l := list(w, 3)
	l.set_items(["ATTACK", "MAGIC", "ITEM", "DEFEND", {"text": "RUN", "disabled": true}])
	l.select(index)
	_rest_on_floor(w)
	battle["menu"] = l
	l.chosen.connect(func(i: int) -> void:
		match i:
			0:
				l.active = false
				_choose_target(battle["enemies"].filter(func(f: Dictionary) -> bool: return f["hp"] > 0),
					func(foe: Variant) -> void: _act(k, foe, randi_range(70, 130), "ATTACK"),
					func() -> void: l.active = true)
			1: _spells(k, l)
			2: _battle_items(k, l)
			3: _end_turn(k)
	)
	return l


## A window of the turn's menus, which _close_menus takes down.
func _battle_window(rect: Rect2, title: String) -> RpgWindow:
	var w := win(rect, title)
	battle["windows"].append(w)
	return w


## Stands a battle menu on the stage's foot, under the enemies' feet, once it fits its contents.
func _rest_on_floor(w: RpgWindow) -> void:
	w.reset_size()
	w.position.y = ART.y - 6.0 - w.size.y


func _spells(k: int, from: MenuList) -> void:
	from.active = false
	var w := _battle_window(Rect2(150, 0, 128, 0), "MAGIC")
	w.pop_open(0.08, false)
	var l := list(w, 1, 106)
	var entries: Array = []
	for s: Array in SPELLS:
		entries.append({"text": s[0], "right": str(s[1]), "disabled": party[k]["mp"] < s[1]})
	l.set_items(entries)
	_rest_on_floor(w)
	l.cancelled.connect(func() -> void:
		w.queue_free()
		from.active = true)
	l.chosen.connect(func(i: int) -> void:
		var s: Array = SPELLS[i]
		l.active = false
		var pool: Array = party.duplicate() if s[2] < 0 else battle["enemies"].filter(
			func(f: Dictionary) -> bool: return f["hp"] > 0)
		_choose_target(pool, func(t: Variant) -> void:
			party[k]["mp"] -= s[1]
			_act(k, t, absi(s[2]) + randi_range(-10, 10), s[0]),
			func() -> void: l.active = true))


func _battle_items(k: int, from: MenuList) -> void:
	from.active = false
	var w := _battle_window(Rect2(122, 0, 160, 0), "ITEM")
	w.pop_open(0.08, false)
	var l := list(w, 1, 138)
	var usable := items.filter(func(it: Dictionary) -> bool: return it["heal"] != 0)
	var entries: Array = []
	for it: Dictionary in usable:
		entries.append({"text": it["name"], "icon": it["icon"], "right": str(it["count"])})
	l.set_items(entries)
	_rest_on_floor(w)
	l.cancelled.connect(func() -> void:
		w.queue_free()
		from.active = true)
	l.chosen.connect(func(i: int) -> void:
		var it: Dictionary = usable[i]
		l.active = false
		_choose_target(party.duplicate(), func(t: Variant) -> void:
			it["count"] -= 1
			if it["count"] <= 0:
				items.erase(it)
			_act(k, t, it["heal"], it["name"]),
			func() -> void: l.active = true))


## Points at one of `pool` (enemies or party members) with the theme's target mark.
func _choose_target(pool: Array, picked: Callable, cancelled: Callable) -> void:
	_targets = pool
	_target = 0
	_on_target = picked
	_off_target = cancelled
	_pointer.show()
	screen = "target"
	_place_pointer()


func _target_input(e: InputEvent, go: bool, back: bool) -> void:
	var step := 0
	if e.is_action_pressed(&"ui_left") or e.is_action_pressed(&"ui_up"):
		step = -1
	elif e.is_action_pressed(&"ui_right") or e.is_action_pressed(&"ui_down"):
		step = 1
	if step:
		_target = (_target + step + _targets.size()) % _targets.size()
		Kit.play(self, "cursor")
	elif go or back:
		_pointer.hide()
		_name_target("")
		screen = "battle"
		Kit.play(self, "confirm" if go else "cancel")
		if go:
			_on_target.call(_targets[_target])
		else:
			_off_target.call()


func _place_pointer() -> void:
	if _targets.is_empty() or _target >= _targets.size():
		return
	var t: Dictionary = _targets[_target]
	_name_target(t["name"])
	var bob := 1.0 if fmod(_clock, 0.5) < 0.25 else 0.0
	if t.has("node"):
		var n: Control = t["node"]
		_pointer.texture = get_theme_icon(&"target", &"Menu")
		_pointer.size = _pointer.texture.get_size()
		_pointer.position = (n.position + Vector2((n.size.x - _pointer.size.x) / 2.0, -_pointer.size.y - 2.0 - bob)).round()
	else:
		var row: Control = battle["hp"][party.find(t)][2]
		_pointer.texture = get_theme_icon(&"cursor", &"Menu")
		_pointer.size = _pointer.texture.get_size()
		_pointer.position = (row.global_position - stage.global_position
			+ Vector2(-_pointer.size.x + 1.0 - bob, (row.size.y - _pointer.size.y) / 2.0)).round()


## Party member k uses `what` on t: an enemy takes `power` as damage, a party member is healed by it
## as by an item (_heal).
func _act(k: int, t: Variant, power: int, what: String) -> void:
	var g := gen
	_close_menus()
	var say := _message("%s: %s" % [party[k]["name"], what])
	if t is Dictionary and (t as Dictionary).has("node"):
		var foe: Dictionary = t
		var n: Control = foe["node"]
		for i in 3:
			n.modulate = Color(2.2, 2.2, 2.2)
			await get_tree().create_timer(0.06).timeout
			if g != gen:
				return
			n.modulate = Color.WHITE
			await get_tree().create_timer(0.06).timeout
		foe["hp"] = maxi(0, foe["hp"] - power)
		_number(n.position + Vector2(n.size.x / 2.0, n.size.y * 0.4), power, false)
		if foe["hp"] <= 0:
			var tw := n.create_tween()
			tw.tween_method(func(a: float) -> void: n.modulate.a = snappedf(a, 0.25), 1.0, 0.0, 0.4)
	else:
		var who := party.find(t)
		_number(_row_point(battle["hp"][who][2], 64.0), _heal(who, power), true)
		_battle_numbers()
	await get_tree().create_timer(0.9).timeout
	if g != gen:
		return
	say.get_parent().queue_free()
	if battle["enemies"].all(func(f: Dictionary) -> bool: return f["hp"] <= 0):
		victory()
		return
	_end_turn(k)


func _end_turn(k: int) -> void:
	_close_menus()
	battle["turn"][k] = 0.0
	battle["bars"][k].value = 0.0
	battle["acting"] = false


func _close_menus() -> void:
	for w: RpgWindow in battle.get("windows", []):
		if is_instance_valid(w):
			w.queue_free()
	battle["windows"] = []
	_name_target("")


## Names what the target pointer is on, over the fight; "" takes the name down.
func _name_target(text: String) -> void:
	var shown: Variant = battle.get("named")
	if text == "":
		if is_instance_valid(shown):
			shown.get_parent().queue_free()
		battle.erase("named")
	elif is_instance_valid(shown):
		shown.text = text
	else:
		battle["named"] = _message(text)


func _message(text: String) -> Label:
	var w := win(Rect2(6, 6, CARDS_X - 12, 0))
	var l := Kit.label(w, text)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return l


func _enemy_turn(foe: Dictionary) -> void:
	var g := gen
	battle["acting"] = true
	var say := _message("%s: %s" % [foe["name"], foe["move"]])
	var n: Control = foe["node"]
	var home := n.position
	var tw := n.create_tween()
	tw.tween_property(n, "position", home + Vector2(0, 6), 0.1)
	tw.tween_property(n, "position", home, 0.1)
	await get_tree().create_timer(0.3).timeout
	if g != gen:
		return
	var who := randi() % party.size()
	var hurt := randi_range(18, 46)
	party[who]["hp"] = maxi(1, party[who]["hp"] - hurt)
	_number(_row_point(battle["hp"][who][2], 64.0), hurt, false)
	_battle_numbers()
	await get_tree().create_timer(0.8).timeout
	if g != gen:
		return
	say.get_parent().queue_free()
	battle["acting"] = false


func victory(counted := false) -> void:
	_close_menus()
	screen = "victory"
	var w := win(Rect2((CARDS_X - 240) / 2.0, 30, 240, 0))
	w.pop_open(0.1, false)
	var rows := vbox(w, 3)
	fixed(Kit.label(rows, "VICTORY", &"Big"), 216, HORIZONTAL_ALIGNMENT_CENTER)
	rows.add_child(HSeparator.new())
	var exp_row := hbox(rows, 8)
	fixed(Kit.label(exp_row, "EXP", &"Accent"), 60)
	var exp_label := fixed(Kit.label(exp_row, "0"), 60, HORIZONTAL_ALIGNMENT_RIGHT)
	var gold_row := hbox(rows, 8)
	fixed(Kit.label(gold_row, "GOLD", &"Accent"), 60)
	var gold_label := fixed(Kit.label(gold_row, "0"), 60, HORIZONTAL_ALIGNMENT_RIGHT)
	var found := hbox(rows, 4)
	fixed(Kit.label(found, "FOUND", &"Accent"), 60)
	Kit.picture(found, Kit.icon("gem"))
	Kit.label(found, "STAR SHARD")
	var level := Kit.label(rows, "MIRA is now LV 12!", &"Hot")
	level.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level.custom_minimum_size.x = 216
	gold += 85
	if counted:
		exp_label.text = "240"
		gold_label.text = "85"
		return
	level.modulate.a = 0.0
	var g := gen
	var tw := create_tween()
	tw.tween_method(func(v: float) -> void: exp_label.text = str(roundi(v)), 0.0, 240.0, 0.6)
	tw.tween_callback(func() -> void: Kit.play(self, "gold"))
	tw.tween_method(func(v: float) -> void: gold_label.text = str(roundi(v)), 0.0, 85.0, 0.4)
	tw.tween_interval(0.3)
	tw.tween_callback(func() -> void:
		if g == gen:
			level.modulate.a = 1.0
			party[1]["lv"] = 12
			Kit.play(self, "level_up"))


# ---- stills and the tour ----

func _pose_title() -> void:
	show_title()


func _pose_field() -> void:
	show_field(0).complete()


func _pose_menu() -> void:
	open_menu(0)


func _pose_items() -> void:
	open_items(2)


func _pose_equip() -> void:
	open_equip(0)
	await get_tree().process_frame
	var lists := stage.find_children("", "GridContainer", true, false)
	var slots: MenuList = lists.filter(func(n: Node) -> bool: return n is MenuList)[0]
	slots.press()
	var choices: MenuList = lists.filter(func(n: Node) -> bool: return n is MenuList)[1]
	choices.select(1)
	choices.moved.emit(1)


func _pose_status() -> void:
	open_status(1)


func _pose_config() -> void:
	open_config()


func _pose_save() -> void:
	open_save()


func _pose_battle() -> void:
	start_battle()
	battle["turn"] = [1.0, 0.55, 0.8]
	for k in 3:
		battle["bars"][k].value = battle["turn"][k]
	battle["enemies"][0]["hp"] = 90
	var l := _command(0)
	l.select(0)
	await get_tree().create_timer(0.2).timeout
	var golem: Control = battle["enemies"][2]["node"]
	_number(golem.position + Vector2(golem.size.x / 2.0, golem.size.y * 0.4), 128, false)


func _pose_victory() -> void:
	start_battle()
	for foe: Dictionary in battle["enemies"]:
		foe["hp"] = 0
		foe["node"].hide()
	victory(true)


## Walks through the screens on its own, as the store's moving picture.
func tour() -> void:
	var steps: Array = [
		[1.0, func() -> void: _press()],
		[3.6, func() -> void: _accept_box()],
		[2.8, func() -> void: open_menu()],
		[0.8, func() -> void: _move(1)],
		[0.5, func() -> void: _move(-1)],
		[0.6, func() -> void: _press()],
		[0.8, func() -> void: _move(2)],
		[0.6, func() -> void: _move(1)],
		[1.2, func() -> void: open_menu(1)],
		[0.8, func() -> void: _pose_equip()],
		[1.8, func() -> void: open_status(2)],
		[1.6, func() -> void:
			if _has_battle():
				start_battle()],
		[2.4, func() -> void: _press()],
		[0.8, func() -> void:
			if screen == "target":
				_target_input(InputEventAction.new(), true, false)],
		[2.4, func() -> void:
			if _has_battle():
				_pose_victory()],
		[2.5, func() -> void: show_title()]]
	show_title()
	for s: Array in steps:
		await get_tree().create_timer(s[0]).timeout
		s[1].call()


func _active_list() -> MenuList:
	var found: MenuList = null
	for n in stage.find_children("", "GridContainer", true, false):
		if n is MenuList and n.active and n.is_visible_in_tree():
			found = n
	return found


func _move(by: int) -> void:
	var l := _active_list()
	if l:
		l.select((l.index + by + l.items.size()) % l.items.size())
		l.moved.emit(l.index)


func _press() -> void:
	var l := _active_list()
	if l:
		l.press()
	elif screen == "battle" and battle.get("menu"):
		battle["menu"].press()


func _accept_box() -> void:
	for n in stage.get_children():
		if n is DialogueBox:
			n.complete()
			n.advance()
