# pbd_splash_screen.gd
# This file is part of I, Voyager
# https://ivoyager.dev
# *****************************************************************************
# Copyright 2019-2026 Charlie Whitfield
# I, Voyager is a registered trademark of Charlie Whitfield in the US
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# *****************************************************************************
class_name PBDSplashScreen
extends ColorRect

## Example splash screen with Pale Blue Dot image and interactive text.


@onready var _menu: VBoxContainer = %MenuVBox
@onready var _start_button: Button = %StartButton
@onready var _project_label: Label = %ProjectLabel
@onready var _version_label: Label = %VersionLabel
@onready var _copyright_label: Label = %CopyrightLabel
@onready var _pbd_caption: Label = %PBDCaption


func _ready() -> void:
	IVGlobal.translations_imported.connect(_on_translations_imported)
	IVStateManager.state_changed.connect(_on_state_changed)
	_pbd_caption.mouse_entered.connect(_pbd_mouse_entered)
	_pbd_caption.mouse_exited.connect(_pbd_mouse_exited)
	_pbd_caption.gui_input.connect(_pbd_caption_input)
	_pbd_caption.add_theme_color_override("font_color", Color.LIGHT_SKY_BLUE)


func _on_translations_imported() -> void:
	_project_label.show()
	_version_label.show()
	_copyright_label.show()
	if IVSettingsManager.get_setting(&"pbd_splash_caption_open"):
		_pbd_caption.text = "TXT_PBD_LONG"
	else:
		_pbd_caption.text = "TXT_PBD_SHORT"


func _on_state_changed() -> void:
	visible = IVStateManager.show_splash_screen
	_menu.visible = IVStateManager.ok_to_start
	if IVStateManager.ok_to_start:
		_start_button.grab_focus()


func _pbd_mouse_entered() -> void:
	_pbd_caption.remove_theme_color_override("font_color")


func _pbd_mouse_exited() -> void:
	_pbd_caption.add_theme_color_override("font_color", Color.LIGHT_SKY_BLUE)


func _pbd_caption_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var is_open: bool = not IVSettingsManager.get_setting(&"pbd_splash_caption_open")
		IVSettingsManager.change_setting("pbd_splash_caption_open", is_open)
		_pbd_caption.text = "TXT_PBD_LONG" if is_open else "TXT_PBD_SHORT"
