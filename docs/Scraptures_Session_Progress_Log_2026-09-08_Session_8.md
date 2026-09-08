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

- **Date:** September 8, 2026
- **Session number:** 8
- **Week 1:** Complete.
- **Week 2:** Core milestone complete.
- **Week 3:** Core milestone complete.
- **Week 4:** Core milestone complete.
- **Next roadmap milestone:** Week 5 — connect exploration, encounters, battle, capture, party/loadout, and the final encounter.
- **Git status:** Local Week 4 work must be verified with `git status`, committed, and pushed. The last remote state previously checked was still Week 3, so do not replace local files with GitHub versions.

The project now proves this larger portion of the demo loop:

```text
Explore
→ collect ModuleDefinitions
→ store them in ModuleInventory
→ equip modules on a player-owned Scrapture
→ enforce Attachment Capacity
→ recalculate final stats
→ manually start a test battle with B
→ use Basic Attack / Guard through Battle UI
→ use module-granted moves through dynamic Battle UI buttons
→ resolve Speed-based turns and Guard reduction
→ weaken a wild Scrapture
→ capture at or below the deterministic 30% Health threshold
→ add the captured runtime to the party
→ return to the overworld
→ open the Inventory / loadout screen
→ select a party member
→ inspect and change that selected Scrapture's loadout
```

The remaining major integration gap is that Battle still begins through the temporary `B` key rather than a real overworld encounter.

---

# Week 4 — Module-Granted Moves and Capture

## Milestone Status

**Core Week 4 milestone complete.**

Week 4 added the systems needed to make modules affect combat directly and to make wild Scraptures become player-owned runtime objects.

Implemented Week 4 foundation:

- reusable `MoveDefinition` Resources;
- module-granted battle moves;
- Engine Ram;
- Arc Pulse;
- Brace;
- damage and Guard move kinds;
- dynamic module-move discovery from equipped modules;
- specific move selection rather than always using array index `0`;
- multiple module-move buttons in Battle UI;
- predictable capture at or below 30% Health;
- capture completion signal;
- captured Scraptures joining a persistent runtime party;
- party selection in the loadout screen;
- loadout actions applying to the selected party member;
- minimal player-facing Battle action buttons;
- correct Battle end / UI state flow.

Do not add a large move system, type chart, status effects, random capture formula, large party-management system, or polished battle presentation before later roadmap milestones require them.

---

# Session Goal

Complete the Week 4 demo milestone without expanding scope beyond module-granted moves, predictable capture, captured party ownership, and the minimum UI needed to operate those systems.

This session focused on:

- creating move definition data;
- linking modules to granted moves;
- exposing granted moves from `ScraptureRuntime`;
- integrating granted moves into the existing round resolver;
- making Guard reduction generic for different damage values;
- implementing Engine, Battery, and Armor Plate moves;
- adding deterministic capture;
- storing captured Scraptures in a party;
- selecting party members in the loadout screen;
- making equip / unequip operate on the selected Scrapture;
- proving multiple granted moves can be selected correctly;
- replacing temporary battle action keys with minimal Battle UI buttons;
- fixing Battle UI signal wiring and battle-state regression bugs;
- completing the Week 4 regression pass.

---

# Features Completed This Session

## MoveDefinition Resource

Created a reusable move definition type:

```gdscript
class_name MoveDefinition
extends Resource

enum MoveKind {
    DAMAGE,
    GUARD
}

@export var display_name: String = ""
@export var damage: int = 0
@export var move_kind: MoveKind = MoveKind.DAMAGE
```

This separates move definition data from battle runtime state.

---

## Modules Can Grant Moves

`ModuleDefinition` now has:

```gdscript
@export var granted_move: MoveDefinition
```

Current module move assignments:

```text
Engine
→ Engine Ram
→ Damage move

Battery
→ Arc Pulse
→ Damage move

Armor Plate
→ Brace
→ Guard move
```

No electric type system or advanced move taxonomy was added.

---

## ScraptureRuntime Exposes Granted Moves

`ScraptureRuntime` now derives available module moves from equipped modules.

Conceptually:

```text
equipped_modules
→ inspect each ModuleDefinition.granted_move
→ return available MoveDefinitions
```

This keeps move ownership derived from the Scrapture's actual equipment.

---

## Module Move Resources

Created:

```text
resources/moves/engine_ram.tres
resources/moves/battery_arc.tres
resources/moves/brace.tres
```

Current intent:

```text
Engine Ram
→ Damage
→ 6 damage

Arc Pulse
→ Damage
→ 5 damage

Brace
→ Guard
→ 0 direct damage
```

Brace reuses the existing Guard behavior.

---

## Generic Guard Damage Reduction

Current helper:

```gdscript
func get_guarded_damage(damage: int) -> int:
    return maxi(1, int(damage * 0.5))
```

Examples:

```text
Basic Attack 4
→ guarded damage 2

Engine Ram 6
→ guarded damage 3

Arc Pulse 5
→ guarded damage 2
```

---

## Granted Moves Integrated Into Round Resolution

`BattleAction` now includes:

```gdscript
GRANTED_MOVE
```

A selected `MoveDefinition` can be passed into the round resolver.

Responsibility split:

```text
UI / input
→ selects a MoveDefinition

Battle
→ validates that the move is currently granted
→ resolves the move through normal battle state and turn-order rules
```

The resolver uses the exact selected move rather than rediscovering and executing `granted_moves[0]`.

---

## Multiple Granted Move Selection

A helper was added during development:

```gdscript
perform_granted_move_at_index(index)
```

This proved that multiple granted moves can be selected independently.

The Battle UI exposes up to two module move buttons and maps them to the corresponding granted move positions.

The labels come from:

```gdscript
MoveDefinition.display_name
```

so move names are not hardcoded in the UI.

---

## Predictable Capture

Current eligibility rule:

```text
enemy current Health
≤ 30% of enemy final maximum Health
→ capture succeeds
```

Capture fails above that threshold and leaves Battle active.

No random capture probability is currently used.

---

## Capture Completion Signal

Battle now exposes:

```gdscript
signal scrapture_captured(scrapture: ScraptureRuntime)
```

On successful capture:

```text
Battle
→ enters ENDED state
→ displays Captured!
→ emits scrapture_captured(enemy runtime)
→ emits battle_ended
```

The captured Scrapture is the existing enemy runtime object.

---

## Persistent Scrapture Party

`Main` now owns:

```gdscript
var scrapture_party: Array[ScraptureRuntime] = []
```

The Starter is added to the party when created.

A successfully captured enemy runtime is appended to the party if it is not already present.

---

## Captured Health Persists

Captured Scraptures retain the Health value they had when captured.

Example:

```text
wild Scrapture captured at 4 / 15 HP
→ party receives that same runtime
→ loadout screen shows 4 / 15 HP
```

No automatic post-capture healing has been added.

---

## Selected Party Member for Loadout

`Main` now tracks:

```gdscript
var selected_scrapture: ScraptureRuntime
```

The Starter is initially selected.

Equip and unequip operations apply to `selected_scrapture`.

Battle still uses the Starter as the current test combatant. Choosing which party member enters Battle is not part of the current Week 4 milestone.

---

## Party Selector UI

The Inventory screen now includes a party selector.

Conceptually:

```text
InventoryScreen
└── PartyOptionButton
    → Starter
    → captured Scrapture
    → ...
```

Selecting a party member refreshes the displayed runtime and loadout information.

After capture, the selector is refreshed so the new Scrapture appears without restarting the game.

---

## Minimal Battle Action UI

Current structure is conceptually:

```text
Battle
└── BattleUI
    ├── HealthDisplay
    │   ├── PlayerHealthLabel
    │   ├── EnemyHealthLabel
    │   └── ResultLabel
    └── ActionMenu
        ├── BasicAttackButton
        ├── GuardButton
        ├── CaptureButton
        ├── ModuleMove1Button
        └── ModuleMove2Button
```

The UI requests actions. It does not calculate damage, capture chance, turn order, or Health.

Dynamic module buttons are hidden when the corresponding move does not exist.

Major presentation polish remains a Week 6 task.

---

## Temporary Battle Action Keys Removed

The old development action keys for Basic Attack, Guard, Capture, and module moves were replaced by Battle UI buttons.

The temporary:

```text
B
→ start test battle
```

trigger remains because real exploration encounters belong to Week 5.

---

## Battle End UI Flow

When Battle ends through defeat or capture:

```text
Battle state
→ ENDED

ActionMenu
→ hidden

battle_ended
→ emitted

Main
→ restores overworld player input
```

A new Battle initialization restores the action menu and refreshes module-move buttons.

---

# Tests Passed

- [x] Engine grants Engine Ram.
- [x] Battery grants Arc Pulse.
- [x] Armor Plate grants Brace.
- [x] Granted moves are discovered from equipped modules.
- [x] A Scrapture with no granted move does not crash when a move is requested.
- [x] Module moves participate in normal Battle state validation.
- [x] Engine Ram deals its configured damage.
- [x] Arc Pulse deals its configured damage.
- [x] Brace routes through Guard behavior.
- [x] Guard reduces Basic Attack damage from 4 to 2.
- [x] Guard can reduce module-move damage through the generic helper.
- [x] Enemy Guard reduces incoming module-move damage.
- [x] Multiple granted moves can be represented by separate Battle UI buttons.
- [x] The second move button can execute its own selected move rather than always using move index `0`.
- [x] Module move button labels come from `MoveDefinition.display_name`.
- [x] Capture fails while the enemy is above the 30% threshold.
- [x] Capture succeeds at or below the 30% threshold.
- [x] Successful capture ends Battle.
- [x] Successful capture emits the captured runtime.
- [x] Captured Scrapture is added to the party.
- [x] Captured Scrapture remains in the party after a new enemy runtime is created.
- [x] Captured Health state persists.
- [x] Party selector displays multiple owned Scraptures.
- [x] Selecting a party member refreshes the loadout display.
- [x] Equip / unequip refreshes the currently selected Scrapture correctly.
- [x] Basic Attack UI button resolves one normal round.
- [x] Guard UI button resolves the Guard round.
- [x] Capture UI button uses the existing capture rules.
- [x] Dynamic module move buttons execute the corresponding Battle action.
- [x] Action menu hides when Battle ends.
- [x] A new Battle restores the action menu.
- [x] Battle returns from `RESOLVING` to `WAITING_FOR_PLAYER_ACTION` after surviving rounds.
- [x] Battle remains `ENDED` after defeat or successful capture.
- [x] Player control returns after Battle.
- [x] Existing Week 1–3 exploration, module, Attachment Capacity, final-stat, and Battle foundations remain functional.

---

# Week 4 Core Exit Criteria

- [x] A module can grant a battle move.
- [x] Module move data is represented by reusable Resources.
- [x] Engine grants a specific battle move.
- [x] Battery grants a specific battle move.
- [x] Armor Plate grants a defensive move.
- [x] Module moves are derived from equipped modules.
- [x] Multiple available module moves can be selected independently.
- [x] Module move damage interacts with Guard.
- [x] Capture has a predictable demo rule.
- [x] Capture can fail without ending Battle.
- [x] Successful capture ends Battle.
- [x] Captured Scrapture becomes player-owned runtime state.
- [x] Captured Scrapture appears in the party / loadout flow.
- [x] Loadout can target a selected party member.
- [x] Minimal Battle UI exposes Basic Attack, Guard, Capture, and granted moves.
- [x] Week 4 systems work without adding a type chart, status system, random capture formula, or advanced battle architecture.

**Week 4 core milestone is complete.**

---

# Files Changed During Session 8

Verify the exact list locally with:

```bash
git status
```

Expected changed/new files include at least:

```text
project.godot

scripts/main.gd
scripts/Battle/battle.gd
scripts/modules/module_definition.gd
scripts/scraptures/scrapture_runtime.gd
scripts/ui/inventory_screen.gd
scripts/moves/move_definition.gd

scenes/Battle/Battle.tscn
scenes/ui/InventoryScreen.tscn

resources/modules/engine.tres
resources/modules/battery.tres
resources/modules/armor_plate.tres

resources/moves/engine_ram.tres
resources/moves/battery_arc.tres
resources/moves/brace.tres
```

Godot may also show generated `.uid`, scene serialization, or other editor-managed changes.

Do not assume this list is exact until local `git status` is checked.

Add this progress document under:

```text
docs/Scraptures_Session_Progress_Log_2026-09-08_Session_8.md
```

---

# Bugs Fixed During Session 8

## Guard Button Signal Was Miswired

The Guard gameplay logic was correct, but the UI button was connected incorrectly.

Runtime debugging proved that a Basic Attack action was being executed instead.

The `GuardButton.pressed()` signal was corrected to call:

```gdscript
_on_guard_button_pressed()
```

After fixing the signal, Guard correctly reduced incoming Basic Attack damage.

---

## Round State Temporarily Stuck in RESOLVING

During later Battle edits, Basic Attack temporarily worked only once.

The round-state reset flow / indentation at the bottom of `perform_round()` was corrected.

Expected surviving-round flow is:

```text
WAITING_FOR_PLAYER_ACTION
→ RESOLVING
→ round completes
→ WAITING_FOR_PLAYER_ACTION
```

Repeated actions now work again.

---

## Granted Move Selection Previously Fell Back to Index 0

One granted-move resolver branch still rediscovered:

```gdscript
granted_moves[0]
```

even after a specific `selected_move` had been supplied.

It was corrected so the exact selected `MoveDefinition` continues through round resolution.

---

# Known Limitations and Deferred Work

## Battle Still Uses the Temporary B Trigger

Current entry:

```text
B
→ start_test_battle()
```

Week 5 should replace this with one real overworld encounter trigger.

Do not build a large encounter-generation system.

---

## Battle Currently Uses the Starter Combatant

The party selector changes the selected Scrapture for loadout / equipment purposes.

The current test Battle still starts with the Starter runtime.

Party switching, multiple active combatants, and complex party battle selection are not required yet.

---

## Battle UI Is Functional, Not Polished

Deferred presentation includes:

```text
health bars
portraits / creature art
battle backgrounds
animations
audio
button styling
layout polish
transitions
```

These belong primarily to Week 6.

---

## Enemy AI Is Intentionally Simple

Current deterministic rule:

```text
above half Health
→ Basic Attack

at/below half Health
→ Guard
```

Do not build advanced AI unless the demo requires it.

---

## Capture Is Intentionally Deterministic

Current rule:

```text
enemy Health <= 30%
→ capture succeeds
```

Do not add capture probability, capture items, rarity modifiers, status modifiers, or complex formulas during the current demo scope.

---

## Player-Owned Health Persists

The Starter and captured Scraptures do not receive automatic healing.

A defeated Starter cannot currently start another test Battle.

A minimal recovery solution may eventually be required for the integrated demo, but do not create a large healing / consumable system.

---

## Save / Load Remains Deferred

Party, inventory, equipped modules, and Health are runtime-only.

Persistent save data is not required for the current milestone.

---

## Old Prototype Scrap Naming May Still Exist

Older names such as:

```text
ScrapLabel
GoalLabel
scrap_count
scrap_goal
scenes/scrap/
```

may still remain.

This is non-blocking cleanup.

Do not combine broad renaming with Week 5 encounter integration.

---

# Important Concepts Reinforced This Session

- Definition data and runtime state are different responsibilities.
- `MoveDefinition` is definition data; selected moves during Battle are runtime choices.
- Modules grant moves through data rather than Battle hardcoding module names.
- A `MoveKind` enum allows Battle to route different behaviors without checking display names.
- `selected_move` must remain the exact move chosen by the player through the resolver.
- Array indices are temporary UI-slot positions, not permanent move identities.
- Battle validates whether a requested move is actually available.
- Guard is a gameplay rule; a Guard button is only a UI request.
- Button `pressed()` is a Signal and must be connected to the correct callback.
- `BattleState` controls when actions are legal.
- Surviving rounds must return from `RESOLVING` to `WAITING_FOR_PLAYER_ACTION`.
- Capturing the enemy transfers ownership of the existing runtime object.
- Party ownership and current loadout selection are separate concepts.
- `Main` coordinates cross-system ownership and transitions.
- `Battle` owns combat and capture rules.
- `InventoryScreen` displays state and emits selection / equip requests.
- Minimal player-facing UI can be added without moving gameplay rules into UI code.

---

# Week 4 Final Status

- [x] Create module-granted move data.
- [x] Connect Engine to a granted move.
- [x] Connect Battery to a granted move.
- [x] Connect Armor Plate to a defensive granted move.
- [x] Resolve module moves through the Battle system.
- [x] Allow multiple granted moves to be selected.
- [x] Add predictable capture.
- [x] Add captured Scrapture to player ownership.
- [x] Show captured Scraptures in party / loadout flow.
- [x] Keep Attachment Capacity and existing module stats working.
- [x] Add minimal Battle action UI required to use the new systems.
- [x] Complete Week 4 regression testing.

**Week 4 is complete.**

---

# Next Session

## Roadmap Week

**Week 5 — Integration and Final Encounter**

Protect scope aggressively.

The goal is not to build a broad encounter framework.

The Week 5 purpose is to connect the systems already built into one playable demo path.

---

## Immediate Next Objective

Replace:

```text
B
→ start test battle
```

with **one real overworld Scrapture encounter trigger**.

First Week 5 acceptance test:

```text
Player explores overworld
→ Player enters one encounter trigger
→ Battle starts automatically
→ the existing Battle system receives the Starter and a fresh wild runtime
→ overworld input is disabled during Battle
```

Do not add the second wild species, final encounter, encounter randomization, map expansion, or encounter tables in the same step.

First prove one real encounter transition.

---

# Suggested Git Commit

Before committing:

```bash
git status
```

Review the changed files and make sure no accidental editor files or unrelated changes are included.

Then:

```bash
git add .
git commit -m "Complete Week 4 module moves and capture"
git push
```

Suggested commit message:

```text
Complete Week 4 module moves and capture
```

---

# Next Session Starting Point

1. Read this progress file.
2. Confirm the Week 4 commit exists on `main`.
3. Check `git status` and confirm the working tree is clean.
4. Run one quick regression: collect/equip a module, start Battle, use one module move, and confirm Battle still resolves.
5. Confirm capture still adds the wild runtime to the party.
6. Begin Week 5 with exactly one overworld encounter trigger.
7. Remove or bypass the `B` test trigger only after the real encounter trigger successfully starts the existing Battle.
8. Do not build the final encounter until the first overworld-to-Battle transition works.

---

# Suggested First Week 5 Commit

```text
Connect overworld encounter to battle
```
