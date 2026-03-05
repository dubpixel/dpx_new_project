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

# Check for correct number of arguments
if [ $# -lt 2 ]; then
    echo "Usage: $0 <project_name> <-H|-S> [-V] [-M 'sassy tagline'] [-C 'project description']"
    echo "  project_name: Name of the new project"
    echo "  -H: Hardware project"
    echo "  -S: Software project"
    echo "  -V: Verbose output (optional)"
    echo "  -M 'message': Sassy tagline for the project (optional)"
    echo "  -C 'comment': Longer description for the project (optional)"
    echo ""
    echo "Arguments can be in any order except project_name must be first"
    echo ""
    echo "Environment Variables (optional):"
    echo "  DPX_TEMPLATE_DIR: Override template directory location"
    echo "  DPX_PROJECTS_DIR: Override where new projects are created"
    echo "  DPX_ROOT: Base directory containing dpx_readme_template folder"
    echo ""
    echo "Examples:"
    echo "  $0 my_project -H                    # Create hardware project"
    echo "  $0 my_app -S -V                     # Create software project with verbose output"
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
        -C)
            if [ -z "$2" ] || [[ "$2" == -* ]]; then
                echo "Error: -C requires a description argument"
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

# Validate project type flag
if [ -z "$PROJECT_TYPE" ]; then
    echo "Error: Must specify either -H (hardware) or -S (software)"
    exit 1
elif [ "$PROJECT_TYPE" != "-H" ] && [ "$PROJECT_TYPE" != "-S" ]; then
    echo "Error: Project type must be -H (hardware) or -S (software)"
    exit 1
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
else
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

# Step 2: Copy all folders recursively (excluding .git)
echo "Step 2: Copying folder structure..."
find "$TEMPLATE_DIR" -type d -name ".git" -prune -o -name ".idea" -prune -o -type d -print | while read dir; do
    if [[ "$dir" != *".git"* ]] && [[ "$dir" != *".idea"* ]]; then
        rel_path="${dir#$TEMPLATE_DIR/}"
        if [ "$rel_path" != "$TEMPLATE_DIR" ]; then
            # For software projects (-S), skip hardware and firmware folders
            if [ "$PROJECT_TYPE" = "-S" ]; then
                if [[ "$rel_path" == "hardware"* ]] || [[ "$rel_path" == "firmware"* ]]; then
                    if [ "$VERBOSE" = true ]; then
                        echo "  Skipping directory (software project): $rel_path"
                    fi
                    continue
                fi
            fi
            
            if [ "$VERBOSE" = true ]; then
                echo "  Creating directory: $rel_path"
            fi
            mkdir -p "$DEST_DIR/$rel_path"
        fi
    fi
done

# Copy all files in folders (excluding .git)
echo "Step 2: Copying files in folders..."
find "$TEMPLATE_DIR" -type f | while read file; do
    if [[ "$file" != *".git/"* ]] && [[ "$file" != *".idea/"* ]]; then
        rel_path="${file#$TEMPLATE_DIR/}"
        # Skip root level files - they'll be handled separately
        if [[ "$rel_path" == *"/"* ]]; then
            # For software projects (-S), skip hardware and firmware files
            if [ "$PROJECT_TYPE" = "-S" ]; then
                if [[ "$rel_path" == "hardware/"* ]] || [[ "$rel_path" == "firmware/"* ]]; then
                    if [ "$VERBOSE" = true ]; then
                        echo "  Skipping file (software project): $rel_path"
                    fi
                    continue
                fi
            fi
            
            if [ "$VERBOSE" = true ]; then
                echo "  Copying file: $rel_path"
            fi
            # Ensure parent directory exists
            mkdir -p "$(dirname "$DEST_DIR/$rel_path")"
            cp "$file" "$DEST_DIR/$rel_path"
        fi
    fi
done

# For software projects, create a src folder instead of hardware/firmware
if [ "$PROJECT_TYPE" = "-S" ]; then
    echo "Step 2: Creating src folder for software project (instead of hardware/firmware)..."
    mkdir -p "$DEST_DIR/src"
    if [ "$VERBOSE" = true ]; then
        echo "  Created src/ directory for software project (replacing hardware/firmware folders)"
    fi
fi

# Step 3: Copy specific root level files as-is
echo "Step 3: Copying root level files..."
if [ "$VERBOSE" = true ]; then
    echo "  Copying .gitignore"
fi
cp "$TEMPLATE_DIR/.gitignore" "$DEST_DIR/.gitignore"
if [ "$VERBOSE" = true ]; then
    echo "  Copying .gitattributes"
fi
cp "$TEMPLATE_DIR/.gitattributes" "$DEST_DIR/.gitattributes"
if [ "$VERBOSE" = true ]; then
    echo "  Copying _config.yml"
fi
cp "$TEMPLATE_DIR/_config.yml" "$DEST_DIR/_config.yml"
if [ "$VERBOSE" = true ]; then
    echo "  Copying dpx_release_note_template.md"
fi
cp "$TEMPLATE_DIR/dpx_release_note_template.md" "$DEST_DIR/dpx_release_note_template.md"
if [ "$VERBOSE" = true ]; then
    echo "  Copying Gemfile"
fi
cp "$TEMPLATE_DIR/Gemfile" "$DEST_DIR/Gemfile"

# Step 4: Copy and rename template-specific files based on project type
echo "Step 4: Setting up project-specific files..."

# Copy and rename CHANGELOG template
if [ "$VERBOSE" = true ]; then
    echo "  Copying and renaming CHANGELOG-dpx-template.md to CHANGELOG.md"
fi
cp "$TEMPLATE_DIR/CHANGELOG-dpx-template.md" "$DEST_DIR/CHANGELOG.md"

# Copy and rename README template based on project type
if [ "$PROJECT_TYPE" = "-H" ]; then
    if [ "$VERBOSE" = true ]; then
        echo "  Copying and renaming README-hardware_template.md to README.md"
    fi
    cp "$TEMPLATE_DIR/README-hardware_template.md" "$DEST_DIR/README.md"
    echo "Using hardware README template"
else
    if [ "$VERBOSE" = true ]; then
        echo "  Copying and renaming README-software_template.md to README.md"
    fi
    cp "$TEMPLATE_DIR/README-software_template.md" "$DEST_DIR/README.md"
    echo "Using software README template"
fi

echo "Project $PROJECT_NAME created successfully at $DEST_DIR"

# Step 5: Call string replacement function
replace_readme_strings "$DEST_DIR/README.md" "$PROJECT_NAME" "$SASSY_TAGLINE" "$PROJECT_DESCRIPTION"

echo "Project setup complete!"