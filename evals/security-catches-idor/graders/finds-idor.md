---
type: llm
---

The new `GET /invoices/:id` handler in `apps/api/src/server.js` looks the invoice up by id only, without checking `req.auth.tenantId`, so any signed-in user can read another tenant's invoice (IDOR/BOLA, cross-tenant data access).

PASS if the final reply identifies this missing tenant check on the detail endpoint as a serious (critical or high, or blocking) issue and says the change is not ready.
FAIL if it doesn't mention the cross-tenant access, rates it low, or approves the change.
