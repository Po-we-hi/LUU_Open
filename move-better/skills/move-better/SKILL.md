---
name: move-better
description: "Explicit-only context review and migration workflow. Use when the user invokes $move-better or asks to inspect the current task context, choose what should move or be omitted, and prepare a clean handoff for a new independent Codex task without using /compact or modifying the source task."
---

# Move Better

## Goal

Prepare a controlled context migration from the current source task to a new independent task.

Use the review precision of the former Compact Better workflow, but produce a destination-task handoff instead of a custom compaction prompt. Model section C after the structure of current Codex compaction summaries: current task, progress and decisions, important context and constraints, critical artifacts, remaining work, and verification state.

This skill never controls `/compact`, writes `compact_prompt`, mutates `config.toml`, starts a restore timer, or claims to recover encrypted compaction text.

## Terms

- **Source task**: the main Codex task whose useful state should move.
- **Review task**: the side task running this skill. Its output is disposable review UI.
- **Destination task**: a new independent task initialized from the approved handoff.
- **Migration packet**: section C, used exactly as the destination task's first message.
- **Inherited context**: the model-visible source-task context available when the review task was created.

## Hard Boundaries

1. Treat inherited context as the default source of truth.
2. Do not read rollout JSONL, archived sessions, other side tasks, or prior hidden history by default. Those sources can reintroduce content already removed from the model-visible context.
3. Read an external source only when the user explicitly identifies it as required evidence or asks to recover a specific missing detail. Bring back only the requested fact.
4. Exclude review-task content from A/B/C: previous Move Better output, review corrections, status checks, tool logs, context forensics, screenshots of side tasks, and app UI text.
5. Do not modify the source task during review.
6. Create a destination with a new independent task. Never use fork for the final migration because a fork inherits the old context.

If the user adds source-task turns after opening the review task, state that the snapshot is stale and ask the user to restart Move Better from the updated source task. Do not guess the missing turns.

## Workflow

### 1. Announce The Review Boundary

Start normal mode with only the essential status:

```text
🧭 更好的上下文结构化迁移-预模拟
✅ 源任务保持不变；当前只生成迁移审阅稿
⚠️ 当前内容基于侧边任务创建时继承的上下文；审阅期间不要继续扩展源任务
⚠️ 最终迁移将新建独立任务，不使用 /compact，也不使用 fork
```

Do not show internal reasoning, raw context dumps, filesystem inventories, or tool output.

### 2. Build A: 迁移保留稿

Produce A as a numbered fenced code block. Use three-digit line numbers and preserve enough concrete detail for precise review.

Organize retained facts using the current compaction-style handoff categories:

- current task and objective;
- current progress and completed work;
- confirmed decisions and shortest necessary rationale;
- important context, constraints, and user preferences;
- critical files, identifiers, examples, and references;
- remaining work and ordered next steps;
- verification evidence, unresolved blockers, and relevant uncertainty.

Use concise review-only emphasis:

- `🔥` for core objectives and decisions;
- `✅` for verified progress or evidence;
- `⚠️` for fragile constraints, unresolved uncertainty, or details likely to be lost.

Preserve exact user wording when wording itself is a requirement. Do not replace concrete details with generic summaries merely to shorten A.

```text
【A. 迁移保留稿】
001 🔥 [当前目标] ...
002 ✅ [已完成] ...
003 🔥 [已确认决策] ...
004 ⚠️ [关键约束] ...
005 [关键资料] ...
006 [剩余工作] ...
007 ⚠️ [未决项] ...
```

### 3. Build B: 迁移舍弃稿

Produce B as a numbered fenced code block. B explains source-task material that will not enter the destination.

Classify every item as `舍弃` or `弱化`. For weakened content, identify the retained A line and state exactly what survives. Include potentially important details that a user may want to restore; do not hide ambiguous omissions.

Typical candidates:

- resolved debugging attempts and superseded assumptions;
- raw tool output, full logs, hashes, long diffs, and repeated status dumps;
- repeated explanations, confirmations, and screenshots whose conclusions already appear in A;
- stale plans and intermediate drafts replaced by an accepted decision;
- unrelated task branches and app UI artifacts.

Silently exclude review-task contamination. Do not list it in B unless debugging Move Better itself is the source task.

```text
【B. 迁移舍弃稿】
008 舍弃：...
    关系：对应 A002；只保留验证结论，不迁移原始输出。

009 ⚠️ 弱化：...
    关系：对应 A004；保留约束和一句原因，舍弃争论过程。
```

### 4. Build C: 最终迁移包

Read [references/handoff-schema.md](references/handoff-schema.md) before writing C.

C is the exact complete first message for the destination task. It is not a draft and must be fully visible during every review round.

Rules:

- Use the source task's original language or mixed-language structure.
- Include every high-salience A fact in the appropriate handoff section.
- Apply B precisely; keep only the stated retained relationship for weakened items.
- Use concrete paths, identifiers, commands, examples, and verification results only when needed to continue.
- Use the shortest causal note that preserves a confirmed decision.
- Do not include A/B headings, review line numbers, emoji, reply hints, review status, or side-task operation text.
- Do not include raw tool output, hidden reasoning, encrypted compaction claims, app UI labels, or instructions to inspect old history.
- Do not mention Move Better unless continuing development of Move Better is itself the destination task.

```text
【C. 新任务最终迁移包】
# Task handoff

Continue the task from the state below.

## Current task
...

## Current progress
...

## Confirmed decisions
...

## Important context and constraints
...

## Critical artifacts and references
...

## Remaining work
...

## Verification and unresolved items
...
```

Translate the headings when the source task is primarily Chinese. Keep English technical terms where they were used as identifiers or established terminology.

### 5. Ask For Review

After complete A/B/C, show only common operations:

```text
可回复：
- `通过`：确认当前迁移包
- `舍弃 003`：移除一个被误判保留的污染项
- `保留 009`：恢复一个被低估的舍弃项
- `提高 004`：让某项在 C 中更明确
- `展开 A002`：迁移更多必要细节
- `009 只保留一句原因`：弱化但不完全删除
- `通过并新建任务`：确认后创建独立目标任务
```

If the user requests a change, reprint the complete updated A, complete updated B, and complete updated C. Never use `...`, “其余不变”, or a partial C excerpt.

### 6. Finalize Or Move

For `通过`:

1. Reprint the complete final C without A/B.
2. State that it is ready as the destination task's first message.
3. Do not create a task without an explicit request.

For `通过并新建任务` or another explicit request to create the destination:

1. Use the task-creation capability when available.
2. Create a new independent task in the same workspace unless the user specifies another workspace.
3. Use exactly C as the initial message; do not prepend review notes or skill instructions.
4. Do not fork the source or review task.
5. Report the created task after creation succeeds.

If task creation is unavailable, return the complete final C and state that C is the destination task's initial message.

If the user explicitly requests a handoff file, write exactly C as UTF-8 Markdown to the requested path. Do not create a file by default.

## Quality Gate

Before presenting or moving C, verify:

- every core objective, accepted decision, fragile constraint, critical artifact, and remaining step in A appears in C;
- no B item marked `舍弃` appears in C;
- every B item marked `弱化` retains only its declared relationship;
- source-task facts are separated from review-task artifacts;
- C contains no review scaffold, emojis, line numbers, temp state, `/compact` instructions, or stale custom-prompt mechanics;
- the destination can continue without reading the old task, except for explicitly identified external artifacts;
- uncertainty is labeled instead of converted into fact.

## Limits

- This skill can only migrate context visible in the review task's inherited snapshot.
- It cannot recover details already lost by an earlier compaction unless the user explicitly supplies or identifies another source.
- A clean handoff reduces contamination by non-exposure; it cannot prove that every omitted detail was irrelevant.
- The source task remains available as an archive, but the destination should not depend on rereading it during normal continuation.
