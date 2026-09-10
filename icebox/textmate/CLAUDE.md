# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a personal TextMate 2 bundle (RyBundle.tmbundle) containing custom commands, snippets, macros, and preferences for text editing and development workflows.

## TextMate Bundle Structure

The bundle follows standard TextMate 2 bundle organization:
- **Commands/**: XML plist files defining custom commands for text manipulation
- **Snippets/**: Text snippets for quick insertion of boilerplate code
- **Macros/**: Recorded macro actions
- **Preferences/**: Editor preferences
- **Syntaxes/**: Language syntax definitions
- **Support/**: Supporting scripts and libraries
  - **lib/**: Perl scripts for text processing (align_pipes.pl, tableize_csvs.pl, underline_above.pl)
  - **test/**: Test files for support scripts

## Key Commands

The bundle includes various text manipulation commands:
- **Text Formatting**: Figlet, underline/hash line decorators, comma list formatting
- **CSV Operations**: Format CSV, CSV to Perl Hash, CSV to YAML
- **HTML/Markdown**: HTML boilerplate generation, Pandoc to MediaWiki conversion
- **Development Utilities**: Add SVN keywords, copy project GUID, work log entry tools

## Command File Format

Commands are XML plist files containing:
- `command`: Shell command or script to execute
- `input`: Input source (selection, document, etc.)
- `output`: Output destination (replaceSelectedText, newWindow, etc.)
- `keyEquivalent`: Keyboard shortcut binding
- `scope`: Language scope where command is available

## Working with This Bundle

When modifying commands:
1. Commands are XML plist files - maintain proper plist structure
2. Test commands through TextMate's Bundle Editor before committing
3. Support scripts in lib/ are Perl-based utilities for text processing
4. The info.plist defines menu organization and command ordering