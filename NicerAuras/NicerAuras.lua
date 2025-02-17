UnitFrames = {
    Blizzard = {
        target = "TargetFrame",
        focus = "FocusFrame",
        yOffset = 34,
        xOffset = 4,
    },
    NicerFrames = {
        target = "TargetFrameCustom",
        focus = "FocusFrame",
        yOffset = 6,
        xOffset = 1,
    },
    ShadowedUnitFrames = {
        target = "SUFUnittarget",
        focus = "SUFUnitfocus",
        yOffset = 0,
        xOffset = 0,
    },
    PitBull4 = {
        target = "PitBull4_Frames_Target",
        focus = "PitBull4_Frames_Focus",
        yOffset = 0,
        xOffset = 0,
    },
    ElvUI = {
        target = "ElvUF_Target",
        focus = "ElvUF_Focus",
        yOffset = 0,
        xOffset = 0,
    }
}

NicerAuras = LibStub("AceAddon-3.0"):NewAddon("NicerAuras", "AceEvent-3.0", "AceConsole-3.0")

NicerAuras.buildInfo = select(2, GetBuildInfo())
NicerAuras.build = tonumber(NicerAuras.buildInfo)
NicerAuras.isClassic = NicerAuras.build > 40000
NicerAuras.isTBC = NicerAuras.build > 5000 and NicerAuras.build < 10000
NicerAuras.isWotlk = NicerAuras.build > 9000 and NicerAuras.build < 13000

function NicerAuras:OnEnable()
    self:DatabaseInitialize()
    self:LoadConfig()
    self:CreateSlashCommands()
    self:HideBlizAurasFrames()
    NicerAuras:RegisterEvent("PLAYER_TARGET_CHANGED")
    NicerAuras:RegisterEvent("PLAYER_FOCUS_CHANGED")
    NicerAuras:RegisterEvent("UNIT_AURA")
    NicerAuras:RegisterEvent("UNIT_TARGET")
    local unitFrameFamilyName = NicerAuras:GetUnitFramesFamilyName()
    self.unitFrameFamily = UnitFrames[unitFrameFamilyName]
    self:CreateMainFrame()
end

function NicerAuras:PLAYER_TARGET_CHANGED()
    NicerAuras:UpdateAuras()
end

function NicerAuras:PLAYER_FOCUS_CHANGED()
    NicerAuras:UpdateAuras()
end

function NicerAuras:UNIT_TARGET(_, unit)
    if unit == "target" or unit == "focus" then
        NicerAuras:UpdateAuras()
    end
end

function NicerAuras:UNIT_AURA(_, unit)
    if unit == "target" or unit == "focus" then
        NicerAuras:UpdateAuras()
    end
end

function OnAuraClick(self, buttonName)
    if not (buttonName == "LeftButton" and IsAltKeyDown()) then return end
    NicerAuras:UpdateAuras(NicerAuras)
    local targetChannel
    if self.isClassic then
        if UnitInBattleground("player") then
            targetChannel = "INSTANCE_CHAT"
        elseif UnitInRaid("player") then
            targetChannel = "RAID"
        elseif UnitInParty("player") then
            local isInstanceGroup = IsInGroup(LE_PARTY_CATEGORY_INSTANCE)
            if isInstanceGroup then
                targetChannel = "INSTANCE_CHAT"
            else
                targetChannel = "PARTY"
            end
        else
            if IsInInstance() then
                targetChannel = "SAY"
            end
        end
    elseif self.isTBC or self.isWotlk then
        if UnitInBattleground("player") then
             targetChannel = "CHAT_MSG_BATTLEGROUND"
        elseif UnitInRaid("player") then
            targetChannel = "RAID"
        elseif UnitInParty("player") > 1 then
            targetChannel = "PARTY"
        end
    end

    local targetType = "Enemy "
    local isFriendly = UnitIsFriend("player", "target")
    if isFriendly then targetType = "Mate " end

    local class = UnitClass("target") or ""
    local casterName = UnitName("target")

    local chatMessage = targetType .. casterName .. " [" .. class .. "] "
    if self.sortIndex > 50000 then
        chatMessage = chatMessage .. "affected by " .. self.type .. ": " .. self.auraName
    elseif self.sortIndex > 60 then
        chatMessage = chatMessage .. self.type .. ": " .. self.auraName .. ", " .. math.ceil(self.sortIndex / 60) .. " min left"
    elseif self.sortIndex > 10 then
        chatMessage = chatMessage .. self.type .. ": " .. self.auraName .. ", " .. math.ceil(self.sortIndex) .. " sec left"
    elseif self.sortIndex < 10 then
        chatMessage = chatMessage .. self.type .. ": " .. self.auraName .. ", " .. string.format("%.1f", self.sortIndex) .. " sec left"
    end
    if targetChannel ~= nil then
        SendChatMessage(chatMessage, targetChannel);
    else
        print(chatMessage)
    end
end

