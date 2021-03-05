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

# Nots:
# See ivoyager/static/UnitDefs.gd for conversion of base units to derived
# units. Values here don't matter *in theory*. They affect internal float
# representation of quantities, but not physics or display because everything
# is converted (e.g., if you double METER, then the gravitational constant will
# be appropriately increased by eight-fold). However, in practice, the Godot
# Engine will break with some values of METER. 

