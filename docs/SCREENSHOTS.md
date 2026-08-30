# CurseForge image capture guide

## Capture setup

- Capture at 2560×1440 or 1920×1080 in 16:9, using the same resolution throughout.
- Use the normal game UI scale; do not enlarge chat or settings only for a shot.
- Set graphics high enough for clean silhouettes and readable zone lighting.
- Hide unrelated quest tracking, damage meters, nameplates, and addon windows.
- Keep the minimap only when it helps establish location.
- Enable **Announce track** only for shots that call for a Now Playing message.
- Use `/bettermusic status` immediately before capture to confirm the assignment.
- Avoid player, guild, BattleTag, realm, or chat information that should not be public.
- Save lossless PNG originals. Do not add sharpening, fake UI, or altered track text.

## Required shot list

### 01-eversong-hero.png

- Location: a recognizable Eversong or Silvermoon overlook.
- Time: golden daylight or blue hour, whichever gives the character a clear silhouette.
- Character: Blood Elf framed off-center with the environment still identifiable.
- UI: minimal; show one authentic Now Playing line in chat.
- Camera: medium-wide, level horizon, no combat effects.

### 02-day-night-day.png and 02-day-night-night.png

- Use the same exact camera position in a supported day/night zone.
- Capture one during the addon day window and one during its night window.
- Show `/bettermusic status` or a Now Playing line identifying each variant.
- Do not fabricate the comparison by recoloring a single screenshot.

### 03-native-settings.png

- Open **Options > AddOns > Classic Music: Midnight**.
- Frame the full category with the title, content toggles, announcements, and volume.
- Use default UI styling and avoid overlapping tooltips unless the tooltip is the subject.

### 04-instance-theme.png

- Capture a supported dungeon, raid, or delve in a distinctive non-combat space.
- Show one authentic track announcement; keep party chat and player names private.
- Favor a scene whose Classic/TBC match is visually understandable.

### 05-chat-controls.png

- Use a quiet supported area with an uncluttered background.
- Run `/bettermusic status`, then `/bettermusic toggle` twice so the final state is on.
- Crop closely enough for the output to be legible while retaining some game context.

### 06-midnight-coverage.png (optional)

- Provide four separate originals from Eversong, Harandar, Voidstorm, and Coiled Isle.
- Assemble a simple 2×2 montage with equal crops and small location labels.
- Do not use Blizzard logos, promotional key art, or unrelated expansion imagery.

## Processing and export

- Keep gallery images at 16:9 and export PNG or high-quality JPEG.
- Apply the same restrained exposure and contrast correction to the whole set.
- Crop private chat and identifiers rather than painting over gameplay.
- Keep authentic UI pixel-perfect; do not warp, regenerate, or replace it.
- Use the titles and captions in `docs/CURSEFORGE.md`.

## Avatar source capture

- Provide the original full-resolution Blood Elf screenshot separately.
- A head-and-shoulders or waist-up pose with clear ears and hair gives headphones
  enough room to read at 400×400.
- Prefer a simple darker background and even facial light.
- Avoid overlapping UI, weapons through the silhouette, or copyrighted logos.
- Final deliverables after editing: `avatar-master-1024.png`,
  `avatar-curseforge-400.png`, and `github-social-preview-1280x640.png`.
