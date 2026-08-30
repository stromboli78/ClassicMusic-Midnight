# CurseForge project copy

## Project fields

- **Name:** Classic Music: Midnight
- **Preferred slug:** `classic-music-midnight`
- **Class:** Addons
- **Main category:** Audio & Video
- **Release channel:** Beta
- **Game flavor/version:** Retail 12.1.0
- **License:** MIT
- **Source:** https://github.com/stromboli78/ClassicMusic-Midnight
- **Issues:** https://github.com/stromboli78/ClassicMusic-Midnight/issues

## Summary

Hand-matched Classic and Burning Crusade zone music for Midnight, with day/night themes and native audio behavior.

## Description

## Bring the old world into Midnight

Classic Music: Midnight replaces the music in supported Midnight content with
hand-matched themes from Vanilla World of Warcraft and The Burning Crusade.
Eversong feels like Eversong again, the Amani return to their original musical
roots, and unfamiliar regions receive one carefully selected historical theme
that matches their atmosphere.

Every supported area has a fixed musical identity rather than a broad shuffled
playlist. Outdoor and city areas can also choose an appropriate day or night
variant using realm time.

The addon contains no music files and streams nothing. It plays Blizzard
SoundKits already installed with World of Warcraft.

### Highlights

- Hand-matched Vanilla and Burning Crusade music for Midnight zones
- Support for outdoor areas, cities, dungeons, raids, delves, lairs, and 12.1 content
- Realm-time day and night music where verified variants exist
- Native-style transitions and WoW Loop Music behavior
- Pauses for cinematics and restores normal Blizzard music elsewhere
- Native settings under **Options > AddOns > Classic Music: Midnight**
- Optional Now Playing messages and helpful status/debug commands
- No external audio, custom media player, or minimap button

### Getting started

Install the addon, make sure WoW Sound and Music are enabled, and enter supported
Midnight content. Open the settings with `/bettermusic` or through
**Options > AddOns**.

If you use a macro to toggle music and dialogue together, use:

```text
/bettermusic toggle
```

This treats addon playback like WoW's main music and prints the resulting status
in chat.

### Commands

- `/bettermusic` — open settings
- `/bettermusic toggle` — toggle music and dialogue together
- `/bettermusic next` — restart the current area's assigned track
- `/bettermusic status` — show the active area theme and track
- `/bettermusic restore` — stop addon playback and restore Blizzard music
- `/bettermusic debug` — print safe map and instance details for a report

### Supported content

The beta covers verified Midnight launch and 12.1 maps, including Eversong,
Silvermoon, Quel'Danas, Zul'Aman, Harandar, Voidstorm, Coiled Isle, all nine
Midnight dungeons through Altar of Fangs, the Season 1 raids, current delves,
scenarios, and lairs.

Locations are identified by numeric map and instance IDs. Unrecognized future
maps intentionally keep Blizzard music until their identity and matching track
have been verified.

### Native audio behavior

The addon respects WoW's Music, Sound, Loop Music, and Sound in Background
settings. It never enables audio that the player disabled. With Loop Music off,
the assigned track finishes and waits for a new area entry, matching WoW's
non-looping behavior. Cinematics temporarily return audio control to Blizzard.

Another manual music addon may overlap because WoW does not provide a universal
ownership system for addon-started Master-channel sounds.

### 0.9.0 beta

This is a public beta. If a location is silent, unmapped, or has the wrong mood,
please report the zone or activity, realm time, current track, expected music,
and `/bettermusic debug` output on GitHub.

### Independent fan project

World of Warcraft, its names, music, and game assets are trademarks or property
of Blizzard Entertainment. Classic Music: Midnight is an independent fan-made
addon and is not endorsed by or affiliated with Blizzard Entertainment. No
Blizzard audio is distributed with the addon.

## Gallery captions

1. **Eversong, remembered** — Classic Eversong music returns to Midnight's rebuilt homeland, with optional track announcements.
2. **Music that follows the hour** — Verified outdoor profiles select their day or night counterpart using realm time.
3. **Native settings** — Choose supported content categories, announcements, and playback volume from WoW's AddOns settings.
4. **Historical themes in instances** — Dungeons, raids, delves, and lairs receive fixed Vanilla or Burning Crusade counterparts.
5. **Simple chat controls** — Check the current track or toggle music and dialogue without fighting Blizzard music.
6. **Across Midnight** — Representative themes for Eversong, Harandar, Voidstorm, and Coiled Isle.

## Image disclosure template

Use this sentence only if the published avatar is generatively edited:

> Project avatar created from an original in-game screenshot captured by the addon author and generatively edited for decorative branding. Gallery screenshots show the addon in game without generative alteration.
