---
name: delegate
description: Run a large task as its editor. The main session splits the task into subtasks, briefs a forked session per subtask, reads the reports, and relays what matters to the user. The forked sessions, which inherit the whole conversation, do the reading, writing, and editing. Use for deliverables that split into parts and take many tool calls, such as a multi-section document, a change across modules or services, or an investigation with several questions.
compatibility: Requires an agent that can fork a child session inheriting the whole conversation and message it again later, such as Claude Code.
---

# Delegate mode

The main session is the editor: it splits the task, briefs, reads reports, relays, and carries information between subtasks. Forked sessions are the writers: each owns one subtask and does its reading, searching, editing, and verifying.

The mode stays on for the rest of the session. Arguments, if any, are the first task.

## Roles

A forked session inherits this skill. If you are one, follow Forked session at the end.

### The main session does itself

- Talk with the user and answer their questions.
- Understand the inputs and the shape of the deliverable before the first fork, enough to split it, brief, and judge reports.
  - Document or code change: usually build the outline or skeleton yourself.
  - Investigation: know the questions and where the answers would come from.
- Split, brief, read reports, and route information between subtasks.
- Keep and record the list of settled rules.
- A quick lookup or calculation is fine when it decides the next step and its output is small.

### The main session forks

- Work that produces or edits the deliverable.
  - Measure by what enters the main session's context, not by the size of the change.
  - A one-line edit to a page you have not read costs a full read: send it to the owning fork.
  - A change you can make from what you already hold: make it yourself.
- Investigation with large tool output: many pages or files, wide searches, many commands.
- Passes over the whole deliverable: consistency checks, summaries, final reviews.

### Fresh sessions

A read-only lookup that needs nothing from the conversation, such as listing the callouts in a page, goes to a fresh session with a self-contained prompt. A fork re-reads the whole conversation and costs more.

## Subtasks and phases

Split the deliverable along its own structure into subtasks that one fork can own and edit without touching the others.

| Deliverable | Subtasks | After all the others |
|---|---|---|
| Document | Chapters or sections | Summary chapter, index, cross-references |
| Change across a codebase | Modules, services, packages | Shared types, integration, cross-module tests |
| Investigation | Questions or sources | Synthesis, comparison |
| Response to review findings | Groups of findings by area | Consistency of the responses |

When forks edit the same artifact at once, each brief names the neighbouring subtasks and their owners, and each fork edits only its own.

### Phases

1. **Ground.** Understand the inputs and the deliverable well enough to split it. Build the skeleton yourself if there is one. The rule list starts from the user's instructions so far and grows with their corrections.
2. **Pass.** One directive applied to every subtask: the initial writing, or a later correction or premise that touches every part.
   - If the user asks, or you are unsure of the expected structure or style, do one subtask first and have the user review it. Send corrections to the same fork until it passes.
   - Then run the rest, one at a time or in parallel per the user's checkpoint preference. Launch independent forks in the same turn.
   - Dependent subtasks wait. Subtasks that span the whole deliverable run last, in every pass.
3. **Finalize.** One fork checks the whole: consistency between parts, duplicates, dangling references, traces of the editing process, body versus summary.

### Fork lifetime

- A fork owns its subtask until it is stable. Corrections to that subtask go to the same fork by message; it holds the sources, the structure, and the scratch files.
- A new fork is needed for a new subtask, or when the owning fork cannot be resumed.
- For a later pass, message the owning forks or start new forks split by range. New forks suit a pass that changes premises: they start from the context that holds the change.

## The brief

The fork inherits the conversation, but the user's decisions are scattered across it. The brief gathers the current state in one place. Six parts, in order:

1. **Target and scope.** The identifier: page, file, module. Neighbouring subtasks and their owners. Edit only within scope.
2. **Settled premises.** Facts the user has confirmed.
3. **Settled rules, in full.** Paste the whole current list every time. Never summarize or paraphrase; a restated rule drifts.
4. **Leads.** Facts from earlier reports that bear on this subtask, with sources, to verify against primary sources before use.
5. **Procedure.** Read the current state. Do the work. Re-read to verify.
6. **Report items.** What this report must contain. Always:
   - complete or not
   - decisions and judgments with grounds
   - open items by kind
   - assumptions
   - awaiting confirmation
   - information useful to other subtasks but not written into the deliverable
   - never diffs or contents

A follow-up message to a fork is the same shape, shortened: what changed, what to do, what to report.

## Relaying to the user

The user cannot see reports. Do not paste them. Write, in order:

1. Outcome: complete or not, key results and counts.
2. What the user needs to decide.
3. Side effects: comments added, items moved, anything that will look different.
4. Information held for other subtasks.
5. What runs next.

With several forks running, relay each report briefly as it arrives and aggregate once at the end. While forks run, say in a few lines what is running and what will come back.

Route leads: a lead for another subtask goes into its next brief or message. A mistake found in another subtask goes to its fork, with the source to verify against.

## Checkpoints

The user sets how often to stop. Without an instruction, keep going and relay as reports arrive. Always stop when:

- A judgment belongs to the user: interpreting a criterion, changing a result, a trade-off.
- An action is destructive, hard to reverse, or visible outside: push, publish, send, delete.
- A premise the work depends on looks wrong.

To change a judgment or interpretation: present it with grounds, the user approves or changes it, then send the approved version to the fork. A fork never changes a settled judgment on its own.

## Records

When the user settles a rule, add it to the rule list at once and to persistent memory if there is one, so the next session starts from the same premises. Record the rule as applied, not the conversation behind it.

## Forked session

You own one subtask. Do the work yourself; do not fork.

- Edit only within scope. Note anything outside it in one sentence.
- Read first, work, re-read to verify.
- You cannot ask the user. On ambiguity, take the conservative reading, continue, and record the assumption.
- Do not change a settled rule or judgment. If evidence contradicts one, follow the rule and report the conflict.
- Stop before any destructive, hard-to-reverse, or externally visible action; report it as awaiting confirmation.
- If the subtask is too large, stop at a clean point, report, and propose a split.

Report once per directive, with the items the brief asked for, and always:

- complete or not
- decisions and judgments with grounds
- open items by kind
- assumptions
- awaiting confirmation
- information useful to other subtasks, with sources
- no diffs, no file or page contents
