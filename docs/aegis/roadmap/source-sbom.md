---
title: Source SBoM
area: Supply Chain
status: In Progress
funding_required: true
supporters:
  - To Be Announced
index: 3
progress: 75
previous:
  url: cna
  title: Erlang Ecosystem Foundation CNA
next:
  url: supply-chain-security-audit
  title: Supply Chain Security Audit
---

## Goals

Source SBoM Support in the default toolchain and integration into common
industry Tooling

## Impact

By integrating Source Software Bill of Materials (SBoM) support into the default
Erlang ecosystem toolchain and aligning with industry standards (SPDX 3.0.1,
CycloneDX 1.6), this milestone significantly increases visibility and
traceability of source dependencies. By offering plugins for common build tools
(mix, rebar3, Gleam) and integrating with scanning solutions (ORT, ScanCode),
developers gain the ability to generate and verify source SBoMs for their
projects. Extending these practices to the core infrastructure (Erlang, Elixir,
Gleam, rebar3, and Hex) ensures an auditable record of source dependencies,
fostering stronger security, compliance, and trust within the Erlang and Elixir
communities.

## Deliverables

* [X] Integrations into ORT (mix, rebar3, Gleam)
* [X] Integrations into ScanCode (mix, rebar3, Gleam)
* [ ] Build Tools (or plugins for build tools) can generate SBoMs
  - [X] Type: Source
  - [ ] Format: SPDX
  - [X] Format: CycloneDX
* Core Infrastructure Source SBoM
  - [X] Language: Erlang
  - [ ] Language: Gleam
  - [X] Language: Elixir
  - [ ] Build Tools: rebar3
  - [ ] Package Manager: Hex

## Relevant Standards

* [SPDX 3.0.1](https://spdx.github.io/spdx-spec/v3.0.1/)
* [CycloneDX 1.6](https://ecma-international.org/publications-and-standards/standards/ecma-424/)

## Results

* [mix_sbom](https://github.com/erlef/mix_sbom)
* [rebar3_sbom](https://github.com/erlef/rebar3_sbom)
* [ORT Mix Plugin](https://oss-review-toolkit.org/ort/docs/plugins/package-managers/Mix)
* [ORT Rebar3 Plugin](https://oss-review-toolkit.org/ort/docs/plugins/package-managers/Rebar3)
* [ORT Gleam Plugin](https://oss-review-toolkit.org/ort/docs/plugins/package-managers/Gleam)
* [Gleam Source Bill of Materials](https://gleam.run/documentation/source-bill-of-materials/)
* [rebar3 SBoM Plugin](https://www.rebar3.org/docs/configuration/plugins/#software-bill-of-materials-sbom)
* [Elixir SBoM Documentation](https://hexdocs.pm/elixir/main/sbom.html)
