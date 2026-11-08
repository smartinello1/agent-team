# Evals

Behaviour tests for the agent team, run with `claude plugin eval`. Each case seeds a tiny multi-tenant Node API in a git repo (`fixture.sh`), sends the leader a realistic request, and grades what happened.

| Case | Checks |
|---|---|
| `leader-delegates-backend` | The leader dispatches `backend-engineer` instead of coding, sends the unauthenticated route to `security-engineer`, and the change lands with tests. |
| `leader-asks-on-legal-rules` | A feature with legal weight and no stated rules gets a question with a recommendation, and no implementation starts before the answer. |
| `code-reviewer-catches-bug` | `code-reviewer` finds an off-by-one that the existing tests miss. |
| `security-catches-idor` | `security-engineer` finds cross-tenant access on a new endpoint. |
| `handbook-no-invented-vision` | The handbook gets its core files and no invented `vision.md`. |

Run from the plugin root. The fixtures are bash scripts, so `--scaffold` is required; the cases dispatch agents that edit files and run tests, so grant those tools:

```bash
# iterate cheaply: one run per case, no baseline
claude plugin eval . --scaffold --allow-tools Bash Edit Write --ablation none --runs 1

# full run with the no-plugin baseline (3 runs per arm by default)
claude plugin eval . --scaffold --allow-tools Bash Edit Write

# one case
claude plugin eval . --scaffold --allow-tools Bash Edit Write --case code-reviewer-catches-bug
```

To see why a case failed, add `--keep-temp`: without it the run's trace and workspace are deleted when it ends, and the report keeps only the final reply. Each `tracePath` in the JSON result then points to the session, one message per line.

Note that a case's own `CLAUDE.md` is loaded into the session automatically, so don't grade on the leader reading it. The trace also includes tool calls made inside subagents, so a `tool_used` count can't tell the leader's edits from an engineer's.

Each run is a full session that dispatches Opus and Sonnet agents, so a full run is not cheap: start with `--runs 1 --ablation none`, and use `--max-cost-usd` if you want a hard ceiling. Results go to `evals/results/` (git-ignored).

Run the suite after any change to an agent prompt or the handbook skill. The guard hook has its own fast test: `bash hooks/guard-destructive-db.test.sh`.
