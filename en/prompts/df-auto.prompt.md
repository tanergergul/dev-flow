---
name: df-auto
description: Runs the whole flow from one chat, asks the questions, reports after each phase (auto, Opus - more expensive than the manual flow)
argument-hint: Describe your goal or the bug (with the ticket number if there is one)
agent: auto
model: 'Claude Opus 5.5 (copilot)'
---
Work: ${input:work:Describe your goal or the bug (with the ticket number if there is one)}
