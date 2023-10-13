---
title: Secure Coding and Deployment Hardening Guidelines
layout: page
next:
  url: introduction
  title: Introduction
---

Best-practices for writing and running applications on the BEAM, by the Erlang Ecosystem Foundation’s Security Working Group.

To report mistakes or suggest additional content, please open an issue or create a pull request in the [GitHub repository]({{site.github.repository_url}}).

## Contents

* [Introduction](introduction)
* [Secure Coding Recommendations](secure_coding)
  * [Preventing atom exhaustion](atom_exhaustion)
  * [Serialisation and deserialisation](serialisation)
  * [Spawning external executables](external_executables)
  * [Protecting sensitive data](sensitive_data)
  * [Sandboxing untrusted code](sandboxing)
  * [Preventing timing attacks](timing_attacks)
  * [Erlang standard library: ssl](ssl)
  * [Erlang standard library: inets](inets)
  * [Erlang standard library: crypto](crypto)
  * [Erlang standard library: public_key](public_key)
  * [Erlang standard library: xmerl](xmerl)
* [Deployment Hardening](deployment_hardening)
  * [Installing/building the runtime system](installing)
  * [Releases](releases)
  * [Distribution](distribution)
  * [Crash dumps and core dumps](crash_dumps)
* [Resources](resources)
