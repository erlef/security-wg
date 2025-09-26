---
layout: page
title: Ægis Initiative
description: Supply Chain Security & Compliance Initiative
---

## Objectives

1. **Elevate Ecosystem-Wide Security**
    
    Establish a strong, foundational security posture that benefits every user
    of BEAM languages and tools, regardless of their organization’s size.
    
2. **Streamline Compliance Readiness**
    
    Ensure that projects and maintainers can easily meet or exceed emerging
    global regulations (e.g., EU CRA, NIST SSDF) through built-in security
    features and best practices.
    
3. **Foster Trust and Transparency**
    
    Implement mechanisms like event transparency logs and verifiable package
    provenance to create an auditable trail that builds user confidence in the
    ecosystem.
    
4. **Democratize Advanced Security**
    
    Provide user-friendly libraries and tools (e.g., cosign, SLSA, SCITT) so
    that smaller teams without dedicated security resources can adopt
    best-in-class protections.
    
5. **Enable Secure Publishing Workflows**
    
    Protect package maintainers and end-users by deploying robust authentication
    (passkeys, MFA) and replacing exposed API keys with safer, tokenless
    publication methods.
    
6. **Empower Continuous Vulnerability Management**
    
    Integrate automated vulnerability scanning and reporting into build and
    install processes, making security awareness accessible to every developer.
    
7. **Support Sustainable Maintenance**
    
    Offer stipends, guidance, and community collaboration so maintainers and
    contributors have the resources needed to keep security features robust and
    up to date.
    
8. **Enhance Embedded & Enterprise Integration**
    
    Develop toolchains (e.g., Yocto integration, BOM generation) that ease the
    adoption of BEAM-based applications in embedded and heavily regulated
    environments.
    
9. **Cultivate Long-Term Funding & Governance**
    
    Transition from single large grants to a diversified funding
    model—attracting industry sponsorships and broad community support to ensure
    financial stability.
    
10. **Promote Ecosystem Growth & Adoption**
    
    Demonstrate how open source security capabilities drive broader adoption of
    BEAM technologies, thereby strengthening the community through shared
    innovation and best practices.

## Roadmap

<div class="table-responsive">
  <table class="table table-striped table-bordered">
    <thead class="thead-dark">
      <tr>
        <th scope="col">Name</th>
        <th scope="col">Area</th>
        <th scope="col">Status</th>
        <th scope="col">Sponsors</th>
      </tr>
    </thead>
    <tbody>
      {% assign milestones = site.pages | where: "is_aegis_milestone", true | sort: "index" %}
      {% for milestone in milestones %}
        <tr>
          <th scope="row">
            <a href="{{ milestone.url }}">
              {{ milestone.title }}
            </a>
          </th>
          <td>{{ milestone.area }}</td>
          <td>
            {{ milestone.status }}
            {% if milestone.status == "In Progress" %}
              ({{ milestone.progress }}%)
            {% endif %}
          </td>
          <td>
            {% if milestone.funding_required %}
              <p>
                <em>More Funding Required</em>
              </p>
            {% endif %}
            {% if milestone.sponsors %}
              <ul class="randomize-order">
                {% for sponsor in milestone.sponsors %}
                  <li>
                    {{ sponsor }}
                  </li>
                {% endfor %}
              </ul>
            {% endif %}
          </td>
        </tr>
      {% endfor %}
    </tbody>
  </table>
</div>


## Progress Updates

* [EEF Security Update 2025 Q3](/assets/aegis/updates/2025-q3.pdf)

## Funding

Achieving the objectives and milestones on our roadmap requires external
funding. We welcome contributions in various forms. If you’d like to support
this initiative, please contact us at [sponsorship@erlef.org](mailto:sponsorship@erlef.org).
Sponsorship can be provided through:

1. **Financial Contributions**
    - Directly fund key activities such as security audits, engineering work,
      and stipends for maintainers.
    - Support can be one-time or recurring, depending on your preference.
2. **In-Kind Contributions (Manpower)**
    - Offer developer time, security expertise, or other specialized skill sets
      to help implement features, review code, or audit progress.
    - Enables direct collaboration on critical tasks while also shaping the
      future of the ecosystem.

## Sponsors

<div class="sponsors randomize-order mb-5">
  <a href="https://www.ericsson.com/">
    <img src="/assets/aegis/sponsors/ericsson.svg" alt="Ericsson" />
  </a>
  <a href="https://www.herrmannultraschall.com/">
    <img src="/assets/aegis/sponsors/herrmann-ultraschall.svg" alt="Herrmann Ultraschall" />
  </a>
  <a href="https://dashbit.co/">
    <img src="/assets/aegis/sponsors/dashbit.png" alt="Dashbit" />
  </a>
  <a href="https://hcahealthcare.com/">
    <img src="/assets/aegis/sponsors/hca.png" alt="HCA Healthcare" />
  </a>
</div>


## Implementation

The initiative is designed to accommodate multiple pathways for contributing new
security features and improvements. Regardless of the approach, all work is
guided and reviewed by the EEF Security Working Group and the EEF CISO to ensure
consistency, quality, and adherence to our strategic roadmap. Here are the
primary ways implementation can happen:

1. **Internal EEF Resources**
    
    The EEF can allocate its own staff and experts (including the CISO) to
    implement features directly.
    
2. **Stipends for External Contributors**
    
    The EEF can fund stipends or grants for developers, maintainers, or other
    specialists in the community.
    
3. **Sponsor-Provided Implementation**
    
    A sponsor may opt to contribute manpower directly, having their own team or
    contractors develop and integrate new capabilities.
