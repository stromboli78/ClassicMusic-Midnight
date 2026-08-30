# Changelog

All notable changes to Classic Music: Midnight are recorded here.

## [0.9.0] - 2026-08-30

### Added

- Public beta release for Retail 12.1.
- Hand-matched Vanilla and Burning Crusade themes for supported Midnight zones,
  dungeons, raids, delves, lairs, scenarios, and Coiled Isle content.
- Fixed area identities with realm-time day/night variants where available.
- Native Loop Music behavior, cinematic handling, audio-session recovery, and
  safe restoration of Blizzard music.
- Native AddOns settings, volume debounce, track announcements, and diagnostic
  slash commands.
- `/bettermusic toggle` for music/dialogue macros with chat status.

### Known limitations

- This beta has not been broadly auditioned across every supported phase and
  instance. Reports with `/bettermusic debug` output are encouraged.
- Background playback depends on WoW's Sound in Background option and the active
  operating-system audio device.
- Other addons playing music on the Master channel may overlap this addon.

[0.9.0]: https://github.com/stromboli78/ClassicMusic-Midnight/releases/tag/v0.9.0
