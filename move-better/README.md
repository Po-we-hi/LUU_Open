# Move Better

Move Better is an explicit Codex skill for reviewing the current task context and preparing a clean handoff to a new independent task.

It keeps the useful review surface from Compact Better, but removes the obsolete custom compact-prompt workflow. It does not write `compact_prompt`, wait for `/compact`, or restore temporary files.

## Workflow

1. Run the skill from a side task that inherited the source task context.
2. Review `A` (content to move), `B` (content to omit or weaken), and `C` (the exact destination-task handoff).
3. Adjust numbered items until `C` is clean.
4. Confirm `C`, then optionally create a new independent task with `C` as its first message.

The final handoff follows the structure used by current Codex compaction summaries: current task, progress and decisions, important context and constraints, critical artifacts, remaining work, and verification state.

## Isolation

- The source task is not modified.
- The destination must be a new independent task, not a fork.
- Side-task review output, tool logs, UI artifacts, and historical session archives are excluded by default.
- The skill does not attempt to decrypt or control Codex remote compaction.

## Install

This package is a Codex plugin. Install it from a Codex marketplace that points to `LUU_Open/move-better`.

It is explicit-only: invoke `$move-better` when you want to review and move task context.

```text
move-better/
  README.md
  .codex-plugin/plugin.json
  skills/
    move-better/
      SKILL.md
      agents/openai.yaml
      references/handoff-schema.md
```

## License

MIT. See the repository root license.
