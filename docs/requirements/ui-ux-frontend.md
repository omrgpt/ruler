# UI, UX & Frontend Fixes

**Scope:** All web frontends across projects in this workspace.
**Items:** UIX-105 … UIX-119 (15 requirements).
**Legend:** `[AUTO]` script-checked · `[AGENT]` agent-verified w/ evidence ·
`[MANUAL]` human/device action.

---

## Layout & Mobile

| ID | Requirement | Verification |
|---|---|---|
| UIX-105 | Zero horizontal scroll at any viewport width 320px+: overflowing elements fixed (long words wrapped, tables scroll-contained, media max-width constrained), body-level overflow-x hidden only as last resort after fixing root cause. | `[AGENT]` programmatic sweep: `document.documentElement.scrollWidth <= innerWidth` at 320/375/414px, results recorded |
| UIX-106 | Mobile menu exists and works below breakpoint: opens/closes reliably, focus-trapped while open, closes on route change/Escape/outside tap, reachable by keyboard, doesn't shift layout on open. | `[AGENT]` interaction test at 375px incl. keyboard; cite component |
| UIX-113 | Images compressed and served efficiently: modern formats (WebP/AVIF) or optimized fallbacks, correctly sized (no >200KB hero images), responsive `srcset` where meaningful, lazy-loaded below the fold (`loading="lazy"`), explicit width/height to prevent CLS. | `[AUTO]` oversized-image scan in repo assets; `[AGENT]` Lighthouse image audit results recorded |

## Metadata & Branding

| ID | Requirement | Verification |
|---|---|---|
| UIX-107 | Favicon set complete: standard favicon.ico/PNG + apple-touch-icon + manifest icons; renders crisp at 16–180px; referenced in HTML head; no default framework icon. | `[AGENT]` head-tag inspection + asset presence check |
| UIX-108 | Page titles unique, descriptive, ≤60 chars, template-consistent ("Page – Brand"), every route has one (no untitled/default). Home title states value prop. | `[AUTO]`/`[AGENT]` crawl routes extracting `<title>`, diff table recorded |
| UIX-109 | Meta description present on every indexable page: unique, 120–160 chars, accurately summarizing page; canonical URLs set; no duplicate descriptions across routes. | `[AGENT]` crawl routes extracting meta descriptions, same table as UIX-108 |
| UIX-112 | Copyright year dynamic (auto-updates from current year) — never hardcoded stale year; correct entity name. | `[AUTO]` scan footer for hardcoded year literals; `[AGENT]` confirm `new Date().getFullYear()` usage |

## Pages & Links

| ID | Requirement | Verification |
|---|---|---|
| UIX-110 | Footer links all resolve and are accurate: no dead anchors, contact/legal links point to real pages (pairs with CRO-102 checker), social links valid, footer consistent across all pages. | `[AUTO]` link checker covers footer; `[AGENT]` visual consistency spot check |
| UIX-111 | Custom 404 page: branded, helpful (search/home links), returns proper HTTP 404 status (not soft-404), offered in all locales where site is localized. | `[AGENT]` request bogus URL → verify status code + rendered page |

## Feedback Messages

| ID | Requirement | Verification |
|---|---|---|
| UIX-114 | Success states implemented for every mutating action (forms, purchases, saves): explicit confirmation message/toast near action context, announced to screen readers (`aria-live`), never silent success. | `[AGENT]` trigger each form's happy path → observe confirmation; inventory table |
| UIX-115 | Error states implemented for every failure mode: field-level validation errors inline, network/server failures show retry guidance, messages actionable ("Email already registered") not raw tech dumps, announced to screen readers, input preserved. | `[AGENT]` force failure paths (offline/bad input) per form → observe messaging |
| UIX-116 | No placeholder/stub content shipped: zero `lorem ipsum`, `TODO`, `FIXME`, `placeholder`, dummy emails (`test@test.com`), fake data visible to real users anywhere in production builds. | `[AUTO]` lorem/TODO/placeholder-pattern scan (whitelist dev-only files); `[MANUAL]` final read-through |

## Affordances

| ID | Requirement | Verification |
|---|---|---|
| UIX-117 | Logo links to homepage/site root from every page, with accessible name ("Brand – home"); current-page logo still navigates (or explicitly reloads) rather than dead element. | `[AGENT]` click-through test on sampled pages incl. nested routes |
| UIX-118 | Phone numbers clickable: `tel:` links with international format (`+973…`) wherever displayed, styled distinctly enough to indicate tappable. | `[AUTO]` regex finds phone-like strings lacking tel: wrapper |
| UIX-119 | Email addresses clickable: `mailto:` links wherever displayed; address text matches mailto target; spam-protection (obfuscation) must not break accessibility of the link. | `[AUTO]` regex finds email-like strings lacking mailto: wrapper |

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-24 | Initial import: 15 UI/UX items with stable IDs and verification methods. |
