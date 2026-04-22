---
layout: page
title: Community Support
description: Community members supporting the Ægis Initiative
---

The signers of this statement indicate their support for the [Ægis Initiative](.) and
the Erlang Ecosystem Foundation [EEF] in their efforts to enhance and harden the
BEAM ecosystem's package infrastructure and software supply chain. Furthermore, as
package publishers and/or consumers, we will adopt the forthcoming practices and
tooling. We will also engage in the continued development and maintenance of its
goals.

Ægis aims to elevate ecosystem-wide security, standards compliance and trust
through transparency in supply chain, secure publishing, best-in-class tools,
continuous vulnerability management, improved embedded and enterprise toolchains,
community governance, and broad adoption across the ecosystem.

These advancements will reduce overall operational risk, reinforce open-source
sustainability and bolster industry confidence. The Erlang Ecosystem Foundation
organizes and coordinates these efforts, formulates governance structures to
sustain and advance them, and fosters broad community engagement.

We acknowledge that the measure of success will be long-term, broad community
participation and adoption. In these fast-moving times, the supply chain presents
diverse and evolving threat vectors — continuous enhancement and adaptation are
essential. The Ægis Initiative is our community's commitment to meeting that
challenge.

<style>
  .projects-columns {
    columns: 1;
    column-gap: 2rem;
  }
  @media (min-width: 540px) {
    .projects-columns { columns: 2; }
  }
  @media (min-width: 860px) {
    .projects-columns { columns: 3; }
  }
  .projects-columns .project-group {
    break-inside: avoid;
  }
  .projects-columns .project-group h3 {
    font-size: 1rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    color: #666;
    margin-top: 1.5rem;
  }

  .companies-list {
    list-style: none;
    padding: 0;
    display: flex;
    flex-wrap: wrap;
    gap: 1.5rem;
    align-items: center;
  }
  .companies-list img {
    max-height: 48px;
    max-width: 160px;
    width: auto;
    height: auto;
  }

  .people-columns {
    columns: 1;
    column-gap: 2rem;
  }
  @media (min-width: 540px) {
    .people-columns { columns: 2; }
  }
  @media (min-width: 860px) {
    .people-columns { columns: 3; }
  }
  .people-columns li {
    break-inside: avoid;
  }
  .people-columns .affiliation {
    font-size: 0.85em;
    color: #666;
  }

  .statements-list {
    list-style: none;
    padding: 0;
    columns: 1;
    column-gap: 2rem;
  }
  @media (min-width: 860px) {
    .statements-list { columns: 2; }
  }
  .statements-list li {
    break-inside: avoid;
    margin-bottom: 2rem;
  }
  .statements-list blockquote {
    margin: 0.25rem 0 0;
    padding: 0.75rem 1rem;
    border-left: 4px solid #dee2e6;
    color: #444;
    font-style: italic;
  }
  .statements-list .attribution {
    font-weight: bold;
  }
  .statements-list .attribution .affiliation {
    font-weight: normal;
    font-size: 0.85em;
    color: #666;
  }
</style>

## Companies <span style="font-size: 0.6em; font-weight: normal; color: #666;">({{ site.data.aegis_community_companies.companies | size }})</span>

<ul class="companies-list">
  {% for company in site.data.aegis_community_companies.companies %}
    <li>
      {% if company.logo %}
        <img src="{{ company.logo }}" alt="{{ company.name }}" title="{{ company.name }}" />
      {% else %}
        {{ company.name }}
      {% endif %}
    </li>
  {% endfor %}
</ul>

## Projects <span style="font-size: 0.6em; font-weight: normal; color: #666;">({{ site.data.aegis_community_projects.projects | size }})</span>

<div class="projects-columns">
  <div class="project-group">
    <h3>Hex Packages</h3>
    <ul>
      {% for project in site.data.aegis_community_projects.projects %}
        {% if project.type == "hex" %}
          <li><a href="{{ project.url }}">{{ project.name }}</a></li>
        {% endif %}
      {% endfor %}
    </ul>
  </div>
  <div class="project-group">
    <h3>GitHub Repositories</h3>
    <ul>
      {% for project in site.data.aegis_community_projects.projects %}
        {% if project.type == "github" %}
          <li><a href="{{ project.url }}">{{ project.repo }}</a></li>
        {% endif %}
      {% endfor %}
    </ul>
  </div>
  <div class="project-group">
    <h3>Other</h3>
    <ul>
      {% for project in site.data.aegis_community_projects.projects %}
        {% if project.type == "other" %}
          <li><a href="{{ project.url }}">{{ project.label }}</a></li>
        {% endif %}
      {% endfor %}
    </ul>
  </div>
</div>

## People <span style="font-size: 0.6em; font-weight: normal; color: #666;">({{ site.data.aegis_community_people.people | size }})</span>

<ul class="people-columns">
  {% for person in site.data.aegis_community_people.people %}
    <li>
      {{ person.name }}
      {% if person.companies.size > 0 %}
        <br><span class="affiliation">
          {% for slug in person.companies %}
            {% assign company = site.data.aegis_community_companies.companies | where: "slug", slug | first %}
            {% if company %}{{ company.name }}{% unless forloop.last %}, {% endunless %}{% endif %}
          {% endfor %}
        </span>
      {% endif %}
    </li>
  {% endfor %}
</ul>

## Statements <span style="font-size: 0.6em; font-weight: normal; color: #666;">({{ site.data.aegis_community_statements.statements | size }})</span>

<ul class="statements-list">
  {% for statement in site.data.aegis_community_statements.statements %}
    <li>
      <div class="attribution">
        {{ statement.person }}
        {% assign has_affiliation = false %}
        {% if statement.company %}
          {% assign company = site.data.aegis_community_companies.companies | where: "slug", statement.company | first %}
          {% if company %}
            <span class="affiliation">— {{ company.name }}</span>
            {% assign has_affiliation = true %}
          {% endif %}
        {% endif %}
        {% for url in statement.projects %}
          {% assign project = site.data.aegis_community_projects.projects | where: "url", url | first %}
          {% if project %}
            <span class="affiliation">—
              {% if project.type == "hex" %}<a href="{{ project.url }}">{{ project.name }}</a>
              {% elsif project.type == "github" %}<a href="{{ project.url }}">{{ project.repo }}</a>
              {% else %}<a href="{{ project.url }}">{{ project.label }}</a>
              {% endif %}
            </span>
            {% assign has_affiliation = true %}
          {% endif %}
        {% endfor %}
        {% unless has_affiliation %}<span class="affiliation">— Personal</span>{% endunless %}
      </div>
      <blockquote>{{ statement.text }}</blockquote>
    </li>
  {% endfor %}
</ul>

---

<small>Want to add your name, company, or project? Pull requests are welcome on
<a href="https://github.com/erlef/security-wg">erlef/security-wg</a>.</small>
