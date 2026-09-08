# Scraptures — Session Progress Log

This file is the short source of truth for continuing work between development sessions. Read it at the beginning of the next Scraptures session and update it at the end.

---

## Project Identity

- **Game:** Scraptures
- **Studio:** Wiremane
- **Engine:** Godot 4.x, latest stable
- **Language:** Typed GDScript
- **Tools:** Godot, Cursor, Git, GitHub
- **Demo deadline:** September 28, 2026
- **Repository:** `LionNaiman/Scraptures`
- **Default branch:** `main`

---

## Current Status

- **Date:** July 29, 2026
- **Session number:** 3
- **Roadmap status:** Week 1 complete; Week 2 is next.
- **Latest verified GitHub commit:** `6743dd0d4406dbe1df94cabb4ead84f4b417edaa`
- **Commit message:** `Add data-driven module pickups and module inventory`

The latest committed repository contains the completed Week 1 data-driven module pickup flow.

---

## Core Demo Loop

```text
Explore
→ collect modules
→ encounter a Scrapture
→ battle
→ capture
→ equip modules within Attachment Capacity
→ gain stats and moves
→ use the customized Scrapture in a final encounter
```

The current implementation proves the first part:

```text
Explore
→ collect a specific ModuleDefinition
→ store it in a runtime ModuleInventory
→ display the collected module in the HUD
```

---

## Completed Milestone

### Week 1 — Data-Driven Module Pickup System

The generic Scrap pickup prototype was converted into a reusable module pickup system.

The implemented flow is:

```text
Player enters ModulePickup
→ ModulePickup validates its assigned ModuleDefinition
→ ModulePickup emits collected(module)
→ Main receives the ModuleDefinition
→ ModuleInventory stores it
→ HUD lists the collected module
→ pickup removes itself
```

### Week 1 exit criteria

- [x] Walking over the Engine pickup adds Engine to the runtime inventory.
- [x] The collected pickup disappears.
- [x] The HUD proves that the correct module was collected.
- [x] Battery works through the same reusable pickup Scene.
- [x] Armor Plate works through the same reusable pickup Scene.
- [x] A clean GitHub checkpoint commit was created and pushed.

---

## Features Completed This Session

- [x] Created the global `ModuleDefinition` custom Resource class.
- [x] Created `engine.tres` with `display_name = "Engine"`.
- [x] Created `battery.tres` with `display_name = "Battery"`.
- [x] Created `armor_plate.tres` with `display_name = "Armor Plate"`.
- [x] Renamed the pickup script and global class to `ModulePickup`.
- [x] Added an exported `module_definition: ModuleDefinition` field to the pickup.
- [x] Changed the `collected` Signal to carry a typed `ModuleDefinition` parameter.
- [x] Added a guard clause that prevents collection when no definition is assigned.
- [x] Renamed the pickup Group to `module_pickup`.
- [x] Connected all active module pickups through Group lookup in `Main`.
- [x] Created the runtime `ModuleInventory` Resource class.
- [x] Added typed module storage with `Array[ModuleDefinition]`.
- [x] Added `add_module()`, `get_count()`, and `get_modules()` methods.
- [x] Created a runtime inventory using `ModuleInventory.new()`.
- [x] Added `ModuleListLabel` to display all collected module names.
- [x] Resolved parser errors caused by renaming and duplicate/stale global-class registration.
- [x] Verified the Git workflow and pushed the Week 1 checkpoint.

---

## Current Architecture

### Definition data

```text
ModuleDefinition
├── engine.tres
│   └── display_name = "Engine"
├── battery.tres
│   └── display_name = "Battery"
└── armor_plate.tres
    └── display_name = "Armor Plate"
```

`ModuleDefinition` describes fixed module data. The `.tres` files are saved definition assets.

### Runtime state

```text
Main
└── module_inventory: ModuleInventory
    └── modules: Array[ModuleDefinition]
```

`ModuleInventory` is created in memory when `Main` is created. It records which module definitions were collected during the current run.

### Event flow

```text
ModulePickup.collected(module)
→ Main._on_module_collected(module)
→ ModuleInventory.add_module(module)
→ Main updates labels
```

### Scene structure

```text
Main
├── Grid
├── Player
├── Scrap       → Engine definition
├── Scrap2      → Battery definition
├── Scrap3      → Armor Plate definition
├── ScrapLabel
├── GoalLabel
└── ModuleListLabel
```

The three pickup Nodes are instances of the same reusable Scene. Their assigned Resource data is different.

---

## Files Changed During Week 1

```text
resources/modules/engine.tres
resources/modules/battery.tres
resources/modules/armor_plate.tres

scenes/main.tscn
scenes/scrap/scrap.tscn

scripts/main.gd
scripts/interactions/module_pickup.gd
scripts/modules/module_definition.gd
scripts/modules/module_inventory.gd
```

Godot also created or updated `.uid` metadata files for the new scripts.

The obsolete script was removed:

```text
scripts/interactions/scrap.gd
```

---

## Tests Passed

The developer reported the following runtime tests passing in Godot:

- [x] Project launches without parser errors.
- [x] Existing grid movement still works.
- [x] Engine can be collected.
- [x] Battery can be collected.
- [x] Armor Plate can be collected.
- [x] Each pickup disappears after collection.
- [x] Each pickup emits the correct `ModuleDefinition`.
- [x] Output prints the correct collected module name.
- [x] Output counts owned modules from `1` to `3`.
- [x] HUD lists Engine, Battery, and Armor Plate.
- [x] No duplicate collection Signal behavior was observed.
- [x] All three definitions work through the same pickup Scene.

Expected Output pattern:

```text
Collected module: Engine
Modules owned: 1
Collected module: Battery
Modules owned: 2
Collected module: Armor Plate
Modules owned: 3
```

Expected HUD result:

```text
Modules:
Engine
Battery
Armor Plate
```

---

## Known Bugs, Limitations, and Inconsistencies

### No blocking bugs

There are no known blockers for beginning Week 2.

### Remaining prototype naming

Some older names still use `Scrap` terminology:

```text
scenes/scrap/scrap.tscn
Scrap
Scrap2
Scrap3
ScrapLabel
GoalLabel
scrap_count
scrap_goal
```

This does not break the current system. Rename these only as a separate, tested cleanup task; do not combine it with the first Week 2 data task.

### Module data is intentionally minimal

`ModuleDefinition` currently contains only:

```gdscript
@export var display_name: String = ""
```

Capacity costs, stat bonuses, and granted moves have not been implemented yet. They belong to later Week 2 steps after Scrapture definition/runtime separation is established.

### Runtime inventory resets

`ModuleInventory` is created with:

```gdscript
ModuleInventory.new()
```

It resets whenever the current game run or `Main` instance restarts. This is expected. Save/load is deferred.

### Static pickup connection

`Main` connects pickup Signals by finding Nodes in the `module_pickup` Group during `_ready()`.

This works for the current static overworld. Pickups dynamically created after `_ready()` would need their Signals connected separately. Dynamic spawning is not required now.

### Git line-ending warning

Git displayed a CRLF-to-LF normalization warning for a GDScript file. This is not a gameplay or parser error.

---

## Important Concepts Learned

- A class definition and an instance are different.
- `Resource` is a data object; `.tres` is one way to save a Resource to disk.
- A Resource can also be created only in memory using `.new()`.
- Definition data should remain separate from changing runtime state.
- Signals can carry typed parameters.
- Groups find related Node instances in the active Scene Tree.
- A Scene, a Node instance, a script file, and a `class_name` are different concepts.
- Typed arrays restrict which value types may be stored.
- Guard clauses stop invalid behavior early.
- `ModuleInventory` owns module collection state; `Main` coordinates events and HUD updates.

---

# Next Session

## Roadmap Week

**Week 2 — Scrapture Data and Loadout Customization**

## Immediate Gameplay Goal

Create the fixed definition-data type for a Scrapture.

This supports the core loop by establishing the base Health, Speed, and Attachment Capacity that modules will modify later.

Do not build runtime Scrapture state, loadout UI, equipping, capacity validation, final-stat calculations, or battle code in the same step.

---

## Exact Next Step

Create:

```text
res://scripts/scraptures/scrapture_definition.gd
```

with:

```gdscript
class_name ScraptureDefinition
extends Resource


@export var display_name: String = ""
@export var base_max_health: int = 10
@export var base_speed: int = 5
@export var attachment_capacity: int = 3
```

### Meaning of the fields

- `display_name`: name shown to the player.
- `base_max_health`: maximum Health before module bonuses.
- `base_speed`: Speed before module bonuses.
- `attachment_capacity`: total module capacity available to this Scrapture.

These are fixed definition values. Do not add `current_health` to this Resource.

### Acceptance test

- [ ] `scrapture_definition.gd` saves without a parser error.
- [ ] `ScraptureDefinition` appears in Godot's **New Resource** dialog.
- [ ] Red error count remains `0`.
- [ ] No other scripts or Scenes are changed during this step.
- [ ] Do not create the starter `.tres` until this class test passes.

---

## Session Handoff

### Session

- **Date:** July 29, 2026
- **Session number:** 3
- **Roadmap week completed:** Week 1
- **Session goal:** Convert generic Scrap pickups into reusable data-driven Module pickups and store collected definitions in a small runtime inventory.

### Files changed

```text
resources/modules/engine.tres
resources/modules/battery.tres
resources/modules/armor_plate.tres
scenes/main.tscn
scenes/scrap/scrap.tscn
scripts/main.gd
scripts/interactions/module_pickup.gd
scripts/modules/module_definition.gd
scripts/modules/module_inventory.gd
```

### Features completed

- Data-driven Module definitions.
- Reusable Module pickup.
- Typed collection Signal.
- Runtime Module inventory.
- HUD module list.
- Engine, Battery, and Armor Plate test data.
- GitHub checkpoint.

### Tests passed

- All three module pickups collect correctly.
- Correct definitions reach `Main`.
- Inventory count reaches three.
- HUD displays all module names.
- Project runs without parser errors.
- Existing grid movement remains functional.

### Known bugs

- No blocking bugs.
- Old `Scrap` names remain as non-blocking cleanup.
- Runtime inventory intentionally resets between runs.

### Exact next step

Create and validate the `ScraptureDefinition` Resource class only.

### Existing code commit

```text
Add data-driven module pickups and module inventory
```

### Suggested commit for this progress-log update

```text
Update progress log for Week 1 completion
```

### Suggested future commit after the first Week 2 code step

```text
Add Scrapture definition resource
```

---

## Rules for the Next Assistant

- Read this file before proposing work.
- State that Week 1 is complete and Week 2 is beginning.
- Start only with `ScraptureDefinition`.
- Explain fixed definition data versus runtime state before adding changing values.
- Keep each change small and testable.
- Do not skip to loadout, capacity validation, stat calculations, or battle.
- Preserve the working module pickup and inventory code.
- End the session by updating this file again.
