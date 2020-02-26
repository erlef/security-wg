---
title: "Erlang standard library: inets"
previous:
  url: ssl
  title: "Erlang standard library: ssl"
next:
  url: crypto
  title: "Erlang standard library: crypto"
---

* Pass the `ssl` option with secure client configuration options when connecting to HTTPS servers using ‘httpc’ (see [Erlang standard library: ssl](ssl))
* Use [uri_string:parse/1](https://erlang.org/doc/man/uri_string.html#parse-1) instead of [http_uri:parse/1](https://erlang.org/doc/man/http_uri.html#parse-1) when used with untrusted input, to prevent atom exhaustion (see [Preventing atom exhaustion](atom_exhaustion))

## Background

The ‘httpc` HTTP client in ‘inets’ inherits the TLS protocol defaults from the ‘ssl’ applications, enabling man-in-the-middle (MitM) attacks. Please refer to [Erlang standard library: ssl](ssl) for details.

```erlang
%% Erlang
httpc:request(get, {"https://www.example.net/", []}, [
    {ssl, [
        {verify, verify_peer},
        {cacertfile, "/etc/ssl/cert.pem"},
        {depth, 2},
        {customize_hostname_check, [
            {match_fun, public_key:pkix_verify_hostname_match_fun(https)}
        ]}
    ]}
], []).
```

```elixir
# Elixir
:httpc.request(:get, {'https://www.example.net/', []}, [
  ssl: [
    verify: :verify_peer,
    cacertfile: '/etc/ssl/cert.pem',
    depth: 2,
    customize_hostname_check: [
      match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
    ]
  ]
], [])
```

The [http_uri:parse/1](https://erlang.org/doc/man/http_uri.html#parse-1) function in the ‘inets’ application converts the URI’s scheme to an atom. When used on a URI taken from an untrusted source, such as a web page being parsed, this can lead to atom exhaustion and therefore a crash of the VM. Use the  [uri_string:parse/1](https://erlang.org/doc/man/uri_string.html#parse-1) function from the standard library instead.
