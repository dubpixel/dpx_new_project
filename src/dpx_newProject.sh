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

# Check for minimum arguments (project name required)
if [ $# -lt 1 ]; then
    echo "Usage: $0 <project_name> [-H|-S] [-P] [-C] [-V] [-M 'sassy tagline'] [-T 'project description']"
    echo "  project_name: Name of the new project (required)"
    echo "  -H: Hardware project (default if omitted)"
    echo "  -S: Software project"
    echo "  -P: Interactively pick a README template"
    echo "  -C: Create project in _...CODE directory instead of _...CIRCUIT_PROJECTS"
    echo "  -V: Verbose output (optional)"
    echo "  -M 'message': Sassy tagline for the project (optional)"
    echo "  -T 'text': Longer description for the project (optional)"
    echo ""
    echo "Arguments can be in any order except project_name must be first"
    echo ""
    echo "Environment Variables (optional):"
    echo "  DPX_TEMPLATE_DIR: Override template directory location"
    echo "  DPX_PROJECTS_DIR: Override where new projects are created"
    echo "  DPX_ROOT: Base directory containing dpx_readme_template folder"
    echo ""
    echo "Examples:"
    echo "  $0 my_project -H                        # Create hardware project"
    echo "  $0 my_app -S -V                         # Create software project with verbose output"
    echo "  $0 my_project -H -P                     # Hardware project, pick README interactively"
    echo "  $0 my_app -S -C                         # Software project in _...CODE directory"
    echo "  $0 my_project -T 'desc' -M 'tag'        # With description and tagline (defaults to -H)"
    echo "  DPX_PROJECTS_DIR=~/projects $0 my_project -H  # Create in specific directory"
    exit 1
fi

# Initialize variables
PROJECT_NAME="$1"
shift # Remove project name from arguments
PROJECT_TYPE=""
VERBOSE=false
SASSY_TAGLINE=""
PROJECT_DESCRIPTION=""
PICK_README=false
USE_CODE_DIR=false

# Parse remaining arguments in any order
while [[ $# -gt 0 ]]; do
    case $1 in
        -H|-S)
            if [ -n "$PROJECT_TYPE" ]; then
                echo "Error: Cannot specify both -H and -S"
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
            echo "Error: Unknown option $1"
            exit 1
            ;;
    esac
done

# Default to hardware project if no type specified
if [ -z "$PROJECT_TYPE" ]; then
    PROJECT_TYPE="-H"
    echo "No project type specified, defaulting to Hardware (-H)"
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

# Determine destination directory
if [ -n "$DPX_PROJECTS_DIR" ]; then
    DEST_DIR="$DPX_PROJECTS_DIR/$PROJECT_NAME"
    echo "Using projects directory from DPX_PROJECTS_DIR: $DPX_PROJECTS_DIR"
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
        echo "Warning: Could not locate _...CODE directory, falling back to _...CIRCUIT_PROJECTS"
        USE_CODE_DIR=false
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
echo "Project type: $([ "$PROJECT_TYPE" = "-H" ] && echo "Hardware" || echo "Software")"

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
    # Create empty placeholder dirs
    mkdir -p "$DEST_DIR/ibom" "$DEST_DIR/images"
    [ "$VERBOSE" = true ] && echo "  Created placeholder dirs: ibom/ images/"

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
else
    # Software: just create src/ and images/
    echo "Step 2: Creating src/ for software project..."
    mkdir -p "$DEST_DIR/src" "$DEST_DIR/images"
    [ "$VERBOSE" = true ] && echo "  Created: src/ images/"
fi

# Step 3: Copy root level files
echo "Step 3: Copying root level files..."
for f in .gitignore .gitattributes _config.yml dpx_release_note_template.md Gemfile; do
    if [ -f "$TEMPLATE_DIR/$f" ]; then
        [ "$VERBOSE" = true ] && echo "  Copying $f"
        cp "$TEMPLATE_DIR/$f" "$DEST_DIR/$f"
    else
        echo "  Warning: $f not found in template, skipping"
    fi
done

# Step 3b: Copy dot-directories (.github, .idea, .vscode) if present in template
echo "Step 3b: Copying dot-directories..."
for dotdir in .github .idea .vscode; do
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
else
    echo "Step 6: Select code templates to copy to src/ (or skip)..."
    pick_code_templates "$TEMPLATE_DIR/code_templates" "$DEST_DIR/src"
fi

echo ""
echo "Project setup complete!"