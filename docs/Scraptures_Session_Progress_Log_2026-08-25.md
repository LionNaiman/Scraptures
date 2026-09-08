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

- **Date:** August 25, 2026
- **Session number:** 4
- **Roadmap status:** Week 2 in progress — Scrapture data/runtime, Attachment Capacity, final-stat calculation, and loadout/inventory UI.
- **Week 1:** Complete.
- **Week 2:** Core data and equipment rules are largely implemented; UI work is in progress.
- **Git status:** Local changes were not verified against GitHub at the end of this session. Run `git status` before committing.

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

The current implementation now proves this portion:

```text
Explore
→ collect ModuleDefinitions
→ store them in ModuleInventory
→ create a starter Scrapture runtime
→ equip/unequip modules
→ enforce Attachment Capacity
→ recalculate Speed and Max Health from equipped modules
→ begin presenting Scrapture/loadout data in UI
```

---

# Week 2 — Scrapture Data and Loadout Customization

## Session Goal

Build the Week 2 Scrapture customization foundation:

- fixed Scrapture definition data;
- runtime Scrapture state;
- Attachment Capacity;
- inventory-to-equipment ownership transfer;
- module-based stat bonuses;
- final-stat calculation;
- first reusable loadout UI.

---

## Features Completed This Session

### Scrapture definition data

- [x] Created `ScraptureDefinition` as a custom `Resource`.
- [x] Added fixed definition fields:
  - `display_name`
  - `base_max_health`
  - `base_speed`
  - `attachment_capacity`
- [x] Created a starter Scrapture `.tres` Resource.
- [x] Used temporary starter values:
  - Name: `Starter`
  - Base Max Health: `20`
  - Base Speed: `5`
  - Attachment Capacity: `3`

### Scrapture runtime state

- [x] Created `ScraptureRuntime`.
- [x] Added:
  - `definition: ScraptureDefinition`
  - `current_health`
  - `equipped_modules: Array[ModuleDefinition]`
- [x] Added explicit `initialize()` logic instead of using `_ready()`.
- [x] `Main` creates one runtime Starter from the exported starter definition.

### Attachment Capacity

- [x] Added `capacity_cost` to `ModuleDefinition`.
- [x] Added used-capacity calculation.
- [x] Added remaining-capacity calculation.
- [x] Added `can_equip_module()`.
- [x] Added capacity validation to `equip_module()`.
- [x] A module is rejected when it would exceed the Scrapture's Attachment Capacity.

### Module ownership transfer

- [x] Added `ModuleInventory.remove_module()`.
- [x] Added `ModuleInventory.has_module()`.
- [x] Added `ScraptureRuntime.equip_module()`.
- [x] Added `ScraptureRuntime.unequip_module()`.
- [x] Added `Main.try_equip_module_from_inventory()`.
- [x] Added `Main.try_unequip_module_to_inventory()`.
- [x] Equipping transfers a module from inventory to the Scrapture.
- [x] Unequipping transfers it back to inventory.
- [x] Temporary Enter/U debug controls were used to test the rules and then removed.

### Module stat bonuses

- [x] Added `speed_bonus` to `ModuleDefinition`.
- [x] Engine test value gives a Speed bonus.
- [x] Added `max_health_bonus` to `ModuleDefinition`.
- [x] Armor Plate test value gives a Max Health bonus.
- [x] Battery currently has no Speed or Max Health bonus.

### Final-stat calculation

- [x] Added `ScraptureRuntime.get_final_speed()`.
- [x] Final Speed is derived from base Speed plus equipped module bonuses.
- [x] Added `ScraptureRuntime.get_final_max_health()`.
- [x] Final Max Health is derived from base Max Health plus equipped module bonuses.
- [x] Final stats are calculated from current equipment rather than stored as duplicate mutable values.

### Current Health safety

- [x] Unequipping a Max-Health module clamps `current_health` when necessary.
- [x] `current_health` is prevented from remaining above the new Final Max Health.
- [x] Equipping Armor Plate does not automatically heal the Scrapture.

### Loadout UI

- [x] Created `scenes/ui/LoadoutPanel.tscn`.
- [x] `LoadoutPanel` uses `PanelContainer`.
- [x] Added a `VBoxContainer` named `Content`.
- [x] Added Labels for:
  - Scrapture name
  - Health
  - Speed
  - Capacity
  - Equipped modules
- [x] Created `scripts/ui/loadout_panel.gd`.
- [x] Added `class_name LoadoutPanel`.
- [x] Added typed `@onready` Label references.
- [x] Added `display_scrapture(scrapture: ScraptureRuntime)`.
- [x] The UI reads final values from `ScraptureRuntime` rather than calculating gameplay rules itself.
- [x] Began connecting `LoadoutPanel` to `Main`.

---

## Important Architecture Decisions

### Definition data vs runtime state

```text
ScraptureDefinition
"What kind of Scrapture is this?"
```

Stores fixed data such as base Health, base Speed, and Attachment Capacity.

```text
ScraptureRuntime
"What is happening to this specific Scrapture?"
```

Stores changing state such as current Health and equipped modules.

### Module ownership

```text
ModuleInventory
    owns available/unequipped modules

ScraptureRuntime
    owns equipped modules

Main
    currently coordinates transfer between them
```

The Scrapture runtime does not directly reach into the player's inventory.

### Derived stats

Do not store duplicate `final_speed`, `final_max_health`, or used-capacity variables.

Instead derive them from:

```text
definition base values
+
current equipped_modules
=
current final values
```

This avoids stale values after equipment changes.

### UI responsibility

```text
ScraptureRuntime
    owns gameplay rules

LoadoutPanel
    displays Scrapture/loadout results
```

The UI should call methods such as:

```gdscript
get_final_speed()
get_final_max_health()
get_used_capacity()
get_remaining_capacity()
```

It should not reimplement those calculations.

### Inventory screen clarification

A key UI distinction was clarified near the end of the session:

```text
LoadoutPanel
    = Scrapture stats and equipped-module presentation

InventoryScreen
    = the actual player inventory interface
```

The intended structure is:

```text
InventoryScreen
├── Available Modules
└── LoadoutPanel
    ├── Scrapture stats
    ├── Capacity
    └── Equipped Modules
```

The eventual behavior should be:

```text
Exploration
→ press I
→ InventoryScreen opens
→ view available modules and Scrapture loadout
→ equip/unequip
→ close inventory
→ return to exploration
```

Do not treat `LoadoutPanel` itself as the entire inventory screen.

---

## Tests Passed

The following behavior was tested or accepted during the session:

- [x] Starter definition Resource can be created and assigned in Godot.
- [x] Starter runtime initializes successfully.
- [x] Output showed:
  - `Starter: Starter`
  - `Starting health: 20`
- [x] Existing module pickups still collect correctly.
- [x] Equipping removes a module from `ModuleInventory`.
- [x] Equipped modules consume Attachment Capacity.
- [x] Three cost-1 modules fill a capacity of `3`.
- [x] A fourth module is rejected when capacity is full.
- [x] A rejected module remains in inventory.
- [x] Unequipping returns a module to inventory.
- [x] Unequipping restores available capacity.
- [x] Engine changes Final Speed from the base value and removing it restores the base value.
- [x] Armor Plate changes Final Max Health and removing it restores the lower value.
- [x] Current Health is clamped if removing Armor Plate would otherwise leave Health above the new maximum.
- [x] Temporary keyboard equipment tests were removed after the rule tests.
- [x] Existing movement/module collection was preserved through the gameplay-rule work.

---

## Files Changed During This Session

Based on the work completed in this chat. Verify exact local changes with `git status` before committing.

```text
scripts/scraptures/scrapture_definition.gd
resources/scraptures/starter_scrapture.tres
scripts/scraptures/scrapture_runtime.gd

scripts/modules/module_definition.gd
scripts/modules/module_inventory.gd
resources/modules/engine.tres
resources/modules/battery.tres
resources/modules/armor_plate.tres

scripts/main.gd
scenes/main.tscn

scenes/ui/LoadoutPanel.tscn
scripts/ui/loadout_panel.gd
```

A temporary `Content.tscn` was accidentally created while building the UI and was removed; `Content` should be a `VBoxContainer` child inside `LoadoutPanel.tscn`, not a separate Scene.

---

## Known Bugs, Limitations, and Inconsistencies

### Inventory screen is not implemented yet

The dedicated player inventory interface has been designed conceptually but not completed.

The next scene is intended to be:

```text
res://scenes/ui/InventoryScreen.tscn
```

with:

```text
InventoryScreen (Control)
└── Panel (PanelContainer)
```

Creation of this Scene was explained, but completion was not confirmed before ending the session.

### Inventory open/close input is not implemented

The intended control is:

```text
I → open/close InventoryScreen
```

Do not wire `I` directly to `LoadoutPanel`; `LoadoutPanel` is only the Scrapture/loadout portion of the inventory interface.

### Loadout interaction is incomplete

There are no real module selection, Equip, or Unequip buttons yet.

The gameplay functions already exist, but the UI has not been connected to them.

### Battery move is not implemented

There is a roadmap inconsistency:

- The Week 2 plan lists a Battery electric move in its exit criteria.
- The broader roadmap also places module-granted moves in Week 4.

For the current development sequence, module-granted moves have not been implemented. Keep Week 2 focused on Scrapture data, capacity, stats, and the basic inventory/loadout UI unless the roadmap is deliberately revised.

### Old prototype naming remains

Older `Scrap` terminology may still exist in scene/node/UI names such as:

```text
ScrapLabel
GoalLabel
scrap_count
scrap_goal
```

This is non-blocking cleanup and should not be mixed into the next inventory UI step.

### Runtime state is session-only

`ModuleInventory` and `ScraptureRuntime` are runtime objects and reset when the game restarts.

Save/load is deferred.

### Git state not verified

The local Week 2 changes were not verified against the remote repository at the end of this session.

---

## Important Concepts Reinforced This Session

- `Resource` is suitable for reusable definition data and runtime data that does not need to live in the Scene Tree.
- `_ready()` is a Node callback; runtime Resources can use explicit initialization functions.
- `class_name` creates a globally recognized GDScript type.
- A Scene definition and an instantiated Node are different.
- `@onready` waits until the Node and its children are ready before resolving Node paths.
- `bool` return values allow callers to know whether an operation succeeded.
- Guard clauses stop invalid operations early.
- `Array.has()` checks ownership/presence.
- `Array.erase()` removes one matching entry.
- `min()` can enforce `current_health <= final_max_health`.
- Derived gameplay values are safer than duplicated mutable state.
- UI should display gameplay data, not own gameplay calculations.
- `LoadoutPanel` and `InventoryScreen` have different responsibilities.

---

# Next Session

## Roadmap Week

**Week 2 — Scrapture Data and Loadout Customization**

Week 2 is not complete yet. Do not start battle work.

---

## Immediate Gameplay Goal

Create the dedicated inventory-screen Scene that will eventually open with `I` and contain both the available module list and the reusable Scrapture `LoadoutPanel`.

This supports the core loop by giving the player a real place to manage the modules collected during exploration.

---

## Exact Next Step

Create and verify:

```text
res://scenes/ui/InventoryScreen.tscn
```

with only:

```text
InventoryScreen (Control)
└── Panel (PanelContainer)
```

### Acceptance test

- [ ] `InventoryScreen.tscn` exists under `scenes/ui/`.
- [ ] Root is a `Control` named `InventoryScreen`.
- [ ] It has one `PanelContainer` child named `Panel`.
- [ ] `LoadoutPanel.tscn` remains a separate reusable Scene.
- [ ] No inventory input, module buttons, or equip UI are added in the same step.
- [ ] Project runs with zero parser errors.

After that passes, the next step is to build the InventoryScreen layout and place a `LoadoutPanel` instance inside it.

---

## Session Handoff

### Session

- **Date:** August 25, 2026
- **Session number:** 4
- **Roadmap week:** Week 2 in progress
- **Session goal:** Build Scrapture runtime customization rules, final-stat calculation, and begin the basic loadout/inventory UI.

### Features completed

- Scrapture definition and starter Resource.
- Runtime Scrapture state.
- Attachment Capacity and validation.
- Module equip/unequip ownership transfer.
- Speed and Max Health module bonuses.
- Derived final-stat calculations.
- Current-health clamp after Max Health decreases.
- Reusable `LoadoutPanel` Scene and display script.
- UI responsibility clarified between `LoadoutPanel` and future `InventoryScreen`.

### Tests passed

- Starter runtime initializes correctly.
- Equip/unequip transfer works.
- Capacity rejection works.
- Engine affects Speed.
- Armor Plate affects Max Health.
- Current Health remains valid after Max Health decreases.
- Existing collection and movement remain functional.

### Known bugs / incomplete work

- Dedicated `InventoryScreen` is not yet confirmed created.
- `I` open/close behavior is not implemented.
- Available-module list UI is not implemented.
- Equip/Unequip buttons are not implemented.
- Battery-granted move is deferred/unresolved between Week 2 and Week 4 roadmap wording.
- Old Scrap naming remains as non-blocking cleanup.
- Git status/push was not verified this session.

### Exact next step

Create `InventoryScreen.tscn` with a `Control` root and one `PanelContainer` child, then test that the Scene saves without errors.

### Suggested Git commit message

```text
Add Scrapture runtime customization and loadout UI foundation
```

---

## Rules for the Next Assistant

- Read this file first.
- State that Week 2 is still in progress.
- Do not start Week 3 battle work yet.
- Preserve the working Scrapture runtime, equipment, capacity, and final-stat rules.
- Keep `LoadoutPanel` as the Scrapture stats/equipment presentation component.
- Build `InventoryScreen` separately as the full inventory interface.
- Add one UI step at a time and test after each step.
- Do not reintroduce temporary Enter/U equipment controls.
- Do not implement save/load, large inventories, or unrelated systems.
- Update this progress log again at the end of the next session.
