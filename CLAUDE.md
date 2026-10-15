# Parambariyam — Claude Code guide

A 2D roguelike about a lineage of shaman women with 1000 years to defeat an evil spirit. Each daughter grows up in a village (Reigns-style yearly events, left/right movement), leaves through a cave to fight in Slay the Spire-style card battles, and passes things on through an egg that hatches into her heir.

Full design: Notion → Parambariyam → Game Design Doc.

## Engine rules (important)
- **Godot 4.x only. Never use Godot 3 syntax.**
  - `@export`, `@onready` (not `export`, `onready`)
  - `await` (not `yield`)
  - `CharacterBody2D` (not `KinematicBody2D`)
  - `signal_name.connect(callable)` / `signal_name.emit()` (not string-based `connect("x", self, "y")`)
  - `super()` (not `.method()`)
- **GDScript** with **static typing** everywhere: `var age: int = 0`, `func get_hp() -> int:`
- 2D only.

## Architecture
- **Signals for anything cross-system.** Removing one script should not break others.
- **One script per responsibility.** No giant manager files.
- **Autoloads** (singletons) only for true global state: `Clock` (the 1000-year timeline), `Lineage`, `SaveManager`, `Events` (a global signal bus).
- **Custom Resources** for data (like ScriptableObjects): `CharacterData`, `EggData`, `OverlordData`, `EventCard`, `SpellData`.
- Game state lives in Resources/autoloads, never in UI nodes. UI only reads state and emits signals.
- Prefer composition (child nodes) over deep inheritance.

## Folder layout
```
res://
  autoload/      # Clock, Lineage, SaveManager, Events
  data/          # .tres resource files (cards, overlords, events)
  resources/     # Resource class scripts
  scenes/
    village/
    cave/
    combat/
    ui/
  scripts/       # shared helpers
  art/
  audio/
```

## Conventions
- Files and folders: `snake_case`. Classes: `PascalCase` with `class_name`.
- Signals: past tense (`year_advanced`, `character_died`, `egg_hatched`).
- Add a debug readout (Label or overlay) for any new numeric system (age, stats, metrics) so it can be seen while tuning.
- Use temporary debug overrides for rare or random events, so they can be forced and tested.

## When writing code
- Explain where a new script attaches (which node, which scene).
- If a change needs editor work (adding nodes, connecting signals in the inspector), list those steps clearly.
- Keep changes small and testable. One feature at a time.
