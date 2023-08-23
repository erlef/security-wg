---
title: Common Web Application Vulnerabilities
layout: page_with_toc
previous:
  url: index
  title: Contents
next:
  url: session_management_vulnerabilities
  title: Session Management Vulnerabilities
seo_keywords:
  - xss
  - javascript
  - phoenix
  - content security policy
  - alpine.js
  - CSWSH
  - sql injection
  - dos
  - common vulnerabilities
---

In addition to being a valuable tool for the Elixir ecosystem as a whole, the
static analysis tool [Sobelow][gh:sobelow] is highly recommended to detect common
vulnerabilities particularly in Phoenix projects. Griffin Byatt, the creator of
Sobelow, [gave an ElixirConf][sobelow_conf] talk on this subject when the tool
debuted - speaking more on how it works under the hood.

While Sobelow to this day remains an excellent tool for Elixir developers to
leverage while developing locally; it is recommended that Sobelow be
additionally implemented in the CI/CD pipeline scanning code as it gets merged
to the main branch. While we won’t go into detail how to set that process up
here, it can be accomplished in a number of ways; whether through GitHub Actions
or Docker images executing on CI runners.

The [`put_secure_browser_headers` Plug][hexdoc:phoenix.put_secure_browser_headers],
included in the “browser” pipeline in Phoenix routers by default, provides some
basic protections against a number of web application vulnerabilities. The exact
list of headers changes from one version of Phoenix to another, so please refer
to the latest documentation for details on which headers are being set and what
they protect against.

## Cross Site Scripting (XSS)

Phoenix provides strong guard rails to prevent XSS by default. When rendering
user input as HTML, be aware of the following:

1. The [`Phoenix.HTML.raw/1`][hexdoc:phoenix.html_raw] function. If user input is being
   passed to this function, the application is vulnerable to XSS.
1. The [`Phoenix.Controller.html/2`][hexdoc:phoenix.controller_html] function. For
   example, in a Phoenix controller the following is vulnerable:

```elixir
def html_resp(conn, %{"i" => i}) do
  html(conn, "<html><head>#{i}</head></html>")
end
```

1. Similar to the above example, constructed via a pipeline:

```elixir
def send_resp_html(conn, %{"i" => i}) do
  conn
  |> put_resp_content_type("text/html")
  |> send_resp(200, "#{i}")
end
```

1. File upload functionality can lead to XSS if the content-type of the server
   response is being set by the user. Consider a Phoenix application that renders
   an uploaded file with the following:

```elixir
def view_photo(conn, %{"filename" => filename}) do
  case ImgServer.get(filename) do
    %{content_type: content_type, bin: bin} ->
      conn
      |> put_resp_content_type(content_type)
      |> send_resp(200, bin)
    _ ->
      conn
      |> put_resp_content_type("text/html")
      |> send_resp(404, "Not Found")
  end
end
```

A malicious user could sent the content_type to `text/html`, and upload an HTML
document that executes JavaScript. When this file is viewed by a victim, the
XSS payload executes in the victim web browser.

**Further Reading:**

- [Cross Site Scripting (XSS) Patterns in Phoenix][paraxial:xss_phoenix]

### Content Security Policy

Content Security Policy (CSP) is a security feature that can be implemented on web applications to prevent certain types of attacks, such as cross-site scripting (XSS) and data injection attacks. CSP helps protect web applications by defining a whitelist of trusted sources for the content that the application can load or execute.

If someone is unfamiliar with web security and is using the Phoenix Elixir web framework, it is essential to understand the potential security risks that their application may face. With CSP, the developer can define a set of policies that restrict the types of resources that the application can load or execute. These policies include allowing only specific sources of images, scripts, stylesheets, fonts, and plugins.

Using Content Security Policy in the Phoenix Elixir web framework is a crucial security feature that helps protect web applications from various types of attacks. By restricting the sources of content that the application can load or execute, developers can reduce the risk of security vulnerabilities and ensure the safety of their users.

To learn more about Content Security Policy, see: [https://content-security-policy.com/](https://content-security-policy.com/)

To help create policies, see: [https://report-uri.com/home/generate](https://report-uri.com/home/generate)

#### Setup without external Dependencies

For a very simple setup, no external dependencies are required. If you need a more complicated setup including nonces etc, please refer to the next section.

Supply the following option to the
[`put_secure_browser_headers` Plug][hexdoc:phoenix.put_secure_browser_headers]:

```elixir
plug :put_secure_browser_headers, %{
"content-security-policy": "[Your Policy]"
}
```

#### Setup using [plug_content_security_policy][hex:plug_content_security_policy]

plug_content_security_policy is a small library to aid configuring content
security policies correctly. On top of just generating the header, it also helps
with generating [nonces][csp_nonces].

To use plug_content_security_policy, install the dependency and add the plug to
your router or endpoint. For all available options, see:
[https://github.com/xtian/plug_content_security_policy#usage](https://github.com/xtian/plug_content_security_policy#usage)

```elixir
plug PlugContentSecurityPolicy,
 nonces_for: [
  :style_src,
   # ...
 ],
 directives: %{
   script_src: ~w(https: 'self'),
   # ...
 }
```

#### Using [phoenix_live_dashboard][hex:phoenix_live_dashboard] with a CSP

Phoenix Live Dashboard supports running with a restrictive Content Security Policy. To use it with a CSP, nonces have to be used. To do this, the nonces have to be set on the plug connection assigns. If you use plug_content_security_policy, the nonces will be set automatically if enabled via `nonces_for`.

For detailed configuration options, see:
[`Phoenix.LiveDashboard.Router.html.live_dashboard/2`][hexdoc:phoenix_live_dashboard.live_dashboard]

```elixir
live_dashboard "/",
  metrics: {AcmeTelemetry, :metrics},
  csp_nonce_assign_key: %{
    img: :img_src_nonce,
    style: :style_src_nonce,
    script: :script_src_nonce
  }
```

#### Alpine.js

A popular stack used in the Elixir ecosystem to create fully functional
server-side web experiences is the PETAL stack - **P**hoenix, **E**lixir,
**T**ailwind, **A**lpine.js, **L**iveview. While using this technology stack,
developers can almost entirely forgo the usage of JavaScript when building their
applications. Unfortunately at this point in time, there is still a requirement
to use some amount of JavaScript in order to build to the modern web - this is
usually accomplished via Alpine.js.

As outlined in the Alpine.js developer documentation, “In order for Alpine to be
able to execute plain strings from HTML attributes as JavaScript expressions,
for example `x-on:click="console.log()"`, it needs to rely on utilities that
violate the ‘unsafe-eval’ content security policy.

Under the hood, Alpine doesn't actually use `eval()` itself because it's slow
and problematic. Instead it uses Function declarations, which are much better,
but still violate `unsafe-eval`.

In order to accommodate environments where this CSP is necessary, Alpine will
offer an alternate build that doesn't violate `unsafe-eval`, but has a more
restrictive syntax.

At the time of writing, the Alpine.js project has **not** yet released the
aforementioned alternate build that is more restrictive - leaving it up to the
developers to either develop around this limitation or build their own version
of Alpine.js from the source code.

## Cross Site Request Forgery (CSRF)

Cross site request forgery (CSRF) is a type of vulnerability in web
applications, where an attacker is able to forge commands from a victim user.
For example, consider a social media website that is vulnerable to CSRF. An
attacker creates a malicious website aimed at legitimate users. When a victim
visits the malicious site, it triggers a POST request in the victim’s browser,
sending a message that was written by the attacker. This results in the victim’s
account making a post written by the attacker.

Phoenix protects against CSRF by default, through a combination of the
`protect_from_forgery` plug, and the CSRF token included in form helpers. Forms
generated by Phoenix include a hidden input named `_csrf_token`, which is
included in the state changing HTTP request. Sobelow includes a check,
“UID 5, Config.CSRF: Missing CSRF Protections”, which alerts on router pipelines
missing the `protect_from_forgery` plug.

Sobelow also includes a check for “CSRF via Action Reuse”. The typical
description of CSRF involves a POST request being triggered without a secure
token. If there’s a state changing HTML form making a POST, with a CSRF token,
that’s validated by the server, that should be secure. Consider a web
application where both a GET and POST request can perform the same state
changing action. This is likely not the developer’s intention, but that is the
root of most security problems in software.
For example:

```elixir
get "/users", UserController, :new
post "/users", UserController, :new
```

In this instance, it may be possible to trigger the POST functionality with a
`GET` request and query parameters.

**Further reading:**

- [Elixir/Phoenix Security: What is CSRF via Action Reuse?][paraxial:action_reuse_csrf]
- [Elixir/Phoenix Security: Introduction to Cross Site Request Forgery (CSRF)][paraxial:csrf_intro]

## Cross-Site WebSocket Hijacking (CSWSH)

A cross-site WebSocket hijacking attack is very similar to a CSRF attack, but it
aims to establish a WebSocket connection rather than trigger a classical HTTP
request. If successful, the attacker obtains a bidirectional channel with the
server in the context of a victim’s session. The extent of the damage the
attacker can do depends on the functionality exposed via the WebSocket, but it
could potentially allow the attacker to take full control over the user’s
account and extract private information.

To protect against CSWSH, Phoenix applies CSRF protections when the socket is
configured to expose the session through the
[`connect_info`][hexdoc:phoenix.socket_connect_info] mechanism. If the CSRF
token does not match, as would be expected in a cross-origin scenario, the
session contents is ignored and the socket’s connect callback receives an empty
(`nil`) session instead. Any session-based authentication logic should therefore
fail, presumably blocking the CSWSH attack.

Note, however, that the CSRF token verification does not block the connection
itself: it only applies when session information is requested, and it is the
responsibility of the connect callback to close the connection when
authentication fails. Phoenix provides another mechanism to automatically block
connection attempts based on the browser’s `Origin` header.

The [`socket`][hexdoc:phoenix.socket] Endpoint function accepts a
`check_origin` parameter to configure which origin values are allowed. By default
it uses the value from the
[Endpoint configuration][hexdoc:phoenix.endpoint_configuration], which in turn
defaults to `true`, allowing WebSocket connections only if the origin matches
the Endpoint’s configured hostname.

If the socket is intended to be used in a cross-origin context or from outside a
browser it may be necessary to disable the origin check (`check_origin: false`).
In that case make sure the connection authentication is based on a token passed
through a query parameter rather than cookies.

See also [Session lifecycle and WebSocket connections](session_management_vulnerabilities#session-lifecycle-and-websocket-connections)

## SQL Injection

Preventing SQL Injection in Elixir/Phoenix/Ecto applications

1.  Use Ecto to build queries. The library has very strong SQL injection
    prevention.
    1. SQL injection vulnerabilities are introduced through the “escape hatch”
       provided by Ecto via `Ecto.Query.API.fragment/1` or the `Ecto.Adapters.SQL`
       functions that allow raw SQL input.
1.  Even if you use fragment and are interpolating user input, Ecto will throw an
    error and warn you. For example:
    ```elixir
    query =
      from f in Fruit,
      where: fragment("f0.name = #{name} AND f0.secret = FALSE")
    ```
    ```console
    ** (Ecto.Query.CompileError) to prevent SQL injection attacks, fragment(...) does not allow strings to be interpolated as the first argument via the `^` operator, got: `"f0.name = #{name} AND f0.secret = FALSE"`
    ```
1.  It is possible to bypass the above warning using macros. If the fragment is
    constructed with user-supplied input, you will introduce a SQL injection
    vulnerability.
1.  [Ecto vectors for SQL injection][github:sobelow#2]:
    - `Repo.query`
    - `Repo.query!`
    - `Repo.query_many`
    - `Repo.query_many!`
    - `Ecto.Adapters.SQL.query`
    - `Ecto.Adapters.SQL.query!`
    - `Ecto.Adapters.SQL.query_many`
    - `Ecto.Adapters.SQL.query_many!`
    - `Ecto.Adapters.SQL.stream`
1.  When auditing a codebase for these functions, remember a call to
    `Ecto.Adapters.SQL.query` may be shortened to just `query` via an Elixir
    import statement.
1.  It is possible to use the above APIs safely, if the query input is provided
    via parameters. For example:
    [https://elixirforum.com/t/ecto-adapters-sql-query-for-sql-query-leads-to-sql-injection-attack/34678/2][elixirforum:ecto_sql_injection]
    1. Safe:
       1. `Ecto.Adapters.SQL.query(Repo, "SELECT $1", [input_a])`
    2. Unsafe:
       1. `Ecto.Adapters.SQL.query(Repo, "SELECT #{input_a}"")`
    3. Unsafe:
       1. `q = "SELECT" <> input_a`
       2. `Ecto.Adapters.SQL.query(Repo, q)`

**Further Reading:**

- [Detecting SQL Injection in Phoenix with Sobelow][paraxial:sql_injection]

## Denial of Service (DoS)

### Atom Exhaustion

Phoenix applications are inherently robust, because they are created with
Elixir, running on Erlang’s virtual machine (BEAM). The biggest denial of
service (DoS) risk to a Phoenix application is atom exhaustion. This occurs when
user input to a Phoenix application results in the creation of new atoms.

The Security Working Group of the Erlang Ecosystem Foundation publishes a
[guide to prevent atom exhaustion](../secure_coding_and_deployment_hardening/atom_exhaustion).

The recommendations for Elixir are:

1. Use `String.to_existing_atom/1` instead of `String.to_atom/1`
1. Use `List.to_existing_atom/1` instead of `List.to_atom/1`
1. Use `Module.safe_concat/1,2` instead of `Module.concat/1,2`
1. Do not use interpolation to create atoms:
   1. `:"new_atom_#{index}"`
   1. `:'new_atom_#{index}'`
   1. `~w[row_#{index} column_#{index}]a`
1. Use the `:safe`option when calling `:erlang.binary_to_term/2` on untrusted
   input (see also Serialisation and deserialisation)

**Further reading:**

- [Elixir/Phoenix Security: Denial of Service Due to Atom Exhaustion][paraxial:atom-dos]

### Application Layer (Layer 7) Attacks

If your Phoenix application allows users to perform a computationally expensive
operation, which could be used by an attacker for a denial of service attack, it
is recommended you rate limit the function. There are several open source Elixir
libraries for this:

- [PlugAttack][hex:plug_attack]
- [Hammer][hex:hammer]
- [Ex_rated][hex:ex_rated]

The usage of such libraries should be implemented according to their respective
best practices that also align with expected usage limits of your application.
For example, it is strongly encouraged to implement rate limiting on a user
login function at a rate that a normal user who is having difficulty logging in
would not be penalized yet would still prevent a malicious user from brute
forcing the users password.

#### Web Application Firewalls

While many DoS attacks can be mitigated through techniques such as rate
limiting, avoiding exposing computationally expensive functionality, and
leveraging Elixir’s full concurrency model - it is worth mentioning that some
Distributed Denial of Service (DDoS) attacks can only be mitigated through more
appropriate Web Application Firewalls deployed in front of your application.

## Client-side enforcement of server-side security

Access controls should always be enforced by the server: it is not enough to
hide a “Delete” button from users who do not have permission to delete a
resource if the underlying route is not also checking the user’s permissions.
Similarly, it is not enough to restrict a list of resources in an index page to
only include links to resources the user should be able to access, when a simple
change in the identifier in a resource’s URL exposes arbitrary resources.

This is also true for Single Page Applications (SPAs), in which much of the
application logic is implemented in the browser: the server that implements the
API that allows the client-side code to retrieve and update resources should
implement the necessary access controls based on the current user’s permissions.

In a LiveView application it is just a little bit harder to see where these server-side access controls should be implemented. The
[LiveView guide on security][hexdoc:phoenix_live_view.security_model_content]
does stress the importance of verifying permissions on the server in the
[section on events][hexdoc:phoenix_live_view.security_model_events].

So for instance, when the “delete” action’s availability depends on the user’s
permissions, and is hidden accordingly…

<!-- raw required for double brackets -->

{% raw %}

```heex
<:action :let={{id, post}}>
  <.link
      phx-click={JS.push("delete", value: %{id: post.id}) |> hide("##{id}")}
      data-confirm="Are you sure?"
      :if={allow_delete?(post, @current_user)}
  >
    Delete
  </.link>
</:action>
```

{% endraw %}

…then don’t forget to also implement the permission check in the associated
event handler:

```elixir
@impl true
def handle_event("delete", %{"id" => id}, socket) do
  post = Blog.get_post!(id)
  if allow_delete?(post, socket.assigns[:current_user]) do
    {:ok, _} = Blog.delete_post(post)

    {:noreply, stream_delete(socket, :posts, post)}
  else
    Logger.warn("Unauthorized blog post delete request!")
    {:noreply, socket}
  end
end
```

[csp_nonces]: https://content-security-policy.com/nonce/
[elixirforum:ecto_sql_injection]: https://elixirforum.com/t/ecto-adapters-sql-query-for-sql-query-leads-to-sql-injection-attack/34678/2
[gh:sobelow]: https://github.com/nccgroup/sobelow
[github:sobelow#2]: https://github.com/nccgroup/sobelow/issues/2
[hexdoc:phoenix.controller_html]: https://hexdocs.pm/phoenix/Phoenix.Controller.html#html/2
[hexdoc:phoenix.endpoint_configuration]: https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#module-endpoint-configuration
[hexdoc:phoenix.html_raw]: https://hexdocs.pm/phoenix_html/Phoenix.HTML.html#raw/1
[hexdoc:phoenix_live_dashboard.live_dashboard]: https://hexdocs.pm/phoenix_live_dashboard/Phoenix.LiveDashboard.Router.html#live_dashboard/2
[hexdoc:phoenix_live_view.security_model_content]: https://hexdocs.pm/phoenix_live_view/security-model.html#content
[hexdoc:phoenix_live_view.security_model_events]: https://hexdocs.pm/phoenix_live_view/security-model.html#events-considerations
[hexdoc:phoenix.put_secure_browser_headers]: https://hexdocs.pm/phoenix/Phoenix.Controller.html#put_secure_browser_headers/2
[hexdoc:phoenix.socket_connect_info]: https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#socket/3-connect-info
[hexdoc:phoenix.socket]: https://hexdocs.pm/phoenix/Phoenix.Endpoint.html#socket/3
[hex:ex_rated]: https://github.com/grempe/ex_rated
[hex:hammer]: https://github.com/ExHammer/hammer
[hex:phoenix_live_dashboard]: https://hex.pm/packages/phoenix_live_dashboard
[hex:plug_attack]: https://github.com/michalmuskala/plug_attack
[hex:plug_content_security_policy]: https://hex.pm/packages/plug_content_security_policy
[paraxial:action_reuse_csrf]: https://paraxial.io/blog/action-reuse-csrf
[paraxial:atom-dos]: https://paraxial.io/blog/atom-dos
[paraxial:csrf_intro]: https://paraxial.io/blog/csrf-intro
[paraxial:sql_injection]: https://paraxial.io/blog/sql-injection
[paraxial:xss_phoenix]: https://paraxial.io/blog/xss-phoenix
[sobelow_conf]: https://www.youtube.com/watch?v=w3lKmFsmlvQ
