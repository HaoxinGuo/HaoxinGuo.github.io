---
title: markdown文件和Word文件的转换
top: false
cover: false
toc: true
mathjax: true
date: 2019-09-30 18:00:11
password:
summary: 在使用markdown和Word时存在转换格式的问题，整理了快速转换的方法。
tags:
- 软件 技巧 Markdown Word
categories:
- 软件
---

# 问题描述
在markdown中写作完成初稿，之后在word中进行精细化排版设置。这就需要markdown转换word。以前一直没有找到合适的工具，今天终于发现了一个理想的工具：Writage。
# 技术背景
Writage是一款word插件，下载网址为：http://www.writage.com/
- 功能：支持markdown与word互相转换

安装：
- Writage，word插件
- Pandoc，文档转换后台软件

实际上实现文档格式转换的是pandoc软件，Writage作为word插件，将pandoc的功能集成到了word选项中，避免了繁琐的cmd 命令操作。
# 解决方案

安装Writage和Pandoc软件后，word中不会直接出现选项卡，但在【打开】和【保存】的对话框中会出现相关的选项，如下：
##  markdown转换word

- 通过word软件打开markdown文件实现：
- 打开原markdown文档后，另存为word格式即可；
## word转换markdown

- 首先设置word文档中的标准样式，如一级、二级标题等，如此才能与markdown的格式对应；
- word格式另存为markdown；

# 实施示例
## 插件安装

- 下载软件：http://www.writage.com/
- 分别安装软件，全部按照默认安装即可
- 重启电脑
## markdown转换word

- 创建markdown文档，可以在任意编辑器，如cmd markdown
- 导出markdown文本文档
- word软件打开markdown
- word中markdown文档的预览效果如下
	由于markdown中的图片无法设置大小，因此在word中排布的图片格式不标准，需要人工调整。其他格式，如一级、二级标题，项目列表等基本没有问题。
- 调整格式后，即可保存为word、pdf等格式
## word转换markdown

直接另存为markdown格式即可：
各级标题的设置，实际上在markdown编辑器中更方便修改设置。
# 常见问题

markdown转换word的过程中，尤其需要注意的问题是：图片的下载和存储。
## markdown转换word

在原生的markdown文档中，图片以网络超链接的形式保存：
以上的网址即为图片的网络路径，如果markdown文档中有这一类图片，那么需要在网络连接的情况下，才能正常输出有图片的word文档。否则，图片处显示空白。

## word转换markdown

word转换markdown之后，文档中的图片输出到本地文件夹media下：
文件夹与输出的markdown文档在同一目录下:
在markdown中图片引用本地相对路径：
故必须保证markdown与media文件夹在一起，才能完整的在markdown编辑器中显示图片。