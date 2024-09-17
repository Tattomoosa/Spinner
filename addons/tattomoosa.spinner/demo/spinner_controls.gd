extends PanelContainer

@export var spinner : ProgressSpinner

@onready var menu_button : MenuButton = %StatusSelectorButton
@onready var progressing_slider : HSlider = %ProgressingValueSlider
@onready var diameter_slider : HSlider = %DiameterSlider
@onready var width_slider : HSlider = %WidthSlider
@onready var icon_scale_slider : HSlider = %IconScaleSlider

func _ready():
	menu_button.text = ProgressSpinner.Status.keys()[spinner.status]
	for status in ProgressSpinner.Status.keys():
		menu_button.get_popup().add_item(status)
	menu_button.get_popup().id_pressed.connect(
		func(value: int):
			spinner.status = value as ProgressSpinner.Status
			menu_button.text = ProgressSpinner.Status.keys()[value]
			if spinner.status == ProgressSpinner.Status.PROGRESSING:
				spinner.value = progressing_slider.value
	)
	progressing_slider.value_changed.connect(
		func(value: float):
			spinner.set_progressing(value)
			menu_button.text = ProgressSpinner.Status.keys()[ProgressSpinner.Status.PROGRESSING]
	)
	diameter_slider.value = spinner.diameter
	diameter_slider.value_changed.connect(
		func(value: float):
			spinner.diameter = value
	)
	width_slider.value = spinner.border_width
	width_slider.value_changed.connect(
		func(value: float):
			spinner.border_width = value
	)
	icon_scale_slider.value = spinner.icon_scale
	icon_scale_slider.value_changed.connect(
		func(value: float):
			spinner.icon_scale = value
	)
