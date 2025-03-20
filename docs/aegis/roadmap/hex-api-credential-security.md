---
title: Hex API Credential Security
area: Supply Chain
status: Planning
funding_required: true
index: 10
previous:
  url: hex-account-security
  title: Hex Account Security
next:
  url: hex-build-provenance
  title: Hex Build Provenance
---

## Goals

Provide Mechanisms to Secure API Credentials

## Impact

By implementing trusted publishing for GitHub and GitLab, as well as introducing
clearly prefixed API tokens that can be recognized by popular secret scanning
tools, this milestone fortifies the integrity of package publication workflows
on [Hex.pm](http://hex.pm/). These enhancements ensure that credentials remain
secure, are readily detectable if accidentally exposed, and adhere to best
practices outlined in the Principles for Package Repository Security.
Ultimately, this tighter control and streamlined oversight of authorization
mechanisms significantly reduces the risk of compromised accounts and
unauthorized access, bolstering the trustworthiness of [Hex.pm](http://hex.pm/)’s
ecosystem.

## Deliverables

* Implement Trusted Publishing for at least GitHub and GitLab
* API Tokens are prefixed and the prefix is registered with common secret scanners such as GitHub

## Relevant Standards

* [Principles for Package Repository Security](https://repos.openssf.org/principles-for-package-repository-security.html)
  - Authorization / Level 1, 3