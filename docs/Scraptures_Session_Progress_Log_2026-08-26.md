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

- **Date:** August 26, 2026
- **Session number:** 5
- **Week 1:** Complete.
- **Week 2:** Core milestone complete.
- **Next roadmap milestone:** Week 3 — Minimal one-versus-one turn-based battle.
- **Git status:** Local Session 5 changes still need to be verified with `git status`, committed, and pushed.

The project now proves this part of the core loop:

```text
Explore
→ collect ModuleDefinitions
→ store them in ModuleInventory
→ open InventoryScreen
→ inspect Starter runtime stats
→ select a specific available module
→ equip it
→ enforce Attachment Capacity
→ recalculate Speed / Max Health
→ select a specific equipped module
→ unequip it
→ return it to ModuleInventory
```

---

# Week 2 — Scrapture Data and Loadout Customization

## Milestone Status

**Core Week 2 milestone complete.**

The project now has a functional inventory/loadout interface on top of the Scrapture runtime and equipment rules created previously.

The broader roadmap places module-granted moves in Week 4, so those remain deferred until after the minimal Week 3 battle foundation exists.

---

## Session Goal

Finish the basic Week 2 inventory/loadout interface and prove that the existing gameplay rules work through real UI interaction.

This session focused on:

- creating a dedicated `InventoryScreen`;
- opening and closing it with `I`;
- stopping overworld movement while the inventory is open;
- selecting specific available and equipped modules;
- connecting Equip and Unequip Signals to `Main`;
- refreshing the UI after equipment changes;
- enforcing Attachment Capacity through the UI;
- showing player-facing failure feedback;
- validating Engine Speed and Armor Plate Max Health bonuses;
- removing obsolete duplicate inventory/loadout UI.

---

# Features Completed This Session

## InventoryScreen Scene

Created/finalized:

```text
res://scenes/ui/InventoryScreen.tscn
```

Approximate final structure:

```text
InventoryScreen (Control)
└── Panel (PanelContainer)
    └── Content (VBoxContainer)
        ├── AvailableModulesTitle (Label)
        ├── AvailableModulesOptionButton (OptionButton)
        ├── EquipButton (Button)
        ├── EquippedModulesOptionButton (OptionButton)
        ├── UnequipButton (Button)
        ├── FeedbackLabel (Label)
        └── LoadoutPanel (instanced Scene)
```

Responsibilities:

- `AvailableModulesOptionButton` — choose a module owned by `ModuleInventory`.
- `EquipButton` — request equipping the selected available module.
- `EquippedModulesOptionButton` — choose a module currently equipped on the Starter.
- `UnequipButton` — request removing the selected equipped module.
- `FeedbackLabel` — display equipment feedback.
- `LoadoutPanel` — display Scrapture stats, capacity, and equipped modules.

---

## InventoryScreen Script

Created/finalized:

```text
res://scripts/ui/inventory_screen.gd
```

Key responsibilities:

- Holds typed references to the Inventory UI Controls.
- Displays the current `ModuleInventory`.
- Displays the current `ScraptureRuntime` through `LoadoutPanel`.
- Builds `OptionButton` entries from runtime module arrays.
- Maps `OptionButton` indices back to actual `ModuleDefinition` references.
- Tracks the selected available module.
- Tracks the selected equipped module.
- Enables/disables Equip and Unequip buttons when appropriate.
- Emits requests instead of changing gameplay state directly.
- Displays feedback text.

Important signals:

```gdscript
signal equip_requested(module: ModuleDefinition)
signal unequip_requested(module: ModuleDefinition)
```

Important selection flow:

```text
OptionButton index
→ corresponding ModuleDefinition in displayed_modules
→ selected_module
→ equip_requested(selected_module)
```

The UI does not own the modules and does not decide whether an Equip is legal.

---

## Real Module Selection

The temporary “always use the first module” behavior was replaced with real selection.

Example available-module mapping:

```text
index 0 → Engine
index 1 → Battery
index 2 → Armor Plate
```

When the player selects index `1`:

```text
displayed_modules[1]
→ Battery
→ selected_module = Battery
```

Clicking Equip then emits the actual `Battery` `ModuleDefinition`.

The same approach is used for equipped-module selection before Unequip.

---

## Equip Flow Connected to Main

Current flow:

```text
Player selects module
→ EquipButton pressed
→ InventoryScreen emits equip_requested(module)
→ Main receives request
→ try_equip_module_from_inventory(module)
→ ScraptureRuntime capacity validation
→ ownership transfer on success
→ Main refreshes InventoryScreen + LoadoutPanel
```

The UI does not directly:

- remove modules from `ModuleInventory`;
- add modules to `ScraptureRuntime`;
- calculate Attachment Capacity;
- calculate final stats.

Those remain gameplay responsibilities.

---

## Unequip Flow Connected to Main

Current flow:

```text
Player selects equipped module
→ UnequipButton pressed
→ InventoryScreen emits unequip_requested(module)
→ Main receives request
→ try_unequip_module_to_inventory(module)
→ ScraptureRuntime removes module
→ ModuleInventory receives module
→ Main refreshes InventoryScreen + LoadoutPanel
```

This proves ownership transfer in both directions:

```text
ModuleInventory → ScraptureRuntime
ScraptureRuntime → ModuleInventory
```

---

## Inventory Open / Close

Added an Input Map action for the inventory, mapped to the `I` key.

The Inventory starts hidden.

`Main` toggles `InventoryScreen.visible` when the inventory action is pressed.

Input is handled through an input-event callback rather than a frame callback.

---

## Player Movement Disabled While Inventory Is Open

The existing Player movement uses `_unhandled_input(event)`.

When the Inventory opens, `Main` disables the Player's unhandled-input processing.

When the Inventory closes, `Main` enables it again.

Confirmed behavior:

```text
Inventory closed
→ grid movement works

Inventory open
→ grid movement is blocked

Inventory closed again
→ grid movement resumes
```

The Player movement script itself does not need to know what the InventoryScreen is.

---

## UI Cleanup

Removed obsolete duplicate UI after `InventoryScreen` became functional.

Cleanup included:

- removing the old direct `LoadoutPanel` child from `Main`;
- removing the old direct `LoadoutPanel` reference/call in `main.gd`;
- removing the old `ModuleListLabel` from the overworld;
- removing `update_module_list_label()` and its calls;
- removing the temporary `AvailableModulesLabel` once the `OptionButton` became the actual available-module display.

Current responsibility split:

```text
Main
→ coordinates gameplay state and requests

InventoryScreen
→ owns inventory/loadout presentation

LoadoutPanel
→ displays Scrapture stats/equipment only
```

---

## Attachment Capacity UI Validation

Attachment Capacity was tested through the real Inventory UI.

Confirmed behavior:

```text
selected module cost > remaining capacity
→ Equip request reaches gameplay rules
→ can_equip_module() returns false
→ module remains in ModuleInventory
→ equipped modules do not change
→ capacity does not change
→ stats do not change
```

After Unequipping a module and freeing enough capacity, the previously rejected module can be equipped successfully.

This proves that UI interaction does not bypass `ScraptureRuntime` validation.

---

## Player-Facing Equip Failure Feedback

Added:

```text
FeedbackLabel
```

and a small UI helper:

```gdscript
func show_feedback(message: String) -> void:
    feedback_label.text = message
```

A failed Equip caused by insufficient capacity now displays:

```text
Not enough Attachment Capacity.
```

A later successful Equip or Unequip clears stale feedback.

Temporary debug `print()` calls used while diagnosing the feedback flow should not remain in the final committed code.

---

## Armor Plate Max Health Data Fix

During final Week 2 validation, Armor Plate equipped correctly but Max Health remained at `20`.

The calculation and `LoadoutPanel` display were already correct. The issue was definition data: `armor_plate.tres` still had the default `max_health_bonus = 0`.

Armor Plate was updated to:

```text
Max Health Bonus = 10
```

Confirmed runtime behavior:

```text
Before Armor Plate:
Health: 20 / 20

After equipping Armor Plate:
Health: 20 / 30

After unequipping Armor Plate:
Health: 20 / 20
```

Equipping Max Health does not automatically heal current Health.

---

# Tests Passed

The following behavior was confirmed during Session 5:

- [x] `InventoryScreen` displays the Starter through the reusable `LoadoutPanel`.
- [x] Available modules appear in the Inventory UI.
- [x] Inventory opens with `I`.
- [x] Inventory closes with `I`.
- [x] Player cannot move while Inventory is open.
- [x] Player movement resumes when Inventory closes.
- [x] Equip can move an available module to the Starter.
- [x] Unequip returns an equipped module to inventory.
- [x] Available-module selection can target a module other than the first module.
- [x] Equipped-module selection can target a module other than the first equipped module.
- [x] Selected module identity is preserved through the Signal flow.
- [x] Engine Equip/Unequip changes/restores Final Speed.
- [x] Armor Plate Equip/Unequip changes/restores Final Max Health.
- [x] Armor Plate test shows `20 / 30`, then returns to `20 / 20`.
- [x] Attachment Capacity rejects a module that does not fit.
- [x] Rejected modules remain in inventory.
- [x] Capacity and stats remain unchanged after a rejected Equip.
- [x] Freeing capacity allows a previously rejected module to equip.
- [x] Failed Equip displays `Not enough Attachment Capacity.`
- [x] Feedback clears after a later successful Equip/Unequip.
- [x] Existing module collection still works.
- [x] Existing grid movement still works.
- [x] No blocking parser/runtime errors were reported after the final tests.

---

# Week 2 Core Exit Criteria

Using the current production sequence:

- [x] Scrapture definition data exists.
- [x] Starter definition exists.
- [x] Runtime Scrapture state exists.
- [x] Attachment Capacity exists.
- [x] Modules can be equipped.
- [x] Modules can be unequipped.
- [x] Invalid capacity usage is rejected.
- [x] Final stats derive from base stats plus equipped modules.
- [x] Engine visibly increases Speed.
- [x] Armor Plate visibly increases Max Health.
- [x] The player has a basic interactive loadout/inventory screen.
- [x] Definition data and runtime state remain separate.
- [x] Gameplay rules remain separate from UI presentation.

**Week 2 core milestone is complete.**

### Deferred roadmap item

- [ ] Module-granted moves.

The broader roadmap places module-granted moves in Week 4, after the minimal battle system exists.

---

# Files Changed During Session 5

Verify the exact list locally with:

```bash
git status
```

Expected changed/new files include:

```text
project.godot
scenes/main.tscn
scripts/main.gd

scenes/ui/InventoryScreen.tscn
scripts/ui/inventory_screen.gd

resources/modules/armor_plate.tres
```

Depending on how the earlier accidental scene location was moved, Git may also show deletion/rename activity for:

```text
scripts/ui/InventoryScreen.tscn
```

The intended final location is:

```text
res://scenes/ui/InventoryScreen.tscn
```

Verify that there is no stray duplicate before committing.

Existing reusable files used by this session include:

```text
scenes/ui/LoadoutPanel.tscn
scripts/ui/loadout_panel.gd
scripts/scraptures/scrapture_runtime.gd
scripts/modules/module_inventory.gd
scripts/modules/module_definition.gd
```

These may or may not appear in Session 5's Git diff depending on local edits.

---

# Known Bugs, Limitations, and Deferred Work

## No blocking Week 2 bugs currently known

All final Week 2 acceptance tests performed in this session passed.

## Runtime state resets between game launches

`ModuleInventory` and `ScraptureRuntime` are still session-only runtime objects.

Save/load remains intentionally deferred.

## Placeholder UI

The Inventory/Loadout UI is functional, not polished.

Do not spend Week 3 on visual polish unless it blocks battle readability. Broader UX work belongs to Week 6.

## Equip feedback is intentionally simple

The current failure message assumes a failed Equip is caused by Attachment Capacity.

If more validation rules are added later, failure reasons should become explicit rather than mapping every failure to the same message.

Do not build a large result/error framework now.

## Old prototype Scrap naming remains

Older names may still remain, such as:

```text
ScrapLabel
GoalLabel
scrap_count
scrap_goal
scenes/scrap/
```

This is non-blocking cleanup.

Do not combine broad naming cleanup with the first Week 3 battle implementation.

## Module-granted moves are deferred

Engine/Battery/Armor-granted moves are not implemented yet.

They belong to Week 4 in the current production sequence.

---

# Important Concepts Reinforced This Session

- A `Control` Scene can be reused as a UI component.
- A Node path such as `$Panel/Content/EquipButton` is relative to the Node running the script.
- Inspector defaults and runtime values are different.
- Input events are different from frame callbacks.
- `_unhandled_input(event)` reacts to input events rather than running every frame.
- `OptionButton` emits an integer index for the selected item.
- The index is only a lookup key; gameplay continues using the actual `ModuleDefinition`.
- UI arrays such as `displayed_modules` are presentation references, not ownership containers.
- Signals let UI request gameplay operations without owning gameplay rules.
- `bool` return values let the caller react to success/failure.
- Attachment Capacity validation belongs in gameplay code, not UI code.
- Final stats should be derived from definition data plus equipped-module data.
- Current Health and Final Max Health are separate runtime concepts.
- A Resource's exported default value is used when a `.tres` asset does not override it.
- `Main`, `InventoryScreen`, and `LoadoutPanel` now have clearer separate responsibilities.

---

# Next Session

## Roadmap Week

**Week 3 — Minimal Turn-Based Battle**

The Week 3 roadmap goal is a functional one-versus-one battle with:

- Speed-based turn order;
- Basic Attack;
- Guard;
- health UI;
- simple enemy AI;
- battle end on defeat.

Do not add capture or module-granted moves yet.

---

## Immediate Gameplay Goal

Create the smallest reusable Battle Scene shell that can later operate on two `ScraptureRuntime` objects.

This begins the:

```text
encounter
→ battle
```

portion of the core loop without prematurely adding damage, AI, capture, or module moves.

---

## Exact Next Step

Create:

```text
res://scenes/battle/Battle.tscn
```

with only:

```text
Battle (Node)
```

Then create and attach:

```text
res://scripts/battle/battle.gd
```

with:

```gdscript
class_name Battle
extends Node


var player_scrapture: ScraptureRuntime
var enemy_scrapture: ScraptureRuntime
```

Do not add `_ready()`, attacks, damage, turn order, UI, enemy AI, capture, or module-granted moves in the same step.

### Acceptance test

- [ ] `Battle.tscn` exists under `scenes/battle/`.
- [ ] Root is a `Node` named `Battle`.
- [ ] `battle.gd` is attached to the root.
- [ ] `battle.gd` contains typed `player_scrapture` and `enemy_scrapture` runtime references.
- [ ] Godot reports zero parser errors.
- [ ] Existing overworld/inventory behavior remains unchanged.

After this passes, the next step is to give `Battle` an explicit initialization function that receives the two `ScraptureRuntime` objects rather than creating them internally.

---

# Session Handoff

### Session

- **Date:** August 26, 2026
- **Session number:** 5
- **Roadmap week completed:** Week 2 core milestone
- **Session type:** Integration / review
- **Session goal:** Finish the interactive Inventory/Loadout UI and validate Week 2 end-to-end behavior.

### Features completed

- Dedicated `InventoryScreen`.
- Inventory open/close using `I`.
- Player movement disabled while inventory is open.
- Reusable `LoadoutPanel` embedded in InventoryScreen.
- Selectable available modules.
- Selectable equipped modules.
- Equip request Signal.
- Unequip request Signal.
- Main-connected ownership transfer.
- Attachment Capacity enforcement through UI.
- Player-facing capacity failure feedback.
- Engine Speed validation.
- Armor Plate Max Health validation.
- Duplicate/obsolete inventory UI cleanup.

### Tests passed

- Module collection still works.
- Inventory displays collected modules.
- Inventory toggle works.
- Movement blocking/restoration works.
- Specific module selection works.
- Equip works.
- Unequip works.
- Capacity rejection works.
- Capacity recovery after Unequip works.
- Failure feedback works.
- Engine changes Speed.
- Armor Plate changes Max Health.
- No blocking errors reported.

### Known bugs / limitations

- Runtime state resets between game launches.
- UI is functional but visually placeholder.
- Module-granted moves are deferred to Week 4.
- Old Scrap prototype naming remains.
- Exact Git diff/status still needs local verification.

### Exact next step

Start Week 3 by creating only the reusable `Battle` Scene shell and its two typed `ScraptureRuntime` references.

### Suggested Git commit message

```text
Complete Week 2 inventory and loadout UI
```

### Suggested progress-log commit message

```text
Update progress log for Week 2 completion
```

---

# Before Pushing to GitHub

Run:

```bash
git status
```

Verify the expected files and confirm there is no stray duplicate:

```text
scripts/ui/InventoryScreen.tscn
```

Then run the project one final time and verify:

```text
collect modules
→ open Inventory
→ select module
→ equip
→ capacity/stat updates
→ unequip
→ module returns
→ close Inventory
→ movement resumes
```

After that, commit and push the working Week 2 checkpoint.

---

# Rules for the Next Assistant

- Read this file first.
- State that Week 2 core milestone is complete.
- Begin Week 3 with the smallest Battle Scene scaffold only.
- Preserve all working module collection, inventory, equipment, capacity, and stat logic.
- Do not rewrite `ScraptureRuntime` to start battle work.
- Battle must consume runtime Scrapture state rather than recreating the player's Starter from definition data.
- Keep battle rules separate from UI/animation.
- Do not implement capture until Week 4.
- Do not implement module-granted moves until Week 4.
- Do not add save/load.
- Do not expand the creature roster.
- Test one small battle behavior at a time.
- Update this progress log at the end of the next session.
