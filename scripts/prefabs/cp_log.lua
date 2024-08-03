local assets =
{
    Asset("ANIM", "anim/cp_log.zip"),
	Asset("ATLAS", "images/cp_log.xml"),  -- XML文件
	Asset("IMAGE", "images/cp_log.tex")
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cp_log")
    inst.AnimState:SetBuild("cp_log")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "wood"

    MakeInventoryFloatable(inst, "med", 0.1, 0.75)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("tradable")

	inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.WOOD
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL * 40

    MakeSmallBurnable(inst, TUNING.MED_BURNTIME*40)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    ---------------------

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "cp_log"
	inst.components.inventoryitem.atlasname = "images/cp_log.xml"
	
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM
	
    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.WOOD
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_LOGS_HEALTH * 40

    return inst
end

return Prefab("cp_log", fn, assets)
