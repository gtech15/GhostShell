# GhostShell

[![CI](https://github.com/your-username/GhostShell/actions/workflows/ci.yml/badge.svg)](https://github.com/your-username/GhostShell/actions)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

An AI agent for **authorized** penetration testing and software
development work, powered by [NVIDIA NIM](https://build.nvidia.com) models.
Comes as both a terminal app and a local web UI, sharing the same agent core.

GhostShell can:
- Chat, with responses streaming in live
- Read, write, move, and delete files in a sandboxed workspace
- Run shell commands (always asks for confirmation first, unless `--auto-approve`)
- Use git (`status`/`diff`/`commit`), run your test suite, grep the codebase,
  make HTTP requests, and write findings into a running `REPORT.md`
- Switch between models from the live NVIDIA catalog -- an interactive
  picker in both the CLI and web UI, grouped by free/paid tags you set
  (NVIDIA doesn't publish that split, so GhostShell doesn't guess it)
- Save and resume conversations -- a Chats sidebar in the web UI, `/save` /
  `/load` / `/sessions` in the CLI
- Load local plugins -- drop a `.py` file in a folder and its tools show
  up in the agent (`/plugins`, see `examples/plugins/`)
- Warn (not block) when a command targets something outside an optional
  `scope.yaml` allow-list

## Quick start

```bash
git clone https://github.com/your-username/GhostShell.git
cd GhostShell
python -m venv venv
source venv/bin/activate
pip install -e ".[dev,web]"

ghostshell          # terminal UI -- first run asks your name + NVIDIA API key
# or
ghostshell-web      # browser UI at http://127.0.0.1:8000
```

Get a free NVIDIA API key at <https://build.nvidia.com>. The first time you
run `ghostshell`, it'll ask for your name, your key, and a default model,
then save that to `~/.ghostshell/config.json` so you're not asked again
(`ghostshell --setup` re-runs it any time). The web UI picks up the same
saved key automatically.

## Project layout

```
GhostShell/
├── src/ghostshell/
│   ├── cli.py                 # terminal app: loop, args, first-run wizard call
│   ├── commands.py            # slash-command handlers (/model, /save, /tier, ...)
│   ├── agent.py                # streaming tool-calling loop against NVIDIA NIM
│   ├── tools.py                 # sandboxed file/shell/git/http/report tools + plugin registration
│   ├── config.py                 # Settings dataclass
│   ├── models.py                  # live model discovery (/v1/models), no hardcoded catalog
│   ├── model_tiers.py              # your own free/paid tags for models (NVIDIA doesn't expose this)
│   ├── plugins.py                  # local plugin loader
│   ├── ui.py                        # CLI banner / tables / streaming output
│   ├── profile.py                   # global ~/.ghostshell/config.json + setup wizard
│   ├── scope.py                     # optional scope.yaml enforcement
│   ├── session.py                    # save/load conversations to JSON
│   ├── system_prompt.txt             # the agent's base system prompt (packaged inside, still plain-text editable)
│   ├── assets/logo.txt               # the "[>_]" mark shown in the CLI banner
│   └── web/
│       ├── server.py                  # FastAPI + websocket backend
│       └── static/index.html          # chat UI: sidebar, model picker, slash menu, streaming (has its own inline SVG logo)
├── examples/plugins/example_plugin.py  # template -- copy into a plugins/ folder to try it
├── tests/                      # pytest suite
├── .github/workflows/ci.yml    # lint + test on push/PR
├── scope.yaml.example          # copy to scope.yaml in a workspace to enable scope warnings
├── Dockerfile                  # runs the web UI in a container
├── pyproject.toml              # packaging + `ghostshell` / `ghostshell-web` console scripts
└── requirements*.txt
```

## Why this exists

This started as a jailbroken "unrestricted" chatbot wrapper. It's been
rebuilt from scratch as an honest, legit agent: no forced "ignore your
ethics" prompt injection, a real tool-calling loop, a sandboxed workspace,
and confirmation prompts before anything destructive happens. Use it for
work you're authorized to do.

## Usage

### Terminal

```bash
ghostshell
ghostshell --workspace ~/projects/x
ghostshell --model meta/llama-3.3-70b-instruct
ghostshell --list-models
ghostshell --auto-approve      # skip confirmation prompts (careful!)
ghostshell --setup             # re-run the name/API-key/model wizard
```

| Command | What it does |
|---|---|
| `/models` | list the live catalog, grouped by your free/paid tags |
| `/model` | pick a model interactively from the live catalog |
| `/model <id>` | switch directly to a model id |
| `/tier <id> free\|paid` | tag a model as free or paid (your own note -- see below) |
| `/auto on\|off` | toggle auto-approve for writes & shell commands |
| `/workspace <path>` | change the sandboxed working directory |
| `/clear` | clear conversation history |
| `/save [name]` | save the current conversation |
| `/load [name]` | load a saved conversation |
| `/sessions` | list saved conversations |
| `/plugins` | list loaded plugins |
| `/whoami` | show your saved display name |
| `/scope` | show the authorized-target scope, if any |
| `/help` | show commands |
| `/exit` | quit |

### Web UI

```bash
ghostshell-web --workspace ~/projects/x --port 8000
```

Open `http://127.0.0.1:8000`. The left sidebar (hamburger icon, top-left)
has three tabs: **Chats** (saved sessions, click to load, "New chat" to
start fresh), **Files** (the workspace tree), and **Plugins** (what's
loaded). The compass icon in the header opens the model picker -- search,
pick a model, or tag one Free/Paid with the small F/P buttons. Typing `/`
in the message box opens a command menu (arrow keys + Enter/Tab, or click).

The web server only confirms actions automatically when auto-approve is on
-- it has no terminal to show a y/N prompt to, so an unconfirmed write/shell
call with auto-approve off is simply declined. Toggle auto-approve in the
header when you want it to actually act.

### Docker (web UI only)

```bash
docker build -t ghostshell .
docker run -p 8000:8000 -e NVIDIA_API_KEY=nvapi-xxx -v $(pwd):/workspace ghostshell
```

## Scope file (optional)

Copy `scope.yaml.example` to `scope.yaml` in a workspace to get warnings
when a shell command or HTTP request mentions a target outside your
authorized list:

```yaml
authorized_targets:
  - 127.0.0.1
  - 192.168.1.0/24
  - example-authorized-target.com
```

This is advisory, not a hard block -- there's no reliable way to parse
every possible shell command for its real target. It makes risky commands
visible before you approve them; it doesn't replace reading what you're
about to run.

## Safety design

- **Sandboxed file ops** -- can't read/write/delete outside the configured workspace (path traversal blocked).
- **Confirm before impact** -- writes, deletes, moves, shell commands, HTTP requests, and git commits all prompt before running, unless `--auto-approve` / `/auto on`.
- **Hard-blocked commands** -- a short list of catastrophic shell patterns (`rm -rf /`, fork bombs, `mkfs`, etc.) is refused outright.
- **Scope warnings** -- optional `scope.yaml`, see above.
- **Audit log** -- every write/delete/move/shell/git/http/report action is appended to `.ghostshell.log`.
- **Editable system prompt** -- `src/ghostshell/system_prompt.txt` is a plain text file, not Python -- edit it directly, no code change needed. States plainly the agent is for *authorized* work and refuses unauthorized attacks. Guidance, not a technical control.

## Development

```bash
pip install -e ".[dev,web]"
ruff check src tests
pytest -q
```

CI (`.github/workflows/ci.yml`) runs both on every push/PR against Python 3.10–3.12.

## Extending it

- `src/ghostshell/models.py` -- model discovery is live (`/v1/models`), not hardcoded; tweak `FALLBACK_MODELS` only if you want a different offline fallback
- `src/ghostshell/tools.py` -- add a **built-in** tool here: write the function, add a schema entry to `TOOL_SCHEMAS`, add a dispatch entry to `DISPATCH`, add a test. For a tool you don't want to ship as part of core GhostShell, write a plugin instead (see below)
- `examples/plugins/example_plugin.py` -- template for a **plugin**: same `TOOL_SCHEMAS`/`DISPATCH` shape, but loaded at runtime from `~/.ghostshell/plugins/` or `<workspace>/.ghostshell/plugins/` with no code changes to GhostShell itself
- `src/ghostshell/commands.py` -- add new `/slash` commands (CLI); the web UI's equivalent slash-command list lives in `SLASH_COMMANDS` in `index.html`
- `src/ghostshell/web/static/index.html` -- the whole web UI is one file, vanilla JS, no build step

See `CONTRIBUTING.md` for the full workflow.

Ideas for next features: cost tracking against actual NVIDIA pricing, a
PyPI release, multi-step `/plan` mode where the model writes a task list
before executing, voice input (dropped for now at the user's request).

## License

MIT -- see `LICENSE`.
