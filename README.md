<p align="center">
<img src="readme-resources/hero.png" alt="Terminal for iOS">
</p>

<h1 align="center">OpenTerm</h1>

<p align="center">
<a href="https://itunes.apple.com/app/terminal/id1323205755?mt=8&at=1010lII4"><img src="readme-resources/app_store_badge.svg" alt="Download on the App Store"/></a>
<br><span align="center">(Previously called Terminal for iOS)</span>

</p>

<p align="center">
<a href="https://developer.apple.com/swift/"><img src="https://img.shields.io/badge/Swift-4.1-orange.svg?style=flat" alt="Swift"/></a>

<img src="https://img.shields.io/badge/Platform-iOS%2011.0+-lightgrey.svg" alt="Platform: iOS">
<a href="https://travis-ci.org/louisdh/openterm"><img src="https://travis-ci.org/louisdh/openterm.svg?branch=master" alt="Build Status"/></a>
<br>
<a href="http://twitter.com/LouisDhauwe"><img src="https://img.shields.io/badge/Twitter-@LouisDhauwe-blue.svg?style=flat" alt="Twitter"/></a>
<a href="https://paypal.me/louisdhauwe"><img src="https://img.shields.io/badge/Donate-PayPal-green.svg?style=flat" alt="Donate via PayPal"/></a>
</p>

## About
OpenTerm is a sandboxed command line interface for iOS. 

This fork is being modernized into a premium AI-powered mobile developer workspace for iPhone and iPad. The direction is:

- SwiftUI-first shell
- iOS 18+ baseline
- built with Xcode 26.4 and the iOS 26.4 SDK
- Liquid Glass styling on supported systems
- terminal + SSH + files + Git + servers + AI in one app
- premium sync, vault, and monitoring layers

The legacy terminal core still exists, but the app shell and roadmap are now aimed at a cleaner "Raycast + Warp + Linear for iOS" product surface.

## Current Fork Status

What is in the repo now:

- legacy OpenTerm terminal core
- new SwiftUI workspace shell
- embedded legacy terminal inside the new shell
- workspace sections for Home, Terminal, Files, Git, Servers, AI, and Settings
- iOS 18+ minimum deployment target
- Xcode 26.4 / iOS 26.4 SDK build target
- Swift 5 project baseline
- Liquid Glass-ready styling on supported systems
- local workspace data models for sessions, snippets, SSH profiles, Git summaries, server cards, and premium plan surfaces
- Supabase schema foundation for accounts, devices, subscriptions, snippets, AI usage, server monitors, and audit logs
- GitHub Actions workflow for an unsigned IPA artifact

What is still placeholder or partial:

- SSH connection manager UI is mocked, not fully wired
- code editor is planned, not implemented
- Git actions are surfaced as product UI but not fully executed in-app yet
- AI provider integration is planned, not connected
- live server polling and alerts are planned, not connected
- premium billing and entitlement verification are planned, not connected


Commands included:

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

- real SSH manager and encrypted vault
- code editor with syntax highlighting
- full Git workflow actions
- live server monitoring and alerts
- AI assistant integrations
- premium account verification and sync
- widgets and multi-device sync

## Workspace Roadmap

- new SwiftUI workspace shell wrapping the existing terminal engine
- SSH profiles and quick connect
- local file manager and future editor layer
- Git workspace UI
- server monitoring dashboard
- AI command assistant
- subscription backend and remote feature flags

See:

- `Documentation/OpenTerm-AI-Workspace-Blueprint.md`
- `Documentation/OpenTerm-Data-And-Monetization.md`
- `Documentation/OpenTerm-Backend-Architecture.md`

## Running
Open `OpenTerm.xcworkspace`, change the bundle identifier to an identifier linked to your Apple developer account in order to run. Build using the `OpenTerm` scheme. 

### Running on device
To run on a device, you will have to run `resign-frameworks.sh`, but first change `iPhone Developer: Louis D'hauwe (5U7B95VS8G)` with the name of your own certificate. 

## GitHub Actions

For testing builds on GitHub Actions, use:

- `.github/workflows/ios-unsigned-ipa.yml`

That workflow creates an unsigned IPA artifact for inspection and sideload-oriented testing only. It is not a normal signed App Store or TestFlight build.

It is pinned to `Xcode 26.4` and verifies the `iOS 26.4` SDK before building.

## License

OpenTerm is available under the GPLv2 (or later) and the MPLv2 license.

See [COPYING](./COPYING) for more license info.
