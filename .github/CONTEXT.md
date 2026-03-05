# DPX New Project Template - System Reference

## Project Overview

Template generator for creating standardized dubpixel software and hardware projects with consistent structure, documentation, and tooling.

## Architecture

**Tech Stack:**
- Bash shell script (`dpx_newProject.sh`)
- Template-based file generation
- Git-based version control integration
- Jekyll for GitHub Pages documentation

**Core Components:**
1. Template repository (this repo)
2. Project generator script
3. Dual README templates (hardware/software variants)
4. GitHub workflows and issue templates

## Key Decisions

**Why two README templates:** Hardware and software projects have fundamentally different documentation needs. Hardware requires schematics, BOMs, and fabrication files. Software needs API docs and setup instructions.

**Why exclude .git during copy:** Prevents version control conflicts. New projects initialize their own git history.

**Why string replacement post-copy:** Allows template to remain generic while generated projects are immediately customized with correct names and metadata.

## File Structure

### Template Files (in this repo)
- `src/dpx_newProject.sh` - Main generator script
- `README-hardware_template.md` - Hardware project README
- `README-software_template.md` - Software project README  
- `CHANGELOG-dpx-template.md` - Template changelog
- `dpx_release_note_template.md` - Release note format
- `.github/` - Issue templates, PR templates, workflows, AGENTS.md

### Generated Project Structure
```
PROJECT_NAME/
├── README.md (selected template, renamed)
├── CHANGELOG.md (from CHANGELOG-dpx-template.md)
├── .gitignore
├── .gitattributes
├── _config.yml
├── dpx_release_note_template.md
├── images/
├── hardware/ (if hardware type)
│   ├── 3d/
│   ├── production_files_RTG/
│   ├── schematic/
│   ├── spec/
│   └── src/
├── firmware/ (if hardware type)
├── ibom/
└── .github/
```

## Development Setup

**Prerequisites:**
- Bash shell (macOS/Linux)
- Git
- Text editor

**Running the generator:**
```bash
cd src/
./dpx_newProject.sh
```

Follow interactive prompts to:
1. Select project type (hardware/software)
2. Enter project name
3. Specify destination path

## Configuration

No environment variables required. Script uses interactive prompts for configuration.

## Common Operations

### Creating a New Project
```bash
./src/dpx_newProject.sh
# Follow prompts
```

### Modifying Template Behavior
Edit `src/dpx_newProject.sh` - All copy/rename logic is centralized there.

### Adding New Template Files
1. Add file to template root or appropriate subdirectory
2. Update `dpx_newProject.sh` if file needs special handling (rename/conditional copy)

### Template File Processing Rules

| Source File | Hardware Projects | Software Projects |
|------------|-------------------|-------------------|
| `README-hardware_template.md` | → `README.md` | Not copied |
| `README-software_template.md` | Not copied | → `README.md` |
| `CHANGELOG-dpx-template.md` | → `CHANGELOG.md` | → `CHANGELOG.md` |
| `.gitignore`, `.gitattributes`, `_config.yml`, `dpx_release_note_template.md` | Copied as-is | Copied as-is |

**Folders copied recursively:** All except `.git` (always excluded) and `.idea` (excluded per script logic).