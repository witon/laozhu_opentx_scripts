最新更新
====
1. 全局变量调整界面。
2. 输出通道调整功能提升，
3. 输出通道曲线调整。
4. 下沉率调整
以上暂时没有更新相应使用说明。

-----------------------------------------------------------

介绍
====
[3ktel：F3K比赛和训练飞行辅助](#f3k_usage)<br>
[5jtel：F5J比赛和训练飞行辅助](#f5j_usage)<br>
[adjust：调机小工具](#adjust_usage)，当前支持调整两个副翼或者两个襟翼舵机输出的行程和一致性。<br>


兼容性
====
本脚本在FrSky XLite遥控 & OpenTX2.3固件上测试通过。


安装
====
1. 将"LAOZHU"、"TELEMETRY"两个目录copy到遥控器SD卡"SCRIPTS"目录下。
2. 进入遥控器"DISPLAY"设置界面，选择"3ktel"(for F3K)或者"5jtel"(for F5J)或者"adjust"(for adjust)。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_3k_install.png)
3. 在遥控器主界面，长按摇杆"下"，进入"飞行信息"界面。<br>![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_flightpage.png)<br>(3k飞行信息截图)
4. 连续按摇杆"右"，进入"设置"界面。<br>![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_3k_setting.png)<br>(3k设置界面截图)
5. 在选中的设置项上按摇杆"确定"，设置相应开关，再次按摇杆"确定"完成该开关设置。

<span id="f3k_usage">3K使用指引</span>
====
主要功能：<br>
显示剩余工作时间<br>
飞行计时<br>
设置目标飞行时间并倒数15秒<br>
记录并查看多条飞行记录<br>
使用旋钮选择并语音播报飞行信息（飞行时间、飞行高度、起飞高度、接收信号强度）<br>

1. 设置：<br>
在"飞行信息"界面，连续按摇杆"右"进入设置界面，按摇杆"上"、"下"选中设置项，按摇杆"确定"进入设置，按摇杆"上"、"下"改变设置，再次按摇杆"确定"完成设置。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_3k_setting.png)

2. 设置工作时间：<br>
在"飞行信息"界面，按摇杆"上"、"下"移动焦点，选中工作时间，按摇杆"确定"进入工作时间设置，工作时间会闪烁，此时按摇杆"上"、"下"可改变工作时间。再次按"确定"，结束工作时间设置。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_set_worktime.png)

3. 复位工作时间：<br>
拨动设置里选择的工作时间复位开关进行复位。

4. 设置目标飞行时间（可用于倒数QT）：<br>
在"飞行信息"界面，按摇杆"上"、"下"移动焦点，选中目标飞行时间，按摇杆"确定"进入目标时间设置，目标飞行时间会闪烁，此时按摇杆"上"、"下"可改变目标时间。再次按"确定"，结束目标飞行时间设置，在飞行时间达到目标时间15秒后，开始语音倒数。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_set_dest_flighttime.png)

5. 记录飞行时间：<br>
3k的脚本通过检测飞行模式变化来开始或终止飞行计时，发射和爬升的飞行模式命名必须分别为"preset"和"zoom"。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_flight_modes.png)<br>
从飞行模式"preset"进入飞行模式"zoom"时飞行时间计时器清零并且开始计时。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_state_preset.png)<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_state_zoom.png)<br>
从飞行模式"zoom"进入除"preset"外的飞行模式，计时器继续计时。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_state_flight.png)<br>
正常飞行结束，进入一次飞行模式"preset"（按压发射按钮一次），进入降落状态，计时器停止计时，并且保存当前飞行记录。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_state_landed.png)<br>

6. 查看飞行记录：<br>
在"飞行信息"界面，按摇杆"右"进入飞行记录界面，按摇杆"上"、"下"滚动记录。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_flight_records.png)<br>

7. 语音播报飞行信息：<br>
通过"设置"中选择的"Var Slider"旋钮，选择播报的信息，依次为"当前飞行时间"、"当前高度"、"接收信号强度"、"发射高度"。拨动"设置"中选择的"Read Switch"开关，播报选择的信息。

<span id="f5j_usage">5J使用指引</span>
====
主要功能：<br>
飞行计时<br>
完全按照5j规则自动记录起飞高度（起飞动力30秒，关动力后10秒，记录期间最高高度为起飞高度）<br>
定时定点降落语音倒数<br>
使用旋钮选择并语音播报飞行信息（飞行时间、飞行高度、起飞高度、接收信号强度）<br>

1. 设置：<br>
在"飞行信息"界面，连续按摇杆"右"进入设置界面，按摇杆"上"、"下"选中设置项，按摇杆"确定"进入设置，按摇杆"上"、"下"改变设置，再次按摇杆"确定"完成设置。<br>
Var Slider: 语音播报选择旋钮<br>
Read Switch: 语音播报触发开关，触发播报一次选择的信息。<br>
Reset Switch: 复位开关，复位到准备起飞的状态。<br>
Flight Switch: 飞行开关，建议与油门开关联动，开：开始飞行计时；关：结束飞行计时。<br>
Throttle Channel: 油门通道，用于检测开或者关动力。<br>
Throttle Threshold: 检测动力开或者关的油门阈值，（调整到电机不转时油门最大的值减5）。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_5j_setting.png)<br>

2. 准备状态：<br>
在动力关闭的状态下，触发复位开关（见“设置”），进入准备状态，此时ST显示“Prep”。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_5j_state_prepare.png)

3. 开动力状态：<br>
在准备状态下，打开飞行开关（见“设置”）并且油门通道输出大于油门阈值（见“设置”），进入开动力状态，此时ST显示“PwOn”，此时飞机可以起飞。在开动力状态下，PT显示当前动力时间，并且当动力时间超过20秒，会有倒数提示动力时间结束，作为辅助训练时，需要飞手在动力时间提示为0时，关闭动力。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_5j_state_power.png)

4. 关动力后10秒钟内状态：<br>
在开动力状态下，达到30秒动力时间，或者飞手关闭动力，进入“关动力后10秒钟内状态”，此时ST显示“PwOf”。在此期间，语音倒数10秒，并且PT显示剩余倒数时间。期间如果重新开动力，LALT旁边会显示一个*号。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_5j_state_poweroff_10s.png)<br>

5. 飞行状态：<br>
在关动力10秒钟后，进入飞行状态。此时ST显示“Fligh”。FT显示飞行时间。期间如果重新开动力，LALT旁边会显示一个*号。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_5j_state_flight.png)<br>


6. 降落状态：<br>
在飞机降落的瞬间，关闭飞行开关（“见设置”），进入降落状态。此时ST显示“Land”。飞行计时器停止计时，FT显示飞行时间，LALT显示起飞高度。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_5j_state_landed.png)

7. 在工作时间结束前20秒，如果还没进入降落状态，语音播报工作时间结束倒数秒数，以便定时定点降落。

8. 准备下一次飞行：<br>
在动力关闭的状态下，触发复位开关（见“设置”），进入准备状态，此时ST显示“Prep”。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_5j_state_prepare.png)


9. 语音播报飞行信息：<br>
通过"设置"中选择的"Var Slider"旋钮，选择播报的信息，依次为"当前飞行时间"、"当前高度"、"接收信号强度"、"发射高度"。拨动"设置"中选择的"Read Switch"开关，播报选择的信息。


<span id="adjust_usage">adjust使用指引</span>
====
1. 进入adjust界面<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_adjust.png)<br>
"thr"当前油门摇杆输出的值<br>
"adj"是否开始调整，初始进入默认为"n"<br>
"output1"待调整输出1，用于选择第一个被调整的输出通道。<br>
"output2"待调整输出2，用于选择第二个被调整的输出通道。<br>
2. 选择调整通道<br>
在"adj"为"n"时，移动光标到output1和output2上，按摇杆"确定"，光标开始闪烁，按压摇杆"上"、"下"选择要调整的副翼通道，再次按压摇杆"确定"，退出选择。<br>
注意！！！调整通道时，所选通道的输出会根据油门摇杆所处的位置，可能处于最大输出、最小输出。如果是有动力的飞机，切记断开电机线后调整，或者确保所调整的通道不是油门通道。非油门通道或者非动力飞机，也需要关注所调整通道是否信号输出范围超过机械限位，否则会损坏机械结构，建议非油门通道调整时，油门摇杆推到中间位置。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_select_output.png)<br>
3. 打开调整选项<br>
按压摇杆"上"、"下"，移动光标到"adj"上，按压摇杆"确定"，光标开始闪烁，按压摇杆"上"、"下"，打开或者关闭调整。再次按压"确定"，结束选择。
注意！！！打开调整选项时，确保所选择调整的两个通道不是油门通道。同时建议断开电机线，并且油门摇杆置于中位。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_enable_adjust.png)<br>
4. 调整两个通道的最小、中位、最大<br>
调整最大：<br>
油门摇杆推到上1/4或者再小一点(避免一开始过大超出机械行程损坏结构)，按压摇杆"上"、"下"，移动光标到max，按压"确定"，光标开始闪烁，按压摇杆"上"、"下"改变数值，直到两个舵面处于最大角度并且一致。(当安装不够一致时，其中一个最大角度α比另一个小，调整到两个舵面角度都是α即可)。继续推大油门摇杆，重复以上调整直到一致并且机械不干涉并且角度最大。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_adjust_max.png)<br>
调整最小：<br>
同上。<br>
调整中位：<br>
油门摇杆至于中位(thr显示最好是0或者接近0)，按压摇杆"上"、"下"，移动光标到center，按压"确定"，光标开始闪烁，按压摇杆"上"、"下"改变数值。直到所调整的两个舵面处于中位(一般是处于最大和最小角度的中值)，并且一致。<br>
![](https://gitee.com/dacaodi/laozhu_opentx_scripts/raw/master/document/screenshot_xlites_adjust_center.png)<br>
5. 结束output调整<br>
光标移动到"adj"，设置为"n"。


