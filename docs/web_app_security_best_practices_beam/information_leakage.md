---
title: Information Leakage
layout: page_with_toc
previous:
  url: tls_vulnerabilities
  title: TLS Vulnerabilities
next:
  url: supply_chain_vulnerabilities
  title: Supply Chain Vulnerabilities
seo_keywords:
  - elixir
  - erlang
  - phoenix
  - phoenix socket
  - ecto
  - information leakage
---

## Elixir and Erlang standard library

Please refer to the
[Secure Coding and Hardening Guidelines chapter on Sensitive Data](../secure_coding_and_deployment_hardening/sensitive_data)
for more information about features available in the Elixir and Erlang standard
library for reducing the risk of accidental data leakage. It explains how to
customize the way inspect renders a struct, wrap secrets in closures, and filter
sensitive data from stacktraces, among other things.

## Parameter filter in Phoenix logger

Phoenix by default logs request parameters for every request. For routes that
accept sensitive data, such as user sign-in, it will be necessary to filter out
those values. This can be done through the
[`Phoenix.Logger` configuration][hexdoc:phoenix.logger_filtering]:

```elixir
config :phoenix, :filter_parameters, ["password", "secret"]
```

By default only parameters that contain the word “password” are filtered. A
stronger form of filtering, using an allow-list rather than a deny-list, can be
used instead.

## Phoenix socket messages

In a LiveView application, form data is submitted over a Phoenix socket, wrapped
in a `Phoenix.Socket.Message` struct. If the socket process dies unexpectedly,
the message that triggered the error is logged as part of the process
termination report. Unfortunately the Phoenix logger parameter filter does
**not** prevent sensitive data from being written in this context.

One way to reduce the risk of data leakage would be to implement the `Inspect`
protocol for the `Phoenix.Socket.Message` struct, as shown [here][elixirform:sensitive_data_socket].

## Redacting fields in Ecto schemas

When defining Ecto schemas, individual fields can be marked with
[`redact: true`][hexdoc:ecto.schema_redacting], to replace the value of those
fields with `**redacted**` when inspecting. This applies not only to the
schema’s structs, but also Changesets that wrap it: changes to the redacted
fields are also automatically redacted when the Changeset is inspected.

[hexdoc:phoenix.logger_filtering]: https://hexdocs.pm/phoenix/Phoenix.Logger.html#module-parameter-filtering
[elixirform:sensitive_data_socket]: https://elixirforum.com/t/sensitive-data-in-phoenix-socket-message-when-genserver-exits/57663/4
[hexdoc:ecto.schema_redacting]: https://hexdocs.pm/ecto/Ecto.Schema.html#module-redacting-fields
