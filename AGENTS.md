# AGENTS.md

## Project overview

The Pi-hole documentation, published at [docs.pi-hole.net](https://docs.pi-hole.net). Built with MkDocs and the Material for MkDocs theme.

## Repository layout

- `docs/` - all documentation content (Markdown), organised by topic (`main/`, `ftldns/`, `api/`, `docker/`, `guides/`, etc.)
- `mkdocs.yml` - site configuration and navigation. New pages must be added to the `nav` section here.
- `overrides/` - theme overrides
- `requirements.txt` - Python dependencies (MkDocs and plugins)
- `package.json` - npm scripts for building and linting

## Dev environment tips

- Set up with `pip install -r requirements.txt` and `npm install`.
- Live preview while editing: `npm run serve`
- Match the surrounding style: sentence-case headings, fenced code blocks with language tags, and the admonition syntax already in use.

## Testing instructions

- Run `npm test` before proposing changes; CI enforces it.
- This builds the site with `mkdocs build --clean --strict` (broken internal links and nav errors fail the build), then runs markdownlint and a link checker.

## PR instructions

- **This repository uses `master` as its default branch**; pull requests target `master` (unlike most Pi-hole repositories, which use `development`).
- Read the [contributors guide](https://docs.pi-hole.net/guides/github/contributing/)
- Every commit must be signed off (DCO): use `git commit -s`.
- Run `npm test` before committing.
- Use Unix line endings (LF).
- Documentation should describe released Pi-hole behaviour. Docs for unreleased features normally land alongside or after the feature is released, not before.
- The correct project spelling is "Pi-hole" (capital P, lowercase h, hyphen). Use it consistently.

## Common pitfalls

- Adding a page without adding it to `nav` in `mkdocs.yml`, which fails the strict build.
- Documenting behaviour from the `development` branches of other repos as if it were released.
- Forgetting the DCO sign-off on commits.
- Markdown that passes a casual preview but fails markdownlint.
