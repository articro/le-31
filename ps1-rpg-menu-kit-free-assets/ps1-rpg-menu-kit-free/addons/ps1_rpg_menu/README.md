# PS1 RPG Menu Kit

The menus of a PS1-era RPG for Godot 4.3+: windows shaded from four corner colours, menu lists
with a bobbing cursor, gauges, damage numbers and a dialogue box, in four themes, with item icons
and menu sounds. Every image is also a plain PNG, with the theme parts' 9-slice margins in
`themes/slices.json` for any other engine.

**The full pack:** **[PS1 RPG Menu Kit](https://heyheythere.itch.io/ps1-rpg-menu-kit)** adds the fight: the command
window, turn gauges, target pointers, damage numbers and the victory count. It also has
equipment with each stat's rise or fall, four themes (ember, grove, dune and night), 20 item
icons and 12 menu sounds. Install it over this one.

**Try it first:** click *Run asset pack* above and play the demo in your browser.

**Unity too:** a second download holds the Unity 6.3 package: the window, menu list, gauges and
dialogue box as UGUI components, the night theme as prefabs, the icons as sprites, the sounds as
AudioClips and the font as TextMesh Pro fonts, with the demo scene.

## Use it in Godot

1. Copy `addons/ps1_rpg_menu/` into your project.
2. *Rendering > Textures > Default Texture Filter*: **Nearest**, or the pixels blur.
3. Draw the UI at a whole-number scale. The art is 1x, made for a picture 240 pixels high: set
   *Display > Window > Stretch > Mode* to `canvas_items` with a 426x240 viewport, or set
   `get_tree().root.content_scale_factor` to 3, as `demo/demo.gd` does.
4. Set a theme from `themes/` (ember, grove, dune or night) on your UI's root Control, or as the
   project's *GUI > Theme > Custom*.

```gdscript
const RpgWindow := preload("res://addons/ps1_rpg_menu/menu/rpg_window.gd")
const MenuList := preload("res://addons/ps1_rpg_menu/menu/menu_list.gd")

func _ready() -> void:
	var window: PanelContainer = RpgWindow.new()
	window.position = Vector2(300, 8)
	window.title = "ARLO"
	add_child(window)
	var menu: GridContainer = MenuList.new()
	window.add_child(menu)
	menu.set_items(["ATTACK", "MAGIC", {"text": "ITEM", "icon": "potion", "right": "12"},
		{"text": "RUN", "disabled": true}])
	menu.chosen.connect(func(i: int) -> void: print("chose ", i))
	menu.cancelled.connect(window.pop_close)
```

## The pieces

Each is a script in `menu/` that builds itself; preload it and `new()` it, or set it on a node.

| Piece | Drive it with |
|---|---|
| `rpg_window.gd` (PanelContainer) | `title` (a name tab), `corners` (four colours over the theme's), `brightness`, `opacity`, `pop_open()`, `pop_close()` |
| `menu_list.gd` (GridContainer) | `set_items([...])` with strings or `{text, icon, right, disabled}`, `columns`, `item_width`; `select(i)`, `press()`, `active`, `idle_cursor`; signals `chosen(i)`, `moved(i)`, `cancelled` |
| `gauge.gd` | `kind` (hp, mp, turn, exp), `value`, `max_value`, `low`, `width`, `show_text`, `caption`, `fill_to(value, seconds)` |
| `damage_number.gd` | `DamageNumber.pop(parent, at, 128)`, `pop(parent, at, 40, true)` to heal, a negative amount for MISS |
| `dialogue_box.gd` (a window) | `say("line", "SPEAKER")`, `complete()`, `advance()`, `speed`, `lines`, `takes_input`; signals `finished`, `advanced` |
| `kit.gd` | `Kit.kit_theme(name)`, `Kit.icon(name)`, `Kit.mark("up")`, `Kit.play(node, "confirm")`, `Kit.volume_db` |

The menu list reads ui_up, ui_down, ui_left, ui_right, ui_accept and ui_cancel, so a pad works as
the keyboard does; a right click backs out. It plays the cursor, confirm, cancel and buzzer sounds
through `Kit.play`, one at a time as the console did; set `sounds` off on a list to keep it quiet.

## Themes

`themes/ember.tres`, `grove.tres`, `dune.tres` and `night.tres`. Each styles Label,
PanelContainer, ProgressBar, HSlider, CheckBox and HSeparator. The extras, by
`theme_type_variation`:

| Variation | On | Looks like |
|---|---|---|
| `RpgWindow` | PanelContainer | the window frame; its colours `top_left`, `top_right`, `bottom_left`, `bottom_right` are the fill's corners |
| `Tab` | PanelContainer | a name tab |
| `MenuItem` | Button | a menu line with the selection band when focused or hovered |
| `GaugeHp`, `GaugeMp`, `GaugeTurn`, `GaugeExp`, `GaugeLow` | ProgressBar | a gauge in its colour |
| `Accent`, `Dim`, `Hot`, `Good`, `Bad`, `Low` | Label | headings, faint text, the chosen line, a gain, a loss, a low number |
| `Big`, `Damage`, `Heal` | Label | Quill at 2x for titles; Anvil at 2x for damage numbers |

Scripts read the theme's colours and pointers under the `Menu` type: `get_theme_color("accent",
"Menu")` (ink, dim, accent, hot, good, bad, shadow) and `get_theme_icon("cursor", "Menu")`
(cursor, target, next).

## Art and sounds

- `icons/<name>.png`, 12x12: potion, ether, elixir, antidote, herb, plume, bread, tent, key, map,
  blade, staff, shield, helm, armour, ring, charm, gem, coin, book.
- `marks/up.png`, `down.png`, `same.png`: a stat's rise or fall when comparing equipment.
- `themes/<theme>/`: each theme's parts (frame, tab, band, trough, slider, checkbox, cursor,
  target, next); `gauges/fill_<kind>.png`.
- `sounds/<name>.wav`: cursor, confirm, cancel, buzzer, open, close, equip, save, gold, level_up,
  hit, heal.
- `font/`: Quill at 1x and 2x, Anvil at 2x, as BMFonts.
- `menu/window.gdshader`: the window fill, for a window of your own.
