# select_panel.gd
# This file is part of I, Voyager (https://ivoyager.dev)
# *****************************************************************************
# Copyright (c) 2017-2020 Charlie Whitfield
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
# You can modify widgets or set widget init values in _ready() here.

extends PanelContainer

var content_sizes := [
	Vector2(421.0, 277.0), # GUI_SMALL
	Vector2(561.0, 340.0), # GUI_MEDIUM
	Vector2(698.0, 407.0), # GUI_LARGE
]
var v_spacer_sizes := [3.0, 4.0, 5.0]
var horizontal_separations := [6.0, 8.0, 10.0]

func _ready() -> void:
	Global.connect("gui_refresh_requested", self, "_resize_to_corner")
	Global.connect("setting_changed", self, "_settings_listener")
	# widget mods here
	$VBox/BottomHBox/ViewButtons/Outward.hide()

func _resize_to_corner() -> void:
	var gui_size: int = Global.settings.gui_size
	$VBox.rect_min_size = content_sizes[gui_size]
	$VBox/VSpacer.rect_min_size.y = v_spacer_sizes[gui_size]
	$VBox/MainHBox.set("custom_constants/separation", horizontal_separations[gui_size])
	yield(get_tree(), "idle_frame") # wait for content to resize
	set_anchors_and_margins_preset(PRESET_BOTTOM_LEFT, PRESET_MODE_MINSIZE)
	yield(get_tree(), "idle_frame")
	print("SelectPanel size: ", rect_size)

func _settings_listener(setting: String, _value) -> void:
	match setting:
		"gui_size":
			_resize_to_corner()