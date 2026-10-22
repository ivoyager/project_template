# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **I, Voyager Project Template** — a starting point for a game or educational app set in a realistic solar system, built on the [I, Voyager](https://ivoyager.dev) plugins for Godot Engine. As shipped it is a solar-system viewer with a splash screen, a starter GUI, a main menu, options and hotkeys popups, and save/load dialogs.

The Godot major the project targets is `config/features` in `project.godot`. Open or run it only with a build of that major: another major rewrites `project.godot` and the import files.

Almost all code lives in the plugins under `addons/`. This repository holds only the project's own customization: `template/` and the root config files. A change that looks like it belongs in the template often belongs in a plugin, which is its own repository (see Git Workflow).

## Running the Project

Open `project.godot` in the Godot editor. Core's editor plugin offers to download the non-Git-tracked `addons/ivoyager_assets`; its version and source are in `addons/ivoyager_core/ivoyager_core.cfg`. There is no build system beyond the editor.

Export presets (`export_presets.cfg`) are gitignored and local to each machine. Exports go to `export/`, also ignored.

## Architecture

### Plugins (addons/)

Five plugins are Git submodules; `ivoyager_assets` is downloaded, not tracked.

| Plugin | Provides | Start reading at |
|---|---|---|
| `ivoyager_core` | The simulator: scene tree construction, bodies and orbits, camera, time, HUDs, settings, state, and the GUI widget library (`ui_widgets/`) | `IVUniverseTemplate` (`tree/universe_template.gd`); design docs `PHYSICAL_MODEL.md`, `PHOTOMETRIC_MODEL.md`, `VISUAL_MODEL.md` |
| `ivoyager_tables` | `IVTableData`: imports TSV data tables with unit conversion and type processing | `README.md`; `REDESIGN_v0.3.md` for the coming change to table data structures |
| `ivoyager_units` | `IVUnits` (internal units, SI-based), `IVQConvert` and `IVQFormat` (quantity conversion and display) | `README.md` |
| `ivoyager_save` | `IVSave` and `IVTreeSaver`: saving and loading of procedurally built trees, plus save/load buttons and dialogs in `gui/` | `README.md` |
| `ivoyager_assistant` | `IVAssistantServer`: a JSON-RPC server for automated testing today, accessibility later | `SPECIFICATION.md`, `CODING_PLAN.md` |

Each plugin's editor plugin registers its autoloads from its own `.cfg`, so the `[autoload]` list in `project.godot` is written by the plugins. Change an autoload through the override file below, not in `project.godot`.

### Configuration: `ivoyager_override.cfg`

`res://ivoyager_override.cfg` (and `ivoyager_override2.cfg`, if present) overrides any section of the plugins' `.cfg` files: autoloads, shader globals, `IVCoreSettings`, `IVCoreInitializer` program classes, Assistant settings. The syntax is documented in `addons/ivoyager_core/ivoyager_override_template.cfg`. This project's file does two things:

- replaces the `IVUnits` autoload with `template/units.gd`;
- registers `template/preinitializer.gd` as the Core preinitializer.

`ivoyager_override2.cfg` adds the test probe, `TestProbe` (`tests/test_probe.gd`), to the program. It is kept apart so a project made from the template can drop the probe by deleting that file and `tests/`.

### Initialization Flow

1. Godot loads the plugins' autoloads.
2. `IVCoreInitializer` instantiates the preinitializer. Its `_init()` sets `IVCoreSettings`, adds program classes to `IVCoreInitializer`, sets `IVSettingsManager` defaults and configures `IVSave`.
3. `IVCoreInitializer` instantiates the program objects. The preinitializer's handler for `IVStateManager.core_init_program_objects_instantiated` modifies them (here, `IVSpeedManager`'s speeds) before program nodes enter the tree.
4. `IVStateManager` runs startup through `core_initialized` to `simulator_started`, building the solar system on the way. With `IVCoreSettings.wait_for_start = true` (set here) the splash screen waits for the user's Start. The full signal sequence is in `IVStateManager`'s class doc.

The root scene, `template/universe.tscn` (class `Universe`), was made from Core's `tree/universe_template.tscn`. It holds the world environment, star field, `TopUI` with the GUI panels and `PBDSplashScreen`, the main menu, and the popups and dialogs. Core builds the bodies and the camera at runtime.

### Template Directory (template/)

- `preinitializer.gd` — the project's configuration: threads, start time, physical light, shader warm-up, settings defaults, Save plugin configuration, simulation speeds.
- `universe.gd` / `universe.tscn` — the root scene.
- `units.gd` — a copy of `addons/ivoyager_units/units.gd` that replaces it, kept so the project can experiment with scale (`METER`). Re-sync it whenever the plugin's file changes: a copy that lags silently drops what the plugin adds, such as its automation declarations. Its header records how `METER` affected lighting and shadows in past Godot versions.
- `gui/` — the splash screen (`PBDSplashScreen`) and the navigation and selection panels, assembled from Core's widgets.

`tests/` holds the Assistant-driven tests (see *Testing with the Assistant Plugin*), not app code.

### Runtime Access

Autoloads: `IVUnits`, `IVQConvert`, `IVQFormat`, `IVTableData`, `IVSave`, `IVAstronomy`, `IVGlobal`, `IVCoreSettings`, `IVCoreInitializer`, `IVSettingsManager`, `IVStateManager`, `IVAssistantServer`. Only the preinitializer should reference `IVCoreInitializer`.

Program objects (not singletons) are reached by role in `IVGlobal.program`, keyed by class name without the `IV` prefix: `IVGlobal.program[&"SpeedManager"]` is the `IVSpeedManager`. A project can substitute its own class under the same role.

### Persistence (Save plugin)

A class declares how it is saved in constants: `PERSIST_MODE` (`IVGlobal.PERSIST_PROPERTIES_ONLY` or `IVGlobal.PERSIST_PROCEDURAL`) and `PERSIST_PROPERTIES`, with `PERSIST_PROPERTIES2`, `PERSIST_PROPERTIES3`, … for each subclass level that persists its own members. The rules are in `addons/ivoyager_save/README.md`. Core reaches `IVSave` only through its program node `IVSaveManager`, which duck-types it so Core compiles without the Save plugin, and which supplies Core's save/load permits, checkpoints and input shortcuts.

### Automation (Assistant plugin)

A class declares what an automation client may read and call: `AUTOMATION_METHODS`, `AUTOMATION_PROPERTIES`, `AUTOMATION_KEY`, `is_automation_available()` and `get_automation_objects()`. The Assistant finds those declarations and serves them through `describe`, `get` and `call`, and lists and operates widgets by their accessibility names. A project's classes declare the same way. A declared write method must be the entry point the matching GUI widget calls (`SPECIFICATION.md` §10), and declared members are public API. The convention is `SPECIFICATION.md` §11.

## GDScript Conventions

- **Warnings** — `project.godot` sets `untyped_declaration`, `unsafe_property_access`, `unsafe_method_access`, `unsafe_cast` and `unsafe_call_argument` to warn, and turns off `return_value_discarded`, `static_called_on_instance` and `unused_signal`.
- **Addon warnings are on** — the directory rule `"res://addons": 1` means *Include*, so plugin scripts are analyzed at the same levels (Godot's default, `0`, would exclude them).
- **StringName literals** use the `&"name"` prefix; NodePath literals use `^"path"`.
- **Apache 2.0 license header** on every source file; copy it from any file in `template/`.

## GDScript Warning Preferences

All GDScript code should compile with **zero warnings**. Apply these strategies:

- **UNSAFE_CALL_ARGUMENT / UNSAFE_METHOD_ACCESS / UNSAFE_PROPERTY_ACCESS** — Fix by editing code. For built-in types, assign the Variant to a properly typed intermediate variable before passing it to a typed function parameter or constructor (e.g., `int()` requires `int`/`float`/`bool`, not `Variant`). Note: `as ClassName` generates UNSAFE_CAST — avoid it; direct assignment from `Object`-typed dictionary `.get()` to a typed member variable does not warn.
- **UNUSED_VARIABLE** — Prefix with `_` (e.g., `for _k in count:`).
- **INTEGER_DIVISION** — Suppress with `@warning_ignore("integer_division")` where integer division is intentional.
- **SHADOWED_VARIABLE** — Suppress with `@warning_ignore("shadowed_variable")` only in static functions where shadowing the instance variable is expected. In all other cases, rename the variable to avoid shadowing.

## Testing with the Assistant Plugin

- **Godot executable:** the newest `Godot_v*_console.exe` in the parent directory (`../`) of the major in `config/features`. `addons/ivoyager_assistant/tools/godot_executable.py` picks it; never run a bare `godot` or a build of another major. Use the `_console` variant to see stdout. If no build of that major is there, ask the user for the path.
- **Launch by hand:** `"<godot_console_exe>" --path "<project_dir>"`. Don't pass `--resolution`: test the GUI at the project's own window size, where its panels are laid out as a user sees them.
- **Server:** `IVAssistantServer` runs in debug builds only and listens on `127.0.0.1:29071` by default (`[assistant]` in `addons/ivoyager_assistant/ivoyager_assistant.cfg`). Arguments after `--` override it per process (`--assistant-port=N`, `--assistant-instance=ID`), so several runs can go at once (`SPECIFICATION.md` §7.3).
- **Test runner:** `python tests/template_test.py --launch` runs the Assistant's generic test sequence (`SPECIFICATION.md` §9), then the template's save/load tests; its module docstring lists them and its options. Every save of a run goes to a temporary directory through `TestProbe.set_save_directory`, never the user's saves directory, so runs can go in parallel. A script of your own launches with the Assistant's `GodotLauncher` and talks through its `AssistantClient` (`addons/ivoyager_assistant/tools/assistant_test.py`); don't reimplement either. `tools/assistant_client.sh` sends single commands by hand.
- **API:** use `describe`, `get` and `call` on declared members. The suites are gone; `SPECIFICATION.md` §4.7 maps each removed method to its replacement, including save/load on `IVSave`.
- **A probe a test needs is a class that declares members, not a suite.** `TestProbe` is a program object added in `ivoyager_override2.cfg` and called by its role; add a member there when a test needs something the app's own classes don't declare (`SPECIFICATION.md` §7.2).
- **Splash screen:** the template waits at its splash screen; a client starts the simulator with `call` on `IVStateManager.start`.
- **Quit step:** Always call `quit` with `{"force":true}` as the **last test step**. This calls `IVStateManager.quit(true)`, which shuts down cleanly and reports errors such as orphan nodes and leaked resources in the Godot console output; `GodotLauncher` scans that output for them.

## Git Workflow

- Submodules: clone with `git clone --recursive`. Update with `git submodule update --init --recursive`.
- Each plugin is its own repository with its own `develop`/`master` branches and CHANGELOG.md. Commit a plugin change in its submodule; the template then commits the new submodule pointer ("Update plugins").
- Branches: `master` for releases, `develop` for active work. PRs target `develop`.
- `.godot/`, `addons/ivoyager_assets/`, `export/`, `export_presets.cfg` and `*.translation` are gitignored.
- The template's CHANGELOG.md documents only this shell project; a plugin update is one line ("Updated plugin ivoyager_core to vN").
