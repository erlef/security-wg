---
title: Hex Build Provenance
area: Supply Chain
status: Planning
funding_required: true
sponsors:
  - HCA Healthcare
index: 11
previous:
  url: hex-api-credential-security
  title: Hex API Credential Security
next:
  url: hex-asset-side-loading
  title: Hex Asset Side-Loading
---

## Goals

Implement SLSA Build Provenance

## Impact

By integrating SLSA Build Provenance into Hex’s publishing and installation
workflows, this milestone provides a transparent, verifiable chain of custody
for packages, strengthening trust between developers and end-users. Implementing
sigstore and SLSA libraries, generating attestations on critical events, and
enabling Build Tools (mix, rebar3, Gleam) to produce and verify provenance all
contribute to a more secure and auditable software supply chain. By offering
Level 3 publishing capabilities and maintaining a transparency log accessible
via the Hex.pm API, users gain robust assurance that packages are built and
signed under trustworthy conditions, ultimately reducing the risk of tampering
and enabling higher security standards across the Erlang and Elixir ecosystems.

## Deliverables

* Implement sigstore standalone library written in erlang that passes the [conformance tests](https://github.com/sigstore/sigstore-conformance)
* Implement slsa standalone verification library
* Build Tool Hex Publish can optionally generate SLSA Provenance (mix, rebar3, gleam)
* Provide SLSA L3 Publisher for GitHub and [if ready, GitLab](https://gitlab.com/groups/gitlab-org/-/epics/14378)
* [Hex.pm](http://Hex.pm) Registry will create attestation on events linking build provenance if possible
  - Events: publish, unpublish, retire, Vulnerability publish, VEX publish, maintainer / owner changes
  - See [NPM](https://github.com/npm/attestation/tree/main/specs/publish/v0.1)
* Build Tool Hex Installation can verify Publish Attestation & SLSA Provenance
* All Attestations can be queried via the API as a Transparency Log

## Relevant Standards

* [Principles for Package Repository Security](https://repos.openssf.org/principles-for-package-repository-security.html)
  - Security Capabilities of Package Repositories / Level 3
  - Authorization / Level 3
  - General Capabilities / Level 3
