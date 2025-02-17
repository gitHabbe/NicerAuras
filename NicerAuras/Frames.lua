local singleBuffTemplate = "NicerAuras_SingleBuffTemplate"
local singleDebuffTemplate = "NicerAuras_SingleDebuffTemplate"

local DispelTypeColor = {
    none = { r = 0.00, g = 0.00, b = 0.00 },
    Magic = { r = 0.20, g = 0.60, b = 1.00 },
    Curse = { r = 0.60, g = 0.00, b = 1.00 },
    Disease = { r = 0.60, g = 0.40, b = 0 },
    Poison = { r = 0.00, g = 0.60, b = 0 },
    Grey = { r = 0.8, g = 0.8, b = 0.8 },
    --customDebuff = NicerAuras.db.profile["neutralDebuffColor"],
    [""] = { r = 0.00, g = 0.00, b = 0.00 },
}

local function sortByDuration(frame1, frame2)
    if (frame1.caster ~= frame2.caster) then
        return frame1.caster == "player" or frame1.caster == true
    end
    return frame1.sortIndex < frame2.sortIndex
end

function NicerAuras:GetUnitFramesFamilyName()
    for addonName, _ in pairs(UnitFrames) do
        local loaded, finished = IsAddOnLoaded(addonName)
        if loaded then
            return addonName
        end
    end
    return "Blizzard"
end

function NicerAuras:HideBlizAurasFrames()
    for auraID = 1, MAX_TARGET_BUFFS do
        local blizzardBuff = _G["TargetFrameBuff" .. auraID]
        if (blizzardBuff) then blizzardBuff:Hide() end
        local blizzardDebuff = _G["TargetFrameDebuff" .. auraID]
        if (blizzardDebuff) then blizzardDebuff:Hide() end
    end
    TargetFrame_UpdateAuras = function () end
    TargetDebuffButton_Update = function () end
end

function NicerAuras:CreateMainFrame()
    self.auraFrame = {}
    local unitList = { "target", "focus" }
    for _, unit in ipairs(unitList) do
        local auraFrameParent = _G[self.unitFrameFamily[unit]]
        if self.db.profile.detached then
            auraFrameParent = UIParent
        end
        self.auraFrame[unit] = CreateFrame("Frame", "AuraFrame" .. unit, auraFrameParent, "AuraFrame_Template")
        self.auraFrame[unit]:ClearAllPoints()
        self.auraFrame[unit]:SetPoint("TOPLEFT", auraFrameParent, "BOTTOMLEFT", self.db.profile[unit .. "OffsetX"], self.db.profile[unit .. "OffsetY"])
        --DebugNicerAuras:Print("frame strata: " .. self.auraFrame[unit]:GetFrameStrata())
        --DebugNicerAuras:Print("frame level: " .. self.auraFrame[unit]:GetFrameLevel())
        --local auraFramePoint, auraFrameParent2, auraFrameRelativePoint, auraFrameOffsetX, auraFrameOffsetY = self.auraFrame[unit]:GetPoint()
        --DebugNicerAuras:Print(auraFrameParent2:GetName())
        self.auraFrame[unit].buffFrame = _G[self.auraFrame[unit]:GetName() .. "BuffFrame"]
        self.auraFrame[unit].debuffFrame = _G[self.auraFrame[unit]:GetName() .. "DebuffFrame"]
    end
    NicerAuras:UpdateAuras()
end

function NicerAuras:_CreateButtonFrame(self, auraType, auraID, unit)
    local frame, frameName;

    if (auraType == "Debuff") then -- Debuff
        local debuffFrameName = self.auraFrame[unit].debuffFrame:GetName();
        frameName = debuffFrameName .. auraType .. auraID;
        frame = CreateFrame("Button", frameName, self.auraFrame[unit].debuffFrame, singleDebuffTemplate)
        self.auraFrame[unit].debuffFrame["Aura" .. auraID] = frame;
    elseif (auraType == "Buff") then -- Buff
        local buffFrameName = self.auraFrame[unit].buffFrame:GetName();
        frameName = buffFrameName .. auraType .. auraID;
        frame = CreateFrame("Button", frameName, self.auraFrame[unit].buffFrame, singleBuffTemplate)
        self.auraFrame[unit].buffFrame["Aura" .. auraID] = frame;
        --DebugNicerAuras:Print("frame strata: " .. frame:GetFrameStrata())
        --DebugNicerAuras:Print("frame level: " .. frame:GetFrameLevel())
    end

    frame.icon      = _G[frameName .. "Icon"];
    frame.count     = _G[frameName .. "Count"];
    frame.cooldown  = _G[frameName .. "Cooldown"];
    frame.stealable = _G[frameName .. "Stealable"];
    frame.border    = _G[frameName .. "Border"];

    frame.unit      = unit
    frame:SetID(auraID)

    return frame
end

function NicerAuras:HideLeftoverFrames(auraType, count, unit)
    if (auraType == "Buff") then
        for auraID = count + 1, MAX_TARGET_BUFFS do
            local frameName = self.auraFrame[unit].buffFrame:GetName() .. "Buff" .. auraID
            local frame = _G[frameName]
            if (frame) then frame:Hide() end
        end
    elseif (auraType == "Debuff") then
        for auraID = count + 1, MAX_TARGET_DEBUFFS do
            local frameName = self.auraFrame[unit].debuffFrame:GetName() .. "Debuff" .. auraID
            local frame = _G[frameName]
            if (frame) then frame:Hide() end
        end
    end
end

function NicerAuras:_MakeMovableFrame(unit)
    if self.db.profile.freeMove then
        self:_CreateDraggableOverlay(unit)
        self.auraFrame[unit]:SetMovable(true)
    else
        if not self.auraFrame[unit].overlay then
            return
        end
        self.auraFrame[unit]:SetMovable(false)
        self.auraFrame[unit].overlay:SetMovable(false)
        self.auraFrame[unit].overlay:EnableMouse(false)
        self.auraFrame[unit].overlay:Hide()
        --self.auraFrame[unit]:SetFrameStrata(defaultStrataLevel)
        --self.auraFrame[unit]:SetFrameLevel(1)
        --DebugNicerAuras:Print(unit .. NicerAuras.db.profile[unit .. "freeX"])
        --local offsetX = NicerAuras.db.profile[unit .. "FreeX"]
        --local offsetY = NicerAuras.db.profile[unit .. "FreeY"]
        --DebugNicerAuras:Print("SETTING " .. unit .. " X to " .. offsetX .. ", Y to: " .. offsetY)
    end
end

function NicerAuras:_StyleDraggableOverlay(frame, overlay)
    local frameWidth, frameHeight = frame:GetSize()
    DebugNicerAuras:Print(frameWidth .. " x " .. frameHeight)
    frameHeight = math.max(40, frameHeight)
    overlay:ClearAllPoints()
    overlay:SetSize(frameWidth, frameHeight)
    overlay:SetPoint("CENTER")
    overlay:SetBackdrop( { bgFile="Interface\\ChatFrame\\ChatFrameBackground", tileSize=16, tile=true, edgeFile="Interface\\ChatFrame\\ChatFrameBackground", edgeSize=1 } )
    overlay:SetBackdropColor(0.1, 0.60, 0.60, 0.40)
    overlay:SetBackdropBorderColor(0, 0, 0, 0.60)
    overlay:SetFrameLevel(1000)
    overlay:Show()


    --local overlayBackup = CreateFrame("Button", frame:GetName() .. "Overlay", frame, BackdropTemplateMixin and "BackdropTemplate" or nil)
    --table_insert(snapBars, overlay)
    overlay:RegisterForDrag("LeftButton")
    --overlay:RegisterForClicks("LeftButtonUp")
    overlay.Text = overlay:CreateFontString(nil, "ARTWORK")
    overlay.Text:SetFontObject(GameFontNormal)
    --overlay.Text:SetText("DRAG ME")
    overlay.Text:Show()
    overlay.Text:ClearAllPoints()
    overlay.Text:SetPoint("CENTER", overlay, "CENTER")

end

function NicerAuras:_CreateDraggableOverlay(unit)
    local frame = self.auraFrame[unit]
    local frameName = frame:GetName() .. "Overlay"
    local overlay = _G[frameName]
    if not overlay then
        overlay = CreateFrame("Frame", frame:GetName() .. "Overlay", frame, "BackdropTemplate")
        DebugNicerAuras:Print("Creating overlay")
    end
    frame.overlay = overlay
    overlay.frame = frame

    self:_StyleDraggableOverlay(frame, overlay)

    overlay.Text:SetText("DRAG ME (" .. unit .. ")")
    overlay:EnableMouse(true)
    overlay:SetClampedToScreen(true)

    overlay:SetScript("OnDragStart", function(self)
        local parent = self:GetParent()
        parent:StartMoving()
    end)
    overlay:SetScript("OnDragStop", function(self)
        local parent = self:GetParent()
        DebugNicerAuras:Print(parent:GetName())
        parent:StopMovingOrSizing()

        local scale = parent:GetEffectiveScale()
        local xPos  = parent:GetLeft() * scale
        local yPos = parent:GetTop() * scale

        NicerAuras.db.profile[unit .. "FreeX"] = xPos
        NicerAuras.db.profile[unit .. "FreeY"] = yPos
    end)
end

function NicerAuras:UpdateMainFrame()
    local unitList = { "target", "focus" }
    for _, unit in ipairs(unitList) do
        local _, relativeTo = self.auraFrame[unit]:GetPoint()
        self.auraFrame[unit]:ClearAllPoints()

        local offsetX = 0
        local offsetY = 0
        if self.db.profile[unit .. "WantExtraOffsetY"] and unitHasTarget then
            offsetY = offsetY + self.db.profile[unit .. "ExtraOffsetY"]
        end

        local point = "TOPLEFT"
        local relativePoint = "BOTTOMLEFT"
        if self.db.profile[unit .. "GrowUpwards"] then
            point = "BOTTOMLEFT"
            relativePoint = "TOPLEFT"
        end
        if self.db.profile.detached then
            self:_MakeMovableFrame(unit)
            relativeTo = UIParent
            local scale = self.auraFrame[unit]:GetEffectiveScale()
            offsetX = self.db.profile[unit .. "FreeX"] / scale
            offsetY = self.db.profile[unit .. "FreeY"] / scale
        else
            --DebugNicerAuras:Print(unit .. ": " .. self.db.profile[unit .. "OffsetX"])
            relativeTo = _G[self.unitFrameFamily[unit]]
            offsetX = offsetX + self.db.profile[unit .. "OffsetX"] + self.unitFrameFamily.xOffset
            offsetY = offsetY + self.db.profile[unit .. "OffsetY"] + self.unitFrameFamily.yOffset
        end
        local parent = self.auraFrame[unit]:GetParent()
        if parent and parent:GetName() ~= relativeTo:GetName() then
            self.auraFrame[unit]:SetParent(relativeTo)
        end
        --DebugNicerAuras:Print(point .. " " .. relativePoint .. " " .. offsetX .. " x " .. offsetY)
        --DebugNicerAuras:Print("Parent is: " .. relativeTo:GetName())
        self.auraFrame[unit]:SetPoint(point, relativeTo, relativePoint, offsetX, offsetY)
    end
end

function NicerAuras:_SetCooldown(frame, expirationTime, duration)
    if self.isClassic then
        CooldownFrame_Set(frame, expirationTime - duration, duration, duration > 0, true)
    elseif self.isTBC then
        if expirationTime > 0 and duration > 0 then
            local startCooldownTime = GetTime() - (duration - expirationTime);
            CooldownFrame_SetTimer(frame, startCooldownTime, duration, 1);
        else
            frame:Hide()
        end
    elseif self.isWotlk then
        local startCooldownTime = GetTime() - (duration - expirationTime);
        CooldownFrame_SetTimer(frame, expirationTime - duration, duration, 1);
    end
end

function NicerAuras:_SetCountScale(frame)
    if self.isClassic then
        frame.count:SetTextScale(frame:GetSize() * 0.05)
    elseif self.isTBC or self.isWotlk then
        local oldFont, oldSize, oldMono, oldStrata = frame.count:GetFont()
        frame.count:SetFont(oldFont, frame:GetSize() * 0.5, oldMono, oldStrata)
    end
end

function NicerAuras:_CreateBuffFrames(unit)
    local frameTable = {}
    local buffCount = 0
    for auraID = 1, MAX_TARGET_BUFFS do
        local frame = self:_CreateAura("Buff", auraID, unit)
        if (frame == nil) then break end -- Might not need this?
        buffCount = buffCount + 1
        table.insert(frameTable, frame)
    end
    self:HideLeftoverFrames("Buff", buffCount, unit)

    if self.db.profile["durationSort"] then
        table.sort(frameTable, sortByDuration)
    end
    for i, _ in ipairs(frameTable) do
        if self.isClassic or self.isWotlk then
            self.largeAuraList[unit .. "Buff"][i] = frameTable[i].caster == "player"
        elseif self.isTBC  then
            self.largeAuraList[unit .. "Buff"][i] = frameTable[i].caster == true
        end
        self.auraFrame[unit].buffFrame["Aura" .. i] = frameTable[i]
    end
    return buffCount
end

function NicerAuras:_CreateDebuffFrames(unit)
    local frameTable = {}
    local debuffCount = 0
    for auraID = 1, MAX_TARGET_DEBUFFS do
        local frame = self:_CreateAura("Debuff", auraID, unit)
        if (frame == nil) then break end -- Might not need this?
        debuffCount = debuffCount + 1
        table.insert(frameTable, frame)
    end
    self:HideLeftoverFrames("Debuff", debuffCount, unit)

    if self.db.profile["durationSort"] then
        table.sort(frameTable, sortByDuration)
    end
    for i, _ in ipairs(frameTable) do
        if self.isClassic or self.isWotlk then
            self.largeAuraList[unit .. "Debuff"][i] = frameTable[i].caster == "player"
        elseif self.isTBC then
            self.largeAuraList[unit .. "Debuff"][i] = frameTable[i].caster == true
        end
        self.auraFrame[unit].debuffFrame["Aura" .. i] = frameTable[i]
    end
    return debuffCount
end

function NicerAuras:GetAuraTypeFrame(auraType, unit)
    if (auraType == "BUFF") then
        return self.auraFrame[unit].buffFrame
    elseif (auraType == "DEBUFF") then
        return self.auraFrame[unit].debuffFrame
    end
end

function NicerAuras:_CreateAura(auraType, auraID, unit)
    local auraName, rank, icon, count, dispelType, duration, expirationTime, caster
    local GetUnitAura, frameName
    if (auraType == "Buff") then
        frameName = self.auraFrame[unit].buffFrame:GetName() .. auraType .. auraID
        GetUnitAura = UnitBuff
    elseif (auraType == "Debuff") then
        frameName = self.auraFrame[unit].debuffFrame:GetName() .. auraType .. auraID
        GetUnitAura = UnitDebuff
    end
    if self.isClassic then
        auraName, icon, count, dispelType, duration, expirationTime, caster = GetUnitAura(unit, auraID)
    elseif self.isTBC then
        if auraType == "Buff" then
            auraName, rank, icon, count, duration, expirationTime, caster = GetUnitAura(unit, auraID)
        elseif auraType == "Debuff" then
            auraName, rank, icon, count, dispelType, duration, expirationTime, caster = GetUnitAura(unit, auraID)
        end
        if duration == nil then duration = 0 end
        if expirationTime == nil then expirationTime = 0 end
    elseif self.isWotlk then
        if auraType == "Buff" then
            auraName, rank, icon, count, dispelType, duration, expirationTime, caster = GetUnitAura(unit, auraID)
        elseif auraType == "Debuff" then
            auraName, rank, icon, count, dispelType, duration, expirationTime, caster = GetUnitAura(unit, auraID)
        end
    end
    if (self.db.profile["testMode"]) then
        if self.isClassic then
            auraName, icon, count, dispelType, duration, expirationTime, caster = DebugNicerAuras:MockAuraData(auraID, auraType)
        elseif self.isTBC then
            if auraType == "Buff" then
                auraName, rank, icon, count, duration, expirationTime, caster = DebugNicerAuras:MockAuraData(auraID, auraType)
            elseif auraType == "Debuff" then
                auraName, rank, icon, count, dispelType, duration, expirationTime, caster = DebugNicerAuras:MockAuraData(auraID, auraType)
            end
        elseif self.isWotlk then
            if auraType == "Buff" then
                auraName, rank, icon, count, dispelType, duration, expirationTime, caster = DebugNicerAuras:MockAuraData(auraID, auraType)
            elseif auraType == "Debuff" then
                auraName, rank, icon, count, dispelType, duration, expirationTime, caster = DebugNicerAuras:MockAuraData(auraID, auraType)
            end
        end
    end
    if (not icon) then return nil end
    local frame = _G[frameName]
    if (not frame) then
        frame = self:_CreateButtonFrame(self, auraType, auraID, unit)
    end
    --DebugNicerAuras:Print("rank: " .. rank)
    --DebugNicerAuras:Print("dispelType: " .. dispelType)
    --DebugNicerAuras:Print("auraName: " .. auraName)
    --DebugNicerAuras:Print("icon: " .. icon)
    --DebugNicerAuras:Print("count: " .. count)
    --DebugNicerAuras:Print("duration: " .. duration)
    --DebugNicerAuras:Print("expirationTime: " .. expirationTime)
    --DebugNicerAuras:Print("caster: " .. caster)
    local sortIndex = (GetTime() - expirationTime) * -1
    if self.isTBC or self.isWotlk then
        sortIndex = expirationTime
    end
    if (sortIndex > 0) then frame.sortIndex = sortIndex else frame.sortIndex = 100000 end

    frame.auraName = auraName
    frame.caster = caster or "target"

    frame.type = auraType
    frame.icon:SetTexture(icon)
    frame.icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)

    NicerAuras:_SetCooldown(frame.cooldown, expirationTime, duration)
    --frame.cooldown:SetSwipeTexture(frame.icon) -- Thank you twitch.tv/tomcat
    local colors
    if auraType == "Buff" then
        colors = DispelTypeColor[dispelType] or NicerAuras.db.profile.neutralBuffColor
    else
        colors = DispelTypeColor[dispelType] or NicerAuras.db.profile.neutralDebuffColor
    end
    frame.border:SetVertexColor(colors.r, colors.g, colors.b)

    if (count and count > 1 and frame.count) then
        frame.count:SetText(count)
        frame.count:SetDrawLayer("OVERLAY", -7)
        NicerAuras:_SetCountScale(frame)
        frame.count:Show()
    else
        frame.count:Hide()
    end

    frame:SetScript("OnMouseDown", OnAuraClick)

    return frame
end

function NicerAuras:_LoopAuraFrame(auraType, auraCount, unit)
    local yOffset, totalFrameHeight, rowLargestIconSize, rowWidth = 0, 0, 0, 0

    local auraTypeFrame = self:GetAuraTypeFrame(auraType, unit)

    for auraID = 1, auraCount do
        local maxRowWidth = self.db.profile[unit .. "RowWidth"]
        local iconSize = self:GetAuraSizeSetting(auraType, auraID, unit)
        if (auraID == 1) then
            rowWidth = iconSize
            rowLargestIconSize = iconSize
        else
            rowWidth = rowWidth + iconSize + self.db.profile[unit .. "PaddingX"]
        end

        local isShortRow = self.rowCount[unit] <= self.db.profile[unit .. "ShortRowCount"]
        if (isShortRow and unitHasTarget) then
            maxRowWidth = self.db.profile[unit .. "ShortRowWidth"]
        end
        --DebugNicerAuras:Print(rowWidth)
        --DebugNicerAuras:Print(maxRowWidth)
        local isNewRow = rowWidth > maxRowWidth
        if (isNewRow) then
            self.rowCount[unit] = self.rowCount[unit] + 1
            yOffset = yOffset + rowLargestIconSize + self.db.profile[unit .. "PaddingY"]
            rowWidth = iconSize
            rowLargestIconSize = 0

            self:_PositionAuraFrame(auraTypeFrame, auraID, auraID, iconSize, yOffset)
            -- if the last icon creates a new row, we add his size to the newRowYOffset to get the overall height of the auraFrame.
            if (auraID == auraCount) then
                totalFrameHeight = yOffset + iconSize;
            end
        else
            --Debug:Print(auraType .. " id: " .. auraID .. " yOffset: " ..  yOffset, "Offset")
            self:_PositionAuraFrame(auraTypeFrame, auraID, auraID - 1, iconSize, yOffset);
            -- The last Icon creates no new row, so we add the largestIconSize to newRowYOffset to get the total height.
            if (auraID == auraCount) then
                totalFrameHeight = yOffset + rowLargestIconSize;
            end
        end

        -- Check if the icon is larger than the current largest icon.
        if (rowLargestIconSize < iconSize) then
            rowLargestIconSize = iconSize;
        end
    end

    local buffRowNeedsRows = auraType == "DEBUFF" and (self.rowCount[unit] == 1 or self.rowCount[unit] == 2) and rowWidth > 0
    if buffRowNeedsRows then
        self.rowCount[unit] = self.rowCount[unit] + 1
    end

    return totalFrameHeight;
end

function NicerAuras:_PositionAuraFrame(auraFrame, auraID, relativeIndex, size, yOffset)
    local frame = auraFrame["Aura" .. auraID]
    if (not frame) then
        return
    end

    -- Set point and relative point according to the grow upwards setting.
    local point, relativePoint
    if (self.db.profile[frame.unit .. "GrowUpwards"]) then
        point = "BOTTOM"
        relativePoint = "BOTTOM"
    else
        point = "TOP"
        relativePoint = "TOP"
        -- Because we grow downwards, yOffset must be a negative value.
        yOffset = -yOffset
    end
    point = point .. "LEFT"
    relativePoint = relativePoint .. "RIGHT"

    local relativeTo;
    local xOffset = self.db.profile[frame.unit .. "PaddingX"]
    if (auraID == 1) then
        --DebugNicerAuras:Print("AuraID: " .. auraID .. " is first row")
        relativePoint = point;
        xOffset = 0;
        yOffset = 0;
        relativeTo = frame:GetParent();

    elseif (relativeIndex ~= auraID - 1) then
        --[[ If the relativeIndex isn't the icon before, this means that a new row begins. Set relativePoint = point,
             because otherwise the icon would be attached to the wrong side of the auraType frame.
             Also reset the xOffset, since we're at the beginning of a row. ]]--
        relativePoint = point;
        relativeTo = frame:GetParent();
        xOffset = 0;
        --xOffset = self.db.profile["positionX"];
    else
        -- Set the relative Frame (the preceding buff) and reset yOffset, because positioning is relative to the preceding frame.
        relativeTo = auraFrame["Aura" .. relativeIndex];
        yOffset = 0;
    end

    -- Set up the frame. The Aura is finally done!
    frame:SetWidth(size);
    frame:SetHeight(size);

    if (frame.stealable) then
        frame.stealable:SetWidth(size + 5, size + 5);
        --frame.stealable:SetHeight(size + 5, size + 5);
    end

    -- Now set the new anchor and show the icon.
    frame:ClearAllPoints();
    frame:SetPoint(point, relativeTo, relativePoint, xOffset, yOffset);
    frame:Show();
end

function NicerAuras:UpdateAuras()
    --targetHasTarget = UnitExists("targettarget")
    --TargetIsSelf = UnitExists("target") and UnitName("target") == UnitName("targettarget")
    self:UpdateMainFrame()
    self.largeAuraList = {}
    self.rowCount = {}

    --local unitList = { "target" }
    local unitList = { "target", "focus" }
    for _, unit in ipairs(unitList) do
        unitHasTarget = UnitExists(unit .. "target")
        unitIsTarget = UnitExists(unit) and UnitName(unit) == UnitName(unit .. "target")
        self.largeAuraList[unit .. "Buff"] = {}
        self.largeAuraList[unit .. "Debuff"] = {}
        self.rowCount[unit] = 1
        local buffCount = self:_CreateBuffFrames(unit)
        local debuffCount = self:_CreateDebuffFrames(unit)
        local debuffFrameheight = NicerAuras:_LoopAuraFrame("DEBUFF", debuffCount, unit)
        local buffFrameheight = NicerAuras:_LoopAuraFrame("BUFF", buffCount, unit)
        --DebugNicerAuras:Print(unit)
        NicerAuras:_PositionBuffAndDebuffFrames(buffCount, debuffCount, buffFrameheight, debuffFrameheight, unit)
    end
end

function NicerAuras:_PositionBuffAndDebuffFrames(buffCount, debuffCount, buffFrameheight, debuffFrameheight, unit)
    local point, relativeTo, relativePoint
    --DebugNicerAuras:Print(self.unitFrameFamily.yOffset)
    local yOffset = 0
    if (self.db.profile[unit .. "GrowUpwards"]) then
        point = "BOTTOMLEFT";
        relativePoint = "TOPLEFT"
    else
        point = "TOPLEFT";
        relativePoint = "BOTTOMLEFT";
    end

    if (buffCount == 0) then
        buffFrameheight = 1
    end

    if (debuffCount == 0) then
        debuffFrameheight = 1
    end

    self.auraFrame[unit].debuffFrame:ClearAllPoints();
    self.auraFrame[unit].buffFrame:ClearAllPoints();

    self.auraFrame[unit].debuffFrame:SetPoint(point, self.auraFrame[unit], point, 0, 0);
    if debuffCount == 0 then
        self.auraFrame[unit].buffFrame:SetPoint(point, self.auraFrame[unit].debuffFrame, relativePoint, 0, yOffset);
    else
        self.auraFrame[unit].buffFrame:SetPoint(point, self.auraFrame[unit].debuffFrame, relativePoint, 0, yOffset - 3);
    end

    local totalHeight = buffFrameheight + debuffFrameheight + tonumber(self.db.profile[unit .. "PaddingY"])

    if (totalHeight == 0) then
        totalHeight = 1;
    end

    local width = self.auraFrame[unit]:GetWidth();
    self.auraFrame[unit].buffFrame:SetWidth(width);
    self.auraFrame[unit].buffFrame:SetHeight(buffFrameheight);
    self.auraFrame[unit].debuffFrame:SetWidth(width);
    self.auraFrame[unit].debuffFrame:SetHeight(debuffFrameheight);
    self.auraFrame[unit]:SetWidth(width, totalHeight);
    self.auraFrame[unit]:SetHeight(totalHeight);
end

