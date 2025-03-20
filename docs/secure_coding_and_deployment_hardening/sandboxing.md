---
layout: page
title: Sandboxing untrusted code
previous:
  url: sensitive_data
  title: Protecting sensitive data
next:
  url: timing_attacks
  title: Preventing timing attacks
---

## General

* Use an embedded language runtime, such as Lua

## Erlang

* Do not use `file:script/1,2` and `file:eval/1,2` on untrusted input, or in production code at all

## Elixir
* Do not use `Code.eval_file/1,2`, `Code.eval_string/1,2,3` and `Code.eval_quoted/1,2,3` on untrusted input, or in production code at all

## Background

The BEAM runtime has very little support for access control between running processes: code that runs somewhere in a BEAM instance has almost unlimited access to the VM and the interface to the host on which it runs. Moreover, a process on a node in a distributed Erlang cluster has the same level of access to the other nodes as well.

It is therefore not possible to isolate ‘untrusted’ processes in some sort of sandbox. If there is a need to allow untrusted parties, such as users of the application, to customize an application’s behaviour, use a dedicated runtime as a sandbox for untrusted code. The [Lua language](https://www.lua.org) in particular was designed with this use-case in mind, and various Erlang/Elixir bindings exist.
