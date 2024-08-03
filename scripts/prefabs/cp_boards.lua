local assets =
{
    Asset("ANIM", "anim/cp_boards.zip"),
	Asset("ATLAS", "images/cp_boards.xml"),  -- XML文件
	Asset("IMAGE", "images/cp_boards.tex")
}

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cp_boards")
    inst.AnimState:SetBuild("cp_boards")
    inst.AnimState:PlayAnimation("idle")

    inst.pickupsound = "wood"

    MakeInventoryFloatable(inst, "med", 0.1)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

	inst:AddComponent("edible")
    inst.components.edible.foodtype = FOODTYPE.WOOD
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = 0

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_TINYITEM

    inst:AddComponent("inspectable")

    MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME*40)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "cp_boards"
	inst.components.inventoryitem.atlasname = "images/cp_boards.xml"

    inst:AddComponent("repairer")
    inst.components.repairer.repairmaterial = MATERIALS.WOOD
    inst.components.repairer.healthrepairvalue = TUNING.REPAIR_BOARDS_HEALTH * 40
    inst.components.repairer.boatrepairsound = "turnoftides/common/together/boat/repair_with_wood"

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL * 40

    MakeHauntableLaunchAndIgnite(inst)

    return inst
end

return Prefab("cp_boards", fn, assets)
