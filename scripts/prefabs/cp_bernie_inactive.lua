--Inventory item version

local commonfn =  require "prefabs/cp_bernie_common"
local assets =
{
    Asset("ANIM", "anim/cp_bernie.zip"),
    Asset("ANIM", "anim/cp_bernie_build.zip"),
	Asset("ATLAS", "images/cp_bernie_inactive.xml"),  -- XML文件
	Asset("IMAGE", "images/cp_bernie_inactive.tex"),
    Asset("INV_IMAGE", "images/cp_bernie_dead.xml"),
	Asset("MINIMAP_IMAGE", "minimap/cp_bernie.png"),
    Asset("SCRIPT", "scripts/prefabs/cp_bernie_common.lua"),
}

local prefabs =
{
    "cp_bernie_active",
    "beardhair",
    "beefalowool",
    "silk",
    "small_puff",
}

local function getstatus(inst)
    return inst.components.fueled:IsEmpty() and "BROKEN" or nil
end

--------------------------------------------------------------------------

local function dodecay(inst)
    if inst.components.lootdropper == nil then
        inst:AddComponent("lootdropper")
    end
    inst.components.lootdropper:SpawnLootPrefab("beardhair")
    inst.components.lootdropper:SpawnLootPrefab("beefalowool")
    inst.components.lootdropper:SpawnLootPrefab("silk")
    SpawnPrefab("small_puff").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function startdecay(inst)
    if inst._decaytask == nil then
        inst._decaytask = inst:DoTaskInTime(TUNING.BERNIE_DECAY_TIME, dodecay)
    end
end

local function stopdecay(inst)
    if inst._decaytask ~= nil then
        inst._decaytask:Cancel()
        inst._decaytask = nil
    end
end

local function onsave(inst, data)
    if inst._decaytask ~= nil then
        local time = TUNING.BERNIE_DECAY_TIME - GetTaskRemaining(inst._decaytask)
        data.decaytime = time > 0 and time or nil
    end
end

local function onload(inst, data)
    if inst._decaytask ~= nil and data ~= nil and data.decaytime ~= nil then
        local remaining = math.max(0, TUNING.BERNIE_DECAY_TIME - data.decaytime)
        inst._decaytask:Cancel()
        inst._decaytask = inst:DoTaskInTime(remaining, dodecay)
    end
end

--------------------------------------------------------------------------

-- 尝试重新激活函数
local function tryreanimate(inst)
    local target = nil  -- 用于存储符合条件的目标玩家
    local rangesq = 256 -- 最大搜索范围的平方（16 * 16 = 256）
    
    -- 获取当前实体的位置
    local x, y, z = inst.Transform:GetWorldPosition()
    
    -- 遍历所有玩家
    for i, v in ipairs(AllPlayers) do
        -- 如果玩家符合条件（leader疯狂或者hotheaded）并且可见
        if (commonfn.isleadercrazy(inst, v) or inst:hotheaded(v)) and v.entity:IsVisible() then
            -- 计算玩家到当前实体的距离的平方
            local distsq = v:GetDistanceSqToPoint(x, y, z)
            -- 如果玩家在当前范围内，并且距离小于当前最小距离
            if distsq < rangesq then
                rangesq = distsq -- 更新最小距离
                target = v -- 更新目标玩家
            end
        end
    end
    
    -- 如果找到符合条件的目标玩家
    if target ~= nil then
        -- 获取当前实体的皮肤名称
        local skin_name = inst:GetSkinName()
        if skin_name ~= nil then
            -- 去掉皮肤名称中的特定后缀并添加 "_active"
            skin_name = skin_name:gsub("_shadow_build", ""):gsub("_lunar_build", "") .. "_active"
        end
        -- 生成新的活跃实体
        local active = SpawnPrefab("cp_bernie_active", skin_name, inst.skin_id, nil)
        if active ~= nil then
            -- 将燃料百分比转换为健康值
            active.components.health:SetPercent(inst.components.fueled:GetPercent())
            -- 设置新实体的位置和旋转
            active.Transform:SetPosition(inst.Transform:GetWorldPosition())
            active.Transform:SetRotation(inst.Transform:GetRotation())
            -- 获取并设置计时器剩余时间
            local bigcd = inst.components.timer:GetTimeLeft("transform_cd")
            if bigcd ~= nil then
                active.components.timer:StartTimer("transform_cd", bigcd)
            end
            -- 移除当前实体
            inst:Remove()
        end
    end
end


local function activate(inst)
    if inst._activatetask == nil then
        inst._activatetask = inst:DoPeriodicTask(1, tryreanimate)
    end
end

local function deactivate(inst)
    if inst._activatetask ~= nil then
        inst._activatetask:Cancel()
        inst._activatetask = nil
    end
end

local function bernie_swap_object_helper(owner, skin_build, symbol, guid)
    if skin_build ~= nil then
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, symbol, guid, "cp_bernie_build")
        owner.AnimState:OverrideItemSkinSymbol("swap_object_bernie", skin_build, symbol.."_idle_willow", guid, "cp_bernie_build")
    else
        owner.AnimState:OverrideSymbol("swap_object", "cp_bernie_build", symbol)
        owner.AnimState:OverrideSymbol("swap_object_bernie", "cp_bernie_build", symbol.."_idle_willow")
    end
end

-- 处理燃料变化的函数
local function onfuelchange(section, oldsection, inst)
    -- 检查燃料是否耗尽
    if inst.components.fueled:IsEmpty() then
        -- 如果当前不是“死亡”状态
        if not inst._isdeadstate then
            inst._isdeadstate = true -- 设置为“死亡”状态
            inst.components.equippable.dapperness = 0 -- 设置精神提升为0
            inst.components.insulator:SetInsulation(0) -- 设置绝缘效果为0
            inst.AnimState:PlayAnimation("dead_loop") -- 播放死亡动画
            
            -- 设置图像前缀名称
            local prefix_name = "bernie"
            if inst:GetSkinName() ~= nil then
                prefix_name = inst:GetSkinName()
            end
            -- 改变图像为“死亡”状态图像
            inst.components.inventoryitem:ChangeImageName(prefix_name .. "_dead")
            inst.components.inventoryitem.imagename = "cp_bernie_dead"
            inst.components.inventoryitem.atlasname = "images/cp_bernie_dead.xml"
            -- 如果实体没有被持有
            if not inst.components.inventoryitem:IsHeld() then
                deactivate(inst) -- 停用实体
                startdecay(inst) -- 开始衰减
            -- 如果实体正在装备
            elseif inst.components.equippable:IsEquipped() then
                bernie_swap_object_helper(inst.components.inventoryitem.owner, inst:GetSkinBuild(), "swap_bernie_dead", inst.GUID) -- 更新装备图像
            end
        end
    -- 如果燃料未耗尽且当前是“死亡”状态
    elseif inst._isdeadstate then
        inst._isdeadstate = nil -- 取消“死亡”状态
        inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL * 40 -- 恢复精神提升
        inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL*40) -- 恢复绝缘效果
        inst.AnimState:PlayAnimation("inactive") -- 播放非活跃动画
        inst.components.inventoryitem:ChangeImageName(inst:GetSkinName()) -- 恢复正常图像
        
        -- 如果实体没有被持有
        if not inst.components.inventoryitem:IsHeld() then
            stopdecay(inst) -- 停止衰减
            -- 如果实体处于唤醒状态
            if inst.entity:IsAwake() then
                activate(inst) -- 激活实体
            end
        -- 如果实体正在装备
        elseif inst.components.equippable:IsEquipped() then
            bernie_swap_object_helper(inst.components.inventoryitem.owner, inst:GetSkinBuild(), "swap_bernie", inst.GUID) -- 更新装备图像
            inst.components.fueled:StartConsuming() -- 开始消耗燃料
        end
    end
end


local function topocket(inst, owner)
    stopdecay(inst)
    deactivate(inst)
end

local function toground(inst)
    if inst.components.fueled:IsEmpty() then
        startdecay(inst)
    elseif inst.entity:IsAwake() then
        activate(inst)
    end
end

local function onentitywake(inst)
    if not (inst.components.inventoryitem:IsHeld() or inst.components.fueled:IsEmpty()) then
        activate(inst)
    end
end

--------------------------------------------------------------------------

local function OnEquip(inst, owner)
    if inst:GetSkinBuild() ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
    end

    if inst.components.fueled:IsEmpty() then
        bernie_swap_object_helper(owner, inst:GetSkinBuild(), "swap_bernie_dead", inst.GUID)
    else
        bernie_swap_object_helper(owner, inst:GetSkinBuild(), "swap_bernie", inst.GUID)
        inst.components.fueled:StartConsuming()
    end

    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst._lastowner ~= owner then
        if inst._lastowner ~= nil then
            inst:RemoveEventCallback("onattackother", inst._onattackother, inst._lastowner)
        end
        inst._lastowner = owner
        inst:ListenForEvent("onattackother", inst._onattackother, owner)
    end
end

local function OnUnequip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")

    inst.components.fueled:StopConsuming()

    if inst._lastowner ~= nil then
        inst:RemoveEventCallback("onattackother", inst._onattackother, inst._lastowner)
        inst._lastowner = nil
    end
end

local function OnEquipToModel(inst, owner, from_ground)
    inst.components.fueled:StopConsuming()

    if inst._lastowner ~= nil then
        inst:RemoveEventCallback("onattackother", inst._onattackother, inst._lastowner)
        inst._lastowner = nil
    end
end

--------------------------------------------------------------------------

-- 定义创建实体的函数
local function fn()
    local inst = CreateEntity()  -- 创建实体

    -- 为实体添加必要的组件
    inst.entity:AddTransform()  -- 添加位置、旋转、缩放组件
    inst.entity:AddAnimState()  -- 添加动画状态组件
    inst.entity:AddDynamicShadow()  -- 添加动态阴影组件
    inst.entity:AddMiniMapEntity()  -- 添加小地图实体组件
    inst.entity:AddNetwork()  -- 添加网络组件，使实体能够在客户端和服务器之间同步

    MakeInventoryPhysics(inst)  -- 设置实体的物理属性，使其行为类似于库存物品

    inst.DynamicShadow:SetSize(1, .5)  -- 设置动态阴影的大小

    -- 设置动画状态
    inst.AnimState:SetBank("bernie")
    inst.AnimState:SetBuild("bernie_build")
    inst.AnimState:PlayAnimation("inactive")
    inst.scrapbook_anim = "inactive"

    inst.MiniMapEntity:SetIcon("minimap/cp_bernie.png")  -- 设置小地图图标

    inst:AddTag("nopunch")  -- 添加标签，使实体无法被拳击

    inst.entity:SetPristine()  -- 设置实体的初始状态

    -- 如果当前世界不是主服务器，则返回实体
    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_specialinfo = "CP_BERNIE"  -- 设置特别信息

    inst._isdeadstate = nil  -- 初始化“死亡”状态
    inst._decaytask = nil  -- 初始化衰减任务
    inst._activatetask = nil  -- 初始化激活任务

    -- 添加可检查组件
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = getstatus
	
    -- 添加库存物品组件
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(false)  -- 设置为不可下沉物品
	inst.components.inventoryitem.imagename = "cp_bernie_inactive"
	inst.components.inventoryitem.atlasname = "images/cp_bernie_inactive.xml"
	

    -- 添加可装备组件
    inst:AddComponent("equippable")
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL * 40  -- 设置精神提升
    inst.components.equippable.restrictedtag = "bernieowner"  -- 限制装备标签
    inst.components.equippable:SetOnEquip(OnEquip)  -- 设置装备时的回调函数
    inst.components.equippable:SetOnUnequip(OnUnequip)  -- 设置卸装备时的回调函数
    inst.components.equippable:SetOnEquipToModel(OnEquipToModel)  -- 设置装备到模型时的回调函数

    -- 添加保暖组件
    inst:AddComponent("insulator")
    inst.components.insulator:SetInsulation(TUNING.INSULATION_SMALL*40)  -- 设置保暖值

    -- 添加燃料组件
    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = FUELTYPE.USAGE  -- 设置燃料类型
    inst.components.fueled.rate = TUNING.BERNIE_FUEL_RATE  -- 设置燃料消耗速率
    inst.components.fueled:InitializeFuelLevel(TUNING.BERNIE_FUEL*40)  -- 初始化燃料水平
    inst.components.fueled:SetSectionCallback(onfuelchange)  -- 设置燃料变化的回调函数

    inst:AddComponent("timer")  -- 添加计时器组件

    -- 添加事件监听器
    inst:ListenForEvent("onputininventory", topocket)
    inst:ListenForEvent("ondropped", toground)
    toground(inst)  -- 设置初始状态为在地面上

    MakeHauntableLaunch(inst)  -- 使实体可被惊吓并被扔出

    -- 设置实体睡眠和唤醒时的行为
    inst.OnEntitySleep = deactivate
    inst.OnEntityWake = onentitywake

    -- 设置热头行为
    inst.hotheaded = commonfn.hotheaded
    inst.isleadercrazy = commonfn.isleadercrazy

    -- 设置保存和加载函数
    inst.OnLoad = onload
    inst.OnSave = onsave

    -- 定义攻击其他实体时的行为
    inst._onattackother = function(attacker)
        if not (attacker.components.rider ~= nil and attacker.components.rider:IsRiding() or inst.components.fueled:IsEmpty()) then
            inst.components.fueled:DoDelta(-.01/40 * TUNING.BERNIE_FUEL)
        end
    end

    return inst  -- 返回实体
end


return Prefab("cp_bernie_inactive", fn, assets, prefabs)
