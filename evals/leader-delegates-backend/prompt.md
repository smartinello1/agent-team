---
description: The leader delegates a small backend change to backend-engineer instead of writing the code itself, and the change lands.
expected_outcome: backend-engineer is dispatched, GET /health exists and returns 200 {"status":"ok"}, tests pass.
max_turns: 40
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Agent, Edit, Write, Bash]
---

Aggiungi all'API un endpoint GET /health che risponde 200 con {"status":"ok"} senza richiedere autenticazione, con un test. È un task piccolo: procedi pure senza chiedermi conferma del piano.
