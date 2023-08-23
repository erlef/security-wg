---
title: Session Management Vulnerabilities
layout: page_with_toc
previous:
  url: common_web_application_vulnerabilities
  title: Common Web Application Vulnerabilities
next:
  url: tls_vulnerabilities
  title: TLS Vulnerabilities
seo_keywords:
  - session vulnerabilities
  - session hijacking
  - information leakage
---

For background information on the security requirements for web application
session management, check out the
[OWASP Session Management Cheat Sheet][owasp_session_management_cheatsheet].

## No server-side session revocation

The default session management for a new Plug/Phoenix application typically uses
the [cookie session store][hexdoc:plug.session_cookie]. With this session store
the session state is maintained entirely in the client’s browser: there is no
server-side session state, meaning the server cannot revokea session. Signing
out merely clears the session cookie in the client’s browser, but does not
invalidate the session cookie value.

In practice this means that a session cookie, once captured by an attacker, can
be injected into HTTP requests to resume the session at any time, even if the
user signed out afterwards. The only way to invalidate a session on the server
would be to rotate the signing key used to validate the session (the
`secret_key_base` and/or the `signing_salt`), but this would invalidate all
sessions of all clients.

Proper session management combines the client-side cookie with server-side
state. A common way of achieving this is to store the session contents in the
server’s database, identified by a random session identifier to be stored in the
cookie. The session can then be invalidated by deleting the record from the
database or marking it as invalid, for instance when the user signs out.

The `mix phx.gen.auth` task, included in recent Phoenix versions, uses a
slightly different approach, where the session contents is stored in the cookie
rather than the database, along with the session identifier (here called the
`session_token`, stored in the `user_tokens` table). The task generates
implementations for session lifecycle events, such as invalidating sessions on
sign-out and on password change.

## No server-side session timeout

A session may not always be explicitly invalidated: the user might forget to
sign out, or the browser might crash. It is important that such ‘orphaned’
sessions do not remain valid indefinitely. The server should therefore
invalidate old or idle sessions. Note that setting an expiry time on the session
cookie is not sufficient, as this only takes care of clearing the cookie in the
browser: it does not invalidate the session in the server.

This requires a server-side session store, as described above, with additional
fields for tracking the session creation timestamp and optionally the timestamp
the session was last used. Invalidation can then happen periodically through a
background task, or as a filter on these fields in the query that looks up a
session in the database.

The aforementioned `mix phx.gen.auth` task by default invalidates sessions after
60 days. It may be wise to reduce this interval and/or to add a mechanism to
invalidate sessions much sooner if they are found to be idle.

## Session leakage (session hijacking)

If a session cookie falls into the wrong hands, the attacker can take over the
user’s session, at least until the user or the server invalidates that session
(see [No server-side session revocation](#no-server-side-session-revocation)).
Browsers support several mechanisms for minimizing the risk of cookie leakage,
but these only really work when they are configured correctly on the server,
in particular:

- **HttpOnly** attribute - if enabled when setting a cookie, the cookie cannot
  be read using client-side (JavaScript) code, reducing the risk of session
  leakage through XSS vulnerabilities
- **Secure** attribute - if enabled when setting a cookie, the cookie is only
  transmitted when the connection to the server uses HTTPS (TLS), reducing the
  risk of session leakage by tricking the user into sending a request to a
  (non-existent) plain-HTTP URL for the server

The HttpOnly attribute is set by default by `Plug.Session` or when setting
cookies directly using `Plug.Conn.put_resp_cookie/4`. The Secure attribute is
set based when Plug believes the request was made over HTTPS. This means care
must be taken to ensure the conn struct correctly reflects the transport
protocol (see
[Misconfigured TLS offload](tls_vulnerabilities#misconfigured-tls-offload)).

## Session fixation

In a way, a session fixation attack is the opposite of session hijacking: the
attacker tricks the user into resuming a session that was started by the
attacker. Intuitively this may not seem like a big issue: why would the attacker
volunteer to have their session hijacked? However, session fixation can lead to
account compromise or information leakage.

The actual fixation attack usually involves tricking users into clicking a link
to a vulnerable site, which seeds the session with a session ID provided by the
attacker. But depending on the exact vulnerability, even “drive-by” session
fixation triggered by e.g. an image embedded in a public forum might be
possible.

The most dangerous session fixation vulnerabilities are those that start with
an “anonymous” session: some servers assign a session identifier even before a
user signs in, for instance for analytics purposes. An attacker might start such
an anonymous session, take the session identifier and trick a victim into taking
over that session. The user might then sign into the application with their user
credentials, upgrading the anonymous session to an authenticated session. If the
session identifier does not change as a result of the sign-in action, the
attacker can now use the original session cookie to take over the user’s
authenticated session and access the user’s data.

This attack can be mitigated by ensuring session identifiers are always rotated
when the session’s privilege level changes. The `Plug.Session` API provides the
`configure_session/2` function to request session identifier renewal. This
functionality needs to be provided by the session store implementation. The
session management implemented by `mix phx.gen.auth` provides the
`renew_session/1` function to rotate the session identifier, and the default
implementations for signing in/out call this function to prevent fixation.

Another fixation attack uses an already authenticated session, prepared by the
attacker, and aims to leak information by tricking the user into entering (or
uploading) the information into an account under the attacker’s control without
realizing it. This attack cannot be mitigated by session identifier rotation.

To fully protect against all session fixation attacks it is necessary to block
such attacks at the source.

The most common source is an endpoint that allows a session to be created from
request parameters, either in the request URL or in the request body. This is
typically done to enable external authentication servers (OAuth2, SAML, OIDC) to
redirect back to the relying application. These protocols all support a
server-generated nonce or state that must match the value returned in the
redirection, thus blocking session creation attempts that were not triggered by
the user. Make sure to study the mechanisms provided by the authentication
server and apply them correctly.

Another, less common source is HTTP header splitting: if a server sets an HTTP
response header with a value that contains user input, a malicious user may
attempt to inject a value that includes a newline (CR+LF characters), followed
by another HTTP header name/value pair. This would allow the attacker to send a
`Set-Cookie` header that appears to originate from the server itself. The
`Plug.Conn` APIs for setting response headers protect against this by
disallowing newline characters in HTTP response header values.

## Session information leakage

Storing data in the session cookie, or cookies in general, can reveal sensitive
information to the user. For instance, imagine a website that performs a credit
check on its users and stores the result in the session for later use: this
might reveal information that is not intended to be shared with the user.

The default cookie session store in Plug/Phoenix protects the integrity of the
session using a signature, meaning that the session contents is protected from
tampering, but it does not encrypt the session. The following code snippet can
be used by the user to inspect the contents of the session:

```elixir
cookie_value
|> String.split(".")
|> Enum.at(1)
|> Base.decode64!(padding: false)
|> :erlang.binary_to_term()
```

To protect the session contents from prying eyes, set the `encryption_salt`
parameter when invoking the `Plug.Session` plug, e.g. in the project’s Endpoint.
For other (non-session) cookies, pass the `encrypt: true` option when calling
`Plug.Conn.put_resp_cookie/4`.

## Session lifecycle and WebSocket connections

Whenever a user’s session is revoked, WebSocket connections that were
established as part of that session should be disconnected. The connection is
authenticated only once, at the start of the connection, and event handlers do
not (typically) check if the session is still active.

The `mix phx.gen.auth` task uses a per-user `users_sessions#{id}` channel for
this purpose, which each authenticated socket implicitly subscribes to. On user
sign-out a `disconnect` message is broadcast to the user session’s channel,
which causes the socket to be closed. A similar mechanism should be used when
building a custom authentication solution.

Remember to also disconnect sockets when the session is revoked by the server,
due to an overall session time expiry or due to inactivity. You may also have to
consider whether to reset the session inactivity timer as a result of socket
activity, perhaps only in response to explicitly user-triggered events.

[hexdoc:plug.session_cookie]: https://hexdocs.pm/plug/Plug.Session.COOKIE.html
[owasp_session_management_cheatsheet]: https://cheatsheetseries.owasp.org/cheatsheets/Session_Management_Cheat_Sheet.html
