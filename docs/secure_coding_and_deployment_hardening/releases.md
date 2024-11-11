---
title: Releases
previous:
  url: installing
  title: Installing/building the runtime system
next:
  url: distribution
  title: Distribution Protocol and EPMD
---

* Package a project as a ‘release’ for deployment
* Include only the OTP applications necessary for production use

## Background

Packaging and deploying a project as a release is a good way to reduce the attack surface. A release only includes those parts of the Erlang/OTP runtime system that are actually needed to run the application, eliminating unnecessary code.

Whether introspection and development tools, such as [observer](https://erlang.org/doc/man/Observer_app.html), [runtime_tools](https://erlang.org/doc/man/runtime_tools_app.html) and even [compiler](https://erlang.org/doc/apps/compiler/index.html), should be included or excluded is a policy decision: traditionally, removing developer tools such as compilers from a production environment is considered good practice, but on the other hand, the ability to monitor, debug and even patch the application in-place may be one of the reasons for choosing the BEAM platform in the first place.

It is worth noting that Elixir applications always ship with the full Elixir standard library, including the compiler.

At runtime, another advantage of a release over other deployment methods is the use of [embedded mode](https://erlang.org/doc/system_principles/system_principles.html#code-loading-strategy) for the code server (the `code` module). In this mode, modules are loaded once at release startup by the boot script, and automatic loading of code on-demand is disabled. This eliminates some paths for code injection by an attacker with limited control over the host machine/VM.
