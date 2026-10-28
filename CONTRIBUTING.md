# Contributing to GhostShell

Thanks for considering a contribution! A few guidelines to keep the
project easy to maintain.

## Setup

```bash
git clone https://github.com/your-username/GhostShell.git
cd GhostShell
python -m venv venv
source venv/bin/activate
pip install -e ".[dev,web]"
ghostshell --setup   # saves your NVIDIA API key to ~/.ghostshell/config.json
```

## Project layout

```
src/ghostshell/
  cli.py          terminal app: loop, args, first-run wizard call
  commands.py     slash-command handlers (/model, /save, /tier, ...)
  agent.py        streaming tool-calling loop against NVIDIA NIM
  tools.py        sandboxed file/shell/git/http/report tools + plugin registration
  config.py       Settings dataclass
  models.py       live model discovery (/v1/models)
  model_tiers.py  local free/paid model tags (NVIDIA doesn't expose this via the API)
  plugins.py      local plugin loader
  ui.py           banner / tables / streaming output
  profile.py      global ~/.ghostshell/config.json + setup wizard
  scope.py        optional scope.yaml enforcement
  session.py      save/load conversations to JSON
  web/
    server.py          FastAPI + websocket backend
    static/index.html  web chat UI (single file, vanilla JS)
  system_prompt.txt   agent's base system prompt (packaged inside, not at repo root -- see config.py's PACKAGE_ROOT note for why)
  assets/logo.txt     the "[>_]" mark shown in the CLI banner
examples/plugins/  plugin template(s) -- not auto-loaded, copy to try
tests/          pytest test suite
```

## Adding a new tool

1. Write the function in `tools.py` (keep it sandboxed to `workspace`,
   and ask for confirmation via `_confirm()` before anything destructive).
2. Add its JSON schema to `TOOL_SCHEMAS`.
3. Add a one-line lambda to `DISPATCH`.
4. Add a test in `tests/test_tools.py`.

## Models

There's no hardcoded model list to maintain -- `models.py` fetches the
live catalog from NVIDIA's `/v1/models` endpoint for whatever API key is
in use, so it can't go stale. `models.FALLBACK_MODELS` is only used if
that live call fails outright (no network, no key yet); if you touch it,
keep it small and keep the "verify at build.nvidia.com/models" framing --
it's explicitly not meant to be trusted as current.

## Before opening a PR

```bash
ruff check src tests
pytest -q
```

## Code of conduct

Be respectful. This tool is built for *authorized* security work and
legitimate development -- contributions that add features explicitly
meant for unauthorized access, malware, or jailbreak-style prompt
injection will be declined.
