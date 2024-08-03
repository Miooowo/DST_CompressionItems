local commonfn =  require "prefabs/cp_bernie_common"
local brain = require("brains/berniebrain")

local assets =
{
    Asset("ANIM", "anim/cp_bernie.zip"),
    Asset("ANIM", "anim/cp_bernie_build.zip"),
    Asset("SOUND", "sound/together.fsb"),
	Asset("MINIMAP_IMAGE", "minimap/cp_bernie"),
    Asset("SCRIPT", "scripts/prefabs/cp_bernie_common.lua"),
}

local prefabs =
{
    "cp_bernie_inactive",
    "cp_bernie_big",
}

local function goinactive(inst)
    local skin_name = inst:GetSkinName()
    if skin_name ~= nil then
        skin_name = skin_name:gsub("_shadow_build", ""):gsub("_lunar_build", ""):gsub("_active", "")
    end

    local inactive = SpawnPrefab("cp_bernie_inactive", skin_name, inst.skin_id, nil)
    if inactive ~= nil then
        --Transform health % into fuel.
        inactive.components.fueled:SetPercent(inst.components.health:GetPercent())
        inactive.Transform:SetPosition(inst.Transform:GetWorldPosition())
        inactive.Transform:SetRotation(inst.Transform:GetRotation())
        local bigcd = inst.components.timer:GetTimeLeft("transform_cd")
        if bigcd ~= nil then
            inactive.components.timer:StartTimer("transform_cd", bigcd)
        end
        inst:Remove()
        return inactive
    end
end

local function gobig(inst,leader)

    if leader.bigbernies then
        return
    end

    local skin_name = inst:GetSkinName()
    if skin_name ~= nil then
        skin_name = skin_name:gsub("_shadow_build", ""):gsub("_lunar_build", ""):gsub("_active", "_big")
    end

    local big = SpawnPrefab("cp_bernie_big", skin_name, inst.skin_id, nil)
    if big ~= nil then
        --Rescale health %
        if not leader.bigbernies then
            leader.bigbernies = {}
        end

        leader.bigbernies[big] = true
        
        big.Transform:SetPosition(inst.Transform:GetWorldPosition())
        big.Transform:SetRotation(inst.Transform:GetRotation())
        big.components.health:SetPercent(inst.components.health:GetPercent())

        big:onLeaderChanged(leader)

        inst:Remove()

        big:CheckForAllegiances(leader)

        return big
    end
end

local function onpickup(inst, owner)
    local inactive = goinactive(inst)
    if inactive ~= nil then
        owner.components.inventory:GiveItem(inactive, nil, owner:GetPosition())
    end
    return true
end

local function OnSleepTask(inst)
    inst._sleeptask = nil
    inst:GoInactive()
end

local function OnEntitySleep(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask = inst:DoTaskInTime(.5, OnSleepTask)
    end
end

local function OnEntityWake(inst)
    if inst._sleeptask ~= nil then
        inst._sleeptask:Cancel()
        inst._sleeptask = nil
    end
end

local function fn()
    -- 创建一个新的实体
    local inst = CreateEntity()

    -- 添加各个组件到实体
    inst.entity:AddTransform() -- 允许实体在世界中进行位置变换
    inst.entity:AddAnimState() -- 允许实体播放动画
    inst.entity:AddSoundEmitter() -- 允许实体发出声音
    inst.entity:AddDynamicShadow() -- 给实体添加动态阴影
    inst.entity:AddMiniMapEntity() -- 允许实体在小地图上显示
    inst.entity:AddNetwork() -- 允许实体在网络游戏中同步

    -- 设置实体的物理属性
    MakeCharacterPhysics(inst, 50, .25)
    inst.DynamicShadow:SetSize(1, .5) -- 设置阴影大小
    inst.Transform:SetFourFaced() -- 设置实体的朝向

    -- 设置动画资源
    inst.AnimState:SetBank("bernie")
    inst.AnimState:SetBuild("bernie_build")
    inst.AnimState:PlayAnimation("idle_loop", true) -- 设置动画播放

    -- 设置小地图图标
    inst.MiniMapEntity:SetIcon("minimap/bernie.png")

    -- 添加标签，标签用于标识实体的类型和属性
    inst:AddTag("smallcreature")
    inst:AddTag("companion")
    inst:AddTag("soulless")

    -- 设置实体的原始状态
    inst.entity:SetPristine()

    -- 如果当前不是服务器主机，则返回实例
    if not TheWorld.ismastersim then
        return inst
    end

    -- 添加特殊信息
    inst.scrapbook_specialinfo = "CP_BERNIE"

    -- 添加并配置健康组件
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BERNIE_HEALTH*40)
    inst.components.health.nofadeout = true

    -- 添加可检查组件
    inst:AddComponent("inspectable")

    -- 添加移动组件并设置移动速度
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = TUNING.BERNIE_SPEED

    -- 添加战斗组件
    inst:AddComponent("combat")

    -- 添加计时器组件
    inst:AddComponent("timer")

    -- 添加物品组件，并设置物品拾取函数
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnPickupFn(onpickup)
    inst.components.inventoryitem:SetSinks(false)

    -- 添加可闹鬼组件，并设置闹鬼值
    inst:AddComponent("hauntable")
    inst.components.hauntable:SetHauntValue(TUNING.HAUNT_TINY)

    -- 设置状态机和大脑
    inst:SetStateGraph("SGbernie")
    inst:SetBrain(brain)

    -- 添加自定义函数
    inst.GoInactive = goinactive
    inst.GoBig = gobig
    inst.OnEntitySleep = OnEntitySleep
    inst.OnEntityWake = OnEntityWake

    -- 添加自定义行为函数
    inst.hotheaded = commonfn.hotheaded
    inst.isleadercrazy = commonfn.isleadercrazy

    return inst
end


return Prefab("cp_bernie_active", fn, assets, prefabs)
