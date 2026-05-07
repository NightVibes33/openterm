<p align="center">
<img src="readme-resources/hero.png" alt="Terminal for iOS">
</p>

<h1 align="center">OpenTerm</h1>

<p align="center">
<a href="https://itunes.apple.com/app/terminal/id1323205755?mt=8&at=1010lII4"><img src="readme-resources/app_store_badge.svg" alt="Download on the App Store"/></a>
<br><span align="center">(Previously called Terminal for iOS)</span>

</p>

<p align="center">
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-5.0-orange.svg?style=flat" alt="Swift"/></a>

<img src="https://img.shields.io/badge/Platform-iOS%2018.0+-lightgrey.svg" alt="Platform: iOS">
<a href="https://github.com/NightVibes33/openterm/actions/workflows/ios-unsigned-ipa.yml"><img src="https://github.com/NightVibes33/openterm/actions/workflows/ios-unsigned-ipa.yml/badge.svg" alt="Build Status"/></a>
<br>
<a href="http://twitter.com/NightVibes33"><img src="https://img.shields.io/badge/Twitter-@NightVibes33-blue.svg?style=flat" alt="Twitter"/></a>
<a href="https://www.buymeacoffee.com/ZYN3"><img src="https://img.shields.io/badge/Donate-Buy%20Me%20A%20Coffee-green.svg?style=flat" alt="Donate via Buy Me a Coffee"/></a>
</p>

## About
OpenTerm is a sandboxed command line interface for iOS, being modernized into a premium AI-powered mobile developer workspace for iPhone and iPad.

**Current direction:**
- SwiftUI-first workspace shell
- iOS 18+ baseline
- Liquid Glass styling on supported systems
- Terminal + SSH + Files + Git + Servers + AI in one app
- Premium sync, vault, and monitoring layers

The goal is a cleaner **"Raycast + Warp + Linear for iOS"** product surface — aesthetic, fast, modern, and beginner-friendly.

## Current Fork Status

### What is in the repo now
- Legacy OpenTerm terminal core
- New SwiftUI workspace shell
- Embedded legacy terminal inside the new shell
- Workspace sections for Home, Terminal, Files, Git, Servers, AI, and Settings
- iOS 18.0 minimum deployment target
- Swift 5 project baseline
- Liquid Glass-ready styling on supported systems
- Local workspace data models for sessions, snippets, SSH profiles, Git summaries, server cards, and premium plan surfaces
- Supabase schema foundation for accounts, devices, subscriptions, snippets, AI usage, server monitors, and audit logs
- GitHub Actions CI workflow building unsigned IPA artifacts

### What is still placeholder or partial
- SSH connection manager UI is mocked, not fully wired
- Code editor is planned, not implemented
- Git actions are surfaced as product UI but not fully executed in-app yet
- AI provider integration is planned, not connected
- Live server polling and alerts are planned, not connected
- Premium billing and entitlement verification are planned, not connected

## Commands Included

|            |            |            |            |
| ---------- | ---------- | ---------- | ---------- |
| awk        | cat        | cd         | chflags    |
| chksum     | clear      | compress   | cp         |
| credits    | cub        | curl       | date       |
| dig        | du         | echo       | egrep      |
| env        | fgrep      | grep       | gunzip     |
| gzip       | help       | host       | link       |
| ln         | ls         | mkdir      | mv         |
| nc         | nslookup   | open-url   | pbcopy     |
| pbpaste    | ping       | printenv   | pwd        |
| readlink   | rlogin     | rm         | rmdir      |
| say        | scp        | sed        | setenv     |
| sftp       | share      | sleep      | ssh        |
| ssh-keygen | stat       | sum        | tar        |
| tee        | telnet     | touch      | tr         |
| uname      | uncompress | unlink     | unsetenv   |
| uptime     | wc         | whoami     |            |

## Dependencies
To set up dependencies, run `bootstrap.sh`.

## Planned Additions

- Real SSH manager and encrypted vault
- Code editor with syntax highlighting
- Full Git workflow actions
- Live server monitoring and alerts
- AI assistant integrations
- Premium account verification and sync
- Widgets and multi-device sync

## Workspace Roadmap

- [x] Fork OpenTerm
- [x] Update dependencies
- [x] Modern SwiftUI redesign foundation
- [x] Stable terminal core preserved
- [ ] SSH manager (in progress)
- [ ] AI assistant integration
- [ ] Git support
- [ ] Premium features
- [ ] TestFlight beta

## Documentation

- `Documentation/OpenTerm-AI-Workspace-Blueprint.md`
- `Documentation/OpenTerm-Data-And-Monetization.md`
- `Documentation/OpenTerm-Backend-Architecture.md`

## Running
Open `OpenTerm.xcworkspace`, change the bundle identifier to an identifier linked to your Apple developer account in order to run. Build using the `OpenTerm` scheme.

### Running on device
To run on a device, you will have to run `resign-frameworks.sh`, but first change `iPhone Developer: Louis D'hauwe (5U7B95VS8G)` with the name of your own certificate.

## GitHub Actions

The CI workflow `.github/workflows/ios-unsigned-ipa.yml` builds an unsigned IPA artifact for testing and inspection only.

**Important:** Unsigned IPAs do not install on normal real iPhones without proper signing/provisioning, sideload tooling, or a special device environment. A signed workflow for TestFlight/App Store distribution can be added later using Apple certificate and provisioning profile secrets.

## License

OpenTerm is available under the GPLv2 (or later) and the MPLv2 license.

See [COPYING](./COPYING) for more license info.
