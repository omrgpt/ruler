# Master Compliance Checklist — 154-Point Master List (v3)

**The ledger.** Every requirement's live status and evidence lives here.
An item is `done` ONLY when this row says ✅ **and** evidence is recorded.

The v3 master list contains **154 checkpoints**. This library tracks them as
**164 stable IDs**: v3's reorganization moved items between sections (IDs are
permanent — they didn't move), three v3 lines were duplicates and were
deduped (#142 = #27, #153 = #25, #154 = #26), and 12 genuinely new items
became SEC-064…075. See the mapping in [README](./README.md).

## Status legend

| Symbol | Meaning |
|---|---|
| ☐ | Open — not started |
| 🔶 | Partial / in progress |
| ✅ | Done — evidence recorded |
| ➖ | N/A / consolidated — justification required |
| ⛔ | FAILING — audit found violation; must fix |

Evidence format: `file:line`, test name, audit-output snippet, dated
screenshot/console reference.

---

## 🔐 Security, Authentication & Web Vulnerabilities (75) — v3 items 1–61 + pipeline additions
[security-authentication.md](./security-authentication.md)

### Secrets & Key Management

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-001 | No DB credentials in code/bundles/logs | ☐ | |
| SEC-002 | .env gitignored, never tracked | ☐ | |
| SEC-003 | API keys server-side env only; short-lived where possible | ☐ | |
| SEC-015 | Git history secret-free (rotate+purge on leak) | ☐ | |
| SEC-016 | No secrets in front-end bundles | ☐ | |
| SEC-030 | JWT secrets long/random/rotated/env-sourced | ☐ | |
| SEC-035 | Default credentials removed everywhere | ☐ | |
| SEC-062 | Spend caps + billing alerts all paid services | ☐ | |
| SEC-063 | 2FA on all infrastructure accounts | ☐ | |

### Authentication & Sessions

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-004 | Auth enforced server-side, not UI-only | ☐ | |
| SEC-026 | Password reset: single-use, TTL ≤15min, no enumeration | ☐ | |
| SEC-064 | User-facing MFA (TOTP) offered; enforced for admins | ☐ | |
| SEC-065 | Account enumeration blocked on login/signup/reset (generic responses + timing) | ☐ | |
| SEC-027 | Sessions expire, rotate, server-side destroy on logout | ☐ | |
| SEC-028 | Tokens in Secure/HttpOnly/SameSite cookies (not localStorage) | ☐ | |
| SEC-029 | bcrypt ≥12 / argon2id password hashing | ☐ | |
| SEC-061 | OAuth state validated, strict redirects, server-side exchange | ☐ | |

### Authorization & Access Control

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-005 | Server-side authz on every endpoint, deny by default | ☐ | |
| SEC-006 | Users access only own records | ☐ | |
| SEC-038 | IDOR/BOLA sweep incl. nested/export endpoints | ☐ | |
| SEC-056 | Tenant isolation absolute (scoping + RLS) | ☐ | |

### Database Security

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-007 | DB rules/grants deny-by-default, reviewed | ☐ | |
| SEC-008 | RLS enabled on every user/business table | ☐ | |
| SEC-047 | Least-privilege DB roles; service keys never client-side | ☐ | |
| SEC-055 | Sensitive data encrypted at rest (+app-level crown jewels) | ☐ | |

### API & Input Validation

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-017 | Never trust client-side security decisions | ☐ | |
| SEC-018 | Schema-based validation: types, lengths, reject unexpected fields | ☐ | |
| SEC-019 | Parameterized queries exclusively (SQL injection) | ☐ | |
| SEC-020 | NoSQL injection blocked (operator/`$where`) | ☐ | |
| SEC-039 | Every API route validates inputs independently | ☐ | |
| SEC-058 | Mass assignment blocked via field allowlists | ☐ | |

### Web Attack Prevention

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-021 | XSS: escape/sanitize rendered user content + CSP | ☐ | |
| SEC-022 | CSRF protection on state-changing routes | ☐ | |
| SEC-023 | File uploads: type+magic-byte+size checks, safe storage | ☐ | |
| SEC-024 | Path traversal blocked (containment verified) | ☐ | |
| SEC-025 | SSRF blocked (allowlist, private-range denial) | ☐ | |
| SEC-066 | Open redirects prevented (allowlist-validated redirects) | ☐ | |
| SEC-059 | Command injection eliminated | ☐ | |
| SEC-060 | No native deserialization of untrusted data | ☐ | |

### Payments & Webhooks

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-036 | Webhook signatures strictly verified, idempotent processing | ☐ | |
| SEC-037 | Pricing set/verified server-side only | ☐ | |

### Rate Limiting & Abuse Prevention

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-032 | Rate limits on login/signup/paid APIs (IP + account) | ☐ | |
| SEC-033 | Bot protection/CAPTCHA on public forms | ☐ | |

### Infrastructure & Configuration

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-009 | Only anon/public key in frontend | ☐ | |
| SEC-010 | Cloud prod settings hardened + quarterly recheck | ☐ | |
| SEC-011 | Admin routes protected (authz + 2FA, undiscoverable) | ☐ | |
| SEC-012 | Debug mode/toolbars disabled in production | ☐ | |
| SEC-031 | CORS explicit allowlist, no wildcard w/ credentials | ☐ | |
| SEC-034 | Environments isolated (DBs, keys, accounts) | ☐ | |
| SEC-041 | Source maps not public in production | ☐ | |
| SEC-051 | Internal dashboards unreachable from public internet | ☐ | |
| SEC-052 | Security headers: CSP/HSTS/nosniff/frame-deny/etc. | ☐ | |
| SEC-053 | Cookie flags: Secure/HttpOnly/SameSite/scope/max-age | ☐ | |
| SEC-054 | HTTPS forced everywhere, TLS ≥1.2 | ☐ | |

### Logging & Monitoring

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-013 | Logs redact secrets/PII at library level | ☐ | |
| SEC-014 | Generic prod errors; traces stay server-side | ☐ | |
| SEC-040 | Logs/log-endpoints themselves protected | ☐ | |
| SEC-048 | Audit logs for security events (actor/IP/UA/time) | ☐ | |
| SEC-049 | Security alerting wired to a human-read channel | ☐ | |

### Supply Chain & Resilience

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-042 | Dependency scanning in CI, zero known-critical at release | ☐ | |
| SEC-043 | New packages vetted (typosquat/popularity/license) | ☐ | |
| SEC-050 | Automatic backups + tested restore drill (dated) | ☐ | |
| SEC-057 | No unreviewed merges to main; CI green required | ☐ | |

### AI-Specific Security

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-044 | Prompt injection defended; LLM output untrusted | ☐ | |
| SEC-045 | AI endpoints authed/authz'd; keys server-side | ☐ | |
| SEC-046 | Per-user AI usage caps enforced server-side | ☐ | |
| SEC-067 | AI output schema-validated before execution/render | ☐ | |
| SEC-068 | AI agents least-privileged (scoped tools/credentials) | ☐ | |

### Business Logic, Concurrency & Resilience

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-069 | Business-logic abuse tested (discounts, credits, sequences) | ☐ | |
| SEC-070 | Race conditions prevented (atomic ops, locks) | ☐ | |
| SEC-071 | Security checks fail CLOSED on error/timeout | ☐ | |
| SEC-072 | Strict timeouts on external APIs + DB queries | ☐ | |

### CI/CD & Pipeline Security

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEC-073 | Deployment pipelines secured (review-gated, masked secrets) | ☐ | |
| SEC-074 | Third-party build actions vetted before adoption | ☐ | |
| SEC-075 | Build deps pinned (SHA-pinned actions, lockfile `npm ci`) | ☐ | |

---

## 📱 Mobile App Specifics (5) — v2 items 64–68
[mobile.md](./mobile.md)

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| MOB-064 | No API keys in compiled app bundle | ☐ | |
| MOB-065 | Tokens in Keychain/Keystore, not AsyncStorage | ☐ | |
| MOB-066 | Deep links validated before sensitive actions | ☐ | |
| MOB-067 | Biometrics unlock UI only; server step-up for sensitive actions | ☐ | |
| MOB-068 | ATT prompt iff tracking used; disclosures synced | ☐ | |

---

## ⚙️ Backend Performance & Audits (8) — v2 items 69–76
[backend-performance.md](./backend-performance.md)

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| PERF-069 | Queries fetch only what UI needs | ☐ | |
| PERF-070 | N+1 queries eliminated/batched | ☐ | |
| PERF-071 | Indexes on frequent search/filter/join columns | ☐ | |
| PERF-072 | Connections closed properly; bounded pools | ☐ | |
| PERF-073 | Object storage free of orphaned blobs; cleanup jobs | ☐ | |
| PERF-074 | No hidden background jobs holding connections | ☐ | |
| PERF-075 | Cascading deletions: files/images/rows all wiped, zero orphans | ☐ | |
| PERF-076 | Third-party purge: payment/ESP/AI-log deletion requests automated | ☐ | |

---

## 🌍 Legal, Global Compliance & Data Privacy (19) — v2 items 77–95
[legal-compliance-gcc-gdpr.md](./legal-compliance-gcc-gdpr.md)

### Policies & Consent

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| LEG-075 | Accessibility statement + WCAG 2.1 AA incl. alt text on all images | ☐ | |
| LEG-076 | EULA published, versioned | ☐ | |
| LEG-077 | Privacy Policy: exact data inventory, bases, transfers | ☐ | |
| LEG-078 | ToS published; acceptance captured w/ version+timestamp | ☐ | |
| LEG-079 | Cookie consent STRICT opt-in; nothing non-essential pre-consent | ☐ | |

### Deletion Mechanics

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| LEG-080 | Right to be forgotten: in-app deletion across all stores ≤30d | ☐ | |
| LEG-085 | Soft-deleted records fully anonymized where retention is mandated | ☐ | |
| LEG-086 | Deleted data ages out of backups within compliant window (≤30d default) | ☐ | |

### Data Rights & Transfers

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| LEG-081 | Data portability: machine-readable export ≤30d, audit-logged | ☐ | |
| LEG-082 | Data localization/transfer mechanisms documented per region | ☐ | |
| LEG-083 | Zero pre-ticked marketing checkboxes; consent records kept | ☐ | |
| LEG-084 | Breach plan: ≤72h regulator notice, templates, drill done | ☐ | |

### Minors & Youth Safety

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| LEG-087 | Age verification gate at onboarding; minors blocked where intended | ☐ | |
| LEG-088 | Verifiable parental consent documented + revocable (if minors allowed) | ☐ | |
| LEG-089 | Minor accounts default to maximum privacy settings | ☐ | |

### AI & Cross-Border Processing

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| LEG-090 | ZDR agreements with AI providers (no training on user payloads) | ☐ | |
| LEG-091 | PII scrubbing middleware before external AI calls | ☐ | |
| LEG-092 | Cross-border transfer adequacy verified per external destination | ☐ | |
| LEG-093 | Explicit unbundled consent for sensitive data processing | ☐ | |

---

## 🤖 SEO, Metadata & Production Config (14) — v2 items 96–109
[seo-metadata-production.md](./seo-metadata-production.md)

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| SEO-096 | Launched on custom domain (no platform-preview URL) | ☐ | |
| SEO-097 | No boilerplate tab titles ("Vite + React" etc.) | ☐ | |
| SEO-098 | Open Graph/Twitter tags + image on every shareable page | ☐ | |
| SEO-099 | Exactly one `<h1>` per page; hierarchical headings; landmarks | ☐ | |
| SEO-100 | Canonical URLs on every indexable page | ☐ | |
| SEO-101 | JSON-LD structured data, validated | ☐ | |
| SEO-102 | sitemap.xml present, accurate, linked from robots.txt | ☐ | |
| SEO-103 | `<html lang>` correct (+hreflang when multi-language) | ☐ | |
| SEO-104 | robots.txt allows intended crawlers; blocks only deliberately | ☐ | |
| SEO-105 | llms.txt removed unless deliberately maintained | ☐ | |
| SEO-106 | View-source shows real content (SSR/prerender), curl-verified | ☐ | |
| SEO-107 | Zero console errors in production build | ☐ | |
| SEO-108 | Zero console warnings in production build | ☐ | |
| SEO-109 | JS bundles proportionate; no MB-scale payload on simple pages | ☐ | |

---

## 💰 Website Conversions & Content (20 IDs ↔ v2 items 110–123)
[conversion-content.md](./conversion-content.md)

v2 merged several conversion checks into single lines. All original granular
IDs stay active; a v2 line is satisfied when ALL its member IDs pass.
Mapping: 110←085 · 111←086 · 112←087+089 · 113←088+096 · 114←090 · 115←091+092 ·
116←093+094 · 117←095 · 118←097+098 · 119←099 · 120←100 · 121←101 · 122←102 ·
123←103. CRO-104 (unnecessary cookies/storage) was folded into LEG-079's
consent scope in v2 and is tracked there.

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| CRO-085 | Max one popup interruption per intent, frequency-capped | ☐ | |
| CRO-086 | Headline passes 5-second clarity test | ☐ | |
| CRO-087 | One clear primary CTA above the fold per page | ☐ | |
| CRO-089 | No equal-weight competing CTAs in same viewport | ☐ | |
| CRO-088 | No AI-slop images; no text baked into images | ☐ | |
| CRO-096 | Stock photos minimal/tasteful; real media preferred | ☐ | |
| CRO-090 | Speed budget: mobile perf ≥80, LCP ≤2.5s, CLS ≤0.1 | ☐ | |
| CRO-091 | No walls of text; scannable structure | ☐ | |
| CRO-092 | Copy specific, owner-approved; no generic AI filler | ☐ | |
| CRO-093 | Value prop explicit above the fold (desktop + mobile) | ☐ | |
| CRO-094 | Clear next step at every scroll depth | ☐ | |
| CRO-095 | Mobile-first layouts verified 320–430px | ☐ | |
| CRO-097 | Animations restrained, reduced-motion respected | ☐ | |
| CRO-098 | Video backgrounds muted/lazy/mobile-skipped | ☐ | |
| CRO-099 | Forms minimal; every field justified | ☐ | |
| CRO-100 | Pricing transparent (≤1 click); hidden pricing justified | ☐ | |
| CRO-101 | Real social proof near conversion points | ☐ | |
| CRO-102 | Zero broken links/buttons; checker runs pre-release | ☐ | |
| CRO-103 | Navigation lean; dead nav removed | ☐ | |
| CRO-104 | ➖ Consolidated into LEG-079 (storage minimization) in v2 | ➖ | absorbed — verify with cookie consent work |

---

## 🎨 UI, UX & Frontend (15 IDs ↔ v2 items 124–134)
[ui-ux-frontend.md](./ui-ux-frontend.md)

Mapping: 124←105 · 125←106 · 126←107 · 127←108+109 · 128←110 · 129←111 ·
130←112 · 131←113 · 132←114+115 · 133←116 · 134←117+118+119.

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| UIX-105 | Zero horizontal scroll ≥320px viewports | ☐ | |
| UIX-106 | Mobile menu works, focus-trapped, closes properly | ☐ | |
| UIX-107 | Favicon set complete (ico/PNG/apple-touch/manifest) | ☐ | |
| UIX-108 | Titles unique/descriptive/≤60 chars on every route | ☐ | |
| UIX-109 | Meta descriptions unique, 120–160 chars, every page | ☐ | |
| UIX-110 | Footer links resolve; footer consistent site-wide | ☐ | |
| UIX-111 | Custom branded 404 returning proper HTTP status | ☐ | |
| UIX-112 | Copyright year dynamic | ☐ | |
| UIX-113 | Images compressed/modern formats/lazy/sized | ☐ | |
| UIX-114 | Success messages on every mutating action (aria-live) | ☐ | |
| UIX-115 | Error messages actionable on every failure mode | ☐ | |
| UIX-116 | No placeholder/lorem/TODO content shipped | ☐ | |
| UIX-117 | Logo clickable → home, accessible name present | ☐ | |
| UIX-118 | Phone numbers are tel: links (international format) | ☐ | |
| UIX-119 | Emails are mailto: links | ☐ | |

---

## 🚀 Analytics, Monitoring & Post-Launch (8) — v2 items 135–142
[analytics-monitoring.md](./analytics-monitoring.md)

| ID | Requirement (short) | Status | Evidence / Notes |
|---|---|---|---|
| OPS-120 | Uptime monitoring + tested alert delivery | ☐ | |
| OPS-121 | Frontend error tracking (Sentry-class), PII-scrubbed | ☐ | |
| OPS-122 | Search Console verified, sitemap submitted | ☐ | |
| OPS-123 | Conversion tracking mapped + end-to-end tested | ☐ | |
| OPS-124 | GA4 installed, consent-gated, internal traffic filtered | ☐ | |
| OPS-125 | Email capture lawful: double-opt-in, unsubscribe honored | ☐ | |
| OPS-126 | A/B testing hygiene if used (anti-flicker, no SEO cloaking) | ☐ | |
| OPS-127 | Heatmap/replay masks PII, consent-gated if used | ☐ | |

---

## Roll-up (update after each audit)

| Section | IDs | ✅ | 🔶 | ⛔ | ☐ | ➖ |
|---|---|---|---|---|---|---|
| Security | 75 | | | | 75 | |
| Mobile | 5 | | | | 5 | |
| Performance | 8 | | | | 8 | |
| Legal | 19 | | | | 19 | |
| SEO | 14 | | | | 14 | |
| Conversion | 20 | | | | 19 | 1 |
| UI/UX | 15 | | | | 15 | |
| Ops | 8 | | | | 8 | |
| **Total** | **164** | | | | **163** | **1** |

*164 ledger IDs cover the v3 master list's 154 checkpoints: 12 new items
(SEC-064…075) + v3's section reorganization (IDs permanent, unmoved) + 3
deduped duplicates (#142, #153, #154) + the v2 merge mappings noted above.*
