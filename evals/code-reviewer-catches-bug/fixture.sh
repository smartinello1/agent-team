#!/usr/bin/env bash
# Fixture: base API plus a commit that adds pagination with an off-by-one bug.
set -euo pipefail
mkdir -p apps/api/src apps/api/test
cat > package.json <<"J"
{ "name": "invoices", "private": true, "workspaces": ["apps/*"],
  "scripts": { "test": "node --test apps/api/test/*.test.js" } }
J
cat > CLAUDE.md <<"J"
# Invoices

Small invoicing SaaS. One app for now: `apps/api`, a Node.js HTTP API with no framework and no dependencies (node:http).
Multi-tenant: every request carries a verified session in `req.auth` = { userId, tenantId }; data must always be scoped to `req.auth.tenantId`.
Data lives in memory in `apps/api/src/db.js` (a stand-in for the real database).
Commands: `npm test` (node:test). No lint or typecheck yet.
J
cat > apps/api/src/db.js <<"J"
const invoices = [];
for (let i = 1; i <= 45; i++) {
  invoices.push({ id: String(i), tenantId: i % 2 ? "t1" : "t2", number: i, totalCents: i * 1000 });
}
module.exports = { invoices };
J
cat > apps/api/src/server.js <<"J"
const http = require("node:http");
const { invoices } = require("./db");

function send(res, status, body) {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(body === undefined ? "" : JSON.stringify(body));
}

function handler(req, res) {
  if (!req.auth) return send(res, 401, { error: { code: "unauthenticated", message: "Sign in" } });
  const url = new URL(req.url, "http://x");
  if (req.method === "GET" && url.pathname === "/invoices") {
    return send(res, 200, invoices.filter((i) => i.tenantId === req.auth.tenantId));
  }
  return send(res, 404, { error: { code: "not_found", message: "Not found" } });
}

module.exports = { handler, server: http.createServer(handler) };
J
cat > apps/api/test/server.test.js <<"J"
const test = require("node:test");
const assert = require("node:assert");
const { handler } = require("../src/server");

function call(method, path, auth) {
  return new Promise((resolve) => {
    const res = { status: 0, body: "", writeHead(s) { this.status = s; }, end(b) { this.body = b; resolve(this); } };
    handler({ method, url: path, auth }, res);
  });
}

test("lists only the caller tenant invoices", async () => {
  const res = await call("GET", "/invoices", { userId: "u1", tenantId: "t1" });
  assert.equal(res.status, 200);
  assert.ok(JSON.parse(res.body).every((i) => i.tenantId === "t1"));
});
J
git init -q && git add -A && git -c user.name=fixture -c user.email=fixture@example.com commit -qm "feat: invoices api"
mkdir -p docs/product
cat > docs/product/backlog.md <<"J"
# Backlog

## Paginate the invoice list (owner: backend-engineer, status: in review)
As a user I want the invoice list paginated so it loads fast.
Acceptance criteria:
- `GET /invoices?page=N&pageSize=M` with pages starting at 1; defaults page=1, pageSize=20.
- `page=1` returns the caller's first `pageSize` invoices, in order.
- Response: `{ items, page, pageSize, total }` where `total` is the caller's invoice count.
J
cat > apps/api/src/paginate.js <<"J"
function paginate(items, page = 1, pageSize = 20) {
  const offset = page * pageSize;
  return { items: items.slice(offset, offset + pageSize), page, pageSize, total: items.length };
}
module.exports = { paginate };
J
cat > apps/api/src/server.js <<"J"
const http = require("node:http");
const { invoices } = require("./db");
const { paginate } = require("./paginate");

function send(res, status, body) {
  res.writeHead(status, { "content-type": "application/json" });
  res.end(body === undefined ? "" : JSON.stringify(body));
}

function handler(req, res) {
  if (!req.auth) return send(res, 401, { error: { code: "unauthenticated", message: "Sign in" } });
  const url = new URL(req.url, "http://x");
  if (req.method === "GET" && url.pathname === "/invoices") {
    const page = Number(url.searchParams.get("page") || 1);
    const pageSize = Number(url.searchParams.get("pageSize") || 20);
    const mine = invoices.filter((i) => i.tenantId === req.auth.tenantId);
    return send(res, 200, paginate(mine, page, pageSize));
  }
  return send(res, 404, { error: { code: "not_found", message: "Not found" } });
}

module.exports = { handler, server: http.createServer(handler) };
J
cat > apps/api/test/paginate.test.js <<"J"
const test = require("node:test");
const assert = require("node:assert");
const { paginate } = require("../src/paginate");

test("returns pageSize items and the total", () => {
  const items = Array.from({ length: 50 }, (_, i) => i);
  const res = paginate(items, 1, 10);
  assert.equal(res.items.length, 10);
  assert.equal(res.total, 50);
});
J
cat > apps/api/test/server.test.js <<"J"
const test = require("node:test");
const assert = require("node:assert");
const { handler } = require("../src/server");

function call(method, path, auth) {
  return new Promise((resolve) => {
    const res = { status: 0, body: "", writeHead(s) { this.status = s; }, end(b) { this.body = b; resolve(this); } };
    handler({ method, url: path, auth }, res);
  });
}

test("lists only the caller tenant invoices, paginated", async () => {
  const res = await call("GET", "/invoices?page=1&pageSize=5", { userId: "u1", tenantId: "t1" });
  assert.equal(res.status, 200);
  const body = JSON.parse(res.body);
  assert.ok(body.items.every((i) => i.tenantId === "t1"));
});
J
git add -A && git -c user.name=backend-engineer -c user.email=agent@example.com commit -qm "feat: paginate invoice list"
