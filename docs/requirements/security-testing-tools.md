# Security testing tools

Use these tools for a full review when relevant and available. Repeated or
overlapping checks are intentional: compare results and investigate
disagreements. Tools can miss issues and produce false positives. Neither
an installed tool nor a clean scan proves a requirement is satisfied.

| Tool and official repository | Review purpose | When relevant |
|---|---|---|
| [Strix](https://github.com/usestrix/strix) | Agent-led security assessment and vulnerability validation | Authorized apps, APIs and code |
| [PentAGI](https://github.com/vxcontrol/pentagi) | Independent agent-led security assessment | Authorized apps, APIs and code |
| [ZAP](https://github.com/zaproxy/zaproxy) | Dynamic website and API security checks | Running web applications and APIs |
| [Nuclei](https://github.com/projectdiscovery/nuclei) | Template-based vulnerability and configuration checks | Authorized running services |
| [Gitleaks](https://github.com/gitleaks/gitleaks) | Secrets in files and Git history | Source repositories; include available history |
| [Trivy](https://github.com/aquasecurity/trivy) | Dependency, container, configuration and secret checks | Supported dependencies, images or configurations |
| [OSV-Scanner](https://github.com/google/osv-scanner) | Independent known-vulnerability check for dependencies | Supported dependency lockfiles or SBOMs |
| [Opengrep](https://github.com/opengrep/opengrep) | Source-code security pattern analysis | Supported source languages |
| [Semgrep](https://github.com/semgrep/semgrep) | Independent source-code security analysis | Supported source languages |
| [k6](https://github.com/grafana/k6) | Controlled performance, abuse and rate-limit tests | Running backends or protected endpoints |

Ruler stores links and instructions only; do not vendor or install these tools
in the Ruler repository.

## Safety check before use

Before installing or running any tool, verify the official repository and
distribution channel independently, then inspect current maintainer security
advisories, recent supply-chain incidents, and the selected version's affected
and fixed ranges. Check the release provenance, signatures or checksums where
available against the official source; pin an identified safe artifact or
commit. Review the tool's dependencies, permissions, network access and any
external model or telemetry. Prefer an isolated environment and least privilege.
Record the review date, source, version, advisory links, evidence and unresolved
risk in the project report. If identity, integrity or a relevant critical risk
cannot be resolved, mark the tool BLOCKED and use another verified approach.
No repository review can prove a tool is harmless.

For example, Trivy's maintainers published a
[2026 supply-chain compromise advisory](https://github.com/aquasecurity/trivy/security/advisories/GHSA-69fq-xp46-6x23).
Do not assume every version or artifact is affected; check the advisory and
later advisories for the exact artifact, version and exposure window.
Nuclei also published a
[DAST template signature-bypass advisory](https://github.com/projectdiscovery/nuclei/security/advisories/GHSA-jpf4-98qj-qr67).
Review the selected version and template source before use.

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
Install or configure outside Ruler only within the user's authorization and
available environment. Fix confirmed findings and retest. Do not conceal
unrun checks.

Sources: [Strix sandbox](https://docs.strix.ai/tools/sandbox),
[PentAGI](https://github.com/vxcontrol/pentagi),
[ZAP](https://www.zaproxy.org/docs/desktop/start/),
[Gitleaks](https://github.com/gitleaks/gitleaks),
[OSV-Scanner](https://google.github.io/osv-scanner/),
[k6](https://grafana.com/docs/k6/latest/using-k6/thresholds/).
