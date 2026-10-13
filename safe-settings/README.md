# safe-settings: repository settings as code

Every repository's settings are defined here and applied by
[safe-settings](https://github.com/github/safe-settings), run by the
[Safe Settings workflow](../.github/workflows/safe-settings.yml). **Change settings by editing
these files in a pull request, never in the GitHub UI.** The workflow runs on every merge that
touches this directory and daily, and it reverts any drift.

| File | Applies to | Contents |
| :-- | :-- | :-- |
| [`settings.yml`](settings.yml) | Every repository | Features (issues, wiki, projects), merge policy (squash only), auto-merge, branch deletion, Dependabot, the `maintainers` team |
| [`suborgs/all-repositories.yml`](suborgs/all-repositories.yml) | Every repository (`*`) | The **Protect default branch** ruleset: pull request required, `CI result` check required, linear history, no force pushes or deletion, **no bypass** |
| [`repos/<name>.yml`](repos/) | One repository | Canonical description (the GitHub *About* text), homepage, topics, and any exceptions |
| [`deployment-settings.yml`](deployment-settings.yml) | The sync itself | Which repositories are managed (all of them) |

## What is managed elsewhere

- **Security features** (dependency graph, Dependabot, CodeQL, secret scanning, push
  protection, private vulnerability reporting) come from the organization's enforced code
  security configuration, **dialectic-playground standard**, which is the default for new
  repositories.
- **Organization settings** (Actions allowlist, SHA pinning, member permissions, 2FA, web
  commit sign-off) are set
  in the organization settings, and the docs site lists them.

## Adding a repository

1. Create it from [`repo-template`](https://github.com/dialectic-playground/repo-template).
2. Add `repos/<name>.yml` with its canonical description, homepage, and topics.
3. Merge. The workflow applies the defaults, the ruleset, and the new file. You can also run
   **Safe Settings** manually with *dry run* unchecked to apply them immediately.

The complete checklist is
[Add a repository](https://dialectic-playground.github.io/docs/how-to/add-a-repository/).

## The GitHub App

The workflow authenticates as the organization's **safe-settings** GitHub App, which is
installed on all repositories. It needs the repository variable `SAFE_SETTINGS_APP_ID` and the
repository secret `SAFE_SETTINGS_PRIVATE_KEY` in this repository. The App's permissions follow
the safe-settings
[deployment guide](https://github.com/github/safe-settings/blob/main/docs/deploy.md#permissions--events).
To rotate the key, generate a new private key in the App settings, update the secret, then
delete the old key.
