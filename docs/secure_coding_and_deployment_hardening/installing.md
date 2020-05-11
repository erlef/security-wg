---
title: Installing/building the runtime system
previous:
  url: deployment_hardening
  title: Deployment Hardening
next:
  url: releases
  title: Releases
---

* Use a version of Erlang/OTP that is being actively maintained
* Ensure patch packages can be installed quickly and easily
* Ensure build hardening is enabled, to leverage OS protections

## Background

There are several ways to deploy the Erlang runtime system on a production server/VM, including OS (distribution) native package repositories, [Erlang Solutions](https://www.erlang-solutions.com/resources/download.html), [kerl](https://github.com/kerl/kerl), [asdf](https://asdf-vm.com/), manual build from [source](https://github.com/erlang/otp), and Docker (e.g. the [images](https://hub.docker.com/u/hexpm) published by hex.pm).

Which one to choose may depend on personal preferences and operational constraints, but there are a few aspects that impact security that should be considered:

### Release availability

Some sources, in particular the OS native package repositories, may be stuck on an outdated Erlang/OTP release. Officially, bug fixes and security patches are made available for the latest release only. In practice, the last version of the previous major version tends to receive critical fixes for some time. Contact the Erlang/OTP team at Ericsson about the availability of commercial support for specific releases/versions, and the associated SLAs.

For more information, please refer to the [Support, Compatibility, Deprecations, and Removal](https://erlang.org/doc/system_principles/misc.html) chapter in the System Principles User's Guide, and consult the [OTP Versions Tree](http://erlang.org/download/otp_versions_tree.html).

### Patch package availability and installation process

Some sources distribute patch packages as regular software updates, while others require that [the patch be applied](https://github.com/erlang/otp/blob/master/HOWTO/OTP-PATCH-APPLY.md) using the `otp_patch_apply` script. Verify what steps are needed to install a patch package, to ensure they can be applied at short notice when necessary.

### Build hardening

Many operating systems offer features such as Address Space Layout Randomization (ASLR) and stack canaries that help reduce the risk of exploitation of memory-related bugs. To fully leverage these features, the Erlang/OTP runtime system must be built with certain compiler and/or linker options.

On Linux, use the ‘hardening-check’ tool, available as part of the ‘devscripts’ package on recent Debian/Ubuntu and Fedora/Red Hat distributions, to check the hardening status of the Erlang/OTP runtime system’s executables, including ‘beam.smp’, ‘erlexec’ and ‘epmd’.

When building for Linux from source, manually or through tools that handle the build for you such as ‘kerl’ and ‘asdf’, it may be necessary to export the following environment variables prior to building (update with other flags, such as `-O`, as needed):

```bash
CFLAGS="-fpie -fstack-protector-strong"
LDFLAGS="-pie -z now" 
```
