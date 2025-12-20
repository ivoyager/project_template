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

## Root scene node for the Template simulator.
##
## This root scene was duplicated and modified from
## [code]addons/ivoyager_core/tree/universe_template.tscn[/code] in the Core
## plugin. [IVUniverseTemplate] is the main entry point for I, Voyager docs, so
## start there![br][br]
##
## [b]Important Class File Docs[/b][br][br]
##
## * [IVUniverseTemplate] for scene tree construction.[br]
## * [IVCoreInitializer] & [IVCoreSettings] for plugin init & settings.[br]
## * [IVGlobal] & [IVStateManager] for runtime state management.[br]
## * [IVBody] for the physical 3D world. (Also has roadmap details.)[br]
## * [IVOrbit] for orbital mechanics. (Has more roadmap for spacecraft thrust).


## Don't free on load. This constant only matters if the
## [url=https://github.com/ivoyager/ivoyager_save]Save plugin[/url] is used.
## Nodes have persistence only if they and all ancestors have this constant set
## to PERSIST_PROPERTIES_ONLY or PERSIST_PROCEDURAL.
const PERSIST_MODE := IVGlobal.PERSIST_PROPERTIES_ONLY # Godot ISSUE 4.5.1: Class doc broken! 
