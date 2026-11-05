# YouMod stability: diagnostic build and test protocol

This repository supports two YouTube IPA build configurations through **Actions → Build IPA with tweaks → Run workflow**.

## Build selection

- **Minimal diagnostic:** set `minimal_build` to **true**. The workflow builds and injects only `youmod.deb`. It does **not** include the Safari extension, YouPiP, YTUHD, Return-YouTube-Dislikes, YTVideoOverlay, YTABConfig, UncappedAVPlayer, DontEatMyContent, YouSlider, YTweaks, Gonerino, youtube-native-share, VolumeBoostYT, YouQuality, or YouGroupSettings. Other optional switches are ignored in this mode.
- **Full:** leave `minimal_build` **false** to retain the previously configured integrations. These are not necessarily all required, compatible, or performance-neutral.
- Both workflows compile **this repository at the branch selected in GitHub Actions**. To test unmerged changes, choose the development branch before clicking **Run workflow**. Neither workflow silently checks out the upstream repository anymore.

An independently sourced, decrypted YouTube IPA is required as the input; the repository does not distribute it. Do not publish copyrighted IPA files or share sensitive build inputs.

## Before testing

Record device model, iOS version, installation/signing method, YouTube IPA version, YouMod commit SHA, `minimal_build`, whether playback fix is enabled, the input IPA hash, the final IPA hash, and whether the app was installed over an older build.

Use the **same input IPA and signing method** for A/B comparisons. If testing the playback fix toggle, fully close and relaunch the app after changing it: the relevant hook is initialized when the tweak loads.

## Test matrix

1. **Baseline (unmodified app, if available):** verify that the source YouTube version works with the same network and account.
2. **Minimal build, fix OFF:** open at least 30 different normal videos. Record error popups, time-to-first-frame, retries, and startup behavior. Test Wi-Fi and cellular if available.
3. **Minimal build, fix ON:** repeat on the same videos, restarting after enabling the fix. Watch for repeated reloads or a video that never begins.
4. **Navigation and duration:** watch at least two videos for 20+ minutes each; reopen the feed and subscriptions, rotate to/from fullscreen, play 20 Shorts, try background audio and picture-in-picture when supported.
5. **Full build:** only if the minimal baseline is reliable, enable additional integrations incrementally, recording exactly which change introduces regressions.

Compare adjacent versions only after the previous version passes the same tests. Do not infer playback stability from a successful GitHub Actions build.

## Evidence for issues

For every failure, capture the video URL or ID, time, current network, app/tweak versions, the precise visible message, the playback error **domain and code** if available, and the reproduction steps. Redact account tokens, credentials, and private data before sharing logs.

### Acceptance target

- No reproducible playback error overlay or infinite retry loop across 30 video opens.
- No reproducible scrolling freeze after watching a video.
- No unexpected crash during the long-playback, navigation, Shorts, or background-playback checks.
- No systematic increase in time-to-first-frame relative to the stable reference build.

These are **test goals**, not claims of current compatibility. A different YouTube version or a new dependency can invalidate previous results.

## Remaining engineering work

This phase adds a reproducible **feature selection**, not fully reproducible dependencies: external Theos/tweak dependencies are still fetched at moving upstream heads. Pinning their tested SHAs and recording build provenance belongs in a subsequent change after the diagnostic baseline is established.
