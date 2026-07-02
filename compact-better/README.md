# Compact Better

Compact Better is a manual Codex skill for preparing one reviewed `/compact`.

It runs in a side session, shows what the next compacted continuation should keep or omit, previews the exact model-visible compact prompt, writes that prompt temporarily, and restores the clean baseline after a short delay.

## What It Does

- Runs a safety check for a file-backed compact prompt.
- Produces review sections:
  - `A`: facts likely worth retaining after compaction.
  - `B`: details likely worth omitting or weakening.
  - `C`: the exact final prompt to write for the next manual `/compact`.
- Waits for user confirmation before writing anything.
- Writes the temporary prompt only for the next manual `/compact`.
- Restores the baseline prompt after the configured delay.

## What It Does Not Do

- It does not trigger `/compact` for you.
- It does not prove the hidden compacted plaintext followed the prompt.
- It does not block every other conversation from compacting during the temporary window.
- It is a soft prompt-control helper, not a hard guarantee.

## Requirements

- Codex with skill/plugin support.
- Windows PowerShell for the bundled helper script.
- A file-backed Codex compact prompt configured in `config.toml`.

Example `config.toml` entry:

```toml
experimental_compact_prompt_file = 'C:\Users\<you>\.codex\compact-better.md'
```

The helper expects the active prompt file to be named `compact-better.md`.

## Install Shape

This folder is a skill-only Codex plugin:

```text
.codex-plugin/plugin.json
skills/compact-better/SKILL.md
skills/compact-better/scripts/compact-better.ps1
```

If this plugin is stored in a Codex marketplace repository, install it from that marketplace. If you are testing locally, add the plugin folder to a local Codex plugin marketplace.

## Usage

In a side session, explicitly invoke:

```text
$compact-better
```

Review sections `A`, `B`, and `C`. Reply with `通过` when section `C` is correct. Then return to the main session and run:

```text
/compact
```

## License

MIT. See the repository root license.
