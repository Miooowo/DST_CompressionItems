-- 一些预设置，防止系统报错
env.RECIPETABS = GLOBAL.RECIPETABS
env.TECH = GLOBAL.TECH

--下行代码只代表查值时自动查global，增加global的变量或者修改global的变量时还是需要带"GLOBAL."
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local TheInput = GLOBAL.TheInput
local require = GLOBAL.require
local Recipe2 = GLOBAL.Recipe2
local Vector3 = GLOBAL.Vector3
io      = GLOBAL.io
assert  = GLOBAL.assert
rawget  = GLOBAL.rawget

local BaseDamge = TUNING.POCKETWATCH_SHADOW_DAMAGE
local DepletedDamge = TUNING.POCKETWATCH_DEPLETED_DAMAGE
local WANDA_DAMAGE = 81.6
GLOBAL.BaseDamge = WANDA_DAMAGE * 40
GLOBAL.DepletedDamge = WANDA_DAMAGE * 32

PrefabFiles = {
	--"sacred_chest",
	"cp_cutgrass",
	"cp_twigs",
	"cp_log",
	"cp_pocketwatch_weapon",
	"cp_slingshot",
	"cp_slingshotammo",
	"cp_flint",
	"cp_boards",
	"cp_torch",
	"cp_bernie_inactive",
	"cp_bernie_active",
	"cp_bernie_big",
	"cp_lighter",
	"cp_goldnugget",
	--"medal_fish",
	--"cp_punchingbag",
}
Assets ={
	Asset("SOUND", "sound/common.fsb"),
	Asset("ATLAS", "images/inventoryimages/8z.xml"),
	Asset("ATLAS", "images/cp_ammo.xml"),
	Asset("IMAGE", "images/cp_ammo.tex"),
	Asset("ATLAS", "images/cp_torch.xml"), 
	--Asset("ATLAS", "images/cp_punchingbag.xml"),
	--Asset("IMAGE", "images/cp_punchingbag.tex"),
	--Asset("IMAGE", "fx/cp_pocketwatch.tex"),
} --载入资源

-- 开导！
modimport("scripts/cp_recipes.lua")
modimport("scripts/cp_containers.lua")
--modimport("scripts/cp_recipes_filter.lua")
--[[
AddComponentPostInit("stackable", function(self)
	self:SetIgnoreMaxSize(true)
	self.SetIgnoreMaxSize = function() end
end)
]]


--[[
health, sanityaura, damage, stacksize, finiteuses, waterproofer, dapperness, sewable
perishable, hungervalue, planardamage, weapondamage, armor, insulator, fueledrate, fueltype and speed
]]
if not GLOBAL.TUNING.dataset then GLOBAL.TUNING.dataset = {} end
GLOBAL.TUNING.dataset.cp_bernie_inactive = { dapperness = 1.2 , sewable = true, insulator = 2400, fueledmax=2400*40, fueledrate=0.33333333333333, fueledtype1="USAGE"}
--GLOBAL.TUNING.dataset.newprefabnameitem2 = { 武器伤害 = 99, 护甲 = 99 }
-- 翻译配置
local language = GetModConfigData("Language")---获取配置
if language == "en" then
	modimport("scripts/language/en.lua")
elseif language == "chs" then
    modimport("scripts/cp_strings.lua")
	--STRINGS.CHARACTERS.WILLOW = require "cp_speech_willow"
end
-- 开局物品
local cpstart = GetModConfigData("CP_START")---获取配置
if cpstart == "true" then
	local function OnPlayerSpawn(src, player)
		player.prev_OnNewSpawn = player.OnNewSpawn
		player.OnNewSpawn = function()
			local start_items = {}

			-- 根据角色名称分配不同的物品
			local character = player.prefab
			if character == "wilson" then
				table.insert(start_items, "cp_torch")
				--table.insert(start_items, "pickaxe")
			elseif character == "willow" then
				table.insert(start_items, "cp_lighter")
				table.insert(start_items, "cp_bernie_inactive")
			--elseif character == "wendy" then
				--table.insert(start_items, "abigail_flower")
			-- 其他角色的物品分配
			-- elseif character == "其他角色名称" then
			--     table.insert(start_items, "相应物品名称")
			end

			-- 添加共同的起始物品
			--table.insert(start_items, "goldnugget")
			--table.insert(start_items, "flint")
			--table.insert(start_items, "rocks")

			-- 将物品生成并添加到玩家背包中
			for _, v in ipairs(start_items) do
				local item = SpawnPrefab(v)
				if item ~= nil then
					player.components.inventory:GiveItem(item)
				end
			end

			-- 调用原始的 OnNewSpawn 方法（如果有的话）
			if player.prev_OnNewSpawn ~= nil then
				player:prev_OnNewSpawn()
				player.prev_OnNewSpawn = nil
			end
		end
	end

	local function ListenForPlayers(inst)
		if GLOBAL.TheWorld.ismastersim then
			inst:ListenForEvent("ms_playerspawn", OnPlayerSpawn)
		end
	end

	AddPrefabPostInit("world", ListenForPlayers)
end


