#最新更新
====
1. 全局变量调整界面。<br>
2. 输出通道调整功能提升，输出通道曲线调整。<br>
3. 下沉率调整<br>
4. 发射高度调整
<br>
以上暂时没有更新相应使用说明。<br>

-----------------------------------------------------------

#使用介绍
====
[3ktel：F3K比赛和训练飞行辅助](#f3k_usage)<br>
[5jtel：F5J比赛和训练飞行辅助](#f5j_usage)<br>
[adjust：调机小工具](#adjust_usage)，当前支持调整两个副翼或者两个襟翼舵机输出的行程和一致性。<br>


#兼容性
====
本脚本在RM Zorro遥控器edgetx v2.9.4固件上测试通过。


#安装
====
1. 下载安装文件，进入安装文件目录，运行install.bat。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_install_cmd.png)
2. 输入遥控器SD卡盘符，比如我的是f盘，则是f:<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_install_click.png)
3. 等待安装完成。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_install_copy.png)
4. 另一种安装方法（不推荐）：将"LAOZHU"、"TELEMETRY"、"data"三个目录copy到遥控器SD卡"SCRIPTS"目录下。<br>
5. 进入遥控器"DISPLAY"设置界面，选择"3ktel"(for F3K)或者"5jtel"(for F5J)或者"adjust"(for adjust)。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_3k_install.png)
6. 安装完成后，第一次运行需要脚本编译，在遥控器主界面，长按摇杆"下"。这时会出现编译界面，等待编译完成，按退出键进入“飞行信息”界面<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_compiling.png)<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_finish_compile.png)<br>
7. 进入"飞行信息"界面。<br>![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_flightpage.png)<br>(3k飞行信息截图)
8. 连续按摇杆"右"，进入"设置"界面。<br>![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_3k_setting.png)<br>(3k设置界面截图)
9. 在选中的设置项上按摇杆"确定"，设置相应开关，再次按摇杆"确定"完成该开关设置。


-----------------------------------------------------------

#开发说明

##一、主要脚本目录
====
###1.LAOZHU：包含核心功能代码
包含各种状态管理类（如LDState.lua, F5jState.lua）
包含记录类（如LDRecord.lua, SinkRateRecord.lua）
包含数据读取和处理类（如readVar.lua, LDReadVarMap.lua）
包含工具类（如OTUtils.lua, LuaUtils.lua）
包含F3K和F5J特定功能的子目录

###2.TELEMETRY：包含遥测界面相关代码
包含主要界面入口（3ktel.lua, 5jtel.lua, adjust.lua）
包含不同功能模块的子目录（3k, 5j, adjust, common）
每个子目录包含该功能的界面实现（FlightPage.lua, SetupPage.lua等）

###3.data：存储飞行时记录的数据文件
###4.各种.cfg文件：存储用户使用时的设置

##二、构建和安装
====
install.bat：Windows安装脚本
build_sound_dll.bat/build_sound_so.sh：声音相关编译脚本
CompileFiles.lua/GenCompileList.lua：编译相关脚本


##三、功能模块
====
###1.F3K功能：用于F3K比赛和训练飞行辅助（手抛模型飞机比赛）
###2.F5J功能：用于F5J比赛和训练飞行辅助（电动滑翔机比赛）
###3.调整功能：用于调整舵机输出等参数

##四、测试相关
====
###1.test/：在单元测试脚本
###2.emutest/：在遥控器或者模拟器上执行自动化测试脚本

