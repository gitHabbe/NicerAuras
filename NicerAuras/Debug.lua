function colorize(text, color)
    return color .. text .. "|r"
end

DebugNicerAuras = {}

function DebugNicerAuras:Print(msg, header)
    if msg == nil then msg = "nil" end
    if NicerAuras.db.profile["debugMode"] then
        if header then
            print(
                colorize("NicerAuras", NORMAL_FONT_COLOR_CODE) ..
                colorize(" (" .. header .. ")", GRAY_FONT_COLOR_CODE) ..
                " - " .. msg
            )
        else
            print(colorize("NicerAuras", NORMAL_FONT_COLOR_CODE) .. " - " .. msg)
        end
    end
end

function DebugNicerAuras:MockAuraData(auraID, auraType)
    local auraName = "Death Coil"
    local stackCount = 3
    local duration = math.random(30, 60)
    local caster = "target"
    local dispelTypes = { "Magic", "Curse", "Poison", "Disease", nil }
    local dispelType = dispelTypes[math.random(1, #dispelTypes)]
    local playerCount = NicerAuras.db.profile["testPlayerCount"]
    local icon, expirationTime
    if NicerAuras.isClassic then
        expirationTime = duration + GetTime()
        if auraID <= playerCount then caster = "player" end
        if auraType == "Buff" then
            icon = 135953
        elseif auraType == "Debuff" then
            icon = 136139
        end
        return auraName, icon, stackCount, dispelType, duration, expirationTime, caster
    elseif NicerAuras.isTBC then
        expirationTime = math.random(20, duration)
        if auraID <= playerCount then caster = true end
        if auraType == "Buff" then
            icon = "Interface\\Icons\\spell_holy_renew"
            return auraName, "Rank 1", icon, stackCount, duration, expirationTime, caster
        elseif auraType == "Debuff" then
            icon = "Interface\\Icons\\spell_shadow_curseofsargeras"
            return auraName, "Rank 1", icon, stackCount, dispelType, duration, expirationTime, caster
        end
    elseif NicerAuras.isWotlk then
        if auraID <= playerCount then caster = true end
        if auraType == "Buff" then
            icon = "Interface\\Icons\\spell_holy_renew"
            return auraName, "Rank 1", icon, stackCount, dispelType, duration, expirationTime, caster
        elseif auraType == "Debuff" then
            icon = "Interface\\Icons\\spell_shadow_curseofsargeras"
            return auraName, "Rank 1", icon, stackCount, dispelType, duration, expirationTime, caster
        end
    end
end

