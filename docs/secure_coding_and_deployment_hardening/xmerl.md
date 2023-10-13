---
title: "Erlang standard library: xmerl"
previous:
  url: public_key
  title: "Erlang standard library: public_key"
next:
   url: deployment_hardening
   title: Deployment Hardening
---

* Do not use [xmerl_scan](https://erlang.org/doc/man/xmerl_scan.html) on untrusted input (see [Preventing atom exhaustion](atom_exhaustion))
* When using [xmerl_sax_parser](https://erlang.org/doc/man/xmerl_sax_parser.html) on untrusted input, disable both internal and external entity expansion:
  * In your [EventFun callback](https://erlang.org/doc/man/xmerl_sax_parser.html#EventFun-3), raise an exception on receiving an 'internalEntityDecl' or 'externalEntityDecl' event

## Background

The [xmerl_scan](https://erlang.org/doc/man/xmerl_scan.html) module returns XML attribute names and tag names as atoms. When used on untrusted user input, or even trusted but highly dynamic input, this can lead to atom exhaustion and therefore a DoS vulnerability (see [Preventing atom exhaustion](atom_exhaustion)).

The [xmerl_sax_parser](https://erlang.org/doc/man/xmerl_sax_parser.html) module by default expands both internal and external entities. Any entity expansion can lead to exponential expansion through a payload called an XML bomb, such as the ‘billion laughs’ attack. Allowing entity expansion in untrusted input is therefore a DoS vulnerability.

Entity expansion can be disabled by raising an exception on 'internalEntityDecl' or 'externalEntityDecl' events in the SAX callback function.

Expanding external entities carries additional risks, potentially leading to DoS or information leakage. These issues are not specific to Erlang or `xmerl`; please search for ‘XXE attack’ or ‘XML External Entity attack’ for further information.
