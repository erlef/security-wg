---
title: "Erlang standard library: ssl"
previous:
  url: timing_attacks
  title: Preventing timing attacks
next:
  url: inets
  title: "Erlang standard library: inets"
---

## TLS clients

* Set `verify` to `verify_peer` and select a CA trust store using the `cacertfile` or `cacerts` options
* Consider enabling certificate revocation checks using the `crl_check` and `crl_cache` options
* Customize the enabled protocol versions and cipher suites, depending on the use-case

## TLS servers

* Customize the enabled protocol versions and cipher suites, depending on the use-case
* Set `honor_cipher_order` to true
* Set `client_renegotiation` to false

## Server certificate verification

The default value for the `verify` [option](https://erlang.org/doc/man/ssl.html#TLS/DTLS%20OPTION%20DESCRIPTIONS%20-%20CLIENT) in the ssl application is `verify_none`. While this is an appropriate value for most servers, it presents a significant risk for clients: with the default value clients silently ignore the server’s certificate, making them vulnerable to man-in-the-middle (MitM) attacks. Except under very specific circumstances, any TLS client should set the `verify` option to `verify_peer`.

In order for client connections to succeed in `verify_peer` mode, a few more ssl options must be set:

* A set of trusted root CA certificates must be selected, using the `cacertfile` or `cacerts` options; consider using the CA trust store available in the target operating system (e.g. /etc/ssl/certs/ca-certificates.crt), or add a Hex package such as [certifi](https://hex.pm/packages/certifi) or [castore](https://hex.pm/packages/castore) as a dependency; either way, ensure the CA trust store is regularly updated

* It may be necessary to increase the value of the `depth` option from its default of 1; a value of 2 or 3 should be sufficient for most servers on the public Internet

* It may also be necessary to pass the `customize_hostname_check` option, to enable support for common wildcard certificates; the examples given below work on OTP 21 or later; for compatibility with older releases consider using the [ssl_verify_fun](https://hex.pm/packages/ssl_verify_fun) Hex package instead

```erlang
%% Erlang
ssl:connect("example.net", 443, [
    {verify, verify_peer},
    {cacertfile, "/etc/ssl/cert.pem"},
    {depth, 3},
    {customize_hostname_check, [
        {match_fun, public_key:pkix_verify_hostname_match_fun(https)}
    ]}
]).
```

```elixir
# Elixir
:ssl.connect('example.net', 443,
  verify: :verify_peer,
  cacertfile: '/etc/ssl/cert.pem',
  depth: 3,
  customize_hostname_check: [
    match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
  ]
)
```

Make sure to test the selected options against test endpoints, such as those provided by [https://badssl.com](https://badssl.com). Negative testing, i.e. making sure the connection fails when it should, is arguably more important than positive (interoperability) testing.

## Revocation check

One scenario that’s not handled by the above examples is certificate revocation: no revocation check is performed, and therefore a revoked but otherwise valid certificate would be accepted. It is possible to check certificates against the CA’s Certificate Revocation List (CRL) by setting the `crl_check` option to `best_effort`. This also requires the `crl_cache` to be configured:

```erlang
%% Erlang
ssl:connect("revoked.badssl.com", 443, [
    {verify, verify_peer},
    {cacertfile, "/etc/ssl/cert.pem"},
    {depth, 3},
    {customize_hostname_check, [
        {match_fun, public_key:pkix_verify_hostname_match_fun(https)}
    ]},
    {crl_check, best_effort},
    {crl_cache, {ssl_crl_cache, {internal, [{http, 1000}]}}}
]).
```

```elixir
# Elixir
:ssl.connect('revoked.badssl.com', 443,
  verify: :verify_peer,
  cacertfile: '/etc/ssl/cert.pem',
  depth: 3,
  customize_hostname_check: [
    match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
  ],
  crl_check: :best_effort,
  crl_cache: {:ssl_crl_cache, {:internal, [http: 1000]}}
)
```

The stricter `true` can be used instead of `best_effort`: in this case validation will fail if CRL is missing, which can happen if the certificate has no CRL or exclusively uses OCSP.

However, please note that the `ssl_crl_cache` module does not actually cache the CRL contents, so each handshake will trigger a new CRL lookup, which impacts the performance and reliability of TLS connections. In applications that require revocation checks as well as high throughput a custom CRL cache implementation will be needed.

## Selecting protocol versions and ciphers

In both clients and servers it is recommended to review the enabled TLS protocol versions and cipher suites, disabling weaker values that are not strictly required for interoperability. Additionally, in servers the cipher suites should be listed in order of preference (typically stronger ciphers should be listed first, and weaker ciphers included for compatibility reasons should be last), and the `honor_cipher_order` option should be set to true.

```erlang
%% Erlang
Versions = ['tlsv1.2'],

%% Start with TLS 1.2 defaults
CipherSuites0 = ssl:cipher_suites(default, 'tlsv1.2'),
CipherSuites = ssl:filter_cipher_suites(CipherSuites0, [
    %% Only ECDHE key exchange, for forward secrecy
    {key_exchange, fun
        (ecdhe_ecdsa) -> true;
        (ecdhe_rsa) -> true;
        (_) -> false
    end},
    %% Exclude SHA1
    {mac, fun
        (sha) -> false;
        (_) -> true
    end}]).
```

```elixir
# Elixir
versions = [:"tlsv1.2"]

ciphers_suites =
  # Start with TLS 1.2 defaults
  :ssl.cipher_suites(:default, :"tlsv1.2")
  # Only ECDHE key exchange, for forward secrecy
  |> Enum.filter(&match?(%{key_exchange: kx} when kx in [:ecdhe_ecdsa, :ecdhe_rsa], &1))
  # Exclude SHA1
  |> Enum.reject(&match?(%{mac: :sha}, &1))
```

Consider making the protocol version and cipher suite configuration part of the application’s runtime configuration, instead of hardcoding the values: it should be possible to remove or add a protocol version or cipher suite without rebuilding the application.

## Other options

The `client_renegotiation` server-side option can be set to `false` to disable client-initiated session renegotiation, to prevent it from being used as a DoS vector by malicious clients. Note that very long-lived TLS connections sending large data volumes may require periodic renegotiation to prevent sequence numbers (nonce) from wrapping. If this happens when `client_renegotiation` is set to `false`, the connection will be terminated.

This option is relevant only for TLS version 1.2 and earlier, as in 1.3 renegotiation is not supported and nonce wrapping is handled by rekeying.

## TLS client and server libraries

Finally, when using standard library or third party packages that use ssl to implement TLS clients or servers, verify whether secure defaults are used. See also [Erlang standard library: inets](inets), for information about the ‘httpc’ HTTP client.
