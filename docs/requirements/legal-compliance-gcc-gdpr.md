# Legal & Global Compliance — GCC PDPL & Europe GDPR

**Scope:** Assess each project against the laws that actually apply to its entity, users, markets, data and processing. A requirement can be N/A only with a documented reason. Obtain qualified legal review where needed; this library cannot guarantee compliance or prevent legal disputes.
**Items:** LEG-075 … LEG-100 (26 requirements).

**Regulatory anchors:** EU/EEA → GDPR (Regulation 2016/679). Bahrain → PDPL
(Law No. 30 of 2018). UAE → PDPL (Federal Decree-Law No. 45 of 2021). KSA →
PDPL (SDAIA, Royal Decree M/19, implementing regulations). Common threads:
lawful basis + consent records, data-subject rights, minimization, breach
notification timelines, cross-border transfer controls.

**Legend:** `[AUTO]` machine-verifiable (not necessarily by the Ruler audit) · `[AGENT]` agent-verified w/ evidence ·
`[MANUAL]` human/legal action required.

Source anchors: [Bahrain PDPL, official Arabic legislation](https://lloc.gov.bh/Legislation/HTM/K3018);
[GDPR, official text](https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng);
[EDPB cookie and anonymization guidance](https://www.edpb.europa.eu/contact/frequently-asked-questions_en).
Check current implementing decisions and local legal requirements for each
project; these anchors do not establish compliance.

---

| ID | Requirement | Verification |
|---|---|---|
| LEG-075 | Accessibility statement page published + site meets WCAG 2.1 AA basics: keyboard navigability, alt text on ALL meaningful images (decorative images explicitly `alt=""`), contrast, focus states, form labels, semantic headings. Statement explains known limitations and feedback channel (ADA/EAA-style expectations). Amended (v4): annually RECORDED whether the EU Accessibility Act microenterprise service-provider exemption applies (fewer than 10 employees AND (annual turnover OR balance-sheet total ≤ €2 m) — the financial limb is a disjunction; services only); if it does not apply, EN 301 549/WCAG 2.1 AA conformance evidence stands against EAA enforcement (live since 28 Jun 2025). | `[AGENT]` automated axe/lighthouse accessibility pass incl. missing-alt scan on key pages; `[MANUAL]` keyboard-only walkthrough; annual exemption-basis check dated in evidence |
| LEG-076 | EULA (End User License Agreement) exists for app/software distribution, covering license grant, restrictions, disclaimers, termination — versioned and dated. Linked from app stores/signup where applicable. | `[MANUAL]` legal text finalized by owner; `[AGENT]` verify link present + reachable from signup/app pages |
| LEG-077 | Where a privacy notice is required, accurately explain processing purposes, categories, lawful bases, recipients, retention, applicable transfer safeguards, rights and contact channels. Map it to real processing; keep it clear and current. Determine transfer direction and mechanism rather than assuming SCCs apply to every GCC/EU flow. | `[MANUAL]` owner and legal review mapped to the data inventory; `[AGENT]` cross-check collection and disclosures |
| LEG-078 | Terms of Service published protecting business liability: governing law + venue (e.g., Bahrain/Courts choice consistent with hosting entity), limitation of liability, acceptable use, IP terms, termination, dispute process. Dated/versioned; acceptance captured at signup with timestamp+version stored. | `[MANUAL]` owner-approved ToS; `[AGENT]` verify acceptance record written on signup (cite schema) |
| LEG-079 | Where non-essential cookies or similar storage require consent, block them before a valid opt-in; offer clear, equally accessible accept/reject choices, record consent choices, and make withdrawal easy. Strictly necessary storage may be used where lawful. If no non-essential technologies are used, record the evidence and do not add a needless banner. Check local rules for the actual deployment. | `[AGENT]` inspect storage and network before and after consent and withdrawal; `[MANUAL]` review consent UX and jurisdiction |
| LEG-080 | Provide a verified erasure request path where applicable. Delete or anonymize data without undue delay where the right applies; evaluate documented legal-retention and other exceptions. Record processors, logs and backup expiry, prevent deleted data returning on restore, and communicate the outcome. Under GDPR Art. 12, respond within one month, with extensions only where permitted; this is not a blanket 30-day erasure mandate. Confirm other jurisdictions separately. | `[AGENT]` test a request across live stores, processors and restore procedures; `[MANUAL]` verify deadlines and retention exceptions for the actual jurisdiction |
| LEG-081 | Where applicable, provide a verified, machine-readable personal-data export. Determine scope and eligibility from the applicable law and processing basis. For GDPR, Art. 20 applies to qualifying automated processing based on consent or contract; Art. 12 generally requires a response within one month, subject to its permitted extension. Protect and audit exports. | `[AGENT]` test export against eligible data inventory; `[MANUAL]` verify applicability and response deadline |
| LEG-082 | Assess sector-specific localization and cross-border transfer rules for actual data, hosting, provider access and applicable jurisdictions. Document any required region, legal mechanism and safeguards; do not assume a universal in-country hosting mandate. | `[MANUAL]` verify current rules and provider locations; record data-class and transfer assessment |
| LEG-083 | Marketing opt-in is affirmative: absolutely no pre-ticked checkboxes for newsletters/promotions anywhere (web forms, checkout, onboarding, apps). Consent separate from terms acceptance, per channel, with proof-of-consent records (who/when/what text). | `[AUTO]` scan for `checked` default-true on marketing/newsletter inputs; `[AGENT]` inspect all opt-in form states |
| LEG-084 | Maintain a breach response plan covering detection, containment, assessment, regulator and user notification, contacts and a tested escalation path. Where GDPR Art. 33 applies, notify the authority without undue delay and where feasible within 72 hours unless the breach is unlikely to risk rights and freedoms; assess other jurisdictions and notification duties independently. | `[MANUAL]` verify jurisdiction-specific deadlines, notification triggers and a tabletop drill |

---

## Data Inventory Requirement (supporting artifact)

Maintain `docs/requirements/data-inventory.md` listing every personal data
field collected: name, purpose, lawful basis, storage location, retention,
processor. Privacy Policy (LEG-077), deletion (LEG-080), and export (LEG-081)
all derive from it. Keep it current when adding features.

---

## Deletion Data Mechanics (pairs with PERF-075 / PERF-076)

The right to be forgotten (LEG-080) removes data from the live system.
These two requirements close the two places deleted data famously survives:
legally-mandated records that keep existing, and automated backups.

| ID | Requirement | Verification |
|---|---|---|
| LEG-085 | Minimize and protect data retained after deletion. Preserve identifiers only where genuinely necessary for documented legal obligations or another valid exception; restrict access and enforce retention. Remove or anonymize other eligible data. Pseudonymization reduces risk but is not necessarily irreversible anonymization: assess re-identification risk. | `[AGENT]` inspect post-deletion stores and access restrictions; `[MANUAL]` approve retention basis and expiry per record class |
| LEG-086 | Define and enforce backup retention per environment and applicable obligations. Keep deleted data inaccessible in retained backups, expire it on schedule, and reapply deletions before restoring. A 30-day backup target is a house target only when technically and legally appropriate, not an asserted universal legal deadline. Test restores. | `[MANUAL]` verify backup retention and access controls; `[AGENT]` test deletion, expiry and restore handling |

---

## Minors & Youth Safety

Assess child access and associated risks per product and jurisdiction. Do not assume an age gate, blanket exclusion, or parental consent is universally required.

| ID | Requirement | Verification |
|---|---|---|
| LEG-087 | Assess whether children may use the product and document applicable child-safety and age-assurance requirements. Choose proportionate methods that minimize age data; block under-age access only when required or explicitly chosen as product policy. A universal DOB gate is not assumed. | `[MANUAL]` assess jurisdictions, audience and age rules; `[AGENT]` test the chosen proportionate control and data minimization |
| LEG-088 | Where law requires parental authorization, obtain and verify it proportionately, document the basis and process, and support applicable withdrawal rights. GDPR Art. 8 concerns consent-based processing when information-society services are offered directly to a child; national age thresholds vary. Do not assume every processing activity involving a minor requires consent. | `[MANUAL]` assess age thresholds, legal basis and applicable local rules; `[AGENT]` test any required authorization and withdrawal flow |
| LEG-089 | Default safety settings for minor accounts: newly created minor accounts default to MAXIMUM privacy — profiles non-discoverable, DMs restricted/off, no personalized ads/profiling, location sharing off, analytics/tracking tags suppressed for known minors regardless of cookie consent state. Defaults can only be loosened by verified guardian action. | `[AGENT]` create minor test account → enumerate defaults vs adult defaults table |

---

## AI & Cross-Border Processing

Assess actual external processing and cross-border flows whenever user-derived data leaves your infrastructure. External processing and a cross-border transfer are not synonymous.

| ID | Requirement | Verification |
|---|---|---|
| LEG-090 | For external AI receiving user-derived data, minimize payloads and review provider contracts, retention, training use, access, subprocessors and transfer arrangements before use. Zero retention and no training are strong house controls when available and appropriate; document any exception and compensating safeguards. Do not describe them as universal statutory requirements. | `[MANUAL]` review provider terms and data inventory; `[AGENT]` verify payload minimization and provider settings |
| LEG-091 | Minimize user-derived data sent to external AI. Prefer not to send identifiers; when redaction is used, test it against relevant data classes, handle missed detection safely and do not claim perfect anonymization. Protect logs and confirm a valid legal basis, contracts and any required consent or transfer conditions. | `[AGENT]` test outbound payload and failure paths; `[MANUAL]` assess legal basis and provider safeguards |
| LEG-092 | Map external processors, actual data flows, access locations and transfer destinations; assess applicable cross-border transfer rules and mechanisms before production use. An external API call is not automatically a cross-border transfer. Verify GCC and EU rules separately for the real flow and jurisdictions. | `[MANUAL]` review and approve data-flow and transfer assessment; `[AGENT]` compare integrations against the map |
| LEG-093 | Identify sensitive data under each applicable law. For GDPR Art. 9 special categories, establish a valid processing basis and applicable Art. 9 condition; explicit consent is one possible condition, not the only one. Treat precise location and financial data as potentially high risk without automatically labeling them GDPR Art. 9 categories. If relying on consent, make it specific, informed, freely given, and withdrawable. | `[MANUAL]` assess legal bases, special-category conditions and jurisdictions; `[AGENT]` verify safeguards and any required consent flows |

## Retention Automation & v4 Obligations

Added in the v4 expansion (2026-08-24 research pass). Items marked
*(feature-gated)* activate when the named feature/market exists.

| ID | Requirement | Verification |
|---|---|---|
| LEG-094 | Every retention period declared in the data inventory (logs, sessions, analytics events, exports, soft-deleted rows) is enforced by an automated purge mechanism — TTL, lifecycle rule, or scheduled job — whose runs are logged and alert on failure. Retention that exists only in policy text fails this requirement (GDPR Art. 5(1)(e): the controller "has to actually delete or anonymise"). Extends LEG-085/086 from deletion-request mechanics to scheduled expiry of live data classes. | `[AGENT]` table: record class → declared period → purge mechanism → last-run log; `[MANUAL]` lifecycle/TTL configs verified in provider consoles |
| LEG-095 | *(feature-gated: customer-facing conversational/generative AI)* Ground consequential factual claims in approved, current sources; provide citations where useful and refuse or escalate unsupported claims. Assess applicable AI-disclosure duties and implement required notices. Retain transcripts only when justified, with a documented purpose, lawful basis, access controls and retention period; do not assume indefinite retention. | `[AGENT]` test unsupported claims and disclosure; `[MANUAL]` approve sources, applicable legal obligations and transcript retention |
| LEG-096 | *(feature-gated: EU B2C checkout)* EU consumer checkouts show pre-contract withdrawal information and provide an electronic withdrawal function (mandatory since 19 Jun 2026, Dir. 2023/2673); express-consent-to-immediate-performance and loss-of-right acknowledgements are captured ONLY where the waiver is legally valid (downloaded/copied digital content, fully performed services — not blanket subscription waivers, CJEU C-234/25). Missing/incorrect info stretches the cooling-off window to 12 months + 14 days (CRD Art. 10). Cross-ref LEG-078 acceptance records. | `[AGENT]` checkout-flow inspection (info link + correctly-scoped waiver control); `[MANUAL]` legal wording owner-approved |
| LEG-097 | When GDPR Art. 3(2) applies to a controller or processor without an EU establishment, assess Art. 27 representative requirements and its exceptions. Appoint and disclose a representative when required; document any exception with evidence. | `[MANUAL]` record applicability assessment, exception or written mandate; `[AGENT]` check policy disclosures where applicable |
| LEG-098 | *(feature-gated: WhatsApp/SMS channels)* Business-initiated WhatsApp/SMS goes only to contacts with documented PER-CHANNEL opt-in using platform-approved templates (WhatsApp/Meta) and registered sender IDs per destination-country telecom rules (KSA CST / UAE TDRA). KSA's first PDPL enforcement wave explicitly cited marketing-without-consent. Extends LEG-083 consent records into delivery-channel rules. | `[AGENT]` sample sends show opted-in audience + approved template IDs + registered sender; `[MANUAL]` sender registrations recorded |
| LEG-099 | *(feature-gated: EU consumer sales)* Before launch, assess the actual seller or merchant of record, customer location, product type, place-of-supply rules, registration thresholds and applicable VAT schemes. Record the decision and obtain tax advice where needed; do not assume every sale must use the same registration scheme. | `[MANUAL]` document jurisdiction-specific tax assessment and any registration; `[AGENT]` verify checkout tax display against the approved treatment |
| LEG-100 | For user-generated content or other hosting/intermediary services, assess whether EU Digital Services Act obligations apply to the actual service, including notice-and-action, decision explanations, complaint mechanisms and any relevant exemptions. Provide an appropriate reporting and handling process, protect users and record decisions. Do not assume all explanation or appeal duties apply only to very large platforms. | `[MANUAL]` assess service classification and legal obligations; `[AGENT]` test applicable reporting, response, explanation and complaint flows |

---

## Changelog

| Date | Change |
|---|---|
| 2026-11-08 | Corrected GDPR erasure, portability, children, representative and special-category scope; clarified cookies, breach notification, AI and tax applicability; distinguished house AI/backup policy from legal requirements; corrected transfer, anonymization and DSA applicability. Confirm local-law applicability and unresolved points with qualified counsel. Sources: [GDPR Arts. 8, 12, 17, 20, 27](https://eur-lex.europa.eu/eli/reg/2016/679/oj/eng), [EDPB consent guidance](https://www.edpb.europa.eu/sites/default/files/files/file1/edpb_guidelines_202005_consent_en.pdf), [EDPB data protection FAQ](https://www.edpb.europa.eu/contact/frequently-asked-questions_en), [DSA](https://eur-lex.europa.eu/eli/reg/2022/2065/oj/eng). |
| 2026-08-24 | Initial import: 10 legal items with stable IDs, GCC/GDPR anchors, verification methods. Added data-inventory requirement. |
| 2026-08-24 | v2: Added LEG-085/086 (deletion data mechanics), LEG-087–089 (minors & youth safety), LEG-090–093 (AI & cross-border processing) from the 142-point master list. Alt-text emphasis added to LEG-075. |
| 2026-08-24 | v4: Added LEG-094 (retention automation), LEG-095 (grounded/refusing customer AI + disclosure), LEG-096 (EU withdrawal-right mechanics), LEG-097 (Art. 27 representative), LEG-098 (WhatsApp/SMS channel compliance), LEG-099 (VAT place-of-supply routing), LEG-100 (UGC/AI-content notice-and-action). LEG-075 amended with annual EAA microenterprise-exemption status record. Total now 26. |
| 2026-08-25 | v4.1 calibration pass (owner-approved): **LEG-075** EAA microenterprise exemption corrected per Directive 2019/882 Art. 4(5) with Art. 3(23)/Recital 2003/361 — the financial limb is turnover OR balance-sheet total ≤ €2 m (previously stated as "both required", which would wrongly deny qualifying businesses). **LEG-100** simplified to solo-scale manual notice-and-action: report → owner notification → removal under a published acceptable-use/takedown policy; moderation-queue SLAs / statements of reasons / appeal paths deferred until UGC volume outgrows manual handling; DSA Art. 16 obligation itself unchanged. ID count unchanged at 26. |
