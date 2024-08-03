local assets =
{
    Asset("ANIM", "anim/cp_slingshot.zip"),
    Asset("ANIM", "anim/swap_cp_slingshot.zip"),
	Asset("ATLAS", "images/cp_slingshot.xml"),  -- XML文件
}

local prefabs =
{
	"cp_slingshotammo_rock_proj",
	"slingshotammo_rock_proj",
}

local SCRAPBOOK_DEPS =
{
    "slingshotammo_rock",
    "slingshotammo_gold",
    "slingshotammo_marble",
    "slingshotammo_thulecite",
    "slingshotammo_freeze",
    "slingshotammo_slow",
    "slingshotammo_poop",
    "trinket_1",
	"cp_slingshotammo_rock",
	"cp_slingshotammo_gold",
	"cp_slingshotammo_marble",
	"cp_slingshotammo_thulecite",
	"cp_slingshotammo_freeze",
	"cp_slingshotammo_slow",
	"cp_slingshotammo_poop",
	"cp_trinket_1",
}

local PROJECTILE_DELAY = 0.05 * FRAMES

local function OnEquip(inst, owner)
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("equipskinneditem", inst:GetSkinName())
        owner.AnimState:OverrideItemSkinSymbol("swap_object", skin_build, "swap_slingshot", inst.GUID, "swap_slingshot")
    else
        owner.AnimState:OverrideSymbol("swap_object", "swap_slingshot", "swap_slingshot")
    end
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")

    if inst.components.container ~= nil then
        inst.components.container:Open(owner)
    end
	local owner = inst.components.inventoryitem.owner
	if owner ~= nil then
		if owner.components.combat ~= nil then
			owner.components.combat.externaldamagemultipliers:SetModifier(inst, 40)
		end
	end
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
    local skin_build = inst:GetSkinBuild()
    if skin_build ~= nil then
        owner:PushEvent("unequipskinneditem", inst:GetSkinName())
    end

    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
	
	-- 移除攻击倍率修正
	local owner = inst.components.inventoryitem.owner
	if owner ~= nil and owner.components.combat ~= nil then
	    owner.components.combat.externaldamagemultipliers:RemoveModifier(inst)
	end
end

local function OnEquipToModel(inst, owner, from_ground)
    if inst.components.container ~= nil then
        inst.components.container:Close()
    end
end

local function OnProjectileLaunched(inst, attacker, target)
	if inst.components.container ~= nil then
		local ammo_stack = inst.components.container:GetItemInSlot(1)
		local item = inst.components.container:RemoveItem(ammo_stack, false)
		if item ~= nil then
			if item == ammo_stack then
				item:PushEvent("ammounloaded", {slingshot = inst})
			end

			item:Remove()
		end
	end
end

--[[
local function OnProjectileLaunched(inst, data)
    local projectile = data.projectile
    if projectile ~= nil and inst.projectile_damage_multiplier ~= nil then
        local original_damage = projectile.components.projectile.damage
        projectile.components.projectile:SetDamage(original_damage * inst.projectile_damage_multiplier)
    end
end
]] 
local function OnAmmoLoaded(inst, data)
	if inst.components.weapon ~= nil then
		if data ~= nil and data.item ~= nil then
			inst.components.weapon:SetProjectile(data.item.prefab.."_proj")
			inst:AddTag("ammoloaded")
			data.item:PushEvent("ammoloaded", {slingshot = inst})
		end
	end
end

local function OnAmmoUnloaded(inst, data)
	if inst.components.weapon ~= nil then
		inst.components.weapon:SetProjectile(nil)
		inst:RemoveTag("ammoloaded")
		if data ~= nil and data.prev_item ~= nil then
			data.prev_item:PushEvent("ammounloaded", {slingshot = inst})
		end
	end
end

local floater_swap_data = {sym_build = "swap_slingshot"}

local function cp_slingshot_fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    inst.entity:AddNetwork()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("cp_slingshot")
    inst.AnimState:SetBuild("cp_slingshot")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("rangedweapon")
    inst:AddTag("slingshot")

    --weapon (from weapon component) added to pristine state for optimization
    inst:AddTag("weapon")

    --inst.projectiledelay = PROJECTILE_DELAY

    MakeInventoryFloatable(inst, "med", 0.075, {0.5, 0.4, 0.5}, true, -7, floater_swap_data)

    inst.entity:SetPristine()

    if not TheWorld.ismastersim then
        return inst
    end

    inst.scrapbook_adddeps = SCRAPBOOK_DEPS
    inst.scrapbook_weapondamage = { TUNING.SLINGSHOT_AMMO_DAMAGE_ROCKS*40, TUNING.SLINGSHOT_AMMO_DAMAGE_MAX*40 }

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.imagename = "cp_slingshot"
	inst.components.inventoryitem.atlasname = "images/cp_slingshot.xml"
	
    inst:AddComponent("equippable")
    inst.components.equippable.restrictedtag = "slingshot_sharpshooter"
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)
    inst.components.equippable:SetOnEquipToModel(OnEquipToModel)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(TUNING.SLINGSHOT_DISTANCE*40, TUNING.SLINGSHOT_DISTANCE_MAX*40)
    inst.components.weapon:SetOnProjectileLaunched(OnProjectileLaunched)
    inst.components.weapon:SetProjectile(nil)
	inst.components.weapon:SetProjectileOffset(1)

    inst:AddComponent("container")
    inst.components.container:WidgetSetup("cp_slingshot")
    inst.components.container.canbeopened = false
    inst.components.container.stay_open_on_hide = true
	-- Listen for itemget and itemlose events for the container
	inst:ListenForEvent("itemget", OnAmmoLoaded)
    inst:ListenForEvent("itemlose", OnAmmoUnloaded)
	
    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME*40)
    MakeSmallPropagator(inst)
    MakeHauntableLaunch(inst)
    return inst
end

return Prefab("cp_slingshot", cp_slingshot_fn, assets, prefabs)