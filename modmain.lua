-- 一些预设置，防止系统报错
env.RECIPETABS = GLOBAL.RECIPETABS 
env.TECH = GLOBAL.TECH

--下行代码只代表查值时自动查global，增加global的变量或者修改global的变量时还是需要带"GLOBAL."
GLOBAL.setmetatable(env, { __index = function(t, k) return GLOBAL.rawget(GLOBAL, k) end })
local TheInput = GLOBAL.TheInput
local require = GLOBAL.require
io      = GLOBAL.io
assert  = GLOBAL.assert
rawget  = GLOBAL.rawget

PrefabFiles = {
	"cp_cutgrass","cp_twigs",
}
Assets ={
	Asset("SOUND", "sound/common.fsb"),
	Asset("ATLAS", "images/inventoryimages/8z.xml"),
} --载入资源

-- 开导！
modimport("scripts/recipes.lua")

-- 翻译配置
local language = GetModConfigData("Language")---获取配置
if language == "en" then
	modimport("scripts/language/en.lua")
elseif language == "chs" then
    modimport("scripts/strings.lua")
end

