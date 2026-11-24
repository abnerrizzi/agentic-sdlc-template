# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`docs/glossary.md`**: the project glossary.
- **`docs/adr/`**: read ADRs that touch the area you're about to work in.

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them upfront. The `/domain-modeling` skill (reached via `/grill-with-docs` and `/improve-codebase-architecture`) creates them lazily when terms or decisions actually get resolved. When it does, it writes to `docs/glossary.md` and `docs/adr/`, not to a root `GLOSSARY.md`.

## File structure

Single-context repo:

```text
/
├── docs/
│   ├── glossary.md
│   └── adr/
│       ├── 0001-record-architecture-decisions.md
│       └── 0002-platform-agnostic-make-check.md
└── scripts/
```

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name), use the term as defined in `docs/glossary.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal: either you're inventing language the project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0003 (verify loop and self-critique), but worth reopening because..._
