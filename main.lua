OffscreenIndicators = RegisterMod("Off-screen Indicators", 1)
local mod = OffscreenIndicators
local game = Game()
local path = "gfx/ui/offscreen_icons/"

OIholdTabCounter = 0



--[[/////////////////////////////////////////--
	HOW TO BLACKLIST ENTITIES / ADD EXTRA INDICATORS:
variants and subtypes can be -1 to include all of them
values marked with * are optional


Adding blacklist entry:
OffscreenIndicators:addOIblacklist(type, variant, subtype, *condition, *value)
	there are currently 2 conditions (more will be added if requested): "segmented" and "state"
		if the condition is "segmented", then only entities without parents will have the indicator
		if the condition is "state" you need to specify the states that will NOT have indicators (this can be a table with multiple states in it)


Adding extra indicator:
OffscreenIndicators:addExtraIndicator(name, type, variant, subtype, icon)
	icon should be the FULL path to the icon
	name is used for finding a specifc entry so it can be accessed later
		for example:
		adding an indicator with OffscreenIndicators:addExtraIndicator("test", EntityType.ENTITY_GAPER, -1, -1, "gfx/ui/offscreen_icons/default.png")
		would let you access all the values from this entry with OIextraIndicators.test.{variable name}
		the available variables are:
			type = EntityType.ENTITY_GAPER
			variant = -1
			subtype = -1
			icon = "gfx/ui/offscreen_icons/default.png"
			enabled = true (lets you toggle indicators with Mod Config Menu for example, true by default)
--/////////////////////////////////////////]]--



--[[--------------------------------------------------------
    Blacklist
--]]--------------------------------------------------------

OIblacklist = {
	{EntityType.ENTITY_LARRYJR, -1, -1, "segmented"},
	{EntityType.ENTITY_CHUB, -1, -1, "segmented"},
	{EntityType.ENTITY_PIN, -1, -1, "segmented"},
	{EntityType.ENTITY_DADDYLONGLEGS, -1, -1, "segmented"},
	{EntityType.ENTITY_MAMA_GURDY, 1, -1}, {EntityType.ENTITY_MAMA_GURDY, 2, -1}, -- Mama Gurdy's hands
	{EntityType.ENTITY_POLYCEPHALUS, 0, -1, "state", NpcState.STATE_MOVE}, -- Underground state
	{EntityType.ENTITY_MEGA_SATAN, 0, -1, "state", {NpcState.STATE_APPEAR_CUSTOM, NpcState.STATE_SUMMON}}, -- Hidden states
	{EntityType.ENTITY_MEGA_SATAN, 1, -1}, {EntityType.ENTITY_MEGA_SATAN, 2, -1}, -- Mega Satan's hands
	{EntityType.ENTITY_ULTRA_DOOR, -1, -1},
	{EntityType.ENTITY_STAIN, 0, -1, "state", NpcState.STATE_MOVE}, -- Underground state
	{EntityType.ENTITY_BIG_HORN, 0, -1, "state", NpcState.STATE_MOVE}, -- Hidden state
	{EntityType.ENTITY_BIG_HORN, 1, -1}, {EntityType.ENTITY_BIG_HORN, 2, -1}, -- Big Horn holes
	{EntityType.ENTITY_GIDEON, -1, -1},
	{EntityType.ENTITY_SCOURGE, 10, -1},
	{EntityType.ENTITY_MOTHER, 30, -1}, -- Mother worm
	{EntityType.ENTITY_MOTHER, 100, -1}, -- Mother balls
	{EntityType.ENTITY_RAGLICH, 1, -1}, -- Raglich's arms

	-- Fiend Folio bosses
	{180, 90 -1, "segmented"}, -- Kingpin
	{180, 171 -1}, -- Dusk's arms
	{180, 250 -1}, -- Whisper controller
}

-- Check if the entity is blacklisted or not
function mod:onBlacklist(entity)
	for i,entry in pairs(OIblacklist) do
		if entity.Type == entry[1] and (entry[2] == -1 or entity.Variant == entry[2]) and (entry[3] == -1 or entity.SubType == entry[3]) then
			-- Extra conditions
			if entry[4] then
				-- Segmented bosses
				if entry[4] == "segmented" then
					if entity.Parent or (entity.Type == EntityType.ENTITY_DADDYLONGLEGS and entity:ToNPC().State == NpcState.STATE_STOMP and entity.SpawnerEntity) then
						return true
					end

				-- State
				elseif entry[4] == "state" then
					-- Allow checking for multiple states
					if type(entry[5]) == "table" then
						for j,state in pairs(entry[5]) do
							if entity:ToNPC().State == state then
								return true
							end
						end

					else
						if entity:ToNPC().State == entry[5] then
							return true
						end
					end
				end
				return false

			else
				return true
			end
		end
	end
	return false
end

-- Add blacklist entry
function mod:addOIblacklist(type, variant, subtype, condition, value)
	local tableValues = {type, variant, subtype}
	if condition then
		table.insert(tableValues, condition)
		if value then
			table.insert(tableValues, value)
		end
	end

	table.insert(OIblacklist, tableValues)
end



--[[--------------------------------------------------------
    Extra indicators
--]]--------------------------------------------------------

OIextraIndicators = {
	-- Familiars
	roboBaby2 = {type = EntityType.ENTITY_FAMILIAR, variant = FamiliarVariant.ROBO_BABY_2, 			 subtype = -1, icon = path .. "robobaby2.png", enabled = true},
	bbFly 	  = {type = EntityType.ENTITY_FAMILIAR, variant = FamiliarVariant.BLUEBABYS_ONLY_FRIEND, subtype = -1, icon = path .. "bbfly.png", 	   enabled = true},
	lilDumpy  = {type = EntityType.ENTITY_FAMILIAR, variant = FamiliarVariant.LIL_DUMPY, 			 subtype = -1, icon = path .. "dumpy.png", 	   enabled = true},
	stitches  = {type = EntityType.ENTITY_FAMILIAR, variant = FamiliarVariant.STITCHES, 			 subtype = -1, icon = path .. "stitches.png",  enabled = true},

	-- Pickups
	goldenCoin = {type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_GOLDEN, icon = path .. "coin.png", enabled = true},

	-- Effects
	deathsList = {type = EntityType.ENTITY_EFFECT, variant = EffectVariant.DEATH_SKULL, subtype = -1, icon = path .. "skull.png", 	  enabled = true},
	purgatory  = {type = EntityType.ENTITY_EFFECT, variant = EffectVariant.PURGATORY, 	subtype = 0,  icon = path .. "purgatory.png", enabled = true},
}

-- Check if the entity is in the list or not
function mod:hasIndicator(entity)
	for i,entry in pairs(OIextraIndicators) do
		if entity.Type == entry.type and (entry.variant == -1 or entity.Variant == entry.variant) and (entry.subtype == -1 or entity.SubType == entry.subtype) and entry.enabled == true then
			return entry
		end
	end
	return false
end

-- Add extra indicator
function mod:addExtraIndicator(name, addType, addVariant, addSubType, addIcon)
	OIextraIndicators[name] = {type = addType, variant = addVariant, subtype = addSubType, icon = addIcon, enabled = true}
end



--[[--------------------------------------------------------
    Functions
--]]--------------------------------------------------------

-- Mod Config Menu options
include("configMenu")

-- Render an indicator
function mod:renderIndicator(position, icon, scale, rotation, newAnm2, newAnimation)
	local sprite = Sprite()

	-- Animation file
	if newAnm2 then
		sprite:Load(newAnm2, true)
		if newAnimation then
			sprite:Play(newAnimation, true)
		else
			sprite:Play(sprite:GetDefaultAnimation())
		end

	else
		sprite:Load("gfx/ui/offscreen_icons/icon.anm2", true)
		sprite:Play("Idle", true)
	end

	-- Icon spritesheet
	if icon then
		sprite:ReplaceSpritesheet(0, icon)
		sprite:LoadGraphics()
	end

	-- Scale / Rotation
	if scale then
		sprite.Scale = Vector(scale, scale)
	end
	if rotation then
		sprite.Rotation = rotation
	end

	sprite:Render(position, Vector.Zero, Vector.Zero)
end

-- Check if the map button is held by any players
function mod:isMapButtonHeld()
	for i = 0, game:GetNumPlayers() - 1 do
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, Isaac.GetPlayer(i).ControllerIndex) == true then
			return true
		end
	end
	return false
end

-- Check if indicators should be enabled or not
function mod:areIndicatorsEnabled()
	if game:IsPaused() == false
	and game:GetHUD():IsVisible() == true
	and (OIconfig.alwaysShow == true or OIholdTabCounter >= 15) then
		return true
	end
	return false
end

-- Check if entity is a valid boss
function mod:isValidBoss(entity)
	if OIconfig.bossIndicators
	and entity:ToNPC() and entity:IsBoss()
	and entity.Visible == true
	and entity.HitPoints >= 1
	and mod:onBlacklist(entity) == false
	and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
		return true
	end
	return false
end

-- Check if entity is from Ludovico Tecnique
function mod:isLudoWeapon(entity)
	if OIconfig.ludoIndicators
	and ((entity:ToTear() and entity:ToTear():HasTearFlags(TearFlags.TEAR_LUDOVICO))
	or (entity:ToKnife() and entity:ToTear():HasTearFlags(TearFlags.TEAR_LUDOVICO))
	or (entity:ToLaser() and entity.SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO)) then
		return true
	end
	return false
end

-- Get Enhanced Boss Bars icon (adapted from HPBars:createNewBossBar())
if HPBars then
	function HPBars:getOFBossIcon(entity)
		local entityNPC = entity:ToNPC()
		local championColor =
			entityNPC and HPBars.Config.UseChampionColors and
			(entityNPC:GetChampionColorIdx() >= 0 or entityNPC:GetBossColorIdx() >= 0) and
			HPBars:copyColor(entity:GetColor()) or
			nil

		return { -- I don't know how many of these are necessary so I'll just leave them here
			entity = entity,
			hp = entity.HitPoints or 0,
			maxHP = entity.MaxHitPoints or 0,
			entityColor = championColor,
			bossColorIDx = entityNPC and entityNPC:GetBossColorIdx() or -1,
			iconAnimationType = "HP",
			lastHP = entity.HitPoints,
			hitState = "",
			lastStateChangeFrame = 0,
			initialType = HPBars:getEntityTypeString(entity)
		}
	end
end



--[[--------------------------------------------------------
    Get all indicators to render
--]]--------------------------------------------------------

function mod:onRender()
	-- If "always show" is disabled then check for the map mode
	if OIconfig.alwaysShow == false then
		-- If EID is enabled then just copy the value from its tab variable
		if EID then
			OIholdTabCounter = EID.holdTabCounter
		else
			if mod:isMapButtonHeld() == true then
				OIholdTabCounter = OIholdTabCounter + 1
			else
				OIholdTabCounter = 0
			end
		end
	end


	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		local pos = Isaac.WorldToScreen(entity.Position + entity.PositionOffset)

		-- Only check if entity is off-screen (and not in the Beast fight)
		if (pos.X > Isaac.GetScreenWidth() or pos.X < 0 or pos.Y > Isaac.GetScreenHeight() or pos.Y < 0) and game:GetRoom():GetBackdropType() ~= BackdropType.DUNGEON_BEAST then
			local extraIndicator = mod:hasIndicator(entity)

			if mod:areIndicatorsEnabled() == true and (mod:isValidBoss(entity) == true or mod:isLudoWeapon(entity) == true or extraIndicator ~= false) then
				-- Margins
				pos = Vector(math.min(Isaac.GetScreenWidth() - OIconfig.marginX, pos.X), math.min(Isaac.GetScreenHeight() - OIconfig.marginY, pos.Y))
				pos = Vector(math.max(OIconfig.marginX, pos.X), math.max(OIconfig.marginY, pos.Y))


				-- Icon
				local icon = path .. "default.png"
				local newAnm2 = nil
				local newAnimation = nil
				local rotation = nil

				-- Bosses
				if entity:ToNPC() and entity:ToNPC():IsBoss() then
					-- Enhanced boss bars compatibility
					if HPBars and OIconfig.bossBarsCompat == true then
						-- Dogma's first phase doesn't have a proper bossbar data entry
						if entity.Type == EntityType.ENTITY_DOGMA and entity.Variant == 0 then
							icon = "gfx/ui/bosshp_icons/final/dogma.png"

						else
							-- Adapted from HPBars:updateSprites()
							local bossEntry = HPBars:getOFBossIcon(entity)
							local bossDefinition = HPBars:getBossDefinition(bossEntry.entity)
							icon = HPBars:getIconSprite(bossDefinition, bossEntry, HPBars:getBarStyle(HPBars.Config.EnableSpecificBossbars and bossDefinition.barStyle or bossEntry.barStyle))
							
							-- Big icons
							if ((entity.Type == EntityType.ENTITY_MEGA_SATAN or entity.Type == EntityType.ENTITY_MEGA_SATAN_2) and entity.Variant == 0) or (entity.Type == EntityType.ENTITY_DOGMA and entity.Variant == 2)
							or (entity.Type == EntityType.ENTITY_BEAST and (entity.Variant == 10 or entity.Variant == 20 or entity.Variant == 30 or entity.Variant == 40)) then
								newAnm2 = "gfx/ui/bosshp_icons/bosshp_icon_64px.anm2"
								newAnimation = "idle"
							end
						end

					else
						icon = "gfx/ui/offscreen_icons/boss.png"
					end

				-- Extra indicators
				elseif extraIndicator ~= false then
					icon = extraIndicator.icon
				end

				-- Ludo / default
				if icon == path .. "default.png" then
					rotation = (Isaac.WorldToScreen(entity.Position + entity.PositionOffset) - pos):GetAngleDegrees()
				end


				-- Scale
				local scale = 1 - (Isaac.WorldToScreen(entity.Position + entity.PositionOffset):Distance(pos) * 0.001)
				scale = math.max(0.5, scale)
				scale = math.min(1, scale)


				mod:renderIndicator(pos, icon, scale, rotation, newAnm2, newAnimation)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.onRender)