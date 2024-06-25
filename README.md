# 文本语言
选择你要阅读的文本语言<br>Select the language of the text you want to read  
- English
  
- [简体中文](DST_CompressionItems/README.md)


# 模组介绍
不知道你是否觉得游戏原版的堆叠上限太小，又不习惯用扩大堆叠数的模组，压缩物品就是为此而生的！
该模组对常用物品进行了压缩存储，比起原版物品拥有更高的效益。


# 目录结构描述
    ├── ReadMe.md           // 帮助文档
    
    ├── LICENSE    // 协议
    
    ├── modinfo.lua            // modinfo内设置模组配置项，存放基础的模组信息

    ├── modmain.lua           // modmain是模组的主要读取文件，各种函数、组件等都可以写在这

    ├── scripts              // scripts文件夹存放诸如prefabs、language等脚本配置
    
    │   ├── strings.lua    //strings是字符串文档，定义如物品名称和检查台词等，之后也许会把台词单独分离出来

    │   ├── recipes.lua    //recipes是配方文档，定义了各物品的基础配方

    │   ├── sound          //sound文件夹存放音效、声音

    │       └── common.fsb     
    
    │   ├── prefabs        //prefabs文件夹存放设置的预制物
    
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
