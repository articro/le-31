extends VBoxContainer
## A gauge: its name and "142/ 160" over a bar. hp turns to the low colour at or under `low`; a full
## turn gauge flashes, ready to act. `fill_to` runs the bar down or up rather than jumping.

const Kit := preload("res://addons/ps1_rpg_menu/menu/kit.gd")

## hp, mp, turn or exp: the bar's colour and what it does.
@export var kind := "hp":
	set(v):
		kind = v
		_refresh()
@export var value := 100.0:
	set(v):
		value = clampf(v, 0.0, max_value)
		_refresh()
@export var max_value := 100.0:
	set(v):
		max_value = maxf(v, 0.001)
		value = minf(value, max_value)
		_refresh()
## hp at or under this share of max_value shows in the low colour.
@export_range(0.0, 1.0) var low := 0.25
## The bar's width in art pixels.
@export var width := 56:
	set(v):
		width = v
		_refresh()
## The name and numbers over the bar; off for a bare bar, as in a battle's turn column.
@export var show_text := true:
	set(v):
		show_text = v
		_refresh()
## The name shown, in place of kind's (HP, MP, TURN, EXP).
@export var caption := ""

var bar := ProgressBar.new()
var head := HBoxContainer.new()
var name_label: Label
var numbers: Label
var _shown := 0.0
var _tween: Tween
var _clock := 0.0


func _init() -> void:
	add_theme_constant_override(&"separation", 0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(head)
	name_label = Kit.label(head, "", &"Accent")
	var gap := Control.new()
	gap.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	gap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	head.add_child(gap)
	numbers = Kit.label(head)
	bar.show_percentage = false
	bar.mouse_filter = Control.MOUSE_FILTER_IGNORE
	bar.max_value = 1.0
	bar.step = 0.0
	add_child(bar)


func _ready() -> void:
	_shown = value
	_refresh()


## Runs the bar from where it shows to `to` over `seconds`; the numbers count along with it.
func fill_to(to: float, seconds := 0.5) -> Tween:
	value = to
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_method(func(v: float) -> void:
		_shown = v
		_draw_value(), _shown, value, seconds)
	return _tween


func _process(delta: float) -> void:
	_clock += delta
	if kind == "turn":
		bar.modulate = Color(1.6, 1.6, 1.6) if _shown >= max_value and fmod(_clock, 0.4) < 0.2 else Color.WHITE


func _refresh() -> void:
	if not is_instance_valid(bar):
		return
	if _tween == null or not _tween.is_running():
		_shown = value
	head.visible = show_text
	name_label.text = caption if caption != "" else kind.to_upper()
	bar.custom_minimum_size = Vector2(width, 6)
	_draw_value()


func _draw_value() -> void:
	var ratio := _shown / max_value
	bar.value = ratio
	var is_low := kind == "hp" and ratio <= low
	bar.theme_type_variation = &"GaugeLow" if is_low else StringName("Gauge" + kind.capitalize())
	numbers.text = "%d/%4d" % [roundi(_shown), roundi(max_value)] if kind in ["hp", "mp"] else "%d%%" % roundi(ratio * 100.0)
	numbers.theme_type_variation = &"Low" if is_low else &""
	numbers.visible = kind != "turn"
