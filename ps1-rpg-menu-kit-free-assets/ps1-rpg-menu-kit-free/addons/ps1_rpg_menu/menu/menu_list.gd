extends GridContainer
## A list of choices in rows and `columns`, with the theme's cursor bobbing beside the one focused.
## The arrow keys (ui_up, ui_down, ui_left, ui_right) move round it and wrap, ui_accept or a click
## chooses, ui_cancel or a right click backs out; the mouse moves the cursor too.

signal chosen(index: int)
signal cancelled
signal moved(index: int)

const Kit := preload("res://addons/ps1_rpg_menu/menu/kit.gd")

## Plays the cursor, confirm, cancel and buzzer sounds (Kit.play).
@export var sounds := true
## Space between columns, in art pixels.
@export var column_gap := 12
## Each choice at least this wide, for a count on the right.
@export var item_width := 0
## Off: the list ignores input and its cursor holds still, dimmed, on the choice, as when a list
## further in has the turn. Set on to give it back.
@export var active := true:
	set(v):
		active = v
		if not is_inside_tree():
			return
		if active and index < items.size():
			_refocus.call_deferred()
		elif not active and get_viewport().gui_get_focus_owner() in items:
			get_viewport().gui_get_focus_owner().release_focus()
## Shows the dimmed cursor while not active; off hides it, for a list not yet entered.
@export var idle_cursor := true

var items: Array[Button] = []
var index := 0
var cursor := TextureRect.new()
var _clock := 0.0
var _quiet := false


func _init() -> void:
	cursor.top_level = true
	cursor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(cursor, false, Node.INTERNAL_MODE_FRONT)


func _ready() -> void:
	add_theme_constant_override(&"h_separation", column_gap)
	add_theme_constant_override(&"v_separation", 0)
	if active and index < items.size():
		_refocus.call_deferred()


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		cursor.texture = get_theme_icon(&"cursor", &"Menu")
		cursor.size = cursor.texture.get_size() if cursor.texture else Vector2.ZERO


## Replaces the choices. Each entry is a String, or a Dictionary of text, and optionally icon (a
## Texture2D or an icon's name), right (a count or cost drawn at the right) and disabled (the
## buzzer plays rather than choosing it).
func set_items(entries: Array) -> void:
	for b in items:
		remove_child(b)
		b.queue_free()
	items.clear()
	for e in entries:
		if e is Dictionary:
			add_item(e.get("text", ""), e.get("icon"), str(e.get("right", "")), e.get("disabled", false))
		else:
			add_item(str(e))
	index = clampi(index, 0, maxi(0, items.size() - 1))
	if active and is_inside_tree() and not items.is_empty():
		_refocus.call_deferred()


func add_item(text: String, icon: Variant = null, right := "", disabled := false) -> Button:
	var b := Button.new()
	b.name = "Item%d" % items.size()
	b.theme_type_variation = &"MenuItem"
	b.text = text
	b.icon = Kit.icon(icon) if icon is String else icon
	b.alignment = HORIZONTAL_ALIGNMENT_LEFT
	b.disabled = disabled
	b.custom_minimum_size.x = item_width
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var i := items.size()
	b.focus_entered.connect(_on_focus.bind(i))
	b.mouse_entered.connect(func() -> void:
		if active and not b.has_focus():
			b.grab_focus())
	b.pressed.connect(_choose.bind(i))
	b.gui_input.connect(_on_input.bind(i))
	if right != "":
		var count := Kit.label(b, right, &"Dim" if disabled else &"")
		count.set_anchors_and_offsets_preset(Control.PRESET_RIGHT_WIDE)
		count.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		count.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		count.offset_left = -40
		count.offset_right = -4
	items.append(b)
	add_child(b)
	_link()
	return b


## Moves the cursor to choice `i`, quietly.
func select(i: int) -> void:
	if items.is_empty():
		return
	index = clampi(i, 0, items.size() - 1)
	if active and is_inside_tree():
		_quiet = true
		items[index].grab_focus()
		_quiet = false


func _refocus() -> void:
	if active:
		select(index)


## Chooses the focused choice as ui_accept would: what a store still or a scripted tour calls.
func press() -> void:
	if index < items.size():
		_choose(index)


func _process(delta: float) -> void:
	_clock += delta
	var shown := index < items.size() and is_visible_in_tree() and (active or idle_cursor)
	cursor.visible = shown
	if not shown:
		return
	var b := items[index]
	var bob := 1.0 if active and fmod(_clock, 0.5) < 0.25 else 0.0
	cursor.global_position = (b.global_position + Vector2(-cursor.size.x + 3.0 - bob,
		roundf((b.size.y - cursor.size.y) / 2.0))).round()
	cursor.modulate.a = 1.0 if active else 0.5


func _on_focus(i: int) -> void:
	if i != index:
		index = i
		_clock = 0.0
		if sounds and not _quiet:
			Kit.play(self, "cursor")
		moved.emit(i)


func _choose(i: int) -> void:
	if not active:
		return
	index = i
	if sounds:
		Kit.play(self, "confirm")
	chosen.emit(i)


func _on_input(e: InputEvent, i: int) -> void:
	if not active:
		return
	var right_click: bool = e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_RIGHT
	if e.is_action_pressed(&"ui_cancel") or right_click:
		accept_event()
		if sounds:
			Kit.play(self, "cancel")
		cancelled.emit()
	elif items[i].disabled and (e.is_action_pressed(&"ui_accept")
			or (e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT)):
		accept_event()
		if sounds:
			Kit.play(self, "buzzer")


## Each choice's neighbours, so the cursor wraps round the rows and columns.
func _link() -> void:
	var n := items.size()
	var cols := maxi(1, columns)
	var rows := ceili(float(n) / cols)
	for i in n:
		var r := i / cols
		var c := i % cols
		var row_len := mini(cols, n - r * cols)
		var up := (r - 1) * cols + c if r > 0 else (rows - 1) * cols + c
		if up >= n:
			up -= cols
		var down := (r + 1) * cols + c
		if down >= n:
			down = c
		var left := r * cols + (c - 1 + row_len) % row_len
		var right := r * cols + (c + 1) % row_len
		var b := items[i]
		b.focus_neighbor_top = NodePath("../" + items[up].name)
		b.focus_neighbor_bottom = NodePath("../" + items[down].name)
		b.focus_neighbor_left = NodePath("../" + items[left].name)
		b.focus_neighbor_right = NodePath("../" + items[right].name)
		b.focus_next = NodePath("../" + items[(i + 1) % n].name)
		b.focus_previous = NodePath("../" + items[(i - 1 + n) % n].name)
