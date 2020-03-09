---
title: Serialisation and deserialisation
previous:
  url: atom_exhaustion
  title: Preventing atom exhaustion
next:
  url: external_executables
  title: Spawning external executables
---

## General

* When choosing a serialisation format for use in an untrusted environment, use a standard format (e.g. JSON, XML, Protobuf) instead of External Term Format (ETF)
  * Use a parser that does not generate atoms (see also [Preventing atom exhaustion](atom_exhaustion))

## Erlang

* Use the `safe` option when calling [binary_to_term/2](https://erlang.org/doc/man/erlang.html#binary_to_term-2) on untrusted input (see also [Preventing atom exhaustion](atom_exhaustion))
* Do not use [file:consult/1](https://erlang.org/doc/man/file.html#consult-1) or [file:path_consult/2](https://erlang.org/doc/man/file.html#path_consult-2) on untrusted input
* Do not invoke functions deserialised from untrusted input

## Elixir

* Use the `:safe` option when calling [:erlang.binary_to_term/2](https://erlang.org/doc/man/erlang.html#binary_to_term-2) on untrusted input (see also [Preventing atom exhaustion](atom_exhaustion))
* Prevent function deserialisation from untrusted input, e.g. using [Plug.Crypto.non_executable_binary_to_term/1,2](https://hexdocs.pm/plug_crypto/Plug.Crypto.html#non_executable_binary_to_term/2)

## Background

Deserialisation of untrusted input can result in atom creation, which in turn can make the application vulnerable to denial-of-service attacks, as explained in [Preventing atom exhaustion](atom_exhaustion). When using a deserialisation library, e.g. for parsing JSON or XML, ensure the library does not create arbitrary atoms: either configure the library to return strings/binaries, or enable schema validation to constrain the input (see also [Erlang standard library: xmerl](xmerl)).

When deserializing [External Term Format](http://erlang.org/doc/apps/erts/erl_ext_dist.html) (ETF), note that the input may contain unsafe terms that should not be deserialised from an untrusted source. In particular, functions should not be deserialised and invoked, as this can lead to Remote Code Execution (RCE) vulnerabilities. (The safe option does not affect the deserialisation of functions and other unsafe terms). The same is true when reading Erlang terms from a text file using [file:consult/1](https://erlang.org/doc/man/file.html#consult-1).

## Implicit function invocation in Elixir

This is especially important in Elixir, where invocation of an anonymous function can happen implicitly and therefore unexpectedly, because the [Enumerable protocol](https://hexdocs.pm/elixir/Enumerable.html) is implemented for functions with an arity of 2.

Consider the following Elixir code, from a hypothetical web application that stores UI theme customizations in a cookie, using External Term Format:

```elixir
themes =
  case conn.cookies["themes"] do
    nil -> []
    themes_b64 ->
      themes_b64
      |> Base.decode64!()
      |> :erlang.binary_to_term([:safe])
  end

css = Enum.map(themes, &theme_to_css/1)
```

A malicious user might manipulate the cookie:

```elixir
# Attacker generates:
pwn = fn _, _ -> IO.puts("Boom!"); {:cont, []} end
cookie =
  pwn
  |> :erlang.term_to_binary()
  |> Base.encode64()

# Server executes:
Enum.map(pwn, &theme_to_css/1)
```

The attacker's anonymous function would be executed on the server, making this an RCE vulnerability. A similar issue was originally published as [CVE-2017-1000053](https://www.cvedetails.com/cve/CVE-2017-1000053/), along with an [accompanying write-up](https://www.griffinbyatt.com/post/analysis-plug-security-vulns).

The [Plug.Crypto.non_executable_binary_to_term/1,2](https://hexdocs.pm/plug_crypto/Plug.Crypto.html#non_executable_binary_to_term/2) function in the [plug_crypto](https://hex.pm/packages/plug_crypto) package implements a variant of the `:erlang.binary_to_term/1,2` function that raises an exception when it encounters an unsafe term. Remember to also pass `:safe` to prevent atom creation.

Another data type that implements the Enumerable protocol is [Range](https://hexdocs.pm/elixir/Range.html): a malicious user of the above application could set the cookie to the serialised Range struct for a value such as `1..9999999999999999`, which would likely result in the server process using up large amounts of CPU time and memory.

`Plug.Crypto.non_executable_binary_to_term/1,2` does not protect against this scenario: it requires further input validation of the deserialised value.
