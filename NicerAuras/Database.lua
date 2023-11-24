function NicerAuras:DatabaseInitialize()
    self.defaults = {}
    self.defaults.profile = {}
    for k, v in pairs(NicerAurasDefaults) do
        self.defaults.profile[k] = v
    end
    NicerAuras:_CreateDB()
    --self.db = self.dbi.profile
    self.db = self.dbi
end

function NicerAuras:_CreateDB()
    if self.isClassic then
        self.dbi = LibStub("AceDB-3.0"):New("NicerAuras_DB", self.defaults, true)
    elseif self.isTBC or self.isWotlk then
        self.dbi = LibStub("AceDB-3.0"):New("NicerAuras_DB", self.defaults, "default")
    end
end

function NicerAuras:GetAuraSizeSetting(auraType, auraID, unit)
    local isPlayerBuff = auraType == "BUFF" and self.largeAuraList[unit .. "Buff"][auraID]
    local isPlayerDebuff = auraType == "DEBUFF" and self.largeAuraList[unit .. "Debuff"][auraID]
    if (isPlayerBuff or isPlayerDebuff) then
        return self.db.profile[unit .. "PlayerSize"]
    else
        return self.db.profile[unit .. "OtherSize"]
    end
end
