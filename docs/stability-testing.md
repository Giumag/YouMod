# YouMod — Build profiles & stability testing

The known-working baseline is **YouTube 21.44.4 + YouMod v2.0.0, minimal**, tested by the user on iPhone 16 Pro with iOS 27.0.1 through SideStore. This is one device report, not a universal compatibility guarantee.

## Profiles

In this fork go to **Actions → Build IPA with tweaks**, select the **development branch**, choose **Run workflow**, provide a direct link to a legitimately acquired decrypted YouTube IPA, and set `build_profile`:

| Choice | Included | Purpose |
| --- | --- | --- |
| `minimal` | YouMod only | Playback diagnostics / iPhone 15 initial test |
| `balanced` (default) | YouMod, Return-YouTube-Dislikes, DontEatMyContent, YouGroupSettings | iPhone 16 Pro candidate: modest aesthetic and convenience additions |
| `full` | YouMod, configurable tweak checkboxes, plus the original always-on integrations and Safari extension | Advanced tests only, not recommended as a first install |

Only `full` uses the optional checkboxes; other profiles ignore them. The `balanced` preset deliberately does **not** inject YouPiP, YTUHD, YTVideoOverlay, UncappedAVPlayer, YTABConfig, YouSlider, YTweaks, Gonerino, VolumeBoostYT, or the Safari extension. YouMod itself contains SponsorBlock, background playback, downloader, OLED appearance and player controls.

GitHub Actions produces a **draft release** with the `.ipa` and corresponding `.manifest.txt` (source-IPA/output-IPA SHA-256, tweak hashes and source commits). These provenance records do not pin external dependencies, which still follow upstream branches: versions can change between runs.

## Appearance — manual, conservative configuration

Inside YouMod Settings, consider **OLED Theme** (Appearance), **Premium navigation icon** (Navigation bar), and optionally **Frosted Tab Bar** (Tab bar). Try one appearance setting at a time and verify scrolling, keyboard, dialogs and fullscreen. Avoid forced UHD quality or enabling duplicate player, PiP or SponsorBlock tweaks. Prefer stock/default video quality for initial stability testing.

Back up/export existing YouMod preferences before importing presets: YouMod's preferences importer replaces existing YouMod keys. No setting is automatically changed by this workflow.

## Verification protocol

1. Keep the previous **minimal 21.44.4** IPA as a rollback. For a controlled A/B comparison, use the identical source YouTube IPA, account, network, bundle ID, device and SideStore signing configuration.
2. Test **balanced** on iPhone 16 Pro: 30 video openings, two 20-minute videos, 20 Shorts, feed scrolling before/after playing, fullscreen transitions, audio in background, and downloader.
3. If balanced adds lag, return to the working minimal build. In a follow-up build isolate RYD/DontEatMyContent individually; do not infer causality from simultaneous changes.
4. For the **iPhone 15** when available, record the iOS version and reproduce the error on a **minimal** build first. Compare playback with Fix Playback Issues OFF and ON, fully restarting YouTube after changing the toggle. Test another network and account/sign-out if practical. Record error domain/code, frequency and time-to-error; redact credentials.
5. Only investigate retry limits, token handling or network/client changes after a concrete reproducible error. Do **not** import the highly experimental upstream TV/PS4 client spoofing playback patch without isolated testing.

### Pass criteria

No repeatable playback error or infinite reload across 30 video opens; no feed freeze or crash; no systematic increase in buffering/startup latency compared with the minimal control. Passing GitHub Actions does **not** establish these results.

## SideStore

SideStore's documented update behavior generally supports installing a newer IPA over the existing app with the same bundle ID while preserving app data, but backup is still recommended. Free Apple accounts have app / app-ID limits. Do not remove an existing working installation solely to test a new profile.
