---
title: TLS Vulnerabilities
layout: page_with_toc
previous:
  url: session_management_vulnerabilities
  title: Session Management Vulnerabilities
next:
  url: information_leakage
  title: Information Leakage
seo_keywords:
  - certificate verification
  - weak tls
  - downgrade attack
  - plug
---

## Insufficient peer certificate verification

This is not an issue that is specific to web applications, but it is (or was,
prior to Erlang/OTP 26) the most common TLS-related vulnerability. For
background please refer to [ssl chapter in the Secure Coding and Deployment Hardening Guidelines](../secure_coding_and_deployment_hardening/ssl).

In web applications this issue is most commonly seen in interactions with
external APIs over HTTPS. The exact configuration options necessary to enable
server certificate validation varies by HTTP / API client. When using
Erlang/OTP 26 or later, most clients should correctly verify the server’s
certificate. On older versions, consider using a [Mint][hex:mint]-based HTTP
client, such as [Finch][hex:finch]. Verify the client’s behaviour using a test
site such as [badssl.com](https://badssl.com).

## Weak TLS versions, ciphers and other options

The TLS protocol has evolved over the years and most servers support a range of
protocol versions and cipher configurations. The exact recommendations for
hardening a TLS server are beyond the scope of this document, please refer to
[Mozilla’s recommendations][mozilla_tls_recommendations] and tools such as
[SSL Labs][ssl_labs].

When offloading TLS to an external load balancer or proxy, check out
[Mozilla’s SSL Configuration Generator][mozilla_ssl_confi_gen], but also check
the configuration implementations on the Plug / Phoenix application itself
([Misconfigured TLS offload](#misconfigured-tls-offload)).

When terminating TLS using the web server that host the Plug / Phoenix
application, such as Cowboy or Bandit, check out the
[`Plug.SSL.configure/1`][hexdoc:plug.ssl_configure] function: it may be used to
select a predefined TLS hardening profile based on OWASP’s and Mozilla’s
recommendations. In a Phoenix application the `cipher_suite` option in the
Endpoint’s `https` configuration may be used to select a profile.

## Misconfigured TLS offload

When TLS is terminated by an external load balancer or proxy, rather than the
Plug / Phoenix application itself, the request arrives to the application over
plain HTTP. The `Plug.Conn` struct contains a field, scheme, that indicates
whether the request was received over HTTP or HTTPS, which may be inspected by
other plugs. If this field is not set correctly it can lead to bugs and even
security issues.

Standard plugs and functions that inspect the scheme field include:

- `Plug.Session` - sets the session cookie’s `Secure` attribute if
  `scheme == :https` (see
  [Session leakage (session hijacking)](session_management_vulnerabilities#session-leakage-session-hijacking))
- `Plug.Conn.put_resp_cookie/3,4` - sets the session cookie’s `Secure` attribute
  if `scheme == :https`
- Phoenix route helpers use the scheme field when building absolute URLs, for
  instance callback URLs sent to external authentication servers
- `Plug.SSL` attempts to redirect the user to upgrade the connection to HTTPS
  when `scheme == :http`

When offloading TLS, make sure to configure the load balancer or proxy to inject
the `X-Forwarded-Proto` header to indicate the actual scheme that the client
used. The Plug / Phoenix application can then update the scheme field
accordingly, as follows:

- In a Phoenix application’s Endpoint configuration, set the `force_ssl` option
  according to the recommendations given for `Plug.SSL` below. The advantage of
  using `force_ssl` over using `Plug.SSL` directly is that the Endpoint
  configuration can easily be set differently for production, development and
  testing environments.
- In a Plug application, include `Plug.SSL` with the `rewrite_on` option, set
  according to the headers supported by the load balancer or proxy, e.g.
  `[:x_forwarded_host, :x_forwarded_port, :x_forwarded_proto]`. Consider enabling
  other features as well, e.g. to enable redirection to HTTPS and set the HTTP Strict-Transport-Security response header (see
  [Downgrade attacks](#downgrade-attacks)).
- Alternatively, use `Plug.RewriteOn` instead of `Plug.SSL`, if other features
  of `Plug.SSL` are not needed.

## Downgrade attacks

An application that is only available over HTTPS, not over plain HTTP, protects
user information in-flight by encrypting the request and response data using
TLS. However, if an attacker can trick a user into visiting the application’s
URL with HTTP instead of HTTPS, they may be able to intercept such requests even
if the server itself is not reachable over plain HTTP. This could expose e.g.
the user’s sign-in credentials.

To prevent such downgrade attacks, configure the server to send the HTTP
[`Strict-Transport-Security`][strict_transport_security_header] response header.
This informs the browser that the application should only ever be loaded over
HTTPS, blocking downgrade attacks with a plain HTTP URL. `Plug.SSL` and the
Phoenix `force_ssl` Endpoint configuration take an hsts option that defaults to
`true`.

[hexdoc:plug.ssl_configure]: https://hexdocs.pm/plug/Plug.SSL.html#configure/1
[hex:finch]: https://hex.pm/packages/finch
[hex:mint]: https://hex.pm/packages/mint
[mozilla_ssl_confi_gen]: https://ssl-config.mozilla.org
[mozilla_tls_recommendations]: https://wiki.mozilla.org/Security/Server_Side_TLS
[ssl_labs]: https://www.ssllabs.com/ssltest/
[strict_transport_security_header]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Strict-Transport-Security
