@tool
@icon("./icons/Spinner.svg")
class_name Spinner
extends Range
## Spinner which spins during loading and can also show operation results

## Status displayed by the Spinner
enum Status {
	## Only shows the background, useful if something hasn't started yet
	EMPTY,
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
		_update_status()

@export_group("Display Options")
## Whether or not to use icons during SUCCESS, WARNING, ERROR status

@export var use_icons := true:
	set(value):
		use_icons = value
		_update_status()
## Width of the spinning/static border
@export_range(0.0, 0.3, 0.001) var border_width : float = 0.1:
	set(value):
		border_width = value
		_progress_border.stroke_width = diameter * border_width

@export_subgroup("Spin", "spin_")
## Percent filled by the border when the spinner is spinning
@export_range(0.0, 1.0) var spin_fill_percent := 0.2
## Speed of the spinning border during Status.SPINNING
@export_range(0, 2) var spin_revolution_per_second := 0.5
## Sets whether to animate border spin on Status.SPINNING or not
@export var spin_preview_in_editor := true

@export_subgroup("Colors", "color_")
## Uses editor themes "color_success", "accent_color", "progress_color", "warning_color"
@export var color_use_editor_theme := false
## Color when status is Status.SUCCESS
@export var color_success := Color(0.45, 0.95, 0.5):
	set(value): color_success = value; _update_status()
## Color when status is Status.PROGRESSING or Status.SPINNING
@export var color_progress := Color(0.44, 0.73, 0.98):
	set(value): color_progress = value; _update_status()
## Color when status is Status.ERROR
@export var color_error := Color(1, 0.47, 0.42):
	set(value): color_error = value; _update_status()
## Color when status is Status.WARNING
@export var color_warning := Color(1, 0.87, 0.4):
	set(value): color_warning = value; _update_status()
## Background color
@export var color_background := Color(0.0, 0.0, 0.0, 0.4):
	set(value): color_background = value; _update_status()

@export_subgroup("Icons", "icon_")
## Whether or not to draw the spinning indicator in non-PROGRESSING/SPINNING statuses
##
## Best paired with a circular icon at icon_scale = 1.0, so icons fill the whole control
@export var icon_borderless := false:
	set(value):
		icon_borderless = value
		_update_status()
## Scale (relative to diameter) to render icon
@export_range(0.0, 1.0, 0.01) var icon_scale := 0.7:
	set(value):
		icon_scale = value
		_icon.icon_scale = value
		# _icon.radius = (diameter / 2) * value
		_update_status()
## Icon to display when status is Status.SUCCESS
@export var icon_success : Texture2D = preload("./icons/StatusSuccess.svg"):
	set(value):
		icon_success = value
		_update_status()
## Icon to display when status is Status.ERROR
@export var icon_error : Texture2D = preload("./icons/StatusError.svg"):
	set(value):
		icon_error = value
		_update_status()
## Icon to display when status is Status.WARNING
@export var icon_warning : Texture2D = preload("./icons/StatusWarning.svg"):
	set(value):
		icon_warning = value
		_update_status()

var diameter : float:
	get():
		return min(size.x, size.y)

var _radial_initial_angle : float = 0.0

var _background := _SpinnerSolidCircle.new()
var _icon := _SpinnerIcon.new()
var _progress_border := _SpinnerProgressBorder.new()

## Sets value and status to Status.PROGRESSING at the same time.
func set_progressing(to_value: float):
	if status != Status.PROGRESSING:
		status = Status.PROGRESSING
	value = to_value

func _ready():
	clip_contents = true
	var external_children := get_children()
	for child in get_children(true):
		if child in external_children:
			remove_child(child)
			child.queue_free()

	# TODO not sure how to handle container sizing logic
	if custom_minimum_size == Vector2.ZERO:
		custom_minimum_size = Vector2(16, 16)
	if size.x < custom_minimum_size.x:
		size.x = custom_minimum_size.x
	if size.y < custom_minimum_size.y:
		size.y = custom_minimum_size.y

	add_child(_background, false, INTERNAL_MODE_FRONT)
	add_child(_icon, false, INTERNAL_MODE_FRONT)
	add_child(_progress_border, false, INTERNAL_MODE_FRONT)
	_update_children_size()

	value_changed.connect(queue_redraw.unbind(1))
	# resized.connect(_update_children_size)
	item_rect_changed.connect(_update_children_size)
	_update_status()

func _update_status():
	_background.color = color_background
	match status:
		Status.SUCCESS:
			var color := _get_color("success_color", color_success)
			_icon.show()
			_icon.color = color
			_icon.icon = icon_success if use_icons else null
			if !icon_borderless:
				_progress_border.color = color
				_progress_border.show()
			else:
				_progress_border.hide()
		Status.ERROR:
			var color := _get_color("error_color", color_error)
			_icon.show()
			_icon.color = color_error
			_icon.icon = icon_error if use_icons else null
			_progress_border.color = color_error
			if !icon_borderless:
				_progress_border.color = color
				_progress_border.show()
			else:
				_progress_border.hide()
		Status.WARNING:
			_icon.show()
			var color := _get_color("warning_color", color_warning)
			_icon.color = color_warning
			_icon.icon = icon_warning if use_icons else null
			if !icon_borderless:
				_progress_border.color = color
				_progress_border.show()
			else:
				_progress_border.hide()
		Status.PROGRESSING:
			_progress_border.show()
			_radial_initial_angle = 0.0
			_icon.hide()
			_progress_border.color = _get_color("accent_color", color_progress)
		Status.SPINNING:
			_progress_border.show()
			_radial_initial_angle = 0.0
			_icon.hide()
			_progress_border.color = _get_color("accent_color", color_progress)
		Status.EMPTY:
			_icon.hide()
			_progress_border.hide()
	queue_redraw()

func _update_children_size():
	var radius := diameter / 2
	_background.radius = radius
	_icon.icon_scale = icon_scale
	_icon.radius = radius
	_progress_border.radius = radius
	_progress_border.stroke_width = border_width * radius

func _process(delta: float):
	if status == Status.SPINNING and (!Engine.is_editor_hint() or spin_preview_in_editor):
		_radial_initial_angle += 360 * delta * spin_revolution_per_second
		if _radial_initial_angle >= 360:
			_radial_initial_angle -= 360
	else:
		_radial_initial_angle = 0
	_update_progress_border()

func _update_progress_border():
	var v : float
	match status:
		Status.EMPTY:
			v = min_value
		Status.PROGRESSING:
			v = value
		Status.SPINNING:
			v = min_value + (max_value * spin_fill_percent)
		_:
			v = max_value
	_progress_border.start_angle = _radial_initial_angle
	_progress_border.end_angle = _radial_initial_angle  + lerp(0, 360, float(v - min_value) / float(max_value - min_value))

func _should_use_editor_theme():
	return Engine.is_editor_hint() and color_use_editor_theme and get_tree() and get_tree().edited_scene_root not in [self, owner]

func _get_color(theme_color_name: String, fallback: Color) -> Color:
	var c := get_theme_color(theme_color_name)
	if _should_use_editor_theme():
		return get_theme_color(theme_color_name, "Editor")
	else:
		return fallback
	
func _validate_property(property):
	if property.name in [
			"_radial_initial_angle",
			"page"
			]:
		property.usage = PROPERTY_USAGE_NONE

class _SpinnerElement extends Control:
	var color := Color.BLACK:
		set(value):
			color = value
			queue_redraw()
	var radius := 32.0:
		set(value):
			radius = value
			pivot_offset = Vector2.ZERO
			position = Vector2.ZERO
			size = Vector2(radius * 2, radius * 2)
			# pivot_offset = Vector2(radius, radius)
			queue_redraw()
	func _init():
		set_anchors_preset(PRESET_CENTER)

class _SpinnerSolidCircle extends _SpinnerElement:
	func _draw():
		if color == Color.TRANSPARENT:
			return
		draw_circle(Vector2(radius, radius), radius, color, true)

# Draws solid circle if no icon
class _SpinnerIcon extends _SpinnerSolidCircle:
	var icon : Texture2D
	var icon_scale : float

	func _draw():
		if color == Color.TRANSPARENT:
			return
		if !icon:
			super()
			return
		var diameter = radius * 2
		var scale := Vector2(diameter / icon.get_size().x, diameter / icon.get_size().y)
		draw_set_transform(Vector2(radius, radius), 0, scale * icon_scale)
		var pos := -icon.get_size() / 2.0
		draw_texture(icon, pos, color)
		draw_set_transform(Vector2.ZERO, 0, Vector2.ONE)

class _SpinnerProgressBorder extends _SpinnerElement:
	var stroke_width : float:
		set(value):
			stroke_width = value
			queue_redraw()
	var start_angle : float:
		set(value):
			start_angle = value
			queue_redraw()
	var end_angle : float:
		set(value):
			end_angle = value
			queue_redraw()

	func _draw():
		draw_arc(
			Vector2(radius, radius),
			radius - stroke_width,
			deg_to_rad(start_angle - 90),
			deg_to_rad(end_angle - 90),
			radius * 2,
			color,
			stroke_width,
			true
		)