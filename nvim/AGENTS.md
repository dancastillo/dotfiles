# Repository Guidelines

## Project Structure & Module Organization
- `init.lua` is the main entry point for the Neovim configuration.
- `lua/` contains Lua modules (plugin configs, utilities, and feature-specific logic).
- `lazy-lock.json` pins plugin versions for repeatable installs.
- `spell/` stores custom spellfiles/dictionaries.
- `keymaps.txt` documents key mappings outside of code.

## Build, Test, and Development Commands
- `nvim` — launch Neovim with this configuration.
- `nvim --headless "+Lazy sync" +qa` — update plugins using lazy.nvim in headless mode.
- `nvim --headless "+checkhealth" +qa` — run Neovim health checks to validate providers.

## Coding Style & Naming Conventions
- Indentation: 2 spaces for Lua (follow existing files).
- Use descriptive module names under `lua/` (e.g., `lua/plugins/*.lua`, `lua/config/*.lua`).
- Prefer local functions and tables; keep globals minimal.
- Formatting: `stylua` is configured via `.stylua.toml` (run `stylua lua/ init.lua`).

## Testing Guidelines
- No automated test suite is defined for this configuration.
- Validate changes manually by launching `nvim` and exercising the affected features.
- For plugin changes, consider running `nvim --headless "+checkhealth" +qa`.

## Commit & Pull Request Guidelines
- This directory does not include Git history, so no local commit convention is discoverable.
- Recommended: use Conventional Commits (e.g., `feat: add telescope keymaps`).
- PRs should include: a clear description, linked issue (if any), and screenshots/gifs for UI changes.

## Security & Configuration Tips
- Avoid committing secrets in `init.lua` or module files.
- Pin plugin versions via `lazy-lock.json` to keep setups reproducible.
