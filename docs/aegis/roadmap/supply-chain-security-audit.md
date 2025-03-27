---
title: Supply Chain Security Audit
area: Supply Chain
status: Planning
funding_required: true
index: 7
previous:
  url: cna
  title: Erlang Ecosystem Foundation CNA
next:
  url: hex-vulnerability-handling
  title: Hex Vulnerability Handling
---

## Goals

Audit hex package manager, registry and integration into build tools such as
rebar3, mix and gleam. (PenTest, Verification of Design, Code Audit)

## Impact

By performing a comprehensive supply chain security audit of the Hex package
manager, registry, and related build tools (rebar3, mix, and Gleam), this
milestone will pinpoint structural vulnerabilities, validate the correctness
of the underlying design, and ensure the robustness of code implementations.
The in-depth review—spanning critical repositories like `hexpm/hexpm`,
`hexpm/specifications`, `hexpm/hex_core` , and others — will generate a clear,
actionable roadmap for remediation, reinforcing the security of not only the
individual components but the broader Erlang and Elixir ecosystems. With
findings addressed and the security posture hardened, future enhancements
(such as Build Provenance, SBoMs, and streamlined Vulnerability Handling) can
proceed from a stable, trustworthy foundation.

## Deliverables

* Conducted Audit Reports on
  - [`hexpm/hexpm`](https://github.com/hexpm/hexpm) - Package Registry
  - [`hexpm/specifications`](https://github.com/hexpm/specifications) - Hex Specification
  - [`hexpm/hex_core`](https://github.com/hexpm/hex_core) - Hex Client Implementation
  - [`hexpm/hex`](https://github.com/hexpm/hex) - Hex Elixir (mix) Integration
  - [`erlang/otp`](https://github.com/erlang/otp) - Erlang VM / Language
  - [`erlang/rebar3`](https://github.com/erlang/rebar3) - rebar3 Build Tool
  - [`elixir-lang/elixir`](https://github.com/elixir-lang/elixir) - Mix Build Tool
  - [`gleam-lang/gleam`](https://github.com/gleam-lang/gleam) - Gleam Build Tool
* Remediation of findings
