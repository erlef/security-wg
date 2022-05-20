---
title: "'otp' Package URL type"
layout: page
---

This document proposes a new [Package URL (purl)](https://github.com/package-url/purl-spec) type for OTP applications. It explains the use-case for this new purl type, along with how it relates to the ['hex' purl type](https://github.com/hexpm/specifications/blob/master/package-url.md), followed by a formal specification.

For background information on Package URLs, please refer to the [purl specifications](https://github.com/package-url/purl-spec).

## Background

Suppose we were to deploy a BEAM project on a Linux VM using Debian 10 (Buster), using the OS native package manager to install the 'erlang' package ([erlang_21.2.6+dfsg-1_all](https://debian.pkgs.org/10/debian-main-amd64/erlang_21.2.6+dfsg-1_all.deb.html)). The project itself depends on Cowboy (fetched from Hex, along with its dependencies) and is built on a dediced build server and packaged as a release. The release contains only the project files, not the Erlang runtime system.

For such an installation, the software bill-of-materials (SBOM) might include the following purls:

```
pkg:deb/debian/erlang@21.2.6+dfsg-1?arch=amd64&distro=buster
pkg:deb/debian/erlang-asn1@21.2.6+dfsg-1?arch=amd64&distro=buster
pkg:deb/debian/erlang-base@21.2.6+dfsg-1?arch=amd64&distro=buster
pkg:deb/debian/erlang-base-hipe@21.2.6+dfsg-1?arch=amd64&distro=buster
pkg:deb/debian/erlang-common-test@21.2.6+dfsg-1?arch=amd64&distro=buster
pkg:deb/debian/erlang-crypto@21.2.6+dfsg-1?arch=amd64&distro=buster
[...snip...]
pkg:deb/debian/erlang-wx@21.2.6+dfsg-1?arch=amd64&distro=buster
pkg:deb/debian/erlang-xmerl@21.2.6+dfsg-1?arch=amd64&distro=buster
pkg:hex/cowboy@2.7.0
pkg:hex/cowlib@2.8.0
pkg:hex/ranch@1.7.1
```

To reduce the attack surface, the 'erlang-base' package along with the required OTP application packages could be selected manually, rather than installing everything through the 'erlang' meta-package.

So far, so good: if a vulnerability is found in Erlang/OTP's crypto application the advisory could identify the affected Debian package using a 'deb' purl, and a vulnerability advisory for Cowboy could use a 'hex' purl.

In practice, however, OS-native Erlang/OTP packages are often out-of-date. Instead, a specific Erlang/OTP version might be built using 'kerl' or 'asdf', or the runtime system might be bundled with the release. The latter option has the added advantage that the applications required at runtime will be selected and packaged by the build process.

Furthermore, the project might be written in Elixir, which would requires the 'elixir', 'logger' and perhaps 'eex' applications, part of the Elixir runtime system. These applications would therefore have to be installed on the deployment machine, e.g. using 'asdf' or by including them in the release.

Now when we want to build an SBOM we have a problem: a significant part of our project consists of OTP applications that cannot be identified by a 'deb' or 'hex' purl.

One way around this might be to reference the source repo, as used by 'kerl' or 'asdf', by using 'github' purls:

```
pkg:github/erlang/otp@OTP-22.2.6
pkg:github/elixir-lang/elixir@v1.10.0
pkg:hex/cowboy@2.7.0
pkg:hex/cowlib@2.8.0
pkg:hex/ranch@1.7.1
pkg:hex/plug@1.8.3
pkg:hex/phoenix@1.4.12
```

However, we loose the ability to specify which parts of Erlang or Elixir we are actually using, or to selectively patch or upgrade the individual applications. It may also be difficult for SBOM tools to determine exactly which source repository was used.

## Proposal

OTP applications are required to declare a name and version. Granted, application names cannot be guaranteed to be globally unique, but for a set of well-known applications collisions are unlikely.

Identifying Erlang/OTP built-in applications versions by their own version number, rather than the Erlang/OTP release number, is both more accurate and more flexible: it is easy at runtime or through inspection of the '.app' file to tell exactly which version of an application is in use, and any selective patching is reflected properly.

The SBOM for our Elixir project release with bundled runtime system would now look something like this:

```
pkg:otp/erts@10.6.3?arch=amd64
pkg:otp/kernel@6.5.1
pkg:otp/stdlib@3.11.2
pkg:otp/crypto@4.6.4?arch=amd64
pkg:otp/public_key@1.7.1
pkg:otp/ssl@9.5.3
[...snip...]
pkg:otp/elixir@1.10.0
pkg:otp/eex@1.10.0
pkg:otp/logger@1.10.0
pkg:hex/cowboy@2.7.0
pkg:hex/cowlib@2.8.0
pkg:hex/ranch@1.7.1
pkg:hex/plug@1.8.3
pkg:hex/phoenix@1.4.12
[...snip...]
```

Other applications that may be identified using the 'otp' purl type include Rebar3, Hex, LFE and Alpaca.

## Relation to 'hex' purl type

The main advantage of 'hex' purls over 'otp' purls is that Hex has a global namespace, at least when scoped to a specific repo (e.g. hex.pm). This means name collisions are less likely. Moreover, a Hex package version uniquely identifies a specific set of source files, whereas an OTP application compiled from different branches/commits of the source repo might produce an application with the same version number.

Therefore, when building an SBOM tools should prefer a 'hex' purl whenever the source of the package is indeed a Hex repository. An 'otp' purl should only be used for software components that were not (cannot be) retrieved from a Hex repository.

It is worth noting that the application name of a Hex package does not necessarily match the package name. In other words, for a given Hex package, the 'name' element of its 'hex' purl may not match the 'name' element of that same package's 'otp' purl.

## Specification

* The 'type' is "otp"
* The 'namespace' is not used
* The 'name' is the OTP application name; it is not case sensitive and must be lowercased
* The 'version' is the OTP application version
* Optional qualifiers:
  * 'platform' - if the application contains native code (such as NIFs), this qualifier may be used to specify the target platform for which that code was compiled, such as 'linux', 'darwin' (MacOS X), 'freebsd', 'sunos' (Solaris), 'win32' (Windows); it is not case sensitive and must be lowercased
  * 'arch' - if the application contains native code (such as NIFs), this qualifier may be used to specify the target architecture for which that code was compiled; it is not case sensitive and must be lowercased

## Examples

The Erlang Run Time System (ERTS) application, including the BEAM emulator, EPMD, 'erlexec' and other binaries, version 10.6.3 compiled for Linux on AMD64:

    pkg:otp/erts@10.6.3?platform=linux&arch=amd64

The 'stdlib' application, version 3.11.2:

    pkg:otp/stdlib@3.11.2

The 'crypto' application, version 4.6.4 with NIFs compiled for MacOS X:

    pkg:otp/crypto@4.6.4?platform=darwin&arch=x86_64

The Elixir, Logger and EEx applications, part of Elixir version 1.10.0:

    pkg:otp/elixir@1.10.0
    pkg:otp/eex@1.10.0
    pkg:otp/logger@1.10.0

The Rebar3 application, version 3.13.0:

    pkg:otp/rebar@3.13.0
