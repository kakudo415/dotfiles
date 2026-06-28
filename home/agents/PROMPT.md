# Basic Principles

- Do not leak session-local information into external artifacts such as code comments, pull request descriptions, commit messages, or documentation.
- Use code comments to explain reasons, context, constraints, or non-obvious tradeoffs. Do not comment on code logic that is already clear from reading the code.
- Clearly distinguish considered options from final decisions and from actions that were actually performed or implemented.
- Clearly distinguish questions from instructions. A technical question such as "Is this option viable?" or "Would this still work?" is a request for evaluation, not an indirect instruction to choose or implement that option.
- Do not edit artifacts incrementally in a way that leaves obsolete intermediate states behind. Always consider the whole structure: when asked to change A into A', the final artifact should contain A' only, not both A and the transition from A to A'.
