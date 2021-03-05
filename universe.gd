# universe.gd
# This file is part of I, Voyager
# https://ivoyager.dev
# *****************************************************************************
# Copyright (c) 2017-2021 Charlie Whitfield
# I, Voyager is a registered trademark of Charlie Whitfield
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
#
#       Developers! The place to start is:
#           ivoyager/singletons/project_builder.gd
#           ivoyager/singletons/global.gd
#
# *****************************************************************************

extends Spatial
class_name Universe

# SI base units - all sim units derived from these!
const METER := 1e-13 # engine length units per meter; see Notes below
const SECOND := 1.0
const KG := 1.0
const AMPERE := 1.0
const KELVIN := 1.0
const CANDELA := 1.0

# Nots on base SI units:
# See ivoyager/static/UnitDefs.gd for conversion of base units to derived
# units. Values here don't matter *in theory* because everything is converted.
# E.g., if you double METER, then the gravitational constant will be
# appropriately increased by eight-fold. They affect internal float values but
# not physics or display. 
#
# However, in practice, METER has to be set properly or the Godot Engine will
# break or fail to show things. This works in conjunction with dynamic changes
# in Camera.near and .far (see ivoyager/tree_nodes/vygr_camera.gd).
# Setting METER = 1.0 causes AABB and other errors. Values must be tested at
# extreems of distance, from close asteroid zoom to 200 AU solar system view.
# For Godot 3.2.2 and before, 1e-9 or smaller worked well. With Godot 3.2.3, we
# needed to decrease to 1e-13 to prevent distant objects disappearing. (The 
# cost of very small values is that, when zoomed close, more distant objects
# including orbit lines disappear.)
