nivBuffDB = 
{
	-- Anchors = { AnchorFrom, AnchorFrame, AnchorTo, x-offset (horizontal), y-offset (vertical) }
	--> Glue the <AnchorFrom> corner of the header to the <AnchorTo> corner of <AnchorFrame>
	--
	-- See addon description on wowinterface.com for more information and examples!	
	
	buffAnchor = { "TOPLEFT", "UIParent", "TOPLEFT", 15, -15 },
	debuffAnchor = { "TOPLEFT", "UIParent", "TOPLEFT", 15, -135 },
    
    -- growth direction: 0 -> from left to right, 1 -> from right to left
    buffGrowDir = 0,
    debuffGrowDir = 0,
	
    -- horizontal distance between icons
    buffXoffset = 35,
	debuffXoffset = 35,

    -- scale
    buffScale = 0.8,
    debuffScale = 0.8,

    iconsPerRow = 20,               -- maximum number of icons in one row before a new row starts
    sortMethod = "TIME",            -- how to sort the buffs/debuffs, possible values are "NAME", "INDEX" or "TIME"
    sortReverse = true,             -- reverse sort order
    showWeaponEnch = true,          -- show or hide temporary weapon enchants
    showDurationSpiral = true,      -- show or hide the duration spiral
    coloredBorder = true,           -- highlight debuffs and weapon enchants with a different border color
	borderBrightness = 0.25,		-- brightness of the default non-colored icon border ( 0 -> black, 1 -> white )
    blinkTime = 6,                  -- a buff/debuff icon will blink when it expires in less than x seconds, set to 0 to disable
	blinkSpeed = 0.75,				-- blinking speed as number of blink cycles per second
    durationPos = "BOTTOM",         -- position of remaining time text, possible values are "TOP" or "BOTTOM"

    -- font color for cooldown text and stack count
    fontColor = { r = 1.0, g = 1.0, b = 0.4 },
}