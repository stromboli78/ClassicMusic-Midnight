# 0.9.0 beta release checklist

## Static checks

- [ ] Installed Retail build and interface match the TOC.
- [ ] TOC version matches the intended Git tag.
- [ ] Every Lua/TOC file passes syntax and load-order review.
- [ ] No player SavedVariables, local paths, credentials, or bundled audio exist.
- [ ] Release ZIP contains one top-level `BetterMusic/` directory.
- [ ] Development documentation and GitHub files are excluded from the ZIP.

## In-game smoke test

- [ ] Clean install, login, `/reload`, logout/login, and preference persistence.
- [ ] Enter and leave supported Midnight content.
- [ ] Cross same-theme and different-theme subzones.
- [ ] Verify day and night selection using realm time.
- [ ] Test Loop Music both enabled and disabled.
- [ ] Drag the addon volume slider; expect one quiet restart after it settles.
- [ ] Run `/bettermusic toggle`; verify music/dialogue status and recovery.
- [ ] Alt-tab with WoW Sound in Background enabled; expect uninterrupted playback.
- [ ] Enter and leave an in-engine cinematic and a streamed movie.
- [ ] Disable the addon feature and run `/bettermusic restore`; Blizzard music returns.
- [ ] Enable Lua errors with `/console scriptErrors 1`; no Lua, secret-value, taint,
      or protected-action errors occur.

## GitHub

- [ ] Reauthenticate `gh` as `stromboli78`.
- [ ] Create public `stromboli78/ClassicMusic-Midnight` with no generated files.
- [ ] Push the source branch and confirm issue forms render correctly.
- [ ] Add the CurseForge URL to repository metadata after project approval.
- [ ] Tag `v0.9.0`; GitHub Actions creates a prerelease and installable ZIP.
- [ ] Download the generated ZIP and test installation into a clean AddOns folder.

## CurseForge

- [ ] Confirm `classic-music-midnight` is accepted as the project slug.
- [ ] Upload the original 400×400 PNG avatar.
- [ ] Add the summary and description from `docs/CURSEFORGE.md`.
- [ ] Select Addons → Audio & Video, MIT, Retail, and game version 12.1.0.
- [ ] Set GitHub as source and issue tracker.
- [ ] Upload `ClassicMusic-Midnight-v0.9.0.zip` as Beta with the matching changelog.
- [ ] Confirm CurseForge recognizes `BetterMusic/BetterMusic.toc`.
- [ ] Upload honest in-game gallery screenshots with prepared captions.
- [ ] Add the avatar disclosure if generative editing was used.
