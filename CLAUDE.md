# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is the **I, Voyager Project Template** — a solar system simulator/viewer built on the [I, Voyager](https://ivoyager.dev) framework for **Godot Engine 4.6+**. It serves as a starting point for building games or educational apps set in a realistic solar system.

## Running the Project

Open `project.godot` in the Godot 4.6 editor. The editor plugin will prompt to download non-Git-tracked assets (`ivoyager_assets`). There is no external build system — everything runs through the Godot editor.

**Export:** Windows Desktop preset configured in `export_presets.cfg`, outputs to `export/`.

## Architecture

### Plugin System (addons/)

All core functionality lives in five Git submodules under `addons/`. The template directory contains only project-specific customization.

| Plugin | Purpose |
|---|---|
| `ivoyager_core` | Main simulator: 3D world, orbital mechanics, bodies, camera, 47 UI widgets |
| `ivoyager_tables` | TSV data table importer with unit conversion and type processing |
| `ivoyager_units` | SI unit system and conversion (overridden locally in `template/units.gd`) |
| `ivoyager_save` | Save/load serialization with quicksave support |
| `ivoyager_assistant` | AI assistant for solar system navigation (in development) |

Non-Git-tracked: `ivoyager_assets` — 3D models, textures, starmaps, fonts (auto-downloaded by editor plugin).

### Initialization Flow

1. Godot loads 11 autoload singletons defined in `project.godot` (IVUnits, IVGlobal, IVCoreInitializer, etc.)
2. `ivoyager_override.cfg` redirects IVUnits to `template/units.gd` and registers `template/preinitializer.gd`
3. The preinitializer configures IVCoreSettings, IVSave, IVSettingsManager, and simulation speed before the scene tree builds
4. `template/universe.tscn` is the root scene (Universe node extending Node3D) containing the world environment, UI panels, and camera

### Template Directory (template/)

- `preinitializer.gd` — Project configuration: threading, start time, simulation speeds, save settings. Connects to `core_init_program_objects_instantiated` to modify program objects before tree insertion.
- `universe.gd` / `universe.tscn` — Root scene with UI layout (NavigationPanel, SelectionPanel, PBDSplashScreen, menus/dialogs)
- `units.gd` — Overrides plugin's IVUnits singleton. Sets `METER = 1e-3` (critical for lighting/shadow behavior across platforms).
- `gui/` — Splash screen and panel scenes assembled from ivoyager_core's widget library

### Key Singletons

Access at runtime: `IVGlobal`, `IVCoreSettings`, `IVCoreInitializer`, `IVStateManager`, `IVUnits`, `IVTableData`, `IVSave`, `IVAstronomy`, `IVSettingsManager`

Program objects (non-singleton) accessed via `IVGlobal.program[&"ClassName"]` (e.g., `IVSpeedManager`).

## GDScript Conventions

- **Type hints required** — `untyped_declaration` warning is enabled (level 1)
- **Unsafe access warnings enabled** — property, method, cast
- **Addon warnings suppressed** — directory rule sets `res://addons` to level 1
- **StringName references** use `&"name"` prefix
- **PERSIST_MODE constant** on nodes indicates save/load behavior (from IVSave plugin)
- **Apache 2.0 license headers** on all source files

## GDScript Warning Preferences

All GDScript code should compile with **zero warnings**. Apply these strategies:

- **UNSAFE_CALL_ARGUMENT / UNSAFE_METHOD_ACCESS / UNSAFE_PROPERTY_ACCESS** — Fix by editing code. For built-in types, assign the Variant to a properly typed intermediate variable before passing it to a typed function parameter or constructor (e.g., `int()` requires `int`/`float`/`bool`, not `Variant`). Note: `as ClassName` generates UNSAFE_CAST — avoid it; direct assignment from `Object`-typed dictionary `.get()` to a typed member variable does not warn.
- **UNUSED_VARIABLE** — Prefix with `_` (e.g., `for _k in count:`).
- **INTEGER_DIVISION** — Suppress with `@warning_ignore("integer_division")` where integer division is intentional.
- **SHADOWED_VARIABLE** — Suppress with `@warning_ignore("shadowed_variable")` only in static functions where shadowing the instance variable is expected. In all other cases, rename the variable to avoid shadowing.

## Testing with the Assistant Plugin

When running the Planetarium for testing:

- **Godot executable:** Find the most recent `Godot_v*_console.exe` (or `godot*.console.exe`) in the parent directory of this project (i.e., `../`). Use the `_console` variant to see stdout. If no Godot executable is found there, ask the user for the path.
- **Launch command:** `"<godot_console_exe>" --path "<project_dir>" --windowed --position 0,0 --resolution 800x600`
- **TCP interface:** The `AssistantServer` listens on `127.0.0.1:29071` after the simulator starts. Use `addons/ivoyager_assistant/tools/assistant_client.sh` to send JSON-RPC commands.
- **Quit step:** Always call `quit` with `{"force":true}` as the **last test step**. This calls `IVStateManager.quit(true)` which performs a clean shutdown and reveals errors such as orphan nodes in the Godot console output.

## Git Workflow

- Submodules: clone with `git clone --recursive`. Update with `git submodule update --init --recursive`.
- Branches: `master` for releases, `develop` for active work
- Assets, `.godot/` directory, and translation files are gitignored
- PRs should target the `develop` branch

## Scale Warning

The `METER` constant in `template/units.gd` directly affects lighting and shadow rendering. Changing it requires testing across all target platforms (Windows, HTML5). See the extensive comments in that file for version-specific behavior.
