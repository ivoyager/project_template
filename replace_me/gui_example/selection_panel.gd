# selection_panel.gd
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
extends PanelContainer

# THIS IS AN EXAMPLE GUI SCENE! You can modify it or replace it.

var default_view_name := &"LABEL_VIEW1" # will increment if taken
var collection_name := &"SP"
var is_cached := false # if false, persisted via gamesave
var view_flags := IVView.ALL
var init_flags := IVView.ALL_CAMERA
var reserved_view_names: Array[StringName] = [&"BUTTON_HOME"]


func _ready() -> void:
	var mod: IVControlSized = $ControlMod
	mod.init_min_size(IVEnums.GUISize.GUI_SMALL, Vector2(435.0, 291.0))
	mod.init_min_size(IVEnums.GUISize.GUI_MEDIUM, Vector2(575.0, 354.0))
	mod.init_min_size(IVEnums.GUISize.GUI_LARGE, Vector2(712.0, 421.0))
	
	($"%ViewSaveFlow" as IVViewSaveFlow).init(($"%ViewSaveButton" as IVViewSaveButton),
			default_view_name, collection_name, is_cached, view_flags, init_flags,
			reserved_view_names)

