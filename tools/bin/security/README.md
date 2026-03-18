# Security Tools

`defectdojo-gitleaks-scan` runs `gitleaks` in Docker against the repo, writes a
redacted JSON report to `data/security/gitleaks/latest.json`, and imports the
report into DefectDojo.

If `.gitleaks.toml` exists at the repo root, the scanner passes it to
`gitleaks` so targeted allowlists can suppress known false positives.

Usage:

```bash
./tools/bin/security/defectdojo-gitleaks-scan
./tools/bin/security/defectdojo-gitleaks-scan --scan-only
./tools/bin/security/defectdojo-gitleaks-scan --import-only
```
