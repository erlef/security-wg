---
title: Source SBoM
area: Supply Chain
status: In Progress
funding_required: false
sponsors:
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

* Integrations into ORT (mix, rebar3, Gleam)
* Integrations into ScanCode (mix, rebar3, Gleam)
* Build Tools (or plugins for build tools) can generate SBoMs
  - Type: Source, Build, Runtime, & Cryptography
  - Formats: SPDX, CycloneDX
* Core Infrastructure Source SBoM
  - Languages (Erlang / Gleam / Elixir)
  - Separate Build Tools (rebar3)
  - Package Manager (Hex)
  - offer Source SBoM

## Relevant Standards

* [SPDX 3.0.1](https://spdx.github.io/spdx-spec/v3.0.1/)
* [CycloneDX 1.6](https://ecma-international.org/publications-and-standards/standards/ecma-424/)
