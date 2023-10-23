---
title: Preventing timing attacks
previous:
  url: sandboxing
  title: Sandboxing untrusted code
next:
  url: ssl
  title: "Erlang standard library: ssl"
---

* Use `crypto:hash_equals/2`, or similar specialized constant-time comparison functions, rather than pattern matching or built-in operators to compare secrets


## Background

Pattern-matching is a powerful feature of the BEAM platform. Over the years the compiler and runtime have seen numerous performance improvements, often involving reordering or restructuring the patterns that appear in the source code. Measuring the response time of an application that uses pattern matching can reveal details about the values or data structures the application is expecting. An attacker might be able to use this information to drastically reduce the number of attempts needed to achieve a certain result, compared to a brute-force approach.

The following functions compare a received cookie value versus the expected values in the current session. The first function uses pattern matching to determine if the received value matches the expected value. Pattern matching uses a variable-time equality algorithm to detect differences. For example, if the first bytes of the two values differ, the equality check fails without testing subsequent bytes. Attackers can statistically analyze the time it took for compare two values and eventually infer the expected value.

```erlang
%% Erlang
case Cookie of
    Session#session.cookie -> ok;
    _ -> access_denied
end.
```

```elixir
# Elixir
case conn.assigns[:token] do
  ^token -> :ok
  _ -> :access_denied
end
```

The second implementation uses `crypto:hash_equals/2`. The check avoids comparison shortcuts that would leave it vulnerable to timing attacks. Note that it requires both arguments to be the same size, typically the output of a hash function.

```erlang
%% Erlang
case crypto:hash_equals(Cookie, Session#session.cookie) of
    true -> ok;
    false -> access_denied
end.
```

```elixir
# Elixir
case Plug.Crypto.secure_compare(conn.assigns[:token], token) do
  true -> :ok
  false -> :access_denied
end
```

The `crypto:hash_equals/2` function was introduced in OTP 25. On older Erlang/OTP versions it may be necessary to use a 3rd party library instead. The [pbkdf2](https://hex.pm/packages/pbkdf2) Erlang package contains a `compare_secure/2` function, and the [plug_crypto](https://hex.pm/packages/plug_crypto) Elixir package (which is included in any Phoenix application by default) provides [secure_compare/2](https://hexdocs.pm/plug_crypto/Plug.Crypto.html#secure_compare/2).
