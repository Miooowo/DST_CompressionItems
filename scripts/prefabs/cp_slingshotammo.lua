local assets =
{
    Asset("ANIM", "anim/cp_slingshotammo.zip"),
	Asset("ATLAS", "images/cp_ammo.xml"),
	Asset("IMAGE", "images/cp_ammo.tex"),
}


-- temp aggro system for the slingshots
local function no_aggro(attacker, target)
	local targets_target = target.components.combat ~= nil and target.components.combat.target or nil
	return targets_target ~= nil and targets_target:IsValid() and targets_target ~= attacker and attacker ~= nil and attacker:IsValid()
			and (GetTime() - target.components.combat.lastwasattackedbytargettime) < 4
			and (targets_target.components.health ~= nil and not targets_target.components.health:IsDead())
end

local function ImpactFx(inst, attacker, target)
    if target ~= nil and target:IsValid() then
		local impactfx = SpawnPrefab(inst.ammo_def.impactfx)
		impactfx.Transform:SetPosition(target.Transform:GetWorldPosition())
    end
end

local function OnAttack(inst, attacker, target)
	if target ~= nil and target:IsValid() and attacker ~= nil and attacker:IsValid() then
		if inst.ammo_def ~= nil and inst.ammo_def.onhit ~= nil then
			inst.ammo_def.onhit(inst, attacker, target)
		end
		ImpactFx(inst, attacker, target)
	end
end

local function OnPreHit(inst, attacker, target)
    if target ~= nil and target:IsValid() and target.components.combat ~= nil and no_aggro(attacker, target) then
        target.components.combat:SetShouldAvoidAggro(attacker)
	end
end

local function OnHit(inst, attacker, target)
    if target ~= nil and target:IsValid() and target.components.combat ~= nil then
		target.components.combat:RemoveShouldAvoidAggro(attacker)
	end
    inst:Remove()
end

local function NoHoles(pt)
    return not TheWorld.Map:IsPointNearHole(pt)
end

local function SpawnShadowTentacle(inst, attacker, target, pt, starting_angle)
    -- 计算一个可行走的偏移位置
    local offset = FindWalkableOffset(pt, starting_angle, 2, 3, false, true, NoHoles, false, true)
    -- 如果找到一个有效的偏移位置
    if offset ~= nil then
        -- 生成影子触手预制物
        local tentacle = SpawnPrefab("shadowtentacle")
        -- 如果影子触手生成成功
        if tentacle ~= nil then
            -- 设置影子触手的所有者
            tentacle.owner = attacker
            -- 将影子触手放置在计算得到的位置
            tentacle.Transform:SetPosition(pt.x + offset.x, 0, pt.z + offset.z)
            -- 设置影子触手的攻击目标
            tentacle.components.combat:SetTarget(target)
            -- 播放影子触手攻击的声音效果
            tentacle.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shadowTentacleAttack_1")
            tentacle.SoundEmitter:PlaySound("dontstarve/characters/walter/slingshot/shadowTentacleAttack_2")
        end
    end
end


local function OnHit_Thulecite(inst, attacker, target)
    -- 50%的几率触发
    if math.random() < 1.1 then
        local pt
        if target ~= nil and target:IsValid() then
            -- 如果目标存在且有效，获取目标的位置
            pt = target:GetPosition()
        else
            -- 否则，获取弹药自身的位置，并将目标设为nil
            pt = inst:GetPosition()
            target = nil
        end

        -- 随机生成一个角度（以弧度表示）
        local theta = math.random() * 2*40 * PI
        -- 生成一个影子触手（具体实现取决于SpawnShadowTentacle函数）
        SpawnShadowTentacle(inst, attacker, target, pt, theta)
    end

    -- 移除弹药实例
    inst:Remove()
end


local function onloadammo_ice(inst, data)
	if data ~= nil and data.slingshot then
		data.slingshot:AddTag("extinguisher")
	end
end

local function onunloadammo_ice(inst, data)
	if data ~= nil and data.slingshot then
		data.slingshot:RemoveTag("extinguisher")
	end
end

local function OnHit_Ice(inst, attacker, target)
    -- 如果目标有睡眠组件且正在睡觉，则唤醒目标
    if target.components.sleeper ~= nil and target.components.sleeper:IsAsleep() then
        target.components.sleeper:WakeUp()
    end

    -- 如果目标有可燃组件
    if target.components.burnable ~= nil then
        -- 如果目标正在燃烧，则熄灭火焰
        if target.components.burnable:IsBurning() then
            target.components.burnable:Extinguish()
        -- 如果目标正在冒烟，则扑灭火苗
        elseif target.components.burnable:IsSmoldering() then
            target.components.burnable:SmotherSmolder()
        end
    end

    -- 如果目标有冻结组件
    if target.components.freezable ~= nil then
        -- 增加目标的寒冷值
        target.components.freezable:AddColdness(TUNING.SLINGSHOT_AMMO_FREEZE_COLDNESS*40)
        -- 生成破碎效果
        target.components.freezable:SpawnShatterFX()
    else
        -- 如果目标没有冻结组件，生成破碎效果
        local fx = SpawnPrefab("shatter")
        fx.Transform:SetPosition(target.Transform:GetWorldPosition())
        fx.components.shatterfx:SetLevel(2)
    end

    -- 如果目标有战斗组件且不在攻击者的免疫列表中，则建议目标攻击攻击者
    if not no_aggro(attacker, target) and target.components.combat ~= nil then
        target.components.combat:SuggestTarget(attacker)
    end

    -- 移除投射物实例
    inst:Remove()
end


local function OnHit_Speed(inst, attacker, target)
    -- 定义减益的键名，使用弹药的 prefab 名称作为键
    local debuffkey = inst.prefab

    -- 如果目标存在且有效，并且目标具有 locomotor 组件
    if target ~= nil and target:IsValid() and target.components.locomotor ~= nil then
        -- 如果目标已经有一个速度减益任务，则取消它
        if target._slingshot_speedmulttask ~= nil then
            target._slingshot_speedmulttask:Cancel()
        end
        
        -- 设置一个新的任务，在 TUNING.SLINGSHOT_AMMO_MOVESPEED_DURATION 时间后移除速度减益
        target._slingshot_speedmulttask = target:DoTaskInTime(TUNING.SLINGSHOT_AMMO_MOVESPEED_DURATION*40, function(i) 
            i.components.locomotor:RemoveExternalSpeedMultiplier(i, debuffkey) 
            i._slingshot_speedmulttask = nil 
        end)

        -- 为目标施加速度减益
        target.components.locomotor:SetExternalSpeedMultiplier(target, debuffkey, TUNING.SLINGSHOT_AMMO_MOVESPEED_MULT/40)
    end

    -- 移除弹药实例
    inst:Remove()
end


local function OnHit_Distraction(inst, attacker, target)
    -- 检查目标是否存在且有效，并且目标具有 combat 组件
    if target ~= nil and target:IsValid() and target.components.combat ~= nil then
        -- 获取目标的当前攻击目标
        local targets_target = target.components.combat.target
        -- 检查目标的当前攻击目标是否为空或是攻击者
        if targets_target == nil or targets_target == attacker then
            -- 使目标避免攻击攻击者
            target.components.combat:SetShouldAvoidAggro(attacker)
            -- 触发目标被攻击的事件，但不造成伤害
            target:PushEvent("attacked", { attacker = attacker, damage = 0, weapon = inst })
            -- 移除避免攻击攻击者的标志
            target.components.combat:RemoveShouldAvoidAggro(attacker)

            -- 如果目标不是“epic”类型，则丢弃当前攻击目标
            --if not target:HasTag("epic") then
                target.components.combat:DropTarget()
            --end
        end
    end

    -- 移除弹药实例
    inst:Remove()
end


local function OnMiss(inst, owner, target)
    inst:Remove()
end

local function projectile_fn(ammo_def)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    inst.Transform:SetFourFaced()

    MakeProjectilePhysics(inst)

    inst.AnimState:SetBank("slingshotammo")
    inst.AnimState:SetBuild("slingshotammo")
    inst.AnimState:PlayAnimation("spin_loop", true)
	if ammo_def.symbol ~= nil then
		inst.AnimState:OverrideSymbol("rock", "slingshotammo", ammo_def.symbol)
	end

    --projectile (from projectile component) added to pristine state for optimization
    inst:AddTag("projectile")

	if ammo_def.tags then
		for _, tag in pairs(ammo_def.tags) do
			inst:AddTag(tag)
		end
	end

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.persists = false

	inst.ammo_def = ammo_def

	inst:AddComponent("weapon")
	inst.components.weapon:SetDamage(ammo_def.damage)
	inst.components.weapon:SetOnAttack(OnAttack)


    -- 添加投射物组件
    inst:AddComponent("projectile")
    -- 设置投射物的飞行速度
    inst.components.projectile:SetSpeed(25*40)
    -- 设置投射物是否自动追踪目标
    inst.components.projectile:SetHoming(true)
    -- 设置命中距离
    inst.components.projectile:SetHitDist(1.5)
    -- 设置命中前的回调函数
    inst.components.projectile:SetOnPreHitFn(OnPreHit)
    -- 设置命中的回调函数
    inst.components.projectile:SetOnHitFn(OnHit)
    -- 设置未命中的回调函数
    inst.components.projectile:SetOnMissFn(OnMiss)
    -- 设置投射物的射程
    inst.components.projectile.range = 400
    -- 标记投射物具有独立设置的伤害
    inst.components.projectile.has_damage_set = true

    return inst
end

local function inv_fn(ammo_def)
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("slingshotammo")
    inst.AnimState:SetBuild("slingshotammo")
    inst.AnimState:PlayAnimation("idle")
	if ammo_def.symbol ~= nil then
		inst.AnimState:OverrideSymbol("rock", "slingshotammo", ammo_def.symbol)
        inst.scrapbook_overridedata = {"rock", "slingshotammo", ammo_def.symbol}
	end

    inst:AddTag("molebait")
	inst:AddTag("slingshotammo")
	inst:AddTag("reloaditem_ammo")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("reloaditem")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 1
    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
	inst.components.inventoryitem.imagename = ammo_def.texture -- 使用 ammo_def.texture
	inst.components.inventoryitem.atlasname = "images/cp_ammo.xml"

    inst:AddComponent("bait")
    MakeHauntableLaunch(inst)

	if ammo_def.fuelvalue ~= nil then
		inst:AddComponent("fuel")
		inst.components.fuel.fuelvalue = ammo_def.fuelvalue
	end

	if ammo_def.onloadammo ~= nil and ammo_def.onunloadammo ~= nil then
		inst:ListenForEvent("ammoloaded", ammo_def.onloadammo)
		inst:ListenForEvent("ammounloaded", ammo_def.onunloadammo)
		inst:ListenForEvent("onremove", ammo_def.onunloadammo)
	end

    return inst
end
-- NOTE(DiogoW): Add an entry to SCRAPBOOK_DEPS table in prefabs/slingshot.lua when adding a new ammo.
local ammo =
{
	{
		name = "cp_slingshotammo_rock",
		damage = TUNING.SLINGSHOT_AMMO_DAMAGE_ROCKS*40,
		texture = "cp_slingshotammo_rock",  -- 从 XML 文件中读取
		description = "只是压缩石子弹",
	},
    {
        name = "cp_slingshotammo_gold",
		symbol = "gold",
        damage = TUNING.SLINGSHOT_AMMO_DAMAGE_GOLD*40,
		texture = "cp_slingshotammo_gold",  -- 从 XML 文件中读取
		description = "只是压缩金子弹",
    },
	{
		name = "cp_slingshotammo_marble",
		symbol = "marble",
		damage = TUNING.SLINGSHOT_AMMO_DAMAGE_MARBLE*40,
		texture = "cp_slingshotammo_marble",  -- 从 XML 文件中读取
		description = "只是伤害翻40倍的大理石弹",
	},
	{
		name = "cp_slingshotammo_thulecite", -- chance to spawn a Shadow Tentacle
		symbol = "thulecite",
		onhit = OnHit_Thulecite,
		damage = TUNING.SLINGSHOT_AMMO_DAMAGE_THULECITE*40,
		texture = "cp_slingshotammo_thulecite",  -- 从 XML 文件中读取
		description = "极高概率生成暗影触手",
	},
    {
        name = "cp_slingshotammo_freeze",
		symbol = "freeze",
        onhit = OnHit_Ice,
		tags = { "extinguisher" },
		onloadammo = onloadammo_ice,
		onunloadammo = onunloadammo_ice,
        damage = nil,
		texture = "cp_slingshotammo_freeze",  -- 从 XML 文件中读取
		description = "美丽冻人",
    },
    {
        name = "cp_slingshotammo_slow",
		symbol = "slow",
        onhit = OnHit_Speed,
        damage = TUNING.SLINGSHOT_AMMO_DAMAGE_SLOW*40,
		texture = "cp_slingshotammo_slow",
		description = "让敌人和“闪电”一样“快”",
    },
    {
        name = "cp_slingshotammo_poop", -- distraction (drop target, note: hostile creatures will probably retarget you very shortly after)
		symbol = "poop",
        onhit = OnHit_Distraction,
        damage = nil,
		fuelvalue = (TUNING.MED_FUEL / 10)*40, -- 1/10th the value of using poop
		texture = "cp_slingshotammo_poop",  -- 从 XML 文件中读取
		description = "使Boss丢失仇恨",
    },
    {
        name = "cp_trinket_1",
		symbol = "trinket_1",
		damage = TUNING.SLINGSHOT_AMMO_DAMAGE_TRINKET_1*40,
		texture = "cp_trinket_1",  -- 从 XML 文件中读取
		description = "小饰品弹",
    },
}

local ammo_prefabs = {}
for _, v in ipairs(ammo) do
	v.impactfx = "slingshotammo_hitfx_" .. (v.symbol or "rock")

	---
	if not v.no_inv_item then
		table.insert(ammo_prefabs, Prefab(v.name, function() return inv_fn(v) end, assets))
	end
	local prefabs =
	{
		"shatter",
	}
	table.insert(prefabs, v.impactfx)
	table.insert(ammo_prefabs, Prefab(v.name.."_proj", function() return projectile_fn(v) end, assets, prefabs))
end

return unpack(ammo_prefabs)

