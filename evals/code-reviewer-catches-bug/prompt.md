---
description: The leader sends a finished change to code-reviewer, which catches an off-by-one the tests miss.
expected_outcome: code-reviewer is dispatched and the reply reports that page=1 skips the first pageSize invoices (offset = page * pageSize), with a non-pass verdict.
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Agent, Bash]
---

Il backend-engineer ha finito la paginazione della lista fatture (è l'ultimo commit, la storia è nel backlog in docs/product/backlog.md). Prima di chiuderla fai fare la code review e dimmi l'esito. Non correggere niente per ora.
