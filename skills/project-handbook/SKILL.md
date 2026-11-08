---
name: project-handbook
description: Set up, audit or update a project's handbook — the docs/ structure with one short entry point (docs/README.md) that links to an append-only decision log, an architecture overview, ADRs, domain docs and, when the user gives product direction, a product vision. Use when a project has no docs/ yet, when docs are scattered or stale, when someone needs to pick up the project from one place, or after a change that makes the architecture or domain docs out of date.
---

# Project handbook

Goal: anyone (a person or an agent) can pick up the project from **one page** in five
minutes, and every other document has one clear job. One entry point that links, not one
file that holds everything: a single big file grows into a wall of text, duplicates the app
READMEs and deploy docs, and mixes "how it works now" (rewritten as things change) with
"why we decided" (never rewritten).

## Structure

```
docs/
  README.md              entry point, 1-2 pages: what the product is, current state,
                         system map, "where to find what", first day, doc rules
  decisions.md           append-only dated log: decision + why + links
  product/
    domain.md            glossary, business rules, lifecycles; created with the first
                         domain concept or rule, not as an empty template
    vision.md            optional: only when the user gives real product direction
                         (users, positioning, roadmap); otherwise "What <Product> is"
                         in README.md is the whole product statement
    backlog.md           only if the project doesn't use an issue tracker
  architecture/
    overview.md          how the system works today: apps, identity, tenancy, data,
                         integrations, environments, known gaps
    NNNN-<title>.md      ADRs, only for cross-cutting or hard-to-reverse decisions
  design/                owned by product-designer
```

Rules:
- **Don't duplicate, link.** Setup and commands stay in the app READMEs, deploy and
  migrations in the deploy doc, agent rules in `CLAUDE.md`, roadmap and backlog in the issue
  tracker when the project uses one. The handbook points to them.
- **Living vs append-only.** `README.md`, `overview.md`, `vision.md`, `domain.md` describe the
  present: update them in the same PR that changes the behaviour. `decisions.md` is never
  rewritten: a reversed decision gets a new entry that supersedes the old one.
- **Facts vs assumptions.** Market, regulatory, provider and pricing claims need a source;
  otherwise mark them as assumptions. Product sections the user hasn't decided stay `_TBD_`.
- **Never invent product direction.** Users, value proposition, positioning, principles and
  roadmap come only from the user or cited sources. If they're missing, keep "What <Product>
  is" to what the code and the user show, and ask; don't write a `vision.md` to fill the gap.
- **No empty files.** Create a document when there is something true to put in it. A file of
  headings and `_TBD_` reads as if it were decided.
- **Language.** Follow the project's convention (`CLAUDE.md`) for docs language.

## Procedure

### Setting it up
1. Read what exists: `CLAUDE.md`, root and app READMEs, deploy docs, existing `docs/`, ADRs,
   the issue tracker (milestones, labels), recent git history and merged PRs.
2. If the project already keeps some of this elsewhere, map it instead of moving it, and
   propose the structure to the user before writing.
3. Write the files from the templates below. Fill only what is known and sourced; seed
   `decisions.md` from decisions you can trace (PRs, issues, `CLAUDE.md`, user statements),
   dated. Always write `README.md`, `decisions.md` and `architecture/overview.md`. Write
   `product/domain.md` only if the code or the user already show domain concepts or rules,
   and `product/vision.md` only if the user has given product direction; ask the user whether
   they want one rather than drafting it yourself.
4. Add a "start here" link to `docs/README.md` in the root `README.md`, and a line in
   `CLAUDE.md` telling agents to start from it and to keep it current.
5. Docs-only PR when the user asks for one; format with the project's formatter.

### Keeping it current (after each piece of work)
- New decision that matters beyond one task → entry in `decisions.md`.
- Behaviour changed (identity, data model, integrations, environments, commands) →
  update `architecture/overview.md`; new concept or rule → `product/domain.md` (create it
  if it doesn't exist yet).
- Milestone reached or scope changed → "Current state" in `docs/README.md`.
- The user gives product direction (target users, positioning, roadmap) beyond what fits in
  "What <Product> is" → create or update `product/vision.md`.

### Auditing
Check links resolve, "Current state" matches the code and tracker, `overview.md` matches the
code (routes, auth, data model, environments), no duplicated instructions that drifted from
their source, open `_TBD_` sections that now have answers, and product content with no
source in the user's words or the tracker (flag it as an assumption). Report findings; fix what is
yours to fix.

## Templates

### docs/README.md
```markdown
# <Product> handbook

Start here. This page tells you what <Product> is, where it stands and where every other
document lives.

## What <Product> is
<2-4 sentences from what the user and the code show: who it is for, the problem, the core of
the product, what is not core. Mark anything the user hasn't confirmed as an assumption.>
<Link only the files that exist:> More in [`product/domain.md`](product/domain.md) and
[`product/vision.md`](product/vision.md).

## Current state
- **Built:** <what works end to end today>
- **Next:** <current milestone>
- **Paused / out of scope:** <frozen apps, deferred areas>
- <constraints that shape every decision: team size, budget, hosting tier>

## Map of the system
<small ASCII diagram: clients, server, database, external services and the arrows between them>
Details: [`architecture/overview.md`](architecture/overview.md).

## Where to find what
| You need | Go to |
|---|---|
| Why something was decided, and when | [`decisions.md`](decisions.md) |
| How the system works | [`architecture/overview.md`](architecture/overview.md) |
| Big architecture decisions (ADRs) | [`architecture/`](architecture/) |
| Domain concepts and rules (and product vision, if written) | [`product/`](product/) |
| Roadmap and backlog | <issue tracker milestones / product/backlog.md> |
| Design system and handoffs | [`design/`](design/) |
| Quick start, commands per app | <root README, app READMEs> |
| Deploy, migrations, recovery | <deploy doc> |
| Rules for agents | [`../CLAUDE.md`](../CLAUDE.md) |

## First day
1. Read this page, `architecture/overview.md` and the latest entries of `decisions.md`.
2. Follow the quick start in <root README>. <Environment gotchas: separate dev accounts, tunnels, secrets.>
3. Pick work from <current milestone>.

## Keeping these docs alive
- This page summarises and links; it doesn't duplicate.
- `architecture/overview.md` and `product/*.md` describe the present: update them in the PR
  that changes the behaviour.
- `decisions.md` is append-only.
```

### docs/decisions.md
```markdown
# Decisions

Append-only log of product, architecture and tooling decisions. Newest first. Never edit an
old entry; if a decision changes, add a new one that supersedes it. Big, hard-to-reverse
decisions get a full ADR in [`architecture/`](architecture/).

## YYYY-MM-DD

- **<Decision, stated as the rule that now holds.>** _Why:_ <reason, the problem it solves,
  the alternative rejected>. _Links:_ <issues, PRs, ADRs>.
```

### docs/architecture/overview.md
```markdown
# Architecture overview

How <Product> works **today**. Update it in the PR that changes the behaviour. Why things
are this way: [`../decisions.md`](../decisions.md).

## Apps and stack
| App | Stack | Notes |
|---|---|---|

## Identity
<identity provider, how users/accounts reach the database, which id is the identity key>

## Tenancy and API auth
<tenant model, how every request is authenticated and scoped, error codes>

## Data
<database, where the schema lives, how migrations work, rules every table follows>

## Integrations
<third parties, webhooks and their retry/idempotency semantics>

## Environments
| | Local | Staging | Production |
|---|---|---|---|

## Known gaps
<links to issues>
```

### docs/product/vision.md (optional)
Only when the user has given product direction. Every section comes from the user or a cited
source; leave out sections they haven't spoken to instead of filling them.
```markdown
# Vision

## Problem
## Target users
## Value proposition
## What <Product> is not
## Principles
## Roadmap
<milestones in order, each with its goal; link to the tracker>
```

### docs/product/domain.md
```markdown
# Domain

Concepts and business rules in plain language. Regulatory rules need a source or an ADR;
mark anything unverified as an assumption.

## Glossary
| Term | Meaning |
|---|---|

## Business rules
## Lifecycles
<states and transitions of the main entities>
```

### docs/architecture/NNNN-title.md (ADR)
```markdown
# NNNN. <Title>

- Status: proposed | accepted (YYYY-MM-DD) | rejected (YYYY-MM-DD) | superseded by NNNN
- Context: <the forces and constraints>
- Options: <2-3 realistic options with trade-offs, cost, risk, reversibility>
- Decision: <the option chosen and why>
- Consequences: <what becomes easier or harder>
- Follow-ups: <issues>
```
