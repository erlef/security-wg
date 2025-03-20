---
layout: page
title: Distribution Protocol and EPMD
previous:
  url: releases
  title: Releases
next:
  url: crash_dumps
  title: Crash dumps and core dumps
---

* Enable strong authentication, confidentiality and integrity protection by using TLS rather than TCP for the distribution protocol
* Isolate the distribution protocol and EPMD from client facing network interfaces
* Use an SSH tunnel or VPN for remote access to the Erlang shell
* Do not use Erlang distribution to connect layers in a multi-tier architecture (e.g. application layer to database layer), as it does not provide any isolation

## Background

The Erlang distribution protocol allows multiple VM instances to form a cluster, capable of running distributed applications. Processes can access resources across all nodes, transparently or through RPC, so if one node in a cluster is compromised, all nodes are. This also means the distribution protocol itself is extremely powerful, and it is absolutely essential to ensure that malicious users cannot gain access to it.

The distribution protocol is started by assigning a node name to a VM at startup, either through [command line arguments](https://erlang.org/doc/man/erl.html#flags) or in the 'vm.args' file of a release. It may also be started at runtime through the [net_kernel:start/1](https://erlang.org/doc/man/net_kernel.html#start-1) function.

## Authentication, confidentiality, integrity

By default the distribution protocol is authenticated using ‘cookies’, as described in the [Erlang Reference Manual](https://erlang.org/doc/reference_manual/distributed.html#security). Cookies enable rudimentary access control, letting nodes decide which other nodes can join a cluster. The cookie value is not transmitted on the wire (a challenge/response mechanism is used), but no protections are in place against an active (man-in-the-middle) attack. Moreover, the default distribution protocol transmits all application data in the clear, using a variant of [External Term Format](http://erlang.org/doc/apps/erts/erl_ext_dist.html).

Because of the limitations of cookie-based authentication, and in order to ensure the confidentiality and integrity of data exchanged between nodes, the use of TLS is recommended. The ‘ssl’ application’s User Guide includes a chapter on [Using TLS for Erlang Distribution](https://erlang.org/doc/apps/ssl/ssl_distribution.html). The `{verify, verify_peer}` option must be present in the client options, along with a `{cacertfile, Path}` pointing to the root CA certificate used to issue node certificates. The use of mutual TLS authentication, using a client certificate and  `{verify, verify_peer}` in the server options, is recommended.

## EPMD

The [Erlang Port Mapper Daemon](http://erlang.org/doc/man/epmd.html) (EPMD) is a service that enables discovery of nodes by name. It may be launched directly through the `epmd` executable, or implicitly by the first node on a host (unless the `-start_epmd false` argument is passed to the VM). EPMD normally listens on port 4369.

The [EPMD protocol](https://erlang.org/doc/apps/erts/erl_dist_protocol.html#epmd-protocol) allows unauthenticated clients to look up a node by name, as well as to retrieve the full list of known nodes. The response includes the TCP port on which the node's distribution protocol may be reached. Running EPMD on an untrusted network therefore exposes information about the distributed Erlang cluster(s) known at the host.

## Network isolation

By default the distribution protocol binds to all available network interfaces. To minimize the risk of unauthorized access, consider setting up a dedicated intra-cluster network, for example using virtual network interfaces (in a cloud environment) or VLANs (on bare-metal). Use the `inet_dist_use_interface` [kernel configuration](https://erlang.org/doc/man/kernel_app.html#configuration) option to make sure the distribution protocol binds only to the IP address of that interface. The address must be specified in Erlang tuple syntax.

EPMD also binds to all network interfaces by default. An IP address can be specified using the `-address` [command line argument](http://erlang.org/doc/man/epmd.html#regular-options) or the 'ERL_EPMD_ADDRESS' environment variable. The environment variable also takes effect when EPMD is started implicitly by the first node on a host. Note that EPMD always listens on the loopback interface (127.0.0.1 and ::1), regardless of the address specified.

## Unclustered nodes

Remote access to a node for monitoring and maintenance can be achieved over [an SSH tunnel](http://blog.plataformatec.com.br/2016/05/tracing-and-observing-your-remote-node/) without exposing the distribution protocol on any external network interface. If the node is not part of a cluster, and the distribution protocol is enabled only to allow remote access through an SSH tunnel, consider binding to the loopback interface only:

```bash
ERL_EPMD_ADDRESS=127.0.0.1 erl -sname example -kernel inet_dist_use_interface '{127, 0, 0, 1}'
```

When deploying a BEAM project that has no need for distribution whatsoever, ideally we should disable the distribution protocol completely. Unfortunately, since everything needed to run a distributed node is included in the ‘kernel’ application, this is not trivial. The distribution protocol can be *mostly* disabled by passing the `-proto_dist none` VM argument, which prevents node initialization because `none` is not a valid option.

## Architectural considerations

When building a multi-tier application in which several tiers are implemented on top of the BEAM it can be tempting to use distributed Erlang to connect the tiers. But keep in mind that this effectively removes the isolation between the layers. The use of distributed Erlang should typically be constrained to horizontal clusters only, relying on more constrained interfaces such as HTTP and database APIs between layers.
