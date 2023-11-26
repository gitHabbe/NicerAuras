local function option(params)
    local options = {
        get = function(info)
            local key = info.arg or info[#info]
            return NicerAuras.db.profile[key]
        end,
        set = function(info, value)
            local key = info.arg or info[#info]
            NicerAuras.dbi.profile[key] = value
            NicerAuras:UpdateMainFrame()
            NicerAuras:UpdateAuras() -- Keep this // Hab
        end,
    }

    for k, v in pairs(params) do
        options[k] = v
    end

    return options
end

local function getColorOpt(info)
    local key = info.arg or info[#info]
    return NicerAuras.dbi.profile[key].r, NicerAuras.dbi.profile[key].g, NicerAuras.dbi.profile[key].b, NicerAuras.dbi.profile[key].a
end

local function setColorOpt(info, r, g, b, a)
    local key = info.arg or info[#info]
    NicerAuras.dbi.profile[key].r, NicerAuras.dbi.profile[key].g, NicerAuras.dbi.profile[key].b, NicerAuras.dbi.profile[key].a = r, g, b, a
    NicerAuras:UpdateMainFrame()
end

NicerAurasDefaults = {
    neutralBuffColor = { r = 0, g = 0, b = 0, a = 0 },
    neutralDebuffColor = { r = 0, g = 0, b = 0, a = 0 },
    durationSort = false,
    detached = false,

    targetRowWidth = 200,
    targetPlayerSize = 42,
    targetOtherSize = 32,
    targetOffsetX = 0,
    targetOffsetY = 0,
    targetGrowUpwards = false,
    targetWantExtraOffsetY = false,
    targetExtraOffsetY = 0,
    targetPaddingX = 2,
    targetPaddingY = 2,
    targetShortRowCount = 2,
    targetShortRowWidth = 80,
    targetFreeX = 0,
    targetFreeY = 0,

    focusRowWidth = 200,
    focusPlayerSize = 42,
    focusOtherSize = 32,
    focusOffsetX = 0,
    focusOffsetY = 0,
    focusGrowUpwards = false,
    focusWantExtraOffsetY = false,
    focusExtraOffsetY = 0,
    focusPaddingX = 2,
    focusPaddingY = 2,
    focusShortRowCount = 2,
    focusShortRowWidth = 80,
    focusFreeX = 0,
    focusFreeY = 0,

    lighterBuffs = false,
    shortRowCount = 2,
    shortRowWidth = 80,

    debugMode = false,
    testMode = false,
    testPlayerCount = 3,
}

NicerAurasAceConfig = {
    type = "group",
    width = "half",
    args = {
        generalGroup = {
            type = "group",
            name = "General",
            order = 10,
            args = {
                colorNeutralBordersHeader = {
                    type = "header",
                    name = "Color neutral buff & debuff borders",
                    order = 10,
                },
                neutralBuffColor = {
                    name = "Buff",
                    type = "color",
                    order = 20,
                    hasAlpha = true,
                    get = getColorOpt,
                    set = setColorOpt,
                },
                neutralDebuffColor = {
                    name = "Debuff",
                    type = "color",
                    order = 30,
                    hasAlpha = true,
                    get = getColorOpt,
                    set = setColorOpt,
                },
                sortingHeader = {
                    type = "header",
                    name = "Sorting",
                    order = 40,
                },
                durationSort = option({
                    type = "toggle",
                    name = "Sort by duration",
                    order = 50,
                }),
                positionHeader = {
                    type = "header",
                    name = "Attach to frame or move freely",
                    order = 60
                },
                detached = option({
                    type = "toggle",
                    name = "Detach auras from frames",
                    order = 70,
                }),
                freeMove = option({
                    type = "toggle",
                    name = "Free move frame",
                    order = 80,
                    disabled = function() return not NicerAuras.db.profile.detached end
                }),
            }
        },
        targetGroup = {
            type = "group",
            name = "Target",
            order = 20,
            args = {
                targetSizeHeader = {
                    type = "header",
                    name = "Size",
                    order = 1,
                },
                targetPlayerSize = option({
                    type = "range",
                    name = "My aura size",
                    step = 1,
                    order = 10,
                    min = 8,
                    max = 100
                }),
                targetOtherSize = option({
                    type = "range",
                    name = "Others aura size",
                    step = 1,
                    order = 20,
                    min = 8,
                    max = 100
                }),
                targetRowWidth = option({
                    type = "range",
                    name = "Width",
                    step = 1,
                    order = 30,
                    min = 70,
                    max = 400,
                }),
                targetPositionHeader = {
                    type = "header",
                    name = "Position",
                    order = 39,
                },
                targetOffsetX = option({
                    type = "range",
                    name = "X offset",
                    step = 1,
                    order = 40,
                    min = -200,
                    max = 200,
                }),
                targetOffsetY = option({
                    type = "range",
                    name = "Y offset",
                    order = 50,
                    step = 1,
                    min = -200,
                    max = 200,
                }),
                targetPaddingX = option({
                    type = "range",
                    name = "Aura X padding",
                    order = 55,
                    min = 0,
                    max = 5,
                }),
                targetPaddingY = option({
                    type = "range",
                    name = "Aura Y padding",
                    order = 56,
                    min = 0,
                    max = 5,
                }),
                targetGrowUpwards = option({
                    name = "Auras on top",
                    type = "toggle",
                    order = 60,
                }),
                targetExtraPositionHeader = {
                    type = "header",
                    name = "Extra position",
                    order = 63,
                },
                targetExtraPositionDescription1 = {
                    type = "description",
                    name = "Make room for TargetOfTarget unitframe in case it overlaps the first rows",
                    order = 64,
                },
                targetShortRowCount = option({
                    type = "range",
                    name = "Short row count",
                    order = 65,
                    step = 1,
                    min = 0,
                    max = 4,
                }),
                targetShortRowWidth = option({
                    type = "range",
                    name = "Short row width",
                    order = 66,
                    step = 1,
                    min = 30,
                    max = 400,
                }),
                targetExtraPositionDescription2 = {
                    type = "description",
                    name = "If you are using unitframes that are rectangular, then you might want extra room for TargetOfTarget unit frames",
                    order = 69,
                },
                targetWantExtraOffsetY = option({
                    type = "toggle",
                    name = "Enabled",
                    order = 70
                }),
                targetExtraOffsetY= option({
                    type = "range",
                    name = "Extra Y offset",
                    disabled = function() return not NicerAuras.db.profile.targetWantExtraOffsetY end,
                    order = 80,
                    step = 1,
                    min = -300,
                    max = 300,
                }),
            }
        },
        focusGroup = {
            type = "group",
            name = "Focus",
            order = 30,
            args = {
                focusSizeHeader = {
                    type = "header",
                    name = "Size",
                    order = 1,
                },
                focusRowWidth = option({
                    type = "range",
                    name = "Width",
                    step = 1,
                    order = 10,
                    min = 70,
                    max = 400,
                }),
                focusPlayerSize = option({
                    type = "range",
                    name = "My aura size",
                    step = 1,
                    order = 20,
                    min = 8,
                    max = 100
                }),
                focusOtherSize = option({
                    type = "range",
                    name = "Others aura size",
                    step = 1,
                    order = 30,
                    min = 8,
                    max = 100
                }),
                focusPositionHeader = {
                    type = "header",
                    name = "Position",
                    order = 39,
                },
                focusOffsetX = option({
                    type = "range",
                    name = "X offset",
                    step = 1,
                    order = 40,
                    min = -200,
                    max = 200,
                }),
                focusOffsetY = option({
                    type = "range",
                    name = "Y offset",
                    step = 1,
                    order = 50,
                    min = -200,
                    max = 200,
                }),
                focusPaddingX = option({
                    type = "range",
                    name = "Aura X padding",
                    order = 55,
                    min = 0,
                    max = 5,
                }),
                focusPaddingY = option({
                    type = "range",
                    name = "Aura Y padding",
                    order = 56,
                    min = 0,
                    max = 5,
                }),
                focusGrowUpwards = option({
                    name = "Auras on top",
                    type = "toggle",
                    order = 60,
                }),
                targetExtraPositionHeader = {
                    type = "header",
                    name = "Extra position",
                    order = 63,
                },
                focusShortRowCount = option({
                    type = "range",
                    name = "Short row count",
                    order = 64,
                    step = 1,
                    min = 0,
                    max = 4,
                }),
                focusShortRowWidth = option({
                    type = "range",
                    name = "Short row width",
                    order = 65,
                    step = 1,
                    min = 30,
                    max = 400,
                }),
                targetExtraPositionDescription = {
                    type = "description",
                    name = "If you are using unitframes that are rectangular, then you might want extra room for TargetOfTarget unit frames",
                    order = 69,
                },
                focusWantExtraOffsetY = option({
                    type = "toggle",
                    name = "Enabled",
                    order = 70
                }),
                focusExtraOffsetY= option({
                    type = "range",
                    name = "Extra Y offset",
                    disabled = function() return not NicerAuras.db.profile.focusWantExtraOffsetY end,
                    order = 80,
                    step = 1,
                    min = -300,
                    max = 300,
                }),
            }
        },
        testGroup = {
            type = "group",
            name = "Test Mode",
            order = 60,
            args = {
                testMode = option({
                    type = "toggle",
                    name = "Fill auras",
                    order = 1,
                }),
                testPlayerCount = option({
                    type = "range",
                    name = "Number of player auras",
                    step = 1,
                    min = 0,
                    max = 20,
                    order = 2,
                }),
                debugMode = option({
                    type = "toggle",
                    name = "Debug mode",
                    order = 1
                })
            }
        }
    }
}

function NicerAuras:CreateSlashCommands()
    self:RegisterChatCommand("na", "SlashCommand")
    self:RegisterChatCommand("nicerauras", "SlashCommand")
end

function NicerAuras:SlashCommand(msg)
    if self.isClassic or self.isWotlk then
        InterfaceOptionsFrame_OpenToCategory(self.optionsTable)
    elseif self.isTBC then
        InterfaceOptionsFrame_OpenToFrame("NicerAuras")
    end
end

function NicerAuras:LoadConfig()
    LibStub("AceConfig-3.0"):RegisterOptionsTable("NicerAuras", NicerAurasAceConfig)
    self.optionsTable = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("NicerAuras", "NicerAuras")
    if (self.isClassic or self.isWotlk) and NicerAuras.db.profile.debugMode then
        InterfaceOptionsFrame_OpenToCategory(self.optionsTable)
    end
end
