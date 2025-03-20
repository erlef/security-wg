---
layout: page
title: Resources
layout: page
previous:
  url: crash_dumps
  title: Crash dumps and core dumps
---

## Tools

Static analysis:

* [Dialyzer](https://erlang.org/doc/apps/dialyzer/index.html) - DIscrepancy AnaLYZer for ERlang programs, using the concept of success typings
* [Sobelow](https://github.com/nccgroup/sobelow) - Security-focused static analysis for the Phoenix Framework
* [Credo](https://github.com/rrrene/credo) - A static code analysis tool for the Elixir language with a focus on code consistency and teaching

## Documentation

### Anti-patterns in Elixir

The Elixir documentation includes a section on [anti-patterns](https://hexdocs.pm/elixir/what-anti-patterns.html): common mistakes or indicators of potential problems in code. The unintended behaviours caused by such mistakes or problems may lead to vulnerabilities. Getting familiar with these anti-patterns and learning to avoid them can help produce cleaner code, fewer bugs, fewer surpises and therefore fewer vulnerabilities.

For instance, the [Non-assertive truthiness](https://hexdocs.pm/elixir/code-anti-patterns.html#non-assertive-truthiness) anti-pattern can lead to logic errors in authentication or authorization checks.

### Other documentation

Web development, e.g. with Cowboy, Plug and/or Phoenix:

* [OWASP](https://www.owasp.org/):
  * [Secure Coding Practices](https://www.owasp.org/index.php/OWASP_Secure_Coding_Practices_-_Quick_Reference_Guide)
  * [Cheat Sheet Series](https://cheatsheetseries.owasp.org)
  * And more...
* Plug [HTTPS guide](https://hexdocs.pm/plug/https.html) and the ["Using SSL" section](https://hexdocs.pm/phoenix/using_ssl.html#content) in Phoenix Endpoint Guide

Deployment:

* [CIS Benchmarks](https://www.cisecurity.org/cis-benchmarks/):
  * Operating systems
  * Databases
  * Reverse proxies
  * Container platforms
  * Cloud environments
  * And more...
