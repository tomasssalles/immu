# immu

Persistent data structures implemented in [Mojo](https://www.modular.com/open-source/mojo).

## Project goals

Two learning objectives running in parallel:
1. Learn the Mojo language.
2. Understand how persistent (immutable) data structures work in detail.

The package is named **immu** — short for "immutable", and a nod to the emu, which is very fast (as Mojo aims to be).

## Branding

The project mascot is an emu running fast, rendered in a cartoon style with blocky/pixel motion streaks suggesting data streams.

- **Light mode**: shiny teal gradient
- **Dark mode**: shiny light-grey gradient (same luminosity mapping, different hue)

Source images live in `assets/`. Naming convention:
- `logo-full-body-{variant}.full-size.png` — full-body emu, used in README and docs
- `logo-head-{variant}.full-size.png` — emu head only, used for GitHub avatar, favicon, etc.
- Variants so far: `light` (teal), `dark` (grey)

## How we work

- The **user does most of the coding** — this is a learning project.
- Claude helps with: boilerplate, refactoring, explanations, debugging.
- Work in **small incremental steps**. Do not batch large changes without discussion.
- Do not add features, refactoring, or improvements beyond what was asked.
- Discuss ideas before acting on them.