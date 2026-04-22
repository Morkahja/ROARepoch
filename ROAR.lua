local f = CreateFrame("Frame")

local ADDON_PREFIX = "ROAR"
local playerName
local playerRoarID
local playerRoarSound

local roarSounds = {
    DwarfMale = "Sound\\Character\\PlayerRoars\\CharacterRoarsDwarfMale.wav",
    DwarfFemale = "Sound\\Character\\PlayerRoars\\CharacterRoarsDwarfFemale.wav",
    GnomeMale = "Sound\\Character\\PlayerRoars\\CharacterRoarsGnomeMale.wav",
    GnomeFemale = "Sound\\Character\\PlayerRoars\\CharacterRoarsGnomeFemale.wav",
    HumanMale = "Sound\\Character\\PlayerRoars\\CharacterRoarsHumanMale.wav",
    HumanFemale = "Sound\\Character\\PlayerRoars\\CharacterRoarsHumanFemale.wav",
    NightElfMale = "Sound\\Character\\PlayerRoars\\CharacterRoarsNightElfMale.wav",
    NightElfFemale = "Sound\\Character\\PlayerRoars\\CharacterRoarsNightElfFemale.wav",
    OrcMale = "Sound\\Character\\PlayerRoars\\CharacterRoarsOrcMale.wav",
    OrcFemale = "Sound\\Character\\PlayerRoars\\CharacterRoarsOrcFemale.wav",
    TaurenMale = "Sound\\Character\\PlayerRoars\\CharacterRoarsTaurenMale.wav",
    TaurenFemale = "Sound\\Character\\PlayerRoars\\CharacterRoarsTaurenFemale.wav",
    TrollMale = "Sound\\Character\\PlayerRoars\\CharacterRoarsTrollMale.wav",
    TrollFemale = "Sound\\Character\\PlayerRoars\\CharacterRoarsTrollFemale.wav",
    UndeadMale = "Sound\\Character\\PlayerRoars\\CharacterRoarsUndeadMale.wav",
    UndeadFemale = "Sound\\Character\\PlayerRoars\\CharacterRoarsUndeadFemale.wav",
}

local function NormalizeName(name)
    if not name then
        return nil
    end

    local dashPos = string.find(name, "-", 1, true)
    if dashPos then
        return string.sub(name, 1, dashPos - 1)
    end

    return name
end

local function GetPlayerRoarID()
    local _, raceFile = UnitRace("player")
    local sex = UnitSex("player")
    local sexText

    if sex == 2 then
        sexText = "Male"
    elseif sex == 3 then
        sexText = "Female"
    else
        return nil
    end

    if raceFile == "Scourge" then
        raceFile = "Undead"
    end

    if not raceFile then
        return nil
    end

    return raceFile .. sexText
end

local function UpdatePlayerRoar()
    playerRoarID = GetPlayerRoarID()

    if playerRoarID then
        playerRoarSound = roarSounds[playerRoarID]
    else
        playerRoarSound = nil
    end
end

local function IsMyRoar(text, sender)
    if NormalizeName(sender) ~= playerName then
        return false
    end

    if not text then
        return false
    end

    text = string.lower(text)

    if string.find(text, " roars", 1, true) then
        return true
    end

    if string.find(text, " roar", 1, true) then
        return true
    end

    return false
end

local function PlayRoarByID(roarID)
    local soundPath = roarSounds[roarID]

    if soundPath then
        PlaySoundFile(soundPath)
    end
end

local function SendRoarToAddonUsers(roarID)
    if not roarID then
        return
    end

    if UnitInRaid("player") then
        SendAddonMessage(ADDON_PREFIX, roarID, "RAID")
    elseif UnitInParty("player") then
        SendAddonMessage(ADDON_PREFIX, roarID, "PARTY")
    elseif IsInGuild() then
        SendAddonMessage(ADDON_PREFIX, roarID, "GUILD")
    end
end

local function FindUnitBySender(sender)
    local normalizedSender = NormalizeName(sender)
    local i
    local unit
    local unitName

    if not normalizedSender then
        return nil
    end

    if normalizedSender == playerName then
        return "player"
    end

    if UnitExists("target") then
        unitName = NormalizeName(UnitName("target"))
        if unitName == normalizedSender then
            return "target"
        end
    end

    if UnitExists("mouseover") then
        unitName = NormalizeName(UnitName("mouseover"))
        if unitName == normalizedSender then
            return "mouseover"
        end
    end

    if UnitExists("focus") then
        unitName = NormalizeName(UnitName("focus"))
        if unitName == normalizedSender then
            return "focus"
        end
    end

    if UnitInRaid("player") then
        for i = 1, 40 do
            unit = "raid" .. i
            if UnitExists(unit) then
                unitName = NormalizeName(UnitName(unit))
                if unitName == normalizedSender then
                    return unit
                end
            end
        end
    elseif UnitInParty("player") then
        for i = 1, 4 do
            unit = "party" .. i
            if UnitExists(unit) then
                unitName = NormalizeName(UnitName(unit))
                if unitName == normalizedSender then
                    return unit
                end
            end
        end
    end

    return nil
end

local function IsSenderInRange(sender)
    local unit = FindUnitBySender(sender)

    if not unit then
        return false
    end

    if unit == "player" then
        return true
    end

    return UnitInRange(unit)
end

f:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        playerName = UnitName("player")
        UpdatePlayerRoar()

    elseif event == "UNIT_MODEL_CHANGED" then
        if arg1 == "player" then
            UpdatePlayerRoar()
        end

    elseif event == "CHAT_MSG_TEXT_EMOTE" then
        local text = arg1
        local sender = arg2

        if playerRoarSound and playerRoarID and IsMyRoar(text, sender) then
            PlaySoundFile(playerRoarSound)
            SendRoarToAddonUsers(playerRoarID)
        end

    elseif event == "CHAT_MSG_ADDON" then
        local prefix = arg1
        local message = arg2
        local channel = arg3
        local sender = arg4

        if prefix ~= ADDON_PREFIX then
            return
        end

        if NormalizeName(sender) == playerName then
            return
        end

        if not IsSenderInRange(sender) then
            return
        end

        PlayRoarByID(message)
    end
end)

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UNIT_MODEL_CHANGED")
f:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
f:RegisterEvent("CHAT_MSG_ADDON")
