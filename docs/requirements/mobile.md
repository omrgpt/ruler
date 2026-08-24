# Mobile App Specifics

**Scope:** Any iOS/Android app, React Native/Expo/Flutter/native wrapper shipped
by projects in this workspace.
**Items:** MOB-064 … MOB-068 (5 requirements).
**Legend:** `[AUTO]` script-checked · `[AGENT]` agent-verified w/ evidence ·
`[MANUAL]` human/device/console action.

---

| ID | Requirement | Verification |
|---|---|---|
| MOB-064 | API keys and secrets must not exist in the compiled app bundle. Anything in the binary/APK/IPA is extractable (strings/jadx class-dump). Secrets live behind your own backend proxy; only public identifiers ship in the app. Release builds audited for embedded keys before store submission. | `[AUTO]` audit scan of repo source for key literals; `[MANUAL]` post-build `strings`/jadx spot-check recorded per release |
| MOB-065 | Tokens stored in platform secure storage — iOS Keychain / Android Keystore / EncryptedSharedPreferences. AsyncStorage/localStorage/plain SharedPreferences forbidden for tokens and credentials. Survives app backup policies appropriately (non-restorable flags where offered). | `[AGENT]` cite storage call sites; `[AUTO]` scan for AsyncStorage.setItem with token-like keys |
| MOB-066 | Deep links validated before triggering sensitive actions: verify host/scheme against allowlist, require authenticated session, confirm intent server-side for anything state-changing (password reset, payment, invite acceptance). Unhandled/untrusted links never auto-execute actions. | `[AGENT]` malicious-link test cases (wrong host, missing params, replay) → rejected |
| MOB-067 | Biometrics unlock the UI only; they are never the sole gate for sensitive actions. Server re-verifies session + step-up auth (re-auth/OTP) for payments, credential changes, and data export. Biometric bypass on device changes nothing server-side. | `[AGENT]` demonstrate sensitive action requiring server step-up even when biometric enabled |
| MOB-068 | App Tracking Transparency: if the app (or embedded SDKs: analytics, ads) tracks users across other companies' apps or accesses IDFA, Apple's ATT prompt is triggered and permission honored before any tracking. If no cross-app tracking occurs, document that determination instead. Privacy manifest / data-disclosure labels kept in sync with actual SDK behavior. | `[MANUAL]` device test: fresh install → prompt appears iff tracking used; `[AGENT]` SDK inventory vs disclosure table |
| MOB-069 | *(feature-gated: store distribution)* Store privacy accuracy enforced: Play Data safety section and Apple privacy nutrition labels match actual SDK data flows; Play account-deletion web resource registered and functional (pairs with LEG-080 pipeline); Apple `PrivacyInfo.xcprivacy` present with required-reason API codes for the app AND every listed third-party SDK. Inaccurate labels or missing manifests cause Play removals and Apple build blocks (ITMS-91061). | `[AUTO]` manifest presence/link-liveness scan; `[AGENT]` SDK inventory vs Data safety form |

---

## Changelog

| Date | Change |
|---|---|
| 2026-08-24 | Initial import: 5 mobile items with stable IDs and verification methods. |
| 2026-08-24 | v4: Added MOB-069 (store privacy-label accuracy, deletion web link, privacy manifests). Total now 6. |
