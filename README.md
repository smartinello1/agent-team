# agent-team

A Claude Code plugin that turns every session into a small software team: one **team-leader** (Opus 5.5) that you talk to, and six specialists that do the work: five **executors** (Sonnet 5.5) and a **security reviewer** (Opus 5.5).

The agents are **stack-agnostic**. They define roles, workflow and rules; the stack (frameworks, commands, conventions) comes from each project's `CLAUDE.md`, manifests and docs, which they read before every task.

| Agent | Model | Role |
|---|---|---|
| `team-leader` | `claude-opus-5-5` | Entrypoint. Learns the project, plans, writes briefs, dispatches, reviews, decides. |
| `backend-engineer` | `claude-sonnet-5-5` | API, data model and migrations, auth, integrations, backend tests. |
| `frontend-engineer` | `claude-sonnet-5-5` | Web app and shared web components. |
| `mobile-engineer` | `claude-sonnet-5-5` | Mobile app (React Native/Expo, Flutter, native). |
| `product-designer` | `claude-sonnet-5-5` | Brand, design system, handoff specs. |
| `e2e-tester` | `claude-sonnet-5-5` | Browser end-to-end tests against the real backend. |
| `security-engineer` | `claude-opus-5-5` | Security-only review of the others' work. Read-only; reports findings with severity, never edits code. |

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
4. **Review before done.** The leader checks real diffs and test results against the acceptance criteria, not the agents' summaries.
5. **Security gate.** Changes that touch auth, tenant isolation, input, data, secrets, webhooks, uploads, integrations or dependencies go to `security-engineer` before they're done. It reviews security only (no style or performance), with read-only tools, and returns `block`, `fix before done` or `pass`; findings go back to the owning engineer and the fix is re-reviewed.

The leader keeps product state in `docs/product/` (vision, roadmap, backlog, decisions) and architecture decisions as ADRs in `docs/architecture/`; the designer owns `docs/design/`. If your project already keeps these elsewhere, say so in `CLAUDE.md`.

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

- **Models**: change `model:` in each agent's frontmatter (`opus`, `sonnet`, `haiku` or a full model ID).
- **Roles**: delete agents you don't need, or add project-specific ones in `.claude/agents/`; the leader treats them as team members.
- **Restrict dispatch**: add a `tools:` list to `team-leader.md` with `Agent(agent-team:backend-engineer, ...)` plus the other tools it needs.

## Layout

```
.claude-plugin/plugin.json        plugin manifest
.claude-plugin/marketplace.json   makes this repo installable as a marketplace
settings.json                     default agent = team-leader
agents/*.md                       the seven agents
```
