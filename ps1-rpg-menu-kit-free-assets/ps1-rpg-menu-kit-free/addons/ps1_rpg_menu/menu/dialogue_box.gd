extends "res://addons/ps1_rpg_menu/menu/rpg_window.gd"
## A window that types a line out under the speaker's name tab, then bobs the next mark in its
## corner. ui_accept (or a click) finishes the line at once, or once finished, sends `advanced`.

signal finished
signal advanced

## Letters a second; 0 shows the whole line at once.
@export var speed := 40.0
## Lines of text the box holds, which sets its height.
@export var lines := 3
## Takes ui_accept and clicks itself; off when the game drives it through complete() and advance().
@export var takes_input := true

var text_label: Label
var next_mark := TextureRect.new()
var typing := false
var _shown := 0.0
var _clock := 0.0


func _build() -> void:
	text_label = Kit.label(self)
	text_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	text_label.visible_characters_behavior = TextServer.VC_CHARS_AFTER_SHAPING
	next_mark.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.add_child(next_mark)


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		next_mark.texture = get_theme_icon(&"next", &"Menu")
		# the window's own lookups: the label's may not have caught up with the theme yet
		var line := get_theme_font(&"font", &"Label").get_height(get_theme_font_size(&"font_size", &"Label")) \
			+ get_theme_constant(&"line_spacing", &"Label")
		text_label.custom_minimum_size.y = lines * line
		text_label.max_lines_visible = lines


## Types `line` out; `speaker` goes on the name tab ("" for none).
func say(line: String, speaker := "") -> void:
	title = speaker
	text_label.text = line
	text_label.max_lines_visible = lines
	_shown = 0.0
	typing = speed > 0.0
	text_label.visible_characters = 0 if typing else -1
	if not typing:
		finished.emit()


## Shows the rest of the line at once.
func complete() -> void:
	if typing:
		typing = false
		text_label.visible_characters = -1
		finished.emit()


## Finishes the line, or if it's finished, sends `advanced`.
func advance() -> void:
	if typing:
		complete()
	else:
		Kit.play(self, "cursor")
		advanced.emit()


func _process(delta: float) -> void:
	_clock += delta
	if typing:
		_shown += delta * speed
		text_label.visible_characters = int(_shown)
		if _shown >= text_label.get_total_character_count():
			complete()
	var tex := next_mark.texture
	next_mark.visible = not typing and text_label.text != "" and tex != null
	if next_mark.visible:
		var bob := 1.0 if fmod(_clock, 0.6) < 0.3 else 0.0
		next_mark.size = tex.get_size()
		next_mark.position = (fill.size - tex.get_size() - Vector2(3, 2.0 - bob)).round()


func _unhandled_input(e: InputEvent) -> void:
	if not takes_input or not is_visible_in_tree():
		return
	var click: bool = e is InputEventMouseButton and e.pressed and e.button_index == MOUSE_BUTTON_LEFT
	if e.is_action_pressed(&"ui_accept") or click:
		get_viewport().set_input_as_handled()
		advance()
