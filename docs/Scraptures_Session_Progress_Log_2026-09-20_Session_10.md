# Scraptures — Session Progress Log

**Date:** 2026-09-20  
**Session:** 10  
**Current milestone:** Week 6 — UX, visuals, presentation, and world-building  
**Studio:** Wiremane  
**Project:** Scraptures  

---

## Current project status

Week 5's core integration loop is complete and was committed/pushed before this session.

The proven demo loop is:

```text
Explore
→ collect modules
→ equip modules
→ encounter a Scrapture
→ battle
→ capture
→ captured Scrapture joins party
→ select/customize captured Scrapture
→ use customized Scrapture in another/final encounter
→ return to overworld
```

Week 6 is now focused on making that working loop look and feel like an actual game rather than a debug prototype.

The immediate direction is **not** to expand gameplay scope. The priority is to turn the existing demo into a visually coherent, readable, polished vertical slice.

---

# Completed before this session

## Week 5 integration

- Reusable `EncounterTrigger` scene is working.
- Encounter triggers carry a `ScraptureDefinition`.
- Fast Wild and Slow Wild encounters can create the correct runtime enemy.
- Encounters begin battle automatically from the overworld.
- Old `B` test-battle shortcut was removed from normal gameplay.
- Encounter triggers are one-time.
- Fast Wild and Slow Wild species resources exist.
- Final encounter placeholder exists.
- Battle can use the currently selected party Scrapture instead of always forcing the Starter.
- Captured Scraptures can be selected, equipped, and used in later battles.
- Old unequip UI selection bug was fixed.
- Full Explore → Customize → Battle → Capture → Reuse loop passed an end-to-end test.

### Intentionally deferred

- Final encounter progression gating is still intentionally deferred.
- No healing system has been added.
- Do not expand scope with additional species or large systems.

---

# Session 10 — Week 6 work completed

## 1. Battle UI readability work

Battle UI feedback was improved so the player does not need to rely only on the Godot Output console.

### Confirmed

- Battle HP labels now refresh correctly after every round.
- The previous bug was caused by `update_health_display()` only running in one combat branch.
- `update_health_display()` was moved so it runs after all normal round-resolution branches.
- Player and enemy HP changes are now visible immediately.

### Combat message work

`ResultLabel` work was added/updated for:

- attack damage messages,
- Guard feedback,
- module-move names,
- Guard/module-Guard distinction such as Brace.

A final regression pass is still needed after the visual restructuring work.

---

## 2. Player visual pipeline

The Player is no longer required to use only the old debug square.

`scenes/player.tscn` now has a `Sprite2D` visual child while keeping the existing:

- `CharacterBody2D`,
- `CollisionShape2D`,
- grid movement,
- pickup detection,
- encounter detection.

The old debug visual can remain hidden temporarily until the final player sprite is chosen.

Important separation remains:

```text
CharacterBody2D
→ gameplay object / movement

CollisionShape2D
→ collision and detection

Sprite2D
→ visual appearance
```

The Player sprite pipeline was tested successfully.

---

## 3. Data-driven Scrapture overworld visuals

`ScraptureDefinition` was expanded with visual definition data.

Added concept:

```gdscript
@export var overworld_texture: Texture2D
```

The reusable `EncounterTrigger` now contains a child:

```text
ScraptureSprite (Sprite2D)
```

and reads the texture from its assigned `ScraptureDefinition`.

Conceptual flow:

```text
ScraptureDefinition.overworld_texture
→ EncounterTrigger
→ ScraptureSprite.texture
```

This means an encounter does not hardcode the species art.

Example:

```text
FastWildEncounter
→ fast_wild_scrapture.tres
→ Fast Wild overworld texture

SlowWildEncounter
→ slow_wild_scrapture.tres
→ Slow Wild overworld texture
```

A missing-node error caused by the `ScraptureSprite` Node name/path was identified and fixed.

---

## 4. Fast Wild overworld art workflow

PixelLab was used to generate small pixel-art Scrapture variations.

The first generation produced many 32×32 frames/variations. The workflow was corrected so a single selected 32×32 frame can be exported as its own PNG.

Fast Wild now has a working small overworld sprite pipeline.

Recommended ongoing art rule:

```text
Overworld sprite
→ 32×32
→ simple and readable
→ top-down / 3/4
→ low detail

Battle sprite
→ 96×96 or 128×128
→ more detail
→ combat pose
```

---

## 5. Separate battle textures

The project direction was changed so battle visuals do not reuse tiny overworld sprites.

`ScraptureDefinition` now uses the concept:

```gdscript
@export var overworld_texture: Texture2D
@export var battle_texture: Texture2D
```

This separates:

```text
Overworld
→ small map sprite

Battle
→ larger detailed battle sprite
```

An enemy Battle `TextureRect` was added/prototyped and can read:

```gdscript
enemy_scrapture.definition.battle_texture
```

The enemy battle-sprite pipeline works as a temporary proof.

### Not yet completed

- Final Battle layout is not designed.
- Player-side battle sprite setup is not finished.
- Starter battle art is not finalized.
- Slow Wild battle art/import still needs a final confirmed pass.
- Battle sprite positioning and scale are temporary.

---

## 6. Fullscreen and target resolution

A fixed logical game resolution was established so visuals can now be designed against a stable screen size.

Current target:

```text
Logical resolution: 640 × 360
Aspect ratio: 16:9
Fullscreen: enabled
Stretch mode: Canvas Items
Aspect: Keep
```

The intent is:

```text
640×360 logical game
→ Godot scales it to the physical monitor
```

Sprites and gameplay coordinates should be designed in the logical 640×360 space rather than manually targeting the monitor's physical resolution.

The existing gameplay grid size remains based on 32-pixel cells.

Fullscreen behavior was tested successfully.

---

## 7. Tile-based overworld started

The old debug grid is no longer intended to be the final world presentation.

A new:

```text
Ground (TileMapLayer)
```

was added to begin constructing the actual overworld from tiles.

The project is using the current Godot 4 `TileMapLayer` workflow rather than building a new visual debug grid.

### Ground setup

- `Ground` exists as a `TileMapLayer`.
- Tile size is based on 32×32 pixels.
- A proper 32×32 pixel-art tileset workflow was established.
- Early AI-generated presentation-sheet tiles were rejected because they were not a real game-ready atlas.
- PixelLab's dedicated Create Tileset workflow was used instead.
- A Grass ↔ Dirt terrain set was configured.
- Ground tiles can now be painted successfully in Godot.

### Ground rendering

Ground is intended to render below gameplay entities.

Current ordering concept:

```text
Ground
Z Index = -10

Player / Scraptures / Pickups
Z Index = 0
```

The ground is currently visual terrain only.

No finished obstacle/collision tile system has been added yet.

---

## 8. HUD moved to a CanvasLayer

Ground painting exposed an ordering issue where world graphics could draw over UI.

A new HUD `CanvasLayer` was introduced.

Current conceptual structure:

```text
Main
├── Ground
├── Player
├── encounters
├── pickups
├── HUD (CanvasLayer)
│   ├── ScrapLabel
│   └── GoalLabel
├── InventoryScreen
└── Battle
```

Because the Labels moved under `HUD`, their Node paths in `main.gd` had to change.

Example:

```gdscript
@onready var scrap_label: Label = $HUD/ScrapLabel
@onready var goal_label: Label = $HUD/GoalLabel
```

The resulting `Node not found` / `null instance` errors were fixed.

HUD rendering and the updated paths are confirmed working.

---

# Explicitly NOT started yet

## Decoration TileMapLayer

A separate `Decoration` layer was proposed but **has not been created yet**.

Do not mark this as completed.

The developer intentionally stopped before this step.

Potential future layers may include:

```text
Ground
Decoration
Obstacles
```

but these should only be added as needed while building the actual starter map.

---

# New presentation direction

The developer explicitly wants the project to stop looking like a debug prototype and begin taking the shape of the actual demo.

The priority is now:

1. Build a polished, intentional starter map from tiles.
2. Remove leftover debug/prototype presentation.
3. Rework Battle UI into a proper battle screen.
4. Finalize overworld and battle sprites.
5. Improve visual layer ordering.
6. Add animation and visual feedback.
7. Improve transitions and overall presentation.
8. Add audio/title-screen polish later in Week 6.

This remains a **single small demo area**, not an open-world expansion.

---

# Requested UI change

## Remove the `Scrap: 0 / 3` HUD

The developer explicitly wants to remove the visible:

```text
Scrap: 0 / 3
```

UI from the game.

Important:

Removing this Label should **not** remove or rewrite the underlying module/inventory collection logic.

The intent is:

```text
remove prototype/debug HUD presentation
≠
remove collection gameplay
```

This should be one of the first cleanup tasks in the next session.

---

# Next visual milestone: make the demo look like a real game

The next phase should concentrate on finished presentation rather than adding new gameplay systems.

## Starter map

Build one small, attractive, playable starter area using the new TileMap workflow.

The map should visually communicate:

- reclaimed nature,
- salvaged technology,
- nature-cyberpunk atmosphere,
- clear paths,
- readable encounter placement,
- readable module pickup placement,
- intentional beginning-to-end flow.

Keep the map small enough for the demo.

Do not increase the number of areas.

## Battle presentation

After the starter map begins to look coherent, return to Battle presentation:

```text
Battle background / layout
Player battle sprite
Enemy battle sprite
HP presentation
Action menu layout
Result/combat text
Layer ordering
Battle transitions
```

## Animation pass

After static layouts are stable, add small animations rather than complex systems.

Examples appropriate for the demo:

- subtle idle movement,
- attack lunge / shake,
- damage flash,
- capture feedback,
- encounter transition,
- UI appear/disappear motion.

Avoid building a large animation framework before basic presentation is working.

---

# Files changed / likely changed this session

The following files are known or expected to contain Session 10 work. **Run `git status` before committing to verify the exact local list.**

```text
project.godot
scenes/main.tscn
scripts/main.gd
scenes/player.tscn
scenes/Battle/Battle.tscn
scripts/Battle/battle.gd
scripts/scraptures/scrapture_definition.gd
scenes/interactions/EncounterTrigger.tscn
scripts/interactions/encounter_trigger.gd
resources/scraptures/fast_wild_scrapture.tres
resources/scraptures/slow_wild_scrapture.tres
```

There are also new/changed image and tileset assets created during the visual pass. Their exact local paths should be taken from `git status` rather than guessed in this document.

This progress log itself should be added under:

```text
docs/Scraptures_Session_Progress_Log_2026-09-20_Session_10.md
```

---

# Tests passed

Confirmed during this session:

- Player Sprite2D renders and moves with the existing Player.
- Existing grid movement remains functional.
- Encounter collision still works after adding visual sprites.
- Data-driven encounter texture loading works.
- Fast Wild overworld sprite workflow works.
- Enemy battle texture pipeline works as a temporary proof.
- Battle HP labels update after rounds.
- Game can run using the 640×360 logical fullscreen setup.
- TileMapLayer Ground can paint terrain.
- Ground can be ordered below gameplay visuals.
- HUD CanvasLayer remains above world rendering.
- `ScrapLabel` / `GoalLabel` Node-path errors were fixed after moving them under HUD.

---

# Known issues / deferred work

- `Scrap: 0 / 3` HUD is still present and should be removed next.
- Decoration layer has not been started.
- Starter map is not yet visually finished.
- Existing debug grid may still exist and should remain only until the TileMap world fully replaces it.
- Tile collision / obstacle behavior is not yet implemented.
- Battle layout is still prototype-quality.
- Player-side battle sprite is not yet completed.
- Battle sprite sizes/positions are temporary.
- Starter/Slow Wild final battle art is not fully finalized.
- Combat ResultLabel changes need one final regression test after the UI restructuring.
- Final encounter progression gating remains intentionally deferred.
- No healing system exists; do not add one unless the demo proves it is necessary.

---

# Exact next step

## Remove the prototype Scrap counter UI

Remove only the visible:

```text
Scrap: 0 / 3
```

HUD Label and its direct UI-update dependency.

Preserve:

- module collection,
- inventory ownership,
- module counts/data,
- pickup signals,
- loadout behavior.

### Acceptance test

```text
Launch game
→ no "Scrap: 0 / 3" text is visible
→ collect a module
→ module still enters inventory
→ Inventory/Loadout still sees the collected module
→ no Node-not-found or null-instance errors
```

After that, the next focused objective is:

```text
Build the polished starter map using the Ground TileMapLayer.
```

Do not create the Decoration layer before deciding what the starter map actually needs.

---

# Suggested Git checkpoint

Before committing:

```powershell
git status
```

Review the exact changed and untracked files, especially generated PNG assets and TileSet resources.

Suggested commit message:

```text
Start Week 6 visual presentation pass
```

Alternative, if the commit is primarily the visual/TileMap foundation:

```text
Add Week 6 visual and tilemap foundation
```

---

# Week 6 scope guard

Continue focusing on:

```text
finished starter map
visual readability
battle presentation
sprites
layering
small animations
audio
title/presentation polish
```

Do not expand into:

- additional world areas,
- many new Scrapture species,
- multiplayer,
- breeding,
- procedural generation,
- large inventory systems,
- complex type systems,
- large story systems.

The gameplay loop already works. Week 6 should make that loop feel like a coherent game.
