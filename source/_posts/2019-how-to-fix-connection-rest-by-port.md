---
title: 2019-how to fix connection rest by port
top: false
cover: false
toc: true
mathjax: true
date: 2019-10-03 16:54:05
password:
summary:
tags:
categories:
---
## ����
�������׼�������ҵĲ��͵�ʱ����ͻȻgit�������ҵ�repositories
�������Է���Connection reset�����⣺
```
$ ssh -T git@github.com
Connection reset by 52.74.223.119 port 22
```
һֱ������ʾ���������ٶȼ������ң���Ϊ��ssh�������ˣ�ɾ��ԭ����ssh,Ȼ���������ɲ�add��github�ϣ�Ȼ����ʵ��û����ô��
$ ssh -T git@github.com
Connection reset by 52.74.223.119 port 22
ping github.com 
����
ping github.global.ssl.fastly.net
�޷�����
ԭ��
DNS�޷�����
���������
��hosts(windows/system32/drivers/etc/hots)add:
192.30.255.112  github.com git 
185.31.16.184 github.global.ssl.fastly.net