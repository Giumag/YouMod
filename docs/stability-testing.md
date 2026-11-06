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


## iPhone 15 experimental playback diagnostics branch

An iPhone 15 on iOS 27.0.1 still showed the generic Italian "Si è verificato un problema — Tocca per riprovare" playback overlay using the previously recommended minimal IPA. This overlay alone cannot reveal whether the underlying error is code 14, code 2, or something else.

The **experimental diagnostic branch** is \`dev/iphone15-playback-diagnostics-20261106\`, based on the same minimal-build workflow. Create a **new Minimal IPA using the same legitimate YouTube 21.44.4 input IPA** from **Actions → Build IPA with tweaks**, select the diagnostic branch, enable \`minimal_build\`, and install it on the iPhone 15 using its existing SideStore signing method. This is not a prebuilt IPA until the workflow succeeds.

### Diagnostic changes

- The existing \`handleError:\` hook now records the **last error domain, numeric error code and timestamp** to local \`NSUserDefaults\`, regardless of the recovery-switch setting. It stores no video URL, credentials, request data or error \`userInfo\`.
- **YouMod Settings → Last playback error** shows the captured information. If it says **No player error captured**, that is meaningful: the error may not have reached this hook. A new reproduction is required.
- The existing **Fix Playback Issues** switch is checked at runtime. It tries to reload only the known playback error **14**, with **at least 60 seconds between automatic attempts**. If the retry cannot be scheduled or is rate-limited, YouTube's original error is displayed normally.
- No playback client spoofing, network manipulation or new external tweak is added. The diagnostic hook is observational with recovery disabled, but does modify the app and must be validated in a real build.

### First-device test

1. Verify the same video plays in official YouTube and Safari using the **same account and network**. If official YouTube also fails, investigate connectivity/account/video-specific issues first.
2. In diagnostic YouMod, leave **Fix Playback Issues OFF** and open a video that fails. Immediately open **YouMod Settings → Last playback error** and record only \`Domain\`, \`Code\`, and whether an error was captured. Do not share account information or request headers.
3. If the code is **14**, enable the recovery switch and repeat; it should retry at most once per 60 seconds, without a freeze.
4. If the code is different, leave the retry disabled. Compare Wi-Fi and cellular, quality set to default, and any DNS/VPN/content filtering configurations. Do not reset network settings or delete app data without a reason.
5. If no error is captured, use the recorded screen behavior and a device console log (filter \`[YouMod Playback]\`) to decide what player callback to instrument next, instead of blindly replacing the network protocol.

The experimental branch is intentionally isolated from the known-good iPhone 16 Pro Balanced branch and must not be merged into a stable release before a successful macOS build and iPhone 15 playback tests.
