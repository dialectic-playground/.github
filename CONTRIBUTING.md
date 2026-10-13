# Contributing to Dialectic Playground

Thank you for contributing! This guide applies to every repository in the organization.
A repository can add its own `CONTRIBUTING.md` with project-specific rules (for example
[`docs`](https://github.com/dialectic-playground/docs/blob/main/CONTRIBUTING.md) and
[`sdlc-curriculum`](https://github.com/dialectic-playground/sdlc-curriculum/blob/main/CONTRIBUTING.md));
those rules add to this guide.

By participating you agree to the [Code of Conduct](CODE_OF_CONDUCT.md).

## Workflow

1. **Discuss first** for anything non-trivial: open an issue (bugs, changes) or a
   [discussion](https://github.com/orgs/dialectic-playground/discussions) (ideas, questions).
2. **Branch** from `main` (maintainers) or fork the repository (everyone else).
3. **Commit with sign-off** (see [DCO](#developer-certificate-of-origin-dco) below).
4. **Open a pull request** against `main` using the pull request template.
5. **Pass CI.** Every repository has a required check named **CI result**. `main` is protected:
   changes reach it only through pull requests with passing checks.
6. **Squash merge.** Each pull request becomes one commit on `main`, titled with the pull
   request title.

## Pull request titles: Conventional Commits

Because pull requests are squash-merged, the **pull request title becomes the commit message
on `main`**. Write it as a [Conventional Commit](https://www.conventionalcommits.org/):

```text
<type>(<optional scope>): <imperative summary>
```

| Type | Use for |
| :-- | :-- |
| `feat` | New functionality or content |
| `fix` | A bug fix or correction |
| `docs` | Documentation only |
| `ci` | CI workflows and automation |
| `build` | Build system or dependencies |
| `refactor` | Restructuring without behavior change |
| `test` | Tests or fixtures only |
| `chore` | Maintenance that fits nothing above |

Examples: `docs(how-to): add guide for running the black-box tests`,
`fix(02-cat): correct -v notation for 0x7F in the SRS`.

## Developer Certificate of Origin (DCO)

Every commit must carry a `Signed-off-by:` line matching its author, certifying the
[Developer Certificate of Origin](https://developercertificate.org/): that you wrote the
contribution or otherwise have the right to submit it under the repository's license.

```sh
git commit -s -m "docs: fix a typo"          # adds: Signed-off-by: Your Name <you@example.com>
git commit --amend -s --no-edit              # sign off the last commit
git rebase --signoff main                    # sign off every commit on your branch
```

The **DCO** check fails a pull request if any commit is missing a matching sign-off.
Commits made in the GitHub web editor are signed off automatically.

## Repository conventions

Every repository uses the same baseline so that work feels the same everywhere:

- `.editorconfig`, `.gitattributes` (LF line endings), and a focused `.gitignore`
- `.github/workflows/ci.yml` (workflow **CI**) with actions pinned to full commit SHAs, and
  `.github/dependabot.yml`
- `.github/CODEOWNERS` assigning `@dialectic-playground/maintainers`
- MIT license

New repositories are created from the organization's template repository.
