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
# SCENE path must be defined above for our IVProjectBuilder to add it.
#
# An IVSelectionManager instance manages our current selection. To find this
# instanace, various GUI widgets search up their ancestor tree for the first
# node that has a "selection_manager" member.

# This node has an object we want to persist through game save/loads. Presence
# of the first constant below tells SaveBuilder that this node has something to
# save. The second constant tells SaveBuilder what to persist.
const PERSIST_MODE := IVEnums.PERSIST_PROPERTIES_ONLY
const PERSIST_PROPERTIES := ["selection_manager"]

var selection_manager: IVSelectionManager

var _state: Dictionary = IVGlobal.state

onready var _SelectionManager_: Script = IVGlobal.script_classes._SelectionManager_



# All objects added by IVProjectBuilder need a "_project_init" function.
func _project_init() -> void:
	IVGlobal.connect("project_builder_finished", self, "_on_project_builder_finished")
	IVGlobal.connect("system_tree_built_or_loaded", self, "_on_system_tree_built_or_loaded")
	IVGlobal.connect("simulator_exited", self, "_on_simulator_exited")
	hide()


func _ready():
	IVGlobal.connect("show_hide_gui_requested", self, "show_hide_gui")
	add_child(IVFragmentLabel.new()) # Uses IVFragmentIdentifier to label asteroids
	
	# Example code below assigns a transparent style to all panels
#	var style_box := StyleBoxFlat.new()
#	style_box.bg_color = Color(1.0, 1.0, 1.0, 0.0)
#	for child in get_children():
#		var panel_container := child as PanelContainer
#		if !panel_container:
#			continue
#		panel_container.set("custom_styles/panel", style_box)


func _on_project_builder_finished() -> void:
	# We hook up to a theme managed by ThemeManager so that fonts can resize if
	# user changes GUI size in options
	theme = IVGlobal.themes.main


func _on_system_tree_built_or_loaded(is_new_game: bool) -> void:
	if is_new_game:
		selection_manager = _SelectionManager_.new()
		add_child(selection_manager)
	show()


func _on_simulator_exited() -> void:
	hide()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_all_gui"):
		show_hide_gui()
	else:
		return # input NOT handled!
	get_tree().set_input_as_handled()


func show_hide_gui(is_toggle := true, is_show := true) -> void:
	if !_state.is_system_built:
		return
	visible = !visible if is_toggle else is_show
