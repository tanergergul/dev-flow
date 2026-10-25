# dev-flow

A token-efficient, standard development flow for GitHub Copilot (VS Code, Local harness).

The idea: the expensive model (Opus) works only on thinking and decisions. Ambiguities are asked about before any code is written. Defects are caught by build and tests, not by Opus reviews. Agents rely on task files rather than chat history, so each phase runs in a new, small chat.

## Requirements
| | |
|---|---|
| **VS Code** | A current version. Handoff buttons need 1.106, parallel subagents 1.109 or later. |
| **GitHub Copilot** | Business or Enterprise plan (AI Credits). The models the agents use (GPT-6 Luna, Claude Haiku 5.5, Claude Sonnet 5.5, Claude Opus 5.5 and their fallbacks) must be enabled in your organization. |
| **Local harness** | **Local** must be selected in the chat's **Session Target** picker. Commands (prompt files) and handoff buttons only work in Local. If Local is not shown, the VS Code documentation says the experimental `chat.editor.localAgent.enabled` setting is needed; under enterprise management, administrators can keep Local available with `vscode.temporaryDefaultToLocalHarness` from 1.142 on. |
| **Operating system** | `setup.ps1` is for Windows PowerShell 5.1 or later. On macOS and Linux copy the files by hand (see below). |
| **Git** | Recommended. Per-step commits, the review diff and the PR description use git; without git these steps are skipped. |
| **Project** | Example commands are for .NET, but the structure is language-independent. `/df-setup` finds your project's build and test commands itself. |

---

## Installation

### 1. Once per machine
In the root of the `dev-flow` folder:
```powershell
powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Lang en
```
- Copies the agents and commands to your VS Code user profile (`%APPDATA%\Code\User\prompts`). They work in all your projects.
- Installs the `org-decisions` skill under `~\.copilot\skills\`. Existing skills are never overwritten.
- Restart VS Code.

The Turkish version is the default (`-Lang tr`). Both can be installed on the same machine side by side.

To update, update the `dev-flow` folder and run the script again. Files with different content are backed up as `.bak`.

Options: `-Insiders` for VS Code Insiders; `-Target <the profile's prompts folder>` if you use a different VS Code profile.

**macOS and Linux:** copy `en/agents/*.agent.md` and `en/prompts/*.prompt.md` to the `prompts` subfolder of the VS Code user folder (macOS: `~/Library/Application Support/Code/User/prompts`, Linux: `~/.config/Code/User/prompts`), and the `en/skills/org-decisions` folder to `~/.copilot/skills/`.

If running scripts is blocked in your organization, copy `en\agents\*.agent.md` and `en\prompts\*.prompt.md` to `%APPDATA%\Code\User\prompts\`, and the `en\skills\org-decisions` folder to `%USERPROFILE%\.copilot\skills\` by hand.

### 2. Once per project
Open the project in VS Code and run **`/df-setup`** in the chat. The agent:
- Creates the `.devflow/` folder, templates and knowledge files.
- Scans the project and writes the project info, example pattern files and **quiet** build/test commands into `.github/copilot-instructions.md`.
- Adds the required lines to `.gitignore` and `.vscode/settings.json`. It never deletes existing content.
- Checks the environment and reports.

Run `/df-setup` again after a dev flow update to refresh the templates. If a template was changed in the project, it shows the difference and asks before overwriting: take the new version, keep the project's, or merge.

`setup.ps1` never overwrites an existing `org-decisions` skill. If a new dev flow version adds a section to this file (e.g. "Principles"), copy it from `en/skills/org-decisions/SKILL.md` into your own copy by hand.

### First-use checklist
Agents cannot see the VS Code UI; check these two yourself:
- [ ] The chat's agent list shows `scout`, `architect`, `implementer`, `reviewer`, `quick`, `bug-analyst`, `explainer`, `auto`, `status`, `setup`, `close`, `switch-task`, `skill-maker`. `researcher` and `security-scan` are helper subagents and do not appear in the list.
- [ ] While `/df-setup` runs, the model picker shows Sonnet. If not, change the names in the `model` field of the agent and command files to the names in your model picker and run `setup.ps1` again.
- [ ] **Verify which model actually runs.** The first time you run each agent, search for "Chat Debug" in the Command Palette, open the chat debug view and check the model used. VS Code has an open issue where the model pinned in an agent file is overridden by the model picker's selection ([#338949](https://github.com/microsoft/vscode/issues/338949)). If the model is wrong, select the right model in the model picker by hand. Do not skip this check; an agent meant to run on a cheap model running on Opus drains your quota quickly.

Recommended VS Code user settings:
- `chat.subagents.showCreditUsage: true`: shows the credits subagents spend. For measuring cost.
- `chat.subagents.allowInvocationsFromSubagents: true` (optional): only needed for `/df-auto`. Inside `/df-auto`, the architect's context completion, the scout's parallel research and the reviewer's parallel security scan are nested subagent calls. If the setting is off, the agents do this work themselves; the flow still works.

`/df-setup` also tests and reports these two itself: exclusion of task files from search, and the interactive question tool (`askQuestions`). If the question tool does not work, agents ask their questions as plain text; you answer like `1a 2b`.

### If the agents do not appear
1. Select **Local** in the chat's **Session Target** picker. Commands (`/df-task` etc.) and handoff buttons only work in Local.
2. Open **Configure Custom Agents** from the agent menu. It shows which folder user agents are kept in. If it is a different folder, reinstall with `.\setup.ps1 -Lang en -Target <that folder>`.

---

## Flow

```
 /df-task <goal + ticket>
      │
 scout        (GPT-6 Luna)  → ticket, 01-context.md, size recommendation
      │
      ├── S ──► quick       (Sonnet)  → implements directly (you commit)
      │
      └── M/L ► /df-spec       architect   (Opus)    → ambiguity scan in 10 categories → questions to you
                  │                                  → 03-spec.md → principle check → self-check
                  │                                  (splits into parts beyond 8 steps)
                /df-implement  implementer (Sonnet)  → coverage pre-check → code + tests per step → build/test → commit
                  │    ▲
                  │    └── if stuck: /df-spec (only the affected step)
                  │
                /df-review     reviewer    (Opus)    → diff compared with the spec
                  │
                  ├── findings: /df-implement (at most 2 rounds per part, then asks you)
                  ├── another part: /df-implement
                  └── finished: DONE
                         │
                /df-close      close       (GPT-6 Luna) → PR description, module summary, lessons, skill suggestion
                         │
                /df-make-skill skill-maker (Sonnet)  → optionally a reusable skill from the task
```

### Bug fix flow
```
 /df-bug <symptom + ticket>
      │
 bug-analyst (Sonnet)  → symptom, reproduction, evidence-based root cause, blast radius → 01-bug.md
      │                   → asks you about fix options
      ├── simple ──► short spec: T1 regression test (red first) + fix
      │               /df-implement → the test fails first, passes after the fix
      │
      └── complex (low confidence, contract/business-rule change, >3 files) ──► /df-spec (architect)
      │
 /df-review → symptom verification (verified / partial / failed) → /df-close
```

## Commands
**Start every phase in a new chat** (the `+` at the top of the Chat panel). The command selects the right agent and model itself. **Use the commands rather than picking agents from the menu:** the command file pins the model the way the Local harness documents. If you pick an agent from the menu, the model picker's model may be used (see the first-use checklist).

| Command | Agent | When |
|---|---|---|
| `/df-task <goal>` | scout | Starting a new task. Include the ticket number (e.g. `PROJ-1234 ...`); it asks if you don't. |
| `/df-bug <symptom>` | bug-analyst | Fixing a bug (e.g. `/df-bug OPS-5678 the installment amount on the statement screen is off by one cent`) |
| `/df-auto <goal or bug>` | auto | When you want to run the whole flow from one chat. More expensive, see below |
| `/df-status` | status | Any time: where you are, open findings, the next command |
| `/df-ask <question>` | explainer | To ask how a method, class or flow works (e.g. `/df-ask How does CardService.CheckLimit work?`). Also answers follow-up questions in the same chat; writes a detailed report on request |
| `/df-spec` | architect | After scouting; on a pre-check finding, escalation or spec issue; for complex bugs |
| `/df-spec <change>` | architect | When a requirement changes mid-task (e.g. `/df-spec the limit check should now allow a 2% tolerance`) |
| `/df-implement` | implementer | When the spec is ready; to continue an unfinished implementation, fixes or the next part |
| `/df-review` | reviewer | When the implementation (or a part) is finished |
| `/df-close` | close | When the task is done |
| `/df-make-skill` | skill-maker | When `/df-close` suggests a skill and you want one |
| `/df-switch [id]` | switch-task | To return to an unfinished task |
| `/df-new-project <goal>` | architect | A project from scratch (run `/df-setup` in the empty folder first) |
| `/df-setup` | setup | First setup in a project, or a template update |

For small work you can skip `scout` and select `quick` directly from the agent menu.

Every agent tells you the next step when it finishes. Within a phase (e.g. while answering the architect's questions), stay in the same chat.

## Example: a task from start to finish
Every step starts in a new chat (`+`). Agent output is shortened.

**1. Discovery**
```
/df-task PROJ-1234 Add the last statement date to the card detail endpoint

scout › Task: PROJ-1234-last-statement-date · Size: M (3 files, 2 decision points)
        Next: /df-spec in a new chat
```

**2. Questions and spec**
```
/df-spec

architect › Q1. Where should the last statement date come from?   Why it matters: performance and consistency
              a) Statement table ⭐  b) Card summary service
            Q2. What should be returned for a card with no statement?   Why it matters: API contract
              a) null ⭐  b) omit the field
            You can answer briefly: 1a 2b. If you accept all recommendations, just write "recommended".

you       › recommended

architect › 1 question round · 3 rules, 4 steps, 5 tests · Next: /df-implement in a new chat
```

**3. Implementation**
```
/df-implement

implementer › Pre-check: clean (R 3/3 tested, T 5/5 assigned to a step)
              You are on a protected branch (develop). Shall I create feature/PROJ-1234-last-statement-date?
you         › yes
implementer › S1 ✓ [PROJ-1234] LastStatementDate field on the response DTO
              S2 ✓ [PROJ-1234] Repository query
              S3 ✓ [PROJ-1234] Handler mapping
              S4 ✓ [PROJ-1234] Endpoint and contract test
              All tests passed · Next: /df-review in a new chat
```
If the task had more than 4 steps, the implementer would stop after step 4 and ask for `/df-implement` in a new chat (session budget).

**4. Review**
```
/df-review

reviewer › Critical 0 · Major 0 · Minor 1 · Status: DONE
           Next: /df-close in a new chat
```

**5. Close**
```
/df-close

close › .devflow/tasks/PROJ-1234-last-statement-date/05-pr.md is ready
        Module summary proposal: 2 lines for Card.Api.md · Lesson proposal: none
        Shall I add them? (all / selected / none)
```
Use `05-pr.md` as the PR description. You push and open the PR yourself.

Use `/df-status` at any time to see where you are.

---

## Questions about code: `/df-ask`
`explainer` (Sonnet) answers your question by reading the code, with a `file › Symbol (~line N)` reference for every claim. It does not change code or touch your active task, so you can use it in the middle of a task.
- **In the chat:** a direct answer first (2-5 sentences), then, if needed, a short flow and the critical business rules; at most ~25 lines. Ask follow-up questions in the same chat; it does not reread files it has already read.
- **Detailed report (on request):** `.devflow/reports/<Class.Method>.md`. Sections: purpose, inputs and outputs, flow, business rules, side effects (DB/stored procedures, external services, cache, logs, transactions), callers and callees, risks, open points. The commit at the time of writing is recorded in the report; if the code changes later, the agent notices and rereads the changed part.
- **Accumulated knowledge:** If a report describes an important part of a module, it proposes lines for the module summary and adds them with your approval. `scout` also reads related reports as hints in later tasks.

Reports are personal and kept outside git (`.devflow/reports/`).

## Automatic flow: `/df-auto`
The `auto` orchestrator runs the whole flow from one chat. It runs the phases as subagents, asks you the agents' questions and posts a one-line progress update after each phase:
```
✓ Scout — size M, 6 files, 2 open points · next: Architect (questions)
✓ Architect — 4 questions answered, spec: 5 rules, 7 steps, 9 tests · awaiting approval
```
It stops for approval in two places: when the spec is ready ("Shall I start the implementation?") and before closing. It asks you if the review is not resolved in 2 rounds or a phase comes back with the same problem. Say "stop" at any time to switch to the manual flow.

**When to use it:** The manual flow is cheaper. In Copilot a subagent cannot run on a more expensive model than the agent that calls it, so the orchestrator must be Opus to call the architect and reviewer (Opus). Also, since subagents cannot ask you questions, the architect is called twice: for the questions and for the spec. Rough estimate, not measured: 30-50% extra cost per task. Use `/df-auto` when convenience matters more than cost. Measure the real difference with `chat.subagents.showCreditUsage`.

## Parallel work
Subagents are used only where they do not increase cost, and only downwards: an expensive agent calls a cheap helper.

| Who | Parallel helper | When | What it does |
|---|---|---|---|
| reviewer (Opus) | `security-scan` (GPT-6 Luna) | Every review | Scans the diff for card numbers, personal data, secrets, new dependencies, missing tests, leftover markers and input validation. The reviewer verifies every candidate finding; unverified ones are dropped |
| scout (GPT-6 Luna) | `researcher` (GPT-6 Luna), one per module | When the work spans 3 or more modules | Researches each module separately; scout merges the findings |
| architect (Opus) | `scout` (GPT-6 Luna) | When context is missing | Completes `01-context.md`; you don't have to go back |

Implementation is not parallelized. Agents changing files in the same working folder at the same time break each other's builds and mix up commits.

## Task files
Each task lives under `.devflow/tasks/<id>/`. The ID is `PROJ-1234-short-name` with a ticket, otherwise `YYYYMMDD-short-name`. The active task's path is in `.devflow/active.md`.

| File | Written by | Content |
|---|---|---|
| `01-context.md` | scout | Ticket, relevant files, current behavior, embedded rules, open points marked `[UNCLEAR: …]` |
| `01-bug.md` | bug-analyst | (Bug tasks) symptom, reproduction, evidence, root cause and confidence, blast radius, fix options |
| `02-decisions.md` | architect | Questions, your answers, defaults and their sources; 10-category coverage summary |
| `03-spec.md` | architect (bug-analyst for simple bugs) | Rules, NFRs, complexity justification, steps (or parts), Given/When/Then test scenarios |
| `04-status.md` | implementer, architect, reviewer | Start commit, coverage pre-check, step status, changes, escalations, review rounds |
| `05-pr.md` | close | PR description |

- **Tasks do not mix.** Agents read only the active task. When `/df-task` opens a new task it tells you if the previous one is unfinished; return to it with `/df-switch`.
- **Continuing an earlier task:** `/df-task continuation of PROJ-1234-statement-installments: ...`. `scout` reads only the goal and rules of the earlier task.
- **If a requirement changes mid-task:** `/df-spec <change>`. The architect updates the decisions and spec and marks affected completed steps "redo"; `/df-implement` redoes only those.

## Quality gates
Defects are caught in cheap phases before they reach Opus:

| Gate | Who | When | What it checks |
|---|---|---|---|
| Ambiguity scan | architect | Before the questions | Clear / partial / missing in 10 categories; questions ordered by impact × uncertainty |
| Principle check | architect | While writing the spec | `org-decisions` principles; a violation requires a "Complexity justification" |
| Self-check | architect | Before finishing the spec | `[UNCLEAR` markers, vague wording, rule-test-step links, NFR measures |
| Coverage pre-check | implementer | Before writing code | Untested rules, unassigned tests, nonexistent symbols, contradictions, terminology drift. Implementation does not start with Critical or Major findings |
| Build and test | implementer | Every step | Quiet build and the step's tests |
| Review | reviewer | After implementation | Diff vs spec, principles, lessons, security; symptom verification for bug tasks |

## Knowledge files (knowledge that accumulates)
| File | Where | Written by | Read by |
|---|---|---|---|
| `org-decisions` skill | Personal: `~/.copilot/skills/` | You, architect (with your approval) | architect, reviewer. Principles and decisions valid in all projects |
| `decisions.md` | Project: `.devflow/knowledge/` | architect (with your approval) | architect. Decisions that recur in this project |
| `lessons.md` | Project: `.devflow/knowledge/` | close (from recurring mistakes, with your approval) | architect, reviewer |
| `modules/*.md` | Project: `.devflow/knowledge/` | close (after each task, with your approval) | scout. Starts its search here |
| Skills created from tasks | Personal or project (`.github/skills/`) | skill-maker | scout, architect. Loaded automatically for similar tasks |
| `reports/*.md` | Personal: `.devflow/reports/` (outside git) | explainer (on request) | explainer, scout. As hints; verified in the code |

As these files grow, the architect asks fewer questions and `scout` scans less code. Because they are shared with the team, `close` shows its proposed module summaries and lessons and asks for your approval before adding them.

## Git
- When build and tests pass in a step, `implementer` commits **locally** only the files changed in that step: `[PROJ-1234] <step title>` (just the title without a ticket).
- Before the first commit, if you are on `main`, `master` or `develop`, it stops and suggests creating a `feature/<task-id>` branch (`bugfix/<task-id>` for bugs).
- Agents never push, amend, rebase, reset, clean or force. You can squash the step commits yourself before the PR.
- `quick` does not commit.

## Team sharing
- **Shared (in git):** `.github/copilot-instructions.md`, `.devflow/templates/`, `.devflow/knowledge/` (project decisions, lessons, module summaries), project skills.
- **Personal (outside git):** `.devflow/active.md`, `.devflow/tasks/`, `.devflow/reports/`. The way to share a task's decisions with the team is the PR description produced by `/df-close`.
- **Personal (on your machine):** agents, commands, `org-decisions` and personal skills. Teammates who want to use dev flow run `setup.ps1` themselves.

## New project
1. Open the empty folder in VS Code and run `/df-setup` (it only creates the skeleton).
2. `/df-new-project <goal>`. The architect first asks whether there is an organizational template or reference project. If the reference project is in another folder, add it to the workspace (File → Add Folder to Workspace); otherwise it may not be readable.
3. The spec covers only the skeleton: layers, shared infrastructure, a test project and one example endpoint through all layers. Project and package creation is done with CLI commands such as `dotnet new`.
4. `/df-implement` → `/df-review` → `/df-close`. After that, `/df-task` for every feature.

## Token-saving rules
- **Open a new chat for every phase.** Handoff buttons switch the agent within the same chat, and the whole history of the previous phase is sent to the new model uncached. Buttons are handy for small tasks; for large ones use a new chat and the command.
- Stay in the same chat within a phase and do not switch models mid-chat; the cache is per model.
- **The implementer stops every 4 steps** and asks for `/df-implement` in a new chat. An agent resends the whole context on every tool call, so long sessions are the biggest cost item. The new session continues from the last step. `/df-auto` does this itself without asking you.
- Agents do not rewrite existing files; they edit only the changed lines. Output tokens cost 5 times more than input.
- In fix modes (pre-check finding, escalation, spec issue) the architect reads only what is needed, and so does the reviewer in the diff: file list first, generated files skipped, file by file.
- Code references use the form `file › Symbol (~line N)`. Even if the line shifts as code changes, the agent finds it by the symbol instead of searching again.
- Do not let Opus (architect, reviewer) do discovery. If context is missing, go back to `scout`.
- Build and test commands run quietly; the implementer runs only the current step's tests.
- Inline completions and Next Edit Suggestions do not cost credits. Use them instead of chat for simple coding.

## Models
The `model` field of every agent file defines a primary and a fallback model; the fallback is used if the primary is unavailable. Every command file (`en/prompts/`) also contains its agent's primary model. Fallbacks are not documented for command files, so they contain only the primary model. **When changing a model, update both places:** `en/agents/<agent>.agent.md` and the `en/prompts/df-*.prompt.md` files that call that agent. Then run `setup.ps1 -Lang en` again.

| Agent | Model | Why |
|---|---|---|
| scout, close, switch-task, status, researcher, security-scan | GPT-6 Luna → Haiku 5.5 | Search, recording, summaries and mechanical scans; cheapest tier |
| auto | Opus 5.5 → GPT-5.6 Sol | Must be at least the tier of the Opus subagents it calls |
| architect | Opus 5.5 → GPT-5.6 Sol | Decisions and spec; where quality is decided |
| implementer, quick | Sonnet 5.5 → GPT-6.1 Sol | Translating the spec into code, small work |
| bug-analyst | Sonnet 5.5 → GPT-6.1 Sol | Root cause analysis needs reasoning; complex bugs escalate to Opus |
| explainer | Sonnet 5.5 → GPT-6.1 Sol | Must read complex business rules correctly; a wrong explanation leads to wrong decisions |
| reviewer | Opus 5.5 → GPT-5.6 Sol | Reads only the diff; small context |
| setup, skill-maker | Sonnet 5.5 → GPT-6.1 Sol | Run rarely; accuracy matters |

According to the documentation, the `reasoning-effort` field is ignored in the Local harness.

---

## Customization
Always make changes in the files of this repository and run `setup.ps1` again. The copies in the VS Code profile folder are overwritten on the next install (the old one is kept as `.bak`).

| What | Where |
|---|---|
| An agent's model | `en/agents/<agent>.agent.md` → `model` field (primary, fallback) **and** that agent's command files `en/prompts/df-*.prompt.md` → `model` field |
| Principles and organization decisions | `~/.copilot/skills/org-decisions/SKILL.md` (personal; the install script never overwrites it) |
| Project decisions | In the project: `.devflow/knowledge/decisions.md` (in git; change it through a PR) |
| A project's templates | In the project: `.devflow/templates/en/`. `/df-setup` shows the difference and asks on update |
| Default templates | `en/agents/setup.agent.md` → "Templates" section |
| Session budget (4 steps) | `en/agents/implementer.agent.md` → "Session budget" |
| Part split threshold (8 steps) | `en/agents/architect.agent.md` → "Phase 2: Spec" |
| Size criteria (S/M/L) | `en/agents/scout.agent.md` → step 7 |
| Protected branches | `en/agents/implementer.agent.md` → "Git" |
| Ticket format | `en/agents/scout.agent.md` and `bug-analyst.agent.md` → "Ticket" |
| Security scan checks | `en/agents/security-scan.agent.md` → "Checks" |

**Adding a new agent:** create `<name>.agent.md` under `en/agents/` (for frontmatter fields see the [VS Code custom agent reference](https://code.visualstudio.com/docs/agents/reference/custom-agent-file-reference)). If you want a command shortcut, write `agent: <name>` in `en/prompts/df-<name>.prompt.md`. Remember to add it in both languages (see `CONTRIBUTING.md`).

## Updating and uninstalling
**Updating**
1. Update the repository (`git pull`).
2. `.\setup.ps1 -Lang en`. Changed files are backed up as `.bak`.
3. Run `/df-setup` once in each project. It asks if templates differ.
4. If `CHANGELOG.md` says a new section was added to the `org-decisions` skill, copy it into your own copy by hand.

**Uninstalling from the machine** (in the repository root, PowerShell):
```powershell
$h = "$env:APPDATA\Code\User\prompts"
Get-ChildItem .\en\agents, .\en\prompts | ForEach-Object { Remove-Item (Join-Path $h $_.Name), (Join-Path $h "$($_.Name).bak") -ErrorAction SilentlyContinue }
# To also delete the personal skill (its decisions are deleted too):
# Remove-Item "$HOME\.copilot\skills\org-decisions" -Recurse
```

**Removing from a project**
- Delete the `.devflow/` folder.
- Delete the "Dev flow" lines in `.gitignore` and the two `search.exclude` entries in `.vscode/settings.json`.
- Delete the "Dev Flow" section of `.github/copilot-instructions.md`. The other sections (project info, example patterns, build and test) help Copilot even without dev flow; keep them if you like.

## FAQ and troubleshooting
**The `/df-…` commands do not appear.**
Is Local selected in Session Target? Did you restart VS Code? Otherwise follow "If the agents do not appear" above.

**I have to use the Copilot harness.**
The agents also work in the Copilot harness, but commands and handoff buttons do not. Select the agent from the agent menu and type "continue". The question tool may be unavailable; agents then ask their questions as plain text.

**The model picker shows a different model, or the debug view shows the wrong model running.**
There are two possible causes. (1) The `model` names in the agent and command files must exactly match the names in your model picker; if not, fix them and run `setup.ps1` again. (2) VS Code has an open issue where the pinned model is overridden by the model picker's selection ([#338949](https://github.com/microsoft/vscode/issues/338949)). Start the agent with its command rather than from the menu; if it is still wrong, select the right model in the model picker by hand.

**Questions arrive as plain text, not clickable.**
The `askQuestions` tool is not available in your environment. No problem: answer like `1a 2b`, or write `recommended`.

**The implementer keeps saying "/df-implement in a new chat".**
On purpose: resetting the context every 4 steps lowers cost. You can change the threshold (Customization).

**An agent seems to work on the wrong task.**
See the active task with `/df-status`; change it with `/df-switch`.

**The quota still runs out quickly.**
Check which phase is expensive with `chat.subagents.showCreditUsage`. The most common causes: continuing in the same chat via handoff buttons, using `/df-auto` often, using the full flow instead of `quick` for small work.

**The architect asks too many questions.**
Have recurring decisions added to `decisions.md` (project) or `org-decisions` (organization); create skills for similar work with `/df-make-skill`. The number of questions drops over time.

**The implementer stopped on the `develop` branch.**
On purpose: it asks before committing on protected branches.

**`setup.ps1` does not run.**
Try `powershell -ExecutionPolicy Bypass -File .\setup.ps1 -Lang en`. If organization policy blocks it, copy the files by hand (Installation).

**Characters in the `setup.ps1` output are garbled.**
This comes from your console's code page; the installed files are not affected. Run `chcp 65001` first if you like.

**Someone on the team uses the Turkish version, someone the English one.**
Supported; see "Turkish version and shared structure".

## Glossary
| Term | Meaning |
|---|---|
| Task | A piece of work under `.devflow/tasks/<id>/`; the active task is in `.devflow/active.md` |
| Spec | The specification the architect writes and the implementer implements without guessing (`03-spec.md`) |
| Rule (R1…) | A business rule in the spec; each is linked to at least one test |
| Step (S1…) | One logical code change; each step is a separate build, test and commit |
| Test scenario (T1…) | A concrete scenario in Given / When / Then form; assigned to a step |
| NFR | Non-functional requirement (performance, audit, security); must be measurable |
| Part (P1…) | Independently reviewable sections of work with more than 8 steps |
| Pre-check | The implementer's coverage and consistency check of the spec before writing code |
| Escalation | The implementer sending a step it could not solve in 2 attempts to the architect |
| Review round | One pass of the reviewer; at most 2 rounds per part |
| Session budget | The implementer doing at most 4 steps in one chat |
| Lasting decision | A decision recorded so it is not asked again (project: `decisions.md`, organization: `org-decisions`) |
| Lesson | A one-line rule derived from recurring mistakes (`lessons.md`) |
| Module summary | A module's responsibility, key files and rules (`knowledge/modules/`) |
| Skill | An instruction package loaded on demand; can be generated from similar tasks |
| Subagent | An agent run by another agent in a separate context; cannot ask the user questions |
| Handoff | The button at the end of an agent's answer that switches to another agent in the same chat |
| Harness | The environment that runs agents (Local, Copilot…); this structure is designed for Local |
| AI Credit | Copilot's usage unit; 1 credit = 0.01 USD, consumed according to model token prices |

## Turkish version and shared structure
The `tr/` folder contains the Turkish version of the same flow (agents: `kesif`, `mimar`, `uygulayici`…, commands: `/df-gorev`, `/df-planla`, `/df-uygula`…). It is the default for `setup.ps1`.

Both versions can be used in the same project:
- Project file paths are language-neutral: `.devflow/active.md`, `tasks/`, `knowledge/`, `01-context.md`, `04-status.md`…
- The shared knowledge files (`knowledge/decisions.md`, `lessons.md`, `modules/`) are the same in both versions; their content stays in whatever language it was written, and both versions' agents read it.
- Templates are per language: `.devflow/templates/tr/` and `.devflow/templates/en/`.
- The section headings and the "Dev Flow" section of `copilot-instructions.md` are identical in both versions (English), so one version does not re-add sections set up by the other.
- Tasks are personal; a task finishes in the language it started in.

## Contents of this folder
```
en/
  agents/      scout, architect, implementer, reviewer, quick, bug-analyst, explainer, auto, status, setup, close,
               switch-task, skill-maker, researcher (helper), security-scan (helper)
  prompts/     df-task, df-bug, df-ask, df-auto, df-status, df-spec, df-implement, df-review, df-close, df-switch,
               df-new-project, df-setup, df-make-skill
  skills/
    org-decisions/SKILL.md   Organization-wide principles and decisions (copied once to ~/.copilot/skills/)
tr/            Turkish version
setup.ps1        Install and update script (-Lang tr | en)
LICENSE        MIT license
CHANGELOG.md   Release notes
CONTRIBUTING.md Contribution guide
```
Project-specific files (`.devflow/`, `copilot-instructions.md`) are created by `/df-setup`; their templates live in `en/agents/setup.agent.md`.
