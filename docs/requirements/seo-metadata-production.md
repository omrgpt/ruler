# SEO, Metadata & Production Config

**Scope:** Every deployed web product in this workspace — domain setup,
metadata, crawler files, rendering output, and shipped bundle weight.
**Items:** SEO-096 … SEO-109 (14 requirements).
**Legend:** `[AUTO]` machine-verifiable (not necessarily by the Ruler audit) · `[AGENT]` agent-verified w/ evidence ·
`[MANUAL]` human/console action.

---

## Domain & Identity

| ID | Requirement | Verification |
|---|---|---|
| SEO-096 | Production launches on its own custom domain: no `*.vercel.app`, `*.netlify.app`, `*.pages.dev`, or platform-preview URL as the public face. Apex + `www` both resolve (one 301s to the other), HTTPS certs live on the final domain before announcement. Platform default domains may exist only as redirect sources. | `[MANUAL]` DNS/registrar check; `[AGENT]` curl apex and www → confirm 301 target and final host |

## Metadata & Semantic HTML

| ID | Requirement | Verification |
|---|---|---|
| SEO-097 | No framework boilerplate titles anywhere: "Vite + React", "Create Next App", "React App", etc. replaced by real per-page titles (works together with UIX-108). | `[AUTO]` boilerplate-title scan in audit script |
| SEO-098 | Open Graph + Twitter card tags on every shareable page: `og:title`, `og:description`, `og:image` (1200×630 recommended), `og:url`; `twitter:card` summary_large_image. Images hosted absolute-path on the custom domain. | `[AUTO]` site-wide og: presence scan; `[AGENT]` per-route metadata inspection; `[MANUAL]` paste-link preview test in Slack/X/WhatsApp recorded |
| SEO-099 | Proper semantic structure: exactly ONE `<h1>` per page reflecting the page topic (zero or multiple are both violations), heading levels hierarchical without skips (h1→h2→h3), landmarks (`header/nav/main/footer`) used for layout rather than bare div soup. | `[AUTO]` h1-count scan for static HTML; `[AGENT]` component-level h1 inventory for SPA routes |
| SEO-100 | Canonical URLs on every indexable page (`<link rel="canonical">`), self-referencing by default, protocol+host normalized to the single canonical form chosen in SEO-096. Paginated/filtered variants canonicalize to the clean URL. | `[AUTO]` site-wide canonical presence scan; `[AGENT]` spot-check dynamic routes emit correct absolute canonical |
| SEO-101 | Structured data (JSON-LD Schema.org) on content pages: Organization/WebSite sitewide, plus type-appropriate markup (Product/Offer/FAQPage/Article/BreadcrumbList) where content matches. Markup validates in Google Rich Results Test — invalid markup is worse than none. | `[AUTO]` ld+json presence scan; `[MANUAL]` rich-results validation screenshot recorded |
| SEO-102 | `sitemap.xml` present at the canonical host root, listing all indexable routes with accurate `lastmod`, referenced from robots.txt via `Sitemap:` line. Auto-generated from the router so new pages can't be forgotten. | `[AUTO]` sitemap existence scan; `[AGENT]` diff sitemap URLs vs route table |

## Crawler & Rendering Configuration

| ID | Requirement | Verification |
|---|---|---|
| SEO-103 | `<html lang="...">` set correctly (e.g., `lang="ar"` / `lang="en"`); multi-language sites use per-page lang + `hreflang` alternates. | `[AUTO]` html-lang scan; `[AGENT]` locale route check |
| SEO-104 | `robots.txt` exists and ALLOWS intended crawlers: no accidental `Disallow: /` under `User-agent: *` carried over from staging; sensitive paths (admin, API, account) disallowed deliberately; sitemap line included. | `[AUTO]` presence + block-all detection in audit script; `[MANUAL]` production URL fetch review |
| SEO-105 | `llms.txt` present ONLY as a deliberate choice: if nobody asked for AI-crawler guidance, remove it; if kept, it's maintained (accurate product description, links) and doesn't leak internal paths. | `[AUTO]` llms.txt detection flags file for review |
| SEO-106 | View-source is not empty: primary content/metadata present in server-rendered or pre-rendered HTML for indexable pages (SSR/SSG/prerender). Pure client-rendered shells that populate via JS fail this requirement for crawlers that don't execute JS. Verify with curl, not just a browser. | `[AGENT]` curl 3 key routes → confirm real content in initial HTML; note renderer used |
| SEO-107 | Zero console ERRORS in production build: open every key page/route with devtools console clean. Errors from third-party scripts get suppressed/fixed too — "not my code" still costs trust and masks real issues. | `[MANUAL]` browser walkthrough with console open, results recorded per release |
| SEO-108 | Zero console WARNINGS in production build: React key/hook warnings, deprecation notices, CSP violations, a11y warnings all resolved before launch. Wire CI to treat warnings as errors where the framework supports it. | `[MANUAL]` same walkthrough pass as SEO-107; `[AGENT]` CI config check for warning escalation |

## Performance Budget

| ID | Requirement | Verification |
|---|---|---|
| SEO-109 | JavaScript payload proportionate to the page: no megabyte-scale JS bundles for simple content pages. Route-level code splitting enabled, heavy libraries lazy-loaded, tree-shaking verified (no full-library imports of lodash/icon packs/moment-class libs), modern image formats over JS-based tricks. Served assets >500 KB flagged by audit. | `[AUTO]` bundle-size scan in audit script; `[AGENT]` bundle analyzer output attached for the heaviest 3 routes |

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-24 | v2 creation: 14 SEO/production-config items (SEO-096…SEO-109) imported from the 142-point master list. |
