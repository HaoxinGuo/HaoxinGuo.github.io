---
title: OpenseesStudy-RecoderNode
top: false
cover: false
toc: true
mathjax: true
date: 2019-10-09 12:03:01
password:
summary: 记录节点。
tags:
- Opensees
- Recorder
categories:
- Opensees
---


----
# 命令详细解释

记录节点在每一步的值，其命令格式如下：
```Tcl
recorder Node <-file $fileName> <-xml $fileName> <-binary $fileName> <-tcp $inetAddress $port> <-precision $nSD>  <-timeSeries $tsTag> <-time> <-dT $deltaT> <-closeOnWrite> <-node $node1 $node2 ...> <-nodeRange $startNode $endNode> <-region $regionTag> -dof ($dof1 $dof2 ...) $respType
```

字符段 | 解释
-|-
```$fileName``` |  输出记录器数据到文件
```-xml $fileName``` | 输出记录器数据+xml元数据标记每列数据（-file和-xml不能同时指定）
```-time``` | 这个参数会把第一个入口的伪时间放在行中。（可选，默认：省略）
 ```-closeOnWrite``` | 可选项，使用此选项将指示记录器在每个时间步之后调用数据处理程序上的关闭。如果这是一个文件，它将在每个步骤关闭该文件，然后为下一步重新打开它。 注意，这极大地减慢了执行时间，但是如果您需要在分析期间监视数据，则很有用。
 ```$deltaT``` | 记录时间间隔。 将在下一个步骤比上一个记录器步骤大deltaT时进行记录。 （可选，默认值：在每个时间步记录）
 ```$tsTag``` | 先前构造的TimeSeries的标记，将节点在每个时间步的结果添加到序列的负载因子中
```$node1 $node2 ..``` | 标记正在记录响应的节点-选择域中的节点（可选，默认：全部）
```$startNode $endNode ..``` |记录响应的开始和结束节点的标记-域中节点的范围（可选，默认值：全部）
```$regionTag``` | 标记以前定义的使用“区域”命令定义的节点选择。（可选的）
```$dof1 dof2 ...``` | 记录响应的自由度，有效范围是从1到ndf，节点的自由度数。
 ```$respType``` | 定义要记录的响应类型。
 
以下响应类型可用:

位移项可选择的内容| 解释
-|-
```disp``` |位移
```vel``` | 速度
```accel``` | 加速度
```incrDisp``` | 增量位移 
```eigen i```| 模式i的特征向量
```reaction``` | 节点反应
```rayleighForces``` | 阻尼力

# 返回值
0表示成功，-1表示命令失败。
# 注意事项

* Only one of -file, -xml, -binary, -tcp will be used. If multiple specified last option is used.
* -tcp option only available for version 2.2.1 and higher.
* In case you want to remove a recorder you need to know the tag for that recorder. Here is an example on how to get the tag of a recorder: 
set tagRc [recorder Node -file nodesD.out -time -node 1 2 3 4 -dof 1 2 disp]


# EXAMPLES

1.
	recorder Node -file nodesD.out -time -node 1 2 3 4 -dof 1 2 disp; 
文件nodesD.out包括节点1,2,3,4在X，Y方向的**相对位移**。文件共有9列：time 1X 1Y 2X 2Y 3X 3Y 4X 4Y

2.
	recorder Node -file nodesA.out -timeSeries 1 -time -node 1 2 3 4 -dof 1 accel; 
文件NodeA.out记录了节点1，2,3,4的绝对加速度（地面加速度+相对加速度）在X方向的值。如果没有关键词 TimeSeries 则为相对速度。

----
