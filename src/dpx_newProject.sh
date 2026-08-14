#!/bin/bash
# ================================================================================
# SHELL SCRIPT - DPX New Project Creator
# ================================================================================
# Automated project template generator for hardware and software projects
# ================================================================================
# PROJECT: DPX_NEW_PROJECT
# ================================================================================
#
# File: dpx_newProject.sh
# Purpose: Copy and customize project templates for new DPX hardware/software projects
# Dependencies: dpx_readme_template folder, bash, sed
#
#
#
# ================================================================================

# Function to perform string replacement in README.md
replace_readme_strings() {
    local readme_file="$1"
    local project_name="$2"
    local sassy_tagline="$3"
    local project_description="$4"
    
    # Convert project name to lowercase
    local project_name_lower=$(echo "$project_name" | tr '[:upper:]' '[:lower:]')
    
    if [ ! -f "$readme_file" ]; then
        echo "Error: README.md file not found at $readme_file"
        return 1
    fi
    
    echo "Step 5: Performing string replacement in README.md..."
    if [ "$VERBOSE" = true ]; then
        echo "  Replacing 'dpx_replace_projectName' with '$project_name_lower' (lowercase)"
    fi
    
    # Use sed to replace all instances of dpx_replace_projectName with the actual project name in lowercase
    sed -i '' "s/dpx_replace_projectName/$project_name_lower/g" "$readme_file"
    
    # Replace sassy tagline if provided
    if [ -n "$sassy_tagline" ]; then
        if [ "$VERBOSE" = true ]; then
            echo "  Replacing 'a sassy project tag line here' with '$sassy_tagline'"
        fi
        sed -i '' "s/a sassy project tag line here/$sassy_tagline/g" "$readme_file"
    fi
    
    # Replace project description if provided
    if [ -n "$project_description" ]; then
        if [ "$VERBOSE" = true ]; then
            echo "  Replacing '...a short description to tease interest' with '$project_description'"
        fi
        sed -i '' "s/\.\.\.a short description to tease interest/$project_description/g" "$readme_file"
    fi
    
    if [ "$VERBOSE" = true ]; then
        echo "  String replacement completed"
    fi
}

# Function: interactive README template picker
# $1 = readme_templates dir, $2 = default filename (basename) or empty
# Prints selected filename to stdout; all prompts go to stderr
select_readme_template() {
    local readme_dir="$1"
    local default_file="$2"

    local files=()
    while IFS= read -r f; do
        files+=("$(basename "$f")")
    done < <(find "$readme_dir" -maxdepth 1 -name "*.md" | sort)

    if [ ${#files[@]} -eq 0 ]; then
        echo "Warning: No .md files found in $readme_dir" >&2
        echo ""
        return
    fi

    echo "" >&2
    echo "  Select a README template:" >&2
    local i=1
    for f in "${files[@]}"; do
        local marker=""
        [ "$f" = "$default_file" ] && marker="  [default]"
        printf "    %d) %s%s\n" "$i" "$f" "$marker" >&2
        ((i++))
    done
    echo "" >&2

    # Find index of default
    local default_idx=0
    if [ -n "$default_file" ]; then
        local j=1
        for f in "${files[@]}"; do
            if [ "$f" = "$default_file" ]; then
                default_idx=$j
                break
            fi
            ((j++))
        done
    fi

    local choice
    while true; do
        if [ "$default_idx" -gt 0 ]; then
            printf "  Enter number [default: %d]: " "$default_idx" >&2
        else
            printf "  Enter number: " >&2
        fi
        read -r choice </dev/tty
        # Blank input → use default
        if [ -z "$choice" ] && [ "$default_idx" -gt 0 ]; then
            choice="$default_idx"
        fi
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#files[@]}" ]; then
            echo "${files[$((choice-1))]}"
            return
        fi
        echo "  Invalid selection, try again." >&2
    done
}

# Function: interactive code template picker (multi-select)
# $1 = code_templates dir, $2 = destination dir for selected files
pick_code_templates() {
    local src_dir="$1"
    local dest_dir="$2"

    local files=()
    while IFS= read -r f; do
        local bn
        bn="$(basename "$f")"
        [[ "$bn" == .DS_Store ]] && continue
        files+=("$bn")
    done < <(find "$src_dir" -maxdepth 1 -type f | sort)

    if [ ${#files[@]} -eq 0 ]; then
        echo "  No code templates found, skipping."
        return
    fi

    echo ""
    echo "  Available code templates:"
    local i=1
    for f in "${files[@]}"; do
        printf "    %d) %s\n" "$i" "$f"
        ((i++))
    done
    echo "    0) Skip"
    echo ""

    local choices
    printf "  Enter numbers (space-separated) or 0 to skip: "
    read -r choices </dev/tty

    if [ -z "$choices" ] || [ "$choices" = "0" ]; then
        echo "  Skipping code templates."
        return
    fi

    mkdir -p "$dest_dir"
    for c in $choices; do
        if [[ "$c" =~ ^[0-9]+$ ]] && [ "$c" -ge 1 ] && [ "$c" -le "${#files[@]}" ]; then
            local fname="${files[$((c-1))]}"
            cp "$src_dir/$fname" "$dest_dir/$fname"
            echo "  Copied: $fname → $(basename "$dest_dir")/"
        else
            echo "  Skipping invalid selection: $c"
        fi
    done
}

# Function: interactive ini file picker (single-select)
# $1 = ini_files dir, $2 = destination dir (project root)
pick_ini_file() {
    local src_dir="$1"
    local dest_dir="$2"

    local files=()
    local paths=()
    while IFS= read -r f; do
        # Show as subdir/filename for clarity
        files+=("$(basename "$(dirname "$f")")/$(basename "$f")")
        paths+=("$f")
    done < <(find "$src_dir" -name "*.ini" | sort)

    if [ ${#files[@]} -eq 0 ]; then
        echo "  No .ini files found in $src_dir, skipping."
        return
    fi

    echo ""
    echo "  Available ini files (PlatformIO configs):"
    local i=1
    for f in "${files[@]}"; do
        printf "    %d) %s\n" "$i" "$f"
        ((i++))
    done
    echo "    0) Skip"
    echo ""

    local choice
    while true; do
        printf "  Enter number or 0 to skip: "
        read -r choice </dev/tty
        if [ "$choice" = "0" ] || [ -z "$choice" ]; then
            echo "  Skipping ini file."
            return
        fi
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#files[@]}" ]; then
            cp "${paths[$((choice-1))]}" "$dest_dir/platformio.ini"
            echo "  Copied: ${files[$((choice-1))]} → platformio.ini"
            return
        fi
        echo "  Invalid selection, try again."
    done
}

# ================================================================================
# INDOCTRINATE MODE FUNCTIONS
# ================================================================================

# Function: prompt user to select project type interactively
# Prints -H, -S, or -D to stdout; all prompts go to stderr
pick_project_type() {
    echo "" >&2
    echo "  Select project type:" >&2
    echo "    1) Hardware (-H)" >&2
    echo "    2) Software (-S)" >&2
    echo "    3) 3D (-D)" >&2
    echo "" >&2
    local choice
    while true; do
        printf "  Enter number: " >&2
        read -r choice </dev/tty
        case "$choice" in
            1) echo "-H"; return ;;
            2) echo "-S"; return ;;
            3) echo "-D"; return ;;
            *) echo "  Invalid selection, try again." >&2 ;;
        esac
    done
}

# Function: list 10 most recently modified project dirs in a root folder
# $1 = root directory to scan
# Prints selected absolute path to stdout; all prompts go to stderr
pick_recent_project() {
    local root_dir="$1"

    if [ ! -d "$root_dir" ]; then
        echo "Error: Project root not found: $root_dir" >&2
        return 1
    fi

    local dirs=()
    while IFS= read -r d; do
        dirs+=("$d")
    done < <(
        find "$root_dir" -maxdepth 1 -mindepth 1 -type d \
            -not -name '.*' \
            -not -name '_....DPX_BLANK_PROJECT_TEMPLATE' |
        while IFS= read -r d; do
            printf "%s\t%s\n" "$(stat -f "%m" "$d" 2>/dev/null || echo 0)" "$d"
        done | sort -rn | head -10 | cut -f2-
    )

    if [ ${#dirs[@]} -eq 0 ]; then
        echo "Error: No project folders found in $root_dir" >&2
        return 1
    fi

    echo "" >&2
    echo "  Recent projects in $(basename "$root_dir"):" >&2
    local i=1
    for d in "${dirs[@]}"; do
        printf "    %d) %s\n" "$i" "$(basename "$d")" >&2
        ((i++))
    done
    echo "" >&2

    local choice
    while true; do
        printf "  Select a project (1-%d): " "${#dirs[@]}" >&2
        read -r choice </dev/tty
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#dirs[@]}" ]; then
            echo "${dirs[$((choice-1))]}"
            return
        fi
        echo "  Invalid selection, try again." >&2
    done
}

# Function: append lines from src that do not already exist in dest
# Prints count of appended lines to stdout
merge_append_unique() {
    local src="$1"
    local dest="$2"
    local count=0

    # If dest exists and doesn't end with a newline, appending via >> would
    # concatenate the first new line onto dest's existing last line. Fix by
    # emitting a newline first.
    if [ -s "$dest" ] && [ -n "$(tail -c1 "$dest")" ]; then
        printf '\n' >> "$dest"
    fi

    while IFS= read -r line; do
        if ! grep -qxF "$line" "$dest" 2>/dev/null; then
            echo "$line" >> "$dest"
            ((count++))
        fi
    done < "$src"
    echo "$count"
}

# Function: returns 0 (true) if the given filename is unsafe to line-merge.
# Naive line-append merging can't represent CHANGELOG.md's dated version
# sections or a YAML file's key/list nesting — merging those structurally
# either duplicates boilerplate or produces invalid/dangling syntax. These
# files should only ever be fully overwritten, skipped, or hand-edited.
is_merge_unsafe() {
    local name
    name="$(basename "$1")"
    case "$name" in
        CHANGELOG.md|*.yml|*.yaml) return 0 ;;
        *) return 1 ;;
    esac
}

# Function: copy a single file with conflict detection
# $1 = source file, $2 = destination file, $3 = display label (optional)
# Reads FORCE_OVERWRITE, OVERWRITE_ALL, MERGE_ALL globals
# May set OVERWRITE_ALL=true or MERGE_ALL=true
#
# Conflict options:
#   [y]es           — overwrite this file
#   [n]o            — skip this file
#   [m]erge         — append lines from template not already in destination
#   [a]ll-overwrite — overwrite this file and all remaining without prompting
#   [M]erge-all     — merge this file and all remaining without prompting
#
# NOTE: merge (m/M) is unsupported for files where is_merge_unsafe() is true
# (CHANGELOG.md, *.yml/*.yaml) — those only offer y/n/a.
copy_with_conflict() {
    local src="$1"
    local dest="$2"
    local label="${3:-$(basename "$dest")}"

    if [ ! -f "$dest" ]; then
        mkdir -p "$(dirname "$dest")"
        cp "$src" "$dest"
        [ "$VERBOSE" = true ] && echo "  Copied: $label"
        return
    fi

    local merge_unsafe=false
    is_merge_unsafe "$dest" && merge_unsafe=true

    # File exists — resolve conflict
    if [ "$FORCE_OVERWRITE" = true ] || [ "$OVERWRITE_ALL" = true ]; then
        cp "$src" "$dest"
        echo "  Overwritten: $label"
        return
    fi

    if [ "$MERGE_ALL" = true ]; then
        if [ "$merge_unsafe" = true ]; then
            echo "  Merge-all skipped for $label (merge unsupported for this file type) — left unchanged, reconcile manually."
            return
        fi
        local added
        added=$(merge_append_unique "$src" "$dest")
        echo "  Merged: $label (+${added} lines)"
        return
    fi

    local choice
    if [ "$merge_unsafe" = true ]; then
        printf "  %s exists — [y]es / [n]o / [a]ll-overwrite (merge unsupported for this file type): " "$label"
    else
        printf "  %s exists — [y]es / [n]o / [m]erge / [a]ll-overwrite / [M]erge-all: " "$label"
    fi
    read -r choice </dev/tty
    case "$choice" in
        y|Y)
            cp "$src" "$dest"
            echo "  Overwritten: $label"
            ;;
        m)
            if [ "$merge_unsafe" = true ]; then
                echo "  Skipped: $label (merge unsupported for this file type)"
            else
                local added
                added=$(merge_append_unique "$src" "$dest")
                echo "  Merged: $label (+${added} lines)"
            fi
            ;;
        M)
            if [ "$merge_unsafe" = true ]; then
                echo "  Skipped: $label (merge unsupported for this file type)"
            else
                MERGE_ALL=true
                local added
                added=$(merge_append_unique "$src" "$dest")
                echo "  Merged: $label (+${added} lines)  (merge-all mode)"
            fi
            ;;
        a|A)
            OVERWRITE_ALL=true
            cp "$src" "$dest"
            echo "  Overwritten: $label  (all-overwrite mode)"
            ;;
        *)
            echo "  Skipped: $label"
            ;;
    esac
}

# Function: recursively copy a directory with per-file conflict detection
# $1 = source dir, $2 = destination dir, $3 = display label
copy_dir_with_conflict() {
    local src_dir="$1"
    local dest_dir="$2"
    local label="$3"

    if [ ! -d "$src_dir" ]; then
        [ "$VERBOSE" = true ] && echo "  $label not found in template, skipping"
        return
    fi

    echo "  Processing $label/..."
    while IFS= read -r src_file; do
        local rel="${src_file#$src_dir/}"
        local dest_file="$dest_dir/$rel"
        copy_with_conflict "$src_file" "$dest_file" "$label/$rel"
    done < <(find "$src_dir" -type f | sort)
}

# Function: if a well-known root doc (AGENTS.md, CLAUDE.md) doesn't exist at
# the target project's root but a copy exists at one of a few conventional
# alternate locations, offer to relocate it before a fresh template copy
# lands at root. Without this, stamping a "new" root file silently shadows
# the project's real, customized doc instead of failing loudly.
# $1 = target project dir, $2 = filename (e.g. AGENTS.md)
# Sets RELOCATE_SKIP_ROOT_STAMP=true if the caller should skip stamping root.
relocate_alternate_doc() {
    local target_dir="$1"
    local name="$2"

    # Already at root — nothing to relocate
    [ -f "$target_dir/$name" ] && return

    local alt_locations=(".github/$name" "docs/$name")
    local found_rel=""
    for rel in "${alt_locations[@]}"; do
        if [ -f "$target_dir/$rel" ]; then
            found_rel="$rel"
            break
        fi
    done

    [ -z "$found_rel" ] && return

    echo ""
    echo "  Found existing $name at $found_rel (not at project root)."
    local choice
    printf "  [m]ove it to root as %s.old + stamp fresh template / [l]eave it + also stamp root %s / [s]kip stamping root %s: " "$name" "$name" "$name"
    read -r choice </dev/tty
    case "$choice" in
        m|M)
            mv "$target_dir/$found_rel" "$target_dir/${name}.old"
            echo "  Moved: $found_rel -> ${name}.old (root)"
            ;;
        s|S)
            RELOCATE_SKIP_ROOT_STAMP=true
            echo "  Skipped: root $name will not be stamped"
            ;;
        *)
            echo "  Leaving $found_rel in place; root $name will also be stamped"
            ;;
    esac
}

# Function: stamp template files into an existing project directory
# $1 = absolute path to the target project directory
indoctrinate_project() {
    local target_dir="$1"

    if [ ! -d "$target_dir" ]; then
        echo "Error: Target directory does not exist: $target_dir"
        exit 1
    fi

    echo ""
    echo "Indoctrinating: $(basename "$target_dir")"
    echo "  Path: $target_dir"
    echo ""

    OVERWRITE_ALL=false
    MERGE_ALL=false

    # Step I-1: Root files (mirrors Step 3 of new project creation)
    echo "Step 1: Stamping root files..."
    for f in .gitignore .gitattributes _config.yml dpx_release_note_template.md Gemfile AGENTS.md CLAUDE.md; do
        if [ -f "$TEMPLATE_DIR/$f" ]; then
            if [ "$f" = "AGENTS.md" ] || [ "$f" = "CLAUDE.md" ]; then
                RELOCATE_SKIP_ROOT_STAMP=false
                relocate_alternate_doc "$target_dir" "$f"
                if [ "$RELOCATE_SKIP_ROOT_STAMP" = true ]; then
                    continue
                fi
            fi
            copy_with_conflict "$TEMPLATE_DIR/$f" "$target_dir/$f" "$f"
        else
            echo "  Warning: $f not found in template, skipping"
        fi
    done

    # Step I-2: Dot-directories (mirrors Step 3b of new project creation)
    # .idea is intentionally excluded — it's JetBrains editor state, not
    # project template content, and the normal new-project flow already
    # excludes it (see the .github .vscode list used for fresh projects).
    echo "Step 2: Stamping dot-directories..."
    for dotdir in .github .vscode; do
        if [ -d "$TEMPLATE_DIR/$dotdir" ]; then
            copy_dir_with_conflict "$TEMPLATE_DIR/$dotdir" "$target_dir/$dotdir" "$dotdir"
        else
            [ "$VERBOSE" = true ] && echo "  $dotdir not in template, skipping"
        fi
    done

    # Step I-3: CHANGELOG (mirrors Step 4 of new project creation)
    echo "Step 3: Stamping CHANGELOG.md..."
    if [ -f "$TEMPLATE_DIR/CHANGELOG-dpx-template.md" ]; then
        copy_with_conflict "$TEMPLATE_DIR/CHANGELOG-dpx-template.md" "$target_dir/CHANGELOG.md" "CHANGELOG.md"
    fi

    # Step I-4: README (mirrors Step 4 — same template selection logic)
    echo "Step 4: Stamping README.md..."
    local readme_src=""
    local README_TEMPLATES_DIR_I="$TEMPLATE_DIR/readme_templates"
    if [ "$PICK_README" = true ]; then
        local default_readme=""
        if [ "$PROJECT_TYPE" = "-H" ]; then
            default_readme="README-dpx_hardware_template.md"
        elif [ "$PROJECT_TYPE" = "-D" ]; then
            default_readme="README-dpx_3d_template.md"
        else
            default_readme="README-dpx_software_template.md"
        fi
        local selected_readme
        selected_readme=$(select_readme_template "$README_TEMPLATES_DIR_I" "$default_readme")
        [ -z "$selected_readme" ] && selected_readme="$default_readme"
        readme_src="$README_TEMPLATES_DIR_I/$selected_readme"
        [ "$VERBOSE" = true ] && echo "  Selected: $selected_readme"
    else
        if [ "$PROJECT_TYPE" = "-H" ]; then
            readme_src="$README_TEMPLATES_DIR_I/README-dpx_hardware_template.md"
            echo "  Using hardware README template"
        elif [ "$PROJECT_TYPE" = "-D" ]; then
            readme_src="$README_TEMPLATES_DIR_I/README-dpx_3d_template.md"
            echo "  Using 3D README template"
        else
            readme_src="$README_TEMPLATES_DIR_I/README-dpx_software_template.md"
            echo "  Using software README template"
        fi
    fi
    if [ -f "$readme_src" ]; then
        # README gets an extended conflict prompt — [t]emplate copies the template
        # alongside the existing README.md as a reference without touching it
        if [ ! -f "$target_dir/README.md" ] \
            || [ "$FORCE_OVERWRITE" = true ] \
            || [ "$OVERWRITE_ALL" = true ] \
            || [ "$MERGE_ALL" = true ]; then
            # No conflict or bulk mode active — use standard handler
            copy_with_conflict "$readme_src" "$target_dir/README.md" "README.md"
        else
            # README.md exists and no bulk mode — show extended prompt with [t]emplate
            local readme_choice
            printf "  README.md exists — [y]es / [n]o / [m]erge / [t]emplate / [a]ll-overwrite / [M]erge-all: "
            read -r readme_choice </dev/tty
            case "$readme_choice" in
                y|Y)
                    cp "$readme_src" "$target_dir/README.md"
                    echo "  Overwritten: README.md"
                    ;;
                m)
                    local added
                    added=$(merge_append_unique "$readme_src" "$target_dir/README.md")
                    echo "  Merged: README.md (+${added} lines)"
                    ;;
                t|T)
                    # Pick a template interactively and copy it alongside README.md
                    echo "  Select a README template to copy alongside README.md:"
                    local tpl_pick
                    tpl_pick=$(select_readme_template "$README_TEMPLATES_DIR_I" "$(basename "$readme_src")")
                    if [ -n "$tpl_pick" ]; then
                        cp "$README_TEMPLATES_DIR_I/$tpl_pick" "$target_dir/$tpl_pick"
                        echo "  Copied: $tpl_pick  (README.md unchanged)"
                    else
                        echo "  No template selected — README.md unchanged"
                    fi
                    ;;
                M)
                    MERGE_ALL=true
                    local added
                    added=$(merge_append_unique "$readme_src" "$target_dir/README.md")
                    echo "  Merged: README.md (+${added} lines)  (merge-all mode)"
                    ;;
                a|A)
                    OVERWRITE_ALL=true
                    cp "$readme_src" "$target_dir/README.md"
                    echo "  Overwritten: README.md  (all-overwrite mode)"
                    ;;
                *)
                    echo "  Skipped: README.md"
                    ;;
            esac
        fi
    else
        echo "  Warning: README source not found at $readme_src"
    fi

    # Step I-5: VERSION — written fresh as 0.1.0 (never copied from template)
    echo "Step 5: Stamping VERSION..."
    if [ -f "$target_dir/VERSION" ]; then
        local existing_ver
        existing_ver=$(cat "$target_dir/VERSION")
        local ver_choice
        printf "  VERSION exists (%s) — overwrite with 0.1.0? [y/n]: " "$existing_ver"
        read -r ver_choice </dev/tty
        if [[ "$ver_choice" =~ ^[yY]$ ]]; then
            echo "0.1.0" > "$target_dir/VERSION"
            echo "  Written: VERSION → 0.1.0"
        else
            echo "  Skipped: VERSION"
        fi
    else
        echo "0.1.0" > "$target_dir/VERSION"
        echo "  Created: VERSION → 0.1.0"
    fi

    # Step I-6: String replacement in README (mirrors Step 5)
    if [ -f "$target_dir/README.md" ]; then
        replace_readme_strings "$target_dir/README.md" "$PROJECT_NAME" "$SASSY_TAGLINE" "$PROJECT_DESCRIPTION"
    fi

    # Step I-7: images/ — always prompt; content differs by project type (mirrors Step 2)
    echo "Step 7: images/ directory..."
    local img_choice
    if [ -d "$target_dir/images" ]; then
        printf "  images/ already exists — populate/update it? [y/n]: "
    else
        printf "  images/ not found — set it up? [y/n]: "
    fi
    read -r img_choice </dev/tty
    if [[ "$img_choice" =~ ^[yY]$ ]]; then
        mkdir -p "$target_dir/images"
        if [ "$PROJECT_TYPE" = "-H" ]; then
            # Hardware: copy all template images
            if [ -d "$TEMPLATE_DIR/images" ]; then
                while IFS= read -r img_file; do
                    copy_with_conflict "$img_file" \
                        "$target_dir/images/$(basename "$img_file")" \
                        "images/$(basename "$img_file")"
                done < <(find "$TEMPLATE_DIR/images" -maxdepth 1 -type f | sort)
            fi
        else
            # Software/3D: copy only the brand/placeholder images
            for img in logo.png front.png dubpixel_identicon.png; do
                if [ -f "$TEMPLATE_DIR/images/$img" ]; then
                    copy_with_conflict "$TEMPLATE_DIR/images/$img" \
                        "$target_dir/images/$img" "images/$img"
                fi
            done
        fi
    else
        echo "  Skipped images/."
    fi

    # Step I-8: ibom/ — hardware only, always prompt
    if [ "$PROJECT_TYPE" = "-H" ]; then
        echo "Step 8: ibom/ directory..."
        local ibom_choice
        if [ -d "$target_dir/ibom" ]; then
            printf "  ibom/ already exists — set it up anyway? [y/n]: "
        else
            printf "  ibom/ not found — create it? [y/n]: "
        fi
        read -r ibom_choice </dev/tty
        if [[ "$ibom_choice" =~ ^[yY]$ ]]; then
            mkdir -p "$target_dir/ibom"
            echo "  ibom/ ready."
        else
            echo "  Skipped ibom/."
        fi
    fi

    # Step I-9: platformio.ini — hardware only (mirrors Step 6)
    if [ "$PROJECT_TYPE" = "-H" ]; then
        echo "Step 9: Select an ini file to copy as platformio.ini (or skip)..."
        pick_ini_file "$TEMPLATE_DIR/ini_files" "$target_dir"
    fi

    # Step I-10: Code templates (mirrors Steps 6/7)
    if [ "$PROJECT_TYPE" = "-H" ]; then
        echo "Step 10: Select code templates for firmware/src/ (or skip)..."
        pick_code_templates "$TEMPLATE_DIR/code_templates" "$target_dir/firmware/src"
    elif [ "$PROJECT_TYPE" = "-S" ]; then
        echo "Step 10: Select code templates for src/ (or skip)..."
        pick_code_templates "$TEMPLATE_DIR/code_templates" "$target_dir/src"
    else
        echo "Step 10: 3D project — no code templates to select."
    fi

    echo ""
    echo "Indoctrination complete!"
    echo "  Project : $PROJECT_NAME"
    echo "  Path    : $target_dir"
}

# Resolve actual script location (handle symlinks)
if [ -L "${BASH_SOURCE[0]}" ]; then
    # Script is a symlink, resolve to actual location
    ACTUAL_SCRIPT="$(readlink "${BASH_SOURCE[0]}")"
    if [[ "$ACTUAL_SCRIPT" != /* ]]; then
        # Relative symlink, make it absolute
        ACTUAL_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd "$(dirname "$ACTUAL_SCRIPT")" && pwd)/$(basename "$ACTUAL_SCRIPT")"
    fi
else
    # Script is not a symlink
    ACTUAL_SCRIPT="${BASH_SOURCE[0]}"
fi

SCRIPT_DIR="$(cd "$(dirname "$ACTUAL_SCRIPT")" && pwd)"

# Read version from VERSION file in project root
VERSION_FILE="$(dirname "$SCRIPT_DIR")/VERSION"
if [ -f "$VERSION_FILE" ]; then
    SCRIPT_VERSION=$(cat "$VERSION_FILE")
    echo "DPX New Project Creator $SCRIPT_VERSION"
else
    SCRIPT_VERSION="unknown"
    echo "DPX New Project Creator (version unknown)"
fi
echo ""

# Pre-scan args for indoctrinate mode before the PROJECT_NAME positional check
INDOCTRINATE_MODE=false
for _arg in "$@"; do
    if [[ "$_arg" == "-I" || "$_arg" == "--indoctrinate" ]]; then
        INDOCTRINATE_MODE=true
        break
    fi
done

# Check for minimum arguments
# In indoctrinate mode no positional args are required (target path is optional)
if [ "$INDOCTRINATE_MODE" = false ] && [ $# -lt 1 ]; then
    echo "Usage:"
    echo "  New project : $0 <project_name> [-H|-S|-D] [-P] [-C] [-V] [-M 'tagline'] [-T 'desc']"
    echo "  Indoctrinate: $0 -I [target_path] [-H|-S|-D] [--force] [-P] [-V] [-M 'tagline'] [-T 'desc']"
    echo ""
    echo "  project_name : Name of the new project (required for new project mode)"
    echo "  -H           : Hardware project (default if omitted in new project mode)"
    echo "  -S           : Software project"
    echo "  -D           : 3D project — creates src/STL/ structure, places in _.DPX_3d_LIB"
    echo "  -I / --indoctrinate : Stamp template files into an existing project"
    echo "  --force      : (indoctrinate) Overwrite existing files without prompting"
    echo "  -P           : Interactively pick a README template"
    echo "  -C           : Create project in _...CODE directory instead of _...CIRCUIT_PROJECTS"
    echo "  -V           : Verbose output (optional)"
    echo "  -M 'message' : Sassy tagline for the project (optional)"
    echo "  -T 'text'    : Longer description for the project (optional)"
    echo ""
    echo "Environment Variables (optional):"
    echo "  DPX_TEMPLATE_DIR: Override template directory location"
    echo "  DPX_PROJECTS_DIR: Override where new projects are created"
    echo "  DPX_ROOT: Base directory containing dpx_readme_template folder"
    echo "  DPX_3D_DIR: Override where new 3D projects are created"
    echo ""
    echo "Examples:"
    echo "  $0 my_project -H                              # Create hardware project"
    echo "  $0 my_app -S -V                               # Create software project (verbose)"
    echo "  $0 my_project -H -P                           # Hardware project, pick README"
    echo "  $0 my_model -D                                # 3D project in _.DPX_3d_LIB"
    echo "  $0 my_project -T 'desc' -M 'tag'              # With description and tagline"
    echo "  $0 -I -H                                      # Indoctrinate: pick from recent hardware projects"
    echo "  $0 -I /path/to/existing -H                    # Indoctrinate specific project"
    echo "  $0 -I /path/to/existing -H --force            # Indoctrinate, overwrite without prompting"
    echo "  DPX_PROJECTS_DIR=~/projects $0 my_project -H  # Create in specific directory"
    exit 1
fi

# Initialize variables
INDOCTRINATE_TARGET=""
FORCE_OVERWRITE=false
OVERWRITE_ALL=false
PROJECT_TYPE=""
VERBOSE=false
SASSY_TAGLINE=""
PROJECT_DESCRIPTION=""
PICK_README=false
USE_CODE_DIR=false

# In new project mode, first positional arg is the project name
if [ "$INDOCTRINATE_MODE" = false ]; then
    PROJECT_NAME="$1"
    shift
fi

# Parse remaining arguments in any order
while [[ $# -gt 0 ]]; do
    case $1 in
        -I|--indoctrinate)
            shift  # already captured in pre-scan above
            ;;
        --force)
            FORCE_OVERWRITE=true
            shift
            ;;
        -H|-S|-D)
            if [ -n "$PROJECT_TYPE" ]; then
                echo "Error: Cannot specify more than one project type (-H, -S, -D)"
                exit 1
            fi
            PROJECT_TYPE="$1"
            shift
            ;;
        -P)
            PICK_README=true
            shift
            ;;
        -C)
            USE_CODE_DIR=true
            shift
            ;;
        -V)
            VERBOSE=true
            shift
            ;;
        -M)
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "Error: -M requires a message argument"
                exit 1
            fi
            SASSY_TAGLINE="$2"
            shift 2
            ;;
        -T)
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "Error: -T requires a text argument"
                exit 1
            fi
            PROJECT_DESCRIPTION="$2"
            shift 2
            ;;
        *)
            # In indoctrinate mode the first non-flag positional arg is the target path
            if [ "$INDOCTRINATE_MODE" = true ] && [ -z "$INDOCTRINATE_TARGET" ] && [[ "$1" != -* ]]; then
                INDOCTRINATE_TARGET="$1"
                shift
            else
                echo "Error: Unknown option $1"
                exit 1
            fi
            ;;
    esac
done

# Type resolution — indoctrinate mode prompts if not provided; new project defaults to -H
if [ -z "$PROJECT_TYPE" ]; then
    if [ "$INDOCTRINATE_MODE" = true ]; then
        PROJECT_TYPE=$(pick_project_type)
    else
        PROJECT_TYPE="-H"
        echo "No project type specified, defaulting to Hardware (-H)"
    fi
fi

# Software projects default to _...CODE directory unless DPX_PROJECTS_DIR is explicitly set
if [ "$PROJECT_TYPE" = "-S" ] && [ -z "$DPX_PROJECTS_DIR" ]; then
    USE_CODE_DIR=true
fi

# 3D projects default to _.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS unless DPX_3D_DIR is explicitly set
USE_3D_DIR=false
if [ "$PROJECT_TYPE" = "-D" ] && [ -z "$DPX_3D_DIR" ]; then
    USE_3D_DIR=true
fi

# Derive DPX_SOFTWARE_DIR from DPX_PROJECTS_DIR if not explicitly set
if [ -z "$DPX_SOFTWARE_DIR" ] && [ -n "$DPX_PROJECTS_DIR" ]; then
    # Find parent of DPX_PROJECTS_DIR and look for _...CODE there
    PROJECTS_PARENT="$(dirname "$DPX_PROJECTS_DIR")"
    if [ -d "$PROJECTS_PARENT/_...CODE" ]; then
        DPX_SOFTWARE_DIR="$PROJECTS_PARENT/_...CODE"
    fi
fi

# Environment variable overrides (for flexibility when symlinked or moved)
if [ -n "$DPX_TEMPLATE_DIR" ]; then
    TEMPLATE_DIR="$DPX_TEMPLATE_DIR"
    echo "Using template directory from DPX_TEMPLATE_DIR: $TEMPLATE_DIR"
elif [ -n "$DPX_ROOT" ]; then
    TEMPLATE_DIR="$DPX_ROOT/_....DPX_BLANK_PROJECT_TEMPLATE/dpx_readme_template"
    echo "Using template directory from DPX_ROOT: $TEMPLATE_DIR"
else
    # Search for template directory - first try to find CIRCUIT_PROJECTS root, then look for template there
    current_search="$SCRIPT_DIR"
    while [ "$current_search" != "/" ]; do
        if [[ "$(basename "$current_search")" == *"CIRCUIT_PROJECTS"* ]]; then
            # Found the DPX root, look for template there
            if [ -d "$current_search/_....DPX_BLANK_PROJECT_TEMPLATE/dpx_readme_template" ]; then
                TEMPLATE_DIR="$current_search/_....DPX_BLANK_PROJECT_TEMPLATE/dpx_readme_template"
                break
            fi
        fi
        current_search="$(dirname "$current_search")"
    done
    
    # If not found via CIRCUIT_PROJECTS search, try relative paths from script location
    if [ -z "$TEMPLATE_DIR" ]; then
        TEMPLATE_LOCATIONS=(
            "$SCRIPT_DIR/../../dpx_readme_template"                    # From DPX_NEW_PROJECT/src/
            "$SCRIPT_DIR/../dpx_readme_template"                       # From dpx_new_project/
            "$SCRIPT_DIR/../../../dpx_readme_template"                 # One level up from project
        )

        for location in "${TEMPLATE_LOCATIONS[@]}"; do
            if [ -d "$location" ]; then
                TEMPLATE_DIR="$location"
                break
            fi
        done
    fi

    # If still not found, try searching up the directory tree from script location
    if [ -z "$TEMPLATE_DIR" ]; then
        current_dir="$SCRIPT_DIR"
        while [ "$current_dir" != "/" ]; do
            if [ -d "$current_dir/dpx_readme_template" ]; then
                TEMPLATE_DIR="$current_dir/dpx_readme_template"
                break
            fi
            current_dir="$(dirname "$current_dir")"
        done
    fi
fi

# ================================================================================
# INDOCTRINATE MODE — resolve target and run; exits before new-project flow
# ================================================================================
if [ "$INDOCTRINATE_MODE" = true ]; then

    # Resolve the scan root based on project type (for interactive picker)
    SCAN_ROOT=""
    if [ "$PROJECT_TYPE" = "-S" ] || [ "$USE_CODE_DIR" = true ]; then
        # Look for _...CODE sibling
        current_search="$SCRIPT_DIR"
        while [ "$current_search" != "/" ]; do
            parent="$(dirname "$current_search")"
            if [ -d "$parent/_...CODE" ]; then
                SCAN_ROOT="$parent/_...CODE"
                break
            fi
            current_search="$parent"
        done
        # Fallback: find CIRCUIT_PROJECTS then look for _...CODE alongside it
        if [ -z "$SCAN_ROOT" ]; then
            current_search="$SCRIPT_DIR"
            while [ "$current_search" != "/" ]; do
                if [[ "$(basename "$current_search")" == *"CIRCUIT_PROJECTS"* ]]; then
                    parent="$(dirname "$current_search")"
                    [ -d "$parent/_...CODE" ] && SCAN_ROOT="$parent/_...CODE"
                    break
                fi
                current_search="$(dirname "$current_search")"
            done
        fi
    elif [ "$PROJECT_TYPE" = "-D" ]; then
        # Look for _.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS
        current_search="$SCRIPT_DIR"
        while [ "$current_search" != "/" ]; do
            parent="$(dirname "$current_search")"
            if [ -d "$parent/_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS" ]; then
                SCAN_ROOT="$parent/_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS"
                break
            fi
            current_search="$parent"
        done
    else
        # Hardware — look for _...CIRCUIT_PROJECTS
        current_search="$SCRIPT_DIR"
        while [ "$current_search" != "/" ]; do
            if [[ "$(basename "$current_search")" == *"CIRCUIT_PROJECTS"* ]]; then
                SCAN_ROOT="$current_search"
                break
            fi
            current_search="$(dirname "$current_search")"
        done
    fi

    # If no explicit target, launch interactive picker
    if [ -z "$INDOCTRINATE_TARGET" ]; then
        if [ -z "$SCAN_ROOT" ]; then
            echo "Error: Could not locate project root directory to scan"
            exit 1
        fi
        echo "No target path given — pick from recent projects in: $SCAN_ROOT"
        INDOCTRINATE_TARGET=$(pick_recent_project "$SCAN_ROOT")
        if [ -z "$INDOCTRINATE_TARGET" ]; then
            echo "Error: No project selected"
            exit 1
        fi
    fi

    # Validate target exists
    if [ ! -d "$INDOCTRINATE_TARGET" ]; then
        echo "Error: Target path does not exist: $INDOCTRINATE_TARGET"
        exit 1
    fi

    # Check template dir was resolved
    if [ ! -d "$TEMPLATE_DIR" ]; then
        echo "Error: Template directory not found at $TEMPLATE_DIR"
        exit 1
    fi

    # Derive project name from target directory basename
    PROJECT_NAME="$(basename "$INDOCTRINATE_TARGET")"

    echo "Indoctrinate mode"
    echo "  Template dir : $TEMPLATE_DIR"
    echo "  Target       : $INDOCTRINATE_TARGET"
    echo "  Project name : $PROJECT_NAME"
    echo "  Project type : $PROJECT_TYPE"
    if [ "$FORCE_OVERWRITE" = true ]; then echo "  Force        : ON"; fi
    if [ "$VERBOSE" = true ]; then echo "  Verbose      : ON"; fi
    echo ""

    indoctrinate_project "$INDOCTRINATE_TARGET"
    exit 0
fi

# Determine destination directory
# For software projects, prefer DPX_SOFTWARE_DIR; for hardware, prefer DPX_PROJECTS_DIR; for 3D, prefer DPX_3D_DIR
if [ "$PROJECT_TYPE" = "-D" ] && [ -n "$DPX_3D_DIR" ]; then
    DEST_DIR="$DPX_3D_DIR/$PROJECT_NAME"
    echo "Using 3D directory from DPX_3D_DIR: $DPX_3D_DIR"
elif [ "$PROJECT_TYPE" = "-S" ] && [ -n "$DPX_SOFTWARE_DIR" ]; then
    DEST_DIR="$DPX_SOFTWARE_DIR/$PROJECT_NAME"
    echo "Using software directory from DPX_SOFTWARE_DIR: $DPX_SOFTWARE_DIR"
elif [ "$PROJECT_TYPE" != "-S" ] && [ "$PROJECT_TYPE" != "-D" ] && [ -n "$DPX_PROJECTS_DIR" ]; then
    DEST_DIR="$DPX_PROJECTS_DIR/$PROJECT_NAME"
    echo "Using projects directory from DPX_PROJECTS_DIR: $DPX_PROJECTS_DIR"
elif [ "$USE_3D_DIR" = true ]; then
    # Walk up from script dir looking for _.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS
    THREE_D_ROOT=""
    current_search="$SCRIPT_DIR"
    while [ "$current_search" != "/" ]; do
        parent="$(dirname "$current_search")"
        if [ -d "$parent/_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS" ]; then
            THREE_D_ROOT="$parent/_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS"
            break
        fi
        current_search="$parent"
    done

    if [ -n "$THREE_D_ROOT" ]; then
        DEST_DIR="$THREE_D_ROOT/$PROJECT_NAME"
        echo "Using 3D directory: $THREE_D_ROOT"
    else
        # Fallback: find CIRCUIT_PROJECTS then look for _.DPX_3d_LIB at the same parent level
        current_search="$SCRIPT_DIR"
        while [ "$current_search" != "/" ]; do
            if [[ "$(basename "$current_search")" == *"CIRCUIT_PROJECTS"* ]]; then
                PARENT_OF_CIRCUITS="$(dirname "$current_search")"
                if [ -d "$PARENT_OF_CIRCUITS/_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS" ]; then
                    DEST_DIR="$PARENT_OF_CIRCUITS/_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS/$PROJECT_NAME"
                    echo "Using 3D directory: $PARENT_OF_CIRCUITS/_.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS"
                    break
                fi
            fi
            current_search="$(dirname "$current_search")"
        done

        # Only fall back if we still don't have a destination
        if [ -z "$DEST_DIR" ]; then
            echo "Warning: Could not locate _.DPX_3d_LIB/DPX_3d/_.3D_PROJECTS, falling back to _...CIRCUIT_PROJECTS"
            USE_3D_DIR=false
        fi
    fi
elif [ "$USE_CODE_DIR" = true ]; then
    # Walk up from script dir looking for a sibling _...CODE directory
    CODE_ROOT=""
    current_search="$SCRIPT_DIR"
    while [ "$current_search" != "/" ]; do
        parent="$(dirname "$current_search")"
        if [ -d "$parent/_...CODE" ]; then
            CODE_ROOT="$parent/_...CODE"
            break
        fi
        current_search="$parent"
    done

    if [ -n "$CODE_ROOT" ]; then
        DEST_DIR="$CODE_ROOT/$PROJECT_NAME"
        echo "Using Code directory: $CODE_ROOT"
    else
        # If still not found and project type is -S, look harder by finding CIRCUIT_PROJECTS first
        if [ "$PROJECT_TYPE" = "-S" ]; then
            current_search="$SCRIPT_DIR"
            while [ "$current_search" != "/" ]; do
                if [[ "$(basename "$current_search")" == *"CIRCUIT_PROJECTS"* ]]; then
                    PARENT_OF_CIRCUITS="$(dirname "$current_search")"
                    if [ -d "$PARENT_OF_CIRCUITS/_...CODE" ]; then
                        DEST_DIR="$PARENT_OF_CIRCUITS/_...CODE/$PROJECT_NAME"
                        echo "Using Code directory: $PARENT_OF_CIRCUITS/_...CODE"
                        break
                    fi
                fi
                current_search="$(dirname "$current_search")"
            done
        fi

        # Only fall back if we still don't have a destination
        if [ -z "$DEST_DIR" ]; then
            echo "Warning: Could not locate _...CODE directory, falling back to _...CIRCUIT_PROJECTS"
            USE_CODE_DIR=false
        fi
    fi
fi

if [ -z "$DEST_DIR" ]; then
    # Find the _...CIRCUIT_PROJECTS folder (the DPX root)
    current_search="$SCRIPT_DIR"
    while [ "$current_search" != "/" ]; do
        if [[ "$(basename "$current_search")" == *"CIRCUIT_PROJECTS"* ]]; then
            # Found the DPX root, create projects here
            DEST_DIR="$current_search/$PROJECT_NAME"
            break
        fi
        current_search="$(dirname "$current_search")"
    done

    # Fallback if CIRCUIT_PROJECTS not found in path
    if [ -z "$DEST_DIR" ]; then
        # Default behavior - create project in current working directory
        DEST_DIR="$(pwd)/$PROJECT_NAME"
        echo "Warning: Could not locate _...CIRCUIT_PROJECTS folder, creating project in current directory"
    fi
fi

echo "Debug info:"
echo "  Script location: $ACTUAL_SCRIPT"
echo "  Script directory: $SCRIPT_DIR"
echo "  Template directory: $TEMPLATE_DIR"
echo "  Destination directory: $DEST_DIR"
if [ "$VERBOSE" = true ]; then
    echo "  Verbose mode: ON"
else
    echo "  Verbose mode: OFF"
fi
if [ "$PICK_README" = true ]; then echo "  README picker: ON"; fi
if [ "$USE_CODE_DIR" = true ]; then echo "  Code directory mode: ON"; fi
if [ "$USE_3D_DIR" = true ]; then echo "  3D directory mode: ON"; fi
if [ -n "$SASSY_TAGLINE" ]; then
    echo "  Sassy tagline: $SASSY_TAGLINE"
fi
if [ -n "$PROJECT_DESCRIPTION" ]; then
    echo "  Project description: $PROJECT_DESCRIPTION"
fi

# Check if template directory exists
if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Error: Template directory not found at $TEMPLATE_DIR"
    exit 1
fi

# Check if destination already exists
if [ -d "$DEST_DIR" ]; then
    echo "Error: Project directory $DEST_DIR already exists"
    echo "Please remove it first or choose a different project name"
    exit 1
fi

echo "Creating new project: $PROJECT_NAME"
if [ "$PROJECT_TYPE" = "-H" ]; then
    echo "Project type: Hardware"
elif [ "$PROJECT_TYPE" = "-D" ]; then
    echo "Project type: 3D"
else
    echo "Project type: Software"
fi

# Step 1: Create destination directory
echo "Step 1: Creating destination directory..."
mkdir -p "$DEST_DIR"
if [ "$VERBOSE" = true ]; then
    echo "  Created: $DEST_DIR"
fi

# Directories that are NEVER copied into new projects (template-internal only)
ALWAYS_EXCLUDE=(".git" "readme_templates" "template_inspiration" "code_templates" "ini_files")

# Helper: returns 0 (true) if rel_path starts with any always-excluded entry
is_excluded() {
    local rel="$1"
    for excl in "${ALWAYS_EXCLUDE[@]}"; do
        if [[ "$rel" == "$excl" ]] || [[ "$rel" == "$excl/"* ]]; then
            return 0
        fi
    done
    return 1
}

# Step 2: Copy folder structure and files
echo "Step 2: Copying folder structure..."

if [ "$PROJECT_TYPE" = "-H" ]; then
    # Hardware: only copy hardware/ and firmware/ trees
    find "$TEMPLATE_DIR" -type d | while IFS= read -r dir; do
        rel_path="${dir#$TEMPLATE_DIR/}"
        [ -z "$rel_path" ] && continue
        is_excluded "$rel_path" && { [ "$VERBOSE" = true ] && echo "  Skipping excluded: $rel_path"; continue; }
        if [[ "$rel_path" == "hardware"* ]] || [[ "$rel_path" == "firmware"* ]]; then
            [ "$VERBOSE" = true ] && echo "  Creating directory: $rel_path"
            mkdir -p "$DEST_DIR/$rel_path"
        fi
    done
    # Create placeholder dirs and copy full images set for hardware projects
    mkdir -p "$DEST_DIR/ibom" "$DEST_DIR/images"
    [ "$VERBOSE" = true ] && echo "  Created placeholder dirs: ibom/ images/"
    if [ -d "$TEMPLATE_DIR/images" ]; then
        cp "$TEMPLATE_DIR/images/"* "$DEST_DIR/images/" 2>/dev/null
        [ "$VERBOSE" = true ] && echo "  Copied template images to images/"
    fi

    echo "Step 2: Copying hardware/firmware files..."
    find "$TEMPLATE_DIR" -type f | while IFS= read -r file; do
        rel_path="${file#$TEMPLATE_DIR/}"
        is_excluded "$rel_path" && { [ "$VERBOSE" = true ] && echo "  Skipping excluded file: $rel_path"; continue; }
        if [[ "$rel_path" == "hardware/"* ]] || [[ "$rel_path" == "firmware/"* ]]; then
            [ "$VERBOSE" = true ] && echo "  Copying file: $rel_path"
            mkdir -p "$(dirname "$DEST_DIR/$rel_path")"
            cp "$file" "$DEST_DIR/$rel_path"
        fi
    done
elif [ "$PROJECT_TYPE" = "-D" ]; then
    # 3D: create src/STL/ and images/
    echo "Step 2: Creating src/STL/ for 3D project..."
    mkdir -p "$DEST_DIR/src/STL" "$DEST_DIR/images"
    [ "$VERBOSE" = true ] && echo "  Created: src/STL/ images/"
    if [ -d "$TEMPLATE_DIR/images" ]; then
        for img in logo.png front.png dubpixel_identicon.png; do
            [ -f "$TEMPLATE_DIR/images/$img" ] && cp "$TEMPLATE_DIR/images/$img" "$DEST_DIR/images/$img"
        done
        [ "$VERBOSE" = true ] && echo "  Copied software template images (logo, front, identicon)"
    fi
else
    # Software: create src/ and images/, copy software-relevant placeholder images
    echo "Step 2: Creating src/ for software project..."
    mkdir -p "$DEST_DIR/src" "$DEST_DIR/images"
    [ "$VERBOSE" = true ] && echo "  Created: src/ images/"
    if [ -d "$TEMPLATE_DIR/images" ]; then
        for img in logo.png front.png dubpixel_identicon.png; do
            [ -f "$TEMPLATE_DIR/images/$img" ] && cp "$TEMPLATE_DIR/images/$img" "$DEST_DIR/images/$img"
        done
        [ "$VERBOSE" = true ] && echo "  Copied software template images (logo, front, identicon)"
    fi
fi

# Step 3: Copy root level files
echo "Step 3: Copying root level files..."
for f in .gitignore .gitattributes _config.yml dpx_release_note_template.md Gemfile AGENTS.md CLAUDE.md; do
    if [ -f "$TEMPLATE_DIR/$f" ]; then
        [ "$VERBOSE" = true ] && echo "  Copying $f"
        cp "$TEMPLATE_DIR/$f" "$DEST_DIR/$f"
    else
        echo "  Warning: $f not found in template, skipping"
    fi
done

# Step 3b: Copy dot-directories (.github, .idea, .vscode) if present in template
echo "Step 3b: Copying dot-directories..."
for dotdir in .github .vscode; do
    if [ -d "$TEMPLATE_DIR/$dotdir" ]; then
        [ "$VERBOSE" = true ] && echo "  Copying $dotdir/"
        cp -r "$TEMPLATE_DIR/$dotdir" "$DEST_DIR/$dotdir"
    else
        [ "$VERBOSE" = true ] && echo "  $dotdir not found in template, skipping"
    fi
done

# Step 4: Copy and rename template-specific files based on project type
echo "Step 4: Setting up project-specific files..."

# CHANGELOG
if [ -f "$TEMPLATE_DIR/CHANGELOG-dpx-template.md" ]; then
    [ "$VERBOSE" = true ] && echo "  Copying CHANGELOG-dpx-template.md → CHANGELOG.md"
    cp "$TEMPLATE_DIR/CHANGELOG-dpx-template.md" "$DEST_DIR/CHANGELOG.md"
fi

# README — pick source
README_TEMPLATES_DIR="$TEMPLATE_DIR/readme_templates"

if [ "$PICK_README" = true ]; then
    # Determine default for pre-highlight based on project type
    if [ "$PROJECT_TYPE" = "-H" ]; then
        DEFAULT_README="README-dpx_hardware_template.md"
    elif [ "$PROJECT_TYPE" = "-D" ]; then
        DEFAULT_README="README-dpx_3d_template.md"
    else
        DEFAULT_README="README-dpx_software_template.md"
    fi
    echo "Step 4: Picking README template interactively..."
    SELECTED_README=$(select_readme_template "$README_TEMPLATES_DIR" "$DEFAULT_README")
    if [ -z "$SELECTED_README" ]; then
        echo "  No selection made, using default for project type"
        SELECTED_README="$DEFAULT_README"
    fi
    README_SRC="$README_TEMPLATES_DIR/$SELECTED_README"
    [ "$VERBOSE" = true ] && echo "  Selected: $SELECTED_README"
else
    if [ "$PROJECT_TYPE" = "-H" ]; then
        README_SRC="$README_TEMPLATES_DIR/README-dpx_hardware_template.md"
        echo "  Using hardware README template"
    elif [ "$PROJECT_TYPE" = "-D" ]; then
        README_SRC="$README_TEMPLATES_DIR/README-dpx_3d_template.md"
        echo "  Using 3D README template"
    else
        README_SRC="$README_TEMPLATES_DIR/README-dpx_software_template.md"
        echo "  Using software README template"
    fi
fi

if [ -f "$README_SRC" ]; then
    [ "$VERBOSE" = true ] && echo "  Copying $(basename "$README_SRC") → README.md"
    cp "$README_SRC" "$DEST_DIR/README.md"
else
    echo "  Warning: README source not found at $README_SRC"
fi

echo "Project $PROJECT_NAME created successfully at $DEST_DIR"

# Step 5: String replacement in README.md
replace_readme_strings "$DEST_DIR/README.md" "$PROJECT_NAME" "$SASSY_TAGLINE" "$PROJECT_DESCRIPTION"

# Step 6 & 7: Interactive template prompts
if [ "$PROJECT_TYPE" = "-H" ]; then
    echo "Step 6: Select an ini file to copy as platformio.ini (or skip)..."
    pick_ini_file "$TEMPLATE_DIR/ini_files" "$DEST_DIR"

    echo "Step 7: Select code templates to copy to firmware/src/ (or skip)..."
    pick_code_templates "$TEMPLATE_DIR/code_templates" "$DEST_DIR/firmware/src"
elif [ "$PROJECT_TYPE" = "-D" ]; then
    echo "Step 6: 3D project — no code templates to select."
else
    echo "Step 6: Select code templates to copy to src/ (or skip)..."
    pick_code_templates "$TEMPLATE_DIR/code_templates" "$DEST_DIR/src"
fi

echo ""
echo "Project setup complete!"