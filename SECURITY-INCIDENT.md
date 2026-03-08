# Security Incident Report

## Incident Summary
- **Date identified:** 2026-03-08
- **Type:** Secret exposure in repository content/history
- **Repository:** `JeremyAdair/LLMStackMac`
- **Severity:** High (credential material exposed in git history)

## Exposed Material (Confirmed)
- Hardcoded Flowise login credentials in `bin/create-flowise-rag-flows.ps1`.
- Authelia secret values in `config/auth/configuration.yml`.
- Tracked `.env.mac` containing local secret values.

## Containment and Remediation Performed
1. Removed hardcoded credentials from tracked scripts.
2. Replaced tracked secret literals in config with non-sensitive placeholders.
3. Added `.env.mac` to `.gitignore` and removed it from tracking.
4. Rewrote repository history to purge leaked values and `.env.mac` from all commits.
5. Verified leaked strings no longer appear in rewritten history.
6. Rotated runtime credentials locally:
- `AUTHELIA_JWT_SECRET` (rotated)
- `AUTHELIA_SESSION_SECRET` (rotated)
- `FLOWISE_USERNAME` / `FLOWISE_PASSWORD` (rotated)
7. Restored Authelia storage compatibility key required for existing DB encryption (to keep auth functional).
8. Force-pushed rewritten history to GitHub.

## Git History Rewrite Details
- **Backup branch before rewrite:** `backup/pre-breach-rewrite-20260308`
- **Sanitized head commit:** `d7ab538adbac0bc1078bb57eb4c9671a1c905cb4`
- **Force push completed:** `main` updated on origin with rewritten history.

## Service Validation After Remediation
- `auth`: healthy
- `flowise`: running
- `reverse-proxy`: running

## Remaining Follow-Up
1. In GitHub Secret Scanning, refresh/re-run and mark alert resolved after confirming no active secrets remain.
2. Rotate any external credentials if they were reused elsewhere.
3. Enable branch protection + required PR reviews for sensitive files.
4. Add pre-commit/CI secret scanning (for example, gitleaks) to prevent recurrence.

## Notes
- Authelia storage encryption key rotation requires planned migration for existing encrypted DB data; do not rotate in-place without migration procedure.
