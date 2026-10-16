<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->

**Table of Contents** _generated with [DocToc](https://github.com/thlorenz/doctoc)_

- [Security policy](#security-policy)
  - [Supported versions](#supported-versions)
  - [Reporting a vulnerability](#reporting-a-vulnerability)
  - [Scope](#scope)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->

# Security policy

This policy applies to every repository in the
[dialectic-playground](https://github.com/dialectic-playground) organization unless a
repository provides its own `SECURITY.md`.

## Supported versions

| Repository type                                         | Supported                            |
| :------------------------------------------------------ | :----------------------------------- |
| Specification repositories (e.g. `sdlc-curriculum`)     | The latest tagged release and `main` |
| Implementation, documentation, and tooling repositories | `main` only                          |

## Reporting a vulnerability

**Do not open a public issue, discussion, or pull request for a security problem.**

Report it privately through GitHub's private vulnerability reporting:

1. Go to the affected repository's **Security** tab.
2. Choose **Report a vulnerability**.
3. Describe the problem, its impact, and the steps to reproduce it.

Only the maintainers can see the report. You can expect an acknowledgement within
**7 days**. We will keep you informed while we investigate, agree a disclosure timeline with
you, and credit you in the published advisory unless you prefer otherwise.

## Scope

Examples of in-scope problems: a flaw in a curriculum tool's specification that would make
conforming implementations unsafe, a vulnerability in a language implementation, injection
in a CI workflow, or a leaked credential. Problems in third-party dependencies should also be
reported upstream.
