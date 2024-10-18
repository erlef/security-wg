---
title: Spawning external executables
previous:
  url: serialisation
  title: Serialisation and deserialisation
next:
  url: sensitive_data
  title: Protecting sensitive data
---

## Erlang

* Use [open_port/2](https://erlang.org/doc/man/erlang.html#open_port-2) instead of [os:cmd/1,2](https://erlang.org/doc/man/os.html#cmd-2), and:
  * Use `{spawn_executable, FileName}` instead of `{spawn, Command}` as the first argument
  * Avoid using a shell as the executable and passing the arguments as a single string
  * Clear or override sensitive environment variables using the `{env, Env}` option

## Elixir

* When using [System.cmd/2,3](https://hexdocs.pm/elixir/System.html#cmd/3):
  * Avoid using a shell as the executable and passing the arguments as a single string
  * Clear or override sensitive environment variables using the `:env` option

## Background

Sometimes it may be necessary to spawn an external executable to complete a task. Often command line arguments must be passed to the external program to customize its behaviour. When some of these arguments are based on untrusted input, an injection vulnerability may allow malicious users to execute arbitrary commands or exfiltrate data from the host filesystem or environment variables.

The [os:cmd/1,2](https://erlang.org/doc/man/os.html#cmd-2) function in the Erlang/OTP standard library takes a single argument containing both the name of the executable and any command line arguments. An operating system shell is spawned to parse the command and locate the executable. This makes it particularly difficult to protect against command injection, requiring careful filtering and escaping of untrusted input prior to inclusion in the command.

It is safer to use [open_port/2](https://erlang.org/doc/man/erlang.html#open_port-2) with `{spawn_executable, FileName}`, which takes the command line arguments as a list, through the `{args, Args}` option. The arguments are passed to the executable as-is, without environment variable expansion or other processing, neutralizing injection attacks. Note, however, that executing batch files (.bat, .cmd, ...) on Microsoft Windows may not be safe, even with `open_port/2`, as mentioned [here](https://erlangforums.com/t/user-controlled-arguments-to-open-port-2-with-spawn-spawn-executable-is-insecure-on-windows/3476). When executing binaries on Windows, explicitly specify the extension (e.g. .exe) to avoid accidental invocation of a batch file.

The input/output behaviour of a Port is different from `os:cmd/1,2`, however, so `open_port/2` is not a drop-in replacement. Also note that the `{spawn_executable, FileName}` form requires specifying the full path to the executable, so it may be necessary to call [os:find_executable/1,2](https://erlang.org/doc/man/os.html#find_executable-2) first.

The [System.cmd/2,3](https://hexdocs.pm/elixir/System.html#cmd/3) function in the Elixir standard library is a wrapper around `open_port/2` rather than `:os.cmd/1,2`, using the safer approach of passing command line arguments as a list. Unless an absolute path is passed as the executable, the executable is located automatically using `:os.find_executable/1`.

Using a shell (such as "/bin/sh") as the executable and passing the command using the shell’s "-c" argument defeats the benefits of `open_port/2` in terms of command injection protection.

## Environment

On most platforms the spawned process will inherit the environment from the BEAM process, which may include sensitive information. For example, when using an environment variable to pass database credentials to the BEAM application, make sure that variable is cleared in the call to `open_port/2` or `System.cmd/2,3`, to minimize the risk of the password leaking through vulnerabilities, core dumps or unanticipated behaviour of the executable:

```erlang
%% Erlang
open_port({spawn_executable, "/usr/bin/env"}, [{env, [{"DB_PASSWORD", false}]}])
```

```elixir
# Elixir
System.cmd("env", [], env: %{"DB_PASSWORD" => nil})
```
