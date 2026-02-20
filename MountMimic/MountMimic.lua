-- MountMimic
-- Detects the mount your target is riding and notifies you if you own it.

local addonName, MM = ...

-- Build a lookup table of mounts the player owns, keyed by spell ID
local ownedMountsBySpell = {}

local function BuildMountCache()
    local mountIDs = C_MountJournal.GetMountIDs()
    for _, mountID in ipairs(mountIDs) do
        local name, spellID, _, _, isUsable, _, isFavorite, _, _, _, creatureDisplayID, isCollected =
            C_MountJournal.GetMountInfoByID(mountID)
        if isCollected and spellID then
            ownedMountsBySpell[spellID] = { name = name, mountID = mountID, isUsable = isUsable }
        end
    end
end