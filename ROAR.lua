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
    ScourgeMale = "Sound\\Character\\PlayerRoars\\CharacterRoarsUndeadMale.wav",
    ScourgeFemale = "Sound\\Character\\PlayerRoars\\CharacterRoarsUndeadFemale.wav",
}

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

    if raceFile then
        return raceFile .. sexText
    end

    return nil
end

local function UpdatePlayerRoar()
    playerRoarID = GetPlayerRoarID()

    if playerRoarID and roarSounds[playerRoarID] then
        playerRoarSound = roarSounds[playerRoarID]
    else
        playerRoarSound = nil
    end
end

local function IsMyRoar(text, sender)
    if sender ~= playerName then
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

f:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        playerName = UnitName("player")
        UpdatePlayerRoar()
        RegisterAddonMessagePrefix(ADDON_PREFIX)

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

        if sender == playerName then
            return
        end

        PlayRoarByID(message)
    end
end)

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UNIT_MODEL_CHANGED")
f:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
f:RegisterEvent("CHAT_MSG_ADDON")
