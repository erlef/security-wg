---
title: "Erlang standard library: crypto"
previous:
  url: inets
  title: "Erlang standard library: inets"
next:
  url: public_key
  title: "Erlang standard library: public_key"
---

* Consider using higher-level APIs to meet your application’s cryptographic needs
* Use the higher-level functions for operations with asymmetrical keys in the [public_key](https://erlang.org/doc/man/public_key_app.html) application:
  * Use [public_key:sign/3,4](https://erlang.org/doc/man/public_key.html#sign-4) instead of [crypto:sign/4,5](https://erlang.org/doc/man/crypto.html#sign-5)
  * Use [public_key:verify/4,5](https://erlang.org/doc/man/public_key.html#verify-5) instead of [crypto:verify/5,6](https://erlang.org/doc/man/crypto.html#verify-6)

## Background

The [crypto](https://erlang.org/doc/man/crypto_app.html) application mostly exists to provide an API to cryptographic primitives of OpenSSL. Using these primitives in applications requires a thorough understanding of the underlying algorithms and the proper way to apply them. It is very easy to use otherwise sound cryptographic algorithms in ways that completely fail to meet the security requirements of an application.

Consider using a higher-level API that offers the functionality the application needs, e.g.:
* [NaCl](https://nacl.cr.yp.to/) / [libsodium](https://libsodium.org/), through the [enacl](https://hex.pm/packages/enacl) package
* The [plug_crypto](https://hex.pm/packages/plug_crypto) package, for simple encrypt/decrypt or sign/verify operations, especially in Plug/Phoenix applications
