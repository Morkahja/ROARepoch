local f = CreateFrame("Frame")

local playerName
local playerRoarID
local playerRoarSound

local ROAR_COOLDOWN = 0.3

local lastRoarTimeBySender = {}

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

local function GetRoarIDForUnit(unit)
    if not UnitExists(unit) then
        return nil
    end

    local _, raceFile = UnitRace(unit)
    local sex = UnitSex(unit)
    local sexText

    if raceFile == "Scourge" then
        raceFile = "Undead"
    end

    if sex == 2 then
        sexText = "Male"
    elseif sex == 3 then
        sexText = "Female"
    else
        return nil
    end

    if not raceFile then
        return nil
    end

    return raceFile .. sexText
end

local function UpdatePlayerRoar()
    playerRoarID = GetRoarIDForUnit("player")

    if playerRoarID then
        playerRoarSound = roarSounds[playerRoarID]
    else
        playerRoarSound = nil
    end
end

local function IsRoarText(text)
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

local function PlayRoarByID(roarID)
    local soundPath = roarSounds[roarID]

    if soundPath then
        PlaySoundFile(soundPath)
    end
end

local function CanPlayRoarForSender(senderName)
    local now = GetTime()
    local lastTime = lastRoarTimeBySender[senderName]

    if lastTime and (now - lastTime) < ROAR_COOLDOWN then
        return false
    end

    lastRoarTimeBySender[senderName] = now
    return true
end

f:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        playerName = NormalizeName(UnitName("player"))
        UpdatePlayerRoar()

    elseif event == "UNIT_MODEL_CHANGED" then
        if arg1 == "player" then
            UpdatePlayerRoar()
        end

    elseif event == "CHAT_MSG_TEXT_EMOTE" then
        local text = arg1
        local sender = arg2
        local senderName = NormalizeName(sender)
        local unit
        local roarID

        if not IsRoarText(text) then
            return
        end

        if not senderName then
            return
        end

        if not CanPlayRoarForSender(senderName) then
            return
        end

        if senderName == playerName then
            if playerRoarSound then
                PlaySoundFile(playerRoarSound)
            end
            return
        end

        unit = FindUnitBySender(sender)
        if not unit then
            return
        end

        roarID = GetRoarIDForUnit(unit)
        if roarID then
            PlayRoarByID(roarID)
        end
    end
end)

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UNIT_MODEL_CHANGED")
f:RegisterEvent("CHAT_MSG_TEXT_EMOTE")