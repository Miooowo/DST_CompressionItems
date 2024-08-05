--[[
{
	name,--配方名，一般情况下和需要合成的道具同名
	ingredients,--配方
	tab,--合成栏(已废弃)
	level,--解锁科技
	--placer,--建筑类科技放置时显示的贴图、占位等/也可以配List用于添加更多额外参数，比如不可分解{no_deconstruction = true}
	min_spacing,--最小间距，不填默认为3.2
	nounlock,--不解锁配方，只能在满足科技条件的情况下制作(分类默认都算专属科技站,不需要额外添加了)
	numtogive,--一次性制作的数量，不填默认为1
	builder_tag,--制作者需要拥有的标签
	atlas,--需要用到的图集文件(.xml)，不填默认用images/name.xml
	image,--物品贴图(.tex)，不填默认用name.tex
	testfn,--尝试放下物品时的函数，可用于判断坐标点是否符合预期
	product,--实际合成道具，不填默认取name
	build_mode,--建造模式,水上还是陆地(默认为陆地BUILDMODE.LAND,水上为BUILDMODE.WATER)
	build_distance,--建造距离(玩家距离建造点的距离)
	filters,--制作栏分类列表，格式参考{"SPECIAL_EVENT","CHARACTER"}
	
	--扩展字段
	placer,--建筑类科技放置时显示的贴图、占位等
	filter,--制作栏分类
	description,--覆盖原来的配方描述
	canbuild,--制作物品是否满足条件的回调函数,支持参数(recipe, self.inst, pt, rotation),return 结果,原因
	sg_state,--自定义制作物品的动作(比如吹气球就可以调用吹的动作)
	no_deconstruction,--填true则不可分解(也可以用function)
	require_special_event,--特殊活动(比如冬季盛宴限定之类的)
	dropitem,--制作后直接掉落物品
	actionstr,--把"制作"改成其他的文字
	manufactured,--填true则表示是用制作站制作的，而不是用builder组件来制作(比如万圣节的药水台就是用这个)
	hint_msg,--未解锁时的提示文字索引，例如为xx，调用的字符串即为STRINGS.UI.CRAFTING.XX

	--注释摘自能力勋章
}
--]]
local Recipe = GLOBAL.Recipe
local Recipe2 = GLOBAL.Recipe2

local CHECK_MODS = {
	["workshop-1909182187"] = "Functional_Medal",
	--["workshop-376333686"] = "COMBINED_STATUS",
	--["CombinedStatus"] = "COMBINED_STATUS",
}

local HAS_MOD = {}
-- If the mod is a]ready loaded at this point
for mod_name, key in pairs(CHECK_MODS) do
	HAS_MOD[key] = HAS_MOD[key] or (GLOBAL.KnownModIndex:IsModEnabled(mod_name) and mod_name)
end

for k,v in pairs(GLOBAL.KnownModIndex:GetModsToLoad()) do
	local mod_type = CHECK_MODS[v]
	if mod_type then
		HAS_MOD[mod_type] = v
	end
end
---------------
-- 旧配方参考 --
---------------
-- AddRecipe是官方提供的MOD API，专门用在modmian.lua。参数非常多，和scripts/recipe.lua里的Recipe类的参数（跳过第一个参数self)是一一对应的。
-- 第一个参数，prefab的名字。
-- 第二个参数，配方表，用{}框起来，里面每一项配方用一个Ingredient。Ingredient的第一个参数是具体的prefab名，第二个是数量，这里cutgrass和twigs分别是干草和树枝。
-- 第三个参数，预制物的归类，RECIPETABS.SURVIVAL表明归类到生存，也就是可以在生存栏里找到。
-- 第四个参数，预制物需要的科技等级，TECH.NONE 表明不需要科技，随时都可以制造。
-- 后续5个参数都是nil，表明不需要这些参数，但需要占位置
-- 最后一个参数，指明图片文档地址，用于制作栏显示图片。
-- end -------

-- 分类标签
AddRecipeFilter({name="CPITEMS",atlas = "images/inventoryimages/8z.xml", image = "8z.tex"})
--API，添加制作栏，一行代码就够了，参数是名字(可以大写小写或者中文，但小写最后还是会变成大写)和图片，自己加上就好，除此之外还能加入其他参数比如index来改变制作栏的序号，不过一般只要这三个就行

local cpitemsrecipe={
"cp_cutgrass",
"cp_twigs",
"transmute_cp_twigs",
"cp_log",
"cp_boards",
"cp_flint",
"cp_goldnugget",
"cp_lucky_goldnugget",
"cp_pocketwatch_weapon",
"cp_slingshot",
"cp_slingshotammo_rock",
"cp_slingshotammo_gold",
"cp_slingshotammo_marble",
"cp_slingshotammo_thulecite",
"cp_slingshotammo_freeze",
"cp_slingshotammo_slow",
"cp_slingshotammo_poop",
"cp_trinket_1",
"cp_torch",
"cp_lighter",
"cp_bernie_inactive",
"transmute_trinket_1",
"cp_transmute_trinket_1",
"cp_walter_transmute_trinket_1",
--"cp_pocketwatch_weapon",
}

local CHARACTER_cpitemsrecipe={
"transmute_cp_twigs",
"cp_pocketwatch_weapon",
"cp_slingshot",
"cp_slingshotammo_rock",
"cp_slingshotammo_gold",
"cp_slingshotammo_marble",
"cp_slingshotammo_thulecite",
"cp_slingshotammo_freeze",
"cp_slingshotammo_slow",
"cp_slingshotammo_poop",
"cp_lighter",
"cp_bernie_inactive",
"transmute_trinket_1",
"cp_transmute_trinket_1",
"cp_walter_transmute_trinket_1",
--"cp_pocketwatch_weapon",
}
-- 创建一个表来快速查找 CHARACTER_cpitemsrecipe 中的配方
local CHARACTER_recipe_lookup = {}
for _, v in pairs(CHARACTER_cpitemsrecipe) do
    CHARACTER_recipe_lookup[v] = true
end

-- 遍历 cpitemsrecipe，首先将所有配方添加到 CPITEMS 制作栏，然后检查是否需要添加到 CHARACTER 制作栏
for _, v in pairs(cpitemsrecipe) do
    AddRecipeToFilter(v, "CPITEMS")
    if CHARACTER_recipe_lookup[v] then
        AddRecipeToFilter(v, "CHARACTER")
    end
end

--[[
for k,v in pairs(cpitemsrecipe) do
AddRecipeToFilter(v,"CPITEMS")--API，把配方添加到制作栏，这里用了遍历
end
]]

-----------------------------
-------materials---------材料
-----------------------------
-- 压缩采下的草
Recipe2("cp_cutgrass", {Ingredient("cutgrass", 40)}, TECH.NONE, {atlas = "images/cp_cutgrass.xml",image = "cp_cutgrass.tex",})
-- 压缩树枝
Recipe2("cp_twigs", {Ingredient("twigs", 40)}, TECH.NONE, {atlas = "images/cp_twigs.xml",image = "cp_twigs.tex",})
-- 压缩木头
Recipe2("cp_log", {Ingredient("log", 40)}, TECH.NONE, {atlas = "images/cp_log.xml",image = "cp_log.tex",})
-- 压缩燧石
Recipe2("cp_flint", {Ingredient("flint", 40)}, TECH.NONE, {atlas = "images/cp_flint.xml",image = "cp_flint.tex",})
-- 压缩金块
Recipe2("cp_goldnugget", {Ingredient("goldnugget", 40)}, TECH.SCIENCE_TWO, {atlas = "images/cp_goldnugget.xml",image = "cp_goldnugget.tex",})
-- 压缩幸运黄金
Recipe2("cp_lucky_goldnugget", {Ingredient("lucky_goldnugget", 40)}, TECH.SCIENCE_TWO, {atlas = "images/cp_lucky_goldnugget.xml",image = "cp_lucky_goldnugget.tex",})
-----------------------------
--refined materials--精炼材料
-----------------------------

-- 压缩绳子

-- 压缩木板
Recipe2("cp_boards", {Ingredient("cp_log", 4,"images/cp_log.xml")}, TECH.SCIENCE_ONE, {atlas = "images/cp_boards.xml",image = "cp_boards.tex",})

-----------------------------
--tools------------------工具
-----------------------------
-- 压缩火把
Recipe2("cp_torch", {Ingredient("cp_cutgrass", 2, "images/cp_cutgrass.xml"), Ingredient("cp_twigs", 2, "images/cp_twigs.xml")}, TECH.NONE,
{atlas = "images/cp_torch.xml",image = "cp_torch.tex",})

--------------------------------
--WILSON TRANSMUTATION--威吊转化
--------------------------------
--压缩树枝
Recipe2("transmute_cp_twigs", {Ingredient("cp_log", 1, "images/cp_log.xml")}, TECH.NONE, 
{product="cp_twigs", atlas = "images/cp_twigs.xml", image = "cp_twigs.tex", 
builder_tag="alchemist", description="transmute_twigs", numtogive = 2, filter = {"CHARACTER"},})

--------------------------------
--WANDA-----------------旺达专属
--------------------------------
-- 压缩警钟
Recipe2("cp_pocketwatch_weapon", {Ingredient("pocketwatch_parts", 3*40), Ingredient("marble", 4*40), Ingredient("nightmarefuel", 8*40)}, TECH.MAGIC_THREE, 
{atlas = "images/cp_pocketwatch_weapon.xml", image = "cp_pocketwatch_weapon.tex", builder_tag="clockmaker", no_deconstruction = pocketwatch_nodecon})

--------------------------------
--Walter---------------沃尔特专属
--------------------------------
-- 压缩弹弓
Recipe2("cp_slingshot", {Ingredient("cp_twigs", 1, "images/cp_twigs.xml"), Ingredient("mosquitosack", 2*40)}, TECH.NONE,
{atlas = "images/cp_slingshot.xml", image = "cp_slingshot.tex", builder_tag="pebblemaker"})
-- 手搓弹珠
Recipe2("cp_walter_transmute_trinket_1", {Ingredient("moonglass", 6)}, TECH.SCIENCE_ONE,
{product="trinket_1",builder_tag="pebblemaker", nounlock=true, filters = {"REFINE","CPITEMS"},})

--ammo 弹药合集
Recipe2("cp_slingshotammo_rock",{Ingredient("rocks", 1*40)},TECH.NONE,
{atlas = "images/cp_ammo.xml", image = "cp_slingshotammo_rock.tex",builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })

Recipe2("cp_slingshotammo_gold",{Ingredient("goldnugget", 1*40)},TECH.SCIENCE_ONE,
{atlas = "images/cp_ammo.xml", image = "cp_slingshotammo_gold.tex",builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })

Recipe2("cp_slingshotammo_marble",{Ingredient("marble", 1*40)},TECH.SCIENCE_TWO,
{atlas = "images/cp_ammo.xml", image = "cp_slingshotammo_marble.tex",builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })

Recipe2("cp_slingshotammo_poop",{Ingredient("poop", 1*40)},TECH.SCIENCE_ONE,
{atlas = "images/cp_ammo.xml", image = "cp_slingshotammo_poop.tex",builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })

Recipe2("cp_slingshotammo_freeze",{Ingredient("moonrocknugget", 1*40), Ingredient("bluegem", 1*40)},TECH.MAGIC_TWO,	
{atlas = "images/cp_ammo.xml", image = "cp_slingshotammo_freeze.tex",builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })

Recipe2("cp_slingshotammo_slow",{Ingredient("moonrocknugget", 1*40), Ingredient("purplegem", 1*40)},TECH.MAGIC_THREE,
{atlas = "images/cp_ammo.xml", image = "cp_slingshotammo_slow.tex",builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, })

Recipe2("cp_slingshotammo_thulecite",{Ingredient("thulecite_pieces", 1*40), Ingredient("nightmarefuel", 1*40)}, TECH.ANCIENT_TWO,
{atlas = "images/cp_ammo.xml", image = "cp_slingshotammo_thulecite.tex",builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true, nounlock=true})

Recipe2("cp_trinket_1",{Ingredient("trinket_1", 1*40)}, TECH.SCIENCE_ONE,
{atlas = "images/cp_ammo.xml", image = "cp_trinket_1.tex",builder_tag="pebblemaker", numtogive = 10, no_deconstruction=true})

--------------------------------
--WILLOW-----------------薇洛专属
--------------------------------
--压缩伯尼
Recipe2("cp_bernie_inactive", {Ingredient("beardhair", 2*40), Ingredient("beefalowool", 2*40), Ingredient("silk", 2*40)}, TECH.NONE,
{atlas = "images/cp_bernie_inactive.xml", image = "cp_bernie_inactive.tex", builder_tag="pyromaniac", filter = {"CHARACTER"}})
--压缩打火机
Recipe2("cp_lighter", {Ingredient("rope", 1*40), Ingredient("goldnugget", 1*40), Ingredient("petals", 3*40)}, TECH.NONE, 
{atlas = "images/cp_lighter.xml", image = "cp_lighter.tex",builder_tag="pyromaniac", filter = {"CHARACTER"},})


--------------------------------
--MEDAL--------------联动能力勋章
--------------------------------
if HAS_MOD.Functional_Medal then
	--浴火勋章 玻璃转弹珠
	Recipe2("transmute_trinket_1", {Ingredient("moonglass", 3)}, TECH.NONE,
	{product="trinket_1",builder_tag="has_bathfire_medal", nounlock=true, filters = {"MEDAL","REFINE","CPITEMS"},})
	--威屌 手搓弹珠
	Recipe2("cp_transmute_trinket_1", {Ingredient("moonglass", 8), Ingredient("lavaeel", 1, "images/lavaeel.xml"),}, TECH.SCIENCE_TWO,
	{product="trinket_1",builder_tag="alchemist", nounlock=true, filters = {"MEDAL","REFINE","CPITEMS"},})
end
-----------------------------
-------buildings---------建筑
-----------------------------
--[[
Recipe2("cp_punchingbag", {Ingredient("cp_cutgrass", 3,"images/cp_cutgrass.xml"), Ingredient("boards", 1*40)}, TECH.SCIENCE_ONE, {atlas = "images/cp_punchingbag.xml", image = "cp_punchingbag.tex",placer="punchingbag_placer"})
]]