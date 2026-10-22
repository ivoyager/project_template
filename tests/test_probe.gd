# test_probe.gd
# This file is part of I, Voyager
# https://ivoyager.dev
# *****************************************************************************
# Copyright 2019-2026 Charlie Whitfield
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
class_name TestProbe
extends RefCounted

## What automated tests need from the app that its own classes don't declare.
##
## A client calls these members through the [code]ivoyager_assistant[/code]
## plugin's [code]call[/code], addressing this object by its role, "TestProbe"
## ([code]ivoyager_override2.cfg[/code] adds it to the program).
## [code]tests/template_test.py[/code] drives it.[br][br]
##
## A test instrument, not part of the app: a project made from the template can
## delete [code]tests/[/code] and [code]ivoyager_override2.cfg[/code].

const AUTOMATION_METHODS: Array[StringName] = [
	&"set_save_directory",
	&"get_counts",
	&"print_orphan_nodes",
]


## Whether an automation client may use [param member] now: the save directory
## can't change while a save or load is in progress.
func is_automation_available(member: StringName) -> bool:
	if member == &"set_save_directory":
		return !IVSave.is_saving and !IVSave.is_loading
	return true


## Points [IVSave] at [param dir_path], created if needed, for the rest of this
## run: quicksaves, autosaves, quickloads and the dialogs all use it. The user's
## saves directory, and the cache that remembers it across sessions, are left as
## they were, so a test run neither touches the user's saves nor collides with
## another run given its own directory.
func set_save_directory(dir_path: String) -> void:
	DirAccess.make_dir_recursive_absolute(dir_path)
	IVSave.directory_cache_path = dir_path.path_join("saves_dir_cache.ivbinary")
	IVSave.directory = dir_path


## Returns [code]objects[/code], [code]resources[/code], [code]nodes[/code]
## (all in memory), [code]orphan_nodes[/code] (nodes outside the tree) and
## [code]tree_nodes[/code] (nodes in the scene tree). The orphan count needs a
## debug build, as the Assistant server does.
func get_counts() -> Dictionary:
	return {
		objects = int(Performance.get_monitor(Performance.OBJECT_COUNT)),
		resources = int(Performance.get_monitor(Performance.OBJECT_RESOURCE_COUNT)),
		nodes = int(Performance.get_monitor(Performance.OBJECT_NODE_COUNT)),
		orphan_nodes = int(Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT)),
		tree_nodes = IVGlobal.get_tree().get_node_count(),
	}


## Prints the orphan nodes to Godot's output, to name what [method get_counts]
## counted.
func print_orphan_nodes() -> void:
	Node.print_orphan_nodes()
