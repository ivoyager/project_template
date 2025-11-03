# pbd_splash_screen.gd
# This file is part of I, Voyager
# https://ivoyager.dev
# *****************************************************************************
# Copyright 2017-2025 Charlie Whitfield
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

var _settings: Dictionary = IVGlobal.settings

@onready var _loading_label: Label = %LoadingLabel
@onready var _menu: VBoxContainer = %MenuVBox
@onready var _pbd_caption: Label = %PBDCaption


func _ready() -> void:
	IVGlobal.core_inited.connect(_configure_for_core_init)
	IVStateManager.state_changed.connect(_on_state_changed)
	IVGlobal.simulator_started.connect(hide)
	IVGlobal.simulator_exited.connect(show)
	_pbd_caption.mouse_entered.connect(_pbd_mouse_entered)
	_pbd_caption.mouse_exited.connect(_pbd_mouse_exited)
	_pbd_caption.gui_input.connect(_pbd_caption_input)
	_pbd_caption.set("theme_override_colors/font_color", Color.LIGHT_BLUE)
	_menu.hide()


func _configure_for_core_init() -> void:
	if _settings[&"pbd_splash_caption_open"]:
		_pbd_caption.text = "TXT_PBD_LONG"
	else:
		_pbd_caption.text = "TXT_PBD_SHORT"


func _on_state_changed() -> void:
	_loading_label.visible = not IVStateManager.is_assets_loaded
	if !_menu.visible and IVStateManager.is_ok_to_start:
		_show_menu_and_grab_focus()


func _show_menu_and_grab_focus() -> void:
	_menu.show()
	(%StartButton as Button).grab_focus()


func _pbd_mouse_entered() -> void:
	_pbd_caption.set("theme_override_colors/font_color", Color.WHITE)


func _pbd_mouse_exited() -> void:
	_pbd_caption.set("theme_override_colors/font_color", Color.LIGHT_SKY_BLUE)


func _pbd_caption_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var is_open: bool = !_settings.pbd_splash_caption_open
		IVSettingsManager.change_current("pbd_splash_caption_open", is_open)
		_pbd_caption.text = "TXT_PBD_LONG" if is_open else "TXT_PBD_SHORT"
