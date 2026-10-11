extends RefCounted
## What the kit's pieces share: its art and sounds by name, labels, and the menu sounds' player.

const KIT := "res://addons/ps1_rpg_menu/"
const THEMES: Array[String] = ["ember", "grove", "dune", "night"]
const ICONS: Array[String] = ["potion", "ether", "elixir", "antidote", "herb", "plume", "bread", "tent", "key", "map", "blade", "staff", "shield", "helm", "armour", "ring", "charm", "gem", "coin", "book"]

## Every menu sound's volume; -80 or under is silent. Store captures and the tests stay silent anyway.
static var volume_db := 0.0
static var _player: AudioStreamPlayer


## The themes installed, in THEMES' order.
static func themes() -> Array[String]:
	var out: Array[String] = []
	for t in THEMES:
		if ResourceLoader.exists(KIT + "themes/%s.tres" % t):
			out.append(t)
	return out


## The named theme, or the first installed.
static func kit_theme(name: String) -> Theme:
	return load(KIT + "themes/%s.tres" % (name if name in themes() else themes()[0]))


## An item icon by name (12x12), or null when this copy of the kit lacks it.
static func icon(name: String) -> Texture2D:
	return _art("icons/%s.png" % name)


## up, down or same: a stat that rises, falls or holds when comparing equipment.
static func mark(name: String) -> Texture2D:
	return _art("marks/%s.png" % name)


static func _art(path: String) -> Texture2D:
	return load(KIT + path) if ResourceLoader.exists(KIT + path) else null


static func label(parent: Node, text := "", variation := &"") -> Label:
	var l := Label.new()
	l.text = text
	l.theme_type_variation = variation
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(l)
	return l


static func picture(parent: Node, texture: Texture2D) -> TextureRect:
	var t := TextureRect.new()
	t.texture = texture
	t.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
	t.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	t.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(t)
	return t


## Plays a menu sound by name (cursor, confirm, cancel, buzzer, open, close, equip, save, gold,
## level_up, hit, heal) on one shared player, so a new sound cuts off the last as on the console.
## A name this copy lacks plays nothing.
static func play(from: Node, name: String) -> void:
	var path := KIT + "sounds/%s.wav" % name
	if volume_db <= -80.0 or Engine.get_write_movie_path() != "" or not ResourceLoader.exists(path) \
			or not from.is_inside_tree():
		return
	if not is_instance_valid(_player):
		_player = AudioStreamPlayer.new()
		_player.autoplay = true  # plays as it enters the tree, at the end of this frame
		from.get_tree().root.add_child.call_deferred(_player)
	_player.stream = load(path)
	_player.volume_db = volume_db
	if _player.is_inside_tree():
		_player.play()
