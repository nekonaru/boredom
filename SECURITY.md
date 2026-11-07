# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 4.3.x   | Yes                |
| < 4.3   | No                 |

## Reporting a Vulnerability

If you discover a security issue in Boredom, please report it privately by email to [neko.naru@proton.me](mailto:neko.naru@proton.me) instead of opening a public issue.

You can expect an acknowledgment within 72 hours and a resolution timeline once the report is triaged.

## Scope

Boredom is fully offline and stores progress only on your own device. It does not collect, transmit, or upload personal data, app analytics, or usage telemetry of any kind.

## Security Practices

- No network calls, accounts, or cloud services are required to run the app.
- The app reads and writes only local storage using `shared_preferences`.
- No API keys, secrets, or credentials are embedded in the binary or source tree.
- Dependencies are limited to Flutter SDK and pub.dev packages tracked in `pubspec.yaml`.
