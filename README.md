# Ghost Shell

A command-line AI chat client built in Python, using OpenRouter for model access.

<p align="center">
  <img src="assets/ghost_shell.webp" alt="Ghost Shell" width="400">
</p>

## Overview

Ghost Shell is a terminal-based chatbot with a styled interface — formatted response panels, markdown rendering, command history, and loading indicators — built as an alternative to plain `print()`/`input()` chat scripts. It connects to any chat model available through OpenRouter's API.

## Features

- Formatted response panels with markdown and code rendering
- Command history and input auto-suggestions
- Loading indicators during model responses
- Compatible with any chat model on OpenRouter
- Clean exit handling on Ctrl+C / Ctrl+D

## Requirements

- Python 3.10 or higher
- An OpenRouter API key: https://openrouter.ai

## Installation

```bash
git clone https://github.com/yourusername/ghost-shell.git
cd ghost-shell
pip install -r requirements.txt
```

Create a `.env` file in the project root:

```
OPENROUTER_API_KEY=your_api_key_here
```

## Usage

```bash
python bot.py
```

Type a message and press Enter to chat. Type `exit`, `quit`, `bye`, or `shutdown` to end the session, or press Ctrl+C at any time to exit immediately.

## Project Structure

```
ghost-shell/
├── bot.py
├── requirements.txt
├── .env
├── .gitignore
├── LICENSE
└── README.md
```

## Built With

- [openai](https://github.com/openai/openai-python) — API client, used with the OpenRouter endpoint
- [rich](https://github.com/Textualize/rich) — terminal formatting and output
- [prompt_toolkit](https://github.com/prompt-toolkit/python-prompt-toolkit) — input handling and history
- [python-dotenv](https://github.com/theskumar/python-dotenv) — environment variable loading

## License

This project is licensed under the MIT License. See `LICENSE` for details.

## Author

Goodluck Timothy
