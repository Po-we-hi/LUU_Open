# LUU Open

Reusable Codex skills and skill-only plugins maintained by LUU.

This repository collects small, practical Codex workflows that can be installed, inspected, and adapted independently. Each top-level folder is a standalone skill or skill-only plugin.

LUU 维护的 Codex skills 与轻量 plugin 开源仓库。

本仓库收集可复用、可检查、可独立改造的 Codex 工作流。每个一级目录都是一个独立 skill 或 skill-only plugin。

## Repository Layout / 仓库结构

Each skill uses its own top-level folder:

每个 skill 使用独立的一级目录：

```text
compact-better/
  .codex-plugin/plugin.json
  skills/
    compact-better/
      SKILL.md
      scripts/
```

This keeps the repository easy to browse while avoiding unnecessary one-repo-per-skill overhead. A skill should move to its own repository only when it grows into a larger standalone project with its own release cycle, issue tracker, website, or non-skill runtime.

这样可以保持浏览和维护简单，同时避免为每个小 skill 单独建仓库。只有当某个 skill 发展成独立项目，拥有自己的发布节奏、issue 管理、文档站或非 skill 运行时，才适合拆成单独仓库。

## Skills / 技能

- [Compact Better](compact-better/README.md): prepares a reviewed, temporary compact prompt before a manual Codex `/compact`.
  - 中文：在手动执行 Codex `/compact` 前，先生成可审阅的保留/舍弃模拟，并临时写入压缩提示，随后恢复基线。

## License / 许可

MIT. See [LICENSE](LICENSE).
