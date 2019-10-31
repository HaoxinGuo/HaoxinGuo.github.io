---
title: Element Recorder（单元记录器）
top: false
cover: false
toc: true
mathjax: true
date: 2019-10-09 12:28:25
password:
summary:
tags:
- Element
- Recorder
categories:
- OpenSees
---
Element Recorder（单元记录器）
------------------------------
## 命令格式
元素类型记录了许多元素的响应。记录的响应是依赖于元素的，并且取决于传递给setResponse（）元素方法的参数。

*recorder Element* \<-file \$fileName\> \<-time\> \<-ele (\$ele1 \$ele2 ...)\>
\<-eleRange \$startEle \$endEle\> \<-region \$regTag\> \<-ele all\> (\$arg1
\$arg2 ...)
# 详细解释
| **-file**               | 输出记录器数据到文件 |
|-|-|
| **-xml**                | 输出记录器数据+ xml元数据标记每列数据（-file和-xml不能同时指定）    |
| **\$filename**          | 存储结果的文件。文件的每一行都包含域的已提交状态的结果（可选，默认：屏幕输出） |
| **-time**               | 这个参数会把第一个入口的伪时间放在行中。（可选，默认：省略）                   |
| **\$ele1 \$ele2 ...**   | 正在记录响应的元素标记 - 域中选定的元素（可选，默认值：省略）                  |
| **\$startEle \$endEle** | 正在记录响应的开始和结束元素的标记 - 域中所选元素的范围（可选，默认值：全部）  |
| **\$regTag**            | 先前定义的记录响应的元素区域的标记 - 域中元素的区域（可选）                    |
| **all**                 | 正在记录响应的元素 - 域中的所有元素（可选＆默认）                              |
| **\$arg1 \$arg2 ...**   | 传递给setResponse（）元素方法的参数      |


setResponse()元素方法依赖于元素类型，并用元素Command来描述。

Beam-Column Elements (Beam With Hinges Element, Displacement-Based Beam-Column 
Element, 

Elastic Beam Column Element, Nonlinear Beam Column Element) 
所有梁柱元素的共同点：

1. *globalForce* - 在全局坐标中的单元阻力（不包括惯性力）

例：recorder Element -file ele1global.out -time -ele 1 globalForce

2. *localForce* - 本地坐标中的单元抗力（不包括惯性力）

例：recorder Element -file ele1local.out -time -ele 1 localForce

部分梁柱元素的特点：

1. *section \$ secNum* - 请求来自元素长度特定部分的响应数量，

**\$ secNum -** 是指要输出数据的集成点

2. **force -** 部分作用力

例：recorder Element -file ele1sec1Force.out –time -ele 1 section 1 force

3. **deformation -** 断面变形

例：recorder Element -file ele1sec1Defo.out –time -ele 1 section 1 deformation

4. *Stiffness -* 截面刚度

例：recorder Element -file ele1sec1Stiff.out –time -ele 1 section 1 stiffness

5. **stressStrain -** 记录应力应变响应

例：recorder Element -file ele1sec1StressStrain.out –time -ele 1 section 1 fiber
\$y \$z \<\$matID\> stressStrain

|命令| 解释|
|-----------|----------------------------|
| *\$y*     | 要监控的光纤的局部y坐标\*  |
| *\$z*     | 要监控的光纤的局部z坐标\*  |
| *\$matID* | 以前定义的材料标签（可选） |

\*注意：记录器对象将搜索最接近该部分位置（\$ y，\$z）的光纤，并记录其应力应变响应。

注意： ZeroLength section element只有1个部分，因此不需要识别记录器命令中的部分。例：recorder Element -file Element1.out -time -ele 1 section 1 fiber 0.10 0.10 stressStrain。

# 输出格式

输出的格式通常取决于元素和/或节类型。然而，总的来说，输出遵循自由度的顺序。

这里有一些情况：

|命令| 参数 | 解释|
|---------|--------------|------------------------------------------------|
| element | globalForce  | 2D, 3dof: FX FY MZ 3D, 6dof: FX FY FZ MX MY MZ |
|         | localForce   | 2D, 3dof: Fx Fy Mz 3D, 6dof: Fx Fy Fz Mx My Mz |
| section | force        | Fx Mx                                          |
|         | deformation  | 轴向应变曲率                                   |
|         | stressStrain | 应力应变                                       |
