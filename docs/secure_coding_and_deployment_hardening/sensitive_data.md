---
title: Protecting sensitive data
previous:
  url: external_executables
  title: Spawning external executables
next:
  url: sandboxing
  title: Sandboxing untrusted code
---

## General

* Wrap sensitive data in a closure when passing it as an argument to a function
* Prune arguments from stack traces (see sample code below)

## Erlang

* Implement the [Module:format_status/2 callback](https://erlang.org/doc/man/gen_server.html#Module:format_status-2) for [gen_server](https://erlang.org/doc/man/gen_server.html), [gen_event](https://erlang.org/doc/man/gen_event.html) or [gen_statem](https://erlang.org/doc/man/gen_statem.html) processes holding sensitive data
* Use the [private option](https://erlang.org/doc/man/ets.html#new-2) for ETS tables containing sensitive data
* Flag the current process as sensitive using [process_flag(sensitive, true)](https://erlang.org/doc/man/erlang.html#process_flag-2) in processes holding sensitive data or application logic

##  Elixir

* Implement or derive the [Inspect](https://hexdocs.pm/elixir/Inspect.html) protocol for structs
* Implement the [format_status/2 callback](https://hexdocs.pm/elixir/GenServer.html#c:format_status/2) for [GenServer](https://hexdocs.pm/elixir/GenServer.html), [:gen_event](https://erlang.org/doc/man/gen_event.html) or [:gen_statem](https://erlang.org/doc/man/gen_statem.html) processes holding sensitive data
* Use the [:private](https://erlang.org/doc/man/ets.html#new-2) option for ETS tables containing sensitive data
* Flag the current process as sensitive using [:erlang.process_flag(:sensitive, true)](https://erlang.org/doc/man/erlang.html#process_flag-2) in processes holding sensitive data or application logic

## Background

Stopping sensitive data from leaking, to disk, to the console, to external log ingestion services, or even other parts of the application, may be a security or a data privacy compliance requirement.

There are many ways in which sensitive data, such as passwords and private keys, may leak:

* A stack trace, printed to the console or the logs following an exception
* Application or framework/library generated log messages
* Introspection functions used for debugging or monitoring, e.g. using the [erlang](https://erlang.org/doc/man/erlang.html), [sys](https://erlang.org/doc/man/sys.html) or [dbg](https://erlang.org/doc/man/dbg.html) modules, or the [Observer tool](https://erlang.org/doc/man/observer.html)
* A [crash dump](https://erlang.org/doc/apps/erts/crash_dump.html), generated when the VM encounters a problem it cannot recover from
* An OS core dump, as a result of an internal failure in the BEAM executable or other native code

To make things worse, due to the immutable nature of data in the BEAM such data may stick around longer than strictly necessary. In languages with mutable data it is common practice to overwrite sensitive data in memory immediately after use, but in BEAM languages this is not possible. However, there are some tools and techniques that may be used to reduce the chance of leakage.

## Wrapping

Exceptions may result in console or log output that includes a stack trace. Mostly a stack trace shows the module/function/arity and the filename/line where the exception occurred, but for the function at the top of the stack the actual list of arguments may be included instead of the function arity.

To prevent sensitive data from leaking in a stack trace, the value may be wrapped in a closure: a zero-arity anonymous function. The inner value can be easily unwrapped where it is needed by invoking the function. If an error occurs and function arguments are written to the console or a log, it is shown as `#Fun<...>` or `#Function<...>`. Secrets wrapped in a closure are also safe from introspection using Observer and from being written to crash dumps.

```erlang
%% Erlang
WrappedSecret = fun() -> os:getenv("SECRET") end.
```

```elixir
# Elixir
wrapped_secret = fn -> System.get_env("SECRET") end
```

## Stacktrace pruning

Another approach, useful in functions that call the standard library (e.g. `crypto`) or other functions that do not support wrapping secrets in a closure, is stripping argument values from the stack trace when an exception occurs. This can be done by wrapping the function call(s) in a try ... catch expression (Erlang) or adding a rescue clause to a function body (Elixir), and stripping the function arguments before re-raising the exception:

```erlang
%% Erlang
encrypt_with_secret(Message, WrappedSecret) ->
    try
        some_crypto_lib:encrypt(Message, WrappedSecret())
    catch
        Class:Reason:Stacktrace0 ->
            Stacktrace = prune_stacktrace(Stacktrace0),
            erlang:raise(Class, Reason, Stacktrace)
    end.

prune_stacktrace([{M, F, [_ | _] = A, Info} | Rest]) ->
    [{M, F, length(A), Info} | Rest];

prune_stacktrace(Stacktrace) ->
    Stacktrace.
```

```elixir
# Elixir
def encrypt_with_secret(message, wrapped_secret) do
  ComeCryptoLib.encrypt(message, wrapped_secret.())
rescue
  e -> reraise e, prune_stacktrace(System.stacktrace())
end

defp prune_stacktrace([{mod, fun, [_ | _] = args, info} | rest]),
  do: [{mod, fun, length(args), info} | rest]

defp prune_stacktrace(stacktrace), do: stacktrace
```

(Adapted from the `plug_crypto` package; the [Plug.Crypto.prune_args_from_stacktrace/1](https://github.com/elixir-plug/plug_crypto/blob/v1.0.0/lib/plug/crypto.ex#L11-L21) function can be used directly in the rescue clause, if the package is available)

## Customizing introspection

In Elixir, when terms need to be written to the console or a log, the [Inspect](https://hexdocs.pm/elixir/Inspect.html) is used to generate a string representation of that term. By customizing the Inspect protocol implementation for structs it is possible to filter or mask sensitive fields. It is also possible to use a [@derive annotation](https://hexdocs.pm/elixir/Inspect.html#module-deriving) before the struct definition, selecting the fields that should be included or excluded when the struct is inspected.

For [GenServer](https://hexdocs.pm/elixir/GenServer.html), [:gen_event](https://erlang.org/doc/man/gen_event.html) or [:gen_statem](https://erlang.org/doc/man/gen_statem.html) processes, implementing the [format_status/2 callback](https://hexdocs.pm/elixir/GenServer.html#c:format_status/2) controls how the internal state is represented by introspection tools, such as ‘observer’. If the state is a map, for example, the function could mask the values for certain keys.

## ETS tables

ETS tables can be declared as ‘private’, preventing the table from being read by other processes, such as remote shell sessions. Private tables are also not visible in ‘observer’.

## Processes

Finally, a process can be marked as ‘sensitive’, using [erlang:process_flag/2](https://erlang.org/doc/man/erlang.html#process_flag-2). This has the following effect:

* Message queue contents cannot be introspected, and is not written to a crash dump
* Process dictionary cannot be introspected, and is not written to a crash dump
* Process state of a gen_server, gen_event or gen_statem process cannot be introspected, and is not written to a crash dump
* Process heap and stack are not written to a crash dump
* The process cannot be traced

Of course the downside is that it may be difficult to troubleshoot issues in sensitive processes. So instead of hiding significant portions of an application’s business logic in sensitive processes, consider wrapping operations that use sensitive data into a short-lived sensitive process, and keeping code complexity in that process to a minimum.

See also the section [Crash dumps and core dumps](crash_dumps) in the
[Deployment hardening chapter](deployment_hardening).
