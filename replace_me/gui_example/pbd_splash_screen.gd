# pbd_splash_screen.gd
# This file is part of I, Voyager
# https://ivoyager.dev
# *****************************************************************************
# Copyright 2017-2024 Charlie Whitfield
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
# Example splash screen with Pale Blue Dot image and interactive text. You
# probably want to replace this.

extends Control
class_name PBDSplashScreen
const SCENE := "res://replace_me/gui_example/pbd_splash_screen.tscn"

var _settings: Dictionary = IVGlobal.settings
var _settings_manager: IVSettingsManager = IVGlobal.program[&"SettingsManager"]

@onready var _pbd_caption: Label = %PBDCaption



func _ready() -> void:
	IVGlobal.simulator_started.connect(hide)
	IVGlobal.simulator_exited.connect(show)
	theme = IVGlobal.themes.splash_screen
	(%MenuVBox as VBoxContainer).theme = IVGlobal.themes.main_menu
	_pbd_caption.mouse_entered.connect(_pbd_mouse_entered)
	_pbd_caption.mouse_exited.connect(_pbd_mouse_exited)
	_pbd_caption.gui_input.connect(_pbd_caption_input)
	_pbd_caption.set("theme_override_colors/font_color", Color.LIGHT_BLUE)
	if _settings.pbd_splash_caption_open:
		_pbd_caption.text = "TXT_PBD_LONG"
	else:
		_pbd_caption.text = "TXT_PBD_SHORT"
	if IVCoreSettings.skip_splash_screen:
		hide()


func _pbd_mouse_entered() -> void:
	_pbd_caption.set("theme_override_colors/font_color", Color.WHITE)


func _pbd_mouse_exited() -> void:
	_pbd_caption.set("theme_override_colors/font_color", Color.LIGHT_SKY_BLUE)


func _pbd_caption_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var is_open: bool = !_settings.pbd_splash_caption_open
		_settings_manager.change_current("pbd_splash_caption_open", is_open)
		_pbd_caption.text = "TXT_PBD_LONG" if is_open else "TXT_PBD_SHORT"

