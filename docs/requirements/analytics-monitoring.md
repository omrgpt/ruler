# Analytics, Monitoring, Testing & Post-Launch

**Scope:** Operational tooling for every deployed product in this workspace.
**Items:** OPS-120 … OPS-127 (8 requirements).

**Privacy coupling:** All trackers/analytics on this list are **non-essential**
and therefore subject to LEG-079 (strict opt-in consent before any tag fires)
and CRO-104 (justified inventory). An analytics requirement is NOT met if it
fires before consent.

**Legend:** `[AUTO]` script-checked · `[AGENT]` agent-verified w/ evidence ·
`[MANUAL]` human/console action.

---

| ID | Requirement | Verification |
|---|---|---|
| OPS-120 | Uptime monitoring active on production URL(s) + health endpoint: checks every 1–5 min from ≥2 regions, alerts via SMS/email/push that the owner actually receives, incident history retained. Alert routing tested with a deliberate downtime window. | `[MANUAL]` monitor config + test-alert delivery proof recorded |
| OPS-121 | Frontend error tracking wired (Sentry-class): SDK in prod bundle with release tagging + sourcemaps uploaded privately (SEC-041 respected — never public), PII scrubbing enabled (LEG/GDPR), alerts on error-rate spikes, errors linked to releases so regressions attributable. | `[AGENT]` throw test error in staging → appears in dashboard with clean stack; `[MANUAL]` alert rule confirmation |
| OPS-122 | Google Search Console verified for all owned domains (DNS or meta method): sitemap submitted, coverage/index errors reviewed monthly, preferred domain set. Access shared with owner account. | `[MANUAL]` verification + sitemap submission screenshot-recorded |
| OPS-123 | Conversion tracking defined and firing: primary conversions (signup, purchase, lead) + micro-conversions (pricing view, demo start) mapped to business goals; events tested end-to-end (tag assistant/debug mode); deduplication handled when multiple tags fire. Conversion definitions documented here or in data inventory. | `[MANUAL]` debug-mode event trace recorded per conversion; `[AGENT]` verify event payloads match documented schema |
| OPS-124 | Google Analytics 4 installed with: filtered internal/dev traffic, key events marked, retention configured, NO PII sent (user IDs only with policy care), and **consent-mode gating** — loads only after LEG-079 opt-in where required. Property access limited to need-to-know. | `[MANUAL]` property config review; `[AUTO]`/`[AGENT]` verify gtag absent from pre-consent network activity (fresh profile test pairs with LEG-079 check) |
| OPS-125 | Email capture functional and lawful: signup forms connected to ESP (list, double-opt-in where market requires), confirmation/welcome flow fires, source-of-capture stored (pairs with LEG-083 affirmative consent records), unsubscribe honored automatically. | `[AGENT]` submit test email → receive welcome/double-opt-in; `[MANUAL]` ESP settings verified |
| OPS-126 | A/B testing platform ready IF used: experiment hygiene rules — no flicker (async load or server-side assignment), equal-prominence variants, minimum sample/power planned before declaring winners, experiments don't break SEO cloaking rules (server serves consistent content to crawlers). If not used yet, mark N/A until first experiment. | `[MANUAL]` platform decision recorded; `[AGENT]` anti-flicker implementation cited when active |
| OPS-127 | Heatmap/session-replay tool (if used): configured to mask ALL input fields and personal data in replays (PII never leaves browser unmasked — GDPR coupling), sampling capped to control cost (pairs with SEC-062), excluded from authenticated admin areas. Consent-gated like all non-essential tracking. | `[MANUAL]` masking config review with sample replay checked; `[AGENT]` verify masked fields in captured session |

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-24 | Initial import: 8 ops items with stable IDs and verification methods, privacy couplings noted. |
