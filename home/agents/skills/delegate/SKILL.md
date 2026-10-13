---
name: delegate
description: Work through forked child sessions that inherit the whole conversation, while the main session only coordinates and the user reviews each child's summary. Use for tasks that take many tool calls, such as editing code, writing a large document, or researching, so that the main session's context stays small.
compatibility: Requires an agent that can fork a child session inheriting the whole conversation, such as Claude Code.
---

# Delegate mode

The main session coordinates, forked sessions do the work, and the user reviews each forked session's summary. The mode stays on for the rest of the session. If invoked with arguments, they are the first task.

## Roles

A forked session inherits this skill. If you are one, follow Forked session. Otherwise follow Main session.

### Main session

- Talk with the user, split the task, fork, and relay summaries. Everything else, including reading files, is a forked session's job. If you need a plan or structure first, fork for it.
- Fork so that the forked session inherits the whole conversation. A fresh agent given a written brief loses the user's instructions and background.
- The brief is the scope only, as in the examples below. The forked session reads this skill, so do not repeat background, rules, or the summary format; a rule restated in other words drifts and competes with the skill.
- Apply corrections with a new forked session, which starts from the corrected context. Continue the same forked session only for a small follow-up to its own work.

### Forked session

- Do the task yourself. Do not fork again.
- Stay within the brief's scope. Other forked sessions may own the neighbouring parts.
- You cannot ask the user. Take the conservative reading, continue, and note the assumption in your summary.
- Stop before destructive, hard-to-reverse, or externally visible actions and report them as awaiting confirmation.
- If the task is too large for one session, stop at a clean point, report, and propose a split.
- End with a summary as in the examples below: complete or not, what you did and decided, assumptions, and what awaits confirmation. No diffs or file contents; they would fill the main session's context.

## Examples

### Writing a document in parallel, then correcting it

User:

> Write docs/guide.md following the outline in it.

The main session forks one session per chapter. The brief to one of them:

> Write chapter 3 (deployment) of docs/guide.md. Chapters 2 and 4 are being written by other forked sessions.

Each forked session ends with a summary, which the main session relays to the user as it is:

> Chapter 3 is written. It covers the three deployment targets in the outline with the deploy commands found in the source, and points to the environment variable table in chapter 2 instead of repeating it. The outline did not name the staging cluster, so I took the name from the Makefile. Nothing awaits confirmation.

User:

> Those are the 2.x commands. The guide is for 3.0, where the deploy subcommands and the config format changed. Use the 3.0 branch.

The main session forks a new session:

> Rewrite chapter 3 (deployment) of docs/guide.md against the 3.0 branch.

The correction now sits in the context that every later forked session inherits.

### Renaming a field across services, with a decision that spans two of them

User:

> Rename customer_id to account_id across the services in this repo.

The main session forks one session per service. The brief to one of them:

> Rename customer_id to account_id in the events service. The other services are being handled by other forked sessions.

The summary:

> Renamed in the events service's code, tests, and migration, except in the order-created event. It is consumed by the billing service and by an external partner, so renaming the field there breaks the partner's integration. Options: rename it anyway, emit both names for a transition period, or leave the event as is. Awaiting confirmation: which one?

User:

> Emit both for now. Removing the old name is tracked separately with the partner.

The change now spans the emitter in events and the consumer in billing, which two forked sessions handled separately, so the main session forks a new session:

> Emit both customer_id and account_id in the order-created event, and make the billing consumer read account_id. The rest of both services is already renamed.
