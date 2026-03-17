# Security Tools

`defectdojo-gitleaks-scan` runs `gitleaks` in Docker against the repo, writes a
redacted JSON report to `data/security/gitleaks/latest.json`, and imports the
report into DefectDojo.

Usage:

```bash
./tools/bin/security/defectdojo-gitleaks-scan
./tools/bin/security/defectdojo-gitleaks-scan --scan-only
./tools/bin/security/defectdojo-gitleaks-scan --import-only
```
