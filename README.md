# agent-team

A Claude Code plugin that turns every session into a small software team: one **team-leader** (Opus) that you talk to, and seven specialists that do the work: five **executors** (Sonnet) and two **reviewers** (Opus), one for correctness and one for security. Models are set by alias, so the team moves to each new Opus and Sonnet release on its own.

The agents are **stack-agnostic**. They define roles, workflow and rules; the stack (frameworks, commands, conventions) comes from each project's `CLAUDE.md`, manifests and docs, which they read before every task.

| Agent | Model | Role |
|---|---|---|
| `team-leader` | `opus` | Entrypoint. Learns the project, plans, writes briefs, dispatches, reviews, decides. |
| `backend-engineer` | `sonnet` | API, data model and migrations, auth, integrations, CI pipelines, backend tests. |
| `frontend-engineer` | `sonnet` | Web app and shared web components. |
| `mobile-engineer` | `sonnet` | Mobile app (React Native/Expo, Flutter, native). |
| `product-designer` | `sonnet` | Brand, design system, handoff specs. |
| `e2e-tester` | `sonnet` | Browser end-to-end tests against the real backend; can also explore the running app in a live browser when browser tools are available. |
| `code-reviewer` | `opus` | Independent correctness review of the others' work against the brief and acceptance criteria. Read-only; never edits code. |
| `security-engineer` | `opus` | Security-only review of the others' work. Read-only; reports findings with severity, never edits code. |

## How it works

```
you ──► team-leader (Opus) ──brief──► specialist (Sonnet)
              ▲                            │
              └──── report + questions ────┘
              │
              └── unsure about direction? ──► you
```

1. **The leader is the entrypoint.** The plugin's `settings.json` sets `"agent": "agent-team:team-leader"`, so the main session runs as the leader. It reads the project first, then dispatches each task to a specialist with a self-contained brief (goal, stack context, acceptance criteria).
2. **Questions go up, never sideways.** Subagents can't talk to each other or to you, and can't spawn agents. A specialist with a doubt finishes what is clear and ends its report with `## Questions for the leader`, each with a recommended answer.
3. **The leader decides, or asks you.** It answers from the backlog, ADRs and code, then resumes the specialist with `SendMessage`. If the leader is itself unsure about direction (scope, priorities, pricing, legal/tax, hard-to-reverse choices), it asks **you** with a recommendation.
4. **Review before done.** The leader checks real diffs and test results against the acceptance criteria, not the agents' summaries. Non-trivial changes also go to `code-reviewer`, which reviews correctness with a fresh context and returns `block`, `fix before done` or `pass`.
5. **Guardrail hook.** A `PreToolUse` hook asks you to confirm any destructive database command (reset, drop, truncate, schema push, flush) unless it can tell the target is local: a local URL in the command, or a local `DATABASE_URL` in the environment or the project's `.env` files. It fires for the leader and every subagent, and never blocks ordinary commands.
6. **Parallel only across apps.** The leader runs tasks in parallel only when different agents own different apps or docs (e.g. backend and design). It never runs two instances of the same agent, or two agents on the same app, at once: that work goes to one agent in sequence, so there are no conflicting edits to reconcile.
7. **Security gate.** Changes that touch auth, tenant isolation, input, data, secrets, webhooks, uploads, integrations or dependencies go to `security-engineer` before they're done. It reviews security only (no style or performance), with read-only tools, and returns `block`, `fix before done` or `pass`; findings go back to the owning engineer and the fix is re-reviewed.

## Project handbook

The leader keeps a **handbook** so anyone can pick up the project from one page: a short entry point that links to documents with one job each, instead of one file that holds everything.

```
docs/
  README.md              entry point: what the product is, current state, system map, where to find what
  decisions.md           append-only dated log: decision + why + links
  product/domain.md      glossary, business rules, lifecycles (created with the first domain rule)
  product/vision.md      optional: only when you give product direction (users, positioning, roadmap)
  architecture/overview.md   how the system works today
  architecture/NNNN-*.md     ADRs for cross-cutting, hard-to-reverse decisions
  design/                owned by product-designer
```

Roadmap and backlog live in your issue tracker if you use one (otherwise `docs/product/roadmap.md` and `backlog.md`). Setup, deploy and agent rules stay where they are (app READMEs, deploy docs, `CLAUDE.md`); the handbook links to them. Documents are created when there is something true to put in them, and the leader never invents product direction: on a technical project with little product input, the handbook is `README.md`, `decisions.md`, `architecture/` and, as rules appear, `domain.md`. The living pages are updated in the PR that changes the behaviour; `decisions.md` is never rewritten.

The `project-handbook` skill holds the templates and the setup, update and audit procedure. The leader loads it when a project has no handbook yet; you can also run it directly with `/agent-team:project-handbook`. If your project already keeps these docs elsewhere, say so in `CLAUDE.md`.

## Install

In Claude Code:

```
/plugin marketplace add smartinello1/agent-team
/plugin install agent-team@agent-team
```

Start a new session: it now runs as the team leader. To use another agent for one session, run `claude --agent <name>`.

### Without the plugin

Copy `agents/*.md` into your project's `.claude/agents/` (or `~/.claude/agents/` for all projects) and add `{"agent": "team-leader"}` to `.claude/settings.json`. Names are then not namespaced: remove the line about `agent-team:` prefixes in `team-leader.md`.

## Make it fit your project

The agents work best when the project tells them what they can't guess. In your `CLAUDE.md`, include:

- **Apps and owners**: e.g. `apps/api` → backend, `apps/web` → frontend, `apps/mobile` → mobile.
- **Stack and versions**, especially anything newer than the model's training (and links to versioned docs or skills to load).
- **Commands**: dev, build, test, lint, typecheck, migrations, monorepo filters.
- **Hard rules**: e.g. "never run schema push against the dev DB", "deploys are manual".
- **Domain rules**: anything regulatory or legal the agents must not guess.

Project instructions always override the agents' defaults.

## Customize

- **Models**: agents use the `opus` and `sonnet` aliases, which follow the latest release. To pin a version (more predictable behaviour across model releases), set `model:` in the agent's frontmatter to a full model ID.
- **Roles**: delete agents you don't need, or add project-specific ones in `.claude/agents/`; the leader treats them as team members.
- **Guardrail hook**: edit the patterns in `hooks/guard-destructive-db.sh` and run `bash hooks/guard-destructive-db.test.sh`; remove `hooks/hooks.json` to turn it off.
- **Restrict dispatch**: add a `tools:` list to `team-leader.md` with `Agent(agent-team:backend-engineer, ...)` plus the other tools it needs.

## Testing the team

`evals/` holds behaviour tests for `claude plugin eval`: the leader delegates instead of coding, asks instead of guessing on legal rules, the reviewers catch a seeded bug and a cross-tenant leak, and the handbook doesn't invent a product vision. See [`evals/README.md`](evals/README.md) for how to run them. Run them after changing an agent prompt or the skill.

## Layout

```
.claude-plugin/plugin.json        plugin manifest
.claude-plugin/marketplace.json   makes this repo installable as a marketplace
settings.json                     default agent = team-leader
agents/*.md                       the eight agents
skills/project-handbook/SKILL.md  handbook structure, templates and procedure
hooks/hooks.json                  PreToolUse guard for destructive database commands
hooks/guard-destructive-db*.sh    the guard and its tests
evals/                            behaviour tests (claude plugin eval)
CHANGELOG.md                      what changed in each version
```
