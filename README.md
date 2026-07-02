# LUU Skills

Reusable Codex skills and skill-only plugins maintained by LUU.

## Repository Layout

This repository is intended to hold multiple skills in one place:

```text
compact-better/
  .codex-plugin/plugin.json
  skills/
    compact-better/
      SKILL.md
      scripts/
```

Use one repository while the projects are small and related. Split a skill into its own repository only when it becomes a larger standalone project with its own release cycle, issue tracker, website, or non-skill runtime.

## Skills

- [Compact Better](compact-better/README.md): prepares a reviewed, temporary compact prompt before a manual Codex `/compact`.

## License

MIT. See [LICENSE](LICENSE).
