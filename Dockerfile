# Runs the GhostShell web UI in a container. The CLI isn't meant to be
# run this way (it needs an interactive TTY for confirmations) -- this
# image is for the web server specifically.
FROM python:3.12-slim

WORKDIR /app

COPY pyproject.toml README.md LICENSE system_prompt.txt ./
COPY src ./src
COPY assets ./assets

RUN pip install --no-cache-dir -e ".[web]"

# Mount your project here: docker run -v $(pwd):/workspace ...
VOLUME ["/workspace"]
WORKDIR /workspace

EXPOSE 8000

# 0.0.0.0 so it's reachable from outside the container -- the server itself
# has no auth, so only publish this port on networks you trust.
CMD ["ghostshell-web", "--workspace", "/workspace", "--host", "0.0.0.0", "--port", "8000"]
