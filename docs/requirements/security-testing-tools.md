# Security testing tools

Use these tools for a full review when relevant and available. Repeated or
overlapping checks are intentional: compare results and investigate
disagreements. Tools can miss issues and produce false positives. Neither
an installed tool nor a clean scan proves a requirement is satisfied.

| Tool | Review purpose | When relevant |
|---|---|---|
| Strix | Agent-led security assessment and vulnerability validation | Authorized apps, APIs and code |
| PentAGI | Independent agent-led security assessment | Authorized apps, APIs and code |
| ZAP | Dynamic website and API security checks | Running web applications and APIs |
| Nuclei | Template-based vulnerability and configuration checks | Authorized running services |
| Gitleaks | Secrets in files and Git history | Source repositories; include available history |
| Trivy | Dependency, container, configuration and secret checks | Supported dependencies, images or configurations |
| OSV-Scanner | Independent known-vulnerability check for dependencies | Supported dependency lockfiles or SBOMs |
| Opengrep | Source-code security pattern analysis | Supported source languages |
| Semgrep | Independent source-code security analysis | Supported source languages |
| k6 | Controlled performance, abuse and rate-limit tests | Running backends or protected endpoints |

Strix's sandbox may include ZAP, Nuclei, Gitleaks, Trivy and Opengrep. An
agent must record the tool that actually ran and its results; do not count a
tool merely because it is installed or included in a container. An independent
run or a different tool can provide a second opinion; record what was repeated
and compare findings. For rate limits, test valid traffic and authorized
bursts, expected 429 responses and recovery; never assume a static scan proved
the limiter works. Use representative users, roles and input cases.

Scope active and load tests to authorized targets, preferably local or staging.
Keep test traffic bounded and do not expose real user data or credentials in
reports. Before sending source, secrets, findings or data to a hosted service
or external model, verify the provider, permissions, privacy terms and cost.
Check license and usage terms, version and configuration; do not assume a
tool or hosted service is free. Record each tool as RUN, UNAVAILABLE, BLOCKED,
or N/A with its reason, target, version, evidence, outcome and next step.
Install or configure only within the user's authorization and available
environment. Fix confirmed findings and retest. Do not conceal unrun checks.

Sources: [Strix sandbox](https://docs.strix.ai/tools/sandbox),
[PentAGI](https://github.com/vxcontrol/pentagi),
[ZAP](https://www.zaproxy.org/docs/desktop/start/),
[Gitleaks](https://github.com/gitleaks/gitleaks),
[OSV-Scanner](https://google.github.io/osv-scanner/),
[k6](https://grafana.com/docs/k6/latest/using-k6/thresholds/).
