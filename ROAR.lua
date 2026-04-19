local f = CreateFrame("Frame")

local playerName
local playerRoarSound

local roarSounds = {
    Dwarf = {
        [2] = "Sound\\Character\\PlayerRoars\\CharacterRoarsDwarfMale.wav",
        [3] = "Sound\\Character\\PlayerRoars\\CharacterRoarsDwarfFemale.wav",
    },
    Gnome = {
        [2] = "Sound\\Character\\PlayerRoars\\CharacterRoarsGnomeMale.wav",
        [3] = "Sound\\Character\\PlayerRoars\\CharacterRoarsGnomeFemale.wav",
    },
    Human = {
        [2] = "Sound\\Character\\PlayerRoars\\CharacterRoarsHumanMale.wav",
        [3] = "Sound\\Character\\PlayerRoars\\CharacterRoarsHumanFemale.wav",
    },
    NightElf = {
        [2] = "Sound\\Character\\PlayerRoars\\CharacterRoarsNightElfMale.wav",
        [3] = "Sound\\Character\\PlayerRoars\\CharacterRoarsNightElfFemale.wav",
    },
    Orc = {
        [2] = "Sound\\Character\\PlayerRoars\\CharacterRoarsOrcMale.wav",
        [3] = "Sound\\Character\\PlayerRoars\\CharacterRoarsOrcFemale.wav",
    },
    Tauren = {
        [2] = "Sound\\Character\\PlayerRoars\\CharacterRoarsTaurenMale.wav",
        [3] = "Sound\\Character\\PlayerRoars\\CharacterRoarsTaurenFemale.wav",
    },
    Troll = {
        [2] = "Sound\\Character\\PlayerRoars\\CharacterRoarsTrollMale.wav",
        [3] = "Sound\\Character\\PlayerRoars\\CharacterRoarsTrollFemale.wav",
    },
    Scourge = {
        [2] = "Sound\\Character\\PlayerRoars\\CharacterRoarsUndeadMale.wav",
        [3] = "Sound\\Character\\PlayerRoars\\CharacterRoarsUndeadFemale.wav",
    },
    Undead = {
        [2] = "Sound\\Character\\PlayerRoars\\CharacterRoarsUndeadMale.wav",
        [3] = "Sound\\Character\\PlayerRoars\\CharacterRoarsUndeadFemale.wav",
    },
}

local function UpdatePlayerRoarSound()
    local _, raceFile = UnitRace("player")
    local sex = UnitSex("player")

    if roarSounds[raceFile] and roarSounds[raceFile][sex] then
        playerRoarSound = roarSounds[raceFile][sex]
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

f:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        playerName = UnitName("player")
        UpdatePlayerRoarSound()
    elseif event == "UNIT_MODEL_CHANGED" then
        if arg1 == "player" then
            UpdatePlayerRoarSound()
        end
    elseif event == "CHAT_MSG_TEXT_EMOTE" then
        local text = arg1
        local sender = arg2

        if playerRoarSound and IsMyRoar(text, sender) then
            PlaySoundFile(playerRoarSound)
        end
    end
end)

f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("UNIT_MODEL_CHANGED")
f:RegisterEvent("CHAT_MSG_TEXT_EMOTE")
