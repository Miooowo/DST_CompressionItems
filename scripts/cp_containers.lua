local containers = require "containers"
local params = containers.params
--------------------------------------------------------------------------
--[[ slingshot ]]
--------------------------------------------------------------------------

params.cp_slingshot =
{
    widget =
    {
        slotpos =
        {
            Vector3(0,   32 + 4,  0),
        },
        animbank = "ui_cookpot_1x2",
        animbuild = "ui_cookpot_1x2",
        pos = Vector3(0, 15, 0),
    },
    usespecificslotsforitems = true,
    type = "hand_inv",
    excludefromcrafting = true,
}

function params.cp_slingshot.itemtestfn(container, item, slot)
	return item:HasTag("slingshotammo")
	or item:HasTag("slingshot")
end

for k, v in pairs(params) do
    containers.MAXITEMSLOTS = math.max(containers.MAXITEMSLOTS, v.widget.slotpos ~= nil and #v.widget.slotpos or 0)
end

--------------------------------------------------------------------------

return containers