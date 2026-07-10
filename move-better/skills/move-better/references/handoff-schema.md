# Destination Handoff Schema

Use this schema for section C. It adapts the structure of current Codex compaction handoffs for an explicit, user-reviewed move to a new independent task.

## Selection Test

Include a fact when at least one condition is true:

- it changes the destination task's objective, next action, or implementation choice;
- it is an accepted decision, user preference, or non-negotiable constraint;
- it is required to locate, modify, test, verify, or roll back relevant work;
- losing it would cause repeated investigation or a plausible wrong turn;
- it is unresolved uncertainty that the destination must not mistake for fact.

Omit or weaken a fact when it is resolved process history, duplicated evidence, raw execution output, obsolete planning, review UI, or unrelated work.

## Required Structure

Use source-language headings. The English names below define semantics, not mandatory display text.

### Current task

- Workspace or project only when operationally relevant.
- Literal objective and desired outcome.
- Current scope boundary.

### Current progress

- Completed work that affects continuation.
- Current implementation or document state.
- The active plan position, if a plan exists.

### Confirmed decisions

- Accepted choices and settled mechanisms.
- Shortest necessary rationale where the reason prevents reversal.
- Rejected alternatives only when they are likely to be repeated.

### Important context and constraints

- User preferences and required behavior.
- Security, isolation, compatibility, and workflow boundaries.
- Assumptions and uncertainty labels.

### Critical artifacts and references

- Necessary file paths, task IDs, commands, examples, APIs, or data.
- Verification evidence in summarized form.
- Exact quotations only when wording is decision-critical.

### Remaining work

- Ordered next steps.
- Clear completion criteria.
- Required user decisions or external dependencies.

### Verification and unresolved items

- Tests already run and their conclusions.
- Known gaps, blockers, residual risks, and open questions.
- State what is directly verified versus inferred.

## Clean Final Template

```markdown
# 任务交接

从以下状态继续任务。

## 当前任务
[目标、范围和必要工作区信息]

## 当前进度
[已完成内容、当前状态和计划位置]

## 已确认决策
[决定及防止错误回退所需的最短原因]

## 重要上下文与约束
[用户偏好、硬约束、边界和不确定性]

## 关键资料与引用
[继续任务所需的路径、标识、示例和证据结论]

## 剩余工作
[按顺序排列的后续步骤和完成标准]

## 验证与未决项
[已验证内容、阻碍、风险和待确认问题]
```

Do not add empty decorative sections. If a required category has no material content, omit the heading rather than writing filler such as “none”.
