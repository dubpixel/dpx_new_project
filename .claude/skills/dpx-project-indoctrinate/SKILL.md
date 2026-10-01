---
name: dpx-project-indoctrinate
description: Drive src/dpx_newProject.sh (new-project mode and indoctrinate/-I mode) without re-reading the whole script — build the right command from context, ask the user only what's actually ambiguous, then hand the command to the user to run interactively. Use whenever the user asks to scaffold a new dubpixel hardware/software/3D project, "indoctrinate" or "bless" an existing folder with dpx template docs (AGENTS.md, CLAUDE.md, README, CHANGELOG, .github/, .vscode/), or update an older project's docs to the current dpx template.
---

# DPX Project Indoctrinate

`src/dpx_newProject.sh` (this repo) either scaffolds a brand-new dubpixel
project from the template, or "indoctrinates" (`-I`) an existing directory —
stamping the current template's root docs, `.github/`, `.vscode/`, README,
CHANGELOG, images, and (hardware) `ibom/`/`platformio.ini`/firmware code
templates into it, with per-file conflict prompts. This skill exists so an
agent doesn't have to re-read all ~1,400 lines of the script every time to
remember the flags and the indoctrinate-mode gotchas.

**Never edit `src/dpx_newProject.sh` from this skill.** If something about
the script itself seems broken or worth changing, file a GitHub issue (see
`AGENTS.md` § "Mid-Session Issue Triage") — don't patch it inline unless the
user explicitly says "fix this" / "fix it now".

## Why you can't just run it yourself

The script reads interactive prompts from `/dev/tty` for several steps —
project type picker, per-file conflict resolution, the `images/`/`ibom/`
yes/no prompts (these are **not** skippable with `--force`), and the
extended README conflict prompt. A backgrounded or piped Bash call will hang
or fail on these reads. **Always hand the finished command to the user to
run themselves** (suggest `! <command>` in Claude Code, or open a terminal —
per `AGENTS.md` § 7, testing that involves user input should happen in a
terminal you can both see). Do not attempt to fake TTY input or run it
non-interactively in the background.

## Step 1 — Decide: new project, or indoctrinate an existing one?

- A brand-new folder / "scaffold a project" / "create a new hardware repo"
  → **new-project mode**.
- An existing repo that predates the current template, or that's missing
  `AGENTS.md`/`.github/` workflows, or the user says "indoctrinate",
  "bless this with the dpx template", "bring this up to date with the
  template" → **indoctrinate mode** (`-I`).

## Step 2 — Resolve the project type (`-H` / `-S` / `-D`)

Infer from context before asking:
- Firmware/PCB/schematic/BOM content, `platformio.ini`, `.ino`/`.cpp` in a
  `firmware/` tree → Hardware (`-H`, the default in new-project mode).
- A `src/` tree with no firmware, a `package.json`, pure application code →
  Software (`-S`).
- STL/STEP files, a `src/STL/` layout, no code → 3D (`-D`).

If you genuinely can't tell (e.g. an empty folder, indoctrinate mode with no
existing content to infer from), ask the user — don't guess silently. In
indoctrinate mode, if type is omitted the script itself prompts
interactively, so it's fine to leave it off and let the user pick when they
run the command.

## Step 3 — Resolve destination (new-project mode only)

Resolution order the script actually uses:
1. `DPX_3D_DIR` env var (3D only, explicit override)
2. `DPX_PROJECTS_DIR` env var (hardware/software, explicit override)
3. `-D` → walks up the tree to find `_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS/`
4. `-C` flag, or `-S` type → walks up to find `_...CODE/`
5. default → walks up to find `_...CIRCUIT_PROJECTS/`
6. fallback → current working directory

Only ask the user about destination if none of steps 1–5 obviously apply
(e.g. you're not inside a dubpixel project tree, or an env var override
should be set) — otherwise let the script's own walk-up resolve it.

## Step 4 — Build the flags

| Flag | Meaning |
|------|---------|
| `<project_name>` | required, new-project mode only, first positional arg |
| `-H` / `-S` / `-D` | project type (see Step 2) |
| `-I` / `--indoctrinate [target_path]` | indoctrinate mode; target path optional (script offers a recent-projects picker if omitted) |
| `--force` | indoctrinate only — overwrite existing files without the per-file `y/n/m/a/M` prompt. **Does not** suppress the `images/`/`ibom/` set-up-or-skip prompts. |
| `-P` | interactively pick a README template instead of auto-selecting by type |
| `-C` | force `_...CODE/` destination (auto-on for `-S`) |
| `-V` | verbose (show every file copied) |
| `-M 'tagline'` | sassy tagline → replaces the README placeholder |
| `-T 'text'` | project description → replaces the README placeholder |

Ask the user for `-M`/`-T` content when they want a customized README and
haven't given you the text — don't invent a tagline for them.

## Step 5 — Indoctrinate-mode caveats worth flagging to the user

These are real script behaviors, not bugs — mention them if relevant so the
user isn't surprised mid-run:

- **Merge (`m`/`M`) is disabled for `CHANGELOG.md` and any `*.yml`/`*.yaml`**
  — naive line-append merging can't represent dated changelog sections or
  YAML nesting safely. Those files only offer `y`/`n`/`a`.
- **Root `AGENTS.md`/`CLAUDE.md` relocation check**: if the target project
  has a customized copy of either file living somewhere other than root
  (e.g. `.github/AGENTS.md`, `docs/AGENTS.md`), the script detects it before
  stamping and offers: move the old one to `<name>.old` at root + stamp
  fresh, leave it where it is + also stamp root, or skip stamping root
  entirely. It will not silently create a blank root file that shadows a
  real customized one.
- **`VERSION` is always (re)written to `0.1.0`** in indoctrinate mode — it
  is never copied from the template. If the target already has a `VERSION`
  file, the script asks before overwriting it.
- **`.idea/` is never touched** in either mode.
- Hardware-only steps (`ibom/`, `platformio.ini` picker, firmware code
  templates) only run when the resolved type is `-H`.

## Step 6 — Hand off the command

Give the user the exact command, e.g.:

```
./src/dpx_newProject.sh -I ~/path/to/old_project -H -M 'a sassy tagline' -T 'what this thing does'
```

Tell them it will prompt interactively for any per-file conflicts, and for
the `images/`/`ibom/` setup steps regardless of `--force`. Suggest running
it with `! <command>` (or in a visible terminal) so you can both see the
prompts and results.

## Step 7 — After they run it

If they report something went wrong with the script's own logic (not a
one-off template conflict they resolved themselves), file a GitHub issue
per `AGENTS.md` § 0/§ "Mid-Session Issue Triage" rather than patching
`dpx_newProject.sh` — unless they explicitly say to fix it now.
