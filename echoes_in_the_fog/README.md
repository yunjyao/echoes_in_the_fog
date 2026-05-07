# Echoes in the Fog

A small independent stealth game prototype built in **Godot 4**. The technical focus is a belief-based enemy AI system: guards do not know the player's true location unless they can directly perceive it. Instead, they update an internal belief from partial vision, sound events, and time-decaying memory.

## Why this project is resume-worthy

Most beginner game projects implement enemies as omniscient agents: if the player exists, enemies know exactly where to go. This project models guards as imperfect decision-makers. Each guard stores a confidence-weighted belief about the player's location and chooses between patrol, investigate, and chase behaviors based on uncertainty.

## Core systems

- **Vision perception**: cone-based line-of-sight detection with wall occlusion.
- **Sound perception**: footsteps and thrown distractions emit radius-based sound events.
- **Memory decay**: each enemy's confidence decays over time without fresh evidence.
- **Belief-based decision making**: guards chase high-confidence beliefs, investigate medium-confidence beliefs, and patrol when confidence is low.
- **Debug visualization**: vision cones, belief points, confidence lines, and AI states can be toggled with `F3`.

## Controls

| Input | Action |
|---|---|
| WASD / Arrow keys | Move |
| Shift | Sprint, but generate louder footsteps |
| Left mouse click | Throw a sound distraction |
| F3 | Toggle debug visualization |

## How to run

1. Install Godot 4.2 or newer.
2. Open Godot.
3. Import this folder as a project.
4. Press **Run**.

Main scene: `res://scenes/main.tscn`

## Suggested resume bullet

> Developed a stealth game prototype in Godot with a belief-based AI system, where enemies make real-time decisions under uncertainty using vision, sound, and time-decaying memory rather than omniscient player tracking.

## Possible extensions

- Add probabilistic belief maps instead of a single belief point.
- Add guard-to-guard communication.
- Replace direct steering with A* pathfinding.
- Add a level editor or procedural room generation.
- Log AI decision latency and detection success rate for a more research-style demo.

## Repository structure

```text
.
├── scenes/
│   └── main.tscn
├── scripts/
│   ├── ai/
│   │   └── enemy.gd
│   ├── player/
│   │   └── player.gd
│   ├── ui/
│   │   └── hud.gd
│   └── world/
│       ├── floor_grid.gd
│       ├── main.gd
│       └── sound_event.gd
├── docs/
│   └── DESIGN.md
├── project.godot
└── README.md
```
