local frame = CreateFrame("Frame");
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEAVING_WORLD")
frame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
frame:RegisterEvent("ADDON_LOADED")

local function ignorePlayers()
    if not IgnoredPlayers then
        IgnoredPlayers = {}
    end
    local allLoaded = false
    while not allLoaded do
        allLoaded = true
        for i = 1, GetNumBattlefieldScores() do
            local name = GetBattlefieldScore(i)
            if name and name ~= UnitName("player") and not IgnoredPlayers[name] then
                IgnoredPlayers[name] = true
                local success = C_FriendList.AddIgnore(name)
                if not success then
                    allLoaded = false
                    break
                end
            end
        end
        if not allLoaded and table.getn(IgnoredPlayers) < 5 then
            -- Wait for 1 second before trying again
            C_Timer.After(1, ignorePlayers)
        end
    end
end



local function unignorePlayers()
    for name in pairs(IgnoredPlayers) do
        C_FriendList.DelIgnore(name)
        IgnoredPlayers[name] = nil
    end
end

frame:SetScript("OnEvent", function(self, event, ...)
    if ((event == "PLAYER_ENTERING_WORLD" and C_PvP.IsRatedSoloShuffle() and table.getn(IgnoredPlayers) < 5) or (event == "PLAYER_LEAVING_WORLD" and C_PvP.IsRatedSoloShuffle() and table.getn(IgnoredPlayers) < 5) or (event == "UPDATE_BATTLEFIELD_STATUS" and C_PvP.IsRatedSoloShuffle() and table.getn(IgnoredPlayers) < 5) or (event == "ADDON_LOADED" and C_PvP.IsRatedSoloShuffle() and table.getn(IgnoredPlayers) < 5)) then
        ignorePlayers()
    elseif event == "PLAYER_ENTERING_WORLD" and next(IgnoredPlayers) ~= nil then
        unignorePlayers()
    elseif event == "PLAYER_LEAVING_WORLD" and next(IgnoredPlayers) ~= nil then
        unignorePlayers()
    elseif not IgnoredPlayers then
        IgnoredPlayers = {}
    end
end)