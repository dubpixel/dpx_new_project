---
title: dpx_new_project
---

# dpx_new_project

Template generator for standardized dubpixel hardware/software/3D projects.
One script, two modes: scaffold a brand-new project, or bring an existing
one up to date with the current template ("indoctrinate").

[Source on GitHub](https://github.com/dubpixel/dpx_new_project) ·
[README](https://github.com/dubpixel/dpx_new_project/blob/main/README.md) ·
[AGENTS.md](https://github.com/dubpixel/dpx_new_project/blob/main/AGENTS.md)

## New project mode

```
./src/dpx_newProject.sh <project_name> [-H|-S|-D] [-P] [-C] [-V] [-M 'tagline'] [-T 'desc']
```

| Flag | Meaning | Default |
|------|---------|---------|
| `-H` | Hardware project — copies `hardware/` + `firmware/` trees | default if no type given |
| `-S` | Software project — creates `src/` + `images/`, lands in `_...CODE` | — |
| `-D` | 3D project — creates `src/STL/` + `images/`, lands in `_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS/` | — |
| `-P` | Interactively pick a README template | auto-selected by type |
| `-C` | Force `_...CODE` destination | auto-on for `-S` |
| `-V` | Verbose output | off |
| `-M 'text'` | Sassy tagline for the README | — |
| `-T 'text'` | Project description for the README | — |

**Destination resolution order:** `DPX_3D_DIR` env var → `DPX_PROJECTS_DIR`
env var → `-D` walks up to `_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS/` → `-C`/`-S`
walks up to `_...CODE/` → default walks up to `_...CIRCUIT_PROJECTS/` →
current directory.

## Indoctrinate mode

Stamps the current template's root docs (`AGENTS.md`, `CLAUDE.md`,
`.gitignore`, `.gitattributes`, `_config.yml`, `Gemfile`,
`dpx_release_note_template.md`), `.github/`, `.vscode/`, `README.md`,
`CHANGELOG.md`, `images/`, and — for hardware projects — `ibom/`,
`platformio.ini`, and firmware code templates into an **existing** project
directory, one file at a time, with conflict resolution per file:

```
./src/dpx_newProject.sh -I [target_path] [-H|-S|-D] [--force] [-P] [-V] [-M 'tagline'] [-T 'desc']
```

Per-file conflicts offer `[y]es / [n]o / [m]erge / [a]ll-overwrite /
[M]erge-all` — except `CHANGELOG.md` and any `*.yml`/`*.yaml`, where merge
is disabled (naive line-append merging can't safely represent dated
changelog sections or YAML nesting), so those only offer `y`/`n`/`a`.

If a customized `AGENTS.md`/`CLAUDE.md` already exists somewhere other than
project root (e.g. `.github/AGENTS.md`), the script detects it and asks
before stamping a fresh root copy — it won't silently create a blank file
that shadows a real one.

`VERSION` is always (re)written to `0.1.0` in this mode, never copied from
the template. `--force` skips the per-file `y/n/m/a/M` prompts, but **not**
the `images/`/`ibom/` set-up-or-skip prompts — those always ask.

## Working with an AI agent

This repo ships a Claude Code skill —
[`.claude/skills/dpx-project-indoctrinate/`](https://github.com/dubpixel/dpx_new_project/tree/main/.claude/skills/dpx-project-indoctrinate) —
that knows this page's content already: flag semantics, destination
resolution, and the indoctrinate-mode caveats above. Point an agent at a
project and ask it to scaffold or indoctrinate; it builds the right command
from context and hands it to you to run (the script needs a real terminal —
several prompts read directly from `/dev/tty` and aren't skippable with
`--force`).

## Environment variables

| Variable | Effect |
|----------|--------|
| `DPX_TEMPLATE_DIR` | Override the template source directory |
| `DPX_PROJECTS_DIR` | Override where new hardware/software projects are created |
| `DPX_3D_DIR` | Override where new 3D projects are created |
| `DPX_ROOT` | Base directory containing the `dpx_readme_template` folder |
