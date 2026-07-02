# LUU Open

Public Codex skills and lightweight agent workflows by LUU.

LUU Open is a public collection of reusable Codex skills, prompts, and small workflow packages. The repository is designed as a readable library: every package should be understandable from its own README, installable without private context, and narrow enough to adapt for a specific task.

LUU Open 是 LUU 公开整理的 Codex skills、提示词与轻量工作流集合。

这个仓库被设计成一个可阅读的工具库：每个包都应该能通过自己的 README 理解用途，不依赖私人上下文即可安装，并且保持足够窄，方便按具体任务改造。

## Design Principles / 设计原则

- Task-shaped: each package solves one repeatable workflow, not a broad personality or style preference.
- Transparent: prompts, scripts, and operating limits should be visible in the repository.
- Portable: public packages should avoid local paths, private logs, and project-specific assumptions.
- Minimal: add files only when they help installation, review, or reliable use.

- 面向任务：每个包解决一个可重复工作流，而不是抽象人格或泛化风格偏好。
- 透明可审：提示词、脚本和运行边界应能在仓库中直接检查。
- 可迁移：公开包应避免本机路径、私人日志和项目专属假设。
- 保持克制：只添加对安装、审阅或稳定使用有帮助的文件。

## Repository Layout / 仓库结构

Each top-level folder is a self-contained package:

每个一级目录都是一个自包含的包：

```text
compact-better/
  .codex-plugin/plugin.json
  skills/
    compact-better/
      SKILL.md
      scripts/
```

Package folders may include Codex plugin metadata, skill instructions, helper scripts, examples, and local verification notes when those files are necessary for reliable use.

包目录可以包含 Codex plugin 元数据、skill 说明、辅助脚本、示例和本地验证记录；是否保留这些文件，取决于它们是否能帮助他人可靠使用。

## Packages / 包

- [Compact Better](compact-better/README.md)
  - EN: Review and prepare a temporary compact prompt before manually running Codex `/compact`.
  - 中文：在手动执行 Codex `/compact` 前，先审阅并准备临时压缩提示。

## Status / 状态

This is a personal public library. Packages may evolve as the underlying Codex workflow changes. Each package README should state its own requirements, limits, and verification boundary.

这是一个个人公开工具库。随着 Codex 工作流变化，包内容可能继续演进。每个包的 README 应说明自己的运行要求、能力边界和验证方式。

## License / 许可

MIT. See [LICENSE](LICENSE).
