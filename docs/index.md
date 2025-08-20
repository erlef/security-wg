---
layout: home
---

Here you can find documents and other resources produced by the Security WG of the [Erlang Ecosystem Foundation](https://erlef.org).

We welcome feedback and suggestions, especially to public drafts: please open an issue or PR through our [GitHub repo](https://github.com/erlef/security-wg). You can reach out to members of the working group through the [#security](https://the-eef.slack.com/archives/CTP7P1E9X) channel at the [EEF Slack workspace](https://erlef.org/slack-invite/erlef), or via email at security (at) erlef (dot) org.

## Documents

* [Secure Coding and Deployment Hardening Guidelines](secure_coding_and_deployment_hardening)
* [Web Application Security Best Practices for BEAM languages](web_app_security_best_practices_beam)
* [Security Vulnerability Disclosure](security_vulnerability_disclosure)
* [Meeting Notes](https://erlangforums.com/t/security-working-group-minutes/3451)

## Specifications

* 'hex' Package URL type
    * Part of [Hex specifications](https://github.com/hexpm/specifications/blob/master/package-url.md)
* ['otp' Package URL type](specs/otp_purl_type) (draft)

## Initiatives

* [Ægis Supply Chain Security & Compliance Initiative](aegis)
* [Erlang Ecosystem Foundation CNA](https://cna.erlef.org)

<section aria-labelledby="latest-articles">
    <header class="d-flex justify-content-between align-items-center mb-4">
        <h2 id="latest-articles" class="mb-0">Latest Articles</h2>
        <a href="{{ '/articles/' | relative_url }}" class="btn btn-link">View all</a>
    </header>

    <div class="container">
        <div class="row">
            {% assign reversed_articles = site.articles | reverse %}
            {% for article in reversed_articles limit:3 %}
                <div class="col-12 col-md-6 col-lg-4 d-flex">
                    {% include article-teaser.html article=article forloop=forloop %}
                </div>
            {% endfor %}
        </div>
    </div>
</section>