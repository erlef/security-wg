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

Runtime SBoM introspection, Cryptography SBoM, and Build SBoM for release
artifacts and Docker images.

## Impact

By enabling runtime SBoM introspection in the Erlang VM and providing
Cryptography and Build SBoMs for core infrastructure releases, this milestone
completes the SBoM coverage across the entire software lifecycle. Runtime
introspection allows developers to query dependency information from running
systems, while Cryptography SBoMs document cryptographic algorithm usage for
compliance requirements. Build SBoMs for Docker images and release artifacts
ensure a complete, auditable record of all software components in production
deployments, fostering stronger security, compliance, and trust within the
Erlang and Elixir communities.

## Deliverables

* Erlang Runtime Introspection - *Details TBD*
* Core Infrastructure SBoM
  - Languages (Erlang / Gleam / Elixir)
  - Separate Build Tools (rebar3)
  - Package Manager (Hex)
  - offer Cryptography SBoM
  - offer Build SBoM for Builds
    * [Hex.pm](http://Hex.pm) Bob Docker Images
    * Official [docker.io](http://docker.io) Erlang / Elixir Images
    * Any release artifacts of the projects

## Relevant Standards

* [SPDX 3.0.1](https://spdx.github.io/spdx-spec/v3.0.1/)
* [CycloneDX 1.6](https://ecma-international.org/publications-and-standards/standards/ecma-424/)