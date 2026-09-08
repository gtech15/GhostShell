Ghost Shell

A command-line AI chat client built in Python, using OpenRouter for model access.

Overview

Ghost Shell is a terminal-based chatbot with a styled interface — formatted responses, markdown rendering, command history, and loading indicators — instead of plain text input/output.

Features
Formatted response panels with markdown and code rendering
Command history and input suggestions
Loading indicators during model responses
Works with any chat model available on OpenRouter
Clean exit handling (Ctrl+C / Ctrl+D)
Requirements
Python 3.10+
An OpenRouter API key (https://openrouter.ai)
Installation
bash
git clone https://github.com/yourusername/ghost-shell.git
cd ghost-shell
pip install -r requirements.txt

Create a .env file in the project root:

OPENROUTER_API_KEY=your_api_key_here
Usage
bash
python bot.py

Type a message and press Enter to chat. Type exit, quit, bye, or shutdown to end the session, or press Ctrl+C at any time.

Built With
openai (OpenRouter API client)
rich (terminal formatting)
prompt_toolkit (input handling)
python-dotenv (environment variables)
License

MIT License. See LICENSE.

Author

Goodluck Timothy
