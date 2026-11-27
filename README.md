# 🐝 Bramble Bee

A small 2D arcade game for Android, built with **Godot 4** and **GDScript**.

Fly a bee through an Irish hedgerow, hop between leaf platforms and collect every flower to finish the level.

> **Status:** In development. Aiming for a Google Play release in early 2027.

## About

Bramble Bee is a portfolio project and my first game. The idea was inspired by the bee arcade minigame in *GTA: San Andreas*, reimagined as an original game with its own name, artwork and levels. Not affiliated with or endorsed by Rockstar Games.

## Features so far

- Gravity-based flying with a thrust button, and quick recovery when you press Fly while falling
- On-screen touch controls with multi-touch (fly and steer at the same time)
- One-way leaf platforms: fly up through them, land on top
- Collectable flowers with a live counter
- "Level complete" when every flower is collected
- Tested on a real Android phone

## Controls

| Action | Phone | PC (for testing) |
|---|---|---|
| Move left | ◀ button | Left arrow / A |
| Move right | ▶ button | Right arrow / D |
| Fly | Yellow Fly button | Space / Up arrow |

## Roadmap

### Phase 1: Build the game
- [x] Part 1: Project setup
- [x] Part 2: The bee flies
- [x] Part 3: Leaves and flowers
- [ ] Part 4: Brambles and lives
- [ ] Part 5: The wasp
- [ ] Part 6: Screens (title, HUD, pause, level complete, game over)
- [ ] Part 7: Five levels and saving progress
- [ ] Part 8: Art and sound
- [ ] Part 9: Upload for closed testing

### Phase 2: Testing and launch
- [ ] Part 10: Closed testing (14 days)
- [ ] Part 11: Fixes from tester feedback
- [ ] Part 12: Store listing and launch on Google Play
- [ ] Part 13: README polish, screenshots and demo video

## Tech

- **Engine:** Godot 4.7 (Compatibility renderer, portrait 720×1280)
- **Language:** GDScript
- **Platform:** Android

## Running it locally

1. Install [Godot 4.7](https://godotengine.org/download) (standard version, not .NET).
2. Clone this repo and open the folder in Godot's Project Manager.
3. Press **F5** to play on your PC.

To run on an Android phone, set the Java and Android SDK paths in **Editor → Editor Settings → Export → Android**, enable USB or wireless debugging on the phone, and use **Remote Deploy**.

## Author

Amy McNabb · [GitHub](https://github.com/AmyRose20)
