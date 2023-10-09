OffscreenIndicators = RegisterMod("Off-screen Indicators", 1)
local mod = OffscreenIndicators



--[[/////////////////////////////////////////--
	HOW TO BLACKLIST ENTITIES / ADD EXTRA INDICATORS:
(Values marked with * are optional)


Adding a blacklist entry:
OffscreenIndicators:AddBlacklist(type, *variant, *subtype, *condition)
	condition can be the following:
		"segmented" to blacklist entities with parents
		a table of states that the entity should be blacklisted during
		a custom function that should return true if the entity should be blacklisted (the first parameter should be the entity!)


Adding an extra indicator:
OffscreenIndicators:AddExtraIndicator(type, *variant, *subtype, *icon, *bigIcon, *directional, *name)
	'icon' should be the FULL path to the icon (will use the default white arrow if not specified)
	'bigIcon' determines if the icon should use a 32x32 sprite or a 64x64 one
	'directional' determines if the icon should point towards its entity
	'name' is used for finding a specific entry so it can be accessed later (eg. for disabling it manually)
		for example:
		adding an indicator with OffscreenIndicators:AddExtraIndicator(EntityType.ENTITY_GAPER, nil, nil, "gfx/ui/offscreen_icons/default.png", false, true, "test")
		would let you access all the values from this entry with OffscreenIndicators.ExtraIndicators.test
		in this case the available variables would be:
			type = EntityType.ENTITY_GAPER
			icon = "gfx/ui/offscreen_icons/default.png"
			bigIcon = false
			directional = true
			enabled = true (true by default, lets you toggle an indicator with Mod Config Menu for example)
--/////////////////////////////////////////]]--



--[[ Load scripts ]]--
local scriptFolder = "oi_scripts."
include(scriptFolder .. "constants")
include(scriptFolder .. "library")
include(scriptFolder .. "dss.dssmenu")



--[[ Get all indicators to render ]]--
function mod:OnRender()
	-- If "always show" is disabled or enemy indicators are set to "with tab" then check for the map mode
	if mod.Config.AlwaysShow == false or mod.Config.EnemyIndicators == mod.ShowEnemyMode.WithTab then
		-- If EID is enabled then just copy the value from its tab variable
		if EID then
			mod.HoldTabCounter = EID.holdTabCounter
		else
			if mod:IsMapButtonHeld() == true then
				mod.HoldTabCounter = mod.HoldTabCounter + 1
			else
				mod.HoldTabCounter = 0
			end
		end
	end

	-- Check if players are outside of combat for enemy indicators
	if mod.Config.EnemyIndicators == mod.ShowEnemyMode.AfterTime then
		if mod:ArePlayersOutOfCombat() == true then
			mod.OutsideCombatTimer = mod.OutsideCombatTimer + 1
		else
			mod.OutsideCombatTimer = 0
		end
	end


	for _, entity in ipairs(Isaac.GetRoomEntities()) do
		local pos = Isaac.WorldToScreen(entity.Position + entity.PositionOffset)

		-- Only check if entity is off-screen (and not in the Beast fight)
		if (pos.X > Isaac.GetScreenWidth() or pos.X < 0 or pos.Y > Isaac.GetScreenHeight() or pos.Y < 0) and Game():GetRoom():GetBackdropType() ~= BackdropType.DUNGEON_BEAST then
			local extraIndicator = mod:HasExtraIndicator(entity)

			if mod:AreIndicatorsEnabled() == true and (mod:IsValidBoss(entity) == true or mod:IsValidEnemy(entity) == true or mod:IsLudoWeapon(entity) == true or extraIndicator ~= false) then
				-- Margins
				local marginX = mod.Config.MarginX * 8
				local marginY = mod.Config.MarginY * 8
				pos = Vector(math.min(Isaac.GetScreenWidth() - marginX, pos.X), math.min(Isaac.GetScreenHeight() - marginY, pos.Y))
				pos = Vector(math.max(marginX, pos.X), math.max(marginY, pos.Y))


				-- Icon
				local icon = mod.Path .. "default.png"
				local isBig = false
				local rotation = nil

				-- Bosses
				if entity:ToNPC() and entity:ToNPC():IsBoss() then
					-- Enhanced boss bars compatibility
					if HPBars and mod.Config.BossBarsCompat == true then
						-- Mother's Shadow doesn't have its own icon
						if entity.Type == EntityType.ENTITY_MOTHERS_SHADOW then
							icon = mod.Path .. "mothers_shadow.png"
							isBig = true

						-- Dogma's first phase doesn't have a bossbar data entry
						elseif entity.Type == EntityType.ENTITY_DOGMA and entity.Variant == 0 then
							icon = "gfx/ui/bosshp_icons/final/dogma.png"

						else
							-- Adapted from HPBars:updateSprites()
							local bossEntry = mod:GetBossIcon(entity)
							local bossDefinition = HPBars:getBossDefinition(bossEntry.entity)
							icon = HPBars:getIconSprite(bossDefinition, bossEntry, HPBars:getBarStyle(HPBars.Config.EnableSpecificBossbars and bossDefinition.barStyle or bossEntry.barStyle))

							-- Big icons
							if ((entity.Type == EntityType.ENTITY_MEGA_SATAN or entity.Type == EntityType.ENTITY_MEGA_SATAN_2) and entity.Variant == 0) -- Mega Satan
							or (entity.Type == EntityType.ENTITY_DOGMA and entity.Variant == 2) then -- Dogma angel
								isBig = true
							end
						end

					else
						icon = mod.Path .. "boss.png"
					end

				-- Extra indicators
				elseif extraIndicator ~= false then
					if extraIndicator.icon then
						icon = extraIndicator.icon
					end
					if extraIndicator.bigIcon and extraIndicator.bigIcon == true then
						isBig = true
					end

				-- Enemy indicators
				elseif entity:ToNPC() and entity:ToNPC():IsActiveEnemy(false) then
					icon = mod.Path .. "enemy.png"
				end

				-- Ludo / default
				if icon == mod.Path .. "default.png" or icon == mod.Path .. "enemy.png" -- Directional icons
				or (extraIndicator ~= false and extraIndicator.directional and extraIndicator.directional == true) then
					rotation = (Isaac.WorldToScreen(entity.Position + entity.PositionOffset) - pos):GetAngleDegrees()
				end


				-- Scale
				local scale = 1 - (Isaac.WorldToScreen(entity.Position + entity.PositionOffset):Distance(pos) * 0.0015)
				scale = math.max(0.5, scale)
				scale = math.min(1, scale)


				-- Mirror world fix
				if Game():GetRoom():IsMirrorWorld() == true then
					pos = Vector(Isaac.GetScreenWidth() - pos.X, pos.Y)

					if icon == mod.Path .. "default.png" or icon == mod.Path .. "enemy.png" -- Directional icons
					or (extraIndicator ~= false and extraIndicator.directional and extraIndicator.directional == true) then
						local realPos = Isaac.WorldToScreen(entity.Position + entity.PositionOffset)
						rotation = (Vector(Isaac.GetScreenWidth() - realPos.X, realPos.Y) - pos):GetAngleDegrees()
					end
				end

				mod:RenderIndicator(pos, icon, scale, rotation, isBig)
			end
		end
	end
end
mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.OnRender)