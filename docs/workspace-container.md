# Workspace and Console

The practical workspace path in the current stack is the OpenHands bind mount:

- `data/openhands-workspace`

That path is also mounted into the browser console service at `/workspace`.

## Console behavior

- route: `https://llmstack.lan/console/`
- backend: `ttyd`
- shell command: `tmux new-session -A -s llmstack`

That means browser console sessions reconnect to the same persistent `tmux` session.

## OpenHands workspace behavior

OpenHands stores persistent app state in `openhands_data` and uses the workspace bind mount for repos and files. The default stack no longer grants `docker.sock` to OpenHands.

If you intentionally need Docker-backed OpenHands sandboxes, use:

- `compose/lab/openhands/docker-runtime.override.yml`

and treat it as a higher-trust mode.
