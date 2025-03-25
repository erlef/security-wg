---
layout: page
title: Secure Coding Recommendations
previous:
  url: introduction
  title: Introduction
next:
  url: atom_exhaustion
  title: Preventing atom exhaustion
---

This section lists a number of recommendations for programmers on the BEAM platform. Adhering to these recommendations does not eliminate the need for implementing other activities that make up a Secure Software Development Life Cycle (SSDLC), such as threat modelling, static analysis, dynamic security scanning, penetration testing and tracking third party components and their vulnerabilities. As part of a more comprehensive program secure coding practices can help prevent potential issues at an early stage in the process.

Code examples are given in Erlang and Elixir, but most recommendations apply equally to other BEAM languages.

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
