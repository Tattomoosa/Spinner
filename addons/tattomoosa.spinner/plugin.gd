@tool
extends EditorPlugin

var spinner_inspector := SpinnerEditorInspector.new()

func _enter_tree():
	# Initialization of the plugin goes here.
	add_inspector_plugin(spinner_inspector)
	pass


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_inspector_plugin(spinner_inspector)





class SpinnerEditorInspector extends EditorInspectorPlugin:
	func _can_handle(object):
		return object is Spinner
	
	func _parse_property(object, type, name, hint_type, hint_string, usage_flags, wide):
		var spinner := object as Spinner
		if name == "nine_patch_stretch":
			return true
		if name == "color_use_editor_theme":
			var use_editor_theme_control := SpinnerColorsProperty.new()
			# add_property_editor(name, use_editor_theme_control)
			add_property_editor_for_multiple_properties(
				"Use Editor Theme",
				[
					"color_use_editor_theme",
					"color_ok",
					"color_warn",
					"color_error",
					"color_progress"
				],
				use_editor_theme_control
			)
			return true
		if spinner.color_use_editor_theme:
			if name.begins_with("color_"):
				return true
	
	func _parse_group(object, group):
		var spinner := object as Spinner

	class SpinnerColorsProperty extends EditorProperty:
		var property_control := CheckBox.new()

		func _init():
			add_child(property_control)
			add_focusable(property_control)
		
		func _ready():
			property_control.button_pressed = get_edited_object().color_use_editor_theme
			property_control.toggled.connect(toggled)
		
		func toggled(value: bool):
			var spinner : Spinner = get_edited_object()
			spinner.color_use_editor_theme = value
			if value:
				spinner.color_success = property_control.get_theme_color("success_color", "Editor")
				spinner.color_warning = property_control.get_theme_color("warning_color", "Editor")
				spinner.color_error = property_control.get_theme_color("error_color", "Editor")
				spinner.color_progress = property_control.get_theme_color("accent_color", "Editor")
			emit_changed(get_edited_property(), spinner)
			emit_changed("color_success", spinner)
			emit_changed("color_warning", spinner)
			emit_changed("color_error", spinner)
			emit_changed("color_progress", spinner)
			
