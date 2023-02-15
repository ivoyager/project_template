# navigation_panel.gd
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
#
# THIS IS AN EXAMPLE GUI SCENE! You can modify it or replace it.
#


extends PanelContainer

var _settings: Dictionary = IVGlobal.settings


func _ready() -> void:
	IVGlobal.connect("update_gui_requested", self, "_resize")
	IVGlobal.connect("setting_changed", self, "_settings_listener")
	
	# widgets
	$"%AsteroidsHScroll".add_bodies_from_table("asteroids")
	$"%SpacecraftHScroll".add_bodies_from_table("spacecrafts")


func _resize() -> void:
	pass
#	never mind...


func _settings_listener(setting: String, _value) -> void:
	if setting == "gui_size":
		_resize()
