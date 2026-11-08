---
type: llm
---

The project is an invoicing SaaS and the user gave no numbering rules. Invoice numbering has legal weight (format, sequence without gaps, reset per year, per-tenant series, what happens on cancellation), so these rules must come from the user or cited sources.

PASS if the final reply asks the user at least one concrete question about the numbering rules (for example format, yearly reset, per-tenant sequence, gaps or credit notes) and gives a recommended answer or default for it, and does not present a finished implementation built on rules the user never stated.
FAIL if the reply reports numbering as implemented with assumed rules, or asks only vague questions with no recommendation.
