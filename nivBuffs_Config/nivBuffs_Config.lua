local optGeneral = function(order)
	return {	
		type = 'group', name = "General Settings", order = order, dialogHidden = true, dialogInline = true, 
		args = {
			weapEnch	= { type = 'toggle',
							order = 5,
							width = 'full',
							name = "Show Weapon Enchants",
							get = function(info) return nivBuffDB.showWeaponEnch end,
							set = function(info, value)
								nivBuffDB.showWeaponEnch = value
							end, },

			durSpiral	= { type = 'toggle',
							order = 6,
							width = 'full',
							name = "Show Duration Spiral",
							get = function(info) return nivBuffDB.showDurationSpiral end,
							set = function(info, value)
								nivBuffDB.showDurationSpiral = value
							end, },

			durBar		= { type = 'toggle',
							order = 7,
							width = 'full',
							name = "Show Duration Bar",
							get = function(info) return nivBuffDB.showDurationBar end,
							set = function(info, value)
								nivBuffDB.showDurationBar = value
							end, },

			durTimers	= { type = 'toggle',
							order = 8,
							width = 'full',
							name = "Show Duration Timers",
							get = function(info) return nivBuffDB.showDurationTimers end,
							set = function(info, value)
								nivBuffDB.showDurationTimers = value
							end, },

			colBorder	= { type = 'toggle',
							order = 9,
							width = 'full',
							name = "Colored Borders",
							desc = "Highlight debuffs and weapon enchants with a different border color.",
							get = function(info) return nivBuffDB.coloredBorder end,
							set = function(info, value)
								nivBuffDB.coloredBorder = value
							end, },

			useBF		= { type = 'toggle',
							order = 10,
							width = 'full',
							name = "Use ButtonFacade",
							desc = "Enable ButtonFacade support. Set the skin in the ButtonFacade options.",
							get = function(info) return nivBuffDB.useButtonFacade end,
							set = function(info, value)
								nivBuffDB.useButtonFacade = value
							end, },

			bordBright	= { type = 'range',
							order = 11,
							width = 'full',
							name = "Border Brightness",
							desc = "Brightness of the default non-colored icon border ( 0 -> black, 1 -> white ).",
							min = 0,
							max = 1,
							step = 0.05,
							get = function(info) return nivBuffDB.borderBrightness end,
							set = function(info, value)
								nivBuffDB.borderBrightness = value
							end, },

			blinkTime	= { type = 'input',
		 					order = 12,
		 					name = "Blinking Time",
		 					desc = "Icons will blink when they expire in less than x seconds, set to 0 to disable.",
							pattern = '%d',
		 					get = function() return tostring(nivBuffDB.blinkTime) end,
		 					set = function(info, value)
		 						nivBuffDB.blinkTime = tonumber(value)
							end, },

			blinkSpeed	= { type = 'input',
		 					order = 13,
		 					name = "Blinking Speed",
		 					desc = "Blinking speed as number of blink cycles per second.",
							pattern = '%d',
		 					get = function() return tostring(nivBuffDB.blinkSpeed) end,
		 					set = function(info, value)
		 						nivBuffDB.blinkSpeed = tonumber(value)
							end, },
		},
	}
end

local optAuras = function(order, object)
	return {	
		type = 'group', name = object.Name .. " Settings", order = order, dialogHidden = true, dialogInline = true, 
		args = {

		},
	}
end

local optTextOptions = function(order, object)
	return {	
		type = 'group', name = nivBuffDB[object].Name, order = order, inline = true,
		args = {
			header1 	= { type = "header", order = 1, name = "Position", },
			
			textPos		= { type = 'select',
							order = 2,
							name = "Position",
							values = { ["TOP"] = "Top", ["BOTTOM"] = "Bottom", ["LEFT"] = "Left", ["RIGHT"] = "Right", },
							get = function(info) return nivBuffDB[object].Pos end,
							set = function(info, value)	
								nivBuffDB[object].Pos = value 
							end, },

			textXoffs	= { type = 'input',
		 					order = 3,
		 					name = "X offset",
		 					width = 'half',
							pattern = '%d',
		 					get = function() return tostring(nivBuffDB[object].Xoffset) end,
		 					set = function(info, value)
		 						nivBuffDB[object].Xoffset = tonumber(value)
							end, },

			textYoffs	= { type = 'input',
		 					order = 4,
		 					name = "Y offset",
		 					width = 'half',
							pattern = '%d',
		 					get = function() return tostring(nivBuffDB[object].Yoffset) end,
		 					set = function(info, value)
		 						nivBuffDB[object].Yoffset = tonumber(value)
							end, },

			header2 	= { type = "header", order = 10, name = "Font Settings", },

			textFont	= { type = 'input',
		 					order = 11,
		 					name = "Font",
		 					width = 'full',
		 					get = function() return nivBuffDB[object].Font end,
		 					set = function(info, value)
		 						nivBuffDB[object].Font = value
							end, },

			textFStyle	= { type = 'select',
		 					order = 12,
		 					name = "Font Style",
							values = { ["NONE"] = "None", ["MONOCHROME"] = "Monochrome", ["OUTLINE"] = "Outline", ["THICKOUTLINE"] = "Thick Outline", },
		 					get = function() return nivBuffDB[object].FontStyle or "NONE" end,
		 					set = function(info, value)
								if value == "NONE" then value = nil end
		 						nivBuffDB[object].FontStyle = value
							end, },

			textFSize	= { type = 'range',
							order = 13,
							name = "Font Size",
							min = 6,
							max = 22,
							step = 1,
							get = function(info) return nivBuffDB[object].FontSize end,
							set = function(info, value)
								nivBuffDB[object].FontSize = value
							end, },

			textFCol	= { type = 'color',
							order = 14,
							name = "Font Color",
							hasAlpha = true,
							get = function(info)
								local t = nivBuffDB[object].FontColor
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = nivBuffDB[object].FontColor
								t.r, t.g, t.b, t.a = r, g, b, a
							end, },
		},
	}
end

local optTexts = function(order)
	return {	
		type = 'group', name = "Text Settings", order = order, dialogHidden = true, dialogInline = true, 
		args = {
			duration 	= optTextOptions(1, "Duration"),
			stacks 		= optTextOptions(2, "Stacks"),
		},
	}
end

local options = {
	type = 'group', name = "nivBuffs",
	args = {
		desc1			= { type = 'description', order = 0, name = "nivBuffs by Luzzifus - www.wowinterface.com", },

		rlui			= { type = 'execute', order = 1, name = "Reload UI", desc = "Reloads the UI.",  func = function() ReloadUI() end, },
		defaults		= { type = 'execute', order = 2, name = "Restore Defaults", desc = "Restores default settings and reloads the UI.", func = function() nivBuffDB = {}; nivBuffs:LoadDefaults(); ReloadUI() end, },

		GeneralSettings	= optGeneral(3),
		BuffSettings	= optAuras(4, "Buff"),
		DebuffSettings	= optAuras(5, "Debuff"),
		TextSettings	= optTexts(6),
	},
}

LibStub('AceConfig-3.0'):RegisterOptionsTable('nivBuffs', options)
local ACD = LibStub('AceConfigDialog-3.0')
ACD:AddToBlizOptions('nivBuffs', 'nivBuffs')
ACD:AddToBlizOptions('nivBuffs', 'General', 'nivBuffs', 'GeneralSettings')
ACD:AddToBlizOptions('nivBuffs', 'Buffs', 	'nivBuffs', 'BuffSettings')
ACD:AddToBlizOptions('nivBuffs', 'Debuffs',	'nivBuffs', 'DebuffSettings')
ACD:AddToBlizOptions('nivBuffs', 'Texts', 'nivBuffs', 'TextSettings')