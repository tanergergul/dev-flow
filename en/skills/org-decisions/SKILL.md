---
name: org-decisions
description: Principles and lasting architecture/coding decisions that apply across the whole organization and all projects (adding dependencies, abstractions, logging, error response format, security, personal data, naming, technology standards). The architect loads it before asking questions and writing specs; the reviewer checks principle compliance.
---
# Organization Decisions

The architect does not ask about topics answered here. Project-specific decisions are kept in the project's `.devflow/knowledge/decisions.md`, not here.

This file is personal (`~/.copilot/skills/org-decisions/SKILL.md`). The dev flow install script never overwrites an existing copy.

## Principles
The architect checks every spec against these principles. If a violation is necessary, it writes it in the spec's "Complexity justification" section and tells the user.

| # | Principle |
|---|---|
| P1 | Adding a new NuGet package, project or external dependency requires justification. |
| P2 | No abstraction, interface or generic solution "because we might need it"; only today's requirement is met. |
| P3 | Framework features are used directly; no wrappers on top of them. |

## Decisions
| # | Topic | Decision | Reason | Date |
|---|---|---|---|---|
<!-- Example:
| OD1 | Error response format | ProblemDetails (RFC 7807) | Organization API standard | 2026-10-24 |
| OD2 | Logging card numbers | Never; only first 6 and last 4 digits masked | PCI DSS | 2026-10-24 |
-->
