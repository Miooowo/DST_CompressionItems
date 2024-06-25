# 文本语言
选择你要阅读的文本语言<br>Select the language of the text you want to read  
- English
  
- [简体中文](https://github.com/Miooowo/DST_CompressionItems?tab=readme-ov-file)


# 模组介绍
不知道你是否觉得游戏原版的堆叠上限太小，又不习惯用扩大堆叠数的模组，压缩物品就是为此而生的！
该模组对常用物品进行了压缩存储，比起原版物品拥有更高的效益。


# 在Steam上订阅！
[压缩物品](https://steamcommunity.com/sharedfiles/filedetails/?id=3274583874)

# 修改和分发许可
根据[GPL 3.0协议](LICENSE)，用户可以自由地修改和分发你的软件，如果用户A对本模组进行了修改并想要分发，他们必须：

- 公开源代码：提供修改后模组的源代码。
- 保留许可证：在修改后的模组中保留原有的GPL 3.0许可证声明，并确保新的修改部分也受GPL 3.0的约束。
- 无附加限制：不能增加任何限制条件，影响其他人使用、修改和分发修改后的模组。
- 声明修改：在分发的版本中添加一个声明，说明这个版本是基于本模组进行了修改。
- 提供专利许可：如果用户A持有任何与修改后模组相关的专利，他们必须同意让这些专利在GPL 3.0许可下免费使用。


# 目录结构描述
    ├── ReadMe.md               // 帮助文档
    
    ├── LICENSE                // 协议
    
    ├── modinfo.lua            // modinfo内设置模组配置项，存放基础的模组信息

    ├── modmain.lua           // modmain是模组的主要读取文件，各种函数、组件等都可以写在这

    ├── scripts              // scripts文件夹存放诸如prefabs、language等脚本配置
    
    │   ├── strings.lua      //strings是字符串文档，定义如物品名称和检查台词等，之后也许会把台词单独分离出来

    │   ├── recipes.lua      //recipes是配方文档，定义了各物品的基础配方

    │   ├── sound            //sound文件夹存放音效、声音

    │       └── common.fsb     
    
    │   ├── prefabs          //prefabs文件夹存放设置的预制物
    
    │       ├── cp_twigs.lua

    │       ├── cp_twigs.lua

    │       └── cp_......

    │   ├── language        //language文件夹存放其他语言的字符串翻译

    │       └── en.lua      //en.lua是英文翻译
    
    ├── images              // images文件夹存放图片、贴图文件
    
    └── anim                // anim文件夹存放动画文件

 
# 版本内容更新
###### v0.0.1: 2024年6月24日 下午 11:47
模组在Steam创意工坊发布，仅有两个物品（压缩采下的草和压缩树枝）
