# Security (App)

> Pre-release security toolkit for mobile and desktop apps (Android, iOS, Windows, macOS, Linux). 18 checks, a copy-paste prompt for each, quick self-tests, and a final test-and-report workflow.

**Pick the right toolkit:** [Web](security-web.md) | **App (this file)** | [General](security-general.md)

Use this for apps that ship as an installed binary or store package, including Flutter, React Native, Kotlin, Swift and desktop apps. For web apps use the Web toolkit. For CLIs, libraries and services use the General toolkit.

---

## Contents

- [Read this first](#read-this-first)
- [Your first hour and red flags](#your-first-hour-and-red-flags)
- [The checklist](#the-checklist)
- [00. Project context and map](#00-project-context-and-map)
- [Checks](#checks)
- [Bonus checks](#bonus-checks)
- [Emergency card](#emergency-card-if-something-goes-wrong)
- [Keep it secure after release](#keep-it-secure-after-release)
- [What your final report looks like](#what-your-final-report-looks-like)
- [Glossary](#glossary)

| # | Check | Severity |
|---|-------|----------|
| A01 | [Enforce auth and authorization on the backend](#a01-enforce-auth-and-authorization-on-the-backend) | CRITICAL |
| A02 | [Keep secrets out of the app bundle](#a02-keep-secrets-out-of-the-app-bundle) | CRITICAL |
| A03 | [Store data securely on the device](#a03-store-data-securely-on-the-device) | HIGH |
| A04 | [Secure network traffic](#a04-secure-network-traffic) | HIGH |
| A05 | [Lock down backend and database rules](#a05-lock-down-backend-and-database-rules) | CRITICAL |
| A06 | [Validate input and prevent injection](#a06-validate-input-and-prevent-injection) | HIGH |
| A07 | [Secure deep links, intents and URL schemes](#a07-secure-deep-links-intents-and-url-schemes) | HIGH |
| A08 | [Harden WebViews and embedded browsers](#a08-harden-webviews-and-embedded-browsers) | HIGH |
| A09 | [Minimise permissions and personal data](#a09-minimise-permissions-and-personal-data) | MEDIUM |
| A10 | [Remove debug mode, verbose logs and data leaks](#a10-remove-debug-mode-verbose-logs-and-data-leaks) | HIGH |
| A11 | [Handle backups, screenshots, clipboard and the app switcher](#a11-handle-backups-screenshots-clipboard-and-the-app-switcher) | MEDIUM |
| A12 | [Harden the release build](#a12-harden-the-release-build) | MEDIUM |
| A13 | [Protect signing keys and the release pipeline](#a13-protect-signing-keys-and-the-release-pipeline) | CRITICAL |
| A14 | [Verify purchases and entitlements on the server](#a14-verify-purchases-and-entitlements-on-the-server) | CRITICAL |
| A15 | [Update dependencies, plugins and SDKs](#a15-update-dependencies-plugins-and-sdks) | HIGH |
| A16 | [Review third-party SDKs, analytics and push](#a16-review-third-party-sdks-analytics-and-push) | MEDIUM |
| A17 | [Run a thorough security review](#a17-run-a-thorough-security-review) | REVIEW |
| A18 | [Test the protections and give me a report](#a18-test-the-protections-and-give-me-a-report) | VERIFY |

---

## Read this first

An app is code you hand to strangers. They can unpack it, read it, patch it and replay its traffic. This toolkit helps you decide what may live inside the app, what must live on a server, and what the operating system can leak on its own. You do not need to be a security expert, you just need to know what to ask, and how to check the answer.

### How to use this toolkit

1. **Save a checkpoint.** Commit your code and work on a branch. If anything breaks, you can roll back.
2. **Map your project.** Fill in the Project Context block, then run Prompt 00. Claude creates `SECURITY_MAP.md`.
3. **Work through the checks.** Run checks one at a time. Do the 2-minute self-check, paste the prompt, review the changes, tick "Done when".
4. **Review, test, report.** Run the review check, then the final test-and-report check to prove every fix and get `SECURITY_REPORT.md`.

### How each check is laid out

| Block | Purpose |
|-------|---------|
| What this means | The idea in plain English, no jargon. |
| What goes wrong | A realistic attack on a typical project. |
| 2-minute self-check | A quick test you can run yourself, before and after. |
| Claude prompt | A detailed, copy-paste prompt: audit, fix, verify, report. |
| Done when | Clear finish line. Do not move on until every box is true. |
| Watch out for | Common traps and stack-specific gotchas. |

### Tips for getting great results

- **Give the AI your whole codebase.** Use a tool that can read and edit files (Claude Code, Cursor, Windsurf, or similar).
- **One check per conversation.** Start fresh each time and paste your Project Context first.
- **Read the findings table before accepting changes.** If something does not make sense, ask "show me the code that proves this".
- **Never paste real secrets into a chat.** Refer to them by variable name.
- **Test after every check.** Run the app or tool and its tests. Security fixes occasionally break things.

> [!NOTE]
> **An honest note.** AI reviewers can miss real problems and occasionally invent fake ones. This toolkit raises your baseline but is not a guarantee. If you handle payments, health data, children's data or many users, get a professional review before release.

> [!TIP]
> **Fully offline app (no backend, no accounts)?** Mark A01, A05 and A14 as N/A and focus on A02, A03, A06, A07, A09, A10, A11, A12, A13 and A15. Offline apps are strong on privacy. Keep that promise true by also checking A16.

---

## Your first hour and red flags

If you are releasing soon and can only do a little, do these in this order.

1. **A02** Keep secrets out of the app bundle
2. **A13** Protect signing keys and the release pipeline
3. **A01** Enforce auth and authorization on the backend
4. **A05** Lock down backend and database rules
5. **A03** Store data securely on the device
6. **A04** Secure network traffic
7. **A10** Remove debug mode and sensitive logs
8. **A14** Verify purchases on the server

**Red flags: drop everything if any is true**

| Red flag | Go to |
|----------|-------|
| A secret key (AI, payment, admin, SMTP) appears in app code or assets | A02 |
| A keystore or signing password is in the repository or its history | A13 |
| Changing an ID in a request returns someone else's data | A01, A05 |
| Your backend rules are in test mode or "allow if true" | A05 |
| Auth tokens are stored in plain SharedPreferences or files | A03 |
| The app accepts any certificate, or allows cleartext traffic in release | A04 |
| Release logs show tokens or personal data | A10 |
| Pro or paid features unlock from a local flag or a client callback | A14 |
| An exported activity or deep link skips login | A07 |
| Your store accounts or GitHub have no MFA | A13 |

---

## The checklist

| # | Check | Severity | Notes / date done |
|---|-------|----------|-------------------|
| | **Identity & Access** | | |
| A01 | Enforce auth and authorization on the backend | CRITICAL | |
| | **Secrets & Keys** | | |
| A02 | Keep secrets out of the app bundle | CRITICAL | |
| | **Data & Inputs** | | |
| A03 | Store data securely on the device | HIGH | |
| A05 | Lock down backend and database rules | CRITICAL | |
| A06 | Validate input and prevent injection | HIGH | |
| A09 | Minimise permissions and personal data | MEDIUM | |
| A11 | Handle backups, screenshots, clipboard and the app switcher | MEDIUM | |
| A14 | Verify purchases and entitlements on the server | CRITICAL | |
| A16 | Review third-party SDKs, analytics and push | MEDIUM | |
| | **Network & Platform** | | |
| A04 | Secure network traffic | HIGH | |
| A07 | Secure deep links, intents and URL schemes | HIGH | |
| A08 | Harden WebViews and embedded browsers | HIGH | |
| | **Deployment & Supply Chain** | | |
| A10 | Remove debug mode, verbose logs and data leaks | HIGH | |
| A12 | Harden the release build | MEDIUM | |
| A13 | Protect signing keys and the release pipeline | CRITICAL | |
| A15 | Update dependencies, plugins and SDKs | HIGH | |
| | **Monitoring & Response** | | |
| A17 | Run a thorough security review | REVIEW | |
| A18 | Test the protections and give me a report | VERIFY | |

---

## 00. Project context and map

`SETUP` | 10 min | do this first

> Give Claude the big picture once, so every check after this is sharper.

Fill in the block below once, save it, and paste it at the top of every new conversation, before the check's prompt.

```text
PROJECT CONTEXT (paste this above any prompt in this toolkit)
- What the app does: [e.g. offline music player with lyrics and stats]
- Who uses it: [public consumers / my team / businesses]
- Platforms: [Android / iOS / Windows / macOS / Linux]
- Built with: [Flutter / React Native / Kotlin / Swift / other] and tool: [Claude Code / Cursor / other]
- Backend: [none, fully offline / Firebase / Supabase / my own API / other]
- Auth: [none / Firebase Auth / Google or Apple sign-in / custom]
- Local storage: [SharedPreferences / SQLite / Hive / Isar / files / other]
- Third-party SDKs: [analytics, ads, crash reporting, push, payments...]
- Distribution: [Play Store / App Store / direct APK / Microsoft Store / other]
- Sensitive data: [emails, payments, health, location, messages, files...]
- Status: [not released yet / live with ___ users]
- Anything I'm worried about: [optional]
```

Then run Prompt 00. It creates `SECURITY_MAP.md`, a single map of your entry points, data, secrets and risky features. Later prompts use it.

**Claude prompt (00): map my project** - run once at the start:

```text
Act as a senior mobile and desktop application security engineer. Before we change anything, I want you to fully understand this app's security surface. Inspect the whole codebase. Do NOT modify any application code in this step.

Create a file called SECURITY_MAP.md containing:
1. Stack: platforms, language and framework versions, build system, minimum OS versions, signing setup and distribution channel.
2. Local data: everything the app stores (preferences, databases, files, caches) and how sensitive each item is.
3. Backend and network: every server, cloud service and third-party API the app calls, the transport used, and how the app authenticates.
4. Entry points: a table of EVERY way outside input reaches the app: deep links, URL schemes, Android exported components, share targets, file associations, notification handlers, widgets, WebViews, clipboard, QR/NFC/Bluetooth, imports. Include: name, purpose, requires login?, inputs accepted.
5. Third-party SDKs and plugins: each one, what it is used for, what data and permissions it adds.
6. Secrets and config: names only (NEVER values), where each is used, and whether it ships in the app.
7. Permissions: every permission in the final merged manifest and the feature that uses it.
8. Risky features: purchases, payments, file import/export, backups, AI/LLM calls, anything that fetches URLs, admin tools.
9. Questions: anything you could not determine from the code that I need to answer.

Then give me your TOP 5 security concerns, ranked, in plain English, each with the check number from this toolkit that addresses it. No fixes yet.
```

---

## Checks

Each check follows the same layout. Run one check per conversation.

## A01. Enforce auth and authorization on the backend

`CRITICAL` | Identity & Access | 20-40 min

> The app is only a client. Every rule that matters must be enforced where an attacker cannot edit it: the server.

**What this means**

Anything inside a mobile or desktop app can be unpacked, patched and replayed. Hiding a screen or disabling a button is only UI. Every API the app calls must verify who the caller is and what they may do, on the server, on every request.

**What goes wrong**

Your app shows the Premium tab when a local isPremium flag is true. An attacker flips the flag in a modified build, or replays the API call from a script, and reads premium data for free. Or they change /notes/18 to /notes/19 and read someone else's note.

**2-minute self-check**

- Capture a request from the app with a proxy (mitmproxy, Charles or Proxyman) on a test device. Replay it with the token removed. You should get 401.
- Replay it with another test user's object ID. You should get 403 or 404.
- Search the code for isPremium, isAdmin, role == and similar flags. Each one must also be checked on the server.

**Claude prompt (A01)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure every rule that matters is enforced on the backend, not just in the app UI.

AUDIT
1. List every backend endpoint, cloud function, database rule and third-party API the app calls. For each: needs login? checked on the SERVER? which roles?
2. Confirm identity comes from a verified token or session on the server (signature, expiry, audience), never from a user ID the app sends.
3. Find every client-side flag that gates features or data (premium, admin, trial, feature flags) and confirm the server enforces the same rule.
4. Check token handling: short-lived access tokens, refresh-token rotation, revocation on logout and on password change.
5. If Google/Apple/OAuth sign-in is used, confirm the ID token is validated on the server, not trusted from the app.

FIX
- Add one reusable server-side helper that requires an authenticated user and call it at the top of every protected handler.
- Move every business rule that matters to the server. Keep the client check only for user experience.
- Add object-level ownership checks to every endpoint that takes an ID.

VERIFY
For every protected endpoint, give me a curl command with no token that returns 401, plus one using another user's ID that returns 403 or 404.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Every protected endpoint returns 401 without a valid token.
- [ ] The user ID always comes from the verified token, never from the request.
- [ ] Every client-side gate is also enforced on the server.
- [ ] Logout and password change revoke refresh tokens.

**Watch out for**

- **Obfuscation is not authorization.** Anyone can patch the app or call your API directly.
- **Fully offline app?** If there is no backend, mark this check N/A. The risk moves to device storage (A03) and the update channel (A15).
- **Social sign-in:** validate the ID token on your server. Do not trust the email address the app sends.

---

## A02. Keep secrets out of the app bundle

`CRITICAL` | Secrets & Keys | 15-30 min

> Every installed app is a zip file anyone can open. Secret keys live on the server only.

**What this means**

Strings, keys, tokens and URLs inside the bundle can be extracted with free tools in minutes, even if the code is obfuscated. Secret keys belong on your server. The app should carry only values that are designed to be public.

**What goes wrong**

A weather app ships an OpenAI key in its Dart, Kotlin or Swift code. Someone downloads the APK, runs strings or jadx, copies the key and runs up a four-figure bill on your account.

**2-minute self-check**

- Build a release APK/AAB/IPA, unzip it (an APK is a zip) and search for sk_, sk-, AKIA, ghp_, Bearer, api_key, secret, password, private_key.
- Run strings on the release binary (or use jadx, apktool or MobSF) and search for the same words.
- Check .env files, google-services.json, GoogleService-Info.plist and build-time defines: only publishable values may be there.

**Claude prompt (A02)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Find every key, token or credential that ships inside the app and move every secret to a server.

AUDIT
1. Search the whole codebase and assets for hard-coded keys, tokens, passwords and private keys (patterns like sk_, sk-, pk_, AKIA, ghp_, xox, Bearer, api_key, secret, password, private_key, long random strings). Include assets/, .env files bundled as assets, gradle.properties, Info.plist and build-time defines (for example --dart-define).
2. List every third-party service the app talks to: which key, called from the app or from a server, and whether the key is PUBLISHABLE or SECRET. Usually publishable: Stripe pk_ keys, Firebase client config, map keys restricted to my package name or bundle ID and signing SHA-1. Always secret: Stripe sk_ keys, AI/LLM keys, database admin or service_role keys, SMTP/SMS keys, webhook secrets, signing keystores.
3. Build the release artifact and search its contents so we know what actually ships.
4. Check Git history for secrets that were ever committed.

FIX
- Move every secret to server-only configuration and replace each app call that needs one with a narrow server endpoint that requires sign-in, validates input and is rate-limited. Do NOT build a generic proxy that forwards any URL or body.
- For publishable keys that stay in the app, tell me which restrictions to set (package name plus SHA-1, bundle ID, allowed APIs, quotas).
- Remove unused keys and config files from the bundle.

VERIFY
Rebuild the release artifact and show me that the same search finds no secrets. List every secret that has EVER been in the app or repo so I can rotate it.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] A search of the release artifact finds no secret keys.
- [ ] All third-party calls that need a secret go through your own server.
- [ ] Publishable keys have package/bundle and API restrictions.
- [ ] You have a list of keys to rotate.

**Watch out for**

- **Obfuscation hides names, not strings.** Flutter --obfuscate does not hide string literals or --dart-define values.
- **Removing a key does not un-leak it.** Rotate anything that has shipped.
- **Assets ship.** A .env file listed as an asset is inside every download.

---

## A03. Store data securely on the device

`HIGH` | Data & Inputs | 20-40 min

> Tokens and personal data are stored the way the data deserves, not the way the default API makes easy.

**What this means**

Phones get lost, backed up, rooted and shared. Tokens and credentials belong in the system Keychain (iOS) or Keystore-backed storage (Android). Plain files, SharedPreferences and unencrypted databases can be read on a rooted device or from a backup.

**What goes wrong**

The app saves the login token in SharedPreferences. Someone with a rooted phone, or anyone who gets a device backup, reads it and is logged in as that user, long after the real user changed their password.

**2-minute self-check**

- On a debug build, inspect the app sandbox (adb run-as on Android, the simulator container on iOS) and look for tokens, passwords or personal data in plain text.
- Search the code for SharedPreferences, UserDefaults, plain files and external storage that hold tokens, passwords or personal data.
- Log out, then inspect the sandbox again. Caches, tokens and personal data should be gone.

**Claude prompt (A03)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure everything the app stores on the device is stored securely and minimally.

AUDIT
1. Inventory everything the app persists (preferences, SQLite/Room/Hive/Isar/Realm, files, caches, cookies, WebView storage) and how sensitive each item is.
2. Tokens, refresh tokens, passwords and keys must be in Keychain or Keystore-backed storage (for example flutter_secure_storage, EncryptedSharedPreferences), never in plain preferences or files.
3. Sensitive local databases should be encrypted (for example SQLCipher). Nothing sensitive on shared or external storage. Files created with private permissions.
4. Logout and account deletion must clear tokens, caches, temp files and local personal data.
5. Store as little as possible. Flag data we keep that we do not need.

FIX
- Move secrets to secure storage and migrate existing users safely (read the old value once, write to secure storage, delete the old one).
- Encrypt or remove sensitive data at rest. Clear data on logout and deletion.

VERIFY
Show me where each data type is stored now, and a test or script that proves no token or password is readable in plain preferences or files.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Tokens and credentials live only in Keychain/Keystore-backed storage.
- [ ] No sensitive data on external or shared storage.
- [ ] Logout and account deletion clear local data.
- [ ] You can list every piece of data the app stores.

**Watch out for**

- **Secure storage is not a vault** on a compromised device. Avoid long-lived secrets.
- **iOS Keychain items can survive uninstall.** Clear them on first launch after reinstall if needed.
- **Flutter:** SharedPreferences and Hive boxes are plain unless you encrypt them.

---

## A04. Secure network traffic

`HIGH` | Network & Platform | 15-30 min

> Every connection uses TLS with valid certificates, and the app never silently accepts a bad one.

**What this means**

Phones connect over untrusted Wi-Fi. Cleartext traffic and disabled certificate checks let anyone on the network read or change data. The usual cause is a "temporary" setting added to fix a staging error that then ships.

**What goes wrong**

A developer adds badCertificateCallback = (cert, host, port) => true to get past a staging error and ships it. On a cafe network an attacker presents a fake certificate and the app sends the login token straight to them.

**2-minute self-check**

- Search the code for badCertificateCallback, trust-all TrustManagers, ALLOW_ALL hostname verifiers, NSAllowsArbitraryLoads, usesCleartextTraffic="true" and http:// URLs.
- Run the release build through a proxy (mitmproxy) WITHOUT installing its CA. Requests should fail.
- Check the release manifest and Info.plist for cleartext exceptions.

**Claude prompt (A04)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure the app only talks over properly validated TLS connections.

AUDIT
1. Find every network client in the app and its SDKs. List the hosts they call.
2. Confirm TLS 1.2+ everywhere, no http:// endpoints, no trust-all certificate handling, no disabled hostname verification.
3. Check platform settings: iOS App Transport Security (NSAllowsArbitraryLoads must be false) and Android networkSecurityConfig (cleartext disabled in release).
4. Make sure debug-only proxies, test certificates and staging hosts are behind build flags and absent from release.
5. For high-risk apps (payments, health, private messages) recommend certificate or public-key pinning WITH a backup pin and a rotation plan.

FIX
- Remove every trust-all handler and cleartext exception from release configuration.
- Replace http:// URLs with https://.
- Add pinning only if I confirm, and explain how a certificate change would be shipped.

VERIFY
Give me a checklist and commands to show the release build rejects a bad certificate and refuses cleartext requests.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] No trust-all certificate code in the release build.
- [ ] Cleartext traffic is disabled in release configuration.
- [ ] All endpoints use https://.
- [ ] Pinning, if used, has a backup pin and an update plan.

**Watch out for**

- **Pinning can lock out every user** when a certificate rotates and no update ships in time.
- **Debug network config leaking into release** is the most common mistake. Check the final manifest.
- **SDKs bring their own endpoints.** Review analytics and ads hosts too.

---

## A05. Lock down backend and database rules

`CRITICAL` | Data & Inputs | 30-60 min

> Users can read and change only their own data, even if they talk to the backend directly.

**What this means**

If the app talks straight to Firebase, Supabase, Realm or a similar service, the public config in the app lets anyone query your backend. The rules, not the app, decide what they get. For your own API, every query must be scoped to the right user.

**What goes wrong**

Ana changes an order ID from 18 to 22 in a request and sees Ben's address. Or a Firestore rule left in test mode lets anyone with the app's public config download the whole users collection.

**2-minute self-check**

- Create two test accounts. As account A, replay a request with an ID belonging to B. Expect 403 or 404.
- Firebase: your rules must not contain "allow read, write: if true" or a date-based test-mode rule. Supabase: every table shows RLS enabled and the Security Advisor is clean.
- Use only the public config (no login) to query a private collection. You should get nothing.

**Claude prompt (A05)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure every user can only read and change the data they are allowed to, and that the backend itself is locked down.

AUDIT
1. List every table, collection and storage bucket. For each, who should read, create, update and delete (owner, team, admin, public).
2. Work out how the app reaches the backend: direct SDK, own API, or both.
3. Direct SDK access: Postgres needs Row Level Security on every exposed table with separate SELECT, INSERT, UPDATE, DELETE policies based on auth.uid() and WITH CHECK on writes. Firebase rules must be per path and depend on request.auth.uid and validate written fields. Storage must be private by default.
4. Own API: every query that fetches or changes by ID must also check ownership (look for IDOR).
5. Admin or service keys must exist only on servers or cloud functions, never in the app.
6. Responses must not return sensitive fields (password hashes, tokens, other users' data).

FIX
- Write the missing rules, policies and ownership checks. Show each one in full with a one-line plain-English explanation.

VERIFY
Write a test or script using two test users that proves user A cannot read, update or delete user B's data or files, and that an unauthenticated client gets nothing private.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Rules are enabled on every table, collection and bucket.
- [ ] User A cannot read, edit or delete user B's data (tested, not assumed).
- [ ] Admin keys appear only in server code.
- [ ] Responses never include other users' private fields.

**Watch out for**

- **Rules enabled with no policies block everything; rules disabled allow everything.** Neither is what you want.
- **Offline-only app?** Mark this check N/A.
- **Cloud functions run with admin power.** They must check permissions themselves.

---

## A06. Validate input and prevent injection

`HIGH` | Data & Inputs | 20-40 min

> Everything that enters the app from outside is untrusted: forms, files, links, QR codes, notifications and server responses.

**What this means**

Input reaches an app from many places, not only text fields: deep links, share targets, imported files, QR and NFC data, clipboard, push payloads and API responses. Unvalidated input can break parsers, corrupt local databases or inject into SQL queries and file paths.

**What goes wrong**

The app builds a local SQLite query by joining a search string. Someone enters a crafted string and reads or deletes rows. Or an imported backup file contains ../ paths and overwrites files outside the app's folder.

**2-minute self-check**

- Search the code for raw SQL built with string concatenation or interpolation (rawQuery, execute with $variables).
- Import a deliberately broken or oversized file (huge JSON, wrong type, ../ in names). The app should reject it without crashing.
- Type very long text, emoji and special characters into every field.

**Claude prompt (A06)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure every external input is validated and no injection or path traversal is possible.

AUDIT
1. List every input source: text fields, deep links, intents, share and file handlers, QR/NFC/Bluetooth, clipboard, push payloads, backend responses.
2. Check local database access uses parameterized queries or the ORM, never string-built SQL.
3. Check file imports and archives for path traversal (../, absolute paths, zip slip), size limits, type checks and safe parsing.
4. Check parsers (JSON, XML, CSV, image, audio metadata) have size and depth limits and handle bad data without crashing.
5. Check server responses are validated too: types, ranges and required fields, not blindly trusted.

FIX
- Use parameterized queries everywhere. Validate type, length, range and format at each entry point.
- Add size limits and safe path handling to imports. Fail safely with a clear message.

VERIFY
Give me a list of malformed inputs per entry point and tests that show each is rejected or handled safely.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] No SQL is built by string concatenation.
- [ ] Every import and external input is validated and size-limited.
- [ ] Bad input produces a safe error, not a crash or data loss.
- [ ] Server responses are validated before use.

**Watch out for**

- **Trusting your own backend is still trust.** Validate what comes back.
- **Metadata parsers** (audio tags, EXIF, archives) are a common crash and exploit source.
- **Crashes are a security signal.** An input that crashes the app may be exploitable.

---

## A07. Secure deep links, intents and URL schemes

`HIGH` | Network & Platform | 20-40 min

> Other apps and websites can open yours. Only intended entry points should be reachable, and only with safe input.

**What this means**

Deep links, custom URL schemes, Android intents, share targets, widgets, notification taps and exported components are doors into your app. Any app on the phone can try them. Custom schemes can be hijacked by another app that registers the same scheme.

**What goes wrong**

A link myapp://reset?token=abc opens the reset screen. A malicious app registers the same scheme, receives the token and takes over the account. Or an exported Android activity skips the login check when launched directly.

**2-minute self-check**

- Search the Android manifest for exported="true" components and the iOS Info.plist for URL schemes and associated domains.
- From a terminal, launch each exported activity or deep link with adb or xcrun simctl openurl while logged out. It must not skip login.
- Try odd values in link parameters (very long, ../, javascript:, other hosts).

**Claude prompt (A07)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure every way another app or website can open this app is intended, authenticated and validated.

AUDIT
1. List every entry point: deep links, URL schemes, Android exported activities, services, receivers and content providers, share targets, file associations, widgets, notification handlers.
2. Prefer verified links (Android App Links, iOS Universal Links) over custom schemes for anything sensitive.
3. Confirm exported components are exported only when needed, and that each enforces authentication and validates every extra and parameter.
4. Never put tokens, passwords or reset secrets in URLs that another app can read. Check redirect parameters only allow expected destinations.
5. Check pending intents and notification actions use the immutable flag and explicit targets.

FIX
- Set exported="false" wherever possible. Add auth and validation to the rest.
- Move sensitive flows to verified links and validate every parameter.

VERIFY
Give me commands to launch every entry point while logged out and with hostile parameters, and show each is handled safely.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Only necessary components are exported.
- [ ] Every entry point checks login and validates input.
- [ ] Sensitive flows use verified links, not bare custom schemes.
- [ ] No secrets travel in link parameters.

**Watch out for**

- **Custom URL schemes are not unique.** Any app can claim them.
- **Exported by default:** components with intent filters were exported on older Android versions. Check the merged manifest, including SDK additions.
- **Notification taps are entry points.** Validate their payloads.

---

## A08. Harden WebViews and embedded browsers

`HIGH` | Network & Platform | 20-40 min

> A WebView is a browser inside your app. Treat what it loads as hostile.

**What this means**

If the app shows web content, a WebView with JavaScript and native bridges enabled can let a malicious page call into your app, read local files or steal tokens. Loading arbitrary URLs makes it worse.

**What goes wrong**

The app opens links inside a WebView with a JavaScript bridge that returns the auth token. A link to a hostile page calls the bridge and sends the token away.

**2-minute self-check**

- Search the code for WebView, webview_flutter, InAppWebView, addJavascriptInterface and loadUrl.
- Open the WebView on an attacker-style page (any test page you control). Can it call your bridges or read local files?
- Check which URLs the WebView can navigate to. It should be a short allowlist.

**Claude prompt (A08)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure every WebView and embedded browser in the app is locked down.

AUDIT
1. List every WebView and every page it can load.
2. Allow only https and a strict domain allowlist. Block navigation to other hosts, file:// and intent:// URLs.
3. Disable JavaScript unless needed. Turn off file access, content access and universal access from file URLs.
4. JavaScript bridges must expose the smallest possible functions, never tokens or secrets, and must check the page origin.
5. Prefer the system browser or a custom tab for external content.

FIX
- Apply the allowlist and settings. Remove or narrow every JavaScript bridge.

VERIFY
Show me the final WebView settings and a test that a page on a non-allowed host cannot load or call a bridge.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] WebViews load only allowlisted https hosts.
- [ ] No bridge exposes tokens or sensitive actions.
- [ ] File and content access are off.
- [ ] External links open in the system browser.

**Watch out for**

- **Mixed content and redirects:** an allowed host that redirects elsewhere can bypass a naive check.
- **No WebViews?** Mark this check N/A.
- **Third-party SDKs** (ads, support chat) may open WebViews of their own.

---

## A09. Minimise permissions and personal data

`MEDIUM` | Data & Inputs | 15-30 min

> Ask only for what the app truly needs, when it needs it, and collect no more data than the feature requires.

**What this means**

Every permission is a promise you must keep and a target for attackers. Unused permissions get apps flagged and users to uninstall. Data you do not collect cannot leak. Privacy laws (GDPR, CCPA, Indonesia's PDP Law and others) may also require deletion and disclosure.

**What goes wrong**

A flashlight-style app requests contacts and location because a plugin added them. A breach or a store review turns that into a crisis.

**2-minute self-check**

- Open the final merged AndroidManifest and Info.plist. For each permission, name the feature that needs it.
- Fresh install the app. It should not ask for anything on first launch that the first screen does not need.
- Check what personal data leaves the device: analytics, crash reports and backend calls.

**Claude prompt (A09)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure the app requests the fewest permissions and collects the least data it can.

AUDIT
1. List every permission requested (including those added by plugins and SDKs) and the exact feature that uses it. Flag unused ones.
2. Make permission requests contextual: ask at the moment of use with a clear reason, and handle denial gracefully.
3. Map every piece of personal data the app collects, where it is stored, who sees it, which third parties receive it and how long it is kept.
4. Flag data we do not need, avoid sending personal data to analytics or crash tools, and make sure account deletion removes data locally, on the backend and at third parties.
5. List what the privacy policy and the store data-safety forms must say. Note what needs legal review.

FIX
- Remove unused permissions (including plugin-added ones via manifest merge rules). Reduce collected data.
- Add or fix in-app deletion and export where required.

VERIFY
Give me a table of permission, feature that needs it, and the file where it is used, and confirm the final manifest matches it.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Every permission maps to a real feature.
- [ ] Permissions are requested in context.
- [ ] You can list all personal data collected and where it goes.
- [ ] Store data disclosures match what the app really does.

**Watch out for**

- **Plugins add permissions.** Read the merged manifest, not just yours.
- **An offline-first app has a strong story.** If nothing leaves the device, say so and keep it true.
- **Wrong store disclosures** can get an app removed.

---

## A10. Remove debug mode, verbose logs and data leaks

`HIGH` | Deployment & Supply Chain | 15-30 min

> Release builds should reveal nothing useful: no tokens in logs, no debug switches, no test endpoints.

**What this means**

Logs on a phone can be read over USB and by other tools, and crash reports travel to third parties. Debug flags, test menus and staging URLs left in a release give attackers a map and sometimes a back door.

**What goes wrong**

The app prints the full API response, including the auth token, to the log in every build. Anyone who connects the phone to a laptop reads it. A hidden "enable test mode" gesture also unlocks free premium.

**2-minute self-check**

- Run the release build while watching logcat (Android) or Console (iOS). Do tokens, emails or full responses appear?
- Search the code for print, debugPrint, Log.d, NSLog and console.log that include user data or secrets.
- Check the release manifest: android:debuggable must be false. Look for test menus, staging URLs and feature flags.

**Claude prompt (A10)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure release builds expose no debug switches, sensitive logs or test back doors.

AUDIT
1. Find every log statement and check none prints tokens, passwords, personal data or full request and response bodies in release.
2. Confirm release builds are not debuggable, have assertions disabled and remove debug banners, test menus and developer gestures.
3. Check crash and analytics tools do not receive personal data or secrets, and that user IDs are pseudonymous.
4. Find staging or test endpoints, hard-coded test accounts and feature flags that unlock paid or admin features.
5. Check error messages shown to users do not reveal internals.

FIX
- Strip or guard logs behind debug-only flags. Remove test code paths and hard-coded test accounts from release.
- Scrub personal data from crash and analytics events.

VERIFY
Show me the release logs for a full session with no sensitive data, and the manifest and config proving the build is not debuggable.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Release builds log no secrets or personal data.
- [ ] android:debuggable is false and debug menus are gone.
- [ ] Crash reports contain no personal data.
- [ ] No test endpoints or accounts are reachable.

**Watch out for**

- **Log wrappers can still print in release.** Check the real output.
- **Flutter:** kDebugMode guards help but verify with a release build.
- **Crash tools** often capture breadcrumbs. Review what they record.

---

## A11. Handle backups, screenshots, clipboard and the app switcher

`MEDIUM` | Data & Inputs | 15-30 min

> Data should not leak through the side doors of the operating system.

**What this means**

The OS can back up app data to the cloud or a computer, take screenshots for the app switcher, and share the clipboard with other apps. For apps that show sensitive screens, each of these is a leak unless you handle it.

**What goes wrong**

A banking-style screen is captured in the recent-apps thumbnail. A copied one-time code stays on the clipboard for any app to read. App data is restored from an unencrypted backup onto another device.

**2-minute self-check**

- Open a sensitive screen, press Home and look at the recent-apps thumbnail. Does it show private data?
- Check android:allowBackup and the iOS backup settings. Decide deliberately what may be backed up.
- Copy something sensitive from the app and paste it elsewhere. Does it persist?

**Claude prompt (A11)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure data does not leak through backups, screenshots, the clipboard or the app switcher.

AUDIT
1. Decide per data type whether it may be included in backups, and configure Android allowBackup, backup rules and iOS file protection accordingly.
2. Hide sensitive content in the app switcher and block screenshots on the most sensitive screens (for example Android FLAG_SECURE).
3. Avoid putting sensitive values on the clipboard. If needed, expire or clear them quickly.
4. Check keyboard learning, autofill and text suggestions are off for sensitive fields.
5. Check files exported or shared by the app do not include more data than needed.

FIX
- Apply the backup rules, screen protection and clipboard handling.

VERIFY
Give me a manual test script for the app switcher, backup and clipboard behaviours on both platforms.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Backup behaviour is a deliberate choice, not a default.
- [ ] Sensitive screens are hidden in the app switcher.
- [ ] Sensitive values are not left on the clipboard.
- [ ] Sensitive fields disable suggestions and autofill where appropriate.

**Watch out for**

- **Backups are great for users.** Do not just disable them. Exclude only what is sensitive.
- **Screenshot blocking** can annoy users and break accessibility. Apply it narrowly.
- **No sensitive screens?** Mark this check mostly N/A.

---

## A12. Harden the release build

`MEDIUM` | Deployment & Supply Chain | 20-45 min

> Make reverse engineering and tampering harder, and never rely on the app itself as the only guard.

**What this means**

Obfuscation, shrinking and integrity checks do not make an app unbreakable, but they raise the cost of copying, patching and cloning it. They are a layer, not a lock. Anything the server must trust has to be verified server-side.

**What goes wrong**

A cloned and re-signed copy of your app with ads removed and licence checks patched circulates online. Or a rooted device runs a tool that edits your game state.

**2-minute self-check**

- Decompile your release artifact (jadx, apktool). How readable is the result?
- Check the build config for minify, shrink and obfuscation flags in the release variant.
- Check that debug symbols and mapping files are stored privately, not shipped.

**Claude prompt (A12)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure the release build is hardened without breaking the app.

AUDIT
1. Review the release build configuration: code shrinking and obfuscation (R8/ProGuard; for Flutter, --obfuscate with --split-debug-info), stripped symbols, no debug code.
2. Check release signing and that the mapping or symbol files are saved privately for crash decoding.
3. Recommend platform integrity signals (Play Integrity, App Attest) ONLY where a server must trust the client, and explain the limits.
4. Recommend root/jailbreak or tamper detection only for high-risk apps, as a signal and not a hard block.
5. Check no test keys, debug certificates or developer settings are in the release.

FIX
- Enable obfuscation and shrinking in release and fix what breaks. Store symbol files privately.
- Add integrity checks only where I confirm.

VERIFY
Show me the release config and a before and after of the decompiled output, and confirm the app still works end to end.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Release builds are shrunk and obfuscated.
- [ ] Symbol and mapping files are stored privately.
- [ ] No debug code or test keys ship.
- [ ] Anything the server must trust is verified server-side.

**Watch out for**

- **Obfuscation can break reflection and plugins.** Test the release build, not just debug.
- **Root detection is a cat-and-mouse game.** Do not block honest users on false positives.
- **Integrity checks need a backend** to be meaningful.

---

## A13. Protect signing keys and the release pipeline

`CRITICAL` | Deployment & Supply Chain | 20-45 min

> Whoever holds your signing key can publish a malicious update that your users will trust.

**What this means**

Your signing key and store accounts are the root of trust for every update. A leaked keystore in a public repo, a CI secret exposed in logs, or an account without MFA lets an attacker ship a trojan version under your name.

**What goes wrong**

A keystore and its password are committed to GitHub "for the CI". Someone finds them, signs a modified app and distributes it as an update.

**2-minute self-check**

- Search the repository and its history for .jks, .keystore, .p12, .pem, key.properties and passwords.
- Check your store accounts, GitHub and CI have MFA on.
- Check CI logs and settings for secrets printed or shared with forks and pull requests.

**Claude prompt (A13)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure the keys and pipeline that publish this app cannot be abused.

AUDIT
1. Find every signing key, keystore, certificate, provisioning profile and passwords file and where it lives. None may be in the repo or its history.
2. Recommend store-managed signing (Play App Signing, Apple-managed certificates) and keeping the upload key offline and backed up in two places.
3. Review the CI pipeline: secrets stored as encrypted CI secrets, not available to untrusted pull requests, never echoed to logs, minimum permissions on tokens.
4. Releases only from protected branches or tags, with required reviews and green checks.
5. List every account that can publish or change the app (stores, repository, CI, domains, backend) and the MFA and role state for each.

FIX
- Remove keys from the repo and history, rotate anything exposed, and document the signing process in a private runbook.
- Tighten CI permissions and branch protection.

VERIFY
Give me a checklist I can tick through for keys, CI and accounts, and commands to confirm no key material remains in the repository.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] No key or keystore exists in the repo or its history.
- [ ] Signing is store-managed or keys are backed up offline.
- [ ] CI secrets are protected from forks and logs.
- [ ] MFA is on for every account that can publish.

**Watch out for**

- **Losing the key can mean losing the app.** Back it up safely.
- **Public repos and old commits:** deleting a file does not remove it from history.
- **Pull requests from forks** must not receive secrets.

---

## A14. Verify purchases and entitlements on the server

`CRITICAL` | Data & Inputs | 30-60 min

> A purchase counts only when your server confirms it with the store, not when the app says so.

**What this means**

In-app purchases, subscriptions, licences and paid unlocks that are decided inside the app can be patched, replayed or faked with tools. The only trustworthy confirmation is a receipt or purchase token verified by your server directly with Apple or Google.

**What goes wrong**

The app unlocks Pro when the store callback returns, and saves a local flag. A patched build sets the flag without paying, or a fake receipt is replayed on many accounts.

**2-minute self-check**

- Search the code for where the Pro or paid state is set. Is the decision made only on the device?
- Try unlocking by editing local data or calling the unlock function with a fake receipt on a test build.
- Check refunds and cancellations: does a refunded purchase lose access?

**Claude prompt (A14)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure paid features are unlocked only after the server verifies the purchase with the store.

AUDIT
1. Map every purchase, subscription and paid feature and how entitlement is decided.
2. Receipts and purchase tokens must be sent to YOUR server and verified with the store APIs (App Store Server API, Google Play Developer API). Tokens must be tied to the user and cannot be reused across accounts.
3. Entitlements must be stored server-side and checked server-side for anything of value. Handle renewals, refunds, revocations and grace periods through server notifications.
4. If the app is fully offline with no server, explain the trade-off honestly and suggest the strongest local approach (store licensing APIs, signed tokens) without claiming it is unbreakable.
5. Check price and product IDs cannot be tampered with by the client.

FIX
- Add server-side verification and entitlement checks, with idempotent handling of duplicate notifications.

VERIFY
Write tests for a fake receipt, a reused receipt, a refunded purchase and a duplicate notification, and show each fails safely.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Entitlement is decided on the server for anything of value.
- [ ] Receipts are verified with the store and cannot be reused across accounts.
- [ ] Refunds and cancellations remove access.
- [ ] Duplicate notifications do no harm.

**Watch out for**

- **No purchases in the app?** Mark this check N/A.
- **Offline apps cannot fully stop patching.** Be honest and rely on the store for the licence.
- **Never trust the success callback alone.**

---

## A15. Update dependencies, plugins and SDKs

`HIGH` | Deployment & Supply Chain | 20-60 min

> Most of your app is other people's code. Keep it patched, real and minimal.

**What this means**

Packages, plugins, native libraries and SDKs carry known vulnerabilities and sometimes malware. AI tools also invent package names that attackers then register ("slopsquatting"). Every extra dependency adds attack surface and permissions.

**What goes wrong**

An old image-parsing plugin has a published exploit. Anyone can craft an image that crashes or takes over the app on a vulnerable version.

**2-minute self-check**

- Run the audit tools for your stack (Flutter: flutter pub outdated and a vulnerability scan such as osv-scanner on pubspec.lock; Gradle and CocoaPods have their own).
- Open the dependency list. Do you recognise and still need every package?
- Check the minimum supported OS version is still receiving security updates.

**Claude prompt (A15)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Find and fix known-vulnerable or suspicious dependencies, plugins and SDKs.

AUDIT
1. Run the right dependency audits and list package, installed version, fixed version, severity, direct or transitive and what it is used for.
2. Verify each DIRECT dependency is the real, well-known package (not a look-alike name), has a real repository, active maintenance and sensible download numbers. Flag abandoned and unexpected ones.
3. Check lockfiles (for example pubspec.lock) are committed and CI builds from them.
4. List native SDKs and what permissions and data they add. Remove what is not needed.
5. Check the framework and platform targets (Flutter, Android targetSdk, iOS deployment target) are current enough for store rules and security fixes.

FIX
- Upgrade vulnerable packages using the smallest safe bump and read changelogs for breaking changes. Do not run blind "force" upgrades.
- Remove unused packages and plugins and re-run tests.
- Set up automated update alerts (Dependabot or Renovate).

VERIFY
Rebuild, run the tests and show before and after audit results and a list of what remains with reasons.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] No known Critical or High vulnerability remains in shipped code.
- [ ] Every direct dependency is verified real and needed.
- [ ] Lockfiles are committed and used in CI.
- [ ] Update alerts are on.

**Watch out for**

- **Check a package before adding it.** AI suggestions can be invented or look-alikes.
- **Plugins add permissions.** See A09.
- **Abandoned plugins** do not get security fixes. Plan replacements.

---

## A16. Review third-party SDKs, analytics and push

`MEDIUM` | Data & Inputs | 20-40 min

> Every SDK runs with your app's permissions and sees what your app sees.

**What this means**

Analytics, ads, crash reporting, push and social SDKs can collect device identifiers, location and behaviour, sometimes more than you intend. Push notifications can leak private content on the lock screen, and push tokens must be handled like credentials.

**What goes wrong**

An ad SDK reads the advertising ID and location and sends them to many partners. Your privacy policy says you collect nothing. The store flags the mismatch.

**2-minute self-check**

- List every SDK in the build. For each, find what it collects (its docs and its network traffic in a proxy).
- Compare that with your privacy policy and store data-safety form.
- Send yourself a test notification and check what shows on the lock screen.

**Claude prompt (A16)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer. Make sure third-party SDKs, analytics and push notifications collect and expose only what you intend.

AUDIT
1. List every third-party SDK, what it collects, where it sends data, and whether it can be disabled or configured to collect less.
2. Check consent: personal data is not sent to analytics or ads before the user agrees where the law requires it.
3. Check push: tokens stored securely and tied to the user server-side, no sensitive content in notification text, tokens revoked on logout.
4. Check deep links inside notifications are validated (A07).
5. Make sure the privacy policy and store disclosures match the real behaviour.

FIX
- Disable or remove SDKs we do not need and turn off collection we do not use.
- Move sensitive notification content behind a tap, and update disclosures.

VERIFY
Give me a table of SDK, data collected, purpose, and consent status, and confirm it matches the privacy policy.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (store consoles, backend dashboards, signing settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Every SDK has a documented purpose and data list.
- [ ] Disclosures match real behaviour.
- [ ] Notifications show no sensitive content on the lock screen.
- [ ] Push tokens are revoked on logout.

**Watch out for**

- **"Anonymous" identifiers are often personal data** under privacy law.
- **No third-party SDKs?** That is a feature. Keep it that way.
- **SDK updates change behaviour.** Re-review after upgrades.

---

## A17. Run a thorough security review

`REVIEW` | Monitoring & Response | 45-90 min

> One full pass across the whole app, like an attacker would see it.

**What this means**

The earlier checks each look at one area. This review looks at everything together and catches what checklists miss, especially logic flaws unique to your app: skipping a step in a flow, reusing a trial, abusing a share or import feature.

**What goes wrong**

Every individual check passes, but an exported share-target activity lets any app write into your local database, and the restore feature trusts any backup file.

**Before you run it**

Run this after the earlier checks, in a fresh session with full codebase access. Use the most capable model available.

**Claude prompt (A17)** - paste your Project Context first, then this:

```text
Act as a senior penetration tester and mobile and desktop application security engineer. Do a full pre-release security review of this app. Think like an attacker. Do NOT change any code in this step.

1. Phase 1, attack surface: read the codebase (and SECURITY_MAP.md if it exists). Summarise platforms, stack, data stored and its sensitivity, backend, entry points (deep links, intents, share targets, file handlers, notifications, widgets), SDKs, and trust boundaries (what the device controls vs. what the server decides).
2. Phase 2, review each area and list what you checked and found: backend auth and access control; secrets in the bundle and history; local storage; network and TLS; backend rules; input validation and imports; deep links and exported components; WebViews; permissions and privacy; logs and debug; backups and screenshots; release hardening and signing; purchases and entitlements; dependencies and SDKs; business logic and abuse (trials, referrals, credits, state skipping); AI features (prompt injection, data leaks, cost abuse) if any.

Phase 3, report: write SECURITY_REVIEW.md with a plain-English executive summary (5 lines max); a findings table sorted by severity (ID, title, severity, location, how an attacker would exploit it step by step, recommended fix, effort S/M/L); what you checked and found fine; and anything you could NOT verify from code with exact steps for me. Rate severity honestly and state your confidence. Do NOT change code in this step. Then STOP and wait for my go-ahead.
```

**Done when**

- [ ] SECURITY_REVIEW.md exists with a ranked findings table.
- [ ] Every Critical and High finding is fixed or has an owner and a date.
- [ ] The "could not verify" items have been checked manually.

**Watch out for**

- **AI reviewers can miss things and can invent problems.** Ask "show me the exact code that proves this".
- **Run it again** after big features and before every major release.

---

## A18. Test the protections and give me a report

`VERIFY` | Monitoring & Response | 45-90 min

> Every fix is proven by a test that tries to break it, and summarised in one report.

**What this means**

A fix you have not tested is a guess. This final step turns each protection into an automated or scripted test that tries to break it, fixes what fails and produces a report you can trust.

**What goes wrong**

The admin screen is hidden in the app, but the API still answers any logged-in user. The test "normal user gets 403 on admin endpoints" fails, the server check is added, and the re-test passes.

**Before you run it**

Run against local or staging backends and test devices, never destructive tests against production or real customer data. Keep the generated tests in your repo and run them in CI.

**Claude prompt (A18)** - paste your Project Context first, then this:

```text
Act as a senior mobile and desktop application security engineer and QA lead. Prove that this app's security protections actually work, fix anything that does not, and give me a final report.

Rules: test only against local or staging backends and test devices, never production data. Use test accounts (signed-out, user A, user B, admin). Write real repeatable tests in the project's test framework (for Flutter: flutter test, integration_test, plus backend tests), and scripts for manual device checks.

STEP 1, write and run "try to break it" tests for every check that applies (A01 to A16): signed-out requests, cross-user access, tampered tokens and receipts, release-artifact secret scan, no cleartext or bad-cert acceptance, no secrets in plain storage, exported components and deep links with hostile input, WebView allowlist, no sensitive logs, debuggable false, dependency audit clean, entitlement verification.

STEP 2, fix and re-test. For every failing test: explain the cause, apply the smallest correct fix and re-run. Never weaken or delete a test to make it pass.

STEP 3, write SECURITY_REPORT.md: (1) summary counts (Passed, Fixed and re-tested, Still open, N/A); (2) a table of all checks with status and evidence (test name or command); (3) findings and fixes; (4) open items with risk and next step; (5) manual actions only I can do (store console, key backup, MFA, billing caps); (6) how to run the tests and a recommendation to run them in CI.
```

**Done when**

- [ ] Tests or scripts exist for every protection that applies.
- [ ] All tests pass, or each failure is listed as an open item.
- [ ] SECURITY_REPORT.md summarises findings, fixes and open items.
- [ ] Security tests run in CI on every push.

**Watch out for**

- **Watch for "fixing" by weakening the test.** If a test changes, ask why.
- **Green tests are not perfect security.** Re-run the review (A17) as the app grows.

---

## Bonus checks

Four extra checks that matter especially for modern apps: AI features, your developer accounts, privacy disclosures and surprise bills.

### AB1. Secure your AI features

`HIGH`

If your app calls an LLM, users can try prompt injection, extract your system prompt, trigger actions they should not, or run up your bill. Never call an AI provider directly from the app with a secret key.

**Claude prompt (AB1)** - paste your Project Context first:

```text
Act as an AI application security engineer. Review every feature in this app that calls an LLM.
1. List each AI call: model, where the API key lives (must be server-side, never in the app), what user content goes into the prompt, and what the output is used for.
2. Prompt injection: assume any user text, file, or web content fed to the model may contain hostile instructions. The model must not reveal secrets, access other users' data or trigger actions beyond the user's permissions. Destructive or costly actions need explicit confirmation.
3. Treat model output as untrusted: validate before using it in queries, URLs, files or commands.
4. Cost abuse: authentication required, per-user rate limits and daily quotas, max input and output tokens, and a provider-side spending cap.
5. Privacy: send the model the minimum personal data.
Fix the issues and list what you changed.
```

### AB2. Lock down your developer and store accounts

`CRITICAL`

The easiest way into your app is often through you: the store console, GitHub, CI, domain, backend dashboard or email. One phished password there bypasses every other check.

**Claude prompt (AB2)** - paste your Project Context first:

```text
Act as a security advisor. List every account that controls this app (store consoles, code hosting, CI, domain and DNS, backend, payments, email, analytics, crash reporting). For each give me a checklist: MFA with an authenticator app or passkey (not SMS where possible); remove people who no longer need access; least-privilege roles; review connected apps and API tokens; turn on security alerts; keep the signing and upload keys backed up offline. Format it as a checklist I can tick off.
```

### AB3. Privacy and store data disclosures

`MEDIUM`

Data you do not collect cannot leak. Store forms (Play Data safety, Apple privacy labels) and privacy laws expect an accurate account of what the app and its SDKs collect.

**Claude prompt (AB3)** - paste your Project Context first:

```text
Act as a privacy-focused security engineer. Map every piece of personal data the app and its SDKs collect, where it is stored, who can see it, which third parties receive it and how long it is kept. Then: flag data we do not need; implement or plan account deletion and data export; produce the answers for the Play Data safety form and Apple privacy labels based on what the app really does; list what the privacy policy must say. Note what needs legal review.
```

### AB4. Spending caps and abuse alarms

`HIGH`

For apps with a backend, the likeliest "attack" is a surprise bill: a leaked AI or cloud key, a loop hammering a paid API, SMS pumping or a traffic spike.

**Claude prompt (AB4)** - paste your Project Context first:

```text
Act as a cloud cost and abuse-prevention advisor. List every service the app uses that bills by usage (backend, functions, database, storage, bandwidth, AI APIs, push, SMS, maps). For each tell me exactly how to set (1) a billing alert, (2) a hard cap or quota, (3) per-key usage limits. Also add app-level per-user quotas on the most expensive features and a simple daily usage summary in the logs.
```

---

## Emergency card: if something goes wrong

A leaked key, a trojan update, strange charges, users reporting accounts they did not touch. Here is what to do, in order.

1. **Stay calm, keep evidence.** Do not delete logs, builds or the repo. Write down what you noticed and when.
2. **Stop the bleeding.** Rotate exposed keys and tokens first. If a bad build is live, halt the rollout or unpublish it in the store console.
3. **Revoke access.** Revoke compromised sessions and refresh tokens. Rotate signing or upload keys if they were exposed.
4. **Investigate.** Check backend logs, store console reports and provider dashboards: when it started, what was accessed, which accounts.
5. **Close the hole.** Fix the vulnerability, add a test that proves it (A18), build and ship an update.
6. **Check your data.** Was data read, changed or deleted? Are backups intact?
7. **Tell people.** If personal data was affected, tell users honestly and check legal notification duties (for example GDPR, local data protection law). Get legal advice.
8. **Learn.** Write a short post-mortem: cause, impact, fix and prevention.

**Claude prompt: incident response** - describe what you saw in the brackets:

```text
Act as an incident responder for a mobile or desktop app. I think my app or its release pipeline has been compromised. Here's what I've noticed: [describe what you saw, when, and anything unusual].
Help me, in this order:
1. Containment: the first three actions to take in the next 15 minutes, with exact steps (store consoles, keys, backend).
2. Which credentials and keys to rotate first, and how, without breaking existing users unnecessarily.
3. Where to look in the code, logs, store console and provider dashboards, and the exact queries or filters to use.
4. The most likely vulnerability given the codebase, and the fix plus a test.
5. A plain-English summary I could adapt to tell affected users.
Don't print secret values. Ask me before running anything destructive.
```

> [!WARNING]
> **Leaked a key right now?** Revoke it in the provider dashboard immediately, even before a replacement is deployed, if it is a payment, cloud, AI or signing key. A few minutes of downtime is cheaper than the alternative. Then follow A02 and A13.

---

## Keep it secure after release

Security is not a one-time pass. Every new feature can reopen an old hole.

| You are adding | Re-run |
|----------------|--------|
| Login or sign-in | A01, A03, A04 |
| A new backend call or endpoint | A01, A04, A05, A06 |
| A new local database or file feature | A03, A06, A11 |
| A WebView or external link handling | A07, A08 |
| A new plugin or SDK | A02, A09, A15, A16 |
| Purchases or subscriptions | A01, A14 |
| Notifications or widgets | A07, A16 |
| AI / LLM features | A02, AB1, A06 |
| Before every release | A10, A12, A13, A15, A17, A18 |

| When | What |
|------|------|
| Every commit | Pre-commit secret scan runs automatically. |
| Every release | Release artifact scan for secrets (A02), logs check (A10), tests in CI (A18). |
| Weekly | Review dependency and security alerts. |
| Monthly | Dependency audit and unused plugin cleanup (A15). Review store account access (A13). |
| Quarterly | Full review (A17) and test run (A18). Review SDK data collection (A16). |
| Every big feature | Re-run the checks in the table above before shipping. |

> [!TIP]
> **Make Claude remember your rules.** Add a short security section to your project's AI rules file (CLAUDE.md or similar), so new code is written safely from the start. For example: "Never put secret keys in app code. Store tokens only in secure storage. Never disable certificate checks. Validate every external input. Ask before adding plugins or permissions."

---

## What your final report looks like

The final check ends with a `SECURITY_REPORT.md`. Use this shape to tell a real report from a vague summary.

| # | Check | Status | Evidence / next step |
|---|-------|--------|----------------------|
| A01 | Enforce auth on the backend | Passed | auth.test, 14 endpoints return 401 |
| A03 | Store data securely | Fixed and re-tested | Token moved to secure storage, scan clean |
| A02 | Keep secrets out of the bundle | Fixed and re-tested | Release artifact scan finds no keys |
| A14 | Verify purchases on the server | Open, next step | Add duplicate-notification handling |
| A13 | Protect signing keys | Needs my action | Enable MFA on store account |
| A05 | Lock down backend rules | N/A | No backend, fully offline |

| A good report has | Push back if you see |
|------------------|----------------------|
| Every check listed, including N/A ones. | "Everything looks secure!" with no evidence. |
| Evidence for every "Passed": a test name or a command. | Tests that were deleted or weakened to pass. |
| Specific next steps for open items. | Findings with no file, line or endpoint. |
| A clear list of what you must do manually. | Critical items quietly marked "N/A". |

---

## Glossary

| Term | Meaning |
|------|---------|
| Bundle / APK / IPA | The installable package. It is a zip anyone can open. |
| Keychain / Keystore | The operating system's protected storage for secrets. |
| Certificate pinning | Making the app trust only your server's certificate or key. |
| Deep link / intent | A way for other apps or websites to open your app with data. |
| Exported component | An Android component other apps are allowed to start. |
| WebView | A browser embedded inside your app. |
| Obfuscation | Renaming code to make it harder to read. It does not hide strings. |
| Root / jailbreak | A device where the user or malware has full control. |
| IDOR | Changing an ID to access someone else's data. |
| Receipt validation | Checking a purchase with the store from your server. |
| Play Integrity / App Attest | Platform signals that a request comes from a genuine app on a genuine device. |
| Rotation | Replacing a credential with a new one, then revoking the old one. |
| Slopsquatting | Attackers publishing malware under package names that AI tools tend to hallucinate. |
| Prompt injection | Hidden instructions in user content that try to hijack an AI model. |

> Ship fast. Ship safe. Run the checks, keep the tests, and re-run the review whenever your app grows.
