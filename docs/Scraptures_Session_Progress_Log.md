# Scraptures — Session Progress Log

This file is the short source of truth for continuing work between chats. Update it at the end of every development session.

---

## Project Identity

- **Game:** Scraptures
- **Studio:** Wiremane
- **Engine:** Godot 4.x, latest stable
- **Language:** Typed GDScript
- **Tools:** Godot, Cursor, Git, GitHub
- **Demo deadline:** September 28, 2026

---

## Core Demo Loop

```text
Explore
→ collect modules
→ battle a wild Scrapture
→ capture it
→ equip modules within Attachment Capacity
→ gain stats and moves
→ win a final encounter
```

---

## Current Milestone

**Week 1 — Convert generic Scrap pickups into data-driven Module pickups.**

### Current session objective

Create the first `ModuleDefinition` Resource and make the existing pickup emit the specific collected module.

### Acceptance test

Walking onto an Engine pickup produces:

```text
Collected module: Engine
```

The same pickup scene must support another module by assigning a different Resource, without changing its script.

---

## Completed Work

- [x] Created Godot project.
- [x] Opened the correct project root in Cursor.
- [x] Created `Main` scene.
- [x] Created reusable `Player` scene.
- [x] Added visible Player shape and collision.
- [x] Added custom movement input actions.
- [x] Implemented one-cell-per-input grid movement.
- [x] Added visual grid.
- [x] Added grid movement boundaries.
- [x] Created reusable `Scrap` pickup scene using `Area2D`.
- [x] Added pickup visual and collision.
- [x] Connected `body_entered`.
- [x] Added Player and Scrap Groups.
- [x] Added custom `collected` signal.
- [x] Connected multiple pickup instances through code.
- [x] Added `class_name Scrap` and typed casting.
- [x] Added basic scrap count.
- [x] Added Label UI for the count.
- [x] Discussed Git and GitHub workflow.

---

## Existing Prototype Architecture

Approximate scene tree:

```text
Main
├── Grid
├── Scrap instances
├── Player
├── ScrapLabel
└── optional temporary GoalLabel
```

Approximate folders:

```text
scenes/
├── main.tscn
├── player/player.tscn
└── scrap/scrap.tscn

scripts/
├── main.gd
├── grid/grid.gd
├── player/player.gd
└── interactions/scrap.gd
```

---

## Important Decisions

- The generic Scrap count was useful for learning, but it is not the final game system.
- The actual game uses distinct equipment modules, not only a single generic resource total.
- Modules modify Scrapture stats and grant moves.
- Every Scrapture has fixed Attachment Capacity.
- The demo will use only Engine, Battery, and Armor Plate modules.
- The first battle system will be one-versus-one.
- The first capture rule should be predictable and simple.
- Scope must remain limited to one complete vertical slice.

---

## Immediate Refactor Plan

1. Create `scripts/modules/module_definition.gd`.
2. Add `class_name ModuleDefinition` and extend `Resource`.
3. Add initial fields:
   - `display_name: String`
   - `capacity_cost: int`
   - `speed_bonus: int`
   - `max_health_bonus: int`
   - granted move placeholder
4. Create `resources/modules/engine.tres`.
5. Give the pickup an exported `ModuleDefinition` field.
6. Change the pickup signal to include the module.
7. Update the receiver to accept the module parameter.
8. Print/display the collected module name.
9. Only after this works, build a small module inventory.

---

## Known Items to Verify

- [ ] Confirm Git repository is initialized.
- [ ] Confirm remote repository is connected.
- [ ] Confirm latest working commit is pushed.
- [ ] Confirm all Scrap instances use the intended Group.
- [ ] Confirm the old manual signal connection is removed if automatic connections are used.
- [ ] Decide whether the temporary `GoalLabel` and scrap-goal code were added; remove them if they do not serve the new module system.
- [ ] Rename `Scrap` scene/script only after the first module pickup behavior is stable.

---

## Deferred Features

Do not start these until their roadmap week:

- Full inventory UI
- Multiple party slots
- Turn-based battle
- Capture
- Scene transitions
- Story dialogue
- Save/load
- Advanced animation
- More areas
- More than three module types
- Complex elemental system

---

## Session Handoff Template

Copy and complete this section at the end of each session.

### Session

- **Date:**
- **Roadmap week:**
- **Session goal:**

### Files changed

```text
- path/to/file.gd
- path/to/scene.tscn
- path/to/resource.tres
```

### Completed

- [ ]
- [ ]

### Tests passed

- [ ] Project launches without parser errors.
- [ ] New behavior works in the running game.
- [ ] Existing grid movement still works.
- [ ] No duplicate signal behavior.

### Known bugs or questions

- None / describe here.

### Exact next step

Write one small next action here.

### Suggested Git commit

```text
Describe the completed feature in imperative form
```

---

## Rules for the Next Assistant

- Read this file before proposing work.
- State the current milestone before writing code.
- Do not add unrelated tutorial features.
- Tie every task to the Scraptures core loop.
- Explain Godot and GDScript syntax in small steps.
- Let the developer write important gameplay rules.
- Use Cursor only for repetitive/mechanical work.
- End each session by updating this log.
