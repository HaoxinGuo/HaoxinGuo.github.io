---
title: 爬虫51job，51租房
top: false
cover: false
toc: true
mathjax: true
date: 2019-10-06 19:49:25
password:
summary:
tags:
- Spyder
categories:
---
# 51job
```python
import requests
from bs4 import BeautifulSoup as bs
import time


def get_data(key_word,page_index):
  try:
    #url = "https://search.51job.com/list/060000,000000,0000,00,9,99,{0},2,{1}.html?lang=c&stype=1&postchannel=0000&workyear=99&cotype=99&degreefrom=99&jobterm=99&companysize=99&lonlat=0%2C0&radius=-1&ord_field=0&confirmdate=9&fromType=&dibiaoid=0&address=&line=&specialarea=00&from=&welfare="
    #url = "https://search.51job.com/list/020000,000000,0000,00,9,99,{0},2,{1}.html?lang=c&stype=&postchannel=0100&workyear=99&cotype=99&degreefrom=99&jobterm=99&companysize=99&providesalary=99&lonlat=0%2C0&radius=-1&ord_field=0&confirmdate=9&fromType=&dibiaoid=0&address=&line=&specialarea=00&from=&welfare=
    #url= "https://search.51job.com/list/000000,000000,0000,00,9,99,{0},2,{1}.html?lang=c&stype=&postchannel=0100&workyear=99&cotype=99&degreefrom=99&jobterm=99&companysize=99&providesalary=99&lonlat=0%2C0&radius=-1&ord_field=0&confirmdate=9&fromType=&dibiaoid=0&address=&line=&specialarea=00&from=&welfare="
    url = "https://search.51job.com/list/020000%252C010000%252C040000%252C030200%252C080200,000000,0000,00,9,99,{0},2,{1}.html?lang=c&postchannel=0100&workyear=99&cotype=99&degreefrom=99&jobterm=99&companysize=99&ord_field=0&dibiaoid=0&line=&welfare="
    url = url.format(key_word,page_index)
    r=requests.get(url)
    r.raise_for_status()
    r.encoding=r.apparent_encoding
    return r.text
  except Exception as e:
    print(e)


def parser_html(content):
  try:
    data=""
    soup = bs(content,"lxml")
    els = soup.select(".el")[16:]
    for row in els:
      position=row.select(".t1 span a")[0].attrs["title"]
      url0 = row.select(".t1 span a")[0].attrs["href"]
      company=row.select(".t2 a")[0].string
      address=row.select(".t3")[0].string
      money=row.select(".t4")[0].string
      dt=time.strftime("%Y",time.localtime())+"-"+row.select(".t5")[0].string
      #total = position+money+dt
      #data+="{0},{1},{2},{3}\n".format(total,company,url0,address)
      data+="{0},{1},{2},{3},{4},{5}\n".format(position,money,dt,company,url0,address)
      print(data)
    return data
  except Exception as e:
    print(e)

def save_file(file,content):
  with open(file,'a+',encoding='utf_8_sig') as f:
    f.write(str(content))
    f.close()

if __name__=="__main__":
  workname = '产品经理'
  for i in range(1,60):
    c=get_data(workname,i)
    content=parser_html(c)
    save_file("%s.csv"%workname,content)
    print(i)
    if len(str(content)) == 0:
      break;
    time.sleep(10)
  print("数据采集完毕")
```

# 51租房

```python
import requests
from bs4 import BeautifulSoup as bs

def house_information(location):
  file = "%s.csv"%location
  print(file)
  url = 'https://sh.58.com/chuzu/?key=%s&classpolicy=main_null,house_B'%location
  print(url)
  html = requests.get(url)
  html.encoding='utf-8'
  html = bs(html.text,"lxml")
  information = html.select(".house-cell")
  for house in information:
    name = house.select('h2')[0].text.strip()
    info = house.select('p')[1].select('a')[1].text
    href = house.select('h2')[0].select('a')[0].attrs['href']
    content = name+','+info+','+href+'\n'
    print(info)
    save(file,content)


def save(file,content):
  with open(file,'a+',encoding='utf_8_sig') as f:
    f.write(content)
    f.close()
  
    
  
if __name__=="__main__":  
  house_information('巴南')
```
# 链家


```python
import requests
from bs4 import BeautifulSoup

def get_html(location):
    file = "%s.csv" % location
    file2="%s.txt" % location
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 6.1; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/64.0.3282.140 Safari/537.36'
    }
    url = "https://sh.lianjia.com/zufang/pg{page}rs%s/#contentList" %location

    page=0
    while page<=2:
        page+=1
        html = requests.get(url.format(page=page),headers=headers)
        html.encoding = 'utf-8'
        htmls = BeautifulSoup(html.text, "lxml")
        content=htmls.select(".content__list--item")
        for house in content:
            name=house.select(".content__list--item--aside")[0].attrs['title']#指定标签
            href=house.select(".content__list--item--aside")[0].attrs["href"]
            info=house.select(".content__list--item--des")[0].select("a")[0].string
            info1 = house.select(".content__list--item--des")[0].select("a")[1].string
            info2 = house.select(".content__list--item--des")[0].select("a")[2].string
            prict = house.find(class_="content__list--item-price").text.strip()#清除两边空格
            data=name+","+info+info1+info2+","+"https://cq.lianjia.com"+href+","+prict.replace(" ","")+"\n"
            save(file, data)
            with open(file2,'a+',encoding='utf_8_sig') as f:
                f.write(info2+" ")
            print(data)

def save(file,content):
  with open(file,'a+',encoding='utf_8_sig') as f:
    f.write(content)
    f.close()


if __name__ == "__main__":
    cha = input("请输入地区：")
    get_html(cha)
```