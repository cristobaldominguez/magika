# Repository Guidelines

## Project Structure & Module Organization

This repository is currently empty and has no detected source tree or Git metadata. Keep the layout simple and explicit as the project grows:

- `src/` — application or library source code.
- `test/` or `spec/` — automated tests mirroring `src/` structure.
- `docs/` — design notes, usage guides, and contributor-facing documentation.
- `bin/` — executable scripts or local developer commands.
- `config/` — non-secret configuration templates and defaults.

Prefer cohesive modules with clear boundaries. Avoid placing production code at the repository root unless it is a conventional entrypoint.

## Build, Test, and Development Commands

No build or test tooling is configured yet. When tooling is added, document the exact commands here. Recommended pattern:

- `bin/setup` — install dependencies and prepare local configuration.
- `bin/test` — run the full test suite.
- `bin/lint` — run formatters and static analysis.
- `bin/dev` — start the local development process.

Keep commands deterministic and safe for contributors to run locally. Do not require secrets for standard tests.

## Coding Style & Naming Conventions

Follow the formatter and linter native to the chosen language or framework. Until one is configured:

- Use clear, descriptive names over abbreviations.
- Keep files focused on one responsibility.
- Prefer small modules and explicit public APIs.
- Match test file names to the unit under test, for example `src/parser.rb` and `test/parser_test.rb`.

Add project-specific formatting rules once the stack is selected.

## Testing Guidelines

Add tests with every behavior change. Tests should be fast, isolated, and readable. Mirror the source structure in the test directory and name tests after observable behavior, not implementation details.

If coverage tooling is introduced, document the minimum threshold and the command used to generate reports.

## Commit & Pull Request Guidelines

Git history is not available in this checkout, so use Conventional Commits by default:

- `feat: add parser entrypoint`
- `fix: handle empty input`
- `docs: document setup workflow`

Pull requests should include a concise description, linked issue when applicable, test evidence, and screenshots or logs for user-visible changes. Keep PRs focused and avoid mixing unrelated refactors with feature work.

## Security & Configuration Tips

Never commit secrets, local credentials, or generated private keys. Store example values in `.env.example` or documented config templates, and keep real values in local environment variables or a secret manager.
