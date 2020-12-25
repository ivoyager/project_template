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

extends PanelContainer


func _ready() -> void:
	Global.connect("gui_refresh_requested", self, "_delayed_resize_to_corner")
	Global.connect("setting_changed", self, "_settings_listener")
	# widget mods
	$HBox/VBox/HBox3/ViewButtons/Outward.hide()
	

func _delayed_resize_to_corner() -> void:
	yield(get_tree(), "idle_frame")
	set_anchors_and_margins_preset(PRESET_BOTTOM_LEFT, PRESET_MODE_MINSIZE)

func _settings_listener(setting: String, _value) -> void:
	match setting:
		"gui_size":
			_delayed_resize_to_corner()




