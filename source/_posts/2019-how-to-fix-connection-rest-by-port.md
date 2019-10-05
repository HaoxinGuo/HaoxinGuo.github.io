---
title: how to fix connection rest by port-GIt
top: false
cover: false
toc: true
mathjax: true
date: 2019-10-03 16:54:05
password:
summary:
tags:
- Git
categories:
- Git
---
## 问题
今天就在准备更新我的博客的时候发现突然git连不上我的repositories
经过测试发现Connection reset的问题：
```
$ ssh -T git@github.com
Connection reset by 52.74.223.119 port 22
```
一直这样提示报错，经过百度几番查找，以为是ssh出问题了，删掉原来的ssh,然后重新生成并add到github上，然而事实并没有这么简单
$ ssh -T git@github.com
Connection reset by 52.74.223.119 port 22
ping github.com 
正常
ping github.global.ssl.fastly.net
无法连接
原因：
DNS无法解析
解决方案：
打开hosts(windows/system32/drivers/etc/hots)add:
192.30.255.112  github.com git 
185.31.16.184 github.global.ssl.fastly.net