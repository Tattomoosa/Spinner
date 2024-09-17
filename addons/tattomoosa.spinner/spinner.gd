@tool
@icon("./icons/ProgressSpinner.svg")
class_name ProgressSpinner
extends TextureProgressBar

## Status displayed by the ProgressSpinner
enum Status {
	## Spinning, for indeterminate progress
	SPINNING,
	## Progressing, for determinate progress, set value elsewhere
	PROGRESSING,
	## Success, for operations that completed successfully
	SUCCESS,
	## Success, for operations that completed successfully but had warnings
	WARNING,
	## Success, for operations that errored
	ERROR,
}

## Current status of the spinner
@export var status : Status = Status.SPINNING:
	set(new_value):
		status = new_value
		match status:
			Status.PROGRESSING:
				value = min_value
				radial_initial_angle = 0.0
			Status.SPINNING:
				value = min_value + ((max_value - min_value) * spin_fill_percent)
			_:
				value = max_value
		_update_colors()
		queue_redraw()
## Spinner diameter
# TODO maybe this just extends range and has secret child TextureProgressBar so diameter can be set by parent containers and size etc
@export_range(8, 256, 1.0) var diameter : float = 24:
	set(value):
		diameter = value
		if is_node_ready():
			_resize()

@export_group("Display Options")
@export var use_icons := true:
	set(value):
		use_icons = value
		queue_redraw()
@export_range(0.0, 1.0, 0.01) var border_width : float = 0.05:
	set(value):
		border_width = value
		_resize()
@export_subgroup("Spin", "spin_")
@export_range(0.0, 1.0) var spin_fill_percent := 0.2
@export_range(0, 2) var spin_revolution_per_second := 0.5

@export_subgroup("Colors", "color_")
@export var color_use_editor_theme := false
@export var color_success := Color(0.45, 0.95, 0.5):
	set(value): color_success = value; _update_colors()
@export var color_progress := Color(0.44, 0.73, 0.98):
	set(value): color_progress = value; _update_colors()
@export var color_error := Color(1, 0.47, 0.42):
	set(value): color_error = value; _update_colors()
@export var color_warning := Color(1, 0.87, 0.4):
	set(value): color_warning = value; _update_colors()
@export var color_background := Color(0.0, 0.0, 0.0, 0.4):
	set(value): color_background = value; _update_colors()

@export_subgroup("Icons", "icon_")
@export var icon_success : Texture2D = preload("./icons/StatusSuccess.svg"):
	set(value):
		icon_success = value
		queue_redraw()
@export var icon_error : Texture2D = preload("./icons/StatusError.svg"):
	set(value):
		icon_error = value
		queue_redraw()
@export var icon_warning : Texture2D = preload("./icons/StatusWarning.svg"):
	set(value):
		icon_warning = value
		queue_redraw()
@export_range(0.0, 1.0, 0.01) var icon_scale := 0.6:
	set(value):
		icon_scale = value
		queue_redraw()

func set_progressing(to_value: float):
	if status != Status.PROGRESSING:
		status = Status.PROGRESSING
	value = to_value

func _ready():
	fill_mode = TextureProgressBar.FILL_CLOCKWISE
	texture_progress = _create_progress_texture()
	texture_under = _create_under_texture()
	_update_colors()
	_resize()

func _resize():
	texture_under = _create_under_texture()
	texture_progress = _create_progress_texture()

func _process(delta: float):
	if status != Status.SPINNING and status != Status.PROGRESSING:
		value = max_value
		return

	if status == Status.SPINNING:
		value = max_value * spin_fill_percent
		radial_initial_angle += 360 * delta * spin_revolution_per_second
	else:
		radial_initial_angle = 0

func _update_colors():
	tint_under = color_background
	if _should_use_editor_theme():
		match status:
			Status.PROGRESSING, Status.SPINNING:
				tint_progress = get_theme_color("accent_color", "Editor")
			Status.SUCCESS:
				tint_progress = get_theme_color("success_folor", "Editor")
			Status.WARNING:
				tint_progress = get_theme_color("warning_color", "Editor")
			Status.ERROR:
				tint_progress = get_theme_color("error_color", "Editor")
		return
	match status:
		Status.PROGRESSING, Status.SPINNING:
			tint_progress = color_progress
		Status.SUCCESS:
			tint_progress = color_success
		Status.WARNING:
			tint_progress = color_warning
		Status.ERROR:
			tint_progress = color_error

func _should_use_editor_theme():
	return Engine.is_editor_hint() and color_use_editor_theme and get_tree().edited_scene_root not in [self, owner]

func _get_color(theme_color_name: String, fallback: Color) -> Color:
	var c := get_theme_color("accent_color")
	if _should_use_editor_theme():
		return get_theme_color(theme_color_name, "Editor")
	else:
		return fallback
	
func _draw_icon_or_fill(icon: Texture2D, fill_color: Color):
	if use_icons and icon_success:
		var scale := Vector2(diameter / icon_success.get_size().x, diameter / icon_success.get_size().y)
		draw_set_transform(Vector2(diameter, diameter) / 2.0, 0, scale * icon_scale)
		var pos := -icon_success.get_size() / 2.0
		draw_texture(icon, pos, fill_color)
	else:
		draw_texture(texture_under, Vector2.ZERO, fill_color)

func _draw():
	match status:
		Status.SUCCESS:
			var color := _get_color("success_color", color_success)
			_draw_icon_or_fill(icon_success, color)
		Status.WARNING:
			var color := _get_color("warning_color", color_warning)
			_draw_icon_or_fill(icon_warning, color)
		Status.ERROR:
			var color := _get_color("error_color", color_error)
			_draw_icon_or_fill(icon_error, color)

func _create_under_texture() -> Texture2D:
	var anti_alias := _get_anti_alias()
	var t := GradientTexture2D.new()
	t.gradient = Gradient.new()
	t.gradient.offsets = [1.0 - anti_alias, 1.0]
	t.gradient.colors = [Color.WHITE, Color.TRANSPARENT]
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(0.5, 0)
	t.width = diameter
	t.height = diameter
	return t

func _get_anti_alias() -> float:
	var anti_alias : float = (1.0 / diameter) * 2.0
	return anti_alias

func _create_progress_texture() -> Texture2D:
	var anti_alias := _get_anti_alias()
	var w := border_width
	var t := GradientTexture2D.new()
	t.gradient = Gradient.new()
	t.gradient.offsets = [
		1.0 - (anti_alias * 3) - w,
		1.0 - (anti_alias * 2) - w,
		1.0 - anti_alias,
		1.0
	]
	t.gradient.colors = [
		Color.TRANSPARENT,
		Color.WHITE,
		Color.WHITE,
		Color.TRANSPARENT
	]
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(0.5, 0)
	t.width = diameter
	t.height = diameter
	return t

func _validate_property(property):
	if property.name in [
			"fill_mode",
			"texture_under",
			"texture_over",
			"texture_progress_offset",
			"texture_progress",
			"radial_initial_angle",
			"radial_fill_degrees",
			"radial_center_offset",
			"nine_patch_strech",
			"tint_under",
			"tint_over",
			"tint_progress",
			"background",
			"stretch_margin_bottom",
			"stretch_margin_left",
			"stretch_margin_right",
			"stretch_margin_top"
			]:
		property.usage = PROPERTY_USAGE_NONE