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
- **Session number:** 6
- **Week 1:** Complete.
- **Week 2:** Core milestone complete.
- **Week 3:** In progress — minimal one-versus-one battle foundation.
- **Current battle milestone:** Battle runtime state, Speed-based order, Basic Attack, damage, defeat detection, and manual test-battle start are working.
- **Git status:** Session 6 local changes still need to be verified with `git status`, committed, and pushed.

The project now proves this larger portion of the core loop:

```text
Explore
→ collect ModuleDefinitions
→ store them in ModuleInventory
→ equip modules on the Starter
→ recalculate final stats
→ manually start a test battle
→ pass the existing Starter runtime into Battle
→ create a wild enemy runtime
→ compare final Speed
→ apply Basic Attack damage
→ detect defeat
→ identify player victory / defeat
→ wait for the player's next battle action
```

The battle is still a development test flow. It is not yet a complete player-facing battle system.

---

# Week 3 — Minimal Turn-Based Battle

## Milestone Status

**Week 3 is in progress.**

The deterministic battle rules are now partially implemented and connected to the existing customized Starter runtime.

Still required before Week 3 is complete:

- player action input;
- Guard;
- simple enemy AI / legal action choice;
- health UI;
- complete turn-state flow that rejects invalid inputs during resolution;
- final battle readability and cleanup.

Do not start capture or module-granted moves yet.

---

## Session Goal

Begin the Week 3 battle system without breaking the completed exploration, inventory, equipment, Attachment Capacity, or final-stat systems.

This session focused on:

- creating a reusable `Battle` Scene;
- giving Battle typed references to two `ScraptureRuntime` objects;
- creating a temporary wild enemy definition/runtime;
- using final Speed for turn order;
- implementing deterministic Basic Attack damage;
- adding safe runtime damage handling;
- detecting defeat;
- ending the battle and distinguishing victory from defeat;
- adding a basic battle-state enum;
- manually starting battles after exploration so equipped modules affect battle rules.

---

# Features Completed This Session

## Battle Scene

Created:

```text
res://scenes/battle/battle.tscn
```

Current root:

```text
Battle (Node)
```

Attached script:

```text
res://scripts/battle/battle.gd
```

`Battle` is a plain `Node` because it currently coordinates gameplay rules/state and does not need position, drawing, or physics behavior.

The Battle Scene is instanced under `Main`.

---

## Typed Battle Runtime References

`battle.gd` contains typed references:

```gdscript
var player_scrapture: ScraptureRuntime
var enemy_scrapture: ScraptureRuntime
```

Battle receives existing runtime objects rather than rebuilding the player's Starter from definition data.

This is important because the player's equipped modules and final stats must carry into battle.

---

## Explicit Battle Initialization

Added an explicit initializer:

```gdscript
func initialize(
    player: ScraptureRuntime,
    enemy: ScraptureRuntime
) -> void:
    player_scrapture = player
    enemy_scrapture = enemy
    current_state = BattleState.WAITING_FOR_PLAYER_ACTION
```

Battle does not use `_ready()` to invent its combatants.

The caller supplies the two runtime references.

---

## Fast Wild Enemy Definition and Runtime

Created a temporary wild Scrapture definition:

```text
res://resources/scraptures/fast_wild_scrapture.tres
```

Temporary values used during testing:

```text
Display Name: fast wild
Base Max Health: 15
Base Speed: 8
Attachment Capacity: 2
```

`Main` creates a fresh `ScraptureRuntime` from this definition when starting the test battle.

The enemy runtime is recreated for each test battle so it begins with full Health.

---

## Speed-Based Turn Order

Added:

```gdscript
func get_first_scrapture() -> ScraptureRuntime:
    if player_scrapture.get_final_speed() >= enemy_scrapture.get_final_speed():
        return player_scrapture

    return enemy_scrapture
```

Important rule:

```text
turn order uses get_final_speed()
not definition.base_speed
```

Therefore equipped modules can affect turn order.

The current deterministic tie rule is:

```text
equal Speed
→ player acts first
```

because the comparison uses `>=`.

---

## Engine Integration With Battle Speed

The battle was changed so it no longer starts automatically when the game launches.

A temporary `test_battle` Input Map action was added and mapped to the `B` key.

Current test flow:

```text
launch game
→ explore
→ collect Engine
→ open Inventory
→ equip Engine
→ close Inventory
→ press B
→ Battle receives the same Starter runtime
→ final Speed includes Engine bonus
→ turn order reflects the equipped build
```

This proves that the Week 2 customization system feeds into Week 3 battle rules.

---

## Safe Runtime Damage

`ScraptureRuntime` now owns safe Health modification:

```gdscript
func take_damage(amount: int) -> void:
    if amount <= 0:
        return

    current_health = max(current_health - amount, 0)
```

Important responsibility split:

```text
Battle
→ decides how much damage happens

ScraptureRuntime
→ safely applies damage to current Health
```

Health is clamped at `0`.

---

## Defeat Detection

Added:

```gdscript
func is_defeated() -> bool:
    return current_health <= 0
```

This keeps the rule for whether a runtime Scrapture is defeated inside `ScraptureRuntime`.

Battle decides what defeat means for battle flow.

---

## Basic Attack

Added a deterministic temporary damage value:

```gdscript
const BASIC_ATTACK_DAMAGE: int = 4
```

and a Basic Attack function that:

```text
receives attacker + defender
→ applies damage
→ prints damage / remaining HP
→ checks defeat
→ ends the battle if needed
```

The fixed value of `4` is intentionally simple for the current deterministic foundation.

A more advanced damage formula is deferred.

---

## Battle End and Result

Added battle-end logic that receives the defeated runtime.

Current result rule:

```text
enemy defeated
→ Player won the battle.

player defeated
→ Player lost the battle.
```

Battle end sets the battle state to `ENDED`.

---

## Battle State Enum

The earlier simple active boolean was replaced with:

```gdscript
enum BattleState {
    INACTIVE,
    WAITING_FOR_PLAYER_ACTION,
    RESOLVING,
    ENDED
}
```

Current state variable:

```gdscript
var current_state: BattleState = BattleState.INACTIVE
```

Current intended flow:

```text
INACTIVE
→ initialize()
→ WAITING_FOR_PLAYER_ACTION
→ player chooses an action
→ RESOLVING
→ actions finish
→ WAITING_FOR_PLAYER_ACTION

or

RESOLVING
→ a Scrapture is defeated
→ ENDED
```

This is the first real state-machine foundation for Week 3.

---

## Basic Attack Round

Added:

```gdscript
func perform_basic_attack_round() -> void:
```

Current behavior:

```text
battle must be WAITING_FOR_PLAYER_ACTION
→ state becomes RESOLVING
→ get_first_scrapture() decides Speed order
→ faster Scrapture uses Basic Attack
→ slower Scrapture uses Basic Attack if battle has not ended
→ if nobody is defeated, return to WAITING_FOR_PLAYER_ACTION
```

The function currently assumes both sides use Basic Attack.

It is a rules scaffold, not the final action-selection system.

---

## Manual Test-Battle Start

`Main` no longer automatically starts Battle during `_ready()`.

A temporary test helper now creates the enemy and initializes Battle only when requested.

Approximate flow:

```gdscript
func start_test_battle() -> void:
    create_enemy_scrapture()
    battle.initialize(starter_scrapture, enemy_scrapture)
```

This allows the player to move, collect modules, and change the Starter before entering the test battle.

The `B` key is temporary development input. It is not the final overworld encounter system.

---

## Waiting for Player Action

Battle initialization now stops at:

```gdscript
current_state = BattleState.WAITING_FOR_PLAYER_ACTION
```

with a temporary debug print:

```text
Waiting for player action.
```

No attack should happen automatically when `B` starts a battle.

This is the correct stopping point for the next session.

---

# Tests Passed

The following behavior was confirmed during Session 6:

- [x] `Battle.tscn` exists and runs without parser errors.
- [x] Battle holds typed player/enemy `ScraptureRuntime` references.
- [x] Battle initializes with `Starter` and `fast wild`.
- [x] A missing enemy-runtime bug was diagnosed and fixed by creating the enemy before initialization.
- [x] The Fast Wild `display_name` was assigned correctly after an empty-name test.
- [x] Starter base Speed `5` vs Fast Wild Speed `8` makes Fast Wild act first.
- [x] `take_damage()` reduces Health correctly and clamps at `0`.
- [x] `is_defeated()` reports defeat at `0 HP`.
- [x] Four Basic Attacks of `4` damage reduce Fast Wild from `15` to `0`.
- [x] Battle stops accepting further Basic Attack damage after it has ended.
- [x] Enemy defeat reports player victory.
- [x] Player defeat reports player loss.
- [x] `perform_basic_attack_round()` resolves attacks in Speed order.
- [x] Battle no longer needs to start automatically in `_ready()`.
- [x] Pressing `B` starts a fresh test battle after exploration.
- [x] Without Engine, Fast Wild acts first.
- [x] After collecting/equipping Engine, the Starter's final Speed can change battle order.
- [x] Starting Battle now stops in `WAITING_FOR_PLAYER_ACTION`.
- [x] Starting Battle does not automatically damage either Scrapture.
- [x] Existing exploration/module/inventory behavior remains usable before starting the test battle.
- [x] No blocking parser/runtime errors were reported after the final cleanup.

---

# Files Changed During Session 6

Verify the exact list locally with:

```bash
git status
```

Expected changed/new files include:

```text
project.godot

scenes/main.tscn
scripts/main.gd

scenes/battle/battle.tscn
scripts/battle/battle.gd

resources/scraptures/fast_wild_scrapture.tres
scripts/scraptures/scrapture_runtime.gd
```

Depending on editor serialization or local adjustments, Git may show additional `.tscn` / `.tres` changes.

Do not assume this list is exact until `git status` is checked.

---

# Known Bugs, Limitations, and Deferred Work

## Battle is still debug-driven

The battle currently uses Output prints rather than a player-facing battle UI.

This is expected at this stage.

Health UI is still required for Week 3.

---

## Player action input is not connected yet

Battle can enter:

```gdscript
BattleState.WAITING_FOR_PLAYER_ACTION
```

but there is not yet an input/action request that tells Battle:

```text
Player chose Basic Attack.
```

This is the immediate next step.

---

## `perform_basic_attack_round()` still assumes both sides choose Basic Attack

There is no real enemy action selection yet.

Simple enemy AI is still required during Week 3.

Do not build complex AI.

---

## Guard is not implemented

Week 3 still requires a minimal Guard action.

Do not add advanced defensive/status systems.

---

## No battle health UI yet

Health changes are currently verified through debug Output.

A simple health display belongs later in Week 3 after the core action/state flow is stable.

---

## `B` is temporary development input

`test_battle` / `B` exists only to test Battle after exploration and equipment changes.

Do not treat it as the final encounter system.

Real overworld encounters belong to later integration work.

---

## Basic Attack damage is intentionally fixed

Current value:

```gdscript
const BASIC_ATTACK_DAMAGE: int = 4
```

Do not replace it with a large combat formula yet.

The immediate priority is correct action/state flow.

---

## Future combat statistics requested but deferred

Future combat design should include statistics for:

- Dodge / Evasion;
- Critical Strike Chance;
- potentially Critical Damage if it proves useful.

Modules may eventually modify these values.

These are explicitly deferred until the deterministic Week 3 battle foundation is complete. Do not implement them in the next step.

---

## Runtime state still resets between launches

`ModuleInventory` and `ScraptureRuntime` remain session-only runtime objects.

Save/load remains deferred.

---

## Module-granted moves remain deferred

Engine/Battery/Armor-granted moves are not implemented yet.

They remain a Week 4 task.

---

## Old prototype Scrap naming remains

Older names may still exist, including:

```text
ScrapLabel
GoalLabel
scrap_count
scrap_goal
scenes/scrap/
```

This is non-blocking cleanup.

Do not combine broad naming cleanup with battle implementation.

---

# Important Concepts Reinforced This Session

- A Scene definition and a Node instance are different.
- `Battle.tscn` is a reusable Scene; the `Battle` Node under `Main` is an instance.
- `@onready` resolves a Node reference after the Scene Tree is ready.
- Definition data and runtime state remain separate.
- A wild `.tres` Resource is definition data; `enemy_scrapture` is changing runtime state.
- Explicit `initialize()` functions are useful when runtime data must be passed into an object.
- Battle should consume the existing customized Starter runtime rather than recreating it.
- `get_final_speed()` should be used for gameplay decisions affected by modules.
- Two variables can reference the same runtime object.
- `return` can be used as a guard clause to stop invalid actions early.
- A runtime object should own safe mutation of its own Health.
- Battle should own battle sequencing and win/loss rules.
- `enum` provides readable names for a finite set of states.
- A state machine prevents actions from being accepted at invalid times.
- Test code such as repeated attack loops should be removed after acceptance tests pass.
- Debug prints show state; they do not create the state itself.
- Input events are useful for temporary development triggers without putting battle logic in frame callbacks.

---

# Week 3 Progress

Current Week 3 roadmap items:

- [x] Create reusable Battle Scene.
- [x] Create player/enemy runtime battle references.
- [x] Create a temporary wild enemy definition/runtime.
- [x] Determine turn order using Speed.
- [x] Apply Basic Attack damage.
- [x] Detect defeat and end battle.
- [x] Begin battle state machine.
- [ ] Connect player action selection.
- [ ] Implement Guard.
- [ ] Add simple enemy AI / action selection.
- [ ] Add health UI.
- [ ] Ensure invalid actions are rejected during resolution/enemy action.
- [ ] Complete a full playable one-versus-one battle.

**Week 3 is not complete. Do not begin Week 4 yet.**

---

# Next Session

## Roadmap Week

**Week 3 — Minimal Turn-Based Battle**

Continue Week 3 only.

---

## Immediate Gameplay Goal

Connect one temporary player input to the existing battle state so the player can explicitly choose **Basic Attack** while Battle is waiting.

The intended flow is:

```text
press B
→ Battle starts
→ WAITING_FOR_PLAYER_ACTION
→ player presses temporary Basic Attack input
→ Battle accepts the action only while waiting
→ state becomes RESOLVING
→ Basic Attack round resolves by Speed
→ if nobody is defeated
→ WAITING_FOR_PLAYER_ACTION
```

This is the next step because the battle rules already exist, but the state machine does not yet receive a real player action request.

---

## Exact Next Step

Add one temporary Input Map action for choosing Basic Attack during the test battle.

Do not add Guard, battle UI, enemy AI complexity, capture, or module-granted moves in the same step.

The action should call the existing:

```gdscript
perform_basic_attack_round()
```

only when Battle is in:

```gdscript
BattleState.WAITING_FOR_PLAYER_ACTION
```

### Acceptance Test

- [ ] Launch the game.
- [ ] Explore and optionally equip modules.
- [ ] Press `B` to start the test battle.
- [ ] Output shows `Waiting for player action.`
- [ ] No damage happens until the Basic Attack input is pressed.
- [ ] Press the temporary Basic Attack input once.
- [ ] Exactly one round resolves.
- [ ] Speed determines which Scrapture attacks first.
- [ ] If both survive, Battle returns to `WAITING_FOR_PLAYER_ACTION`.
- [ ] Pressing the action while Battle is not waiting does not create an extra round.
- [ ] Existing overworld/inventory behavior remains intact.
- [ ] Godot reports zero parser/runtime errors.

After this passes, add only the next smallest piece of the turn/action flow.

---

# Session Handoff

### Session

- **Date:** August 26, 2026
- **Session number:** 6
- **Roadmap week:** Week 3 in progress
- **Session type:** Build / integration
- **Session goal:** Create the deterministic battle foundation and prove that the customized Starter runtime feeds into Speed-based combat.

### Files changed

Expected:

```text
project.godot
scenes/main.tscn
scripts/main.gd
scenes/battle/battle.tscn
scripts/battle/battle.gd
resources/scraptures/fast_wild_scrapture.tres
scripts/scraptures/scrapture_runtime.gd
```

Verify with `git status`.

### Features completed

- Battle Scene shell.
- Typed player/enemy runtime references.
- Explicit battle initialization.
- Fast Wild definition/runtime.
- Final-Speed turn order.
- Safe damage application.
- Basic Attack.
- Defeat detection.
- Player victory / loss result.
- Battle state enum.
- Basic Attack round sequencing.
- Temporary manual `B` test-battle start.
- Engine-to-battle Speed integration.
- Waiting-for-player-action state.

### Tests passed

- Battle initializes correctly.
- Fast Wild is faster than unmodified Starter.
- Engine can change the Starter's battle order.
- Damage reaches but does not pass below `0`.
- Defeat ends Battle.
- Extra attack after battle end does nothing.
- Victory and defeat are distinguished.
- Speed orders Basic Attack rounds.
- Battle can start after exploration instead of at game launch.
- Battle waits without automatically dealing damage.
- No blocking errors reported.

### Known bugs / limitations

- No player-facing battle UI.
- No player Basic Attack input yet.
- No Guard.
- No simple enemy AI yet.
- No health UI.
- `B` is temporary development input.
- Basic Attack still uses fixed damage.
- Dodge/Evasion and Critical Strike are deferred future combat stats.
- Module-granted moves and capture remain deferred to Week 4.
- Runtime save/load remains deferred.
- Exact Git diff still needs local verification.

### Exact next step

Connect one temporary **Basic Attack** player input to `perform_basic_attack_round()` while the Battle state is `WAITING_FOR_PLAYER_ACTION`.

### Suggested Git commit message

```text
Add Week 3 battle foundation and state flow
```

### Suggested progress-log commit message

```text
Update progress log for battle foundation
```

---

# Before Pushing to GitHub

Run:

```bash
git status
```

Review the changed files and make sure no temporary repeated-attack test loops remain.

Run one final test:

```text
launch
→ move normally
→ collect Engine
→ open Inventory
→ equip Engine
→ close Inventory
→ press B
→ Battle starts
→ Waiting for player action.
→ no automatic damage
```

Then commit and push the working Session 6 checkpoint.

---

# Rules for the Next Assistant

- Read this file first.
- State that Week 3 is in progress.
- Preserve the completed Week 1 and Week 2 systems.
- Do not recreate the Starter from definition data when Battle begins.
- Continue using the existing customized `ScraptureRuntime`.
- Start with only one temporary player Basic Attack input.
- Keep Battle rules separate from UI and animation.
- Keep the state machine understandable and deterministic.
- Test one state transition/action at a time.
- Do not implement Guard in the same first step.
- Do not implement capture until Week 4.
- Do not implement module-granted moves until Week 4.
- Do not implement Dodge/Evasion or Critical Strike yet; keep them as deferred combat design requirements.
- Do not add save/load.
- Do not expand the creature roster.
- Update this progress log at the end of the next session.
