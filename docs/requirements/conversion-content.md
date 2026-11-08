# Website Conversions & Content Quality

**Scope:** Public marketing pages, landing pages, pricing pages, signup funnels
across projects in this workspace.
**Items:** CRO-085 … CRO-104 (20 requirements).
**Legend:** `[AUTO]` machine-verifiable (not necessarily by the Ruler audit) · `[AGENT]` agent-verified w/ evidence ·
`[MANUAL]` human judgment/action.

These are quality bars, not hard security: an agent may flag violations and
propose fixes, but final copy/design judgment belongs to the owner.

---

## Popups & Attention Management

| ID | Requirement | Verification |
|---|---|---|
| CRO-085 | Max one popup/modal interruption per session intent — no stacked popups, no instant-on-exit-and-entry double triggers, exit-intent fires at most once, frequency-capped via storage. | `[AGENT]` session walkthrough counting interruptions; `[AUTO]` multiple modal-root components flagged for review |
| CRO-097 | Animations purposeful and restrained: entrance/hover transitions ≤400ms, respects `prefers-reduced-motion`, nothing loops infinitely in peripheral vision, no animation-gated content (content visible if JS/animations fail). | `[AUTO]` prefers-reduced-motion media query presence; `[AGENT]` reduced-motion pass renders all content |
| CRO-098 | Video backgrounds must be muted by default, lazy-loaded, compressed, poster-imaged, and skipped entirely on mobile/slow connections (`Save-Data`, small screens); they never block LCP. Auto-playing audio forbidden. | `[AGENT]` inspect video element attributes + mobile branch; Lighthouse LCP recorded |

## Messaging & Structure

| ID | Requirement | Verification |
|---|---|---|
| CRO-086 | Headline passes the clarity test: a stranger states what the product does, for whom, within 5 seconds of landing. No clever-but-opaque taglines as primary H1. | `[MANUAL]` 5-second test with 2+ people, results noted |
| CRO-092 | Copy is specific, not generic-AI filler: no "Unlock your potential"/"Revolutionary AI-powered solution" boilerplate; claims quantified where possible; feature bullets describe user outcomes. Agent-drafted copy is always edited against the owner's real positioning before publishing. | `[MANUAL]` owner copy approval recorded per page |
| CRO-093 | Value proposition explicit above the fold: what it is + who it's for + key benefit/differentiator visible without scrolling on desktop and mobile. | `[MANUAL]` screenshot review at 375px and 1440px widths |
| CRO-091 | No walls of text: paragraphs ≤4 lines rendered, headings every 2–4 paragraphs, lists over prose for options, key info scannable in bold/callouts. | `[AGENT]` longest-paragraph report per page reviewed |
| CRO-101 | Social proof present near conversion points: real testimonials/reviews/logos/user counts with attribution (name/company/photo where permitted), placed adjacent to CTAs/pricing. Fabricated proof forbidden. | `[MANUAL]` proof authenticity confirmed by owner; `[AGENT]` placement check |

## CTAs & Flow

| ID | Requirement | Verification |
|---|---|---|
| CRO-087 | Every page has exactly one clear primary CTA visible without scrolling; label states the action outcome ("Start free trial"), not generic "Submit"/"Learn more" everywhere. | `[AGENT]` per-page CTA inventory: count + viewport visibility |
| CRO-089 | No competing CTAs of equal visual weight fighting in the same viewport; secondary actions visually subordinate (link/ghost button); navigation doesn't rival the primary CTA on funnel pages. | `[MANUAL]` heatmap/eyeflow review; `[AGENT]` button-style audit per viewport |
| CRO-094 | Clear next step after every section/screen: reader never hits a dead end — next CTA, link, or continuation visible at each scroll depth breakpoint. | `[AGENT]` scroll-through check listing dead-end zones |
| CRO-099 | Forms ask only for what's needed now: every field earns its place (justify each field against immediate necessity); progressive profiling preferred over upfront interrogation; required markers + validation inline. | `[AGENT]` form-field justification table per form |

## Trust & Pricing

| ID | Requirement | Verification |
|---|---|---|
| CRO-100 | Pricing transparent: plans/amounts discoverable in ≤1 click from any page selling anything; hidden "contact us"-only pricing requires deliberate strategic justification recorded here. Currency shown for GCC/EU audiences. | `[MANUAL]` pricing-visibility decision recorded; `[AGENT]` click-path verification |
| CRO-104 | Unnecessary cookies/storage eliminated: every non-essential cookie/storage key inventoried with justification; anything without a purpose is removed rather than consented-to (minimization pairs with LEG-079). Inventory lives alongside data inventory. | `[AGENT]` storage inventory diffed each release; unjustified keys deleted |

## Media & Technical Quality

| ID | Requirement | Verification |
|---|---|---|
| CRO-088 | No AI-slop images: obvious malformed AI artifacts (extra fingers, garbled text-in-image, melted objects) rejected; AI-assisted imagery curated and retouched; text inside images avoided (use HTML text) for accessibility + translation. | `[MANUAL]` image-by-image owner review; `[AGENT]` flag images containing rendered text |
| CRO-096 | Stock photos minimal and tasteful: no generic handshake/office/people-in-headsets clichés on hero sections; prefer real product UI/screenshots/team photos; stock only where authentic option absent. | `[MANUAL]` owner media approval |
| CRO-090 | Page speed budget met: Lighthouse mobile performance ≥80 (or documented plan), LCP ≤2.5s p75, CLS ≤0.1, INP ≤200ms; tested on throttled connection representing target market. | `[AUTO]` CI Lighthouse run where wired; `[MANUAL]` PSI results recorded per release |
| CRO-102 | Zero broken links/buttons: internal links resolve, external links return <400, all buttons have handlers; link checker runs in CI or before release; 404s monitored post-launch. | `[AUTO]` link-check script/CI task; `[MANUAL]` post-launch crawl review |
| CRO-103 | Navigation lean: nav items each earn their place — unused/dead nav entries removed, max ~7 top-level items, dropdowns ≤2 levels deep, current-page state indicated. | `[AGENT]` nav inventory with click-through status per item |
| CRO-095 | Mobile experience first-class: layouts verified at 320–430px widths, tap targets ≥44px, sticky elements don't eat viewport, forms usable with mobile keyboards (correct `inputmode`/`autocomplete`). | `[AGENT]` 375px walkthrough screenshots; `[MANUAL]` real-device spot check |

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-24 | Initial import: 20 conversion/content items with stable IDs and verification methods. |
