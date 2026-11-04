extends ScrollContainer
## PRESENTATION ONLY: this script never changes planes, fuel, timers, or scores.
## All permanent artwork, colors, and button states live in main.tscn and
## assets/dashboard_theme.tres. This small helper handles runtime-created rows.

@export var plane_icon: Texture2D
@export var landing_icon: Texture2D


func _ready() -> void:
	# Wait until Main has finished its @onready lookups at the ORIGINAL paths.
	# That lets main.gd remain completely unchanged.
	call_deferred("_prepare_flight_list")


func _prepare_flight_list() -> void:
	var flight_list: VBoxContainer = get_node("../PlanesList")
	# Main keeps a reference to this SAME VBoxContainer. Moving it into this
	# scene's scroll area only changes its display, not how Main updates it.
	flight_list.reparent(self)
	flight_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	flight_list.add_theme_constant_override("separation", 10)
	flight_list.child_entered_tree.connect(_on_row_added)
	for row in flight_list.get_children():
		_on_row_added(row)


func _on_row_added(row: Node) -> void:
	# Main builds a plain HBox with a Label and Button each time fuel updates.
	# Defer decoration until the new row is completely inside the scene tree.
	_style_row.call_deferred(row)


func _style_row(row: Node) -> void:
	# Old rows may already be waiting for deletion after another list refresh.
	if not is_instance_valid(row) or row.is_queued_for_deletion():
		return
	if not row is HBoxContainer or row.get_child_count() != 2:
		return
	var label := row.get_child(0) as Label
	var button := row.get_child(1) as Button
	if label == null or button == null:
		return

	# Override only presentation; leave Main's text, pressed connection, and
	# disabled state alone. Smaller text and a stretching label align LAND buttons.
	row.custom_minimum_size.y = 60
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	label.add_theme_font_size_override("font_size", 24)
	button.add_theme_font_size_override("font_size", 22)
	button.custom_minimum_size.x = 172
	button.icon = landing_icon
	button.expand_icon = true

	# Fuel already appears in Main's label. Read that displayed number ONLY to
	# tint the text: amber below 20%, coral below 10%. No fuel value is changed.
	var displayed_fuel := label.text.get_slice("Fuel: ", 1).get_slice("%", 0).to_int()
	if displayed_fuel < 20:
		label.add_theme_color_override("font_color", Color("ffd080"))
	if displayed_fuel < 10:
		label.add_theme_color_override("font_color", Color("ff8e9a"))

	# Add a decorative icon without replacing or reconnecting either control.
	var icon := TextureRect.new()
	icon.texture = plane_icon
	icon.custom_minimum_size = Vector2(32, 32)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	icon.modulate = Color("79baff")
	row.add_child(icon)
	row.move_child(icon, 0)
