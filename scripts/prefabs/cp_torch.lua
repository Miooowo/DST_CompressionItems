local assets =
{
    Asset("ANIM", "anim/cp_torch.zip"),
    Asset("ANIM", "anim/swap_cp_torch.zip"),
    Asset("SOUND", "sound/common.fsb"),
	Asset("ATLAS", "images/cp_torch.xml"),  -- XML文件
	Asset("IMAGE", "images/cp_torch.tex")
}

local prefabs =
{
    "torchfire",
}

local function DoIgniteSound(inst, owner)
	inst._ignitesoundtask = nil
    local se = (owner ~= nil and owner:IsValid() and owner or inst).SoundEmitter
    if se ~= nil then
        se:PlaySound("dontstarve/wilson/torch_swing")
    end
end

local function DoExtinguishSound(inst, owner)
	inst._extinguishsoundtask = nil
    local se = (owner ~= nil and owner:IsValid() and owner or inst).SoundEmitter
    if se ~= nil then
       se:PlaySound("dontstarve/common/fireOut")
    end
end

local function PlayIgniteSound(inst, owner, instant, force)
	if inst._extinguishsoundtask ~= nil then
		inst._extinguishsoundtask:Cancel()
		inst._extinguishsoundtask = nil
		if not force then
			return
		end
	end
	if instant then
		if inst._ignitesoundtask ~= nil then
			inst._ignitesoundtask:Cancel()
		end
		DoIgniteSound(inst, owner)
	elseif inst._ignitesoundtask == nil then
		inst._ignitesoundtask = inst:DoTaskInTime(0, DoIgniteSound, owner)
	end
end

local function PlayExtinguishSound(inst, owner, instant, force)
	if inst._ignitesoundtask ~= nil then
		inst._ignitesoundtask:Cancel()
		inst._ignitesoundtask = nil
		if not force then
			return
		end
	end
	if instant then
		if inst._extinguishsoundtask ~= nil then
			inst._extinguishsoundtask:Cancel()
		end
		DoExtinguishSound(inst, owner)
	elseif inst._extinguishsoundtask == nil then
		inst._extinguishsoundtask = inst:DoTaskInTime(0, DoExtinguishSound, owner)
	end
end

local function OnRemoveEntity(inst)
	--Due to timing of unequip on removal, we may have passed CancelAllPendingTasks already.
	if inst._ignitesoundtask ~= nil then
		inst._ignitesoundtask:Cancel()
		inst._ignitesoundtask = nil
	end
	if inst._extinguishsoundtask ~= nil then
		inst._extinguishsoundtask:Cancel()
		inst._extinguishsoundtask = nil
	end
end

local function applyskillbrightness(inst, value)
    -- 检查物体是否有火焰特效
    if inst.fires then
        -- 遍历所有火焰特效并设置其光照范围
        for i, fx in ipairs(inst.fires) do
            fx:SetLightRange(value)
        end
    end
end


local function applyskillfueleffect(inst, value)
    -- 检查 value 是否不等于 1
    if value ~= 1 then
        -- 如果 value 不等于 1，设置燃料消耗速率修改器
        -- 参数解释：
        -- inst: 需要设置修改器的实例对象
        -- value: 修改燃料消耗速率的倍数
        -- "wilsonskill": 修改器的名称，用于标识这个特定的修改器
        inst.components.fueled.rate_modifiers:SetModifier(inst, value, "wilsonskill")
    else
        -- 如果 value 等于 1，移除名为 "wilsonskill" 的燃料消耗速率修改器
        inst.components.fueled.rate_modifiers:RemoveModifier(inst, "wilsonskill")
    end
end


-- 获取燃料效果修正系数
local function getskillfueleffectmodifier(skilltreeupdater)
    -- 检查是否激活 "wilson_torch_3" 技能，若激活，返回 TUNING.SKILLS.WILSON_TORCH_3
    -- 否则继续检查 "wilson_torch_2" 技能，若激活，返回 TUNING.SKILLS.WILSON_TORCH_2
    -- 否则继续检查 "wilson_torch_1" 技能，若激活，返回 TUNING.SKILLS.WILSON_TORCH_1
    -- 若上述技能均未激活，返回 1
    return (skilltreeupdater:IsActivated("wilson_torch_3") and TUNING.SKILLS.WILSON_TORCH_3)
        or (skilltreeupdater:IsActivated("wilson_torch_2") and TUNING.SKILLS.WILSON_TORCH_2)
        or (skilltreeupdater:IsActivated("wilson_torch_1") and TUNING.SKILLS.WILSON_TORCH_1)
        or 1
end

-- 获取亮度效果修正系数
local function getskillbrightnesseffectmodifier(skilltreeupdater)
    -- 检查是否激活 "wilson_torch_6" 技能，若激活，返回 TUNING.SKILLS.WILSON_TORCH_6
    -- 否则继续检查 "wilson_torch_5" 技能，若激活，返回 TUNING.SKILLS.WILSON_TORCH_5
    -- 否则继续检查 "wilson_torch_4" 技能，若激活，返回 TUNING.SKILLS.WILSON_TORCH_4
    -- 若上述技能均未激活，返回 1
    return (skilltreeupdater:IsActivated("wilson_torch_6") and TUNING.SKILLS.WILSON_TORCH_6)
        or (skilltreeupdater:IsActivated("wilson_torch_5") and TUNING.SKILLS.WILSON_TORCH_5)
        or (skilltreeupdater:IsActivated("wilson_torch_4") and TUNING.SKILLS.WILSON_TORCH_4)
        or 1
end

-- 刷新技能效果
local function RefreshAttunedSkills(inst, owner)
    -- 获取技能树更新器组件
    local skilltreeupdater = owner and owner.components.skilltreeupdater or nil
    if skilltreeupdater then
        -- 根据技能树更新器的状态应用亮度和燃料效果
        applyskillbrightness(inst, getskillbrightnesseffectmodifier(skilltreeupdater))
        applyskillfueleffect(inst, getskillfueleffectmodifier(skilltreeupdater))
    else
        -- 如果没有技能树更新器，恢复默认效果
        applyskillbrightness(inst, 1)
        applyskillfueleffect(inst, 1)
    end
end

-- 监视技能刷新事件
local function WatchSkillRefresh(inst, owner)
    -- 如果之前有监视的 owner，移除事件回调
    if inst._owner then
        inst:RemoveEventCallback("onactivateskill_server", inst._onskillrefresh, inst._owner)
        inst:RemoveEventCallback("ondeactivateskill_server", inst._onskillrefresh, inst._owner)
    end
    -- 更新 owner
    inst._owner = owner
    if owner then
        -- 为新的 owner 添加事件回调
        inst:ListenForEvent("onactivateskill_server", inst._onskillrefresh, owner)
        inst:ListenForEvent("ondeactivateskill_server", inst._onskillrefresh, owner)
    end
end


local function onequip(inst, owner)
    -- 点燃火把
    inst.components.burnable:Ignite()
    
    -- 覆盖携带动画
    owner.AnimState:OverrideSymbol("swap_object", "swap_cp_torch", "swap_cp_torch")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    -- 播放点燃声音
    PlayIgniteSound(inst, owner, true, false)

    -- 添加火焰效果
    if inst.fires == nil then
        inst.fires = {}

        -- 生成火焰效果并附加到所有者
        local fx = SpawnPrefab("torchfire")
        fx.entity:SetParent(owner.entity)
        fx.entity:AddFollower()
        fx.Follower:FollowSymbol(owner.GUID, "swap_object", fx.fx_offset_x or 0, fx.fx_offset, 0)
        fx:AttachLightTo(owner)

        table.insert(inst.fires, fx)
    end

    -- 监视技能刷新事件并刷新技能效果
    WatchSkillRefresh(inst, owner)
    RefreshAttunedSkills(inst, owner)
end


local function onunequip(inst, owner)
    if inst.fires ~= nil then
        for i, fx in ipairs(inst.fires) do
            fx:Remove()
        end
        inst.fires = nil
		PlayExtinguishSound(inst, owner, false, false)
    end

    inst.components.burnable:Extinguish()
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

	WatchSkillRefresh(inst, nil)
	RefreshAttunedSkills(inst, nil)
end

local function onequiptomodel(inst, owner, from_ground)
    if inst.fires ~= nil then
        for i, fx in ipairs(inst.fires) do
            fx:Remove()
        end
        inst.fires = nil
		PlayExtinguishSound(inst, owner, true, false)
    end

    inst.components.burnable:Extinguish()
end

local function onpocket(inst, owner)
	--V2C: I think this is redundant, otherwise it would've needed fire fx cleanup as well
    inst.components.burnable:Extinguish()
end

local function onattack(weapon, attacker, target)
    --target may be killed or removed in combat damage phase
    if target ~= nil and target:IsValid() and target.components.burnable ~= nil and (math.random() < TUNING.TORCH_ATTACK_IGNITE_PERCENT * target.components.burnable.flammability or attacker.components.skilltreeupdater:IsActivated("willow_controlled_burn_1")) then
        target.components.burnable:Ignite(nil, attacker)
    end
end

local function onupdatefueledraining(inst)
    local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil
    local owner_protected = owner ~= nil and (owner.components.sheltered ~= nil and owner.components.sheltered.sheltered or owner.components.rainimmunity ~= nil)
    inst.components.fueled.rate =
        (owner_protected or inst.components.rainimmunity ~= nil) and (inst._fuelratemult or 1) or
        (1 + TUNING.TORCH_RAIN_RATE * TheWorld.state.precipitationrate) * (inst._fuelratemult or 1)
end

local function onisraining(inst, israining)
    if inst.components.fueled ~= nil then
        if israining then
            inst.components.fueled:SetUpdateFn(onupdatefueledraining)
            onupdatefueledraining(inst)
        else
            inst.components.fueled:SetUpdateFn()
            inst.components.fueled.rate = inst._fuelratemult or 1
        end
    end
end

-- 当燃料耗尽时触发的回调函数
local function onfuelchange(newsection, oldsection, inst)
    if newsection <= 0 then
        -- 熄灭燃烧效果
        if inst.components.burnable ~= nil then
            inst.components.burnable:Extinguish()
        end

        -- 获取物品所有者
        local owner = inst.components.inventoryitem ~= nil and inst.components.inventoryitem.owner or nil

        if owner ~= nil then
            local equippable = inst.components.equippable
            if equippable ~= nil and equippable:IsEquipped() then
                -- 构造通告数据
                local data = {
                    prefab = inst.prefab,
                    equipslot = equippable.equipslot,
                    announce = "ANNOUNCE_TORCH_OUT",
                }
                -- 播放熄灭声音并移除物品
                PlayExtinguishSound(inst, owner, true, false)
                inst:Remove() -- 需要在 "itemranout" 事件之前移除以使自动重新装备生效
                -- 触发 "itemranout" 事件
                owner:PushEvent("itemranout", data)
            else
                inst:Remove()
            end
        elseif inst.fires ~= nil then
            -- 逐个移除火焰效果
            for i, fx in ipairs(inst.fires) do
                fx:Remove()
            end
            inst.fires = nil
            -- 播放熄灭声音，设置物品不再持久化和不可点击
            PlayExtinguishSound(inst, nil, true, false)
            inst.persists = false
            inst:AddTag("NOCLICK")
            -- 逐渐使物品消失
            ErodeAway(inst)
        else
            -- 不应该到达这里的情况，直接移除物品
            inst:Remove()
        end
    end
end

local function SetFuelRateMult(inst, mult)
    mult = mult ~= 1 and mult or nil

    if inst._fuelratemult ~= mult then
        inst._fuelratemult = mult
        onisraining(inst, TheWorld.state.israining)
    end
end

local function IgniteTossed(inst)
    -- 点燃物体
	inst.components.burnable:Ignite()

	if inst.fires == nil then
		inst.fires = {}

		-- 生成火焰特效并附加到物体上
		local fx = SpawnPrefab("torchfire")
		fx.entity:SetParent(inst.entity)
		fx.entity:AddFollower()
		fx.Follower:FollowSymbol(inst.GUID, "swap_cp_torch", fx.fx_offset_x or 0, fx.fx_offset, 0)
		fx:AttachLightTo(inst)
		table.insert(inst.fires, fx)
	end

    -- 如果有抛掷者，则应用亮度和燃料效果
    if inst.thrower then
		applyskillbrightness(inst, inst.thrower.brightnessmod or 1)
		applyskillfueleffect(inst, inst.thrower.fuelmod or 1)
    end
end


-- 当被投掷时触发的函数
local function OnThrown(inst, thrower)
    -- 获取投掷者的技能效果修正
    inst.thrower = thrower and thrower.components.skilltreeupdater and {
        fuelmod = getskillfueleffectmodifier(thrower.components.skilltreeupdater),
        brightnessmod = getskillbrightnesseffectmodifier(thrower.components.skilltreeupdater),
    } or nil
    -- 播放动画和音效
    inst.AnimState:PlayAnimation("spin_loop", true)
    inst.SoundEmitter:PlaySound("wilson_rework/torch/torch_spin", "spin_loop")
    PlayIgniteSound(inst, nil, true, true)
    -- 点燃
    IgniteTossed(inst)
    inst.components.inventoryitem.canbepickedup = false
    inst:AddTag("FX") -- 防止被目标选中，类似于 flingo
end

-- 被击中时触发的函数
local function OnHit(inst)
    inst.AnimState:PlayAnimation("land")
    inst.SoundEmitter:KillSound("spin_loop")
    inst.SoundEmitter:PlaySound("wilson_rework/torch/stick_ground")
    inst.components.inventoryitem.canbepickedup = true
    inst:RemoveTag("FX")
end

-- 移除投掷者信息的函数
local function RemoveThrower(inst)
    if inst.thrower then
        -- 如果没有所有者，重置亮度和燃烧效果
        if inst._owner == nil then
            applyskillbrightness(inst, 1)
            applyskillfueleffect(inst, 1)
        end
        inst.thrower = nil
    end
end

-- 放入背包时触发的函数
local function OnPutInInventory(inst, owner)
    -- 移除投掷者信息
    RemoveThrower(inst)
    inst.AnimState:PlayAnimation("idle")

    -- 移除火焰效果和播放熄灭声音
    if inst.fires ~= nil then
        for i, fx in ipairs(inst.fires) do
            fx:Remove()
        end
        inst.fires = nil
        PlayExtinguishSound(inst, owner, false, false)
    end

    -- 熄灭燃烧效果
    inst.components.burnable:Extinguish()
end


local function OnExtinguish(inst)
	--V2C: Handle cases where we're extinguished externally while stuck in ground.
	--     e.g. flingo, waterballoon, icestaff
	--     NOTE: these checks should not pass for any internally handled extinguishes.
	if inst.fires ~= nil and not (inst.components.inventoryitem:IsHeld() or inst.components.fueled:IsEmpty()) then
		for i, fx in ipairs(inst.fires) do
			fx:Remove()
		end
		inst.fires = nil
		PlayExtinguishSound(inst, nil, true, false)
		--shouldn't be possible while spinning, but JUST IN CASE
		if inst:HasTag("activeprojectile") then
			inst.components.complexprojectile:Cancel()
			inst.SoundEmitter:KillSound("spin_loop")
			inst.components.inventoryitem.canbepickedup = true
			inst:RemoveTag("FX")
		end
		inst.AnimState:PlayAnimation("idle")
		local x, y, z = inst.Transform:GetWorldPosition()
		local theta = math.random() * TWOPI
		local speed = math.random()
		inst.Physics:Teleport(x, math.max(.1, y), z)
		inst.Physics:SetVel(speed * math.cos(theta), 8 + math.random(), -speed * math.sin(theta))
	end
end

local function OnSave(inst, data)
	if inst.components.burnable:IsBurning() and not inst.components.inventoryitem:IsHeld() then
		if inst.thrower ~= nil then
			data.thrower = inst.thrower
		else
			data.lit = true
		end
	end
end

local function OnLoad(inst, data)
	if data ~= nil and (data.lit or data.thrower ~= nil) and not inst.components.inventoryitem:IsHeld() then
		inst.AnimState:PlayAnimation("land")
		inst.thrower = data.thrower
		IgniteTossed(inst)
	end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cp_torch")
    inst.AnimState:SetBuild("swap_cp_torch")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("wildfireprotected")

    --lighter (from lighter component) added to pristine state for optimization
    inst:AddTag("lighter")

    --waterproofer (from waterproofer component) added to pristine state for optimization
    inst:AddTag("waterproofer")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

	--projectile (from complexprojectile component) added to pristine state for optimization
	inst:AddTag("projectile")

	--Only get TOSS action via PointSpecialActions
    inst:AddTag("special_action_toss")
	inst:AddTag("keep_equip_toss")

	MakeInventoryFloatable(inst, "med", nil, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.TORCH_DAMAGE*40)
    inst.components.weapon:SetOnAttack(onattack)

    -----------------------------------
    inst:AddComponent("lighter")
    -----------------------------------

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem:SetOnPutInInventoryFn(OnPutInInventory)
	inst.components.inventoryitem:SetOnPickupFn(RemoveThrower)
	inst.components.inventoryitem.imagename = "cp_torch"
	inst.components.inventoryitem.atlasname = "images/cp_torch.xml"

    -----------------------------------

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnPocket(onpocket)
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable:SetOnEquipToModel(onequiptomodel)

	-----------------------------------

	inst:AddComponent("complexprojectile")
	-- 设置抛射物的水平速度为15个单位
	inst.components.complexprojectile:SetHorizontalSpeed(15)
	-- 设置抛射物的重力影响为-35，使其向下移动的速度
	inst.components.complexprojectile:SetGravity(-35)
	-- 设置抛射物的发射偏移量，使其在X轴方向偏移0.25个单位，在Y轴方向偏移1个单位
	inst.components.complexprojectile:SetLaunchOffset(Vector3(.25, 1, 0))
	-- 设置在抛射物发射时调用的回调函数为OnThrown
	inst.components.complexprojectile:SetOnLaunch(OnThrown)
	-- 设置在抛射物命中目标时调用的回调函数为OnHit
	inst.components.complexprojectile:SetOnHit(OnHit)
	-- 将抛射物标记为近战武器
	inst.components.complexprojectile.ismeleeweapon = true


    -----------------------------------

    inst:AddComponent("waterproofer")
    inst.components.waterproofer:SetEffectiveness(TUNING.WATERPROOFNESS_SMALL)

    -----------------------------------

    inst:AddComponent("inspectable")

    -----------------------------------

    inst:AddComponent("burnable")
    inst.components.burnable.canlight = false
    inst.components.burnable.fxprefab = nil
	inst.components.burnable:SetOnExtinguishFn(OnExtinguish)

    -----------------------------------

    inst:AddComponent("fueled")
   -- 设置燃料组件的阶段回调函数为 onfuelchange
   inst.components.fueled:SetSectionCallback(onfuelchange)
   -- 初始化燃料组件的燃料等级为火把的燃料值（TUNING.TORCH_FUEL）
   inst.components.fueled:InitializeFuelLevel(TUNING.TORCH_FUEL*40)
   -- 设置燃料用尽时的回调函数为 inst.Remove（即移除该实例）
   inst.components.fueled:SetDepletedFn(inst.Remove)
   -- 设置燃料组件的初始消耗周期
   -- TUNING.TURNON_FUELED_CONSUMPTION 是燃料组件开启后的初始消耗量
   -- TUNING.TURNON_FULL_FUELED_CONSUMPTION 是燃料组件满燃料时的消耗量
   inst.components.fueled:SetFirstPeriod(TUNING.TURNON_FUELED_CONSUMPTION, TUNING.TURNON_FULL_FUELED_CONSUMPTION)


	inst._onskillrefresh = function(owner) RefreshAttunedSkills(inst, owner) end

    inst:WatchWorldState("israining", onisraining)
    onisraining(inst, TheWorld.state.israining)

    inst._fuelratemult = nil
    inst.SetFuelRateMult = SetFuelRateMult

    MakeHauntableLaunch(inst)

	inst.OnSave = OnSave
	inst.OnLoad = OnLoad
	inst.OnRemoveEntity = OnRemoveEntity

    return inst
end

return Prefab("cp_torch", fn, assets, prefabs)
