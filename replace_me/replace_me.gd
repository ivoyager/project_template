# replace_me.gd
# This file is part of I, Voyager
# https://ivoyager.dev
# *****************************************************************************
# Copyright (c) 2017-2021 Charlie Whitfield
# "I, Voyager" is a registered trademark of Charlie Whitfield
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
# This is an example "extension" file that changes some init values and shows
# how to extend an existing class or add a new class. See ivoyager_planetarium
# repository planetarium/planetarium.gd for a much bigger example.
#
# Requirements:
#    1. This file must have the same name as its directory + ".gd"
#    2. Must have the 3 constants below
#    3. Must have function "extension_init"
#
# This file could extend a Node if you want, but it would have to add itself to
# the tree.

extends Reference

const EXTENSION_NAME := "Replace Me!"
const EXTENSION_VERSION := "0.0.8-dev"
const EXTENSION_VERSION_YMD := 20210123 # int allows easy >= tests


func extension_init() -> void:
	ProjectBuilder.connect("project_objects_instantiated", self, "_on_project_objects_instantiated")
	Global.connect("system_tree_ready", self, "_on_system_tree_ready")
	
	# Change global init values...
	Global.allow_dev_tools = true
	Global.project_name = "I Voyager Project Template"
	Global.save_file_extension = "MyProjectSave"
	Global.save_file_extension_name = "My Project Save"
	Global.allow_time_reversal = false
	
	# Add or replace ProjectBuilder classes...
#	ProjectBuilder.gui_controls._ProjectGUI_ = MyTopGUIControl
	
	# You can extend and replace an existing class. For example, if MyExtendedBody
	# extends Body, then this line would cause MyExtendedBody to be used instead
	# of Body in the solar system build...
	# ProjectBuilder.procedural_classes._Body_ = MyExtendedBody
	
	# "Program nodes" and "program reerences" are classes instantiated by
	# ProjectBuider. This line would add one of your own...
	# ProjectBuilder.program_nodes._MyProgramNode_ = MyProgramNode

func _on_project_objects_instantiated() -> void:
	# Here you can access and change init values for program nodes and
	# program references (for nodes, before they are added to the tree).
	var settings_manager: SettingsManager = Global.program.SettingsManager
	settings_manager.defaults.save_base_name = "Template"

func _on_system_tree_ready(_is_new_game: bool) -> void:
	# The solar system has been built or loaded, but we haven't started the
	# sim yet. (See Global for additional sim-state signals.)
	pass

