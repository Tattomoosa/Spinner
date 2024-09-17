<div align="center">
	<br/>
	<br/>
	<img src="addons/tattomoosa.spinner/icons/Spinner.svg" width="100"/>
	<br/>
	<h1>
		Spinner
		<br/>
		<sub>
		<sub>
		<sub>
		Simple but configurable process status indicator node, for <a href="https://godotengine.org/">Godot</a>
		</sub>
		</sub>
		</sub>
		<br/>
		<br/>
		<br/>
	</h1>
	<br/>
	<br/>
	<img src="./promo/spinner-splash.png" height="180">
	<img src="./promo/in-editor.png" height="180">
	<!-- <img src="./readme_images/editor_view.png" height="140"> -->
	<br/>
	<br/>
</div>

Adds new Range control Spinner, an all-purpose process indicator.
Use to provide feedback on ongoing processes - threads, network requests, timers, etc.

## Features

* 5 statuses
	* `EMPTY` for a process that hasn't started
	* `SPINNING` for indeterminate progress, such as a network request
	* `PROGRESSING` for determinate progress, such as a timer or download with known message body size
	* `SUCCESS` for a process that has completed successfully
	* `WARNING` for a process that has completed successfully with warnings
	* `ERROR` for a process that has errored out
* Can use custom icons, with defaults taken from Godot's own icons
* Option to use no icon and fills with status color instead
* Configurable spinner/border width and speed
* Configurable colors and option to use editor theme

## Installation

Install via the AssetLib tab within Godot by searching for Spinner

## Usage

Add the Spinner node to your scene. All options update a live preview in the editor.
All options are documented in the Inspector panel. If anything isn't clear enough there,
open an issue.

### Borderless Icons

If you set `icon_borderless`, you probably also want to set `icon_scale` to `1`.

### Example: Watching an HTTPRequest

A very basic implementation.

``` go
@onready var spinner : Spinner = $Spinner
@onready var http_request : HTTPRequest = $HTTPRequest

func _ready() -> void:
	var error := http_request.request("https://github.com/godotengine/godot/releases/download/4.3-stable/godot-4.3-stable.tar.xz")
	if error != OK:
		spinner.status = Spinner.Status.ERROR
	http_request.request_completed.connect(_on_request_completed)

func _process(_delta: float) -> void:
	if http_request.get_body_size() > 0 and http_request.get_http_client_status() != HTTPClient.STATUS_DISCONNECTED:
		spinner.max_value = http_request.get_body_size()
		spinner.set_progressing(http_request.get_downloaded_bytes())

func _on_request_completed(
	result: int,
	response_code: int,
	headers: PackedStringArray,
	body: PackedByteArray
) -> void:
	spinner.status = Spinner.Status.SUCCESS
```

## My Other Godot Plugins

* [VisionCone3D](https://github.com/Tattomoosa/VisionCone3D)