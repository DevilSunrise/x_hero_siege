require('libraries/timers')

function SpecialEventTPDisabled(event)
local hero = event.activator
local msg = "This section will be activated after Muradin Event! (14 Minutes)"
	Notifications:Bottom(hero:GetPlayerOwnerID(), {text = msg, duration = 6.0})
end

function SpecialEventTPEnabled(event)
local hero = event.activator
local point = Entities:FindByName(nil, "event_tp_fix"):GetAbsOrigin()
if PlayerResource:GetConnectionState(hero:GetPlayerID()) ~= 2 then return end

	CustomGameEventManager:Send_ServerToPlayer(hero:GetPlayerOwner(), "show_events", {})
	Entities:FindByName(nil, "trigger_special_event"):Disable()
	TeleportHero(hero, 0.0, point)
	hero:AddNewModifier(nil, nil, "modifier_boss_stun", {IsHidden = true})
	hero:AddNewModifier(nil, nil, "modifier_invulnerable", {IsHidden = true})
end

function HeroImageBack(event)
local hero = event.activator

	SpecialEventBack(event)
	Timers:RemoveTimer(timers.HeroImage)
	GameMode.HeroImage_occuring = 0

	if GameMode.HeroImage:IsAlive() then
		UTIL_Remove(GameMode.HeroImage)
	end
	hero.hero_image = true
	Notifications:Bottom(hero:GetPlayerOwnerID(), {text = "You can do this event only 1 time!", duration = 5.0})
	CustomGameEventManager:Send_ServerToAllClients("hide_timer_hero_image", {})
end

function HeroImageDead(event)
local caster = event.caster
local point_beast = Entities:FindByName(nil, "hero_image_boss"):GetAbsOrigin()

	if caster:GetHealth() == 0 then
		CustomGameEventManager:Send_ServerToAllClients("hide_timer_hero_image", {})
		Timers:CreateTimer(0.5, function()
			local item = CreateItem("item_tome_big", nil, nil)
			local pos = point_beast
			local drop = CreateItemOnPositionSync( pos, item )
			local pos_launch = pos + RandomVector(RandomFloat(150, 200))
			item:LaunchLoot(false, 300, 0.5, pos)
		end)
	end
end

function SpecialEventBack(event)
local caller = event.caller
local hero = event.activator

	if hero:GetTeamNumber() == 2 then
		TeleportHero(hero, 0.0, base_good:GetAbsOrigin())
	elseif hero:GetTeamNumber() == 3 then
		TeleportHero(hero, 0.0, base_bad:GetAbsOrigin())
	end

	Entities:FindByName(nil, "trigger_special_event"):Enable()

	if caller:GetName() == "trigger_hero_image_duration" then
		CustomGameEventManager:Send_ServerToAllClients("hide_timer_hero_image", {})
	elseif caller:GetName() == "trigger_spirit_beast_duration" then
		CustomGameEventManager:Send_ServerToAllClients("hide_timer_spirit_beast", {})
	elseif caller:GetName() == "trigger_frost_infernal_duration" then
		CustomGameEventManager:Send_ServerToAllClients("hide_timer_frost_infernal", {})
	elseif caller:GetName() == "trigger_all_hero_image_duration" then
		CustomGameEventManager:Send_ServerToAllClients("hide_timer_all_hero_image", {})
	end
end

function SpiritBeastBack(event)
local hero = event.activator

	SpecialEventBack(event)
	Timers:RemoveTimer(timers.SpiritBeast)
	GameMode.SpiritBeast_occuring = 0

	if not GameMode.spirit_beast:IsNull() then
		GameMode.spirit_beast:RemoveSelf()
	end
	CustomGameEventManager:Send_ServerToAllClients("hide_timer_spirit_beast", {})
end

function SpiritBeastDead(event)
local hero = event.activator

	DoEntFire("trigger_spirit_beast_duration", "Kill", nil ,0 ,nil ,nil)
	GameMode.SpiritBeast_killed = 1
	CustomGameEventManager:Send_ServerToAllClients("hide_timer_spirit_beast", {})
	Timers:CreateTimer(0.5, function()
		local item = CreateItem("item_shield_of_invincibility", nil, nil)
		local pos = GameMode.spirit_beast:GetAbsOrigin()
		local drop = CreateItemOnPositionSync( pos, item )
		local pos_launch = pos + RandomVector(RandomFloat(150, 200))
		item:LaunchLoot(false, 300, 0.5, pos)
	end)
end

function FrostInfernalBack(event)
local hero = event.activator

	SpecialEventBack(event)
	Timers:RemoveTimer(timers.FrostInfernal)
	GameMode.FrostInfernal_occuring = 0

	if not GameMode.frost_infernal:IsNull() then
		GameMode.frost_infernal:RemoveSelf()
	end
	CustomGameEventManager:Send_ServerToAllClients("hide_timer_frost_infernal", {})
end

function FrostInfernalDead(event)
local hero = event.activator

	DoEntFire("trigger_frost_infernal_duration", "Kill", nil ,0 ,nil ,nil)
	GameMode.FrostInfernal_killed = 1
	CustomGameEventManager:Send_ServerToAllClients("hide_timer_frost_infernal", {})
	Timers:CreateTimer(0.5,function ()
		local item = CreateItem("item_key_of_the_three_moons", nil, nil)
		local pos = GameMode.frost_infernal:GetAbsOrigin()
		local drop = CreateItemOnPositionSync( pos, item )
		local pos_launch = pos+RandomVector(RandomFloat(150,200))
		item:LaunchLoot(false, 300, 0.5, pos)
	end)
end

function AllHeroImageBack(event)
local hero = event.activator
local point = Entities:FindByName(nil, "all_hero_image_player"):GetAbsOrigin()
if timers.AllHeroImage then Timers:RemoveTimer(timers.AllHeroImage) end
if timers.AllHeroImage2 then Timers:RemoveTimer(timers.AllHeroImage2) end

	CustomGameEventManager:Send_ServerToAllClients("hide_timer_all_hero_image", {})
	GameMode.AllHeroImages_occuring = 0
	SpecialEventBack(event)

	local units = FindUnitsInRadius(DOTA_TEAM_CUSTOM_2, point, nil, 2500, DOTA_UNIT_TARGET_TEAM_FRIENDLY, DOTA_UNIT_TARGET_ALL, DOTA_UNIT_TARGET_FLAG_INVULNERABLE , FIND_ANY_ORDER, false)
	for _, v in pairs(units) do
		UTIL_Remove(v)
	end
end
