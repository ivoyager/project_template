# replace_me.gd
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
# This is an example "extension" file that changes some init values. See
# https://github.com/ivoyager/planetarium for a much more complex example.
#
# Requirements:
#    1. This file must have the same name as its directory + ".gd"
#    2. Must have the 3 constants below
#    3. Must have function "_extension_init"

const EXTENSION_NAME := "Replace Me!"
const EXTENSION_VERSION := "0.0.16"
const EXTENSION_BUILD := "" # hotfix or debug build
const EXTENSION_STATE := "dev" # 'dev', 'alpha', 'beta', 'rc', ''
const EXTENSION_YMD := 20230909 # int allows easy >= tests

const USE_THREADS := false # false can help threaded code debugging (e.g., I/O)

const VERBOSE_GLOBAL_SIGNALS := true
const VERBOSE_STATEMANAGER_SIGNALS := true

func _extension_init() -> void:
	
	print("%s %s%s-%s %s" % [EXTENSION_NAME, EXTENSION_VERSION, EXTENSION_BUILD, EXTENSION_STATE,
			str(EXTENSION_YMD)])
	
	# debug
	if OS.is_debug_build and VERBOSE_GLOBAL_SIGNALS:
		IVDebug.signal_verbosely_all(IVGlobal, "Global") # print all IVGlobal signal emits
	
	print("Use threads = ", USE_THREADS)
	IVGlobal.connect("project_objects_instantiated", Callable(self, "_on_project_objects_instantiated"))
	IVGlobal.connect("project_nodes_added", Callable(self, "_on_project_nodes_added"))
	IVGlobal.connect("system_tree_ready", Callable(self, "_on_system_tree_ready"))
	
	# change global init values
	IVGlobal.project_name = EXTENSION_NAME
	IVGlobal.project_version = EXTENSION_VERSION # helps load file debug
	IVGlobal.project_build = EXTENSION_BUILD
	IVGlobal.project_state = EXTENSION_STATE
	IVGlobal.project_ymd = EXTENSION_YMD # helps load file debug
	IVGlobal.skip_splash_screen = false
	IVGlobal.save_file_extension = "MyProjectSave"
	IVGlobal.save_file_extension_name = "My Project Save"
	IVGlobal.start_time = 21.12135 * IVUnits.YEAR # from J2000 epoch
	IVGlobal.use_threads = USE_THREADS
	
	# modify classes
	IVProjectBuilder.gui_nodes._SplashScreen_ = PBDSplashScreen
	IVProjectBuilder.gui_nodes._GameGUI_ = GameGUI


func _on_project_objects_instantiated() -> void:
	# Here you can access and change init values for program Nodes and
	# program RefCounteds before they are used (for Nodes, before they are
	# added to the tree).
	
	# debug
	if OS.is_debug_build and VERBOSE_STATEMANAGER_SIGNALS:
		var state_manager: IVStateManager = IVGlobal.program.StateManager
		IVDebug.signal_verbosely_all(state_manager, "StateManager") # print all StateManager signal emits
		
	var timekeeper: IVTimekeeper = IVGlobal.program.Timekeeper
	timekeeper.start_speed = 1
	var settings_manager: IVSettingsManager = IVGlobal.program.SettingsManager
	settings_manager.defaults.save_base_name = "Template"


func _on_project_nodes_added() -> void:
	IVProjectBuilder.move_top_gui_child_to_sibling("GameGUI", "SplashScreen", true)


func _on_system_tree_ready(_is_new_game: bool) -> void:
	# The solar system has been built or loaded, but we haven't started the
	# sim yet. See ivoyager/singletons/global.gd for more "state" signals.
	pass

