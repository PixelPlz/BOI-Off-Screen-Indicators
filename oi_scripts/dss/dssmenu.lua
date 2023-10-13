local mod = OffscreenIndicators
local json = require("json")
local DSSMenu = {}

mod.Config = {}



-- Default DSS Data
mod.DefaultConfig = {
	Outline   = true,
	AlwaysShow = true,

	MarginX = 6,
	MarginY = 3,

	EnemyIndicators = mod.ShowEnemyMode.AfterTime,
	BossIndicators  = true,
	BossBarsCompat  = true,

	LudoIndicators = true,
}



-- Load settings
function DSSMenu:LoadSaveData()
	if mod:HasData() then
		mod.Config = json.decode(mod:LoadData())
	end

	for k, v in pairs(mod.DefaultConfig) do
		if mod.Config[k] == nil then
			local keyString = tostring(k)
			local keyFirst = string.sub(keyString, 1, 1)
			local keyLast = string.sub(keyString, 2)
			local key = string.lower(keyFirst) .. keyLast

			-- Convert old variable
			if mod.Config[key] ~= nil then
				mod.Config[k] = mod.Config[key]

			-- No matching old variable found
			else
				mod.Config[k] = v
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, DSSMenu.LoadSaveData)

-- Save settings
function DSSMenu:SaveData()
	mod:SaveData(json.encode(mod.Config))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, DSSMenu.SaveData)



-- Initialize Dead Sea Scrolls
-- Boring variables
local DSSModName = "Dead Sea Scrolls (Off-screen Indicators)"
local DSSCoreVersion = 7
local MenuProvider = {}

function MenuProvider.SaveSaveData()
	DSSMenu.SaveData()
end
function MenuProvider.GetPaletteSetting()
	return mod.Config.PaletteSetting
end
function MenuProvider.SavePaletteSetting(var)
	mod.Config.PaletteSetting = var
end
function MenuProvider.GetHudOffsetSetting()
	if not REPENTANCE then
		return mod.Config.HudOffset
	else
		return Options.HUDOffset * 10
	end
end
function MenuProvider.SaveHudOffsetSetting(var)
	if not REPENTANCE then
		mod.Config.HudOffset = var
	end
end
function MenuProvider.GetGamepadToggleSetting()
	return mod.Config.GamepadToggle
end
function MenuProvider.SaveGamepadToggleSetting(var)
	mod.Config.GamepadToggle = var
end
function MenuProvider.GetMenuKeybindSetting()
	return mod.Config.MenuKeybind
end
function MenuProvider.SaveMenuKeybindSetting(var)
	mod.Config.MenuKeybind = var
end
function MenuProvider.GetMenuHintSetting()
	return mod.Config.MenuHint
end
function MenuProvider.SaveMenuHintSetting(var)
	mod.Config.MenuHint = var
end
function MenuProvider.GetMenuBuzzerSetting()
	return mod.Config.MenuBuzzer
end
function MenuProvider.SaveMenuBuzzerSetting(var)
	mod.Config.MenuBuzzer = var
end
function MenuProvider.GetMenusNotified()
	return mod.Config.MenusNotified
end
function MenuProvider.SaveMenusNotified(var)
	mod.Config.MenusNotified = var
end
function MenuProvider.GetMenusPoppedUp()
	return mod.Config.MenusPoppedUp
end
function MenuProvider.SaveMenusPoppedUp(var)
	mod.Config.MenusPoppedUp = var
end

local DSSInitializerFunction = require("oi_scripts.dss.dssmenucore")
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)



-- Settings helpers
function mod:CreateDSSToggle(settingName, displayName, displayTooltip, extraIndicator, choiceOverride)
	-- Create the setting entry
	local setting = {
		str = displayName,
		fsize = 2,
		choices = choiceOverride or {'on', 'off'},
		setting = 1,
		variable = settingName,
	}


	-- This is dumb... too bad!
	-- Extra indicator
	if extraIndicator then
		setting.load = function()
			if mod.ExtraIndicators[settingName].enabled ~= nil then
				if mod.ExtraIndicators[settingName].enabled then
					return 1
				else
					return 2
				end
			end
			return 1
		end

		setting.store = function(var)
			local bool = var == 1
			mod.ExtraIndicators[settingName].enabled = bool
		end


	-- Mod config
	else
		setting.load = function()
			if mod.Config[settingName] ~= nil then
				if mod.Config[settingName] then
					return 1
				else
					return 2
				end
			end
			return 1
		end

		setting.store = function(var)
			local bool = var == 1
			mod.Config[settingName] = bool
		end
	end


	-- Add tooltip if it has one
	if displayTooltip then
		setting.tooltip = { strset = displayTooltip }
	end

	return setting
end

function mod:CreateDSSChoices(settingName, displayName, displayTooltip, choices)
	-- Create the setting entry
	local setting = {
		str = displayName,
		fsize = 2,
		choices = choices,
		setting = 1,
		variable = settingName,

		load = function()
			return mod.Config[settingName] or mod.DefaultConfig[settingName]
		end,

		store = function(var)
			mod.Config[settingName] = var
		end
	}

	-- Add tooltip if it has one
	if displayTooltip then
		setting.tooltip = { strset = displayTooltip }
	end

	return setting
end

local marginChoices = {'8', '16', '24', '32', '40', '48', '56', '64'}



-- Menus
local directory = {
	main = {
		title = 'off-screen icons',
		buttons = {
			{ str = 'resume game', action = 'resume' },
			{ str = 'general',     dest = 'general' },
			{ str = 'enemy',       dest = 'enemies' },
			{ str = 'item',        dest = 'items' },
			{ str = 'familiar',    dest = 'familiars' },
			dssmod.changelogsButton,
		},
		tooltip = dssmod.menuOpenToolTip
	},

	-- General
	general = {
		title = 'general settings',
		buttons = {
			mod:CreateDSSToggle("Outline", "outline"),
			{ str = '', fsize = 1, nosel = true },
			mod:CreateDSSToggle("AlwaysShow", "always show", { 'if disabled,', 'indicators', 'will only', 'show when', 'the map', 'is open' }),
			{ str = '', fsize = 3, nosel = true },

			mod:CreateDSSChoices("MarginX", "horizontal margin", nil, marginChoices),
			{ str = '', fsize = 1, nosel = true },
			mod:CreateDSSChoices("MarginY", "verical margin",    nil, marginChoices),

			{ str = '', fsize = 3, nosel = true },
			dssmod.gamepadToggleButton,
			dssmod.menuKeybindButton,
			dssmod.paletteButton,
			dssmod.menuHintButton,
			dssmod.menuBuzzerButton,
		}
	},

	enemies = {
		title = 'enemy indicators',
		buttons = {
			mod:CreateDSSChoices("EnemyIndicators", "show enemy indicators", nil, { 'never', 'outside of combat', 'when map is open', 'always' }),
			{ str = '', fsize = 1, nosel = true },
			mod:CreateDSSToggle("BossIndicators", "show boss indicators", nil, false, { 'always', 'with enemy indicators' }),
			{ str = '', fsize = 3, nosel = true },
			mod:CreateDSSToggle("BossBarsCompat", "boss bars compatibility", { 'bosses will', 'use their', 'enhanced', 'boss bar icon' }),
		}
	},

	items = {
		title = 'item indicators',
		buttons = {
			mod:CreateDSSToggle("LudoIndicators", "ludovico tecnique"),
			{ str = '', fsize = 1, nosel = true },
			mod:CreateDSSToggle("GoldenCoin", "golden coins", nil, true),
			{ str = '', fsize = 1, nosel = true },
			mod:CreateDSSToggle("DeathsList", "death's list", nil, true),
			{ str = '', fsize = 1, nosel = true },
			mod:CreateDSSToggle("Purgatory", "purgatory", nil, true),
		}
	},

	familiars = {
		title = 'familiar indicators',
		buttons = {
			mod:CreateDSSToggle("RoboBaby2", "robo-baby 2.0", nil, true),
			{ str = '', fsize = 1, nosel = true },
			mod:CreateDSSToggle("BBFly",     "???'s only friend", nil, true),
			{ str = '', fsize = 1, nosel = true },
			mod:CreateDSSToggle("LilDumpy",  "lil dumpy", nil, true),
			{ str = '', fsize = 1, nosel = true },
			mod:CreateDSSToggle("Stitches",  "stitches", nil, true),
		}
	},
}



-- Add the menu
local directorykey = {
	Item = directory.main,
	Main = 'main',
	Idle = false,
	MaskAlpha = 1,
	Settings = {},
	SettingsChanged = false,
	Path = {},
}

DeadSeaScrollsMenu.AddMenu("off-screen icons", {
	Run = dssmod.runMenu,
	Open = dssmod.openMenu,
	Close = dssmod.closeMenu,
	UseSubMenu = false,
	Directory = directory,
	DirectoryKey = directorykey
})