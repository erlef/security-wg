---
title: Hex Asset Side-Loading
area: Supply Chain
status: Planning
funding_required: true
index: 12
previous:
  url: hex-build-provenance
  title: Hex Build Provenance
next:
  url: sbom
  title: SBoM
---

## Goals

Hex.pm offers a mechanism to store additional artifacts beside the main package

## Impact

By enabling [Hex.pm](http://hex.pm/) to store additional artifacts—such as
platform-dependent compiled NIFs or CLDR data—alongside the main package and
integrating this mechanism into build tools at compile time, the ecosystem
gains a powerful new way to distribute and consume supplemental resources.
This approach retains the same rigorous security features (build provenance,
publish attestations, etc.) already trusted for primary packages, ensuring
that side-loaded artifacts maintain an equally high standard of integrity.
Consequently, developers and end-users benefit from greater flexibility
without compromising the robust security posture that underpins the broader
Erlang and Elixir communities.

## Deliverables

* [Hex.pm](http://Hex.pm) offers a mechanism to store additional artifacts
  - eg. Platform Dependent compiled NIF, CLDR data etc.
* Build Managers offer a way to request the download of additional artifacts at compile time
* All security features (build provenance, publish attestation etc.) support those files