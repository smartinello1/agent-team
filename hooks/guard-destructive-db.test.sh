#!/usr/bin/env bash
# Tests for guard-destructive-db.sh. Run: bash hooks/guard-destructive-db.test.sh
cd "$(dirname "$0")" || exit 1
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/local" "$tmp/remote" "$tmp/none"
echo 'DATABASE_URL="postgresql://u:p@localhost:5432/app"' > "$tmp/local/.env"
echo 'DATABASE_URL=postgresql://u:p@db.example.com:5432/app' > "$tmp/remote/.env"
fail=0
check() { # expected(ask|pass) cwd command
  local c="${3//\\/\\\\}"; c="${c//\"/\\\"}"  # JSON-escape like Claude Code does
  local json; json="$(printf '{"tool_name":"Bash","cwd":"%s","tool_input":{"command":"%s"}}' "$2" "$c")"
  local out; out="$(printf '%s' "$json" | env -u DATABASE_URL ./guard-destructive-db.sh)"
  local got=pass; printf '%s' "$out" | grep -q '"ask"' && got=ask
  if [ "$got" = "$1" ]; then echo "ok   $1  [$2] $3"; else echo "FAIL want $1 got $got  [$2] $3"; fail=1; fi
}
check pass "$tmp/none"   "npm test"
check pass "$tmp/none"   "git status && ls -la"
check pass "$tmp/none"   "grep -r 'DROP TABLE' docs/"
check pass "$tmp/local"  "npx prisma migrate reset --force"
check ask  "$tmp/remote" "npx prisma migrate reset --force"
check ask  "$tmp/none"   "npx prisma db push --accept-data-loss"
check pass "$tmp/none"   "psql postgresql://u:p@localhost:5432/app -c 'DROP TABLE users'"
check ask  "$tmp/none"   "psql postgresql://u:p@prod.example.com/app -c 'TRUNCATE invoices'"
check ask  "$tmp/local"  "psql postgresql://u:p@prod.example.com/app -c 'DROP DATABASE app'"
check ask  "$tmp/none"   "bin/rails db:reset"
check ask  "$tmp/none"   "python manage.py flush --noinput"
check pass "$tmp/none"   "supabase db reset"
check ask  "$tmp/none"   "supabase db reset --linked"
check pass "$tmp/none"   "npx prisma migrate dev --name add_invoices"
check pass "$tmp/none"   "npx prisma migrate deploy"
check pass "$tmp/none"   "echo drop the ball"
check pass "$tmp/none"   "rg -n \"TRUNCATE invoices\" src/"
check ask  "$tmp/remote" "mongosh --eval \"db.dropDatabase()\""
check ask  "$tmp/none"   "cd apps/api && npx prisma migrate reset --force"
printf '{"tool_name":"Read","tool_input":{"file_path":"x"}}' | ./guard-destructive-db.sh | grep -q ask && { echo "FAIL non-Bash tool"; fail=1; } || echo "ok   pass  non-Bash tool"
exit $fail
