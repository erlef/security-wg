---
title: Preventing atom exhaustion
previous:
  url: secure_coding
  title: Secure Coding Recommendations
next:
  url: serialisation
  title: Serialisation and deserialisation
---

## General

* Use lookup tables to convert strings or binaries to atoms when the desired atoms are known beforehand.

## Erlang

* Use [list_to_existing_atom/1](https://erlang.org/doc/man/erlang.html#list_to_existing_atom-1) instead of [list_to_atom/1](https://erlang.org/doc/man/erlang.html#list_to_atom-1)
* Use [binary_to_existing_atom/1,2](https://erlang.org/doc/man/erlang.html#binary_to_existing_atom-2) instead of [binary_to_atom/1,2](https://erlang.org/doc/man/erlang.html#binary_to_atom-2)
* Use the `safe` option when calling [binary_to_term/2](https://erlang.org/doc/man/erlang.html#binary_to_term-2) on untrusted input (see also [Serialisation and deserialisation](serialisation))
* Do not use [file:consult/1](https://erlang.org/doc/man/file.html#consult-1) or [file:path_consult/2](https://erlang.org/doc/man/file.html#path_consult-2) on untrusted input (see also [Serialisation and deserialisation](serialisation))

## Elixir

* Use [String.to_existing_atom/1](https://hexdocs.pm/elixir/String.html#to_existing_atom/1) instead of [String.to_atom/1](https://hexdocs.pm/elixir/String.html#to_atom/1)
* Use [List.to_existing_atom/1](https://hexdocs.pm/elixir/List.html#to_existing_atom/1) instead of [List.to_atom/1](https://hexdocs.pm/elixir/List.html#to_atom/1)
* Use [Module.safe_concat/1,2](https://hexdocs.pm/elixir/Module.html#safe_concat/2) instead of [Module.concat/1,2](https://hexdocs.pm/elixir/Module.html#concat/2)
* Do not use interpolation to create atoms:
    * `:"new_atom_#{index}"`
    * `:'new_atom_#{index}'`
    * `~w[row_#{index} column_#{index}]a`
* Use the `:safe` option when calling [:erlang.binary_to_term/2](https://erlang.org/doc/man/erlang.html#binary_to_term-2) on untrusted input (see also [Serialisation and deserialisation](serialisation))

## Background

Each unique atom value in use in the virtual machine takes up an entry in the global [atom table](http://erlang.org/doc/efficiency_guide/advanced.html). New atom values are appended to this table as needed, but entries are never removed. The size of the table is determined at startup, based on the `+t` [emulator flag](https://erlang.org/doc/man/erl.html#emulator-flags), with a default of 1.048.576 entries. If an attempt is made to add a new value while the table is at capacity, the virtual machine crashes.

Because of the above, care should be taken to not create an unbounded number of atoms. In particular, creating atoms from untrusted input can lead to denial-of-service (DoS) vulnerabilities.

The best way to prevent atom exhaustion is by ensuring no new atom values are created at runtime: as long as any atom value required by the application is referenced in code, that value will be defined in the atom table when the code is loaded (e.g. at [release](releases) startup). The conversion of other types into atoms can then be constrained to only allow existing values by using lookup tables, or when this is not practical, by using the `...to_existing_atom/1` function variants.

A lookup table is to be preferred since the `...to_existing_atom/1` function variants can still accept arbitrary input and introduce unintended atoms. Using a lookup table prevents the risk of converting unexpected or harmful values, such as an existing module name, into atoms. This method not only safeguards against atom table exhaustion but also ensures strict control over which atoms are allowed in your application.

Beware of functions in applications/libraries that create atoms from input values. For instance, the [xmerl_scan](https://erlang.org/doc/man/xmerl_scan.html) XML parser that comes with Erlang/OTP generates atoms from XML tag and attribute names (see [Erlang standard library: xmerl](xmlerl)), and the [http_uri:parse/1](https://erlang.org/doc/man/http_uri.html#parse-1) function in the 'inets' application converts the URI scheme to an atom (see [Erlang standard library: inets](inets)).

Consider using instrumentation to monitor the value of [erlang:system_info(atom_count)](https://erlang.org/doc/man/erlang.html#system_info_atom_count) relative to [erlang:system_info(atom_limit)](https://erlang.org/doc/man/erlang.html#system_info_atom_limit), and generate an alert when the atom count continues to increase after startup or when it crosses a threshold.
