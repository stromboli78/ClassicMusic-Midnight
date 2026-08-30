local _, ns = ...

local function Track(id, labelKey, era)
    return {
        id = id,
        labelKey = labelKey,
        era = era,
    }
end

local function SingleTrack(id, labelKey, era)
    local track = Track(id, labelKey, era)
    return { labelKey = labelKey, tracks = { track } }
end

local function DayNight(dayID, dayLabelKey, nightID, nightLabelKey, era)
    local dayTrack = Track(dayID, dayLabelKey, era)
    local nightTrack = Track(nightID, nightLabelKey, era)
    return {
        labelKey = dayLabelKey,
        tracks = { dayTrack, nightTrack },
        dayTrack = dayTrack,
        nightTrack = nightTrack,
    }
end

-- Every entry is a Blizzard SoundKit. The IDs below were cross-checked against
-- the installed 12.1 client-era soundtrack catalogue and are validated again by
-- C_Sound.PlaySound at runtime before the addon retains a playback handle.
-- Each content profile contains one fixed SoundKit or one verified day/night
-- pair. This mirrors Classic-era zone identity instead of rotating a broad
-- mood pool.
ns.Playlists = {
    eversong = DayNight(9789, "TRACK_EVERSONG_DAY", 9790, "TRACK_EVERSONG_NIGHT", "TBC"),
    eversongRuins = DayNight(9797, "TRACK_EVERSONG_RUINS_DAY", 9798, "TRACK_EVERSONG_RUINS_NIGHT", "TBC"),
    eversongBuildings = SingleTrack(9795, "TRACK_EVERSONG_BUILDINGS_DAY", "TBC"),
    silvermoon = DayNight(9793, "TRACK_SILVERMOON_DAY", 9794, "TRACK_SILVERMOON_NIGHT", "TBC"),
    ghostlandsDark = SingleTrack(10869, "TRACK_GHOSTLANDS_DARK", "TBC"),
    queldanas = DayNight(12528, "TRACK_QUELDANAS_DAY", 12529, "TRACK_QUELDANAS_NIGHT", "TBC"),
    queldanasDay = SingleTrack(12528, "TRACK_QUELDANAS_DAY", "TBC"),
    magistersInterior = SingleTrack(12533, "TRACK_MAGISTERS_INTERIOR", "TBC"),
    sunwell = SingleTrack(12536, "TRACK_SUNWELL", "TBC"),
    zulaman = SingleTrack(12133, "TRACK_ZULAMAN", "TBC"),
    zulgurub = SingleTrack(8452, "TRACK_ZULGURUB", "VANILLA"),
    swamp = DayNight(7082, "TRACK_SOGGY_DAY", 6836, "TRACK_SOGGY_NIGHT", "VANILLA"),
    swampDay = SingleTrack(7082, "TRACK_SOGGY_DAY", "VANILLA"),
    swampNight = SingleTrack(6836, "TRACK_SOGGY_NIGHT", "VANILLA"),
    battleSix = SingleTrack(6350, "TRACK_BATTLE_SIX", "VANILLA"),
    zangarmarsh = SingleTrack(9149, "TRACK_ZANGARMARSH", "TBC"),
    coilfang = SingleTrack(10726, "TRACK_COILFANG", "TBC"),
    enchantedForest = DayNight(2530, "TRACK_ENCHANTED_FOREST_DAY", 2540, "TRACK_ENCHANTED_FOREST_NIGHT", "VANILLA"),
    enchantedForestDay = SingleTrack(2530, "TRACK_ENCHANTED_FOREST_DAY", "VANILLA"),
    enchantedForestNight = SingleTrack(2540, "TRACK_ENCHANTED_FOREST_NIGHT", "VANILLA"),
    netherstorm = SingleTrack(9284, "TRACK_NETHERSTORM", "TBC"),
    netherplant = SingleTrack(10847, "TRACK_NETHERPLANT", "TBC"),
    ecodomes = SingleTrack(10849, "TRACK_ECODOMES", "TBC"),
    shadowmoon = SingleTrack(10848, "TRACK_SHADOWMOON_CORRUPT", "TBC"),
    tempestKeep = SingleTrack(12128, "TRACK_TEMPEST_KEEP", "TBC"),
    blackTemple = SingleTrack(11696, "TRACK_BLACK_TEMPLE", "TBC"),
    blackTempleAnguish = SingleTrack(11700, "TRACK_BLACK_TEMPLE_ANGUISH", "TBC"),
    blackTempleReliquary = SingleTrack(11702, "TRACK_BLACK_TEMPLE_RELIQUARY", "TBC"),
    desertCave = SingleTrack(5394, "TRACK_DESERT_CAVE", "VANILLA"),
    wailingCaverns = SingleTrack(22829, "TRACK_WAILING_CAVERNS", "VANILLA"),
}

-- GetInstanceInfo() instance IDs. Explicit aliases win over UI-map ancestry.
ns.InstancePlaylists = {
    -- Midnight dungeons
    [2805] = { category = "dungeons", playlist = "eversongBuildings" }, -- Windrunner Spire
    [2811] = { category = "dungeons", playlist = "magistersInterior" }, -- Magisters' Terrace
    [2813] = { category = "dungeons", playlist = "ghostlandsDark" },    -- Murder Row
    [2825] = { category = "dungeons", playlist = "zulaman" },           -- Den of Nalorakk
    [2859] = { category = "dungeons", playlist = "enchantedForestDay" }, -- Blinding Vale
    [2874] = { category = "dungeons", playlist = "wailingCaverns" },    -- Maisara Caverns
    [2915] = { category = "dungeons", playlist = "tempestKeep" },       -- Nexus-Point Xenas
    [2923] = { category = "dungeons", playlist = "blackTempleAnguish" }, -- Voidscar Arena
    [2993] = { category = "dungeons", playlist = "zulaman" },           -- Altar of Fangs

    -- Midnight raids
    [2912] = { category = "raids", playlist = "blackTemple" },          -- The Voidspire
    [2913] = { category = "raids", playlist = "sunwell" },              -- March on Quel'Danas
    [2939] = { category = "raids", playlist = "enchantedForestNight" }, -- The Dreamrift
    [3004] = { category = "raids", playlist = "zulgurub" },             -- The Venomous Abyss
    [1592] = { category = "raids", playlist = "zangarmarsh" },          -- Sporefall

    -- Midnight delves and lairs
    [2933] = { category = "delves", playlist = "eversongBuildings" },    -- Collegiate Calamity
    [2952] = { category = "delves", playlist = "shadowmoon" },           -- The Shadow Enclave
    [2953] = { category = "delves", playlist = "queldanasDay" },         -- Parhelion Plaza
    [2961] = { category = "delves", playlist = "zulgurub" },             -- Twilight Crypts
    [2962] = { category = "delves", playlist = "zulaman" },              -- Atal'Aman
    [2963] = { category = "delves", playlist = "wailingCaverns" },       -- The Grudge Pit
    [2964] = { category = "delves", playlist = "enchantedForestNight" }, -- The Gulf of Memory
    [2965] = { category = "delves", playlist = "netherplant" },          -- Sunkiller Sanctum
    [2966] = { category = "delves", playlist = "blackTempleAnguish" },   -- Torment's Rise
    [2979] = { category = "delves", playlist = "shadowmoon" },           -- Shadowguard Point
    [2987] = { category = "delves", playlist = "zulgurub" },             -- Nymrissa's lair
    [3003] = { category = "delves", playlist = "desertCave" },           -- The Darkway
    [3038] = { category = "delves", playlist = "battleSix" },            -- Ring of Glory
    [3077] = { category = "delves", playlist = "swampDay" },             -- Gnarldor Isle
    [3079] = { category = "delves", playlist = "swampNight" },           -- Venomfall Deeps
}

-- Dungeon UI maps are a fallback for phase/map transitions that briefly report
-- no usable instance ID. They are consulted only while inside an instance.
-- Dungeon floors were verified against the current Mythic Dungeon Tools data;
-- delve floors were cross-checked against the current Midnight HandyNotes data.
ns.InstanceMapPlaylists = {
    -- Windrunner Spire
    [2492] = { category = "dungeons", playlist = "eversongBuildings" },
    [2493] = { category = "dungeons", playlist = "eversongBuildings" },
    [2494] = { category = "dungeons", playlist = "eversongBuildings" },
    [2496] = { category = "dungeons", playlist = "eversongBuildings" },
    [2497] = { category = "dungeons", playlist = "eversongBuildings" },
    [2498] = { category = "dungeons", playlist = "eversongBuildings" },
    [2499] = { category = "dungeons", playlist = "eversongBuildings" },

    -- Magisters' Terrace
    [2424] = { category = "dungeons", playlist = "magistersInterior" },
    [2511] = { category = "dungeons", playlist = "magistersInterior" },
    [2515] = { category = "dungeons", playlist = "magistersInterior" },
    [2516] = { category = "dungeons", playlist = "magistersInterior" },
    [2517] = { category = "dungeons", playlist = "magistersInterior" },
    [2518] = { category = "dungeons", playlist = "magistersInterior" },
    [2519] = { category = "dungeons", playlist = "magistersInterior" },
    [2520] = { category = "dungeons", playlist = "magistersInterior" },

    -- Murder Row
    [2433] = { category = "dungeons", playlist = "ghostlandsDark" },
    [2434] = { category = "dungeons", playlist = "ghostlandsDark" },
    [2435] = { category = "dungeons", playlist = "ghostlandsDark" },

    -- Den of Nalorakk
    [2513] = { category = "dungeons", playlist = "zulaman" },
    [2514] = { category = "dungeons", playlist = "zulaman" },
    [2564] = { category = "dungeons", playlist = "zulaman" },

    -- Blinding Vale and Maisara Caverns
    [2500] = { category = "dungeons", playlist = "enchantedForestDay" },
    [2437] = { category = "dungeons", playlist = "wailingCaverns" },
    [2501] = { category = "dungeons", playlist = "wailingCaverns" },

    -- Nexus-Point Xenas and Voidscar Arena
    [2556] = { category = "dungeons", playlist = "tempestKeep" },
    [2572] = { category = "dungeons", playlist = "blackTempleAnguish" },
    [2573] = { category = "dungeons", playlist = "blackTempleAnguish" },
    [2574] = { category = "dungeons", playlist = "blackTempleAnguish" },

    -- Altar of Fangs
    [2588] = { category = "dungeons", playlist = "zulaman" },
    [2589] = { category = "dungeons", playlist = "zulaman" },
    [2590] = { category = "dungeons", playlist = "zulaman" },

    -- Delve UI maps
    [2502] = { category = "delves", playlist = "shadowmoon" },           -- The Shadow Enclave
    [2504] = { category = "delves", playlist = "zulgurub" },             -- Twilight Crypts
    [2505] = { category = "delves", playlist = "enchantedForestNight" }, -- The Gulf of Memory
    [2506] = { category = "delves", playlist = "shadowmoon" },           -- Shadowguard Point
    [2507] = { category = "delves", playlist = "blackTempleAnguish" },   -- Torment's Rise
    [2510] = { category = "delves", playlist = "wailingCaverns" },       -- The Grudge Pit
    [2525] = { category = "delves", playlist = "desertCave" },           -- The Darkway
    [2528] = { category = "delves", playlist = "netherplant" },          -- Sunkiller Sanctum, upper
    [2535] = { category = "delves", playlist = "zulaman" },              -- Atal'Aman
    [2540] = { category = "delves", playlist = "netherplant" },          -- Sunkiller Sanctum, phase
    [2545] = { category = "delves", playlist = "queldanasDay" },         -- Parhelion Plaza
    [2547] = { category = "delves", playlist = "eversongBuildings" },    -- Collegiate Calamity
    [2571] = { category = "delves", playlist = "netherplant" },          -- Sunkiller Sanctum, lower
    [2633] = { category = "delves", playlist = "battleSix" },            -- Ring of Glory
    [2635] = { category = "delves", playlist = "swampDay" },             -- Gnarldor Isle
}

-- C_Map UI map IDs. Parent traversal allows subzones and phased child maps to
-- inherit a pool without comparing localized map names.
ns.OutdoorMapPlaylists = {
    [2393] = "silvermoon",             -- Silvermoon City
    [2395] = "eversong",               -- Eversong Woods
    [2443] = "silvermoon",             -- Silvermoon City phase
    [2541] = "silvermoon",             -- Arcantina
    [2594] = "eversongRuins",          -- Daggerspine Point
    [2561] = "eversong",               -- Quel'Thalas phase
    [2567] = "eversong",               -- Eversong phase
    [2424] = "queldanas",              -- Isle of Quel'Danas
    [2569] = "queldanas",              -- Isle of Quel'Danas phase
    [2437] = "zulaman",                -- Zul'Aman
    [2536] = "zulaman",                -- Atal'Aman region
    [2585] = "zulgurub",               -- Broken Throne
    [2568] = "zulaman",                -- Zul'Aman phase
    [2413] = "zangarmarsh",            -- Harandar / Rootlands
    [2480] = "zangarmarsh",            -- Harandar phase
    [2576] = "enchantedForest",        -- Blinding Vale approach
    [2600] = "coilfang",               -- Naigtal
    [2646] = "wailingCaverns",         -- Naigtal interior
    [2405] = "netherstorm",            -- Voidstorm
    [2444] = "shadowmoon",             -- Slayer's Rise
    [2479] = "netherstorm",            -- Voidstorm phase
    [2526] = "blackTemple",            -- Lair of Predaxas, upper
    [2527] = "blackTempleReliquary",   -- Lair of Predaxas, lower
    [2599] = "ecodomes",               -- Val
    [2512] = "swamp",                  -- Coiled Isle
    [2509] = "zulgurub",               -- Coiled Isle vault
    [2613] = "zulgurub",               -- Coiled Isle lower vault
    [2642] = "zulgurub",               -- Tomb of the Lost Priest
}

ns.Defaults = {
    schemaVersion = 1,
    enabled = true,
    outdoors = true,
    dungeons = true,
    raids = true,
    delves = true,
    announceTrack = false,
    volume = 0.5,
}
