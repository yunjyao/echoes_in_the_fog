# Technical Design: Belief-Based Stealth AI

## Problem

A common weakness in small game prototypes is omniscient enemy behavior. Enemies often know the player's exact position once a simple trigger condition is met. This creates predictable gameplay and does not demonstrate deeper AI engineering.

## Design goal

The goal of this project is to create guards that act from incomplete information. Each guard keeps an internal belief state:

```text
belief_position: Vector2
confidence: float in [0, 1]
```

The enemy's belief is updated by perception events:

1. Direct vision gives exact player position and confidence = 1.
2. Sound gives an approximate position and confidence based on distance.
3. No new evidence causes confidence to decay over time.

## Decision rules

```text
confidence >= 0.82  -> CHASE
confidence >= 0.20  -> INVESTIGATE
otherwise           -> PATROL
```

This produces emergent behavior because enemies can be wrong. A distraction can create a medium-confidence false belief, pulling a guard away from the player.

## Current limitations

The current version uses direct steering toward patrol and belief points. This is simple and easy to inspect, but it can be extended with A* pathfinding or Godot NavigationAgent2D.

## Good next engineering upgrade

The strongest next version would convert the single belief point into a probability heatmap over the map. Vision would collapse the belief distribution, sound would spread probability around the sound source, and time decay would diffuse the distribution.
