local mod = OffscreenIndicators
local json = require("json")

OIconfig = {
	alwaysShow = true,
	outline = true,

	marginX = 48,
	marginY = 24,

	enemyIndicators = 1,
	bossIndicators = true,
	bossBarsCompat = true,

	ludoIndicators = true,
}



-- Load settings
function mod:postGameStarted()
    if mod:HasData() then
        local data = json.decode(mod:LoadData())
        for k, v in pairs(data) do
            if OIconfig[k] ~= nil then OIconfig[k] = v end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.postGameStarted)

-- Save settings
function mod:preGameExit()
	mod:SaveData(json.encode(OIconfig))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.preGameExit)



-- Menu options
if ModConfigMenu then
	local path = "gfx/ui/offscreen_icons/"

	-- Icon positioning fix by Laceous
	local function getRenderPos(x, y)
		local pos = ScreenHelper.GetScreenCenter() + Vector(68, -18) -- Copied from mcm, center of right panel
		return pos + Vector(x, y)
	end


  	local category = "Off-screen Icons"
	ModConfigMenu.RemoveCategory(category);
  	ModConfigMenu.UpdateCategory(category, {
		Name = category,
		Info = "Change settings for Off-screen Indicators"
	})


	-- General --
	-- Always show indicators
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIconfig.alwaysShow
		end,
	    Display = function()
			return "Always show indicators: " .. (OIconfig.alwaysShow and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIconfig.alwaysShow = bool
	    end,
		Info = {"If disabled, indicators will only show when the map button is held down."},
  	})
	-- Outline
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIconfig.outline
		end,
	    Display = function()
			return "Outline: " .. (OIconfig.outline and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIconfig.outline = bool
	    end,
  	})
	-- Margin
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.NUMBER,
	    CurrentSetting = function()
			return (OIconfig.marginX / 8)
		end,
		Minimum = 1,
		Maximum = 8,
	    Display = function()
			return "Horizontal Margin: " .. OIconfig.marginX
		end,
	    OnChange = function(currentNum)
	    	OIconfig.marginX = currentNum * 8
	    end,
  	})
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.NUMBER,
	    CurrentSetting = function()
			return (OIconfig.marginY / 8)
		end,
		Minimum = 1,
		Maximum = 8,
	    Display = function()
			return "Vertical Margin: " .. OIconfig.marginY
		end,
	    OnChange = function(currentNum)
	    	OIconfig.marginY = currentNum * 8
	    end,
  	})

	ModConfigMenu.AddSpace(category, "General")

	-- Enemies
	local enemyModes = {
		{mode = "Never", 				 info = ""},
		{mode = "Outside of combat", 	 info = "Indicators will show after 8 seconds without dealing damage to enemies."},
		{mode = "While map is expanded", info = "Indicators will show while the map button is held down."},
		{mode = "Always", 				 info = ""}
	}
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.NUMBER,
	    CurrentSetting = function()
			return (OIconfig.enemyIndicators)
		end,
		Minimum = 0,
		Maximum = 3,
	    Display = function()
			return "Enemy indicators: " .. enemyModes[OIconfig.enemyIndicators + 1].mode
		end,
	    OnChange = function(currentNum)
	    	OIconfig.enemyIndicators = currentNum
	    end,
		Info = function()
			return enemyModes[OIconfig.enemyIndicators + 1].info
		end,
  	})
	-- Bosses
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIconfig.bossIndicators
		end,
	    Display = function()
			return "Boss indicators: " .. (OIconfig.bossIndicators and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIconfig.bossIndicators = bool
	    end,
  	})
	-- Enhanced boss bars compatibility
	ModConfigMenu.AddSetting(category, "General", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIconfig.bossBarsCompat
		end,
	    Display = function()
			local icon = path .. "boss.png"
			if HPBars and OIconfig.bossBarsCompat == true then
				icon = "gfx/ui/bosshp_icons/chapter1/monstro.png"
			end
			mod:renderIndicator(getRenderPos(0, 78), icon)

			return "Enhanced boss bars compatibility: " .. (OIconfig.bossBarsCompat and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIconfig.bossBarsCompat = bool
	    end,
  	})


	-- Indicator toggles --
	-- Ludovico Technique
	ModConfigMenu.AddSetting(category, "Items", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIconfig.ludoIndicators
		end,
	    Display = function()
			mod:renderIndicator(getRenderPos(-108, -40), path .. "default.png", 0.9)
			return "Ludovico Technique: " .. (OIconfig.ludoIndicators and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIconfig.ludoIndicators = bool
	    end,
  	})
	-- Golden Penny
	ModConfigMenu.AddSetting(category, "Items", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIextraIndicators.goldenCoin.enabled
		end,
	    Display = function()
			mod:renderIndicator(getRenderPos(-108, -27), path .. "coin.png", 0.9)
			return "Golden Penny: " .. (OIextraIndicators.goldenCoin.enabled and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIextraIndicators.goldenCoin.enabled = bool
	    end,
  	})
	-- Death's List
	ModConfigMenu.AddSetting(category, "Items", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIextraIndicators.deathsList.enabled
		end,
	    Display = function()
			mod:renderIndicator(getRenderPos(-108, -14), path .. "skull.png", 0.9)
			return "Death's List: " .. (OIextraIndicators.deathsList.enabled and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIextraIndicators.deathsList.enabled = bool
	    end,
  	})
	-- Purgatory
	ModConfigMenu.AddSetting(category, "Items", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIextraIndicators.purgatory.enabled
		end,
	    Display = function()
			mod:renderIndicator(getRenderPos(-108, 1), path .. "purgatory.png", 0.9)
			return "Purgatory: " .. (OIextraIndicators.purgatory.enabled and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIextraIndicators.purgatory.enabled = bool
	    end,
  	})

	ModConfigMenu.AddSpace(category, "Items")
	ModConfigMenu.AddText(category, "Items", function() return "-- Familiars --" end)
	-- Robo-Baby 2.0
	ModConfigMenu.AddSetting(category, "Items", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIextraIndicators.roboBaby2.enabled
		end,
	    Display = function()
			mod:renderIndicator(getRenderPos(-108, 40), path .. "robobaby2.png", 0.9)
			return "Robo-Baby 2.0: " .. (OIextraIndicators.roboBaby2.enabled and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIextraIndicators.roboBaby2.enabled = bool
	    end,
  	})
	-- Blue Baby's Only Friend
	ModConfigMenu.AddSetting(category, "Items", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIextraIndicators.bbFly.enabled
		end,
	    Display = function()
			mod:renderIndicator(getRenderPos(-108, 56), path .. "bbfly.png", 0.9)
			return "Blue Baby's Only Friend: " .. (OIextraIndicators.bbFly.enabled and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIextraIndicators.bbFly.enabled = bool
	    end,
  	})
	-- Lil Dumpy
	ModConfigMenu.AddSetting(category, "Items", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIextraIndicators.lilDumpy.enabled
		end,
	    Display = function()
			mod:renderIndicator(getRenderPos(-108, 71), path .. "dumpy.png", 0.9)
			return "Lil Dumpy: " .. (OIextraIndicators.lilDumpy.enabled and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIextraIndicators.lilDumpy.enabled = bool
	    end,
  	})
	-- Stitches
	ModConfigMenu.AddSetting(category, "Items", {
    	Type = ModConfigMenu.OptionType.BOOLEAN,
	    CurrentSetting = function()
			return OIextraIndicators.stitches.enabled
		end,
	    Display = function()
			mod:renderIndicator(getRenderPos(-108, 85), path .. "stitches.png", 0.9)
			return "Stitches: " .. (OIextraIndicators.stitches.enabled and "On" or "Off")
		end,
	    OnChange = function(bool)
	    	OIextraIndicators.stitches.enabled = bool
	    end,
  	})
end