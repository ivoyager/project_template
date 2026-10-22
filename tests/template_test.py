#!/usr/bin/env python3
"""Project Template tests through the ivoyager_assistant TCP server.

Runs the Assistant's generic I, Voyager test sequence (its SPECIFICATION.md
section 9), then the template's save/load tests:

  - round trip: a named save, a changed state, a load; the persisted state
    (time, speed, user pause, selection, camera, HUDs) and the procedural tree
    (bodies, small-body groups) come back as saved;
  - repeated loads: node and object counts hold from load to load, with no
    orphan nodes;
  - gates: a save or load asked for while another runs is refused;
  - quicksave and quickload by their hotkeys, and an autosave;
  - the Save As and Load dialogs stop the simulator while open.

Every save and load of the run goes to a new temporary directory, through
TestProbe.set_save_directory (tests/test_probe.gd), so a run touches none of
the user's saves and several runs can go at once. A game attached to without
--launch keeps that directory until it quits. Unfreed procedural objects
reported by the Save plugin fail the run, as leaks at quit do.

Usage:
    python tests/template_test.py --launch            # start Godot, test, quit
    python tests/template_test.py                     # game already running
    python tests/template_test.py --launch --headless # no rendering, no hover test
    python tests/template_test.py --launch --godot PATH
    python tests/template_test.py --load-cycles N     # repeated loads (default 3)
    python tests/template_test.py --skip-hover        # skip mouse-hover identification
    python tests/template_test.py --keep-saves        # leave the run's saves on disk
    python tests/template_test.py --port PORT         # default: 29071, or free with --launch
"""

import argparse
import math
import os
import shutil
import sys
import tempfile
import time

PROJECT_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.insert(0, os.path.join(PROJECT_DIR, "addons", "ivoyager_assistant", "tools"))

from assistant_test import (DEFAULT_PORT, AssistantClient, AssistantError,  # noqa: E402
                            GodotLauncher, TestRunner)
from godot_executable import find_godot_executable  # noqa: E402


ERR_NOT_AVAILABLE = 5

# What a load must restore, read in one batch: (method, object, member).
STATE_READS = [
    ("get", "Timekeeper", "time"),
    ("get", "SpeedManager", "speed_index"),
    ("get", "IVStateManager", "paused_by_user"),
    ("call", "SelectionManager", "get_name"),
    ("get", "IVCamera", "target"),
    ("get", "IVCamera", "flags"),
    ("get", "IVCamera", "view_position"),
    ("get", "IVCamera", "view_rotations"),
    ("get", "IVCamera", "fov"),
    ("get", "BodyHUDsState", "name_visible_flags"),
    ("get", "BodyHUDsState", "symbol_visible_flags"),
    ("get", "BodyHUDsState", "orbit_visible_flags"),
    ("get", "SBGHUDsState", "symbols_visibilities"),
    ("get", "SBGHUDsState", "orbits_visibilities"),
]

# Godot output that fails the run: leaks at quit, and the Save plugin's report
# of procedural objects a load did not free.
FAILURE_MARKERS = GodotLauncher.DEFAULT_LEAK_MARKERS + ("unfreed procedural objects",)


def values_match(a, b, rel_tol=1e-9, abs_tol=1e-9):
    """Whether two JSON values are equal, floats to a tolerance."""
    if isinstance(a, bool) or isinstance(b, bool):
        return a == b
    if isinstance(a, (int, float)) and isinstance(b, (int, float)):
        return math.isclose(a, b, rel_tol=rel_tol, abs_tol=abs_tol)
    if isinstance(a, list) and isinstance(b, list):
        return len(a) == len(b) and all(values_match(x, y, rel_tol, abs_tol)
                                        for x, y in zip(a, b))
    if isinstance(a, dict) and isinstance(b, dict):
        return a.keys() == b.keys() and all(values_match(a[k], b[k], rel_tol, abs_tol)
                                            for k in a)
    return a == b


class TemplateTestRunner(TestRunner):
    """The generic sequence, then the template's save/load tests, all saving to
    `save_directory`."""

    def __init__(self, client, save_directory, load_cycles=3, skip_hover=False):
        super().__init__(client, skip_save=False, skip_hover=skip_hover)
        self.save_directory = save_directory
        self.load_cycles = load_cycles
        self.file_extension = ""

    def run_all(self, print_summary=True):
        print("\n=== Project Template Tests ===\n")

        self.test_1_discover()
        self.test_2_start()
        self.test_3_verify_state()
        self.test_4_exercise_controls()
        self.test_widgets()
        self.test_hover()
        if self.redirect_saves():
            self.test_round_trip()
            self.test_repeated_loads()
            self.test_save_gates()
            self.test_5_save_load()
            self.test_hotkeys()
            self.test_autosave()
            self.test_dialogs()

        if print_summary:
            self.print_summary()
        return self.failed == 0

    # =========================================================================
    # Helpers
    # =========================================================================

    def call_ok(self, address, method, **args):
        """invoke() that answers False for an object a load has freed."""
        try:
            return self.client.invoke(address, method, **args)
        except AssistantError:
            return False

    def get_ok(self, address, member):
        """One property, or None for an object a load has freed."""
        try:
            return self.client.get(address, member)[member]
        except AssistantError:
            return None

    def save_path(self, name):
        return "%s/%s.%s" % (self.save_directory, name, self.file_extension)

    def save_files(self):
        """Every save file under the save directory, by path relative to it, with
        its modification time."""
        found = {}
        for root, _, files in os.walk(self.save_directory):
            for name in files:
                if name.endswith("." + self.file_extension):
                    path = os.path.join(root, name)
                    found[os.path.relpath(path, self.save_directory)] = os.stat(path).st_mtime_ns
        return found

    def written_files(self, before):
        """Save files new or rewritten since `before`, a save_files() result. A save
        named by the game date rewrites the last one while the simulator is paused."""
        return {path for path, mtime in self.save_files().items() if before.get(path) != mtime}

    def wait_saved(self, description):
        return self.poll(lambda: self.get_ok("IVSave", "is_saving") is False,
                         "%s: save finished" % description, timeout=60, interval=0.2)

    def wait_loaded(self, description):
        """Polls until a load has finished and the simulator is ready again."""
        def is_loaded():
            return (self.get_ok("IVSave", "is_loading") is False
                    and self.get_ok("IVStateManager", "started") is True
                    and self.client.result("get_project_info").get("ready"))
        loaded = self.poll(is_loaded, "%s: load finished, simulator ready" % description,
                           timeout=120, interval=0.2)
        if loaded:
            self.refresh()
        return loaded

    def snapshot(self):
        """The state a load must restore, keyed "Object.member", with the
        procedural tree's bodies and small-body groups."""
        requests = []
        for method, address, member in STATE_READS:
            if method == "get":
                requests.append(("get", {"object": address, "properties": member}))
            else:
                requests.append(("call", {"object": address, "method": member}))
        state = {}
        for (method, address, member), response in zip(STATE_READS,
                                                        self.client.batch(requests)):
            value = AssistantClient.check(response)
            state["%s.%s" % (address, member)] = value[member] if method == "get" else value
        self.refresh()
        for class_name in ("IVBody", "IVSmallBodiesGroup"):
            state[class_name + " instances"] = sorted(
                instance["name"] for instance in self.instances(class_name))
        return state

    def assert_state(self, state, expected, description):
        mismatched = [key for key in expected if not values_match(state.get(key), expected[key])]
        for key in mismatched:
            print("    %s: %s (expected %s)" % (key, state.get(key), expected[key]))
        self.assert_true(not mismatched, "%s: %d of %d state values restored"
                         % (description, len(expected) - len(mismatched), len(expected)))

    def set_state(self, body, speed_index, show_orbits, symbols_group, show_symbols):
        """Selects and frames `body`, sets speed and HUDs; leaves the user pause on."""
        self.client.batch([
            ("call", {"object": "IVStateManager", "method": "set_user_paused",
                      "args": {"pause": True}}),
            ("call", {"object": "SelectionManager", "method": "select_by_name",
                      "args": {"name": body}}),
            ("call", {"object": "CameraHandler", "method": "move_to_by_name",
                      "args": {"selection_name": body, "is_instant_move": True}}),
            ("call", {"object": "SpeedManager", "method": "change_speed",
                      "args": {"new_speed_index": speed_index, "allow_ease_curve": False}}),
            ("call", {"object": "BodyHUDsState", "method": "set_all_orbits_visibility",
                      "args": {"is_show": show_orbits}}),
            ("call", {"object": "BodyHUDsState", "method": "set_all_names_visibility",
                      "args": {"is_show": not show_orbits}}),
            ("call", {"object": "SBGHUDsState", "method": "change_symbols_visibility",
                      "args": {"group": symbols_group, "is_show": show_symbols}}),
        ])
        time.sleep(0.5) # the camera settles at its target

    def advance_time(self):
        """Runs the simulator briefly at high speed, then pauses it again."""
        self.client.invoke("SpeedManager", "change_speed", new_speed_index=6,
                           allow_ease_curve=False)
        self.client.invoke("IVStateManager", "set_user_paused", pause=False)
        time.sleep(1.0)
        self.client.invoke("IVStateManager", "set_user_paused", pause=True)

    def load(self, path, description):
        self.client.invoke("IVSave", "load_file", path=path)
        return self.wait_loaded(description)

    # =========================================================================
    # Template tests
    # =========================================================================

    def redirect_saves(self):
        print("[Save directory]")
        if not self.has_member("TestProbe", "set_save_directory"):
            self.skip("TestProbe.set_save_directory not declared; save/load tests skipped"
                      " rather than run in the user's saves directory")
            return False
        self.client.invoke("TestProbe", "set_save_directory", dir_path=self.save_directory)
        save = self.client.get("IVSave", "directory", "file_extension")
        self.file_extension = save["file_extension"]
        self.assert_true(os.path.normcase(os.path.normpath(save["directory"]))
                         == os.path.normcase(os.path.normpath(self.save_directory)),
                         "IVSave.directory is the run's %s" % self.save_directory)
        return True

    def test_round_trip(self):
        print("[Save/load round trip]")
        groups = [instance["name"] for instance in self.instances("IVSmallBodiesGroup")]
        alias = self.client.get({"class": "IVSmallBodiesGroup", "name": groups[0]},
                                "sbg_alias")["sbg_alias"] if groups else ""

        self.set_state("PLANET_MARS", 4, True, alias, True)
        self.saved_state = self.snapshot()
        self.round_trip_path = self.save_path("RoundTrip")
        self.client.invoke("IVSave", "save_file", save_type="NAMED_SAVE",
                           path=self.round_trip_path)
        if not self.wait_saved("named save"):
            return
        self.assert_true(os.path.isfile(self.round_trip_path),
                         "named save wrote %s" % self.round_trip_path)
        self.assert_true(self.client.invoke("IVSave", "has_file", path=self.save_directory),
                         "IVSave.has_file finds it")

        self.advance_time()
        self.set_state("PLANET_JUPITER", 2, False, alias, False)
        changed = self.snapshot()
        for key in ("Timekeeper.time", "SpeedManager.speed_index", "SelectionManager.get_name",
                    "IVCamera.target", "BodyHUDsState.orbit_visible_flags"):
            self.assert_true(not values_match(changed[key], self.saved_state[key]),
                             "changed before load: %s" % key)

        if self.load(self.round_trip_path, "named load"):
            self.assert_state(self.snapshot(), self.saved_state, "named load")

    def test_repeated_loads(self):
        print("[Repeated loads]")
        if not self.has_member("TestProbe", "get_counts"):
            self.skip("TestProbe.get_counts not declared")
            return
        # Counted after a load, not after the first build, which differs.
        baseline = self.client.invoke("TestProbe", "get_counts")
        print("  After first load: %s" % baseline)
        counts = baseline
        for cycle in range(1, self.load_cycles + 1):
            if not self.load(self.round_trip_path, "load %d" % cycle):
                return
            counts = self.client.invoke("TestProbe", "get_counts")
            print("  After load %d: %s" % (cycle + 1, counts))
        for key in ("tree_nodes", "nodes", "objects", "resources"):
            self.assert_eq(counts[key], baseline[key],
                           "%s after %d more loads" % (key, self.load_cycles))
        self.assert_eq(counts["orphan_nodes"], 0, "orphan_nodes")
        if counts["orphan_nodes"]:
            self.client.invoke("TestProbe", "print_orphan_nodes")
        self.assert_state(self.snapshot(), self.saved_state,
                          "load %d" % (self.load_cycles + 1))

    def test_save_gates(self):
        print("[Save/load gates]")
        save = ("call", {"object": "IVSave", "method": "save_file",
                         "args": {"save_type": "NAMED_SAVE", "path": self.save_path("Gate")}})
        quicksave = ("call", {"object": "IVSave", "method": "quicksave"})
        load = ("call", {"object": "IVSave", "method": "load_file",
                         "args": {"path": self.round_trip_path}})

        responses = self.client.batch([save, quicksave, load])
        self.assert_true("result" in responses[0], "save_file starts")
        for name, response in (("quicksave", responses[1]), ("load_file", responses[2])):
            self.assert_eq(response.get("error", {}).get("code"), ERR_NOT_AVAILABLE,
                           "%s refused while saving: error code" % name)
        if not self.wait_saved("gated save"):
            return

        responses = self.client.batch([load, quicksave])
        self.assert_true("result" in responses[0], "load_file starts")
        self.assert_eq(responses[1].get("error", {}).get("code"), ERR_NOT_AVAILABLE,
                       "quicksave refused while loading: error code")
        self.wait_loaded("gated load")

    def test_hotkeys(self):
        print("[Quicksave and quickload hotkeys]")
        before = self.save_files()
        self.client.result("press_action", {"action": "quicksave"})
        written = self.poll(lambda: self.get_ok("IVSave", "is_saving") is False
                            and self.written_files(before),
                            "quicksave hotkey writes a file", timeout=60, interval=0.2)
        if not written:
            return
        self.assert_true(True, "quicksave hotkey wrote %s" % ", ".join(sorted(written)))
        saved_selection = self.client.invoke("SelectionManager", "get_name")

        self.client.invoke("SelectionManager", "select_by_name", name="PLANET_VENUS")
        self.client.result("press_action", {"action": "quickload"})
        restored = self.poll(lambda: self.call_ok("SelectionManager", "get_name")
                             == saved_selection,
                             "quickload hotkey restores selection %s" % saved_selection,
                             timeout=120, interval=0.2)
        if restored and self.wait_loaded("quickload hotkey"):
            self.assert_true(True, "quickload hotkey restored selection %s" % saved_selection)

    def test_autosave(self):
        print("[Autosave]")
        before = self.save_files()
        self.client.invoke("IVSave", "autosave")
        if not self.wait_saved("autosave"):
            return
        written = self.written_files(before)
        self.assert_eq(len(written), 1, "autosave files written")
        for path in written:
            self.assert_true(os.path.dirname(path) != "",
                             "autosave %s is in a subdirectory" % path)

    def test_dialogs(self):
        print("[Save and load dialogs]")
        self.client.invoke("IVStateManager", "set_user_paused", pause=False)
        if not self.poll(lambda: self.get_ok("IVStateManager", "running"),
                         "simulator running", timeout=10, interval=0.2):
            return
        for action in ("save_as", "load_file"):
            self.client.result("press_action", {"action": action})
            if not self.poll(lambda: self.get_ok("IVStateManager", "running") is False,
                             "%s dialog stops the simulator" % action, timeout=10,
                             interval=0.2):
                return
            self.assert_true(True, "%s dialog stops the simulator" % action)
            self.client.result("press_action", {"action": "ui_cancel"})
            if not self.poll(lambda: self.get_ok("IVStateManager", "running"),
                             "%s dialog closed, simulator running" % action, timeout=10,
                             interval=0.2):
                return
            self.assert_true(True, "%s dialog closed, simulator running" % action)


# =============================================================================
# Main
# =============================================================================

def main():
    parser = argparse.ArgumentParser(description="Project Template tests")
    parser.add_argument("--host", default="127.0.0.1", help="Server host")
    parser.add_argument("--port", type=int, default=None,
                        help="Server port (default: %d, or a free port with --launch)"
                             % DEFAULT_PORT)
    parser.add_argument("--launch", action="store_true", help="Launch Godot before testing")
    parser.add_argument("--headless", action="store_true",
                        help="With --launch: pass --headless to Godot (no rendering;"
                             " skips the mouse-hover test)")
    parser.add_argument("--godot", default=None,
                        help="Path to Godot console executable (default: the newest build"
                             " of the project's major beside the project)")
    parser.add_argument("--project", default=PROJECT_DIR, help="Path to project directory")
    parser.add_argument("--load-cycles", type=int, default=3,
                        help="Loads after the first in the repeated-loads test")
    parser.add_argument("--skip-hover", action="store_true",
                        help="Skip mouse-hover identification test")
    parser.add_argument("--keep-saves", action="store_true",
                        help="Leave the run's save directory on disk")
    args = parser.parse_args()

    launcher = None
    if args.launch:
        godot = args.godot or find_godot_executable(args.project, on_message=print)
        if not godot:
            print("No Godot console executable of the project's major; use --godot PATH")
            sys.exit(2)
        # No window flags: the GUI is tested at the project's own window size.
        extra = ["--headless"] if args.headless else []
        launcher = GodotLauncher(godot, args.project, leak_markers=FAILURE_MARKERS,
                                 extra_args=extra, port=args.port or 0)
        print("Launching Godot: %s %s --path %s (port %d)"
              % (godot, " ".join(extra), args.project, launcher.port))
        launcher.start()
    port = launcher.port if launcher else args.port or DEFAULT_PORT

    save_directory = tempfile.mkdtemp(prefix="ivoyager_template_test_").replace("\\", "/")
    client = AssistantClient(host=args.host, port=port)
    try:
        print("Connecting to %s:%d..." % (args.host, port))
        client.connect()
        if launcher:
            launcher.check_instance(client)
        print("Connected! Saving to %s\n" % save_directory)

        runner = TemplateTestRunner(client, save_directory, load_cycles=args.load_cycles,
                                    skip_hover=args.skip_hover or args.headless)
        success = runner.run_all()

        print("\n[Quit]")
        print("  Sending quit with force...")
        client.call("quit", {"force": True})
    except Exception as e:
        print("\nERROR: %s" % e)
        success = False
    finally:
        client.close()
        if launcher:
            launcher.shutdown_and_report()
            if launcher.leaks:
                success = False
        if args.keep_saves:
            print("Saves kept in %s" % save_directory)
        else:
            shutil.rmtree(save_directory, ignore_errors=True)

    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
