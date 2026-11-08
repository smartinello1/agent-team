# Changelog

All notable changes to the agent-team plugin. Versions follow `version` in `.claude-plugin/plugin.json`; update the plugin with `/plugin marketplace update agent-team` to get a new one.

## 1.5.0 — 2026-11-08
- **Guardrail hook**: a `PreToolUse` hook asks for confirmation before destructive database commands (Prisma/Drizzle reset or push, Rails/Django/Laravel/Sequelize/TypeORM resets, `dropdb`, raw `DROP`/`TRUNCATE` through a database client, Redis/Mongo flushes, linked Supabase resets) unless the target is clearly local. It covers the leader and every subagent. Tests: `bash hooks/guard-destructive-db.test.sh`.
- **Evals**: `evals/` adds five behaviour tests for `claude plugin eval`: the leader delegates to `backend-engineer`, the leader asks about legal rules instead of guessing, `code-reviewer` catches an off-by-one, `security-engineer` catches cross-tenant access, and the handbook doesn't invent a vision.
- **Model aliases**: agents use `opus` and `sonnet` instead of pinned model IDs, so they follow new releases. Pin a full ID in an agent's `model:` for stable behaviour.
- Added this changelog.

## 1.4.0 — 2026-11-08
- Handbook: `docs/product/vision.md` is optional and written only from the user's product direction. `docs/product/domain.md` is created with the first domain rule. The leader never invents product direction, and there are no empty template files.

## 1.3.0 — 2026-11-08
- Restored the `code-reviewer` step in the leader's planning flow and the agent count in the README.
- Version bump to ship the `project-handbook` skill from 1.2.x.

## 1.2.x — 2026-11-08
- New `code-reviewer` agent (Opus, read-only): independent correctness review of non-trivial changes, with a `block` / `fix before done` / `pass` verdict. Runs in parallel with `security-engineer`.
- `e2e-tester` can explore the running app in a live browser when browser tools are available (local/test URLs and accounts only).
- `backend-engineer` owns CI pipelines.
- New `project-handbook` skill: the leader keeps a `docs/` handbook with one entry point, an append-only decision log, an architecture overview and ADRs.

## 1.1.0 — 2026-11-08
- The leader runs tasks in parallel only across agents that own different apps, never two instances of the same agent, so there are no conflicting edits to reconcile.

## 1.0.0 — 2026-11-07
- First release: Opus `team-leader` as the default agent, Sonnet specialists (backend, frontend, mobile, design, e2e) and an Opus `security-engineer`.
