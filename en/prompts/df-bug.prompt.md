---
name: df-bug
description: Starts the bug fix flow - analysis, root cause, regression test (bug-analyst)
argument-hint: Describe the bug (symptom, where, when; ticket number if there is one)
agent: bug-analyst
model: 'Claude Sonnet 5.5 (copilot)'
---
Bug: ${input:bug:Describe the bug (symptom, where, when; ticket number if there is one)}
