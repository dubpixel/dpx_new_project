# Changelog

All notable changes to the DPX New Project Creator will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v0.5.7] - 2026-03-05

### Added
- CONTEXT.md file in .github/ directory following AGENTS.md standards
- Comprehensive architecture reference for AI agents
- Structured sections: Project Overview, Architecture, Key Decisions, File Structure, Development Setup, Configuration, Common Operations

### Changed
- Cleaned up AGENTS.md context directive sections for better clarity
- CONTEXT.md now follows clean, scannable format instead of verbose commentary style
- Improved documentation structure per agent workflow standards

## [v0.5.6] - 2026-03-05

### Added
- VERSION file in project root to manage script versioning
- Script displays version number on startup from VERSION file
- Comprehensive header following AGENTS.md file header standards
- CHANGELOG.md with complete git history documentation

### Changed
- Moved changelog from script header to CHANGELOG.md
- Simplified script file header to minimal format
- Reorganized documentation structure per AGENTS.md guidelines

### Fixed
- Fixed duplicate symlink resolution code in script

## [v0.5.5] - 2026-03-05

### Changed
- Removed LICENSE.txt copying from template folder
- New projects now initialize without license file (intentional licensing decision)

### Documentation
- Added AGENTS.md with AI assistant workflow standards
- Added PULL_REQUEST_TEMPLATE.md for GitHub workflows
- Removed legacy copilot-instructions.md

## [v0.5.4] - 2025-09-19

### Added
- Copilot instructions file for AI assistance guidelines

## [v0.5.3] - 2025-09-11

### Fixed
- Template directory path resolution for CIRCUIT_PROJECTS root structure

## [v0.5.2] - 2025-09-11

### Added
- Symlink support for script execution from bin directory
- Environment variable overrides: DPX_TEMPLATE_DIR, DPX_PROJECTS_DIR, DPX_ROOT
- Comprehensive path resolution logic for moved/symlinked scripts
- README section with installation and environment variable instructions

### Changed
- Improved project destination directory logic to use CIRCUIT_PROJECTS as root
- Template directory search now uses multiple fallback paths

## [v0.5.1] - 2025-09-10

### Added
- Flexible argument parsing allowing flags in any order
- -M flag for sassy tagline customization in README
- -C flag for extended project description in README
- String replacement for tagline and description placeholders

### Changed
- Project name now converted to lowercase in all README replacements
- Argument validation improved for new optional flags

## [v0.5.0] - 2025-09-10

### Added
- Software project support with -S flag
- Automatic src/ folder creation for software projects (skips hardware/firmware)
- Destination folder placement logic based on CIRCUIT_PROJECTS root

### Changed
- Hardware vs Software project folder handling differentiated
- Path resolution improved for template folder discovery

## [v0.4.0] - 2025-09-10

### Added
- String replacement function for README.md customization
- Project name placeholder replacement (dpx_replace_projectName)
- Lowercase conversion for project names in replacements

### Changed
- Completed Step 5 implementation (string replacement)

## [v0.3.0] - 2025-09-10

### Added
- Verbose output mode with -V flag
- Conditional echo statements for detailed operation logging
- Standard DPX project file structure (.gitignore, .gitattributes, _config.yml)
- Project documentation templates (CHANGELOG, README variants)
- Image assets and GitHub templates

### Changed
- Echo output behavior: default shows paths only, -V shows detailed operations
- Moved script to src/ subdirectory for better organization

## [v0.2.0] - 2025-09-10

### Added
- Parent directory creation with mkdir -p for nested folder structures
- Detailed echo statements for all file operations
- Gemfile copying from template
- .idea folder exclusion (like .git)

### Fixed
- File copy errors due to missing parent directories

## [v0.1.0] - 2025-09-10

### Added
- Initial script implementation with argument parsing
- Project name argument (required, first position)
- Project type flags: -H (hardware) or -S (software)
- Template directory resolution and validation
- Destination directory creation with existence checking
- Root-level file copying (.gitignore, .gitattributes, _config.yml, dpx_release_note_template.md)
- Recursive folder copying with .git exclusion
- README template selection and renaming based on project type
- CHANGELOG template copying and renaming
- Basic error handling and usage instructions

---

## Version History Summary

- **v0.5.x**: Version management, documentation improvements, license handling
- **v0.5.2-v0.5.3**: Symlink support and environment variables
- **v0.5.0-v0.5.1**: Flexible arguments, software project support, customization flags
- **v0.4.0**: README string replacement functionality
- **v0.3.0**: Verbose mode, project file structure
- **v0.1.0-v0.2.0**: Initial implementation, core file/folder copying

[v0.5.7]: https://github.com/dubpixel/dpx_new_project/compare/v0.5.6...v0.5.7
[v0.5.6]: https://github.com/dubpixel/dpx_new_project/compare/v0.5.5...v0.5.6
[v0.5.5]: https://github.com/dubpixel/dpx_new_project/compare/v0.5.4...v0.5.5
[v0.5.4]: https://github.com/dubpixel/dpx_new_project/compare/v0.5.3...v0.5.4
[v0.5.3]: https://github.com/dubpixel/dpx_new_project/compare/v0.5.2...v0.5.3
[v0.5.2]: https://github.com/dubpixel/dpx_new_project/compare/v0.5.1...v0.5.2
[v0.5.1]: https://github.com/dubpixel/dpx_new_project/compare/v0.5.0...v0.5.1
[v0.5.0]: https://github.com/dubpixel/dpx_new_project/compare/v0.4.0...v0.5.0
[v0.4.0]: https://github.com/dubpixel/dpx_new_project/compare/v0.3.0...v0.4.0
[v0.3.0]: https://github.com/dubpixel/dpx_new_project/compare/v0.2.0...v0.3.0
[v0.2.0]: https://github.com/dubpixel/dpx_new_project/compare/v0.1.0...v0.2.0
[v0.1.0]: https://github.com/dubpixel/dpx_new_project/releases/tag/v0.1.0