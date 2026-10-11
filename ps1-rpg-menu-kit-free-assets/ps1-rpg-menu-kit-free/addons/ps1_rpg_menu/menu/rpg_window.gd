extends PanelContainer
## A window: the theme's frame round a fill shaded from four corner colours (RpgWindow's
## top_left, top_right, bottom_left and bottom_right), in 15-bit colour. Lay out its contents as
## in any PanelContainer.

const Kit := preload("res://addons/ps1_rpg_menu/menu/kit.gd")

## The corner colours, top left, top right, bottom left, bottom right, in place of the theme's;
## empty keeps the theme's.
@export var corners: Array[Color] = []:
	set(v):
		corners = v
		_paint()
@export_range(0.0, 2.0) var brightness := 1.0:
	set(v):
		brightness = v
		_paint()
## Under 1, the game shows through the fill (not the frame).
@export_range(0.0, 1.0) var opacity := 1.0:
	set(v):
		opacity = v
		_paint()
## A name tab on the top edge, as over a speaker's line; "" for none.
@export var title := "":
	set(v):
		title = v
		_title()

var fill := ColorRect.new()
var tab: PanelContainer
var _tween: Tween


func _init() -> void:
	theme_type_variation = &"RpgWindow"
	fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fill.material = ShaderMaterial.new()
	fill.material.shader = preload("res://addons/ps1_rpg_menu/menu/window.gdshader")
	add_child(fill, false, Node.INTERNAL_MODE_FRONT)
	resized.connect(_place)
	sort_children.connect(_place)  # after the container has fitted every child, these two included
	_build()


## What a window made on this one adds to itself, as it's made.
func _build() -> void:
	pass


func _notification(what: int) -> void:
	if what == NOTIFICATION_THEME_CHANGED:
		_place()
		_title()


## The colours in use: `corners`, or the theme's.
func corner_colours() -> Array[Color]:
	if corners.size() == 4:
		return corners
	var out: Array[Color] = []
	for c in [&"top_left", &"top_right", &"bottom_left", &"bottom_right"]:
		out.append(get_theme_color(c))
	return out


## Opens from a line across its middle in four steps, with the open sound.
func pop_open(seconds := 0.1, sound := true) -> void:
	_grow(0.0, 1.0, seconds)
	show()
	if sound:
		Kit.play(self, "open")


## Closes to a line and hides, with the close sound.
func pop_close(seconds := 0.08, sound := true) -> void:
	_grow(1.0, 0.0, seconds).tween_callback(hide)
	if sound:
		Kit.play(self, "close")


func _grow(from: float, to: float, seconds: float) -> Tween:
	if _tween:
		_tween.kill()
	pivot_offset = size / 2.0
	_tween = create_tween()
	_tween.tween_method(func(t: float) -> void: scale.y = maxf(0.05, snappedf(t, 0.25)), from, to, seconds)
	return _tween


func _place() -> void:
	var inset := float(get_theme_constant(&"inset"))
	fill.position = Vector2(inset, inset)
	fill.size = (size - Vector2(inset, inset) * 2.0).max(Vector2.ZERO)
	pivot_offset = size / 2.0
	_paint()
	if tab:
		tab.size = tab.get_combined_minimum_size()
		tab.position = Vector2(6, -tab.size.y + 4) - fill.position


func _paint() -> void:
	if not is_instance_valid(fill):
		return
	var m := fill.material as ShaderMaterial
	var c := corner_colours()
	m.set_shader_parameter("top_left", c[0])
	m.set_shader_parameter("top_right", c[1])
	m.set_shader_parameter("bottom_left", c[2])
	m.set_shader_parameter("bottom_right", c[3])
	m.set_shader_parameter("pixels", fill.size)
	m.set_shader_parameter("brightness", brightness)
	m.set_shader_parameter("opacity", opacity)


func _title() -> void:
	if title == "":
		if tab:
			tab.hide()
		return
	if not tab:
		tab = PanelContainer.new()
		tab.theme_type_variation = &"Tab"
		tab.mouse_filter = Control.MOUSE_FILTER_IGNORE
		Kit.label(tab, "", &"Accent")
		fill.add_child(tab)  # the fill isn't a container, so the tab keeps its place
	tab.show()
	(tab.get_child(0) as Label).text = title
	_place.call_deferred()
