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

- **Date:** August 31, 2026
- **Session number:** 7
- **Week 1:** Complete.
- **Week 2:** Core milestone complete.
- **Week 3:** Core milestone complete.
- **Next roadmap milestone:** Week 4 — Module-granted moves and predictable capture.
- **Git status:** Session 7 local changes still need to be verified with `git status`, committed, and pushed.

The project now proves this larger portion of the core loop:

```text
Explore
→ collect ModuleDefinitions
→ store them in ModuleInventory
→ equip modules on the Starter
→ enforce Attachment Capacity
→ recalculate final stats
→ manually start a test battle
→ carry the existing customized Starter runtime into Battle
→ create a fresh wild enemy runtime
→ choose Basic Attack or Guard
→ let simple enemy AI choose an action
→ resolve actions through one round resolver
→ use final Speed for Attack-vs-Attack turn order
→ apply damage / Guard reduction
→ update player-facing Health UI
→ detect defeat
→ show Victory / Defeat
→ return control to the overworld
→ preserve the Starter's remaining Health between battles
```

The battle still uses a temporary `B` key development trigger rather than a real overworld encounter.

---

# Week 3 — Minimal Turn-Based Battle

## Milestone Status

**Core Week 3 milestone complete.**

The project now has a playable one-versus-one turn-based battle foundation with:

- explicit player action selection;
- Basic Attack;
- Guard;
- simple deterministic enemy AI;
- Speed-based Attack-vs-Attack order;
- runtime Health and defeat handling;
- player-facing Health UI;
- player-facing Victory / Defeat feedback;
- battle-state validation;
- overworld input locking during battle;
- persistent Starter Health between battles;
- module-derived final Speed affecting battle order.

Do not begin large combat expansion, advanced AI, status effects, complex damage formulas, dodge, critical hits, or type charts.

Week 4 should remain focused on the demo roadmap: module-granted moves and a predictable capture mechanic.

---

# Session Goal

Finish the core Week 3 battle milestone without breaking the completed exploration, module inventory, equipment, Attachment Capacity, or final-stat systems.

This session focused on:

- connecting player Basic Attack input;
- implementing Guard;
- introducing explicit battle actions;
- adding simple enemy action selection;
- consolidating round resolution;
- preventing defeated Scraptures from acting;
- adding battle Health UI;
- adding Victory / Defeat UI;
- blocking overworld movement and Inventory use during battle;
- preventing an active battle from being restarted;
- managing Battle UI visibility;
- preserving Starter Health across battles;
- rejecting a new battle when the Starter is already defeated;
- validating the complete Week 3 flow.

---

# Features Completed This Session

## Player Basic Attack Input

Added a temporary Input Map action:

```text
battle_basic_attack
```

mapped to:

```text
A
```

`Main` forwards the input to Battle.

The Battle state itself determines whether the action is currently legal.

Current flow:

```text
press B
→ Battle initializes
→ WAITING_FOR_PLAYER_ACTION
→ press A
→ Basic Attack request
→ Battle validates state
→ one round resolves
```

---

## Guard Action

Added a temporary Input Map action:

```text
battle_guard
```

mapped to:

```text
G
```

Guard behavior for the current demo foundation:

```text
Player chooses Guard
→ Player does not attack
→ incoming Basic Attack damage is reduced
```

Current constants:

```gdscript
const BASIC_ATTACK_DAMAGE: int = 4
const GUARDED_DAMAGE: int = 2
```

Guard intentionally remains simple and deterministic.

---

## Basic Attack Damage Parameter

`perform_basic_attack()` was generalized so it can receive a damage value while still defaulting to normal Basic Attack damage.

Conceptually:

```gdscript
func perform_basic_attack(
    attacker: ScraptureRuntime,
    defender: ScraptureRuntime,
    damage: int = BASIC_ATTACK_DAMAGE
) -> void:
```

This allows the same attack/defeat logic to be reused for guarded damage instead of creating duplicate attack functions.

---

## BattleAction Enum

Added an explicit action type:

```gdscript
enum BattleAction {
    BASIC_ATTACK,
    GUARD
}
```

This is separate from `BattleState`.

Responsibility distinction:

```text
BattleState
→ what phase is the battle in?

BattleAction
→ what action did a Scrapture choose?
```

---

## Simple Enemy AI

Added an explicit enemy action decision function.

Current deterministic rule:

```text
Enemy above half Health
→ BASIC_ATTACK

Enemy at or below half Health
→ GUARD
```

This is intentionally simple.

No random AI, utility scoring, prediction, or advanced combat logic should be added during the current demo milestone.

---

## Single Round Resolver

Player and enemy actions now resolve through one central round function.

Conceptual flow:

```text
player action
→ validate battle state
→ RESOLVING
→ choose enemy action
→ resolve action combination
→ update UI
→ if battle did not end
→ WAITING_FOR_PLAYER_ACTION
```

The resolver handles the four current combinations:

```text
Player Attack + Enemy Attack
Player Attack + Enemy Guard
Player Guard  + Enemy Attack
Player Guard  + Enemy Guard
```

Attack-vs-Attack uses final Speed to determine order.

Attack-vs-Guard causes the guarding target to receive reduced damage.

Guard-vs-Guard causes no damage.

---

## Defeated Scrapture Cannot Act

During Attack-vs-Attack resolution, the second attack is skipped if the first attack already ended the battle.

Current rule:

```text
faster Scrapture attacks
→ defender reaches 0 HP
→ Battle becomes ENDED
→ defeated Scrapture does not attack afterward
```

This prevents a defeated runtime from taking a turn.

---

## Battle Lifecycle and State Validation

Battle continues to use:

```gdscript
enum BattleState {
    INACTIVE,
    WAITING_FOR_PLAYER_ACTION,
    RESOLVING,
    ENDED
}
```

Important round flow:

```text
WAITING_FOR_PLAYER_ACTION
→ player chooses action
→ RESOLVING
→ actions resolve
→ if nobody was defeated
→ WAITING_FOR_PLAYER_ACTION
```

Defeat flow:

```text
damage
→ ScraptureRuntime.is_defeated()
→ Battle.end_battle()
→ current_state = ENDED
```

After `ENDED`, further `A` / `G` inputs do not create additional rounds.

---

## Health UI

Added basic player-facing Health display under the Battle Scene.

Approximate structure:

```text
Battle (Node)
└── BattleUI (CanvasLayer)
    └── HealthDisplay (VBoxContainer)
        ├── PlayerHealthLabel (Label)
        ├── EnemyHealthLabel (Label)
        └── ResultLabel (Label)
```

The Health UI reads runtime state.

It does not calculate or own Health.

Displayed format resembles:

```text
Starter HP: 20 / 20
fast wild HP: 15 / 15
```

The labels refresh after each resolved round.

---

## Victory / Defeat UI

`ResultLabel` displays the battle result.

Current rule:

```text
enemy defeated
→ Victory!

player defeated
→ Defeat!
```

The battle rules decide the winner.

The UI only presents the result.

A new test battle clears the previous result text.

---

## Battle UI Visibility

`BattleUI` begins hidden.

Conceptual behavior:

```text
Battle._ready()
→ BattleUI hidden

Battle.initialize(...)
→ BattleUI shown
```

The result remains visible after battle end so the player can read `Victory!` or `Defeat!`.

The battle UI is not yet a polished or separate full battle screen.

---

## Battle End Signal

Added a custom signal:

```gdscript
signal battle_ended
```

`Battle` emits it when combat ends.

`Main` receives the signal and restores overworld control.

Responsibility split:

```text
Battle
→ announces that battle ended

Main
→ decides what that means for Player / overworld state
```

---

## Overworld Movement Disabled During Battle

When a test battle starts:

```gdscript
player.set_process_unhandled_input(false)
```

The Player's grid movement uses `_unhandled_input(event)`, so disabling unhandled-input processing prevents movement during combat.

When Battle emits `battle_ended`, `Main` re-enables Player unhandled input.

Confirmed flow:

```text
Overworld
→ movement works

Battle active
→ movement blocked

Battle ended
→ movement works again
```

---

## Inventory Blocked During Battle

The Inventory cannot be opened while Battle is active.

Battle exposes a helper resembling:

```gdscript
func is_active() -> bool:
    return (
        current_state != BattleState.INACTIVE
        and current_state != BattleState.ENDED
    )
```

`Main` uses this helper rather than manually checking Battle's individual internal states.

Current behavior:

```text
Overworld
→ I opens Inventory

Battle active
→ I does nothing

Battle ended
→ I works again
```

---

## Inventory Closes When Battle Starts

If the Inventory is already open when a test battle begins:

```text
Inventory open
→ press B
→ Inventory closes
→ Battle starts
→ Player remains unable to move
```

`Main` coordinates this transition.

Battle itself does not know about the InventoryScreen.

---

## Active Battle Cannot Be Restarted

The temporary `B` battle trigger can no longer reset a currently active battle.

Current rule:

```text
No battle active
→ B starts battle

Battle active
→ B does nothing

Battle ended
→ B may start a fresh test battle
```

This prevents the development trigger from bypassing the battle state machine.

---

## Persistent Starter Health

The Starter's runtime Health is intentionally preserved between battles.

Current rule:

```text
Battle 1
Starter ends at 8 / 20
→ Battle ends

Battle 2 starts
→ same Starter runtime
→ starts at 8 / 20
```

The Starter is not automatically healed when a new battle begins.

This is an intentional game-design rule.

Future healing must come from an explicit player-facing healing mechanic.

The wild enemy is different:

```text
enemy_scrapture
→ fresh runtime for each new encounter
```

while:

```text
starter_scrapture
→ persistent player-owned runtime
```

---

## Defeated Starter Cannot Start Another Battle

Because Health persists, a Starter at `0 HP` is prevented from entering another battle.

Current behavior:

```text
Starter HP > 0
→ battle may start

Starter HP = 0
→ battle start rejected
```

Temporary debug Output:

```text
Starter is defeated and cannot battle.
```

No automatic healing is performed.

---

## Module Integration With Battle

The existing Week 2 runtime is passed directly into Battle.

Battle uses:

```gdscript
get_final_speed()
```

for Attack-vs-Attack order.

Therefore:

```text
collect Engine
→ equip Engine
→ Starter final Speed increases
→ battle turn order can change
```

This proves that the customization system affects combat rather than existing only in the Inventory UI.

---

# Tests Passed

The following Week 3 behavior was confirmed during Session 7:

- [x] Player can explicitly choose Basic Attack.
- [x] Player can explicitly choose Guard.
- [x] Battle actions are accepted only while waiting for player input.
- [x] A single action request resolves exactly one round.
- [x] Basic Attack deals the intended normal damage.
- [x] Guard reduces incoming Basic Attack damage.
- [x] Guard-vs-Guard causes no damage.
- [x] Enemy AI explicitly chooses an action.
- [x] Enemy attacks above half Health.
- [x] Enemy Guards at or below half Health.
- [x] Attack-vs-Attack uses final Speed.
- [x] Attack-vs-Guard is resolved correctly.
- [x] Guard-vs-Attack is resolved correctly.
- [x] Guard-vs-Guard is resolved correctly.
- [x] A defeated Scrapture does not attack afterward.
- [x] Battle returns to `WAITING_FOR_PLAYER_ACTION` after a surviving round.
- [x] Battle remains `ENDED` after defeat.
- [x] Further battle actions are ignored after Battle ends.
- [x] Player Health appears in the Battle UI.
- [x] Enemy Health appears in the Battle UI.
- [x] Health UI refreshes after each round.
- [x] `0 HP` displays correctly.
- [x] Victory appears in the UI.
- [x] Defeat appears in the UI.
- [x] Battle UI is hidden before Battle begins.
- [x] Battle UI appears when Battle initializes.
- [x] Player movement is blocked during Battle.
- [x] Player movement resumes after Battle.
- [x] Inventory cannot be opened during Battle.
- [x] Inventory works normally again after Battle.
- [x] An already-open Inventory closes when Battle begins.
- [x] Pressing `B` during an active Battle does not restart/reset it.
- [x] Starter Health persists between Battles.
- [x] A fresh enemy runtime is created for a new test Battle.
- [x] A defeated Starter cannot begin another Battle.
- [x] Equipped modules persist across Battles.
- [x] Engine can change battle turn order through final Speed.
- [x] Existing exploration/module/inventory/loadout behavior remains intact.
- [x] Full Week 3 acceptance test passed.

---

# Week 3 Core Exit Criteria

- [x] Reusable Battle Scene exists.
- [x] Battle receives player/enemy runtime references.
- [x] Wild enemy runtime can be created for combat.
- [x] Player can choose Basic Attack.
- [x] Player can choose Guard.
- [x] Simple enemy action selection exists.
- [x] Speed determines Attack-vs-Attack turn order.
- [x] Damage modifies runtime Health.
- [x] Guard modifies incoming damage.
- [x] Defeat is detected.
- [x] Defeated combatants do not continue acting.
- [x] Battle has explicit state flow.
- [x] Invalid battle actions are rejected outside the waiting state.
- [x] Health is visible to the player.
- [x] Victory / Defeat is visible to the player.
- [x] Battle prevents overworld movement while active.
- [x] Battle prevents Inventory interaction while active.
- [x] Battle returns control to the overworld when finished.
- [x] Customized final Speed affects combat.
- [x] A complete one-versus-one battle can be played from start to finish.

**Week 3 core milestone is complete.**

---

# Files Changed During Session 7

Verify the exact list locally with:

```bash
git status
```

Expected changed/new files include at least:

```text
project.godot

scripts/main.gd

scripts/Battle/battle.gd
scenes/battle/battle.tscn
```

Depending on editor serialization, local naming, Input Map changes, or scene adjustments, Git may show additional `.tscn`, `.tres`, or `.uid` changes.

Do not assume this list is exact until `git status` is checked.

---

# Known Bugs, Limitations, and Deferred Work

## Battle Still Uses a Development Trigger

Battle currently begins through the temporary:

```text
B
```

test input.

This is not the final encounter system.

Real exploration-to-encounter integration belongs to later demo integration work.

---

## Battle Controls Are Temporary Keyboard Inputs

Current development controls:

```text
A → Basic Attack
G → Guard
B → Start test battle
```

These are functional development controls, not final player-facing battle UI.

Do not spend significant time polishing controls before the broader battle/capture loop is connected.

---

## Enemy AI Is Intentionally Simple

Current deterministic AI:

```text
above half Health
→ Basic Attack

at/below half Health
→ Guard
```

This is sufficient for the current demo foundation.

Do not build advanced AI.

---

## Basic Damage Is Intentionally Simple

Current damage values are deterministic:

```text
Basic Attack = 4
Guarded damage = 2
```

Do not introduce a large damage formula yet unless required by the Week 4 module-move implementation.

---

## Health Persists Between Battles

This is intentional.

The player-owned Starter does not receive free healing after combat.

No healing system currently exists.

Future healing should be implemented explicitly through a player-facing mechanic if/when required by the demo.

---

## Defeated Starter Is Currently Locked Out of Battle

At `0 HP`, the Starter cannot begin another battle.

This is correct under the current persistent-Health rule, but a future recovery/healing method will eventually be needed for a complete gameplay loop.

Do not build a large healing/item system now.

---

## Battle UI Is Functional, Not Polished

Current Battle UI is basic text presentation.

It does not yet include:

- health bars;
- portraits;
- battle backgrounds;
- animation;
- action buttons;
- sound;
- polished layout.

Presentation polish belongs primarily to Week 6 unless needed for readability.

---

## Capture Is Not Implemented

Capture is a Week 4 task.

Do not combine capture implementation with unrelated combat expansion.

---

## Module-Granted Moves Are Not Implemented

Engine, Battery, and Armor Plate still do not grant battle moves.

This is a Week 4 task.

---

## Future Combat Statistics Remain Deferred

Previously discussed future ideas include:

- Dodge / Evasion;
- Critical Strike Chance;
- potentially Critical Damage.

These remain deferred.

They are not required for the current demo milestone.

---

## Save / Load Is Still Deferred

Runtime inventory, Scrapture state, equipment, and Health remain session-only.

Persistent save data is not part of the current milestone.

---

## Old Prototype Scrap Naming May Still Remain

Older names may still exist, including names such as:

```text
ScrapLabel
GoalLabel
scrap_count
scrap_goal
scenes/scrap/
```

This remains non-blocking cleanup.

Do not combine broad renaming with Week 4 implementation.

---

# Important Concepts Reinforced This Session

- `BattleState` represents battle phase; `BattleAction` represents a chosen action.
- A guard clause can reject input when the battle is in the wrong state.
- `return` exits the current function call; it does not stop the game.
- Default function parameters allow one attack function to support normal and guarded damage.
- Gameplay state should be stored in runtime objects, not UI Labels.
- UI reads state; UI does not calculate or own combat Health.
- `ScraptureRuntime` owns safe Health mutation and defeat state.
- `Battle` owns combat sequencing and battle-result rules.
- `Main` coordinates systems such as Player, InventoryScreen, and Battle.
- Signals allow Battle to announce completion without knowing about the overworld Player.
- A plain `Node` is appropriate for Battle because Battle currently coordinates rules/state rather than requiring position or physics.
- `CanvasLayer` is appropriate for battle UI that should render independently of world positioning.
- `VBoxContainer` controls layout of its child UI elements.
- `@onready` references are resolved after child Nodes exist in the Scene Tree.
- `_ready()` is called by Godot when a Node enters the Scene Tree.
- `initialize()` is a project-defined function called explicitly by game code.
- Persistent player runtime state and fresh encounter runtime state are different responsibilities.
- The player's existing `ScraptureRuntime` should carry equipment, final stats, and remaining Health into future battles.
- Final Speed, rather than base Speed, must drive turn order so modules affect combat.
- A defeated Scrapture should not receive a later action in the same round.
- Battle logic should expose small queries such as `is_active()` instead of forcing external systems to understand internal state details.

---

# Week 3 Final Status

Current Week 3 roadmap items:

- [x] Create reusable Battle Scene.
- [x] Create player/enemy runtime battle references.
- [x] Create a temporary wild enemy definition/runtime.
- [x] Determine turn order using Speed.
- [x] Apply Basic Attack damage.
- [x] Detect defeat and end battle.
- [x] Implement battle state machine.
- [x] Connect player action selection.
- [x] Implement Guard.
- [x] Add simple enemy AI / action selection.
- [x] Add Health UI.
- [x] Reject invalid actions outside the waiting state.
- [x] Complete a full playable one-versus-one battle.
- [x] Validate module-modified Speed in combat.
- [x] Preserve player runtime Health between battles.

**Week 3 is complete.**

---

# Next Session

## Roadmap Week

**Week 4 — Module-Granted Moves and Capture**

Do not expand beyond Week 4 demo scope.

---

## Immediate Next Objective

Begin with one small, testable Week 4 feature.

Recommended first objective:

```text
Allow one equipped ModuleDefinition to grant one battle move.
```

Begin with the **Engine** module only.

Do not implement Engine, Battery, Armor Plate, capture, party joining, and a full move-selection UI all at once.

The first Week 4 acceptance test should prove only:

```text
Starter equips Engine
→ Battle can detect that Engine is equipped
→ Engine grants one specific move
→ that move can be selected or invoked in a controlled test
```

The exact move data shape and ownership should be decided before implementation.

Capture should follow after the module-granted move path is understood and stable.

---

# Suggested Git Commit

After verifying local changes:

```bash
git status
```

then:

```bash
git add .
git commit -m "Complete Week 3 turn-based battle"
git push
```

Suggested commit message:

```text
Complete Week 3 turn-based battle
```

---

# Next Session Starting Point

At the beginning of the next session:

1. Read this progress file.
2. Confirm the Week 3 commit exists on `main`.
3. Check `git status`.
4. Confirm the existing battle acceptance test still passes.
5. Start Week 4 with **one Engine-granted battle move only**.
6. Do not begin capture until that first module-move acceptance test passes.
