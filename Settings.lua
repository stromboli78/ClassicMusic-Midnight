local _, ns = ...

local L = ns.L
local category

local function RegisterCheckbox(variable, key, label, tooltip)
    local setting = Settings.RegisterAddOnSetting(
        category,
        variable,
        key,
        ns.GetDatabase(),
        Settings.VarType.Boolean,
        label,
        ns.Defaults[key]
    )
    setting:SetValueChangedCallback(function()
        ns.OnSettingChanged(key)
    end)
    Settings.CreateCheckbox(category, setting, tooltip)
end

local function RegisterVolumeSlider()
    local setting = Settings.RegisterAddOnSetting(
        category,
        "BETTER_MUSIC_VOLUME",
        "volume",
        ns.GetDatabase(),
        Settings.VarType.Number,
        L.VOLUME,
        ns.Defaults.volume
    )
    setting:SetValueChangedCallback(function()
        ns.OnSettingChanged("volume")
    end)

    local options = Settings.CreateSliderOptions(0, 1, 0.05)
    options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
        return L.PERCENT_FORMAT:format(math.floor((value * 100) + 0.5))
    end)
    Settings.CreateSlider(category, setting, options, L.VOLUME_TOOLTIP)
end

function ns.InitializeSettings()
    local layout
    category, layout = Settings.RegisterVerticalLayoutCategory(L.ADDON_NAME)

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.SECTION_GENERAL))
    RegisterCheckbox("BETTER_MUSIC_ENABLED", "enabled", L.ENABLED, L.ENABLED_TOOLTIP)

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.SECTION_CONTENT))
    RegisterCheckbox("BETTER_MUSIC_OUTDOORS", "outdoors", L.OUTDOORS, L.OUTDOORS_TOOLTIP)
    RegisterCheckbox("BETTER_MUSIC_DUNGEONS", "dungeons", L.DUNGEONS, L.DUNGEONS_TOOLTIP)
    RegisterCheckbox("BETTER_MUSIC_RAIDS", "raids", L.RAIDS, L.RAIDS_TOOLTIP)
    RegisterCheckbox("BETTER_MUSIC_DELVES", "delves", L.DELVES, L.DELVES_TOOLTIP)

    layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(L.SECTION_PLAYBACK))
    RegisterVolumeSlider()
    RegisterCheckbox(
        "BETTER_MUSIC_ANNOUNCE_TRACK",
        "announceTrack",
        L.ANNOUNCE_TRACK,
        L.ANNOUNCE_TRACK_TOOLTIP
    )

    Settings.RegisterAddOnCategory(category)
end

function ns.OpenSettings()
    if category then
        Settings.OpenToCategory(category:GetID())
    end
end

SLASH_BETTERMUSIC1 = "/bettermusic"
SlashCmdList.BETTERMUSIC = function(message)
    message = string.lower(strtrim(message or ""))
    if message == "" then
        ns.OpenSettings()
    elseif message == "next" then
        ns.NextTrack()
    elseif message == "status" then
        ns.PrintStatus()
    elseif message == "restore" then
        ns.Restore()
    elseif message == "toggle" then
        ns.ToggleMusicAndDialogue()
    elseif message == "debug" then
        ns.PrintDebug()
    else
        DEFAULT_CHAT_FRAME:AddMessage(("|cff33ff99%s:|r %s"):format(L.ADDON_NAME, L.SLASH_HELP))
    end
end
