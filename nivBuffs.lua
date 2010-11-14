nivBuffs = CreateFrame("FRAME", "nivBuffs", UIParent)
nivBuffs:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
nivBuffs:RegisterEvent("ADDON_LOADED")

local LBF = LibStub('LibButtonFacade', true)
local bfButtons = {}
local BF = LBF and nivBuffDB.useButtonFacade

local grey = nivBuffDB.borderBrightness

-- init secure aura headers
local buffHeader = CreateFrame("Frame", "nivBuffs_Buffs", UIParent, "SecureAuraHeaderTemplate")
local debuffHeader = CreateFrame("Frame", "nivBuffs_Debuffs", UIParent, "SecureAuraHeaderTemplate")

local function btn_iterator(self, i)
    i = i + 1
    local child = self:GetAttribute("child" .. i)
    if child and child:IsShown() then return i, child, child:GetAttribute("index") end
end
function buffHeader:ActiveButtons() return btn_iterator, self, 0 end
function debuffHeader:ActiveButtons() return btn_iterator, self, 0 end

local function createAuraButton(btn, filter)
    -- subframe for icon and border
    btn.icon = CreateFrame("Frame", nil, btn)
    btn.icon:SetAllPoints(btn)
    btn.icon:SetFrameLevel(1)
    
    local s, b = 3, 3 / 28

    -- border texture
    local backdrop = {
        edgeFile = "Interface\\Addons\\nivBuffs\\borderTex", 
        edgeSize = 16,
        insets = { left = s, right = s, top = s, bottom = s }
    }

    -- icon texture
    btn.icon.tex = btn.icon:CreateTexture(nil, "ARTWORK")
    btn.icon.tex:SetPoint("TOPLEFT", s, -s)
    btn.icon.tex:SetPoint("BOTTOMRIGHT", -s, s)
    btn.icon.tex:SetTexCoord(b, 1-b, b, 1-b)
    if not BF then btn.icon:SetBackdrop(backdrop) end

    -- duration spiral
    if nivBuffDB.showDurationSpiral then
        btn.cd = CreateFrame("Cooldown", nil, btn.icon)
        btn.cd:SetAllPoints(btn.icon.tex)
        btn.cd:SetReverse(true)
        btn.cd.noCooldownCount = true -- no OmniCC timers
        btn.cd:SetFrameLevel(3)
    end

    if nivBuffDB.showDurationBar then
        btn.bar = CreateFrame("STATUSBAR", nil, btn.icon)
        btn.bar:SetPoint("TOPLEFT", btn.icon, "TOPLEFT", 3, -3)
        btn.bar:SetPoint("BOTTOMLEFT", btn.icon, "BOTTOMLEFT", 3, 3)
        btn.bar:SetWidth(2)
        btn.bar:SetStatusBarTexture("Interface\\Addons\\nivBuffs\\bar")
        btn.bar:SetOrientation("VERTICAL")
        
        btn.bar.bg = btn.bar:CreateTexture(nil, "BACKGROUND")
        btn.bar.bg:SetPoint("TOPLEFT", btn.icon, "TOPLEFT", 3, -3)
        btn.bar.bg:SetPoint("BOTTOMLEFT", btn.icon, "BOTTOMLEFT", 3, 3)        
        btn.bar.bg:SetWidth(3)
        btn.bar.bg:SetTexture("Interface\\Addons\\nivBuffs\\bar")
        btn.bar.bg:SetTexCoord(0, 1, 0, 1)
        btn.bar.bg:SetVertexColor(0, 0, 0, 0.6)
    end

    -- subframe for value texts
    btn.vFrame = CreateFrame("Frame", nil, btn)
    btn.vFrame:SetAllPoints(btn)
    btn.vFrame:SetFrameLevel(5)

    -- duration text
    btn.text = btn.vFrame:CreateFontString(nil, "OVERLAY")
    btn.text:SetFontObject(GameFontNormalSmall)
    btn.text:SetTextColor(nivBuffDB.fontColor.r, nivBuffDB.fontColor.g, nivBuffDB.fontColor.b, 1)
    btn.text:SetFont(nivBuffDB.durationFont, nivBuffDB.durationFontSize, nivBuffDB.durationFontStyle)

    if nivBuffDB.durationPos == "TOP" then btn.text:SetPoint("BOTTOM", btn.icon, "TOP", 0, 2)
    elseif nivBuffDB.durationPos == "LEFT" then btn.text:SetPoint("RIGHT", btn.icon, "LEFT", -2, 0)
    elseif nivBuffDB.durationPos == "RIGHT" then btn.text:SetPoint("LEFT", btn.icon, "RIGHT", 2, 0)
    else btn.text:SetPoint("TOP", btn.icon, "BOTTOM", 0, -2) end

    -- stack count
    btn.stacks = btn.vFrame:CreateFontString(nil, "OVERLAY")
    btn.stacks:SetPoint("BOTTOMRIGHT", btn.icon, "BOTTOMRIGHT", 4, -2)
    btn.stacks:SetFontObject(GameFontNormalSmall)
    btn.stacks:SetTextColor(nivBuffDB.fontColor.r, nivBuffDB.fontColor.g, nivBuffDB.fontColor.b, 1)
    btn.stacks:SetFont(nivBuffDB.stackFont, nivBuffDB.stackFontSize, nivBuffDB.stackFontStyle)
    
    if BF then bfButtons:AddButton(btn, { Icon = btn.icon.tex, Cooldown = btn.cd } ) end
    
    btn.lastUpdate = 0
    btn.filter = filter
    btn.created = true
    btn.cAlpha = 1
end

local function formatTimeRemaining(msecs)
    if not nivBuffDB.showDurationTimers then return "" end
    
    local secs = floor(msecs)
    local mins = ceil(secs / 60)
    local hrs = ceil(mins / 60)
    secs = secs % 60
    
    local tS = (hrs > 1) and hrs.."h" or ( (mins > 1) and mins.."m" or secs.."s" )
    return tS
end

local function updateBlink(btn)
    if btn.cAlpha >= 1 then btn.increasing = false elseif btn.cAlpha <= 0 then btn.increasing = true end
    btn.cAlpha = btn.cAlpha + (btn.increasing and nivBuffDB.blinkStep or -nivBuffDB.blinkStep)
    btn.icon:SetAlpha(btn.cAlpha)
end

local function updateBar(btn, duration)
    if not btn.bar then return end
    local r, g
    if btn.rTime > duration / 2 then r, g = (duration - btn.rTime) * 2 / duration, 1
    else r, g = 1, btn.rTime * 2 / duration end
    
    btn.bar:SetValue(btn.rTime)
    btn.bar:SetStatusBarColor(r, g, 0)
end

local function UpdateAuraButtonCD(btn, elapsed)
    if btn.lastUpdate < btn.freq then btn.lastUpdate = btn.lastUpdate + elapsed; return end
    btn.lastUpdate = 0

    local name,_,_,_,_,duration,eTime = UnitAura("player", btn:GetID(), btn.filter)
    if name and duration > 0 then 
        local msecs = eTime - GetTime()
        btn.text:SetText(formatTimeRemaining(msecs))

        btn.rTime = msecs
        if btn.rTime < btn.bTime then btn.freq = .05 end
        if btn.rTime <= nivBuffDB.blinkTime then updateBlink(btn) end

        updateBar(btn, duration)
    end
end

local function UpdateWeaponEnchantButtonCD(btn, elapsed)
    if btn.lastUpdate < btn.freq then btn.lastUpdate = btn.lastUpdate + elapsed; return end
    btn.lastUpdate = 0

    local _,r1,_,_,r2 = GetWeaponEnchantInfo()
    local rTime = (btn.slotID == 16) and r1 or r2

    btn.rTime = rTime / 1000
    btn.text:SetText(formatTimeRemaining(btn.rTime))

    if btn.rTime < btn.bTime then btn.freq = .05 end
    if btn.rTime <= nivBuffDB.blinkTime then updateBlink(btn) end
    
    updateBar(btn, 1800)
end

local function updateAuraButtonStyle(btn, filter)
    if not btn.created then createAuraButton(btn, filter) end
    
    local name,_,icon,count,dType,duration,eTime = UnitAura("player", btn:GetID(), filter)
    if name then
        btn.icon.tex:SetTexture(icon)

        local cond = (filter == "HARMFUL") and nivBuffDB.coloredBorder
        local c = {}
        c.r, c.g, c.b = cond and 0.6 or grey, cond and 0 or grey, cond and 0 or grey
        if dType and cond then c = DebuffTypeColor[dType] end
        btn.icon:SetBackdropBorderColor(c.r, c.g, c.b, 1)
        
        if duration > 0 then 
            if btn.cd then 
                btn.cd:SetCooldown(eTime - duration, duration)
                btn.cd:SetAlpha(1)
            end
            if btn.bar then
                btn.bar:SetMinMaxValues(0, duration)
                btn.bar:SetAlpha(1)
            end
            btn.icon:SetAlpha(1)

            btn.rTime = eTime - GetTime()
            btn.bTime = nivBuffDB.blinkTime + 1.1
            btn.freq = 1

            btn:SetScript("OnUpdate", UpdateAuraButtonCD)
            UpdateAuraButtonCD(btn, 5)
        else
            btn.text:SetText("")
            btn.icon:SetAlpha(1)
            if btn.cd then 
                btn.cd:SetCooldown(0, -1)
                btn.cd:SetAlpha(0)
            end
            if btn.bar then btn.bar:SetAlpha(0) end
            btn:SetScript("OnUpdate", nil)
        end
        btn.stacks:SetText((count > 1) and count or "")
    else
        btn.text:SetText("")
        btn.stacks:SetText("")
        if btn.cd then 
            btn.cd:SetCooldown(0, -1)
            btn.cd:SetAlpha(0)
        end
        if btn.bar then btn.bar:SetAlpha(0) end
        btn:SetScript("OnUpdate", nil)
    end
end

local function updateWeaponEnchantButtonStyle(btn, slot, hasEnchant, rTime)
    if not btn.created then createAuraButton(btn) end

    if hasEnchant then
        btn.slotID = GetInventorySlotInfo(slot)
        local icon = GetInventoryItemTexture("player", btn.slotID)
        btn.icon.tex:SetTexture(icon)

        local r, g, b = grey, grey, grey
        local c = GetInventoryItemQuality("player", slotid)
        if nivBuffDB.coloredBorder then r, g, b = GetItemQualityColor(c or 1) end
        btn.icon:SetBackdropBorderColor(r, g, b, 1)
        
        btn.rTime = rTime / 1000
        btn.bTime = nivBuffDB.blinkTime + 1.1
        btn.freq = 1

        btn.duration = 1800
        if btn.cd then 
            btn.cd:SetCooldown(GetTime() + btn.rTime - 1800, 1800)
            btn.cd:SetAlpha(1)
        end
        if btn.bar then
            btn.bar:SetMinMaxValues(0, 1800)
            btn.bar:SetAlpha(1)
        end        
        btn.icon:SetAlpha(1)

        btn:SetScript("OnUpdate", UpdateWeaponEnchantButtonCD)
        UpdateWeaponEnchantButtonCD(btn, 5)
    else
        btn.text:SetText("")
        if btn.cd then
            btn.cd:SetCooldown(0, -1)
            btn.cd:SetAlpha(0)
        end
        if btn.bar then btn.bar:SetAlpha(0) end
        btn:SetScript("OnUpdate", nil)
    end
end

local function updateStyle(header, event, unit)
    if unit ~= "player" and unit ~= "vehicle" and event ~= "PLAYER_ENTERING_WORLD" then return end

    for _,btn in header:ActiveButtons() do updateAuraButtonStyle(btn, header.filter) end
    if header.filter == "HELPFUL" then
        local hasMHe,MHrTime,_,hasOHe,OHrTime = GetWeaponEnchantInfo()
        local wEnch1 = buffHeader:GetAttribute("tempEnchant1")
        local wEnch2 = buffHeader:GetAttribute("tempEnchant2")

        if wEnch1 then updateWeaponEnchantButtonStyle(wEnch1, "MainHandSlot", hasMHe, MHrTime) end
        if wEnch2 then updateWeaponEnchantButtonStyle(wEnch2, "SecondaryHandSlot", hasOHe, OHrTime) end
    end
end

function nivBuffs:ADDON_LOADED(event, addon)
    if (addon ~= 'nivBuffs') then return end
    self:UnregisterEvent(event)

    --ChatFrame1:AddMessage(LBF and "OK" or "LBF fehlt!")
    --ChatFrame1:AddMessage(nivBuffDB.useButtonFacade and "OK" or "LBF deaktiviert!")
    
    -- buttonfacade
    if not nivBuffs_BF then nivBuffs_BF = {} end
    if BF then
        --ChatFrame1:AddMessage(nivBuffs_BF.skinID or "?")
        LBF:RegisterSkinCallback("nivBuffs", self.BFSkinCallBack, self)

        --ChatFrame1:AddMessage(nivBuffs_BF.skinID or "?")
        bfButtons = LBF:Group("nivBuffs", "auras")

        --ChatFrame1:AddMessage(nivBuffs_BF.skinID or "?")
        bfButtons:Skin(nivBuffs_BF.skinID, nivBuffs_BF.gloss, nivBuffs_BF.backdrop, nivBuffs_BF.colors)

        --ChatFrame1:AddMessage(nivBuffs_BF.skinID or "?")
    end
end

function nivBuffs:BFSkinCallBack(skinID, gloss, backdrop, group, button, colors)
    nivBuffs_BF.skinID = skinID
    nivBuffs_BF.gloss = gloss
    nivBuffs_BF.backdrop = backdrop
    nivBuffs_BF.colors = colors
    --ChatFrame1:AddMessage("Callback: " .. (nivBuffs_BF.skinID or "?"))
end

do
    BuffFrame:UnregisterEvent("UNIT_AURA")
    BuffFrame:Hide()
    TemporaryEnchantFrame:Hide()
    ConsolidatedBuffs:Hide()

    nivBuffDB.blinkStep = nivBuffDB.blinkSpeed / 10

    local function setHeaderAttributes(header, template, isBuff)
        header:SetAttribute("unit", "player")
        header:SetAttribute("filter", isBuff and "HELPFUL" or "HARMFUL")
        header:SetAttribute("template", template)
        header:SetAttribute("separateOwn", 0)
        header:SetAttribute("minWidth", 100)
        header:SetAttribute("minHeight", 100)

        header:SetAttribute("point", isBuff and nivBuffDB.buffAnchor[1] or nivBuffDB.debuffAnchor[1])
        header:SetAttribute("xOffset", isBuff and nivBuffDB.buffXoffset or nivBuffDB.debuffXoffset)
        header:SetAttribute("yOffset", isBuff and nivBuffDB.buffYoffset or nivBuffDB.debuffYoffset)
        header:SetAttribute("wrapAfter", isBuff and nivBuffDB.buffIconsPerRow or nivBuffDB.debuffIconsPerRow)
        header:SetAttribute("wrapXOffset", isBuff and nivBuffDB.buffWrapXoffset or nivBuffDB.debuffWrapXoffset)
        header:SetAttribute("wrapYOffset", isBuff and nivBuffDB.buffWrapYoffset or nivBuffDB.debuffWrapYoffset)
        header:SetAttribute("maxWraps", isBuff and nivBuffDB.buffMaxWraps or nivBuffDB.debuffMaxWraps)

        header:SetAttribute("sortMethod", nivBuffDB.sortMethod)
        header:SetAttribute("sortDirection", nivBuffDB.sortReverse and "-" or "+")

        if isBuff and nivBuffDB.showWeaponEnch then
            header:SetAttribute("includeWeapons", 1)
            header:SetAttribute("weaponTemplate", "nivBuffButtonTemplate")
        end

        header:SetScale(isBuff and nivBuffDB.buffScale or nivBuffDB.debuffScale)
        header.filter = isBuff and "HELPFUL" or "HARMFUL"
        
        header:RegisterEvent("PLAYER_ENTERING_WORLD")
        header:HookScript("OnEvent", updateStyle)
    end

    setHeaderAttributes(buffHeader, "nivBuffButtonTemplate", true)
    buffHeader:SetPoint(unpack(nivBuffDB.buffAnchor))
    buffHeader:Show()

    setHeaderAttributes(debuffHeader, "nivDebuffButtonTemplate", false)
    debuffHeader:SetPoint(unpack(nivBuffDB.debuffAnchor))
    debuffHeader:Show()
end