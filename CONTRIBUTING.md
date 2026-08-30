# Contributing

Thanks for helping improve Classic Music: Midnight.

## Reporting a problem

Use the matching GitHub issue form. Search existing issues first and submit one
problem per issue. Music and map reports should include:

- zone, subzone, dungeon, raid, delve, or scenario
- realm time and whether the selected track was a day or night variant
- current track and the expected musical match
- safe output from `/bettermusic debug`
- steps to reproduce, including zoning, reloading, alt-tabbing, or changing audio
- other music or audio addons enabled at the time

Do not post account information, character identifiers, SavedVariables, or any
value WoW marks secret.

## Changes

- Target the current Retail 12.1 client and interface `120100`.
- Preserve `BetterMusic`, `BetterMusicDB`, and `/bettermusic` compatibility.
- Use numeric map and instance IDs, never localized zone-name comparisons.
- Do not bundle music, modify Blizzard files, or replace Blizzard UI.
- Keep player-facing strings localized through `Localization.lua`.
- Test restoration of Blizzard music and avoid unsafe secret-value operations.

Pull requests should explain the user-visible behavior, list in-game verification
performed, and call out anything that still requires auditioning in WoW.
