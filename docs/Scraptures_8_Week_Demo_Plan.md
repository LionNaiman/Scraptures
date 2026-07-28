# Scraptures — 8-Week Vertical Slice Demo Plan

**Studio:** Wiremane  
**Engine:** Godot 4.x, latest stable release  
**Language:** Typed GDScript  
**Primary tools:** Godot Editor, Cursor, Git, GitHub  
**Target:** A polished, playable demo by **September 28, 2026**  
**Developer context:** Solo developer, first Godot/GDScript/Cursor project, with two completed years of Computer Science studies.

---

## 1. Product Vision

**Scraptures** is a turn-based, grid-based monster-catching RPG set in a recovered post-apocalyptic world.

Humans now live in relative harmony with robotic creatures called **Scraptures**. The player explores the world, encounters and captures Scraptures, finds mechanical scrap modules, and attaches those modules to customize each Scrapture's stats and abilities.

Examples:

- An **Engine Module** may add `+20 Speed` and unlock a movement- or impact-based attack.
- A **High-Capacity Battery** may add electrical affinity and unlock an electric attack.
- An **Armor Plate** may increase maximum health and unlock a defensive action.

Each Scrapture has a fixed **Attachment Capacity**. Modules consume capacity points, so the player must make meaningful build choices rather than equipping everything.

The visual direction is inspired by the clarity and readability of classic Pokémon-style RPGs, combined with a salvaged science-fantasy atmosphere somewhere between Pokémon and Star Wars. The final art direction must remain original and must not copy protected characters, environments, or UI.

---

## 2. The Core Player Fantasy

> Find robotic creatures, capture them, rebuild them with scavenged parts, and use your custom machines in tactical turn-based battles.

The demo must prove this fantasy through a complete loop:

```text
Explore a small area
↓
Find scrap modules
↓
Encounter a wild Scrapture
↓
Fight and capture it
↓
Attach a module
↓
The module changes stats and grants a move
↓
Use the upgraded Scrapture in another battle
↓
Complete the demo objective
```

Everything in the eight-week plan must support this loop.

---

## 3. Strict Demo Scope

The two-month target is a **vertical slice**, not a full game.

### Included in the demo

- One small overworld area.
- Grid-based player movement.
- Basic obstacles and collision.
- Interactable scrap/module pickups.
- One starter Scrapture.
- Two wild Scrapture species.
- One-versus-one turn-based battles.
- Health, speed, basic damage, and turn order.
- A small move set.
- A capture mechanic.
- Three module types:
  - Engine
  - Battery
  - Armor Plate
- Attachment Capacity and module costs.
- Module-granted stat bonuses.
- Module-granted moves.
- A simple party/loadout screen.
- One final battle or objective that proves the upgraded build matters.
- Basic menus, feedback, audio, and exportable builds.

### Explicitly excluded from the demo

- Open world.
- Large story campaign.
- More than one small area unless all core milestones are finished early.
- Online multiplayer.
- Breeding.
- Evolution trees.
- Procedural generation.
- Complex elemental type charts.
- Large inventories.
- Dozens of Scraptures or modules.
- Full visual modular assembly on every body part.
- Advanced status-effect systems.
- Complex quest systems.
- Voice acting.
- Platform ports beyond desktop.

These are future-game features, not demo requirements.

---

## 4. Demo Content Target

### Scraptures

Use only three combat-ready Scraptures:

1. **Starter Scrapture** — balanced, Attachment Capacity `3`.
2. **Fast Wild Scrapture** — higher Speed, lower Health, Attachment Capacity `2`.
3. **Heavy Wild Scrapture** — higher Health, lower Speed, Attachment Capacity `4`.

Names and final designs can be decided later. Placeholder names are acceptable during implementation.

### Modules

Use only three module families:

| Module | Capacity Cost | Stat Effect | Granted Move |
|---|---:|---|---|
| Engine | 2 | `+20 Speed` | Ram / Overdrive attack |
| Battery | 2 | Electric affinity or energy bonus | Electric attack |
| Armor Plate | 1 | `+20 Max HP` | Guard / Brace |

The exact values will be tuned after the systems work.

### Battle moves

Keep the first move set small:

- Basic Attack
- Guard
- Engine move
- Battery move
- Capture action

### Demo objective

A suitable first objective:

> Capture one wild Scrapture, equip at least one module, and defeat a stronger gatekeeper Scrapture.

This demonstrates exploration, collection, capture, customization, and combat.

---

## 5. Current Project Baseline

Already completed:

- Godot project and folder structure.
- Cursor connected to the correct project root.
- Main scene.
- Reusable Player scene.
- Grid-based movement.
- Visual grid.
- Movement boundaries.
- Reusable Scrap pickup scene.
- Player and Scrap collisions.
- Scrap collection through `body_entered`.
- Custom `collected` signal.
- Scrap group lookup.
- Basic scrap count and Label UI.
- Basic Git/GitHub workflow discussed.

This work is useful as a learning prototype. Some parts will now be refactored so that "scrap" means real equipment modules rather than a generic score.

---

## 6. Technical Direction

### Design principles

- Use typed GDScript.
- Prefer composition and small scenes over deep inheritance.
- Use signals for communication between gameplay systems and UI.
- Store reusable game data in custom `Resource` classes.
- Keep runtime state separate from immutable definition data.
- Build one complete feature at a time.
- Never add a system without a demo requirement.

### Planned data model

#### `ScraptureDefinition` Resource

Stores permanent species data:

- Display name
- Base max health
- Base speed
- Base attack
- Attachment Capacity
- Base move list
- Visual references

#### `ModuleDefinition` Resource

Stores module data:

- Display name
- Capacity cost
- Stat modifiers
- Granted move
- Module category
- Icon

#### `MoveDefinition` Resource

Stores move data:

- Display name
- Power
- Accuracy, only if needed
- Energy cost, only if needed
- Move category
- Basic effect identifier

#### Runtime Scrapture state

Stores values that change during play:

- Current health
- Equipped modules
- Learned/available moves
- Capture ownership

Do not place runtime health directly inside a shared Resource asset, because multiple instances could accidentally share the same changing data.

### Planned high-level scenes

```text
scenes/
├── world/
│   └── demo_world.tscn
├── player/
│   └── player.tscn
├── pickups/
│   └── module_pickup.tscn
├── scraptures/
│   └── scrapture_actor.tscn
├── battle/
│   └── battle_scene.tscn
└── ui/
    ├── overworld_hud.tscn
    ├── battle_ui.tscn
    └── loadout_ui.tscn
```

### Planned script/data folders

```text
scripts/
├── world/
├── player/
├── pickups/
├── battle/
├── scraptures/
├── inventory/
└── ui/

resources/
├── scraptures/
├── modules/
└── moves/
```

This structure is a direction, not a demand to create every file immediately.

---

## 7. Eight-Week Roadmap

## Week 1 — Convert the Prototype into a Real Module Pickup System

### Goal

Replace the generic Scrap counter with actual module data.

### Tasks

- Verify GitHub repository and create a clean checkpoint commit.
- Keep the existing grid movement and pickup interaction.
- Create `ModuleDefinition` as a custom Resource.
- Create Engine, Battery, and Armor Plate Resource assets.
- Rename/refactor the existing Scrap pickup into `ModulePickup`.
- Make a pickup emit which module was collected.
- Create a very small `ModuleInventory` that stores collected modules.
- Update HUD to show collected module names or counts.

### Educational focus

- `class_name`
- Custom Resources
- Typed arrays
- Signals with parameters
- Runtime object versus data asset

### Cursor delegation

Cursor may handle:

- Mechanical folder/file renames.
- Repetitive creation of similar Resource files after the first one is written manually.
- Updating references after renames.

The developer should manually write and understand the first Resource and first signal-with-parameter flow.

### Exit criteria

- Walking over an Engine pickup adds an Engine module to inventory.
- The pickup disappears.
- The HUD proves the correct module was collected.
- Battery and Armor Plate work through the same reusable scene.

---

## Week 2 — Scrapture Data and Loadout Customization

### Goal

Represent a Scrapture and attach collected modules to it.

### Tasks

- Create `ScraptureDefinition` Resource.
- Create one starter definition.
- Create runtime Scrapture state.
- Add Attachment Capacity.
- Create a simple loadout screen.
- Equip and unequip modules.
- Reject a module when capacity would be exceeded.
- Calculate final stats from base stats plus equipped modules.
- Show before/after stats in the UI.

### Educational focus

- Resource composition
- Arrays of custom types
- Pure calculation functions
- Separation between UI and data
- Validation and guard clauses

### Cursor delegation

Cursor may generate:

- Repetitive Label bindings.
- Basic menu layout boilerplate.
- Helper functions after their contracts are designed together.

The developer should manually write capacity validation and final-stat calculation.

### Exit criteria

- The player can equip Engine, Battery, and Armor Plate.
- Capacity limits work.
- Engine visibly increases Speed.
- Armor Plate visibly increases Max HP.
- Battery grants an electric move in the displayed move list.

---

## Week 3 — Minimal Turn-Based Battle

### Goal

Complete a functional one-versus-one battle without capture yet.

### Tasks

- Create `BattleScene`.
- Spawn player and enemy Scrapture runtime states.
- Create `MoveDefinition` Resource.
- Implement Basic Attack and Guard.
- Determine turn order using Speed.
- Apply damage.
- Update health UI.
- Add a simple enemy AI that chooses a legal move.
- End battle on defeat.

### Educational focus

- State machines
- Turn sequencing
- Deterministic logic
- Signals between battle logic and UI
- Awaiting animations without coupling rules to visuals

### Cursor delegation

Cursor may create:

- Boilerplate UI signal hookups.
- Repetitive button creation.
- Test data assets after the first example.

The developer should manually understand and write the turn state transitions.

### Exit criteria

- A complete battle can start, alternate turns, and end.
- Speed determines order.
- Damage and Guard produce visible results.
- The battle cannot accept actions during the enemy turn.

---

## Week 4 — Module-Granted Moves and Capture

### Goal

Prove that attachments change battle behavior and allow one wild Scrapture to be captured.

### Tasks

- Add Engine move.
- Add Battery electric move.
- Add Armor defensive move.
- Build the available move list from base moves plus equipped modules.
- Create a capture action.
- Use a simple capture rule for the demo.
- Add captured Scrapture to the player's party.
- Prevent capturing an already-owned or defeated invalid target.

### Recommended demo capture rule

Use a clear, predictable rule first:

> Capture succeeds when the wild Scrapture is at or below 30% health.

Random capture chance can be added later if time remains. Predictability is easier to test and teach.

### Exit criteria

- Equipping a Battery makes an electric move appear in battle.
- Removing it removes the move.
- A weakened wild Scrapture can be captured.
- The captured Scrapture appears in the party/loadout UI.

---

## Week 5 — Overworld Encounters and Complete Gameplay Loop

### Goal

Connect exploration, pickups, battle, capture, and customization.

### Tasks

- Build one small polished overworld map.
- Add obstacles and interactable objects.
- Add one or two visible wild encounter actors.
- Enter battle from the overworld.
- Return to the overworld after battle.
- Preserve inventory and party state.
- Add a repair/heal station or automatic post-battle healing, whichever is simpler.
- Add the final gatekeeper encounter.

### Educational focus

- Scene transitions
- Persistent session state
- Autoload only when justified
- Passing data between scenes
- Ownership of game state

### Exit criteria

The entire core loop works without manually launching separate test scenes.

---

## Week 6 — UX, Feedback, and Visual Identity

### Goal

Make the demo understandable and pleasant without relying on debug output.

### Tasks

- Replace debug prints with player-facing feedback.
- Improve battle menu flow.
- Add hover/focus states.
- Add simple movement and hit animations.
- Add pickup feedback.
- Add module icons.
- Add readable health bars and capacity display.
- Establish a consistent UI theme.
- Add placeholder or licensed music and sound effects.
- Add a title screen and restart/quit flow.

### Exit criteria

A new player can understand what to do without developer explanation.

---

## Week 7 — Content Lock, Testing, and Bug Fixing

### Goal

Stop adding systems and make the slice reliable.

### Tasks

- Lock feature scope.
- Play through the demo repeatedly.
- Test edge cases:
  - Full capacity
  - Empty inventory
  - Duplicate modules
  - Battle defeat
  - Capture failure conditions
  - Scene transitions
- Add lightweight save/load only if the core demo is already stable.
- Tune health, speed, power, and module values.
- Ask external testers to play.
- Record issues in a prioritized bug list.

### Priority order

1. Crashes and soft locks
2. Broken progression
3. Incorrect battle logic
4. Confusing UI
5. Visual polish

### Exit criteria

The demo can be completed from start to finish repeatedly without intervention.

---

## Week 8 — Release Candidate and Demo Packaging

### Goal

Prepare a public-facing demo build.

### Tasks

- Fix only release-blocking bugs.
- Export Windows build first.
- Add an Itch.io-ready package.
- Create a concise game description.
- Capture screenshots and a short gameplay clip.
- Add credits and license notes for all third-party assets.
- Verify controls and minimum instructions.
- Tag the release in Git.
- Upload the demo privately for final verification, then publish.

### Exit criteria

- A downloadable build launches on a clean machine.
- The full loop is playable.
- No placeholder debug text is visible.
- Credits are complete.
- The project repository has a final release tag.

---

## 8. Weekly Work Rhythm

Use three session types.

### Build session

- Implement one small feature.
- Keep the session focused on a single testable outcome.

### Integration session

- Connect the new feature to existing systems.
- Remove duplicate or temporary code.

### Review session

- Play the current build.
- Fix the highest-priority issue.
- Update documentation and Git.

A realistic weekly rhythm is three to five focused sessions. Do not compensate for missed sessions by adding scope.

---

## 9. Standard Session Protocol

At the beginning of every work session:

1. Read this plan.
2. Read the current progress log.
3. State the current week and milestone.
4. List what is already complete.
5. Choose one session goal that can be tested today.
6. Explain why that goal is next.
7. Implement it in small steps.

During implementation:

- Explain each new Godot concept before using it.
- Explain GDScript syntax, types, return values, and control flow.
- Ask the developer to predict small code outcomes when useful.
- The developer writes the important learning code.
- Cursor handles repetitive boilerplate only after the design is understood.
- Test after every meaningful step.

At the end of every session:

1. Run the project.
2. Record what works.
3. Record current bugs.
4. Record the exact next step.
5. Commit working changes.
6. Update the progress log.

---

## 10. Cursor Usage Rules

Cursor is a productivity tool, not the system designer.

### Good Cursor tasks

- Rename files and update references.
- Generate repeated Resource assets from an established pattern.
- Add repetitive typed getters/setters.
- Create basic UI binding boilerplate.
- Write test helpers.
- Explain compiler errors.
- Search the project for references.
- Refactor duplicated code after tests exist.

### Tasks that should be learned manually

- Scene ownership.
- Signals and their flow.
- Resource design.
- Turn state machines.
- Capacity validation.
- Damage calculation.
- Scene transitions and persistent state.
- Any code that defines the game's core rules.

### Recommended Cursor request format

```text
Context: [file and feature]
Goal: [one precise outcome]
Constraints:
- Godot 4.x
- Typed GDScript
- Do not redesign unrelated systems
- Preserve existing public function names
- Explain every changed file
- Show a diff before applying large changes
Acceptance test: [exact behavior that must work]
```

---

## 11. Definition of Done for the Demo

The demo is complete when a player can:

1. Launch the game from a title screen.
2. Move through a small overworld area.
3. Collect at least two different modules.
4. View one starter Scrapture.
5. Equip a module within Attachment Capacity.
6. See stats and moves change.
7. Enter a one-versus-one battle.
8. Use a module-granted move.
9. Weaken and capture a wild Scrapture.
10. Configure the captured Scrapture.
11. Defeat the final encounter.
12. Reach a clear end-of-demo screen.

The build must also:

- Avoid crashes and soft locks during the intended path.
- Explain controls and important mechanics.
- Use consistent placeholder or final visual/audio assets.
- Include credits and asset licenses.
- Be exportable and shareable.

---

## 12. Immediate Next Session

The next session should not add another generic score or artificial movement restriction.

### Session goal

Convert the current generic `Scrap` pickup into the first real data-driven **Module Pickup**.

### First implementation slice

1. Create `ModuleDefinition.gd`.
2. Define fields for name, capacity cost, Speed bonus, Health bonus, and granted move placeholder.
3. Create one Engine Resource asset.
4. Change the pickup signal from:

```gdscript
signal collected
```

to a signal that carries the collected module:

```gdscript
signal collected(module: ModuleDefinition)
```

5. Print the collected module's display name before building the inventory.

### Acceptance test

Walking onto the Engine pickup prints or displays:

```text
Collected module: Engine
```

The same pickup scene must later support Battery and Armor Plate by changing only its assigned Resource.
