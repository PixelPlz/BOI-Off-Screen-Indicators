local mod = OffscreenIndicators

mod.Path = "gfx/ui/offscreen_icons/"



--[[ Indicator mode variables ]]--
mod.HoldTabCounter = 0
mod.OutsideCombatTimer = 0

mod.ShowEnemyMode = {
	Never = 1,
	AfterTime = 2,
	WithTab = 3,
	Always = 4,
}



--[[ Blacklist ]]--
mod.Blacklist = {
	-- Vanilla bosses
	{type = EntityType.ENTITY_LARRYJR, condition = "segmented"},
	{type = EntityType.ENTITY_CHUB, condition = "segmented"},
	{type = EntityType.ENTITY_PIN, condition = "segmented"},
	{type = EntityType.ENTITY_DADDYLONGLEGS, condition = "segmented"},
	{type = EntityType.ENTITY_MAMA_GURDY, variant = 1}, {type = EntityType.ENTITY_MAMA_GURDY, variant = 2}, -- Mama Gurdy's hands
	{type = EntityType.ENTITY_POLYCEPHALUS, variant = 0, condition = {NpcState.STATE_MOVE}}, -- Underground state
	{type = EntityType.ENTITY_MEGA_SATAN, 0, condition = {NpcState.STATE_APPEAR_CUSTOM, NpcState.STATE_SUMMON}}, -- Hidden states
	{type = EntityType.ENTITY_MEGA_SATAN, variant = 1}, {EntityType.ENTITY_MEGA_SATAN, variant = 2}, -- Mega Satan's hands
	{type = EntityType.ENTITY_ULTRA_DOOR},
	{type = EntityType.ENTITY_STAIN, variant = 0, condition = {NpcState.STATE_MOVE}}, -- Underground state
	{type = EntityType.ENTITY_ULTRA_GREED, condition = {9000, 9001}}, -- Dead states
	{type = EntityType.ENTITY_BIG_HORN, variant = 0, condition = {NpcState.STATE_MOVE}}, -- Hidden state
	{type = EntityType.ENTITY_BIG_HORN, variant = 1}, {type = EntityType.ENTITY_BIG_HORN, variant = 2}, -- Big Horn holes
	{type = EntityType.ENTITY_GIDEON},
	{type = EntityType.ENTITY_SCOURGE, variant = 10}, -- Scource tentacles
	{type = EntityType.ENTITY_MOTHER, variant = 30}, -- Mother worm
	{type = EntityType.ENTITY_MOTHER, variant = 100}, -- Mother balls

	-- Fiend Folio bosses since they'll never add them anyways
	{type = 180, variant = 90, condition = "segmented"}, -- Kingpin
	{type = 180, variant = 171}, -- Dusk's arms
	{type = 180, variant = 250}, -- Whisper controller
}



--[[ Extra indicators ]]--
mod.ExtraIndicators = {
	-- Familiars
	RoboBaby2 = {type = EntityType.ENTITY_FAMILIAR, variant = FamiliarVariant.ROBO_BABY_2, 			 subtype = nil, icon = mod.Path .. "robobaby2.png", enabled = true},
	BBFly 	  = {type = EntityType.ENTITY_FAMILIAR, variant = FamiliarVariant.BLUEBABYS_ONLY_FRIEND, subtype = nil, icon = mod.Path .. "bbfly.png",     enabled = true},
	LilDumpy  = {type = EntityType.ENTITY_FAMILIAR, variant = FamiliarVariant.LIL_DUMPY, 			 subtype = nil, icon = mod.Path .. "dumpy.png",     enabled = true},
	Stitches  = {type = EntityType.ENTITY_FAMILIAR, variant = FamiliarVariant.STITCHES, 			 subtype = nil, icon = mod.Path .. "stitches.png",  enabled = true},

	-- Pickups
	GoldenCoin = {type = EntityType.ENTITY_PICKUP, variant = PickupVariant.PICKUP_COIN, subtype = CoinSubType.COIN_GOLDEN, icon = mod.Path .. "coin.png", enabled = true},

	-- Effects
	DeathsList = {type = EntityType.ENTITY_EFFECT, variant = EffectVariant.DEATH_SKULL, subtype = nil, icon = mod.Path .. "skull.png",     enabled = true},
	Purgatory  = {type = EntityType.ENTITY_EFFECT, variant = EffectVariant.PURGATORY, 	subtype = 0,   icon = mod.Path .. "purgatory.png", enabled = true},
}