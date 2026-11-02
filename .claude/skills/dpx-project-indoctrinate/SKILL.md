---
name: dpx-project-indoctrinate
description: Apply the dpx project template — AGENTS.md, CLAUDE.md, README, CHANGELOG, .github/, .vscode/, images, and (hardware) ibom/, platformio.ini, firmware code templates — to a project yourself, directly, by reading the canonical templates and the target's current state and merging them with judgment. Checks in with the user before anything destructive; does not blindly run src/dpx_newProject.sh. Use whenever the user asks to scaffold a new dubpixel hardware/software/3D project, "indoctrinate" or "bless" an existing folder with dpx template docs, or bring an older project's docs up to the current dpx template.
---

# DPX Project Indoctrinate

`src/dpx_newProject.sh` (in `dpx_new_project`) is a non-interactive shell
script that either scaffolds a brand-new dubpixel project from the
template, or "indoctrinates" (`-I`) an existing directory — stamping the
current template's root docs, `.github/`, `.vscode/`, README, CHANGELOG,
images, and (hardware) `ibom/`/`platformio.ini`/firmware code templates into
it, with per-file `y/n/m/a/M` conflict prompts.

**This skill's job is to perform that stamping yourself** — via Read, Edit,
and Write — reading the real template source and the target's real current
content, and merging them with actual judgment. Treat the script's
`indoctrinate_project()` function (and its new-project-mode equivalent) as
the **spec** for what content should land where, not as something to
execute. If a file list or path below feels stale, re-read
`DPX_NEW_PROJECT/src/dpx_newProject.sh` directly rather than trusting a
summary from memory — the script is ground truth for *what* gets stamped;
this skill is ground truth for *how* to stamp it well.

**Never edit `src/dpx_newProject.sh` itself from this skill.** If something
about the script seems broken or worth changing, file a GitHub issue (see
`AGENTS.md` § "Mid-Session Issue Triage") — don't patch it inline unless the
user explicitly says "fix this" / "fix it now".

## Why not just run the script

The script's own conflict handling is *deliberately* dumb, because it's a
non-interactive shell tool with no understanding of document structure:
`merge_append_unique()` just tacks template lines onto the end of a file if
they're not an exact line-match already present, and every other conflict
is a blind `y/n/m/a/M` prompt read from `/dev/tty` with no idea what's
actually in either file. That's a reasonable floor for a shell script. It's
not a reasonable ceiling for an agent that can actually read both documents.

So: don't build the CLI invocation and hand it to the user to run
interactively. Do the work directly — read the template file, read the
target's existing file (if any), decide what the *right* merged result
looks like, and only stop to ask the user when a choice is genuinely
ambiguous or would destroy real existing content. State what you did (and
why) as you go, so the user can spot-check a merge the way the script's
prompts would otherwise let them.

(The script remains a legitimate option for the user to run themselves if
they explicitly ask for it — e.g. "just give me the command" — in which
case hand off the exact invocation per "Running the script directly" below.
But that is the exception, not the default.)

## Step 1 — Decide: new project, or indoctrinate an existing one?

- A brand-new folder / "scaffold a project" / "create a new hardware repo"
  → **new-project mode**. Lower risk — there's little or nothing to
  conflict with, so most of this skill's judgment calls won't come up.
- An existing repo that predates the current template, or that's missing
  `AGENTS.md`/`.github/` workflows, or the user says "indoctrinate",
  "bless this with the dpx template", "bring this up to date with the
  template" → **indoctrinate mode**. This is where merge judgment matters.

## Step 2 — Resolve the project type (`-H` / `-S` / `-D`)

Infer from context before asking:
- Firmware/PCB/schematic/BOM content, `platformio.ini`, `.ino`/`.cpp` in a
  `firmware/` tree → Hardware.
- A `src/` tree with no firmware, a `package.json`, pure application code →
  Software.
- STL/STEP files, a `src/STL/` layout, no code → 3D.

If you genuinely can't tell (e.g. an empty folder, or an indoctrinate target
with no existing content to infer from), ask the user — don't guess
silently.

## Step 3 — Resolve the template source and the target directory

**Template source** — same resolution the script uses, so find it the same
way rather than asking the user to set env vars:
1. `DPX_TEMPLATE_DIR` env var, if set
2. `DPX_ROOT/_....DPX_BLANK_PROJECT_TEMPLATE/dpx_readme_template`, if
   `DPX_ROOT` is set
3. Walk up from the current location looking for
   `_....DPX_BLANK_PROJECT_TEMPLATE/dpx_readme_template`
4. Sibling-directory checks: `../../dpx_readme_template`,
   `../dpx_readme_template`, `../../../dpx_readme_template` relative to the
   script
5. A `dpx_readme_template` subdirectory somewhere up the tree

**Target directory** (new-project mode only — indoctrinate mode's target is
whatever directory the user named):
1. `DPX_3D_DIR` env var (3D only)
2. `DPX_PROJECTS_DIR` env var (hardware/software)
3. 3D → walk up to `_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS/`
4. Software, or explicit code flag → walk up to `_...CODE/`
5. Default → walk up to `_...CIRCUIT_PROJECTS/`
6. Fallback → current working directory

Only ask the user about either path if none of the above obviously resolves
(e.g. you're not inside a dubpixel project tree).

## Step 4 — Build the file plan, then classify each item before touching anything

Read the target's current state for every item below and classify it:
**create** (doesn't exist yet — no judgment needed, just write it),
**identical** (exists and already matches the template — skip silently,
don't even mention it), or **conflict** (exists and differs — this is
where Step 5's judgment applies).

| Item | Template source | Notes |
|------|------------------|-------|
| `.gitignore`, `.gitattributes`, `_config.yml`, `dpx_release_note_template.md`, `Gemfile` | `<template>/<file>` | Plain root files |
| `AGENTS.md`, `CLAUDE.md` | `<template>/<file>` | **Always a pair** — see Step 5 |
| `.github/`, `.vscode/` | `<template>/<dir>/` (recursive) | `.idea/` is never touched, in either mode |
| `_layouts/`, `_sass/`, `assets/` | `<template>/<dir>/` (recursive) | Self-hosted GitHub Pages theme (replaces the old `remote_theme: pages-themes/midnight`). If the target still has `remote_theme`/`theme` in its own `_config.yml`, see Step 5 — this is the main thing `dpx-fix-pages-rendering` and older indoctrinate targets need patched in |
| `CHANGELOG.md` | `<template>/CHANGELOG-dpx-template.md` | Structured merge only — see Step 5 |
| `README.md` | `<template>/readme_templates/README-dpx_{hardware,software,3d}_template.md` by type (or a newer sub-variant — footer-logo/inline-logo etc — if the user has a preference) | Needs string replacement — see Step 5 |
| `VERSION` | n/a — always written fresh as `0.1.0` | Never copied from template; ask before overwriting an existing value |
| `images/` | `<template>/images/` | Hardware: full set. Software/3D: `logo.png`, `front.png`, `dubpixel_identicon.png` only |
| `ibom/` | n/a — just create the empty dir | Hardware only |
| `platformio.ini` | pick one from `<template>/ini_files/` | Hardware only |
| firmware/src code templates | `<template>/code_templates/` → `firmware/src/` (hardware) or `src/` (software) | Offer the available options, don't silently omit |

## Step 5 — Judgment calls (this is the actual point of this skill)

- **`AGENTS.md` and `CLAUDE.md` are always a pair — never stamp one without
  the other.** If you update/sync a project's `AGENTS.md` and it has no root
  `CLAUDE.md` pointing at it (or `CLAUDE.md` is stale / missing the
  `@AGENTS.md` reference), create or fix `CLAUDE.md` in the same pass.
  **Relocate-alternate-doc check**: if a customized copy of either file
  lives somewhere other than root (e.g. `.github/AGENTS.md`,
  `docs/AGENTS.md`), don't silently stamp a blank root file that shadows it.
  Ask the user: move the old one to `<name>.old` at root + stamp fresh,
  leave it where it is + also stamp root, or skip stamping root entirely.
  If that alternate copy is clearly a stub/placeholder (not real customized
  content), you can skip asking and just note what you're doing.

- **Structural merge, not line-append.** For ordinary markdown/text files,
  insert missing template sections at their correct structural position
  relative to existing numbered sections — don't tack them onto the end or
  scatter lines mid-document. If the target already has project-specific
  content that overlaps a template section's *purpose* (e.g. an existing
  ad-hoc "Architecture" write-up where the template has a `PROJECT:` slot
  for exactly that), fold the real content into the template's slot — don't
  leave a half-filled placeholder sitting next to the user's actual data,
  and don't duplicate the same facts in two places.

- **`CHANGELOG.md` and any `*.yml`/`*.yaml` get edited as structured
  documents, never line-appended or blindly overwritten.** A changelog gets
  a new dated section in the right place; a YAML file gets a new key under
  the correct parent. A pure *addition* like this doesn't need to block on
  a question every time — state what you added and move on. Only ask first
  if the change would remove or rewrite something that's already there.
  **Pages theme migration**: if `_config.yml` already has a `remote_theme:`
  (e.g. `pages-themes/midnight`) or `theme:` key, that's a removal, so ask
  before deleting it — but it's a reasonable default to recommend doing so
  once `_layouts/`/`_sass/`/`assets/` are stamped, since the two theme
  sources will otherwise conflict (gem theme + local theme both claiming
  `default` layout — local wins, but the leftover `remote_theme:` key is
  dead weight and the gem dependency is pointless once local files exist).

- **README**: pick the type-appropriate default template, then apply the
  same string replacements the script does — `dpx_replace_projectName` →
  the project name (lowercase), the sassy-tagline placeholder, and the
  short-description placeholder — via `Edit`, not `sed`. Ask the user for
  tagline/description text if they want it customized and haven't given it
  to you; don't invent one for them. If `README.md` already exists and
  differs substantially from the template, don't overwrite blindly — ask:
  keep the existing file and drop the template alongside as a reference
  copy, do a structural merge, or replace outright.

- **`VERSION`**: create fresh as `0.1.0` if missing. If it already exists
  with a different value, ask before overwriting — don't silently stomp a
  real in-progress version number.

- **`images/`**: only ask the user about setup if there's a genuine
  conflict (existing files that differ from the template set) — not as a
  blanket yes/no gate the way the script does. If the directory doesn't
  exist or is empty, just create it and populate it per the hardware/
  software-3D split above, and say you did.

- **`ibom/`, `platformio.ini`, firmware code templates (hardware only)**:
  present the available options from `ini_files/` and `code_templates/` and
  let the user pick, or pick a sensible default yourself and say what you
  picked — don't silently skip these just because they're optional in the
  script.

- **What counts as "destructive" (gate on asking first)**: overwriting a
  file whose existing content differs from the template, deleting or moving
  any existing file, or applying a default that would replace real
  project-specific content. Pure additions — a brand-new file, a genuinely
  new structured section/key — don't need a question every time; just state
  what you're doing as you go, the same way the script's prompts would
  otherwise surface it to the user, minus the wall of canned prompts.

## Step 6 — Report what happened

Summarize, grouped by outcome: created / merged (with what was added) /
left alone (identical) / asked-about-and-resolved-how / skipped. The user
needs to be able to spot-check the result the way the script's own prompts
would otherwise have let them do live.

## Running the script directly (only if the user explicitly asks for it)

If the user explicitly wants the literal command instead of agent-performed
indoctrination — e.g. "just give me the command to run" — build it and hand
it off; don't run it yourself. The script reads interactive prompts from
`/dev/tty` (project type picker, per-file conflicts, the `images/`/`ibom/`
yes/no prompts — not skippable with `--force`, the extended README prompt),
so a backgrounded or piped Bash call will hang or fail. Suggest `! <command>`
in Claude Code, or a visible terminal, so the user can see the prompts.

| Flag | Meaning |
|------|---------|
| `<project_name>` | required, new-project mode only, first positional arg |
| `-H` / `-S` / `-D` | project type |
| `-I` / `--indoctrinate [target_path]` | indoctrinate mode; target path optional |
| `--force` | indoctrinate only — overwrite without the per-file prompt (does **not** suppress `images/`/`ibom/` prompts) |
| `-P` | interactively pick a README template instead of auto-selecting by type |
| `-C` | force `_...CODE/` destination (auto-on for `-S`) |
| `-V` | verbose |
| `-M 'tagline'` | sassy tagline → replaces the README placeholder |
| `-T 'text'` | project description → replaces the README placeholder |

Example: `./src/dpx_newProject.sh -I ~/path/to/old_project -H -M 'a sassy tagline' -T 'what this thing does'`

If they report something went wrong with the script's own logic (not a
one-off conflict they resolved themselves), file a GitHub issue per
`AGENTS.md` § 0 rather than patching `dpx_newProject.sh` — unless they
explicitly say to fix it now.
