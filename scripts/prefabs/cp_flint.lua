local assets =
{
    Asset("ANIM", "anim/cp_flint.zip"),
	Asset("ATLAS", "images/cp_flint.xml"),  -- XML文件
	Asset("IMAGE", "images/cp_flint.tex")
}

--[[
local function shine(inst)
    inst.task = nil
    inst.AnimState:PlayAnimation("sparkle")
    inst.AnimState:PushAnimation("idle")
    inst.task = inst:DoTaskInTime(4 + math.random() * 5, shine)
end
--]]

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetRayTestOnBB(true)
    inst.AnimState:SetBank("cp_flint")
    inst.AnimState:SetBuild("cp_flint")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "rock"

    inst:AddTag("molebait")
    inst:AddTag("renewable")
    inst:AddTag("quakedebris")

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ELEMENTAL
    inst.components.edible.hungervalue = 1 * 40
    inst:AddComponent("tradable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM
	
    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetSinks(true)
	inst.components.inventoryitem.imagename = "cp_flint"
	inst.components.inventoryitem.atlasname = "images/cp_flint.xml"

    MakeHauntableLaunchAndSmash(inst)

    inst:AddComponent("bait")

    --shine(inst)

    return inst
end

return Prefab("cp_flint", fn, assets)
