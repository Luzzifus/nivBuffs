nivBuffDB = 
{
	-- Anchors = { AnchorFrom, AnchorFrame, AnchorTo, x-offset (horizontal), y-offset (vertical) }
	--> Glue the <AnchorFrom> corner of the header to the <AnchorTo> corner of <AnchorFrame>
	--
	-- See addon description on wowinterface.com for more information and examples!	
	
	buffAnchor = { "TOPLEFT", "UIParent", "TOPLEFT", 15, -15 },
	debuffAnchor = { "TOPLEFT", "UIParent", "TOPLEFT", 15, -135 },
    
    -- horizontal distance between icons in a row 
    -- (positive values -> to the right, negative values -> to the left)
    buffXoffset = 35,
	debuffXoffset = 35,
    
    -- vertical distance between icons in a row 
    -- (positive values -> up, negative values -> down)
    buffYoffset = 0,
	debuffYoffset = 0,

    -- maximum number of icons in one row before a new row starts
    buffIconsPerRow = 20,
    debuffIconsPerRow = 20,

    -- maximum number of rows
    buffMaxWraps = 10,
    debuffMaxWraps = 10,

    -- horizontal offset when starting a new row
    -- (positive values -> to the right, negative values -> to the left)
    buffWrapXoffset = 0,
    debuffWrapXoffset = 0,

    -- vertical offset when starting a new row
    -- (positive values -> up, negative values -> down)
    buffWrapYoffset = -55,
    debuffWrapYoffset = -55,

    -- scale
    buffScale = 0.8,
    debuffScale = 0.8,

    sortMethod = "TIME",            -- how to sort the buffs/debuffs, possible values are "NAME", "INDEX" or "TIME"
    sortReverse = true,             -- reverse sort order
    showWeaponEnch = true,          -- show or hide temporary weapon enchants
    showDurationSpiral = false,     -- show or hide the duration spiral
    showDurationBar = true,         -- show or hide the duration bar
    showDurationTimers = false,     -- show or hide the duration text timers
    coloredBorder = true,           -- highlight debuffs and weapon enchants with a different border color
	borderBrightness = 0.25,		-- brightness of the default non-colored icon border ( 0 -> black, 1 -> white )
    blinkTime = 6,                  -- a buff/debuff icon will blink when it expires in less than x seconds, set to 0 to disable
	blinkSpeed = 0.75,				-- blinking speed as number of blink cycles per second
    durationPos = "BOTTOM",         -- position of remaining time text, possible values are "TOP", "BOTTOM", "LEFT" or "RIGHT"
    useButtonFacade = true,         -- toggle ButtonFacade Support

	-- font settings
    -- style can be "MONOCHROME", "OUTLINE", "THICKOUTLINE" or nil
    fontColor = { r = 1.0, g = 1.0, b = 0.4 },
    
    -- duration text
	durationFont = "Fonts\\FRIZQT__.TTF",
	durationFontStyle = nil,
	durationFontSize = 10,

	-- stack count text
	stackFont = "Fonts\\FRIZQT__.TTF",
	stackFontStyle = nil,
	stackFontSize = 10,
}