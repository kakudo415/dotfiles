---
name: delegate
description: Work through forked child sessions that inherit the whole conversation, while the main session only coordinates and the user reviews each child's summary. Use for tasks that take many tool calls, such as editing code, writing a large document, or researching, so that the main session's context stays small.
compatibility: Requires an agent that can fork a child session inheriting the whole conversation, such as Claude Code.
---

# Delegate mode

This mode stays on for the rest of the session. If invoked with arguments, they are the first task.

## Which role you are

A fork inherits this skill. If you are a forked child session, follow "Fork" below. Otherwise follow "Main".

## Main

Keep your own context small so that the user's instructions, corrections, and background stay intact for every fork. Do only these yourself:

- Talk with the user.
- Split the task and fork.
- Relay each fork's summary and collect the user's review.

Fork everything else, including reading files, searching, fetching, writing, and editing. If you need an overall structure or a plan before splitting, fork a child to propose it first; the proposal comes back into your context and later forks inherit it.

Forking:

- Fork so that the child inherits this whole conversation. A fresh agent given a written brief loses the user's instructions and background.
- The brief states only what this fork does and does not do. Do not restate background; the fork already has the whole conversation.

After a fork returns:

- Relay its summary to the user as it is. The user cannot see it otherwise.
- Wait for the user's review. Their corrections now sit in context and apply to every later fork.
- Apply corrections with a new fork. It starts from the context that now holds the user's corrections, instead of inheriting the previous fork's grown context. Continue the same fork only for a small follow-up to the work it just did.

## Fork

You are the worker. Do the task in the brief yourself; never fork or spawn agents.

- Stay within the brief's scope. Other forks may be working on neighbouring parts at the same time, and the user reviews the work per scope.
- You cannot ask the user. On ambiguity, take the most conservative interpretation, continue, and record the assumption in your summary.
- Stop before any destructive, hard-to-reverse, or externally visible action and report it as awaiting confirmation.
- If the task is too large for one session, stop at a clean point, report what is done, and propose how to split the rest.

Finish with a short summary the user can review from:

- Whether the task in the brief is complete.
- What you did and what you decided, without diffs or file contents. They would fill the main session's context, which this mode exists to keep small.
- Assumptions you made.
- Anything awaiting confirmation.
