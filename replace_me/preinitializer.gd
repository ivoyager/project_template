# preinitializer.gd
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
extends RefCounted

# This file is specified for instantiation in res://ivoyager_override.cfg.
# We can use this file to modify base IVCoreSettings, IVCoreInitializer, and
# instantiated program objects. (As an alternative, all IVCoreSettings and
# IVCoreInitializer changes could be done in res://ivoyager_override.cfg.)

const PROJECT_NAME := "Project Template (Replace Me!)"

const USE_THREADS := true # false can help threaded code debugging (e.g., I/O)

const VERBOSE_GLOBAL_SIGNALS := false
const VERBOSE_STATEMANAGER_SIGNALS := false

func _init() -> void:
	
	var version: String = ProjectSettings.get_setting("application/config/version")
	print("%s %s" % [PROJECT_NAME, version])
	
	# debug
	if OS.is_debug_build and VERBOSE_GLOBAL_SIGNALS:
		IVDebug.signal_verbosely_all(IVGlobal, "Global") # print all IVGlobal signal emits
	
	print("Use threads = ", USE_THREADS)
	IVGlobal.project_objects_instantiated.connect(_on_project_objects_instantiated)
	IVGlobal.project_nodes_added.connect(_on_project_nodes_added)
	IVGlobal.system_tree_ready.connect(_on_system_tree_ready)
	
	# change global init values
	IVCoreSettings.project_name = PROJECT_NAME
	IVCoreSettings.project_version = version # helps load file debug
	IVCoreSettings.use_threads = USE_THREADS
	IVCoreSettings.skip_splash_screen = false
	IVCoreSettings.save_file_extension = "MyProjectSave"
	IVCoreSettings.save_file_extension_name = "My Project Save"
	IVCoreSettings.start_time = 25.0 * IVUnits.YEAR # from J2000 epoch
	
	# modify classes
	IVCoreInitializer.gui_nodes[&"GameGUI"] = GameGUI
	IVCoreInitializer.gui_nodes[&"SplashScreen"] = PBDSplashScreen
	IVCoreInitializer.gui_nodes[&"AdminPopups"] = AdminPopups


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
	pass


func _on_system_tree_ready(_is_new_game: bool) -> void:
	# The solar system has been built or loaded, but we haven't started the
	# sim yet. See ivoyager/singletons/global.gd for more "state" signals.
	pass

