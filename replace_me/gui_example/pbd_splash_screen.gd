# pbd_splash_screen.gd
# This file is part of I, Voyager
# https://ivoyager.dev
# *****************************************************************************
# Copyright 2017-2023 Charlie Whitfield
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
var _settings_manager: IVSettingsManager

func _project_init():
	IVGlobal.connect("simulator_started", self, "hide")
	IVGlobal.connect("simulator_exited", self, "show")
	_settings_manager = IVGlobal.program.SettingsManager

func _ready():
	theme = IVGlobal.themes.splash_screen
	$"%VersionLabel".set_version_label("", true, true, "\n", "",
			"\n\n(c) 2017-2023\nCharlie Whitfield")
	$"%MainMenu".is_splash_config = true
	$"%PBDCaption".connect("mouse_entered", self, "_pbd_mouse_entered")
	$"%PBDCaption".connect("mouse_exited", self, "_pbd_mouse_exited")
	$"%PBDCaption".connect("gui_input", self, "_pbd_caption_input")
	$"%PBDCaption".set("custom_colors/font_color", Color.lightblue)
	if _settings.pbd_splash_caption_open:
		$"%PBDCaption".text = "TXT_PBD_LONG"
	else:
		$"%PBDCaption".text = "TXT_PBD_SHORT"
	if IVGlobal.skip_splash_screen:
		hide()

func _pbd_mouse_entered() -> void:
	$"%PBDCaption".set("custom_colors/font_color", Color.white)
	
func _pbd_mouse_exited() -> void:
	$"%PBDCaption".set("custom_colors/font_color", Color.lightskyblue)

func _pbd_caption_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		var is_open: bool = !_settings.pbd_splash_caption_open
		_settings_manager.change_current("pbd_splash_caption_open", is_open)
		$"%PBDCaption".text = "TXT_PBD_LONG" if is_open else "TXT_PBD_SHORT"
