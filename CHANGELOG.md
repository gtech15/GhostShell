# Changelog

All notable changes to this project are documented here.
Format based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [0.4.1] - Unreleased

### Fixed
- **Logo/system-prompt not loading.** `assets/logo.txt` and
  `system_prompt.txt` used to be found by walking up three parents from
  `__file__` to a guessed repo root -- fragile, and it broke under some
  install methods (symptom: the CLI banner showed the literal fallback
  text "GhostShell" instead of the real mark). Both files now live
  *inside* the installed package (`src/ghostshell/`,
  `src/ghostshell/assets/`) and are found via a package-relative path
  that's correct for an editable install, a real wheel, or a moved
  folder alike. Verified by building an actual wheel and running it from
  an unrelated directory.
- **Blank `Enter` presses stacking up empty `>` lines.** The CLI now
  erases the blank prompt line instead of printing a new one below it,
  so repeatedly hitting Enter on nothing just sits still.
- **`/models` wasn't interactive.** `/models` and `/model` (no argument)
  now both open the same arrow-key + Enter picker over the live catalog;
  previously only the singular `/model` was interactive.

## [0.4.0]

### Added
- Local plugin system (`plugins.py`): drop a `.py` file defining `TOOL_SCHEMAS`
  + `DISPATCH` into `~/.ghostshell/plugins/` or `<workspace>/.ghostshell/plugins/`
  and its tools show up in the agent. New `/plugins` command and a Plugins
  tab in the web sidebar. See `examples/plugins/example_plugin.py`.
  (Not compatible with Claude Code's plugin format -- that's a different
  product with its own packaging; this is GhostShell's own mechanism.)
- Local free/paid model tagging (`model_tiers.py` + `/tier` command): NVIDIA
  doesn't expose a free-vs-paid flag per model via the API (it's a shared
  account credit pool, not a model property), so this is a tag *you* set,
  not something auto-detected -- `/models` and the web model picker group
  by it.
- CLI: `/model` with no argument now opens an interactive picker
  (questionary) over the live catalog instead of requiring you to type
  an exact model id.
- Web UI: full redesign -- glass/blur panels, message and modal animations,
  a left sidebar with Chats (saved sessions, click to load)/Files/Plugins
  tabs, a square (not pill) input box, a dedicated model-picker modal with
  search and free/paid tag buttons, a slash-command autocomplete menu, and
  collapsible tool-call chips instead of always-expanded raw tool output.
- New small REST endpoints backing the above: `/api/sessions`,
  `/api/plugins`, `/api/scope`, `/api/profile`, `/api/model-tiers`
  (GET/POST). `/api/models` now returns `{"groups": {...}, "live": bool}`.
- A GhostShell mark (rounded-square "prompt" glyph) used consistently in
  both the CLI banner and the web header.

### Changed
- `NVIDIA_BASE_URL` env var now overrides the API base URL, for people
  running a self-hosted NIM deployment instead of the hosted catalog.

### Removed
- Browser-native voice input from the web UI (removed at the user's
  request after initially being added).

## [0.3.0]

### Added
- First-run setup wizard (`ghostshell --setup`): asks for your name,
  NVIDIA API key, and default model once, saved to `~/.ghostshell/config.json`.
- Streaming responses -- both the CLI and web UI now show the model's
  answer as it's generated instead of waiting for the full response.
- Session save/load/list (`/save`, `/load`, `/sessions`) in both the CLI
  and web UI, persisted as JSON under `<workspace>/.ghostshell/sessions/`.
- New tools: `git_status`, `git_diff`, `git_commit`, `run_tests`,
  `grep_codebase`, `http_request` (authorized recon only), `write_report`
  (appends findings to `REPORT.md`).
- Optional `scope.yaml` -- when present, `run_shell` and `http_request`
  warn if a command/URL mentions a target outside the authorized list.
  See `scope.yaml.example`. New `/scope` command to view it.
- Web UI: file tree sidebar (`/api/tree`), browser-native voice input
  (Web Speech API), context-token estimate in the footer, scope-status
  pill in the header.
- `Dockerfile` for running the web UI in a container.
- `/whoami` command to show your saved display name.

### Changed
- `agent.run_turn` now streams and reports progress via callbacks
  (`on_text_chunk`, `on_tool_call`, `on_tool_result`) instead of printing
  directly, so the CLI and web server share one implementation.
- Confirmation prompts (`_confirm`) now use `questionary` for a nicer
  y/N prompt, falling back to plain `input()` if unavailable.

## [0.2.0]

### Added
- Agentic tool-calling loop: the model can now read, write, move, and
  delete files, list directories, and run shell commands.
- NVIDIA NIM backend with runtime model switching (`/model`, `/models`).
- Sandboxed workspace, confirmation prompts, hard-blocked destructive
  shell patterns, and a `.ghostshell.log` audit trail.
- `src/` package layout, `pyproject.toml`, pytest test suite, CI workflow.

### Changed
- Rebuilt from the original single-file prototype into a proper
  installable package (`pip install -e .` -> `ghostshell` command).

### Removed
- The forced "unrestricted assistant, no refusals" prompt-injection
  wrapper from the original prototype. The system prompt now plainly
  states the tool is for authorized security testing and refuses
  unauthorized-attack / malware requests.

## [0.1.0] - Initial prototype

- Single-file chat wrapper over an OpenRouter model.
