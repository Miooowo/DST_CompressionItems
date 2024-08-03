local STRINGS = GLOBAL.STRINGS
STRINGS.UI.CRAFTING_FILTERS.CPITEMS="Comperssion items"
local wilson_ds  = STRINGS.CHARACTERS.GENERIC.DESCRIBE
local wurt_ds    = STRINGS.CHARACTERS.WURT.DESCRIBE
-- Compressed cutgrass
STRINGS.RECIPE_DESC.CP_CUTGRASS 				= "Oh, its compressed cutgrass."--"哦，这是压缩的采下的草"
STRINGS.NAMES.CP_CUTGRASS 						= "compressed cutgrass"

STRINGS.CHARACTERS.GENERIC.DESCRIBE.CP_CUTGRASS = "Cut grass,  a compression process, ready for arts and crafts with more efficent." 
-------------------------------------------------"割下来的草，一种压缩工艺，可用于制作和合成其他耐久更高的东西。"

STRINGS.CHARACTERS.WALTER.DESCRIBE.CP_CUTGRASS 	= "Sorry, I cant make a whistle with it! if its thin, its fine." --"如果削薄一点就可以用它来吹口哨！"

STRINGS.CHARACTERS.WURT.DESCRIBE.CP_CUTGRASS 	= "It's my heavy sword now." --"它是我的重剑了。"



-- Compressed twigs
STRINGS.RECIPE_DESC.CP_TWIGS 					= "Oh,it's compressed twigs" 
STRINGS.NAMES.CP_TWIGS 							= "compressed twigs" 
STRINGS.CHARACTERS.GENERIC.DESCRIBE.TWIGS 		= "It's a basket of small twigs." --"一篮小树枝"
STRINGS.CHARACTERS.WURT.DESCRIBE.CP_CUTGRASS    = "Basket sticks, florp."





-- Compressed log
STRINGS.RECIPE_DESC.CP_LOG = "Oh, its compressed log" -- 物体的制作栏描述
STRINGS.NAMES.CP_LOG = "compressed log" --物品名称
wilson_ds.CP_LOG.BURNING = "That's some hot pile of wood!"
wilson_ds.CP_LOG = "It's big, it's heavy, and it's pile of wood."
wurt_ds.CP_LOG.BURNING = wurt_ds.LOG.BURNING
wurt_ds.CP_LOG = wurt_ds.LOG.GENERIC
