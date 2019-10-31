---
title: python study
top: false
cover: false
toc: true
mathjax: true
date: 2019-10-18 21:57:38
password:
summary:
tags:
- Python
categories:
- Python
---

```Python
from random import randint
money = 1000
while money>0:
	print('your money is ',money)
	needs_go_on = True
	while(True):
		debt = int(input('请下注:'))
		if 0 < debt <=money:
			break
	first = randint(1,6)+randint(1,6)
	print("玩家摇出了%d点"%first)
	if first==7 or first==11:
		print("玩家胜")
		money +=debt
	elif first==2 or first==3 or first==12:
		print("庄家胜")
		money -=debt
	else:
		needs_go_on = True
	while needs_go_on:
		needs_go_on = False
		current = randint(1,6)+randint(1,6)
		print("玩家摇出了%d点"%current)
		if current==7:
			print("庄家胜")
			money -=debt
		elif current==first:
			print("玩家胜")
			money +=debt
		else:
			needs_go_on = True
print('你输了，游戏结束')
```