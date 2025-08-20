---
publication_url: "https://paraxial.io/blog/elixir-rce"
title: "Elixir/Phoenix Security: Remote Code Execution and Serialisation"
publisher: "Paraxial.io"
publication_date: "2023-02-28"
---

This post shows how unsafe use of `:erlang.binary_to_term/2` (even with `:safe`)
can enable remote code execution in Elixir/Phoenix apps, demonstrates a real
Paginator exploit that deserializes attacker-supplied functions, and gives
practical fixes — use `non_executable_binary_to_term/2`, run Sobelow scans, and
follow secure serialization guidance to prevent RCE.
