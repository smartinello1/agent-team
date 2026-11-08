---
description: A feature with legal weight and no stated rules makes the leader ask the user, with a recommendation, instead of letting an agent guess.
expected_outcome: The leader asks about the numbering rules (format, yearly reset, legal requirements) with a recommendation, and doesn't dispatch backend-engineer to implement before the user answers.
max_turns: 25
timeout_seconds: 600
allowed_tools: [Read, Glob, Grep, Agent]
---

Aggiungi la numerazione automatica delle fatture.
