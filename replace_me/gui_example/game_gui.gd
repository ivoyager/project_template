# game_gui.gd
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
class_name GameGUI
extends Control
const SCENE := "res://replace_me/gui_example/game_gui.tscn"

# THIS IS AN EXAMPLE GUI SCENE! You can modify it or replace it.
#
# SCENE path must be defined above for our IVProjectBuilder to add it as a
# scene (otherwise, it will load as a bare Control instance w/ this script).


# '_project_init()' is a pseudo-virtual function called by IVProjectBuilder.
func _project_init() -> void:
	IVGlobal.connect("project_builder_finished", self, "_on_project_builder_finished")
	
	# We have some hide/show calls to hide away unfinished GUI
	IVGlobal.connect("simulator_started", self, "show")
	IVGlobal.connect("about_to_free_procedural_nodes", self, "hide") # on exit or game load
	hide()


func _ready():
	IVGlobal.connect("show_hide_gui_requested", self, "show_hide_gui")


func _on_project_builder_finished() -> void:
	# We hook up to a theme managed by ThemeManager. This has dynamic fonts that
	# change size when user changes GUI size in options and other changes that
	# improve GUI widget appearance.
	theme = IVGlobal.themes.main


func _unhandled_key_input(event: InputEventKey) -> void:
	if event.is_action_pressed("toggle_all_gui"):
		show_hide_gui()
		get_tree().set_input_as_handled()


func show_hide_gui(is_toggle := true, is_show := true) -> void:
	if !IVGlobal.state.is_system_built:
		return
	visible = !visible if is_toggle else is_show
