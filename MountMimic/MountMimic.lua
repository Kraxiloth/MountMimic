-- MountMimic
-- Detects the mount your target is riding and notifies you if you own it.

local addonName, MM = ...

-- Build a lookup table of mounts the player owns, keyed by spell ID
local ownedMountsBySpell = {}
local lastMatchedMountID = nil

local function BuildMountCache()
    local mountIDs = C_MountJournal.GetMountIDs()
    for _, mountID in ipairs(mountIDs) do
        local name, spellID, _, _, isUsable, _, _, _, _, hideOnChar, _, isCollected =
            C_MountJournal.GetMountInfoByID(mountID)
        if isCollected and not hideOnChar and spellID then
            ownedMountsBySpell[spellID] = { name = name, mountID = mountID, isUsable = isUsable }
        end
    end
end

-- Scan the target's auras to find a mount spell
local function GetTargetMountSpellID()
    local i = 1
    while true do
        local auraData = C_UnitAuras.GetAuraDataByIndex("target", i, "HELPFUL")
        if not auraData then break end
        if ownedMountsBySpell[auraData.spellId] then
            return auraData.spellId
        end
        i = i + 1
    end
    return nil
end

-- Handle target change events
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("PLAYER_LOGIN")

frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        BuildMountCache()
        return
    end

    local pvpType = GetZonePVPInfo()
    if pvpType ~= "sanctuary" then
        return
    end

    if UnitIsUnit("target", "player") or not UnitExists("target") then
        return
    end

    if not UnitIsPlayer("target") then
        return
    end

    local spellID = GetTargetMountSpellID()
    if spellID then
        local mount = ownedMountsBySpell[spellID]
        if mount then
            lastMatchedMountID = mount.mountID
            print("|cff00ff00[MountMimic]|r Your target is riding |cffffd700"
                .. mount.name .. "|r and you own it!")
        else
            lastMatchedMountID = nil
            print("|cff00ff00[MountMimic]|r Your target is riding a mount you don't own.")
        end
    else
        lastMatchedMountID = nil
    end
end)

-- Slash command handler
SLASH_MOUNTMIMIC1 = "/mountmimic"
SlashCmdList["MOUNTMIMIC"] = function(msg)
    if msg == "mount" then
        if not lastMatchedMountID then
            print("|cff00ff00[MountMimic]|r No matching mount found for your current target.")
            return
        end
        C_MountJournal.SummonByID(lastMatchedMountID)
    end
end