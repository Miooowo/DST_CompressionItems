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
}

for k,v in pairs(cpitemsrecipe) do
AddRecipeToFilter(v,"CPITEMS")--API，把配方添加到制作栏，这里用了遍历
end

-----------------------------
-------materials---------材料
-----------------------------
-- 压缩采下的草
AddRecipe2("cp_cutgrass", {Ingredient("cutgrass", 40)}, TECH.NONE, {atlas = "images/cp_cutgrass.xml",image = "cp_cutgrass.tex",})
-- 压缩树枝
AddRecipe2("cp_twigs", {Ingredient("twigs", 40)}, TECH.NONE, {atlas = "images/cp_twigs.xml",image = "cp_twigs.tex",})
-- 压缩木头

-----------------------------
--refined materials--精炼材料
-----------------------------

-- 压缩绳子

-- 压缩木板

--------------------------------
--WILSON TRANSMUTATION--威吊转化-
--------------------------------
-- Recipe2("transmute_cp_twigs", {Ingredient("cp_log", 1)}, TECH.NONE, {product="cp_twigs", image="images/cp_twigs.xml", builder_tag="alchemist", description="transmute_twigs", numtogive = 2})
