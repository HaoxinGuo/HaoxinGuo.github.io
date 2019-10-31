---
title: OpenSees学习之Tcl命令学习
top: false
cover: false
toc: true
mathjax: true
date: 2019-10-08 15:24:40
password:
summary: Tcl命令学习
tags:
- Tcl
categories:
- Tcl
- OpenSees
---
# 基本语法
## Tcl命令的基本格式
```Tcl
command arg1 arg2 ...
```
第一个单词comman为命令名,其他单词arg1 arg2为命令的参数，用空格分隔各个单词。
## 基本命令与特殊字符解释
序号 | 命令 | 解释 | 示例
- | - | - |
1 | set | 给变量赋值，格式为```set var value``` |``` set E 1```
2 | unset |删除一个变量，释放内存空间 | ```unset E```
3 | expr | 算术运算符 | ```puts [expr sqrt(E)]```
4 | puts | 输出文本，多个文本如果被空格或者TAB分隔则需要使用“ ” 或者{}括起来 | ```puts "$E $F"```
5 | info exists | 检查变量是否存在，若存在则返回1，不存在返回0 | ```if {![info exists m]} {set m 0} else { set m [expr $m+1]}```
6 | info global | 返回包含所有全局变量名字的一个序列 | ```info global #列出全局变量```
7 | $ | 变量替代符号 | ```set E 1```
8 | [] | 命令替代符 | 
9 | \ | 反斜杠替代符，与特殊字符组成替代字符 |
10 | “” | 可将多个元素组成一个参数，引号内的内容会被Tcl进行置换处理 | ```puts "$E"```
11 | {} | 可将多个元素组成一个参数，引号内的内容不会被Tcl进行置换处理 | ```puts {$E}```
12 | ```#/;#``` | 注释符号 | ```#注释```

## 变量
### 一般变量
1. 大小写有区别
2. 在使用前无需声明
3. 名称和值可以是任意字符串
### 数组
数组是元素的集合。每个元素都有名称和值。元素名称由数组名和数组元素下标组成数组名称和数组元素下标名称可以是任何字符串，包括空格。
### 数组操作命令
序号|命令|解释
-|-|-
1 |array exists arrayName | 判断一个数组是否存在，数组存在返回1，不存在返回0 
1 | array get arrayName | 返回数组值的列表 
1 | array size arrayName| 返回数组的大小 
1 |array set arrayName datalist | 定义数组 
1 | array unset arrayName | 删除数组，释放内存空间
### 操作演示
```Tcl
set data_1(name) liming; #set给数组data_1下标为name的元素设定初值
set data_1(age) 23; # set给数组data_1下标为age的元素设定初值
set data_1(gender) male; #set给数组data_1下标为gender的元素设定初值
set data_1(occpution) work; #set给数组data_1下标为occpution的元素设定初值
set size_data_1 [array size data_1]; # 返回数组大小
puts "$size_data_1"
puts "[array get data_1]"; #取的数组的值列表
array unset data_1; # 删除data_1数组
if{[array exists data_1]==0}{   #判断数组data_1是否存在
	puts "data_1 is not an array"
	} else {
	puts "data_1 is an array"
	}
``` 
## 表达式
表达式将值和操作符结合起来。操作符包括：算术操作符，关系操作符，逻辑操作符。支持的操作符包括：```-;+;*;/;~;<<;>>;&;^;|;&&;||;!;>;<;>=;<=;==;!=;?:```
### 数学函数
数学函数有以下函数：
```tcl
abs(n);acos(n);cos(n);asin(n),sin(n);log10(n);log(n);sqrt(n);exp(n);
max(a,b,c);min(a,b,c);tan(n);atan(n)
```
## 控制结构

### while
while命令需要两个参数：condition和statement，程序先处理conditon表达式，如果表达式非0，就执行statement，循环至condition为假时，退出循环。
### while使用示例
```Tcl
set n 0;
set sum 0;
while{$n<5}{incr n; set sum [expr $sum + $n]};
puts "sum is $sum"
switch --$sum{
	15{puts "sum is $sum"}
	default{puts "sum is not $sum}
	}
```
### if
if命令需要两个参数：condition和statement，程序先处理conditon表达式，如果表达式非0，就执行statement，condition为假时，退出if。if命令还可以有elseif子句和一个else子句。

### for
for命令需要四个参数，initial，test，final，statement。第一个参数initial初始化脚本，第二个参数test为终止循环的表达式判断语句，第三个参数final为每执行一次statement需要执行的程序，一般为增减计数值。第四个参数为statement为结构循环体的脚本。

### foreach
foreach命令需要三个参数，var，list,statement，第一个参数var是变量名，第二个list为列表，第三个参数为构成循环体的Tcl脚本。Foreach对列表中的每一个元素执行Tcl脚本，在每次执行前，foreach将变量设为列表的下一个元素。

### for和foreach使用示例
```Tcl
set sum_10
for {set n 0}{$n<6}{incr n}{
	set sum_1 [expr $sum_1 + $n]
	}
set sum_2 0;
set list [list 1 2 3 4 5]
foreach m $list {
	set sum_2 [expr $sum_2 + $m]
	}
puts "sum_1 is $sum_1"
puts "sum_2 is $sum_2"
if{$sum_1<$sum2}{
	puts "$sum_2 is greater than $sum_1"
	} elseif {$sum_1>$sum_2}{
	puts "$sum_1 is greater than $sum_2"
	} else {
	puts "$sum_1 is equal than $sum_2"
	}
```

### 基本格式
序号|命令|基本格式
-|-|-
 1| ```if``` | ```if(condition){statement_1}```
 2|  ```if else``` | ```if(condition){statement_1}else{statement_2}```
 3| ```if elseif else``` | ```if(condition){statement_1}elseif{statement_2}else{statement_3}```
 4|  ```switch``` | ```switch flag value{    pattern1 body1 pattern2 body2  ...}```
 5|   ```while``` | ```while{condition}{statement}```
 6|   ```for``` | ```for{initial}{test}{final}{statement}```
 7| ```foreach``` | ```foreach var list {statement}```

## 过程
proc命令用来定义问题的解决过程，他使得Tcl的脚本易于使用，其基本格式为
```Tcl
proc ProcName arglist body
```
第一个单词Proc为过程命令，定义了名为ProcName的过程，arglist是一个过程的参数列表，body为过程块。除非用return明确返回指定值，否则返回值一般为最后一行执行的结果。
示例如下：
```Tcl
Proc sum {num1 num2 num3} {
	set m [expr $num1+$num2+$num3]
	return $male
	}
set a 1
set b 2
set c 3
puts "The sum of $a + $b + $c is [sum $a $b $c]"
```
## 文件操作
Tcl能够对文件进行操作，比如复制，删除文件、读取文件等。
### 命令解释
序号|命令|解释
-|-|-
 1| cd | 将当前目录转换为指定目录
 2| pwd |  显示当前目录
 3| source |  读入文件
 4| file mkdir |  创建目录
 5| file delete |  删除文件
 6| file copy | 复制文件
 7| file exits|  检查文件是否存在
 
示例：

```Tcl
file mkdir Data
logFile Data/data.txt
if{[File exists Data]==0}{
	file mkdir Data;
	logFile Data/data.txt
	} else {
	file copy Data Data_1;
	file delete Data_1/data.txt
	}
cd Data_1
pwd
```