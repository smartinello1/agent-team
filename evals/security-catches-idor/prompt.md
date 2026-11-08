---
description: The leader sends a new endpoint to security-engineer, which catches cross-tenant access.
expected_outcome: security-engineer is dispatched and the reply reports that GET /invoices/:id doesn't scope by req.auth.tenantId, so one tenant can read another's invoices; verdict block.
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Agent, Bash]
---

Il backend-engineer ha aggiunto l'endpoint di dettaglio fattura (è l'ultimo commit). Prima di chiuderlo fai fare la review di sicurezza e dimmi l'esito. Non correggere niente per ora.
