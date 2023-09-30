---
title: Boolean coercion in Elixir
previous:
  url: xmerl
  title: "Erlang standard library: xmerl"
next:
  url: deployment_hardening
  title: Deployment Hardening
---

## Elixir

When interfacing with Erlang code from Elixir:

* Prefer [case](https://elixir-lang.org/getting-started/case-cond-and-if.html#case) over [if, unless](https://elixir-lang.org/getting-started/case-cond-and-if.html#if-and-unless) or [cond](https://elixir-lang.org/getting-started/case-cond-and-if.html#cond)
* Prefer [and](https://hexdocs.pm/elixir/Kernel.html#and/2) over [&&](https://hexdocs.pm/elixir/Kernel.html#&&/2)
* Prefer [or](https://hexdocs.pm/elixir/Kernel.html#or/2) over [\|\|](https://hexdocs.pm/elixir/Kernel.html#%7C%7C/2)
* Prefer [not](https://hexdocs.pm/elixir/Kernel.html#not/1) over [!](https://hexdocs.pm/elixir/Kernel.html#!/1)

## Background

Elixir, unlike Erlang, has a notion of a ‘truthy’ value, where anything other than false or nil is considered true. Erlang does not have a formal notion of nil at all, but the atom :undefined is sometimes used for similar purposes, including in the Erlang standard library. Elixir would consider this a 'truthy' value.

This can lead to subtle and unexpected bugs, especially when interworking with Erlang libraries. Imagine a library that performs cryptographic signature validation, with a return type of `:ok | {:error, atom()}`. If this function were mistakenly called in a context where a 'truthy' value is expected, the return value would always be considered true.

By using expressions that do not use boolean coercion, the incorrect assumption about the function’s return type is caught early:

Instead of:
```elixir
:signature.verify(signature, message, private_key) || raise(BadSignatureException)
```

Consider writing:
```elixir
:signature.verify(signature, message, private_key) or raise(BadSignatureException)
```

The latter will raise a 'BadBooleanError' when the function returns `:ok` or `{:error, _}`, which would be reported by Dialyzer, or at the latest be found by automatic or manual testing before the code is shipped. In the interest of clarity if may even be better to use a `case` construct, matching explicitly on `true` and `false`.

Of course the error should also be caught by a unit test that verifies the correct behaviour of both the positive and negative code path!
