# ================================================================================
# PROJECT DOCUMENTATION
# ================================================================================
#
# This project includes AI-generated code assistance provided by GitHub Copilot.
# 
# GitHub Copilot is an AI programming assistant that helps developers write code
# more efficiently by providing suggestions and completing code patterns.
#
# Ground Rules for AI Assistance:
# - No modifications to working code without explicit request
# - Comprehensive commenting of all code and preservation of existing comments (remove comments that become false/obsolete)
# - Small, incremental changes to maintain code stability
# - Verification before implementation of any suggestions
# - Stay focused on the current task - do not jump ahead or suggest next steps
# - Answer only what is asked, do not anticipate or propose additional work
#
# The AI assistant will follow these directives to ensure code quality,
# maintainability, and collaborative development practices.
#
# ================================================================================
# DPX NEW PROJECT CREATOR
# ================================================================================
#
# Script Name: dpx_newProject.sh
# Architect: dubpixel / Joshua Fleitell
# Purpose: Automated project template generator for software and hardware projects
#
# FUNCTIONALITY OVERVIEW:
# 1) Template Copying: Recursively copies the DPX_BLANK_PROJECT_TEMPLATE folder
#    - Includes all files and directories (including hidden files/folders)
#    - Excludes .git folder to avoid version control conflicts
#    - Copies everything that is there except .git folder
#    - Supports both software and hardware project templates
#
# 2) Project Type Selection and File Processing:
#    - Hardware projects: README-hardware_template.md → README.md
#    - Software projects: README-software_template.md → README.md
#    - CHANGELOG-dpx-template.md → CHANGELOG.md (always copied and renamed)
#    - dpx_release_note_template.md → dpx_release_note_template.md (always copied as-is)
#    - LICENSE.txt → LICENSE.txt (always copied as-is)
#    - .gitignore → .gitignore (always copied as-is)
#    - .gitattributes → .gitattributes (always copied as-is)
#    - _config.yml → _config.yml (always copied as-is)
#
# 3) Root Level File Handling:
#    - Only specific files from root are copied (listed above)
#    - All template README variants are excluded from final project
#    - Other root files (like README.md, CHANGELOG.md, etc.) are not copied
#
# 4) Folder Structure Copying:
#    - All folders except .git are copied recursively and untouched
#    - Includes: images/, hardware/, firmware/, ibom/, .github/, .idea/, etc.
#    - No renaming of folders - copied as-is with full contents
#
#    KEY FILES TO COPY AS-IS:
#     - LICENSE.txt
#     - .gitignore
#     - .gitattributes
#     - _config.yml
#     - dpx_release_note_template.md
#
#   FOLDERS TO COPY RECURSIVELY (excluding .git and .idea):
#     - images/ (project images and assets)
#     - hardware/ (3d/, production_files_RTG/, schematic/, spec/, src/)
#     - firmware/ (firmware code structure)
#     - ibom/ (interactive BOM files)
#     - .github/ (GitHub templates and workflows)
#
#     ** Note: All folders copied as-is with full contents, no renaming
#
# 5) String Replacement: Post-copy processing to customize template files
#    - Updates project-specific strings in key files (README.md, etc.)
#    - Replaces placeholder text with actual project information
#    - Ensures project-specific customization after template deployment
#
# TEMPLATE FOLDER ANALYSIS:
# Based on the path structure, the template folder contains:
# 
# KEY FILES TO COPY AND RENAME:
# - README-hardware_template.md (becomes README.md for hardware projects)
# - README-software_template.md (becomes README.md for software projects)
# - CHANGELOG-dpx-template.md (becomes CHANGELOG.md)
#
# 
#
# ================================================================================
#
# CHANGE LOG:
# 
# User: "lets now write the script : it takes two arguments to start: first argument is the name of the new project and the second argument is the flag for hardware or software -H or -S - the script should encompas steps 1-4 for now and not step number 5"
#   → Added bash script implementation with argument parsing, path validation, and file copying logic
# 
# User: "ok make it work" (after copy errors for .github files)
#   → Fixed by adding mkdir -p before copying files to ensure parent directories exist
# 
# User: "ok so can u also echo wtf its doing?"
#   → Added detailed echo statements for all operations
# 
# User: "ok edit it to take a third argument -V for that level of verbosity otherwise just echo paths"
#   → Modified to accept 3rd argument -V for verbose mode, otherwise show only paths/steps
# 
# User: "can you actually inlcude verbatim what my prompt was? also lets move that section to around line 91-92 in the code."
#   → Moved change log to line ~91 and added verbatim user prompts
#
# User: "oh i want verbatim user prompts as one line and your solution itemized underneath if ui cam pls pagenate like that would be great thx"
#   → Reformatted change log with user prompts as single lines and solutions itemized underneath
#
# User: "ok so this looks like it works good so far lets put the last step into play -step 5. lets write a separate function to search and replace the string in the README.md file. This is pretty straightforwartd i usually do it manually in sublimetext - basically find and replace all."
#   → Added string replacement function for README.md file using sed to replace placeholder strings
#
# User: "ok so now heres a fun side quest. Take this shell script. leave the directives about how to be a good AI and make a programming file template in the firmware/src directory of te current project were working in?"
#   → Created programming file template with AI directives in firmware/src directory
#
# User: "ok make a variant of that, which is a shell script tamplate."
#   → Created shell script template variant in firmware/src directory
#
# User: "theres also a gemfile that we need to copy. - .ideas should have had files ithem idk what happened to them theyre back now."
#   → Need to add Gemfile to list of root files to copy and verify .idea files are being copied properly
#
# User: "im not even sure we need .idea. i thoght it had to do with something i configured to do with how the githuib pages formatting works"
#   → Added Gemfile to root files copy list, .idea folder may not be necessary (IDE-specific files)
#
# User: "ok lets exclude copying it for now but we can revisit it later"
#   → Modified folder copying to exclude .idea folder (like .git exclusion)
#
# User: "can you init this as a git repo"
#   → Will initialize the dpx_new_project folder as a git repository
#
# User: "ok so here is a twist on step #5. Id like the project name to always be searched and replaced in all lower case regardless of how its typed in as an argument can u do that?"
#   → Modified string replacement function to convert project name to lowercase before replacement
#
# User: "ok so somehwo youre still wokring in the old file can e just consolodate to the one version in one folder please"
#   → Consolidated to work only in dpx_new_project folder going forward
#
# User: "ok lets get rid of old file llease"
#   → Removed old script file from create_new_project_script folder
#
# User: "yep. looks good. lets make another change please. can the program find the template folder to copy based on the new location? can u update the file paths that this is correct and easier depending on hwere i move the template folder?"
#   → Updated path logic to search for template folder relative to script location and handle different locations
#
# User: "ok it needs to create the new project one more folder higher than it did. need to beef up that logic as well. always should be in the folder abouve ...DPX_BLANK etc."
#   → Updated destination directory logic to create projects in the folder above DPX_BLANK_PROJECT_TEMPLATE
#
# User: "ok so here is a twist on step #5. Id like the project name to always be searched and replaced in all lower case regardless of how its typed in as an argument can u do that?"
#   → Modified string replacement function to convert project name to lowercase before replacement
#
# ================================================================================

#!/bin/bash

# Script implementation - Steps 1-5

# Function to perform string replacement in README.md
replace_readme_strings() {
    local readme_file="$1"
    local project_name="$2"
    
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
    
    if [ "$VERBOSE" = true ]; then
        echo "  String replacement completed"
    fi
}

# Check for correct number of arguments
if [ $# -lt 2 ] || [ $# -gt 3 ]; then
    echo "Usage: $0 <project_name> <-H|-S> [-V]"
    echo "  project_name: Name of the new project"
    echo "  -H: Hardware project"
    echo "  -S: Software project"
    echo "  -V: Verbose output (optional)"
    exit 1
fi

# Parse arguments
PROJECT_NAME="$1"
PROJECT_TYPE="$2"
VERBOSE=false

# Check for verbose flag
if [ $# -eq 3 ] && [ "$3" = "-V" ]; then
    VERBOSE=true
elif [ $# -eq 3 ]; then
    echo "Error: Third argument must be -V for verbose output"
    exit 1
fi

# Validate project type flag
if [ "$PROJECT_TYPE" != "-H" ] && [ "$PROJECT_TYPE" != "-S" ]; then
    echo "Error: Project type must be -H (hardware) or -S (software)"
    exit 1
fi

# Set template source directory (search multiple possible locations)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Search for template directory in multiple possible locations
TEMPLATE_LOCATIONS=(
    "$SCRIPT_DIR/../../dpx_readme_template"                    # From DPX_NEW_PROJECT/src/
    "$SCRIPT_DIR/../dpx_readme_template"                       # From dpx_new_project/
    "$SCRIPT_DIR/../../_....DPX_BLANK_PROJECT_TEMPLATE/dpx_readme_template"  # From project root
    "$SCRIPT_DIR/../../../dpx_readme_template"                 # One level up from project
)

TEMPLATE_DIR=""
for location in "${TEMPLATE_LOCATIONS[@]}"; do
    if [ -d "$location" ]; then
        TEMPLATE_DIR="$location"
        break
    fi
done

# If not found in relative paths, try to find it by searching up the directory tree
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

DEST_DIR=""

# Find the DPX_BLANK_PROJECT_TEMPLATE folder and create projects one level above it
current_search="$SCRIPT_DIR"
while [ "$current_search" != "/" ]; do
    if [[ "$(basename "$current_search")" == *"DPX_BLANK_PROJECT_TEMPLATE"* ]]; then
        # Found the template folder, go one level up for destination
        DEST_DIR="$(dirname "$current_search")/$PROJECT_NAME"
        break
    fi
    current_search="$(dirname "$current_search")"
done

# Fallback if DPX_BLANK_PROJECT_TEMPLATE not found in path
if [ -z "$DEST_DIR" ]; then
    # Default behavior - create project relative to script location
    DEST_DIR="$SCRIPT_DIR/../../$PROJECT_NAME"
fi

echo "Debug info:"
echo "  Script directory: $SCRIPT_DIR"
echo "  Template directory: $TEMPLATE_DIR"
echo "  Destination directory: $DEST_DIR"
if [ "$VERBOSE" = true ]; then
    echo "  Verbose mode: ON"
else
    echo "  Verbose mode: OFF"
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
            if [ "$VERBOSE" = true ]; then
                echo "  Copying file: $rel_path"
            fi
            # Ensure parent directory exists
            mkdir -p "$(dirname "$DEST_DIR/$rel_path")"
            cp "$file" "$DEST_DIR/$rel_path"
        fi
    fi
done

# Step 3: Copy specific root level files as-is
echo "Step 3: Copying root level files..."
if [ "$VERBOSE" = true ]; then
    echo "  Copying LICENSE.txt"
fi
cp "$TEMPLATE_DIR/LICENSE.txt" "$DEST_DIR/LICENSE.txt"
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
replace_readme_strings "$DEST_DIR/README.md" "$PROJECT_NAME"

echo "Project setup complete!"