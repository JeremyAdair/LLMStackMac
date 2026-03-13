# `git-push`

Small private helper for this repo.

It pushes the selected branch to both configured remotes:

- `forgejo`
- `origin`

## Usage

From the repo root:

```bash
./tools/bin/git-push/git-push
```

Push a specific branch:

```bash
./tools/bin/git-push/git-push main
```

## Behavior

- Defaults to the current git branch.
- Fails fast if either `forgejo` or `origin` is missing.
- Scans the commits being pushed for obvious secret patterns before pushing.
- Pushes to `forgejo` first, then `origin`.
