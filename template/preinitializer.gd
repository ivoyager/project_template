# preinitializer.gd
# This file is part of I, Voyager
# https://ivoyager.dev
# *****************************************************************************
# Copyright 2017-2025 Charlie Whitfield
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

const USE_THREADS := true # false can help threaded code debugging

#const VERBOSE_GLOBAL_SIGNALS := false
#const VERBOSE_STATEMANAGER_SIGNALS := false

func _init() -> void:
	
	var version: String = ProjectSettings.get_setting("application/config/version")
	print("%s v%s" % [PROJECT_NAME, version])
	
	# debug
	#if OS.is_debug_build and VERBOSE_GLOBAL_SIGNALS:
		#IVDebug.signal_verbosely_all(IVGlobal, "Global") # print all IVGlobal signal emits
	
	print("Use threads = ", USE_THREADS)
	IVStateManager.core_init_program_objects_instantiated.connect(
			_on_core_init_program_objects_instantiated)
	
	# change global init values
	IVCoreSettings.use_threads = USE_THREADS
	IVCoreSettings.wait_for_start = true
	IVCoreSettings.start_time = 25.75 * IVUnits.YEAR # from J2000 epoch
	
	IVSettingsManager.set_default("pbd_splash_caption_open", false)
	IVSettingsManager.set_default(&"save_base_name", "Template")
	
	# Save plugin
	IVSave.file_extension = "MyProjectSave"
	IVSave.file_description = "My Project Save"
	IVSave.autosave_uses_suffix_generator = true
	IVSave.quicksave_uses_suffix_generator = true
	IVSave.configure_save_plugin()
	


func _on_core_init_program_objects_instantiated() -> void:
	# Here you can access and change init values for program Nodes and
	# program RefCounteds before they are used (for Nodes, before they are
	# added to the tree).
	
	# debug
	#if OS.is_debug_build and VERBOSE_STATEMANAGER_SIGNALS:
		#IVDebug.signal_verbosely_all(IVStateManager, "StateManager") # print all StateManager signal emits
		
	var timekeeper: IVTimekeeper = IVGlobal.program[&"Timekeeper"]
	timekeeper.start_speed = 1
