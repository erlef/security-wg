---
title: Supply Chain Vulnerabilities
layout: page_with_toc
previous:
  url: information_leakage
  title: Information Leakage
seo_keywords:
  - supply chain vulnerability
  - dependency vulnerability
  - dependency vetting
  - hex
---

## Outdated dependencies

Critical security fixes are often only made available in the latest and greatest
version of 3rd party packages, When an application’s dependencies are falling
behind the currently available releases, this may impact the ability to quickly
apply fixes as they are released. When a dependency upgrade is non-trivial,
it is probably best to plan the upgrade while there is no pressure to get a security fix
deployed.

The Mix task `mix hex.outdated` displays a list of available package updates.
Remember to also check other sources of 3rd party dependencies for updates, such
as NPM or the OS package manager.

Having said that, upgrading dependencies should not be done without verifying
that the changes are legitimate and unlikely to introduce new security
vulnerabilities or even backdoors (see
[Insufficient due-diligence when adding 3rd party components](#insufficient-due-diligence-when-adding-3rd-party-components)).

## Retired dependencies

Package owners can mark a Hex package version as `retired`, to discourage the
use of those particular versions. Existing users should consider upgrading to a
newer version or, if the package itself is discontinued, switching to another
package.

A package version may be retired for a number of reasons, it does not
necessarily mean the version has a security vulnerability, and conversely, a
known vulnerability does not necessarily mean that the version will be retired.
Nevertheless, it is good practice to periodically check whether a project relies
on retired package versions using the `mix hex.audit` task, and to investigate
the reason and available mitigations.

## Dependencies with known vulnerabilities

While Hex provides built-in tooling for handling outdated or retired packages,
it does not provide information on known vulnerabilities in Hex packages. There
are a number of free and commercial tools to check whether a project has a known
vulnerable dependency.

The free Mix task [`mix deps.audit`][github:mix_audit] checks a project’s
dependencies against the known vulnerabilities in the
[Elixir Security Advisories repository][github:elixir-security-advisories].
Another approach would be to generate a Software Bill-of-Materials (SBoM) for
the project, and ingest the SBoM in a tool that can cross-reference the list
against vulnerability databases (see
[Insufficient visibility into 3rd party components](#insufficient-visibility-into-3rd-party-components)).

Some commercial offerings with Elixir support (in no particular order):

- [GitHub’s Dependabot][github:dependabot]
  - [Dependabot for GitLab][gitlab:dependabot]
- [Snyk][snyk_supply_chain_security]
- [Paraxial.io][paraxial]
- [Mend Renovate][mend_renovate]

## Insufficient due-diligence when adding 3rd party components

Introducing new 3rd party dependencies, or updating them, is always a liability:
code that was written by potentially untrusted or unknown parties becomes part
of a project. This 3rd party code not only affects the way the application
behaves at runtime, but may also execute code on the developer’s local machine
or build servers. Such code could potentially disable security features of the
application, introduce backdoors, steal information from the application or the
development environments, etc.

Whenever dependencies are introduced or updated, review the code being
introduced to make sure it is not malicious and does not negatively affect
security (or quality, performance, stability) of the application. Reviewing the
release notes is a good start, but it is not enough: a malicious package
maintainer is unlikely to document their backdoors there.

The `mix hex.diff` tool shows the exact changes in the Hex package archive, in a
friendly format. It may seem a daunting task to review large diffs, but
presumably it is much less work than implementing the functionality of the
updated package yourself. If it is not, ask yourself if you are not better off
dropping the dependency rather than upgrading it.

## Insufficient visibility into 3rd party components

Software supply chain management is about more than just security
vulnerabilities. Application developers should have full visibility into the 3rd
party components used in their projects for a number of reasons:

- Vulnerability tracking, by correlating information in the SBoM with known
  vulnerabilities
- Licence compliance, by verifying that no packages with
  inappropriate/incompatible licences are introduced, and producing the required
  copyright notices for the entire project
- Due diligence, e.g. sharing the SBoM or a human readable copy thereof with
  customers or other parties

Common open standard SBoM formats are CycloneDX and SPDX. Tools exist to produce
SBoMs in these formats for many languages, including [Elixir][hex:sbom] and
[Erlang][hex:rebar3_sbom].

Once produced, the SBoM can be ingested into a variety of tools, such as
[OWASP Dependency-Track][owasp_dependency_track]. Ideally, SBoM generation and
ingestion happens automatically as part of the project’s CI/CD pipeline.

[github:mix_audit]: https://github.com/mirego/mix_audit
[github:elixir-security-advisories]: https://github.com/mirego/elixir-security-advisories
[github:dependabot]: https://docs.github.com/en/code-security/dependabot/dependabot-alerts/about-dependabot-alerts
[gitlab:dependabot]: https://gitlab.com/dependabot-gitlab/dependabot
[snyk_supply_chain_security]: https://snyk.io/solutions/software-supply-chain-security/
[paraxial]: https://paraxial.io/
[mend_renovate]: https://www.mend.io/free-developer-tools/renovate/
[hex:sbom]: https://hex.pm/packages/sbom
[hex:rebar3_sbom]: https://hex.pm/packages/rebar3_sbom
[owasp_dependency_track]: https://dependencytrack.org
