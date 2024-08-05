local L = locale
local function translate(language_table)  -- 使用这个fn可以根据表中的语言自动翻译
	language_table.zhr = language_table.zh
	language_table.zht = language_table.zht or language_table.zh
	return language_table[L] or language_table.en
end

name = translate({en = "[CPitems]Compression items", zh = "[CPitems]压缩物品"}) --Mod名字
version ="0.3.1-test" --Mod版本，可以自由设定任何值，但如果要更新自己的Mod，就必须和已经上传的Mod版本有差别
description = translate({
	en = "󰀤version:"..version.."\n"..
[[
	Tired of overflowing supplies and dont want to destroy them?
	"Compression items" is a mod designed to reduce storage requirements by compressing original items!
	They are more efficient compared to the dst items.
]],
	zh= "󰀤版本:"..version.."\n"..
[[
	不知道你是否觉得游戏原版的堆叠上限太小󰀞，又不习惯用扩大堆叠数的模组󰀯，压缩物品就是为此而生的！󰀐
	󰀏该模组对常用物品进行了压缩存储，比起原版物品拥有更高的效益。󰀫

	更新日志：
	8月5日更新：压缩金块，压缩幸运黄金
	7月10日更新：压缩火把，压缩伯尼，压缩打火机
	已知bug：压缩火把无法投掷，压缩伯尼和压缩火把没有手持贴图
	7月1日更新：更新压缩木头，压缩警钟，压缩弹弓以及压缩弹药
	看比较多的人对这个感觉比较新鲜，我就提前放一波更新，有bug再修。󰀤
]], --Mod介绍
})
author = "󰀍Mio󰀍" --Mod作者
forumthread = ""  --Mod在klei论坛的地址，没有可以留空，但不可删除
api_version = 10 --Mod的API地址，当前联机版固定为10

dst_compatible = true --用于判定是否和饥荒联机版兼容
dont_starve_compatible = false
reign_of_giants_compatible = false --这两行用于判定是否和饥荒单机版兼容
all_clients_require_mod = true --要求所有客户端都下载此Mod
priority = -20488

icon_atlas = "modicon.xml" --Mod的图标xml文档路径，需要有对应文件存在，否则Mod图标会显示为空白
icon = "modicon.tex" --Mod图标文件名称

server_filter_tags = { 
    "mio","compression items","压缩物品","存储","cpitems"
} -- 服务器过滤标签，会在其他人使用标签筛选功能时起作用，标签可以写英文也可以写中文，可以添加多个标签

configuration_options =
{
    {
        name = "Language",
		label = translate({en = "Language", zh="语言", }),
		hover = translate({
			en = "Choose a language\n󰀐Think the translation isn't perfect? Please give me your feedback!󰀫",
			zh = "选择语言\n󰀐认为翻译可以润色? 请给予反馈！󰀫", 
			}),
        options =
        {
            {description = translate({
				en = "Simplified Chinese",
				zh = "简体中文",
				}), 
			hover = translate({
				en = "如果你是其他语言用户可以在创意工坊帮助我，谢谢！󰀍",
				zh = "如果你是其他语言用户可以在创意工坊帮助我，谢谢！󰀍", 
			}),
				data = "chs",
			},
			{description = translate({
				en = "English",
				zh = "英文 English",
				}),
			hover = translate({
				en = "If you are a user of other languages you can help me at Workshop, thanks!󰀍",
				zh = "If you are a user of other languages you can help me at Workshop, thanks!󰀍", 
			}),
				data = "en",
			},
		},
        default = translate({en = "en", zh = "chs", }),
    },
	{
		name = "CP_START",
		label = translate({en = "Compression Start", zh="压缩开局", }),
		hover = translate({
			en = "Give u compressed items when u born.\n its op!!!",
			zh = "角色出生自带压缩物品\n（超模选项）", 
			}),
		options =
		{
		    {description = translate({
				en = "YES",
				zh = "是",
				}), 
				hover = translate({
					en = "its op, r u sure? ",
					zh = "这很超模，不建议开", 
					}),
				data = "true",
			},
			{description = translate({
				en = "NO",
				zh = "否",
				}),
				hover = translate({
					en = "its ok, im sure. ",
					zh = "没事，慢慢肝就行", 
					}),
				data = "false",
			},
		},
		default = "false"
	},
	
}
-- wordshop = 2427481232 错误追踪
bugtracker_config = {
    upload_client_log = true,  -- 接受客户端报错日志
    upload_server_log = true,  -- 接受服务器报错日志
    upload_other_mods_crash_log = true, -- 接受其他mod引起的报错日志
    email = "miooo55555@163.com", --注意: 不要设置成工作的邮箱！建议注册一个新邮箱专门用于接收日志。
    lang = "CHI", -- 设置邮件语言为中文
    -- 其它配置项目...
}

