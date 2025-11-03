# universe.gd
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
class_name Universe
extends Node3D

## Root scene node for the simulator.
##
## This root scene was duplicated and modified from [IVUniverseTemplate] in the
## Core plugin (res://addons/ivoyager_core/tree_nodes/universe_template.tscn).[br][br]
##
## See [IVUniverseTemplate] for documentation on the scene tree.[br][br]
##
## Also see comments in res://addons/ivoyager_core/override_template.cfg.


const PERSIST_MODE := IVGlobal.PERSIST_PROPERTIES_ONLY ## Don't free on load.


func _ready() -> void:
	if IVCoreSettings.pause_only_stops_time:
		process_mode = PROCESS_MODE_ALWAYS
