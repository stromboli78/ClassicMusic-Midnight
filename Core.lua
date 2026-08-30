local addonName, ns = ...

local L = ns.L
local MUSIC_CVAR = "Sound_EnableMusic"
local DIALOG_CVAR = "Sound_EnableDialog"
local ALL_SOUND_CVAR = "Sound_EnableAllSound"
local MUSIC_VOLUME_CVAR = "Sound_MusicVolume"
local LOOP_MUSIC_CVAR = "Sound_ZoneMusicNoDelay"
local CROSSFADE_MS = 750
local RESTART_FADE_MS = 250
local ZONE_HANDOFF_FADE_MS = 1250
local DEVICE_RECOVERY_DELAY = 0.75
local VOLUME_RESTART_DELAY = 0.6
local DAWN_MINUTES = (5 * 60) + 30
local DUSK_MINUTES = 21 * 60

local database
local initialized = false
local worldReady = false
local loadingScreen = false
local cinematicActive = false
local movieVisible = false
local movieHooked = false
local loggingOut = false
local refreshScheduled = false
local refreshSerial = 0
local transitionSerial = 0
local deviceRecoverySerial = 0
local restartSerial = 0
local volumeChangeSerial = 0
local areaEntrySerial = 0
local managedWriteSerial = 0
local managedWrites = {}
local warnedPools = {}
local suppressedSignature
local suppressedPlaylistKey
local lastContext
local lastResolution

local active = {
    playlistKey = nil,
    track = nil,
    handle = nil,
    content = nil,
    waitingForAreaEntry = false,
    waitingAreaEntrySerial = nil,
    transitioning = false,
    restarting = false,
}

local eventFrame = CreateFrame("Frame")

local function IsSecret(value)
    return issecretvalue and issecretvalue(value) or false
end

local function IsSafeNumber(value)
    return not IsSecret(value) and type(value) == "number"
end

local function IsSafeString(value)
    return not IsSecret(value) and type(value) == "string"
end

local function ClampVolume(value, fallback)
    if IsSecret(value) or type(value) ~= "number" or value ~= value then
        return fallback
    end
    return math.max(0, math.min(1, value))
end

local function Print(message)
    DEFAULT_CHAT_FRAME:AddMessage(("|cff33ff99%s:|r %s"):format(L.ADDON_NAME, message))
end

local function GetCVarString(name)
    local value = C_CVar.GetCVar(name)
    if IsSecret(value) or value == nil then
        return nil
    end
    return tostring(value)
end

local function SetManagedCVar(name, value)
    local lowerName = string.lower(name)
    managedWriteSerial = managedWriteSerial + 1
    local serial = managedWriteSerial
    managedWrites[lowerName] = serial

    local success = C_CVar.SetCVar(name, value)
    if not success then
        if managedWrites[lowerName] == serial then
            managedWrites[lowerName] = nil
        end
        return false
    end

    C_Timer.After(0, function()
        if managedWrites[lowerName] == serial then
            managedWrites[lowerName] = nil
        end
    end)
    return true
end

local function GetDefaultMusicVolume()
    local value = C_CVar.GetCVarDefault(MUSIC_VOLUME_CVAR)
    value = not IsSecret(value) and tonumber(value) or nil
    return ClampVolume(value, 0.5)
end

local function GetCurrentMusicVolume()
    local value = C_CVar.GetCVar(MUSIC_VOLUME_CVAR)
    value = not IsSecret(value) and tonumber(value) or nil
    return ClampVolume(value, GetDefaultMusicVolume())
end

local function IsNightTime()
    if type(GetGameTime) ~= "function" then
        return false
    end

    local hour, minute = GetGameTime()
    if not IsSafeNumber(hour) or not IsSafeNumber(minute) then
        return false
    end

    local minutesSinceMidnight = (hour * 60) + minute
    return minutesSinceMidnight < DAWN_MINUTES or minutesSinceMidnight >= DUSK_MINUTES
end

local function IsMusicLoopingEnabled()
    return GetCVarString(LOOP_MUSIC_CVAR) == "1"
end

local function RestoreInterruptedSession()
    local session = BetterMusicDB.audioSession
    if type(session) == "table"
        and session.active == true
        and session.previous == "1"
        and session.desired == "0"
    then
        local current = GetCVarString(MUSIC_CVAR)
        if current == session.desired and current ~= session.previous then
            SetManagedCVar(MUSIC_CVAR, session.previous)
        end
    end
    BetterMusicDB.audioSession = nil
end

local function InitializeDatabase()
    if type(BetterMusicDB) ~= "table" then
        BetterMusicDB = {}
    end

    RestoreInterruptedSession()
    ns.Defaults.volume = GetDefaultMusicVolume()

    for _, key in ipairs({ "enabled", "outdoors", "dungeons", "raids", "delves", "announceTrack" }) do
        if type(BetterMusicDB[key]) ~= "boolean" then
            BetterMusicDB[key] = ns.Defaults[key]
        end
    end

    if type(BetterMusicDB.volume) ~= "number" or BetterMusicDB.volume ~= BetterMusicDB.volume then
        BetterMusicDB.volume = GetCurrentMusicVolume()
    else
        BetterMusicDB.volume = ClampVolume(BetterMusicDB.volume, ns.Defaults.volume)
    end

    BetterMusicDB.schemaVersion = 1
    database = BetterMusicDB
end

local function GetMapChain()
    local chain = {}
    local mapID = C_Map.GetBestMapForUnit("player")
    if not IsSafeNumber(mapID) then
        return chain
    end

    local seen = {}
    for _ = 1, 16 do
        if not IsSafeNumber(mapID) or mapID <= 0 or seen[mapID] then
            break
        end

        seen[mapID] = true
        chain[#chain + 1] = mapID

        local mapInfo = C_Map.GetMapInfo(mapID)
        if IsSecret(mapInfo) or type(mapInfo) ~= "table" or not IsSafeNumber(mapInfo.parentMapID) then
            break
        end
        mapID = mapInfo.parentMapID
    end

    return chain
end

local function GetContext()
    local inInstance, instanceType = IsInInstance()
    if IsSecret(inInstance) or type(inInstance) ~= "boolean" then
        inInstance = false
    end
    if not IsSafeString(instanceType) then
        instanceType = "none"
    end

    local instanceID
    if inInstance then
        local _, reportedType, _, _, _, _, _, reportedID = GetInstanceInfo()
        if IsSafeString(reportedType) then
            instanceType = reportedType
        end
        if IsSafeNumber(reportedID) then
            instanceID = reportedID
        end
    end

    return {
        inInstance = inInstance,
        instanceType = instanceType,
        instanceID = instanceID,
        maps = GetMapChain(),
    }
end

local function BuildResolution(category, playlistKey, sourceKind, sourceID)
    if not ns.Playlists[playlistKey] then
        return nil
    end
    return {
        category = category,
        playlistKey = playlistKey,
        sourceKind = sourceKind,
        sourceID = sourceID,
        signature = ("%s:%s:%s:%s"):format(category, playlistKey, sourceKind, tostring(sourceID)),
    }
end

local function ResolveContent(context)
    if context.inInstance and context.instanceID then
        local instanceEntry = ns.InstancePlaylists[context.instanceID]
        if instanceEntry then
            return BuildResolution(instanceEntry.category, instanceEntry.playlist, "instance", context.instanceID)
        end
    end

    if context.inInstance then
        if context.instanceType ~= "party" and context.instanceType ~= "raid" and context.instanceType ~= "scenario" then
            return nil
        end

        for _, mapID in ipairs(context.maps) do
            local mapEntry = ns.InstanceMapPlaylists[mapID]
            if mapEntry then
                return BuildResolution(mapEntry.category, mapEntry.playlist, "instanceMap", mapID)
            end
        end

        -- Ordinary story scenarios inherit their associated outdoor theme. The
        -- map ID must still be explicitly registered; future scenarios are not
        -- guessed from their localized names or their expansion root.
        if context.instanceType == "scenario" then
            for _, mapID in ipairs(context.maps) do
                local playlistKey = ns.OutdoorMapPlaylists[mapID]
                if playlistKey then
                    return BuildResolution("outdoors", playlistKey, "scenarioMap", mapID)
                end
            end
        end
        return nil
    end

    for _, mapID in ipairs(context.maps) do
        local playlistKey = ns.OutdoorMapPlaylists[mapID]
        if playlistKey then
            return BuildResolution("outdoors", playlistKey, "map", mapID)
        end
    end
    return nil
end

local function CategoryEnabled(category)
    return database.enabled and database[category] == true
end

local function IsPaused()
    return loadingScreen or cinematicActive or movieVisible
end

local function StopActiveSound(fadeMilliseconds)
    refreshSerial = refreshSerial + 1
    local handle = active.handle
    active.handle = nil
    if IsSafeNumber(handle) then
        StopSound(handle, fadeMilliseconds or 0)
    end
end

local function ClearAreaEntryWait()
    active.waitingForAreaEntry = false
    active.waitingAreaEntrySerial = nil
end

local function CancelZoneTransition()
    transitionSerial = transitionSerial + 1
    active.transitioning = false
end

local function CancelTrackRestart()
    restartSerial = restartSerial + 1
    active.restarting = false
end

local function RestoreMusicCVar(keepSession)
    local session = database and database.audioSession
    if type(session) ~= "table" or session.active ~= true then
        if database and not keepSession then
            database.audioSession = nil
        end
        return
    end

    local current = GetCVarString(MUSIC_CVAR)
    if current == session.desired and current ~= session.previous then
        SetManagedCVar(MUSIC_CVAR, session.previous)
    end

    if not keepSession then
        database.audioSession = nil
    end
end

local function ReleaseControl(fadeMilliseconds, keepTrack)
    CancelZoneTransition()
    CancelTrackRestart()
    deviceRecoverySerial = deviceRecoverySerial + 1
    volumeChangeSerial = volumeChangeSerial + 1
    StopActiveSound(fadeMilliseconds)
    RestoreMusicCVar(loggingOut)
    active.playlistKey = nil
    active.content = nil
    ClearAreaEntryWait()
    if not keepTrack then
        active.track = nil
    end
end

local function OwnsMusicCVar()
    local session = database.audioSession
    return type(session) == "table"
        and session.active == true
        and GetCVarString(MUSIC_CVAR) == session.desired
end

local function AcquireMusicCVar()
    if OwnsMusicCVar() then
        return true
    end

    if GetCVarString(ALL_SOUND_CVAR) ~= "1" or GetCVarString(MUSIC_CVAR) ~= "1" then
        return false
    end

    local session = {
        active = true,
        previous = "1",
        desired = "0",
    }
    database.audioSession = session

    if not SetManagedCVar(MUSIC_CVAR, session.desired) then
        database.audioSession = nil
        return false
    end
    return true
end

local function GetPreferredTrack(playlist)
    if playlist.dayTrack and playlist.nightTrack then
        return IsNightTime() and playlist.nightTrack or playlist.dayTrack
    end
    return playlist.tracks[1]
end

local function DrawTrack(playlistKey)
    return GetPreferredTrack(ns.Playlists[playlistKey])
end

local function PlayTrack(playlistKey, track, announce)
    local success, handle = C_Sound.PlaySound(
        track.id,
        "Master",
        false,
        true,
        nil,
        database.volume
    )

    if IsSecret(success) or success ~= true or not IsSafeNumber(handle) then
        return false
    end

    active.playlistKey = playlistKey
    active.track = track
    active.handle = handle
    active.transitioning = false
    active.restarting = false
    ClearAreaEntryWait()

    if announce and database.announceTrack then
        Print(L.NOW_PLAYING:format(L[track.labelKey], L["ERA_" .. track.era]))
    end
    return true
end

local function BuildRecoveryOrder(playlistKey, firstTrack)
    local playlist = ns.Playlists[playlistKey]
    local order = { firstTrack }
    local remaining = {}

    for _, track in ipairs(playlist.tracks) do
        if track.id ~= firstTrack.id then
            remaining[#remaining + 1] = track
        end
    end
    for _, track in ipairs(remaining) do
        order[#order + 1] = track
    end
    return order
end

local function StartTrackWithRecovery(playlistKey, firstTrack, announce)
    local playlist = ns.Playlists[playlistKey]
    if not playlist or #playlist.tracks == 0 then
        return false
    end

    firstTrack = firstTrack or DrawTrack(playlistKey)
    local order = BuildRecoveryOrder(playlistKey, firstTrack)
    for _, track in ipairs(order) do
        if PlayTrack(playlistKey, track, announce) then
            return true
        end
    end

    if not warnedPools[playlistKey] then
        warnedPools[playlistKey] = true
        Print(L.POOL_FAILED:format(L[playlist.labelKey]))
    end
    return false
end

local function StartNextTrack(announce)
    local playlistKey = active.playlistKey
    if not playlistKey or not AcquireMusicCVar() then
        return false
    end

    if StartTrackWithRecovery(playlistKey, nil, announce) then
        return true
    end

    suppressedPlaylistKey = playlistKey
    ReleaseControl(CROSSFADE_MS)
    return false
end

local function EvaluateState()
    refreshScheduled = false
    if not initialized or not worldReady or loggingOut then
        return
    end

    local context = GetContext()
    local resolution = ResolveContent(context)
    lastContext = context
    lastResolution = resolution

    if IsPaused() or not resolution or not CategoryEnabled(resolution.category) then
        ReleaseControl(CROSSFADE_MS)
        return
    end

    if suppressedSignature then
        if suppressedSignature == resolution.signature then
            ReleaseControl(CROSSFADE_MS)
            return
        end
        suppressedSignature = nil
    end

    if suppressedPlaylistKey then
        if suppressedPlaylistKey == resolution.playlistKey then
            ReleaseControl(CROSSFADE_MS)
            return
        end
        suppressedPlaylistKey = nil
    end

    if GetCVarString(ALL_SOUND_CVAR) ~= "1" then
        ReleaseControl(CROSSFADE_MS)
        return
    end

    if not OwnsMusicCVar() and GetCVarString(MUSIC_CVAR) ~= "1" then
        ReleaseControl(CROSSFADE_MS)
        return
    end

    local poolChanged = active.playlistKey ~= resolution.playlistKey
    active.content = resolution

    if active.restarting then
        if not poolChanged then
            return
        end
        CancelTrackRestart()
    end

    if active.transitioning then
        -- Keep the original fade deadline if several zone events arrive during
        -- one handoff, but always target the most recently resolved profile.
        if poolChanged then
            active.playlistKey = resolution.playlistKey
            active.track = nil
            ClearAreaEntryWait()
        end
        return
    end

    if not poolChanged and active.handle then
        return
    end

    if not poolChanged and active.waitingForAreaEntry then
        local enteredAnotherArea = active.waitingAreaEntrySerial
            and areaEntrySerial > active.waitingAreaEntrySerial
        if not IsMusicLoopingEnabled() and not enteredAnotherArea then
            return
        end
        ClearAreaEntryWait()
    end

    if poolChanged then
        local hadActiveSound = IsSafeNumber(active.handle)
        StopActiveSound(hadActiveSound and ZONE_HANDOFF_FADE_MS or 0)
        ClearAreaEntryWait()
        active.playlistKey = resolution.playlistKey
        active.track = nil

        if hadActiveSound then
            transitionSerial = transitionSerial + 1
            local serial = transitionSerial
            active.transitioning = true
            C_Timer.After(ZONE_HANDOFF_FADE_MS / 1000, function()
                if serial ~= transitionSerial or not active.transitioning then
                    return
                end
                active.transitioning = false
                EvaluateState()
            end)
            return
        end
    end

    if not AcquireMusicCVar() or not StartNextTrack(true) then
        ReleaseControl(CROSSFADE_MS)
    end
end

local function ScheduleRefresh(delay)
    refreshSerial = refreshSerial + 1
    local serial = refreshSerial
    if not delay or delay <= 0 then
        if refreshScheduled then
            return
        end
        refreshScheduled = true
    end

    C_Timer.After(delay or 0, function()
        if serial == refreshSerial or (delay or 0) <= 0 then
            EvaluateState()
        end
    end)
end

local function RestartCurrentTrack()
    if not active.handle or not active.track or not active.playlistKey then
        ScheduleRefresh()
        return
    end

    local playlistKey = active.playlistKey
    local track = active.track
    StopActiveSound(RESTART_FADE_MS)
    active.playlistKey = playlistKey
    active.track = track
    active.restarting = true

    restartSerial = restartSerial + 1
    local serial = restartSerial
    C_Timer.After(RESTART_FADE_MS / 1000, function()
        if serial ~= restartSerial then
            return
        end
        active.restarting = false
        if IsPaused() or not OwnsMusicCVar() then
            ScheduleRefresh()
            return
        end
        if not StartTrackWithRecovery(playlistKey, track, false) then
            suppressedPlaylistKey = playlistKey
            ReleaseControl(CROSSFADE_MS)
        end
    end)
end

local function ScheduleSoundDeviceRecovery()
    deviceRecoverySerial = deviceRecoverySerial + 1
    local serial = deviceRecoverySerial

    C_Timer.After(DEVICE_RECOVERY_DELAY, function()
        if serial ~= deviceRecoverySerial or loggingOut or IsPaused()
            or active.transitioning or active.restarting
        then
            return
        end

        local handle = active.handle
        if IsSafeNumber(handle) and C_Sound.IsPlaying then
            local isPlaying = C_Sound.IsPlaying(handle)
            if not IsSecret(isPlaying) and isPlaying == true then
                return
            end
        end

        local playlistKey = active.playlistKey
        local track = active.track
        if not playlistKey or not track then
            ScheduleRefresh()
            return
        end

        -- A device reset or background mute can emit SOUNDKIT_FINISHED even
        -- though the track did not complete naturally. Clear the non-looping
        -- wait state and rebuild the same area track on the restored device.
        ClearAreaEntryWait()
        StopActiveSound(0)
        active.playlistKey = playlistKey
        active.track = track

        if not OwnsMusicCVar() then
            ScheduleRefresh()
        elseif not StartTrackWithRecovery(playlistKey, track, false) then
            suppressedPlaylistKey = playlistKey
            ReleaseControl(CROSSFADE_MS)
        end
    end)
end

local function PausePlayback()
    if active.handle or OwnsMusicCVar() then
        ReleaseControl(CROSSFADE_MS)
    end
end

local function HookMovieFrame()
    if movieHooked then
        return
    end

    local movieFrame = _G.MovieFrame
    if not movieFrame or type(movieFrame.HookScript) ~= "function" then
        return
    end

    movieHooked = true
    movieFrame:HookScript("OnShow", function()
        movieVisible = true
        PausePlayback()
    end)
    movieFrame:HookScript("OnHide", function()
        movieVisible = false
        ScheduleRefresh(0.1)
    end)

    if movieFrame:IsShown() then
        movieVisible = true
        PausePlayback()
    end
end

local function HandleCVarUpdate(cvarName, value)
    if not initialized or loggingOut or not IsSafeString(cvarName) or IsSecret(value) then
        return
    end

    local lowerName = string.lower(cvarName)
    if managedWrites[lowerName] then
        return
    end

    if lowerName == string.lower(MUSIC_CVAR) then
        local newValue = tostring(value)
        local session = database.audioSession
        if type(session) == "table" and session.active == true and newValue ~= session.desired then
            suppressedSignature = lastResolution and lastResolution.signature or nil
            ReleaseControl(CROSSFADE_MS)
            return
        end
        ScheduleRefresh()
    elseif lowerName == string.lower(ALL_SOUND_CVAR) then
        if tostring(value) ~= "1" then
            ReleaseControl(CROSSFADE_MS)
        else
            ScheduleRefresh()
        end
    elseif lowerName == string.lower(LOOP_MUSIC_CVAR) then
        if IsMusicLoopingEnabled() and active.waitingForAreaEntry then
            ScheduleRefresh()
        end
    end
end

local function SafeDebugValue(value)
    if IsSecret(value) then
        return L.DEBUG_SECRET
    end
    if value == nil then
        return L.DEBUG_NONE
    end
    return tostring(value)
end

function ns.GetDatabase()
    return database
end

function ns.OnSettingChanged(key)
    if not initialized then
        return
    end

    if key == "volume" then
        volumeChangeSerial = volumeChangeSerial + 1
        local serial = volumeChangeSerial
        C_Timer.After(VOLUME_RESTART_DELAY, function()
            if serial == volumeChangeSerial and active.handle and not IsPaused() then
                RestartCurrentTrack()
            end
        end)
    elseif key ~= "announceTrack" then
        ScheduleRefresh()
    end
end

function ns.NextTrack()
    if not active.handle or not active.playlistKey or IsPaused() then
        Print(L.NOTHING_TO_SKIP)
        return
    end

    StopActiveSound(CROSSFADE_MS)
    if StartNextTrack(true) then
        Print(L.RESTARTED)
    end
end

function ns.PrintStatus()
    local context = GetContext()
    local resolution = ResolveContent(context)
    lastContext = context
    lastResolution = resolution

    if IsPaused() then
        Print(L.STATUS_PAUSED)
    elseif active.transitioning and active.playlistKey and active.content then
        local playlist = ns.Playlists[active.playlistKey]
        local targetTrack = GetPreferredTrack(playlist)
        Print(L.STATUS_TRANSITIONING:format(
            L["CATEGORY_" .. string.upper(active.content.category)],
            L[targetTrack.labelKey]
        ))
    elseif active.handle and active.track and active.playlistKey then
        Print(L.STATUS_ACTIVE:format(
            L["CATEGORY_" .. string.upper(active.content.category)],
            L[active.track.labelKey],
            active.track.id
        ))
    elseif active.waitingForAreaEntry and active.playlistKey and active.content then
        local playlist = ns.Playlists[active.playlistKey]
        Print(L.STATUS_WAITING:format(
            L["CATEGORY_" .. string.upper(active.content.category)],
            L[active.track and active.track.labelKey or playlist.labelKey]
        ))
    elseif resolution then
        Print(L.STATUS_IDLE)
    else
        Print(L.STATUS_UNSUPPORTED)
    end
end

function ns.Restore()
    local context = GetContext()
    local resolution = ResolveContent(context)
    suppressedSignature = resolution and resolution.signature or nil
    suppressedPlaylistKey = nil
    ReleaseControl(CROSSFADE_MS)
    Print(L.RESTORED)
end

function ns.ToggleMusicAndDialogue()
    local musicIsLogicallyOn = OwnsMusicCVar() or GetCVarString(MUSIC_CVAR) == "1"

    -- A manual music toggle must override a prior external-CVar suppression.
    -- Pool-failure suppression is deliberately retained so a broken playlist
    -- cannot be forced into another all-track retry loop.
    suppressedSignature = nil

    if musicIsLogicallyOn then
        ReleaseControl(CROSSFADE_MS)
        SetManagedCVar(MUSIC_CVAR, "0")
        SetManagedCVar(DIALOG_CVAR, "0")
        Print(L.MUSIC_DIALOGUE_OFF)
    else
        SetManagedCVar(DIALOG_CVAR, "1")
        SetManagedCVar(MUSIC_CVAR, "1")
        ScheduleRefresh()
        Print(L.MUSIC_DIALOGUE_ON)
    end
end

function ns.PrintDebug()
    local context = GetContext()
    local resolution = ResolveContent(context)
    lastContext = context
    lastResolution = resolution

    local ancestors = {}
    for _, mapID in ipairs(context.maps) do
        ancestors[#ancestors + 1] = SafeDebugValue(mapID)
    end

    Print(L.DEBUG_HEADER:format(
        SafeDebugValue(context.maps[1]),
        #ancestors > 0 and table.concat(ancestors, ">") or L.DEBUG_NONE,
        SafeDebugValue(context.instanceID),
        SafeDebugValue(context.instanceType),
        resolution and resolution.category or L.DEBUG_NONE,
        resolution and resolution.playlistKey or L.DEBUG_NONE,
        SafeDebugValue(active.handle),
        IsMusicLoopingEnabled() and L.DEBUG_ON or L.DEBUG_OFF,
        active.waitingForAreaEntry and L.DEBUG_YES or L.DEBUG_NO,
        IsNightTime() and L.TIME_NIGHT or L.TIME_DAY,
        active.transitioning and L.DEBUG_YES or L.DEBUG_NO
    ))
end

eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(_, event, ...)
    if event == "ADDON_LOADED" then
        local loadedAddon = ...
        if loadedAddon == addonName then
            InitializeDatabase()
            initialized = true

            eventFrame:RegisterEvent("PLAYER_LOGIN")
            eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
            eventFrame:RegisterEvent("PLAYER_LOGOUT")
            eventFrame:RegisterEvent("LOADING_SCREEN_ENABLED")
            eventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
            eventFrame:RegisterEvent("ZONE_CHANGED")
            eventFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
            eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
            eventFrame:RegisterEvent("CINEMATIC_START")
            eventFrame:RegisterEvent("CINEMATIC_STOP")
            eventFrame:RegisterEvent("CVAR_UPDATE")
            eventFrame:RegisterEvent("SOUND_DEVICE_UPDATE")
            eventFrame:RegisterEvent("SOUNDKIT_FINISHED")

            if ns.InitializeSettings then
                ns.InitializeSettings()
            end
            HookMovieFrame()
            if movieHooked then
                eventFrame:UnregisterEvent("ADDON_LOADED")
            end
        else
            HookMovieFrame()
            if initialized and movieHooked then
                eventFrame:UnregisterEvent("ADDON_LOADED")
            end
        end
    elseif event == "PLAYER_LOGIN" then
        HookMovieFrame()
    elseif event == "PLAYER_ENTERING_WORLD" then
        worldReady = true
        loadingScreen = false
        areaEntrySerial = areaEntrySerial + 1
        HookMovieFrame()
        ScheduleRefresh()
    elseif event == "PLAYER_LOGOUT" then
        loggingOut = true
        ReleaseControl(0)
    elseif event == "LOADING_SCREEN_ENABLED" then
        loadingScreen = true
        PausePlayback()
    elseif event == "LOADING_SCREEN_DISABLED" then
        loadingScreen = false
        ScheduleRefresh()
    elseif event == "ZONE_CHANGED" or event == "ZONE_CHANGED_INDOORS" or event == "ZONE_CHANGED_NEW_AREA" then
        areaEntrySerial = areaEntrySerial + 1
        ScheduleRefresh()
    elseif event == "CINEMATIC_START" then
        cinematicActive = true
        PausePlayback()
    elseif event == "CINEMATIC_STOP" then
        cinematicActive = false
        ScheduleRefresh(0.1)
    elseif event == "CVAR_UPDATE" then
        HandleCVarUpdate(...)
    elseif event == "SOUND_DEVICE_UPDATE" then
        ScheduleSoundDeviceRecovery()
    elseif event == "SOUNDKIT_FINISHED" then
        local finishedHandle = ...
        if not IsSecret(finishedHandle) and active.handle and finishedHandle == active.handle then
            active.handle = nil
            if IsMusicLoopingEnabled() then
                StartNextTrack(true)
            else
                active.waitingForAreaEntry = true
                active.waitingAreaEntrySerial = areaEntrySerial
            end
        end
    end
end)
