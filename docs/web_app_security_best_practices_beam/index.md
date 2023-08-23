---
title: Web Application Security Best Practices for BEAM languages
layout: page
next:
  url: common_web_application_vulnerabilities
  title: Common Web Application Vulnerabilities
seo_keywords:
  - beam
  - phoenix
  - plug
  - web application security
  - best practices
---

This document describes best practices for secure development of Phoenix web
applications in the Elixir programming language, written by the Erlang Ecosystem
Foundation’s Security Working Group.

The working group also publishes
[Secure Coding and Deployment Hardening Guidelines](https://erlef.github.io/security-wg/secure_coding_and_deployment_hardening/),
for Elixir and Erlang applications. This document focuses on Phoenix, while the
previous document is on Elixir and Erlang security.

To report mistakes or suggest additional content, please open an issue or create
a pull request in the [GitHub repository]({{site.github.repository_url}}).

## Contents

- [Common Web Application Vulnerabilities](common_web_application_vulnerabilities)
  - [Cross Site Scripting (XSS)](common_web_application_vulnerabilities#cross-site-scripting-xss)
  - [Cross Site Request Forgery (CSRF)](common_web_application_vulnerabilities#cross-site-request-forgery-csrf)
  - [Cross-Site WebSocket Hijacking (CSWSH)](common_web_application_vulnerabilities#cross-site-websocket-hijacking-cswsh)
  - [SQL Injection](common_web_application_vulnerabilities#sql-injection)
  - [Denial of Service (DoS)](common_web_application_vulnerabilities#denial-of-service-dos)
  - [Client-side enforcement of server-side security](common_web_application_vulnerabilities#client-side-enforcement-of-server-side-security)
- [Session Management Vulnerabilities](session_management_vulnerabilities)
  - [No server-side session revocation](session_management_vulnerabilities#no-server-side-session-revocation)
  - [No server-side session timeout](session_management_vulnerabilities#no-server-side-session-timeout)
  - [Session leakage (session hijacking)](session_management_vulnerabilities#session-leakage-session-hijacking)
  - [Session fixation](session_management_vulnerabilities#session-fixation)
  - [Session information leakage](session_management_vulnerabilities#session-information-leakage)
  - [Session lifecycle and WebSocket connections](session_management_vulnerabilities#session-lifecycle-and-websocket-connections)
- [TLS Vulnerabilities](tls_vulnerabilities)
  - [Insufficient peer certificate verification](tls_vulnerabilities#insufficient-peer-certificate-verification)
  - [Weak TLS versions, ciphers and other options](tls_vulnerabilities#weak-tls-versions-ciphers-and-other-options)
  - [Misconfigured TLS offload](tls_vulnerabilities#misconfigured-tls-offload)
  - [Downgrade attacks](tls_vulnerabilities#downgrade-attacks)
- [Information Leakage](information_leakage)
  - [Elixir and Erlang standard library](information_leakage#elixir-and-erlang-standard-library)
  - [Parameter filter in Phoenix logger](information_leakage#parameter-filter-in-phoenix-logger)
  - [Phoenix socket messages](information_leakage#phoenix-socket-messages)
  - [Redacting fields in Ecto schemas](information_leakage#redacting-fields-in-ecto-schemas)
- [Supply Chain Vulnerabilities](supply_chain_vulnerabilities)
  - [Outdated dependencies](supply_chain_vulnerabilities#outdated-dependencies)
  - [Retired dependencies](supply_chain_vulnerabilities#retired-dependencies)
  - [Dependencies with known vulnerabilities](supply_chain_vulnerabilities#dependencies-with-known-vulnerabilities)
  - [Insufficient due-diligence when adding 3rd party components](supply_chain_vulnerabilities#insufficient-due-diligence-when-adding-3rd-party-components)
  - [Insufficient visibility into 3rd party components](supply_chain_vulnerabilities#insufficient-visibility-into-3rd-party-components)
