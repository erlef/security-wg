---
title: SBoM
area: Supply Chain
status: Planning
funding_required: true
index: 13
previous:
  url: hex-asset-side-loading
  title: Hex Asset Side-Loading
---

## Goals

SBoM Support in the default toolchain and integration into common industry
Tooling

## Impact

By integrating Software Bill of Materials (SBoM) support into the default Erlang
ecosystem toolchain and aligning with industry standards (SPDX 3.0.1,
CycloneDX 1.6), this milestone significantly increases visibility and
traceability of dependencies across source, build, runtime, and cryptographic
layers. By offering plugins for common build tools (mix, rebar3, Gleam),
integrating with scanning solutions (ORT, ScanCode), and storing SBoM data at
both compile and runtime, developers gain immediate introspection and
verification capabilities—even for foreign dependencies like NIFs or JS bundles.
Extending these practices to the core infrastructure (Hex package manager,
official Docker images, and key language projects) ensures a complete, auditable
record of all software components, fostering stronger security, compliance, and
trust within the Erlang and Elixir communities.

## Deliverables

* Integrations into ORT (mix, rebar3, Gleam)
* Integrations into ScanCode (mix, rebar3, Gleam)
* Build Tools (or plugins for build tools) can generate SBoMs
  - Type: Source, Build, Runtime, & Cryptography
  - Formats: SPDX, CycloneDX
* Erlang Runtime Introspection -*Details TBD*
* Core Infrastructure SBoM
  - Languages (Erlang / Gleam / Elixir)
  - Separate Build Tools (rebar3)
  - Package Manager (Hex)
  - offer Source SBoM
  - offer Cryptography SBoM
  - offer Build SBoM for Builds
    * [Hex.pm](http://Hex.pm) Bob Docker Images
    * Official [docker.io](http://docker.io) Erlang / Elixir Images
    * Any release artifacts of the projects

## Relevant Standards

* [SPDX 3.0.1](https://spdx.github.io/spdx-spec/v3.0.1/)
* [CycloneDX 1.6](https://ecma-international.org/publications-and-standards/standards/ecma-424/)