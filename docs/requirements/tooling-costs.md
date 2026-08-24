# Tooling & Service Costs Behind the Requirements

Every external service the 190-ID library depends on, with its cost reality:
what's genuinely free, what has a workable free tier, and what eventually
costs money. Use this when planning a launch budget — nothing here should be
a surprise bill.

> **Accuracy note:** prices/approvals below are approximate market knowledge
> as of August 2026. Providers change pricing often — always confirm at
> signup, and record the confirmed number in your project's checklist
> evidence column next to the matching requirement ID.

---

## Legend

| Tag | Meaning |
|---|---|
| FREE | Genuinely free for the use case described |
| TIER | Has a usable free tier; paid above a threshold |
| PAID | Costs money from day one |
| FEE | Percentage/usage-based (no fixed monthly) |

---

## 1. Always-required spend

| Requirement(s) | Item | Cost | Notes |
|---|---|---|---|
| SEO-096 | Custom domain | PAID, ~$10–20/yr (.com); Bahraini `.bh` typically ~$40–70/yr | The only near-unavoidable fixed cost. Registrar: Cloudflare (at-cost), Namecheap, Porkbun. `.bh` via Batelco-licensed registrars. |
| CRO-100, SEC-036/037 | Payment processing | FEE | Stripe: no monthly fee, roughly 2.9% + fixed ~$0.30 per card charge (GCC rates differ slightly; KSA/UAE/BH local cards sometimes cheaper via regional PSPs). Alternatives in GCC: Tap Payments, HyperPay, PayTabs — monthly fees may apply, compare before committing. |
| MOB-064…068 | Selling DIGITAL goods inside an iOS/Android app | FEE, 15–30% commission | Apple App Store / Google Play take a cut of digital-goods sales (15% small-business tier possible). Physical goods/services can bypass via Stripe. This is contractual, not avoidable — factor into mobile pricing. Apple developer account: $99/yr; Google Play: one-time $25. |

## 2. Free-for-life paths (use these first)

| Requirement(s) | Need | Free tool | Paid upgrade trigger |
|---|---|---|---|
| OPS-122 | Search Console | FREE (Google) | n/a |
| OPS-124 | Analytics | GA4 free; Plausible/Fathom are paid alternatives | GA360 enterprise is unnecessary for almost everyone |
| SEC-033 | Bot protection | **Cloudflare Turnstile** — free, unlimited, privacy-friendly (also helps GDPR/GCC consent posture) | hCaptcha/reCAPTCHA enterprise tiers only for extreme abuse |
| SEC-052, SEC-054 | TLS certificates | Let's Encrypt / host-managed certs — free | n/a |
| SEC-042 | Dependency scanning | `npm audit`/`pip-audit`, GitHub Dependabot (free on private repos too) | Snyk/Socket paid tiers for advanced supply-chain policy |
| SEC-015 | Secret scanning | gitleaks / trufflehog (open source, run in CI) | GitHub Advanced Security (paid) adds push protection on private repos |
| LEG-075 | Accessibility testing | axe DevTools browser extension, Lighthouse — free | Manual expert audits are the paid part |
| OPS-127 | Heatmaps/session replay | **Microsoft Clarity — completely free** (unlimited traffic, PII masking built in) | Hotjar/FullStory paid plans if you want their extras |
| OPS-126 | A/B testing | PostHog free tier (includes feature flags + experiments); GrowthBook open source | High event volume or managed hosting |
| OPS-121 | Error tracking | Sentry free tier (~5k errors/mo, sourcemap upload included); GlitchTip self-host free | Sentry Team plan once error volume/team grows |
| SEC-063 | 2FA infrastructure accounts | TOTP apps (Aegis, Google Authenticator, 1Password) + hardware keys you already own — free | SMS 2FA costs per-message via Twilio/Vonage only if YOU send OTPs to users |

## 3. Free-tier-now, paid-at-scale (budget later)

| Requirement(s) | Need | Free allowance (approx.) | Typical paid step |
|---|---|---|---|
| OPS-120 | Uptime monitoring | UptimeRobot: ~50 monitors @ 5-min checks; Better Stack: ~10 monitors | 1-minute intervals, SMS/phone alerts: ~$5–30/mo |
| OPS-125 | Transactional email (receipts, password reset!) | Resend ~3k emails/mo; Brevo ~300/day; Amazon SES ~$0.10 per 1,000 | Resend Pro ~$20/mo; SES stays cents-level |
| OPS-125 | Marketing/newsletter sends | Brevo/MailerLite free caps small | ~$10–30/mo at list growth |
| LEG-079 | Consent banner (if not hand-built) | Hand-rolled banner = $0 and fully compliant if it meets LEG-079 spec; CookieYes/Cookiebot free tiers cover small sites | ~$10–40/mo for multi-domain/advanced scans |
| SEC-010, SEC-050 | DB backups / PITR | Managed free tiers give basic automated backups (e.g., Supabase free: short retention) | Point-in-time-recovery & longer retention: ~$10–30/mo addon on most platforms — REQUIRED for LEG-086 compliance window, so budget this |
| Hosting | Web hosting | Vercel/Netlify/Cloudflare Pages hobby tiers are generous; Cloudflare Pages effectively free | Commercial-use terms usually push to ~$20/user/mo on Vercel/Netlify; Cloudflare remains cheaper |
| SEC-046, LEG-090 | AI API usage | Pay-per-token from first call — no free lunch at scale | OpenAI/Anthropic/Google all metered. ZDR posture: Azure OpenAI applies no-training-on-inputs by default; OpenAI/Anthropic commercial terms exclude training on API inputs by default — still get written confirmation (LEG-090 evidence) |

## 4. Things that LOOK like they should cost money but don't

| Requirement(s) | Misconception | Reality |
|---|---|---|
| LEG-076/077/078 | "Need a lawyer subscription for EULA/Privacy/ToS" | Solid templates (e.g., from iubenda alternatives, GitHub legal repos, Termly free tier) + owner review cover early stage. Paid counsel becomes worth it at scale/regulatory complexity — GCC PDPL formal review recommended before significant Bahraini/KSA user volume. |
| SEC-008 | RLS costs money | It's a database feature (Postgres/Supabase/Firebase rules) — free, just engineering work |
| SEO-101/102 | Schema/sitemaps need paid tools | Generated in code; Google Rich Results Test + Search Console validate free |
| CRO-102 | Link checking needs SaaS | `lychee`/`linkinator` CLI in CI — free |

---

## Minimum viable launch budget (typical)

| Item | Monthly equivalent |
|---|---|
| Domain | ~$1.50 (amortized) |
| Hosting (hobby/commercial-small) | $0 – 20 |
| Uptime + error tracking (free tiers) | $0 |
| Email (free tier) | $0 → 20 at growth |
| Backups/PITR addon | $0 → 25 when LEG-086 matters |
| AI API usage | usage-based (cap with SEC-062 alerts!) |
| Payment processing | fee-per-sale only |
| **Realistic total** | **$0–70/mo until traction**, plus payment fees |

**Hard rule:** every dollar above maps to a requirement ID — record the
confirmed price + plan name in that ID's Evidence cell so future agents know
what's already provisioned vs still needed.

---

## 5. When you upgrade: settings that must flip with the plan

Paying changes behavior. Whenever a service moves from free tier to paid,
these configuration changes must be made and recorded against the listed
requirement IDs — an upgrade without the config flip wastes the money.

| Upgrade | Flip these settings / behaviors | Requirement IDs |
|---|---|---|
| UptimeRobot free → paid | Raise check interval 5-min → 1-min; enable SMS/phone alert channel; add monitors for health endpoints | OPS-120 |
| Sentry free → Team | Keep PII scrubbing ON (never disable for quota); raise rate limits; enable release-health + alert rules routing to human channel | OPS-121, SEC-013, SEC-049 |
| Supabase/Neon free → Pro | Enable PITR / extended backup retention; confirm restore window covers LEG-086's deletion-expiry promise; re-run restore drill | SEC-050, LEG-086 |
| Vercel/Netlify Hobby → Pro | Commercial-usage compliance; enable team roles + deploy previews protection; branch/deploy protection on production | SEC-057, SEC-034 |
| Cloudflare free → Pro/Business | Add WAF managed rules + more rate-limit rules; Turnstile stays free — do not pay for it | SEC-032, SEC-052 |
| Resend/Brevo free → paid | Verify dedicated sending domain (SPF/DKIM/DMARC); enable suppression-list sync; confirm unsubscribe webhook still honored | SEC-054, OPS-125, LEG-083 |
| GitHub Free → Team | Branch protection + required reviews now available on private repos — enable for main; add CODEOWNERS | SEC-057 |
| AI APIs (any provider) | On first paid tier: request/confirm ZDR in writing (LEG-090 evidence); set hard monthly spend caps + billing alerts before first production call | LEG-090, SEC-062, SEC-046 |
| Any analytics upgrade | Re-verify consent gating still suppresses tracking pre-consent — plan changes must not silently re-enable tags | LEG-079, OPS-124 |

**Rule:** the upgrade task isn't done when the invoice is paid — it's done
when the Evidence cells for the affected IDs show the post-upgrade config.
