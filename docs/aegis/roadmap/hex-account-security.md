---
title: Hex Account Security
area: Supply Chain
status: Planning
funding_required: true
index: 9
previous:
  url: hex-vulnerability-handling
  title: Hex Vulnerability Handling
next:
  url: hex-api-credential-security
  title: Hex API Credential Security
---

## Goals

Provide MFA and WebAuthn authentication to Hex.pm, strengthen and document
Account Security

## Impact

By strengthening account security through the introduction of WebAuthn,
mandatory MFA for package authors, and robust mechanisms like brute force
prevention and account recovery policies, this milestone greatly reduces the
risk of unauthorized account access on Hex.pm. Ensuring that package authors
adopt phishing-resistant MFA methods and regularly validating email addresses
for abandoned or compromised domains further safeguards the ecosystem. These
measures not only protect individual contributors but also uphold the collective
trust and integrity of package distribution channels, paving the way for a more
resilient and secure environment for all Hex.pm users.

## Deliverables

* Implement WebAuthn Login (additional as 2FA and separate as primary Login)
* Require 2FA for all package authors (implement conversion period)
* Require phishing-resistant MFA for package authors
* Document Account Recovery Policy
* Notification Email for Account Security Changes
* Implement Brute Force Prevention
* Scan Email Addresses for abandoned email domains and lock abandoned accounts

## Relevant Standards

* [Principles for Package Repository Security](https://repos.openssf.org/principles-for-package-repository-security.html)
  - Security Capabilities of Package Repositories / Level 1, 2, 3
  - Authentication / Level 1, 2, 3