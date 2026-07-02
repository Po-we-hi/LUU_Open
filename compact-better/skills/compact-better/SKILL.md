---
name: compact-better
description: "Manual-only helper for pre-/compact context simulation: use only when the user explicitly invokes $compact-better or asks to prepare a reviewed, low-pollution manual compaction."
---

# Compact Better

## Goal

Prepare one manual `/compact` by running a side-session "更好的上下文结构化压缩-预模拟": show what the main-session compacted continuation should retain, show what should be discarded or weakened, preview the exact model-visible compact prompt, then temporarily write that prompt and restore the baseline.

This skill does not trigger `/compact`, block other compactions, edit past transcript text, or prove the hidden compacted plaintext. It only controls a file-backed compact prompt for the next manual compaction.

## Terms

- Main session: the conversation where the user will manually run `/compact`.
- Side session: the Codex side chat running this skill. Treat side-session content as disposable review UI, not as source material for A/B/C.
- Active prompt file: `%USERPROFILE%\.codex\compact-better.md` by default.
- Clean baseline: the standard content in `compact-better.baseline.md`, stored beside the active prompt file.
- Temp prompt: the complete final prompt preview from section C, written exactly to `compact-better.md`.
- Private state: `compact-better.state.json`, stored beside the active prompt file and used only by the helper to track the temp hash and restore timing.
- Soft constraint: prompt guidance for the compaction model. It is not a guarantee.

## State Rules

The only legal resting state is:

```text
compact-better.md = baseline clean
```

`config.toml` must point Codex at the active prompt file:

```toml
experimental_compact_prompt_file = 'C:\Users\<you>\.codex\compact-better.md'
```

Do not mutate an inline `compact_prompt` block. If a non-empty inline `compact_prompt` is active, stop: Codex gives the inline prompt priority over the file-backed prompt, so editing `compact-better.md` would not affect `/compact`.

Normal runs only control these adjacent files:

- `compact-better.md`
- `compact-better.baseline.md`
- `compact-better.state.json`
- `compact-better.backup-YYYYMMDD-HHMMSS.md`

Never place internal markers such as `COMPACT-BETTER TEMP SPEC` into `compact-better.md`. The active prompt file is model-visible, so it must contain only the final compact prompt.

Use the bundled helper when possible:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\compact-better.ps1" -Mode status
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\compact-better.ps1" -Mode ensure-baseline
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\compact-better.ps1" -Mode write-temp -PromptPath "<final-compact-better.md>"
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\compact-better.ps1" -Mode restore-after -DelaySeconds 180
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\compact-better.ps1" -Mode restore
```

If the helper reports a missing `experimental_compact_prompt_file`, missing `compact-better.md`, active inline `compact_prompt`, missing baseline, or unknown non-clean prompt, stop and report the exact state.

## Workflow

### Invocation Modes

If the user explicitly invokes `compact-better`, `$compact-better`, the Compact Better side action, or asks to prepare a reviewed manual compaction, use normal mode:

1. Run the self-check.
2. If the state is safe, continue in the same response to A/B/C.
3. Do not stop after a clean `status` report.
4. Do not ask "if you want to formally run compact-better" after the user has already invoked this skill.

Use read-only status mode only when the user explicitly asks to inspect, check, audit, or report the `compact-better` state without preparing a compaction. In read-only status mode, run `status`, report the state briefly, and stop.

### 0. Self-Check

Run `status`, then `ensure-baseline`. `ensure-baseline` is part of the self-check, not the temp-write step. It is allowed in normal mode because it either confirms the clean baseline or restores the only legal resting state. It must not be treated like `write-temp`.

If `status` and `ensure-baseline` show a safe clean state, continue immediately to section 1 and generate A/B/C in the same response. Stop after self-check only when:

- the user explicitly asked for read-only status mode;
- the helper reports an unsafe state;
- `ensure-baseline` restored a dirty prompt and the user should be told before continuing.

Normal user-facing output should be concise and risk-oriented, not a tool log:

```text
🧭 更好的上下文结构化压缩-预模拟
✅ compact-better.md = 基线(干净)，尚未写入 temp
⚠️ 从现在起尽量不要在主会话新增内容；侧边 fork 看不到新增轮次
⚠️ 写入 temp 后请尽快回主会话 /compact；恢复前不要触发其他会话 compact
```

If the helper had to restore a dirty prompt, say that explicitly:

```text
⚠️ compact-better.md = 非干净；已从 baseline 恢复
```

Do not show hashes, full JSON, command output, long path lists, or git status unless the state is unsafe or the user asks.

### 1. Produce The Pre-Compaction Simulation

Use the side session's inherited context. The side session is a fork: it can review current context in detail without adding output to the main session, but it cannot see main-session turns added after this point.

Before writing A/B/C, apply the side-session exclusion boundary:

- A/B/C are a processing module for the main session only. They simulate what the next main-session continuation should keep after `/compact`.
- Do not treat prior or current side-session content as source material for A, B, or C. Side-session content is review UI and disposable.
- Exclude previous or current `compact-better` outputs, A/B/C drafts, final prompt previews, reply-option hints, temp/restore notices, status checks, helper logs, JSONL/read_thread/session forensics, context-pollution audits, context-check turns, screenshots or pasted side-chat output, and tool output produced only to inspect compaction behavior.
- Apply this exclusion silently. Do not list excluded side-session content in B, and do not add a C rule saying side-session content was omitted. B is for main-session details that would be omitted or weakened; side-session material should disappear from A/B/C entirely.
- Do not mention phrases such as `side-session`, `side conversation`, `当前侧边会话`, `compact-better 自检`, `helper hash`, `status JSON`, `本文 A/B/C`, or `review scaffold` inside A/B/C unless the user's main task is debugging `compact-better` itself.
- Also silently exclude app UI artifacts and preview chrome: browser preview/open labels, attachment viewer text, copied button labels, timestamps, app status labels, and stray text such as `网页预览`, `网站`, `Open`, or `打开方式`.
- Exception: if the user explicitly says a side-session conclusion should enter the main compact summary, restate only that conclusion as a main-session decision. Do not carry over the side-session transcript, tool trail, or review scaffold.

Produce A and B as numbered fenced code blocks. Use three-digit line numbers so the user can give precise corrections. Preserve concrete details; reduce review cost through structure rather than by dropping important context.

Do not create a separate risk-edge section. Classify every item into A or B first, then annotate special cases in place.

Before writing A, apply the main-session continuation filter:

- A only contains facts useful for the next LLM after the main session `/compact` resumes.
- Do not put side-session operation facts in A: clean status, no temp written, pending review, this side session did not modify files, reply-option hints, helper JSON status, restore-window warning text, side-session boundary statements, compaction forensics, or app/browser preview chrome.
- File cleanliness and temp-window state belong in the opening safety notice, not A or C, unless the user's actual task is debugging `compact-better` state.
- A "next step" must be a next step for the main task after `/compact`, not the next step of this skill run.

#### A. 模拟保留稿

This is the likely compacted continuation body. Include current objective, accepted decisions, verified mechanisms, durable constraints, main-task next steps, and critical identifiers. A must use brief emoji markers on high-salience review lines: `🔥` for core objectives/decisions, `✅` for verified state, and `⚠️` for fragile constraints or easy-to-drop details. These markers are for user review only and must not enter section C.

```text
【A. 模拟保留稿】
001 🔥 当前目标：...
002 🔥 已定机制：...
003 ⚠️ 易误删但保留：...
004 当前状态：...
005 下一步：...
```

#### B. 模拟舍弃稿

This is what the rules would omit or weaken from the main session. Include details that might look important but should not silently enter the compacted continuation. For every weakened item, keep the retained part in A and put the discarded detail in B with its relationship to A. B should also use concise emoji emphasis on high-salience lines, such as `⚠️` for easy-to-misclassify omissions. Do not list side-session/tool-status/UI artifacts here; drop them silently instead.

```text
【B. 模拟舍弃稿】
006 舍弃：完整工具 JSON、hash、长 config 展开、重复 git status。
    关系：对应 A002/A003；最终只保留机制结论和必要路径，不保留执行噪音。

007 弱化：已解决的路径、语法、转义、探索错误。
    关系：对应 A004；只在解释未解决 blocker 时保留一句。

008 舍弃：主会话里的重复截图描述、完整粘贴文本、长篇工具输出和重复确认语。
    关系：如果其中含有主任务结论，把结论保留在 A；证据展开和重复外壳不进入 C。
```

### 2. Preview The Exact Final Prompt

Produce section C as the exact complete content that will be written to `compact-better.md` if the user confirms. C is for the compact model, not for the user interface.

Rules for C:

- Start with the clean baseline prompt content.
- Add only the minimum extra constraints needed for this compaction.
- Do not include line numbers, emoji, A/B headings, operation hints, helper state, hashes, internal markers, or app UI artifacts.
- Do not include or name transient side-session operation state: status checks, no-temp notices, pending review/confirmation steps, reply options, side-session boundary statements, context audits, compaction forensics, restore-window safety instructions, browser preview/open labels, attachment viewer labels, timestamps, or other UI chrome.
- For normal non-`compact-better` tasks, do not add a model-facing bullet about side-session cleanup. Apply that cleanup silently. If a generic cleanup rule is needed, use only a short phrase such as `Omit transient tool, UI, and operation artifacts`.
- Include current operational state only when the user explicitly asks the future agent to continue debugging `compact-better` itself.
- Include concrete retain and omit/weaken constraints from A/B when they can change the compact result.
- Do not paste A/B in full. Translate A/B into a short model-facing prompt.

Shape:

```text
【C. compact-better.md 最终内容预览】
You are performing a CONTEXT CHECKPOINT COMPACTION...

For this compaction, additionally:
- Preserve ...
- Omit ...
- When an omitted detail explains a retained decision, keep only the shortest causal note.
- Omit transient tool, UI, and operation artifacts; do not preserve the review scaffold, line numbers, emoji labels, or this pre-compression simulation format.
```

### 3. Ask For Review

End with common operations:

```text
可回复：
- `通过`
- `舍弃 003`：某个被误判保留的污染项不要进摘要
- `保留 007`：某个被低估的舍弃项要进入摘要
- `提高 004`：某项需要更明确地进入最终 prompt
- `展开 A002`：保留更多机制细节
- `007 只保留一句原因`：弱化但不完全删除
```

If the user requests changes, regenerate the affected A/B lines and section C. Then reply with a concise change note followed by the complete updated A/B/C review state, not only the changed lines or a partial C excerpt. The user needs the full current state to judge whether the next prompt is clean.

Revision reply rules:

- Reprint the full updated A fenced block, full updated B fenced block, and full updated C fenced block.
- Renumber A/B lines if removals or moves created gaps.
- Do not use `...`, "key changes", or "rest unchanged" inside A/B/C. If C is long, split the fenced block only at natural paragraph boundaries, but preserve the complete text.
- Keep common operation hints after the full A/B/C so the user can continue editing from the current version.
- After the common operation hints, stop the response. Do not append browser preview/open labels, timestamps, app UI text, or any webpage-preview artifact.

Do not write temp until the user confirms the final C.

### 4. Write The Temp Prompt

After confirmation, create a temporary file containing exactly section C content, without the `【C...】` heading. Pass it to:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\compact-better.ps1" -Mode write-temp -PromptPath "<final-compact-better.md>"
```

After `write-temp` succeeds, broadcast:

```text
🚨 临时压缩提示 compact_prompt 已成功写入
✅ compact-better.md = temp(非干净)
请立刻回主会话执行 /compact

下方恢复计时器只是自动恢复等待；写入已经完成，不是仍在写入。
计时器结束前不要触发其他会话 compact，也不要继续扩展主会话内容。
```

Also broadcast the fixed limits:

- 留删是软约束，效果取决于最终 prompt 和 compact 模型执行。
- 写入 temp 后、用户在主会话 `/compact` 前新增的轮次，会被压缩且预压缩模拟未覆盖。
- 压缩完成到恢复之间若再压缩，可能复用陈旧规则；检测延迟堵不住。
- 要中止随时关侧边会话；下次触发第 0 步会先自检并尝试恢复。
- 要查结果直接看主会话记录。

### 5. User Manually Compacts

Do not trigger `/compact` from this skill. The user runs `/compact` in the main session and checks the result there.

Do not add new main-session turns between final preview and `/compact`; this skill cannot cover them.

### 6. Restore After Delay

Immediately after the step 4 broadcast, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File "<skill-dir>\scripts\compact-better.ps1" -Mode restore-after -DelaySeconds 180
```

When it completes, broadcast:

```text
✅ compact-better.md 已恢复基线
可以继续正常对话；如需再次压缩，请重新触发 Compact Better。
```

If restore failed, broadcast `compact-better.md = temp/unknown(non-clean)` and run `restore` once. If that also fails, report the exact helper error, state file path, and baseline backup path.

## Mechanism Notes

- `/compact` runs as a separate compaction task and installs a replacement history; the compaction process itself is not preserved as an ordinary conversation turn.
- Side-session A/B output is review UI only and must not become source material for later A/B/C runs. C must stay short and clean because it is model-visible.
- `compact-better.md` should contain the full final prompt during temp state, not an appended internal spec block.

## Verification Boundary

If the user asks whether compaction happened, verify only structural markers when available:

- `contextCompaction` from thread-reading tools.
- `compacted`, `replacement_history` with `type: compaction`, or `context_compacted` in local Codex session logs under `%USERPROFILE%\.codex\sessions\YYYY\MM\DD\`.

Do not claim the hidden compacted body followed A/B/C unless the user confirms it from the main session. The compacted body is not generally plaintext-verifiable from those markers.

Confidence labels:

- Compaction occurrence from markers: `确定`.
- Keep/omit effect from final prompt alone: `较少验证信息的推测`.
- Keep/omit effect confirmed by visible main-session result: confidence depends on the user-visible evidence.
