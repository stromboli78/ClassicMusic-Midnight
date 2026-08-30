local _, ns = ...

local fallback = {
    ADDON_NAME = "Classic Music: Midnight",
    DESCRIPTION = "Plays Classic and Burning Crusade music in supported Midnight content.",

    SECTION_GENERAL = "General",
    SECTION_CONTENT = "Content",
    SECTION_PLAYBACK = "Playback",
    ENABLED = _G.ENABLE or "Enable",
    ENABLED_TOOLTIP = "Replace Midnight music with matching Classic and Burning Crusade tracks.",
    OUTDOORS = "Outdoor zones",
    OUTDOORS_TOOLTIP = "Use Classic Music: Midnight in supported outdoor zones, subzones, and story scenarios.",
    DUNGEONS = _G.DUNGEONS or "Dungeons",
    DUNGEONS_TOOLTIP = "Use Classic Music: Midnight in supported dungeons.",
    RAIDS = _G.RAIDS or "Raids",
    RAIDS_TOOLTIP = "Use Classic Music: Midnight in supported raids.",
    DELVES = "Delves and lairs",
    DELVES_TOOLTIP = "Use Classic Music: Midnight in supported delves and lairs.",
    ANNOUNCE_TRACK = "Announce tracks",
    ANNOUNCE_TRACK_TOOLTIP = "Print a chat message whenever Classic Music: Midnight starts a track.",
    VOLUME = _G.VOLUME or "Volume",
    VOLUME_TOOLTIP = "Set the volume override used by Classic Music: Midnight. Changing this restarts the current track with a short fade.",
    PERCENT_FORMAT = "%d%%",

    CATEGORY_OUTDOORS = "outdoor",
    CATEGORY_DUNGEONS = "dungeon",
    CATEGORY_RAIDS = "raid",
    CATEGORY_DELVES = "delve or lair",
    ERA_VANILLA = "Classic",
    ERA_TBC = "The Burning Crusade",

    TRACK_EVERSONG_DAY = "Eversong Woods — Day",
    TRACK_EVERSONG_NIGHT = "Eversong Woods — Night",
    TRACK_EVERSONG_RUINS_DAY = "Eversong Ruins — Day",
    TRACK_EVERSONG_RUINS_NIGHT = "Eversong Ruins — Night",
    TRACK_EVERSONG_BUILDINGS_DAY = "Eversong Buildings — Day",
    TRACK_EVERSONG_BUILDINGS_NIGHT = "Eversong Buildings — Night",
    TRACK_SILVERMOON_DAY = "Silvermoon City — Day",
    TRACK_SILVERMOON_NIGHT = "Silvermoon City — Night",
    TRACK_GHOSTLANDS_DAY = "Ghostlands — Day",
    TRACK_GHOSTLANDS_NIGHT = "Ghostlands — Night",
    TRACK_GHOSTLANDS_DARK = "Ghostlands — Dark Walk",
    TRACK_DEATHOLME_DAY = "Deatholme — Day",
    TRACK_DEATHOLME_NIGHT = "Deatholme — Night",
    TRACK_QUELDANAS_DAY = "Isle of Quel'Danas — Day",
    TRACK_QUELDANAS_NIGHT = "Isle of Quel'Danas — Night",
    TRACK_MAGISTERS_WALK = "Magisters' Terrace — Exterior",
    TRACK_MAGISTERS_INTERIOR = "Magisters' Terrace — Interior",
    TRACK_MAGISTERS_KAELTHAS = "Magisters' Terrace — Kael'thas",
    TRACK_SUNWELL = "Sunwell Plateau",
    TRACK_ZULAMAN = "Zul'Aman",
    TRACK_JUNGLE_DAY = "Classic Jungle — Day",
    TRACK_JUNGLE_NIGHT = "Classic Jungle — Night",
    TRACK_ZULGURUB = "Zul'Gurub Moment",
    TRACK_SOGGY_DAY = "Classic Swamp — Day",
    TRACK_SOGGY_NIGHT = "Classic Swamp — Night",
    TRACK_BATTLE_TWO = "Classic Battle II",
    TRACK_BATTLE_FIVE = "Classic Battle V",
    TRACK_BATTLE_SIX = "Classic Battle VI",
    TRACK_ZANGARMARSH = "Zangarmarsh",
    TRACK_COILFANG = "Coilfang Reservoir",
    TRACK_ENCHANTED_FOREST_DAY = "Enchanted Forest — Day",
    TRACK_ENCHANTED_FOREST_NIGHT = "Enchanted Forest — Night",
    TRACK_DARNASSUS = "Darnassus",
    TRACK_NETHERSTORM = "Netherstorm",
    TRACK_NETHERPLANT = "Netherstorm — Manaforge",
    TRACK_ECODOMES = "Netherstorm — Eco-Domes",
    TRACK_BLOODELF_HOSTILE = "Outland Blood Elf — Hostile",
    TRACK_SHADOWMOON_CORRUPT = "Shadowmoon Valley — Corrupt",
    TRACK_TEMPEST_KEEP = "Tempest Keep",
    TRACK_BLACK_TEMPLE = "Black Temple",
    TRACK_BLACK_TEMPLE_KARABOR = "Black Temple — Karabor",
    TRACK_BLACK_TEMPLE_ANGUISH = "Black Temple — Anguish",
    TRACK_BLACK_TEMPLE_RELIQUARY = "Black Temple — Reliquary",
    TRACK_DESERT_CAVE = "Classic Cave",
    TRACK_WAILING_CAVERNS = "Wailing Caverns",

    NOW_PLAYING = "Now playing: %s (%s).",
    STATUS_ACTIVE = "%s; %s (SoundKit %d).",
    STATUS_TRANSITIONING = "%s; fading into %s.",
    STATUS_WAITING = "%s; %s; waiting for the next area because WoW's Loop Music option is off.",
    STATUS_IDLE = "Inactive. Classic Music: Midnight does not own playback.",
    STATUS_PAUSED = "Paused for a cinematic or loading screen.",
    STATUS_UNSUPPORTED = "This location is not mapped. Blizzard music is in control.",
    RESTORED = "Stopped and restored the captured WoW music setting.",
    MUSIC_DIALOGUE_ON = "Music and dialogue are on.",
    MUSIC_DIALOGUE_OFF = "Music and dialogue are off.",
    RESTARTED = "Restarted the current area's track.",
    NOTHING_TO_SKIP = "There is no Classic Music: Midnight track to skip.",
    POOL_FAILED = "No track in the %s playlist could be played. Blizzard music has been restored.",
    DEBUG_HEADER = "Debug: map=%s, ancestors=%s, instance=%s, type=%s, category=%s, playlist=%s, handle=%s, loop=%s, waiting=%s, time=%s, transition=%s",
    DEBUG_ON = "on",
    DEBUG_OFF = "off",
    DEBUG_YES = "yes",
    DEBUG_NO = "no",
    TIME_DAY = "day",
    TIME_NIGHT = "night",
    DEBUG_SECRET = "secret",
    DEBUG_NONE = "none",
    SLASH_HELP = "Commands: /bettermusic, toggle, next, status, restore, debug",
}

local localized = {}

-- Add locale overrides here. Missing keys always use the enUS fallback above.
local locale = GetLocale()
local overrides = {}

if locale == "enUS" then
    overrides = {}
end

setmetatable(localized, {
    __index = function(_, key)
        return overrides[key] or fallback[key] or key
    end,
})

ns.L = localized
