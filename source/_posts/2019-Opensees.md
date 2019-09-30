---
title: Opensees介绍
top: false
cover: false
toc: true
mathjax: true
date: 2019-09-30 17:39:25
password:
summary: 本文针对OpenSees在地震工程领域的独特优势，对软件结构整体进行详细分解和剖析，为OpenSees的学习和二次开发提供参考。
tags:
- 读书笔记 Opensees
categories:
- 读书笔记
---

本文针对OpenSees在地震工程领域的独特优势，对软件结构整体进行详细分解和剖析，为OpenSees的学习和二次开发提供参考。
# Opensees中的基本概念
======================
OpenSees全称是Open System for Earthquake Engineerting
Simulation，是土木工程学术界广泛使用的有限元分析软件和地震工程模拟平台。
作为新一代的有限元计算软件，OpenSees致力于强非线性分析，具有丰富的非线性单元、材料库和针对强非线性分析开发的算法，可用于分析非线性岩土和结构体系。
OpenSees程序自1999年正式推出以来，已广泛用于太平洋地震工程研究中心和美国其它一些大学和科研机构的科研项目中，较好的模拟了包括钢筋混凝土结构、桥梁、岩土工程在内众多的实际工程和振动台试验项目，证明其具有较好的非线性数值模拟精度。该程序正在引起世界各国结构工程领域众多研究人员的关注和重视，而在国内也开始有少数学校开展了一些初步的学习和相关的研究工作。
作为国外具有一定影响的分析程序和开发平台，
OpenSees还具有以下一些突出特点：便于改进，易于协同开发，保持国际同步。OpenSees主要用于结构和岩土方面的地震反应模拟。可以实现的分析包括：简单的静力线弹性分析，静力非线性分析，截面分析，模态分析，Pushover拟动力分析，动力线弹性分析和复杂的动力非线性分析等；还可用于结构和岩土体系在地震作用下的可靠度及灵敏度的分析。自从1999年推出以来，该软件不断进行升级和提高，加入了许多新的材料和单元，引入了许多业已成熟的Fortran库文件为己所用(如FEAP、FEDEAS材料)，更新了高效实用的运算法则和判敛准则，允许多点输入地震波纪录，并不断提高运算中的内存管理水平和计算效率，允许用户在脚本层面上对分析进行更多控制。
OpenSees的另一个优点就是使用面向对象的先进程序框架设计，基于C++的源代码公开有限元程序，方便使用者按照自己的需求进行二次开发。并且，基于此框架易于实现并行计算。它的主要特点归纳如下：
（1）源码公开，学术界共同开发和共享代码，实现科研合作，持续集成最新科研成果；
（2）OpenSees突出强非线性（土和结构非线性），针对强非线性开发的算法；
（3）基于C++面向对象的先进程序框架设计以及基于此构架先进的并行计算方法；
（4）敏感性可靠度和优化分析；
（5）高性能云计算，比如Open Science Grid、TerraGrid;
（6）通过OpenFresco等技术，实现和其他系统的集成以及混合实验等。
# Tcl命令语言简介
=================
选择了Tcl脚本语言来支持OpenSees命令，这些命令用于定义问题几何，加载，配方和解决方案。这些命令是具有特定任务的单行命令。Tcl语言提供了有用的编程工具，如变量操作，数学表达式评估和控制结构。
Tcl是一个基于字符串的脚本语言，它允许以下内容：
（1）变量和变量替换
（2）数学表达评估
（3）基本的控制结构(if , while, for, foreach)
（4）程序
（5）文件操作
有关Tcl命令的更多信息可以在其网站上找到：Tcl / Tk
[Primer](http://dev.scriptics.com/scripting/primer.html)
Tcl语言命令：
*incr* - Increment the value of a variable（增加一个变量的值）:
*set a 1*
*incr a*
参考:
Brent Welch \<welch\@acm.org\>, Ken Jones, and Jeff Hobbs: 
[Practical Programming in Tcl and Tk,](http://www.beedub.com/book/) 
[4th Edition ISBN:0-13-038560-3, June, 2003](http://www.beedub.com/book/)
## Tcl命令格式
---------------
Tcl脚本由用新行或分号（;）分隔的命令组成。
Tcl命令的基本语法是：
*command \$arg1 \$arg2 ...*
command? ：Tcl命令的名称或用户定义的过程
\$arg1 \$arg2 ：命令参数
Tcl允许任何参数嵌套命令：
*command [nested-command1] [nested-command2]*
其中[]用于分隔嵌套的命令。Tcl解释器将首先评估嵌套命令，然后评估外部命令，并将结果嵌入到嵌套命令中。
Tcl中最基本的命令是set命令：
*set variable \$value*
例如：
*set a 5*
Tcl解释器认为一个以井号（＃）开始的命令是一个注释语句，所以它不会执行＃之后的任何内容。例如：
*＃*这个命令给变量a赋值5
*set a 5*
英镑符号和分号可以一起用来将注释放在与命令相同的行上。例如：
*set a 5*； ＃这个命令给变量a赋值5
Tcl命令示例，如下表所示。
*set a*
## Tcl命令示例
---------------

| Arithmetic       | procedure                                                                                                                                                                           | for& foreach functions                                                                                                                               |
|------------------------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| *\>set a 1 1 \>set b a a \>set b \$a 1 \>expr 2 + 3 5 \>expr 2 + \$a 3 \>set b [expr 2 + \$a] 3 \>*                    | *\>proc sum {a b} { return [expr \$a + \$b] } \>sum 2 3 5 \>set c [sum 2 3] 5 \>*                                                                                                   | *for {set i 1} {\$i \< 10} {incr i 1} 
{ puts "i equals \$i" } set sum 0 foreach value {1 2 3 4} { set sum [expr \$sum + \$value] } puts \$sum 10 \>* |
| file manipulation                                                                                                      | procedure & if statement                                                                                                                                                            |                                                                                                                                                      |
| *\>set fileId [open tmp w] anumber \>puts \$fileId "hello" \>close \$fileID \>type tmp hello \> \>source Example1.tcl* | *\>proc guess {value} { global sum if {\$value \< \$sum} { puts "too low" } else { if {\$value \> \$sum} { puts "too high" } else { puts "you got it!"} } } \> guess 9 too low \>*  |                                                                                                                                                      |

##  Tcl的其他资源
-----------------
<http://www.freeprogrammingresources.com/tcl.html>;
http://www.tcl.tk/man/Tcl/Tkmanualpages;
<http://www.mit.edu/afs/sipb/user/golem/doc/tcltk-iap2000/TclTk1.html>
(通过在一个简短的程序中描述它们的实现来描述许多命令的教程);
<http://www.beedub.com/book/>
(一些来自Tcl和Tk的编程实例的章节，由Welch和Jones编写);
http://philip.greenspun.com/tcl/;
<http://www.tcl.tk/scripting/>;
<http://hegel.ittc.ukans.edu/topics/tcltk/tutorial-noplugin/index.htm>
（一个关于基本Tcl命令的简短教程，在下面的网站中也包含一个Tcl / Tk命令手册）
## OpenSees编译器
------------------

OpenSees的主要抽象将使用OpenSees解释器进行解释。解释器是Tcl脚本语言的扩展。OpenSees解释器将命令添加到Tcl进行有限元分析。这些命令中的每一个都与提供的C
++过程相关联。解释器调用这个过程来解析命令。在这个文档中，我们只概述那些被OpenSees添加到Tcl中的命令。

对于OpenSees，我们向Tcl添加了有限元分析的命令：

*Modeling* – create nodes, elements, loads and
constraints（创建节点，元素，载荷和约束）；

*Analysis* – specify the analysis procedure（指定分析过程）

*Output specification* – specify what it is you want to monitor during the
analysis（指定在分析过程中要监视的内容）

# Opensees 基本概况
===================

# OpenSees概述
----------------

OpenSees的全称是Open System for Earthquake Engineering Simulation
（地震工程模拟的开放体系）。它是由美国国家自然科学基金（NSF）资助、西部大学联盟“太平洋地震工程研究中心”（Pacific
Earthquake Engineering Research
Center，简称PEER）主导、加州大学伯克利分校为主研发而成的、用于结构和岩土方面地震反应模拟的一个较为全面且不断发展的开放的程序软件体系。

在Silvia Mazzoni, Frank McKenna, Michael H. Scott, Gregory L.
Fenves等人编写的OpenSEES的Users Manual (v2.0)开篇，是这样回答“What is
OpenSees?”这个问题：

（1）它是用有限元方法模拟地震工程应用的软件框架。 OpenSees不是一个代码；

（2）在PEER，NEES及其以外的交流机制，交流和建立研究成果；

（3）作为开源软件，它具有建立地震工程社区代码的潜力。

OpenSees可以描述一个结构/模型。多个级别组件：

![图1](114b5d55abb9b8a74bb18b1bcb0a2dca.png)

![图2](3a04b2f3ba77e09e1d4a195a723210b2.png)

传统的代码与OpenSees代码对比

![图3](46afa9afcf5fa20bf42a6c9a6f73d79e.png)

**Opensees计算仿真分区**

OpenSees由一组模块组成，用于执行有限元模型的创建，分析过程的说明，分析过程中要监测的量的选择以及结果的输出。
在每个有限元分析中，使用分析来构建4个主要类型的主题，如下图所示：

![图4](3b1adcfc091178afbb2f106514eed312.png)

Domain对象负责存储由ModelBuilder对象创建的对象，并提供对这些对象的分析和记录器对象的访问权限。

![图6](3a471a82ccc457c44eba5125317e883a.png)

Analysis对象负责执行分析。分析将模型从t时刻的状态转移到t +
dt时刻的状态。这可能会从简单的静态线性分析到瞬态非线性分析。在OpenSees中，每个Analysis对象由多个组件对象组成，这些组件对象定义了如何执行分析的分析类型。

![图7](df03b2f5e7ca2bcccbbfaa784be671c3.png)

3.2 OpenSees 特性
-----------------

为什么选择OpenSees？

（1）材料，元素和分析命令库使得OpenSees成为非线性结构和岩土系统数值模拟的强大工具；

（2）OpenSees组件库不断增长，处于数值模拟模型的前沿；

（3）OpenSees界面基于命令驱动的脚本语言，使用户能够创建更多功能的输入文件；

（4）OpenSees不是黑匣子，使其成为数值模拟的有用教育工具；

（5）可以创建自己的材料，元素或分析工具，并将它们合并到OpenSees machine中；

（6）NEES正在支持将OpenSees集成为实验室测试的模拟组件。

模型：
- 线性和非线性结构和岩土模型
模拟：
- static push-over analyses
- static reversed-cyclic analyses
- dynamic time-series analyses
- uniform-support excitation
- multi-support excitation
