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
		Simple but configurable process status indicator node for <a href="https://godotengine.org/">Godot</a>
		</sub>
		</sub>
		</sub>
		<br/>
		<br/>
		<br/>
	</h1>
	<br/>
	<br/>
	<!-- <img src="./readme_images/demo.png" height="140">
	<img src="./readme_images/stress_test.png" height="140">
	<img src="./readme_images/editor_view.png" height="140"> -->
	<br/>
	<br/>
</div>

Adds new Range control Spinner, an all-purpose process indicator.
Use to provide feedback on ongoing processes - threads, network requests, timers, etc.

## Features

* 5 statuses
	* `SPINNING` for indeterminate progress, such as a network request
	* `PROGRESSING` for determinate progress, such as a timer or download with known message body size
	* `SUCCESS` for a proces that has completed successfully
	* `WARNING` for a proces that has completed successfully with warnings
	* `ERROR` for a proces that has errored out
* Customizable icons, defaults taken from Godot's own icons
* Option to use no icon and fills with status color instead
* Configurable spinner/border width and speed
* Configurable colors and option to use editor theme

## Installation

Install via the AssetLib tab within Godot by searching for Spinner

## Usage

Add the Spinner node to your scene. All options update a live preview in the editor.
All options are documented in the Inspector panel. If anything isn't clear enough there,
open an issue.

### The Progressing Status

Spinner's value will be overridden by all statuses except `PROGRESSING`.
To set the progressing value, it's recommended to use `set_progressing()` instead.
This will set the status to `PROGRESSING` if it isn't already as well as set the value.

### Borderless Icons

If you set `icon_borderless`, you probably also want to set `icon_scale` to `1`.