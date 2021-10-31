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

One scenario that’s not handled by the above examples is certificate revocation: no revocation check is performed, and therefore a revoked but otherwise valid certificate would be accepted. It is possible to check certificates against the CA’s Certificate Revocation List (CRL) by setting the `crl_check` option to true. This also requires the `crl_cache` to be configured:

```erlang
%% Erlang
ssl:connect("revoked.badssl.com", 443, [
    {verify, verify_peer},
    {cacertfile, "/etc/ssl/cert.pem"},
    {depth, 3},
    {customize_hostname_check, [
        {match_fun, public_key:pkix_verify_hostname_match_fun(https)}
    ]},
    {crl_check, true},
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
  crl_check: true,
  crl_cache: {:ssl_crl_cache, {:internal, [http: 1000]}}
)
```

However, please note that the `ssl_crl_cache` module does not actually cache the CRL contents, so each handshake will trigger a new CRL lookup, which impacts the performance and reliability of TLS connections. In applications that require revocation checks as well as high throughput a custom CRL cache implementation will be needed.

## Selecting protocol versions and ciphers

Recent versions of Erlang/OTP disable most weak, legacy SSL/TLS protocol versions and cipher suites. For instance, Erlang/OTP 24 receives an 'A' score on the [Qualys SSL Labs 'SSL Server Test'](https://www.ssllabs.com/ssltest/), without any further tuning.

Further hardening of the TLS parameters to comply with the Mozilla '[Server Side TLS](https://wiki.mozilla.org/Security/Server_Side_TLS)' "Intermediate compatibility" recommendations can be achieved as described below. These recommendations were written for servers, but the same settings may be used for client-side hardening, depending on the configuration of the TLS server(s) the client is expected to connect to.

```erlang
%% Erlang

PreferredCiphers = [
  %% Cipher suites (TLS 1.3): TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
  #{cipher => aes_128_gcm, key_exchange => any, mac => aead, prf => sha256},
  #{cipher => aes_256_gcm, key_exchange => any, mac => aead, prf => sha384},
  #{cipher => chacha20_poly1305, key_exchange => any, mac => aead, prf => sha256},
  %% Cipher suites (TLS 1.2): ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:
  %% ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:
  %% ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
  #{cipher => aes_128_gcm, key_exchange => ecdhe_ecdsa, mac => aead, prf => sha256},
  #{cipher => aes_128_gcm, key_exchange => ecdhe_rsa, mac => aead, prf => sha256},
  #{cipher => aes_256_gcm, key_exchange => ecdhe_ecdsa, mac => aead, prf => sha384},
  #{cipher => aes_256_gcm, key_exchange => ecdhe_rsa, mac => aead, prf => sha384},
  #{cipher => chacha20_poly1305, key_exchange => ecdhe_ecdsa, mac => aead,prf => sha256},
  #{cipher => chacha20_poly1305, key_exchange => ecdhe_rsa, mac => aead, prf => sha256},
  #{cipher => aes_128_gcm, key_exchange => dhe_rsa, mac => aead, prf => sha256},
  #{cipher => aes_256_gcm, key_exchange => dhe_rsa, mac => aead, prf => sha384}
],
Ciphers = ssl:filter_cipher_suites(PreferredCiphers, []),

%% Protocols: TLS 1.2, TLS 1.3
Versions = ['tlsv1.2', 'tlsv1.3'],

%% TLS curves: X25519, prime256v1, secp384r1
PreferredEccs = [secp256r1, secp384r1],
Eccs = ssl:eccs() -- (ssl:eccs() -- PreferredEccs),

SslOpts = [
  {ciphers, Ciphers},
  {versions, Versions},
  {eccs, Eccs}
].
```

```elixir
# Elixir

preferred_ciphers = [
  # Cipher suites (TLS 1.3): TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256
  %{cipher: :aes_128_gcm, key_exchange: :any, mac: :aead, prf: :sha256},
  %{cipher: :aes_256_gcm, key_exchange: :any, mac: :aead, prf: :sha384},
  %{cipher: :chacha20_poly1305, key_exchange: :any, mac: :aead, prf: :sha256},
  # Cipher suites (TLS 1.2): ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:
  # ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:
  # ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384
  %{cipher: :aes_128_gcm, key_exchange: :ecdhe_ecdsa, mac: :aead, prf: :sha256},
  %{cipher: :aes_128_gcm, key_exchange: :ecdhe_rsa, mac: :aead, prf: :sha256},
  %{cipher: :aes_256_gcm, key_exchange: :ecdh_ecdsa, mac: :aead, prf: :sha384},
  %{cipher: :aes_256_gcm, key_exchange: :ecdh_rsa, mac: :aead, prf: :sha384},
  %{cipher: :chacha20_poly1305, key_exchange: :ecdhe_ecdsa, mac: :aead, prf: :sha256},
  %{cipher: :chacha20_poly1305, key_exchange: :ecdhe_rsa, mac: :aead, prf: :sha256},
  %{cipher: :aes_128_gcm, key_exchange: :dhe_rsa, mac: :aead, prf: :sha256},
  %{cipher: :aes_256_gcm, key_exchange: :dhe_rsa, mac: :aead, prf: :sha384}
]
ciphers = :ssl.filter_cipher_suites(preferred_ciphers, [])

# Protocols: TLS 1.2, TLS 1.3
versions = [:"tlsv1.2", :"tlsv1.3"]

# TLS curves: X25519, prime256v1, secp384r1
preferred_eccs = [:secp256r1, :secp384r1]
eccs = :ssl.eccs() -- (:ssl.eccs() -- preferred_eccs)

ssl_opts = [
  {:ciphers, ciphers},
  {:versions, versions},
  {:eccs, eccs}
]
```

Notes:

  * The preferred cipher suites from Mozilla's recommendation are filtered
    through `ssl:filter_cipher_suites/2` with an empty filter, to remove any
    values not supported by the `crypto` and its underlying OpenSSL version
  * The X25519 curve is not included in the preferred curve names, as `ssl`
    enables it implicitly
  * The list of supported ECC curves is fetched using `ssl:eccs/0` and used to
    remove any unsupported values from the list of preferred curves
  * The `ssl` application default of `{honor_cipher_order, false}` is retained,
    in accordance with Mozilla's recommendation; some test tools rate a
    server's configuration higher when this option is set to `true`, to let
    the server override the client's cipher preferences

Consider making the protocol version and cipher suite configuration part of the application’s runtime configuration, instead of hardcoding the values: it should be possible to remove or add a protocol version or cipher suite without rebuilding the application.

## Other options

The `client_renegotiation` server-side option can be set to `false` to disable client-initiated session renegotiation, to prevent it from being used as a DoS vector by malicious clients. Note that very long-lived TLS connections sending large data volumes may require periodic renegotiation to prevent sequence numbers (nonce) from wrapping. If this happens when `client_renegotiation` is set to `false`, the connection will be terminated.

This option is relevant only for TLS version 1.2 and earlier, as in 1.3 renegotiation is not supported and nonce wrapping is handled by rekeying.

## TLS client and server libraries

Finally, when using standard library or third party packages that use ssl to implement TLS clients or servers, verify whether secure defaults are used. See also [Erlang standard library: inets](inets), for information about the ‘httpc’ HTTP client.
