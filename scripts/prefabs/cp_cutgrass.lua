local assets =
{
    Asset("ANIM", "anim/cp_cutgrass.zip"),
	Asset("ATLAS", "images/cp_cutgrass.xml"),  -- XML文件
	Asset("IMAGE", "images/cp_cutgrass.tex"),  -- TEX文件
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cp_cutgrass")
    inst.AnimState:SetBuild("cp_cutgrass")
    inst.AnimState:PlayAnimation("idle")
	
    inst.pickupsound = "vegetation_grassy"

    inst:AddTag("cattoy")
    inst:AddTag("renewable")

    MakeInventoryFloatable(inst, "med", 0.05, 0.68)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "cp_cutgrass"
	inst.components.inventoryitem.atlasname = "images/cp_cutgrass.xml"
	
    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

    inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.ROUGHAGE 
    inst.components.edible.healthvalue = TUNING.HEALING_TINY * 40
    inst.components.edible.hungervalue = TUNING.CALORIES_TINY/2 * 40

    inst:AddComponent("inspectable")
    inst:AddComponent("tradable")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL * 40

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME*40)
    MakeSmallPropagator(inst)

    MakeHauntableLaunchAndIgnite(inst)

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.HAY
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_CUTGRASS_HEALTH * 40

    return inst
end

return Prefab("cp_cutgrass", fn, assets)
