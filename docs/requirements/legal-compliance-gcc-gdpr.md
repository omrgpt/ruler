# Legal & Global Compliance — GCC PDPL & Europe GDPR

**Scope:** Every user-facing product in this workspace serving users in
Bahrain, UAE, KSA, the EU/EEA, or anywhere else.
**Items:** LEG-075 … LEG-093 (19 requirements).

**Regulatory anchors:** EU/EEA → GDPR (Regulation 2016/679). Bahrain → PDPL
(Law No. 30 of 2018). UAE → PDPL (Federal Decree-Law No. 45 of 2021). KSA →
PDPL (SDAIA, Royal Decree M/19, implementing regulations). Common threads:
lawful basis + consent records, data-subject rights, minimization, breach
notification timelines, cross-border transfer controls.

**Legend:** `[AUTO]` script-checked · `[AGENT]` agent-verified w/ evidence ·
`[MANUAL]` human/legal action required.

---

| ID | Requirement | Verification |
|---|---|---|
| LEG-075 | Accessibility statement page published + site meets WCAG 2.1 AA basics: keyboard navigability, alt text on ALL meaningful images (decorative images explicitly `alt=""`), contrast, focus states, form labels, semantic headings. Statement explains known limitations and feedback channel (ADA/EAA-style expectations). | `[AGENT]` automated axe/lighthouse accessibility pass incl. missing-alt scan on key pages; `[MANUAL]` keyboard-only walkthrough |
| LEG-076 | EULA (End User License Agreement) exists for app/software distribution, covering license grant, restrictions, disclaimers, termination — versioned and dated. Linked from app stores/signup where applicable. | `[MANUAL]` legal text finalized by owner; `[AGENT]` verify link present + reachable from signup/app pages |
| LEG-077 | Privacy Policy clearly states exactly what data is collected, purposes, lawful bases, processors/subprocessors (hosting, payments, analytics), retention periods, transfer mechanism (e.g., SCCs for GCC↔EU flows), and user rights with contact channel. Written in plain language, dated/versioned, change-notified. | `[MANUAL]` owner-approved policy text mapped to actual data inventory; `[AGENT]` cross-check: every collected field in code appears in the policy inventory (and vice versa) |
| LEG-078 | Terms of Service published protecting business liability: governing law + venue (e.g., Bahrain/Courts choice consistent with hosting entity), limitation of liability, acceptable use, IP terms, termination, dispute process. Dated/versioned; acceptance captured at signup with timestamp+version stored. | `[MANUAL]` owner-approved ToS; `[AGENT]` verify acceptance record written on signup (cite schema) |
| LEG-079 | Cookie consent is strict opt-in: NO non-essential cookie/storage set or read before explicit consent; banner offers accept/reject of equal prominence; consent recorded (categories, timestamp, version); granular categories (necessary/analytics/marketing); withdrawal as easy as granting; consent state re-checked on each load. Applies to cookies AND equivalent local storage/pixels. | `[AUTO]` pre-consent scan: fresh profile hits site → only necessary storage present before interaction; `[MANUAL]` banner UX review (equal-weight buttons) |
| LEG-080 | Right to be forgotten implemented in-app: self-service account deletion (or verified request path) erases/anonymizes personal data across primary DB, backups per retention policy, logs (per redaction policy), third-party processors (deletion API calls documented), within 30 days max (GDPR Art. 17; PDPL equivalents). Confirmation issued to user. | `[AGENT]` execute deletion on test account → enumerate all stores showing removal; list processor deletion calls |
| LEG-081 | Data portability: user can export/download their personal data in a machine-readable format (JSON/CSV) — directly in-app or via verified request fulfilled ≤30 days. Export covers provided data + observed data per GDPR Art. 20; export action itself is audit-logged. | `[AGENT]` run export for test account → validate file completeness against data inventory |
| LEG-082 | Data localization/transfer compliance: cloud regions chosen to satisfy GCC localization rules where sensitive data requires it (e.g., KSA/Bahrain in-region hosting for regulated workloads), and cross-border transfers use valid mechanisms (adequacy decisions, SCCs). Region selection documented per data class; provider region settings screenshot-recorded. | `[MANUAL]` provider region config review + data-class→region mapping table recorded |
| LEG-083 | Marketing opt-in is affirmative: absolutely no pre-ticked checkboxes for newsletters/promotions anywhere (web forms, checkout, onboarding, apps). Consent separate from terms acceptance, per channel, with proof-of-consent records (who/when/what text). | `[AUTO]` scan for `checked` default-true on marketing/newsletter inputs; `[AGENT]` inspect all opt-in form states |
| LEG-084 | Breach notification plan documented and ready: detection → containment → assessment → notification workflow; regulator notice ≤72h of becoming aware (GDPR Art. 33; KSA/Bahrain PDPL timelines confirmed and followed); affected users notified without undue delay when high risk; template notices pre-drafted; contact roster (owner, hosting, legal counsel) maintained. One tabletop drill performed. | `[MANUAL]` plan document + drill date recorded; contact roster verified current |

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
| LEG-085 | Soft deletion & anonymization: where financial/tax/usage records must legally be retained after account deletion (invoice history, fraud records), ALL personal identifiers are irreversibly scrubbed from those retained rows — name/email replaced with opaque token, free-text fields redacted, foreign keys to content severed — so no remaining record can be re-linked to the individual. Retention schedule per record class documented in the data inventory; nothing is retained "just in case". | `[AGENT]` inspect post-deletion DB snapshot: retained rows show tokenized identifiers only, cite scrub function |
| LEG-086 | Backup retention expiry: deleted user data provably ages out of automated database backups within the legally compliant window configured for the product (default ≤30 days). Backup retention period documented per environment; restore drill (SEC-050) includes a check that a deleted user's data is absent from backups older than the window; backup snapshots never restored selectively into production without re-running deletion logic. | `[MANUAL]` provider backup-retention setting recorded; `[AGENT]` deletion→backup expiry timeline test on staging |

---

## Minors & Youth Safety

Applies when the product is, or may be, used by anyone under 18. GCC PDPLs
and GDPR set heightened bars for children's data — if minors are not a target
audience, an age gate is still required to prove it.

| ID | Requirement | Verification |
|---|---|---|
| LEG-087 | Age verification gate at onboarding: age/self-declared DOB collected before account creation where the service targets or plausibly reaches minors; under-age signups blocked by default; method proportionate to risk (self-declaration minimum for general audience, document/verifiable checks for adult-only services). Age data handled as sensitive and never used for anything else. | `[AGENT]` attempt signup with minor DOB → blocked path demonstrated; cite gate implementation |
| LEG-088 | Verifiable parental consent: where minors ARE permitted users, documented verifiable parental consent obtained before processing their personal data (GDPR Art. 8 / member-state age floors 13–16; GCC equivalents followed). Consent evidence stored (guardian identifier, timestamp, method) and revocable, revocation triggers same deletion pipeline as LEG-080. | `[MANUAL]` consent flow reviewed against applicable age floor; `[AGENT]` consent record schema + revocation path cited |
| LEG-089 | Default safety settings for minor accounts: newly created minor accounts default to MAXIMUM privacy — profiles non-discoverable, DMs restricted/off, no personalized ads/profiling, location sharing off, analytics/tracking tags suppressed for known minors regardless of cookie consent state. Defaults can only be loosened by verified guardian action. | `[AGENT]` create minor test account → enumerate defaults vs adult defaults table |

---

## AI & Cross-Border Processing

Every external AI/API call is a cross-border transfer into a third party's
systems. These requirements apply whenever prompts or attachments derived from
user data leave your infrastructure.

| ID | Requirement | Verification |
|---|---|---|
| LEG-090 | Zero-data-retention agreements: every AI API provider receiving user-derived payloads operates under a contractual zero-retention / no-training-on-your-data arrangement (OpenAI/Anthropic/Google enterprise ZDR terms, Azure OpenAI data policies, etc.). Provider tier + agreement link recorded in the data inventory per integration. Consumer-tier endpoints that retain prompts are not allowed for user data. | `[MANUAL]` provider plan/agreement documentation recorded per AI integration |
| LEG-091 | PII scrubbing middleware: before any prompt containing user data hits an external model, a middleware layer strips/anonymizes PII (names, emails, phone numbers, national IDs, addresses, payment traces) unless the user explicitly opted into sending that field. Scrubber has tests covering each PII class; raw unscrubbed payloads never logged either. | `[AGENT]` send PII-laced prompt through pipeline → capture outbound payload proving scrubbing; cite middleware + tests |
| LEG-092 | Cross-border transfer verification: for EVERY external service receiving personal data (AI providers, ESPs, analytics, storage regions), destination country + transfer mechanism verified adequate (GCC adequacy/SDAIA transfer rules, UAE regulations, EU SCCs/adequacy list). Data-flow map kept current: field class → processor → country → mechanism. New integrations require this row filled before first production call. | `[MANUAL]` data-flow map reviewed/signed off; `[AGENT]` inventory external callsites vs map completeness |
| LEG-093 | Explicit consent for sensitive data: processing of sensitive/special-category data (health, biometrics, religious/ethnic fields, precise geolocation, financial details beyond transaction necessity) requires separate, explicit, unbundled opt-in consent — never bundled into ToS acceptance or pre-ticked (extends LEG-083's rule to sensitive classes). Purpose of each sensitive field stated at collection point; refusal path keeps core service working. | `[AGENT]` inspect each sensitive-field collection UI → separate unticked consent control present; `[MANUAL]` legal sign-off of purpose statements |

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-24 | Initial import: 10 legal items with stable IDs, GCC/GDPR anchors, verification methods. Added data-inventory requirement. |
| 2026-08-24 | v2: Added LEG-085/086 (deletion data mechanics), LEG-087–089 (minors & youth safety), LEG-090–093 (AI & cross-border processing) from the 142-point master list. Alt-text emphasis added to LEG-075. |
