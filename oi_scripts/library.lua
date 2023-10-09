local mod = OffscreenIndicators



--[[ General functions ]]--
-- Render an indicator
function mod:RenderIndicator(position, icon, scale, rotation, isBig)
	local sprite = Sprite()

	-- Animation
	sprite:Load("gfx/ui/offscreen_icons/icon.anm2", true)
	if isBig == true then
		sprite:Play("Big", true)
	else
		sprite:Play("Default", true)
	end

	-- Icon spritesheet
	if icon then
		sprite:ReplaceSpritesheet(0, icon)

		-- Outline
		if mod.Config.Outline then
			for i = 1, 4 do
				sprite:ReplaceSpritesheet(i, icon)
			end
		end
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
function mod:IsMapButtonHeld()
	for i = 0, Game():GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		if Input.IsActionPressed(ButtonAction.ACTION_MAP, player.ControllerIndex) == true then
			return true
		end
	end
	return false
end


-- Are players out of combat
function mod:ArePlayersOutOfCombat()
	if Isaac.CountEnemies() > 0 and Game():GetRoom():GetEnemyDamageInflicted() <= 0 then
		return true
	end
	return false
end


-- Check if indicators should be enabled or not
function mod:AreIndicatorsEnabled()
	if Game():IsPaused() == false
	and Game():GetHUD():IsVisible() == true
	and (mod.Config.AlwaysShow == true or mod.HoldTabCounter >= 15) then
		return true
	end
	return false
end


-- Check if entity is a valid boss
function mod:IsValidBoss(entity)
	if mod.Config.BossIndicators == true
	and entity:ToNPC() and entity:IsBoss()
	and entity.Visible == true
	and entity.HitPoints >= 0.1
	and mod:OnBlacklist(entity) == false
	and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
		return true
	end
	return false
end

-- Check if entity is a valid enemy
function mod:IsValidEnemy(entity)
	if ((mod.Config.EnemyIndicators == mod.ShowEnemyMode.AfterTime and mod.OutsideCombatTimer >= (30 * 8))
	or (mod.Config.EnemyIndicators == mod.ShowEnemyMode.WithTab and mod.HoldTabCounter >= 15)
	or mod.Config.EnemyIndicators == mod.ShowEnemyMode.Always)
	and entity:ToNPC() and entity:ToNPC():IsActiveEnemy(false)
	and entity.Visible == true
	and entity.HitPoints >= 0.1
	and mod:OnBlacklist(entity) == false
	and entity.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE and entity:IsInvincible() == false
	and entity:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) == false then
		return true
	end
	return false
end


-- Check if entity is from Ludovico Tecnique
function mod:IsLudoWeapon(entity)
	if mod.Config.LudoIndicators
	and ((entity:ToTear() and entity:ToTear():HasTearFlags(TearFlags.TEAR_LUDOVICO))
	or (entity:ToKnife() and entity:ToKnife():HasTearFlags(TearFlags.TEAR_LUDOVICO))
	or (entity:ToLaser() and entity.SubType == LaserSubType.LASER_SUBTYPE_RING_LUDOVICO)) then
		return true
	end
	return false
end


-- Get Enhanced Boss Bars icon (adapted from HPBars:createNewBossBar())
if HPBars then
	function mod:GetBossIcon(entity)
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



--[[ Blacklist functions ]]--
-- Check if the entity is blacklisted or not
function mod:OnBlacklist(entity)
	for i,entry in pairs(mod.Blacklist) do
		if entity.Type == entry.type -- Type
		and (not entry.variant or entity.Variant == entry.variant) -- Variant
		and (not entry.subtype or entity.SubType == entry.subtype) then -- SubType

			-- Extra conditions
			if not entry.condition then
				return true

			-- Segmented
			elseif entry.condition == "segmented" then
				if entity.Parent or (entity.Type == EntityType.ENTITY_DADDYLONGLEGS and entity:ToNPC().State == NpcState.STATE_STOMP and entity.SpawnerEntity) then
					return true
				end

			-- States
			elseif type(entry.condition) == "table" then
				for j,state in pairs(entry.condition) do
					if entity:ToNPC().State == state then
						return true
					end
				end

			-- Custom condition
			elseif type(entry.condition) == "function" then
				return entry.condition(entity)
			end
		end
	end
	return false
end

-- Add blacklist entry
function mod:AddBlacklist(addType, addVariant, addSubType, addCondition)
	table.insert(mod.Blacklist, {type = addType, variant = addVariant, subtype = addSubType, condition = addCondition})
end



--[[ Extra indicator functions ]]--
-- Check if the entity is in the list or not
function mod:HasExtraIndicator(entity)
	for i,entry in pairs(mod.ExtraIndicators) do
		if entity.Type == entry.type -- Type
		and (not entry.variant or entity.Variant == entry.variant) -- Variant
		and (not entry.subtype or entity.SubType == entry.subtype) -- SubType
		and (not entry.enabled or entry.enabled == true) then -- Is enabled
			return entry
		end
	end
	return false
end

-- Add extra indicator
function mod:AddExtraIndicator(addType, addVariant, addSubType, addIcon, isBigIcon, isDirectional, name)
	local data = {type = addType, variant = addVariant, subtype = addSubType, icon = addIcon, bigIcon = isBigIcon, directional = isDirectional, enabled = true}
	if name then
		mod.ExtraIndicators[name] = data
	else
		table.insert(mod.ExtraIndicators, data)
	end
end