---
title: OpenSees坐标转换
top: false
cover: false
toc: true
mathjax: true
date: 2019-10-09 16:59:48
password:
summary:
tags:
- CrdTrans
- OpenSees
categories:
- OpenSees
---
# 坐标转换
在opensees建模时需要用到几何坐标转换，使用几何转换命令（geomTransf）构造坐标转换（CrdTransf）对象，将梁单元的刚度和抗力从基础坐标系转换到全局坐标系。该命令至少有一个参数，即转换类型。下面概述了每种类型。
## 线性转换
该命令用于构造线性坐标变换（LinearCrdTransf）对象，该对象执行从基础系统到全局坐标系的梁刚度和阻力的线性几何变换。
对于一个二维问题：
```Tcl
geomTransf Linear $transfTag <-jntOffset $dXi $dYi $dXj $dYj>
```
对于一个三维问题：
```Tcl
geomTransf Linear $transfTag $vecxzX $vecxzY $vecxzZ <-jntOffset $dXi $dYi $dZi $dXj $dYj $dZj>
```
**二维框架分析不需要指定局部坐标方向**，故可以采用以下方式定义坐标转换：
```
gemTransf Linear $transfTag
```
## 参数解析

参数|解释
-|-
 $transfTag | 坐标变换编号
 $vecxzX $vecxzY $vecxzZ |  vecxz的X，Y和Z分量，用于定义局部坐标系的局部x-z平面的向量，通过取x轴与vecxz向量的叉积来定义局部y轴。这些分量在全局坐标系X，Y，Z中指定，并定义一个在与局部坐标系的x-z平面平行的平面中的向量。对于三维问题，需要指定这些项目。
 $dXi $dYi $dZi |  节点偏移值-相对于元素节点i的全局坐标系指定的绝对偏移（参数数取决于当前模型的尺寸）（可选）
 $dXj $dYj $dZj |  节点偏移值-相对于元素节点j的全局坐标系指定的绝对偏移（参数数取决于当前模型的尺寸）（可选） 

## 单元局部坐标系指定如下
x轴是连接两个单元节点的方向; 然后使用位于与局部x-z平面平行的平面上的矢量 - vecxz来定义y轴和z轴。y轴是通过取vecxz向量和X轴向量的叉积定义的。
该部分附加到该单元，使得用于指定该部分的y-z坐标系对应于该单元的y-z轴。
![](https://raw.githubusercontent.com/HaoxinGuo/PicBed/master/Blog/U1.jpg)
![](https://raw.githubusercontent.com/HaoxinGuo/PicBed/master/Blog/U2.jpg)
![](https://raw.githubusercontent.com/HaoxinGuo/PicBed/master/Blog/U3.jpg)

## 注意
	1. 局部坐标系的x方向始终沿着杆的方向，z方向垂直纸面向外，基于此可以确定局部y方向。
	2. gemTransf的后面的三个参数($vecxzX $vecxzY $vecxzZ)定义了一个新的方向，此方向为局部坐标系中x'z'平面上的一个方向，将此方向和x'方向叉乘（符合右手规则），就得到局部坐标系的y'方向，然后根据局部坐标系的x'和y'叉乘得到局部坐标系的z’方向。
	