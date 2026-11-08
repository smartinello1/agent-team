#!/usr/bin/env bash
# PreToolUse guard for Bash: when a command looks destructive for a database
# (reset, drop, truncate, schema push, flush...) and nothing shows it targets a
# local database, ask the user to confirm instead of letting the agent run it.
# It never blocks outright and never fires on ordinary commands.
# No dependencies beyond bash, grep and sed (no jq, python or node).

input="$(cat)"

# Only Bash tool calls.
printf '%s' "$input" | grep -q '"tool_name"[[:space:]]*:[[:space:]]*"Bash"' || exit 0

# The command as it appears in the JSON (still escaped; fine for keyword matching).
cmd="$(printf '%s' "$input" | sed -nE 's/.*"command"[[:space:]]*:[[:space:]]*"(([^"\\]|\\.)*)".*/\1/p' | head -n 1)"
[ -n "$cmd" ] || exit 0

# Framework and CLI commands that wipe or force-sync a schema.
tool_cmds='(prisma[^|;&]*migrate[[:space:]]+reset|prisma[^|;&]*db[[:space:]]+push|drizzle-kit[^|;&]*push|dropdb([[:space:]]|$)|db:(drop|reset|schema:load|setup)|manage\.py[[:space:]]+(flush|reset_db)|sequelize[^|;&]*db:drop|migrate:(fresh|reset|rollback[^|;&]*--all)|typeorm[^|;&]*schema:drop|supabase[^|;&]*db[[:space:]]+reset[^|;&]*(--linked|--db-url))'
# Raw SQL or store commands, only when a database client runs them (so `grep "DROP TABLE"` passes).
sql_cmds='((^|[^a-z])(drop|truncate)[[:space:]]+(table|database|schema)|(^|[^a-z])truncate[[:space:]]+[a-z_"]|dropDatabase|flushall|flushdb)'
db_client='(^|[^a-z])(psql|mysql|mariadb|sqlite3|mongosh|mongo|redis-cli|sqlcmd|pgcli|prisma[[:space:]]+db[[:space:]]+execute|dbmate|flyway|liquibase)([^a-z]|$)'

if printf '%s' "$cmd" | grep -Eiq "$tool_cmds"; then
  :
elif printf '%s' "$cmd" | grep -Eiq "$sql_cmds" && printf '%s' "$cmd" | grep -Eiq "$db_client"; then
  :
else
  exit 0
fi

local_host='(localhost|127\.0\.0\.1|\[?::1\]?|0\.0\.0\.0|host\.docker\.internal|@(db|postgres|mysql|mariadb|mongo|redis)(:|/))'
remote_url='(postgres(ql)?|mysql|mariadb|mongodb(\+srv)?|redis|sqlserver)://'

# A URL written in the command decides it.
if printf '%s' "$cmd" | grep -Eiq "$remote_url"; then
  if printf '%s' "$cmd" | grep -Eo "${remote_url}[^[:space:]\"']+" | grep -Eivq "$local_host"; then
    target="a non-local database URL in the command"
  else
    exit 0
  fi
else
  # Otherwise look at DATABASE_URL in the environment and in the project's env files.
  cwd="$(printf '%s' "$input" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | head -n 1)"
  urls="${DATABASE_URL:-}"
  for f in .env.local .env.development.local .env.development .env; do
    [ -n "$cwd" ] && [ -f "$cwd/$f" ] && urls="$urls
$(grep -E '^[[:space:]]*(export[[:space:]]+)?[A-Z_]*DATABASE_URL[[:space:]]*=' "$cwd/$f" 2>/dev/null)"
  done
  if [ -n "$(printf '%s' "$urls" | tr -d '[:space:]')" ] && ! printf '%s\n' "$urls" | grep -E "$remote_url" | grep -Eivq "$local_host"; then
    if printf '%s\n' "$urls" | grep -Eiq "$local_host|file:|sqlite"; then
      exit 0
    fi
  fi
  target="a database the hook couldn't confirm is local"
fi

reason="agent-team guard: this looks like a destructive database command (reset, drop, truncate or schema push) against ${target}. Agents must never run these against a non-local database. Confirm only if you're sure it targets a local or test database."
reason="$(printf '%s' "$reason" | sed 's/\\/\\\\/g; s/"/\\"/g')"
printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"ask","permissionDecisionReason":"%s"}}\n' "$reason"
exit 0
