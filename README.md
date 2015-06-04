# que
[![Build Status](https://travis-ci.org/DavidCai1993/que.svg)](https://travis-ci.org/DavidCai1993/que)
[![Coverage Status](https://coveralls.io/repos/DavidCai1993/que/badge.svg?branch=master)](https://coveralls.io/r/DavidCai1993/que?branch=master)

## 简介
一个基于`redis`的任务队列，支持分布式（基于http），可横向拓展，错误警告与重试。

## benchmark
在自己的最低配阿里云上（单核CPU，1GB内存，1M带宽），利用`ab`发起10k并发任务请求（[script](https://github.com/DavidCai1993/que/blob/master/benchmark/script.coffee)）：
```SHELL
ab -n 10000 -c 10000 -p 'post.txt' -T 'application/json' http://127.0.0.1:8083/task
```

```SHELL
#output
Server Software:
Server Hostname:        127.0.0.1
Server Port:            8083

Document Path:          /task
Document Length:        22 bytes

Concurrency Level:      10000
Time taken for tests:   13.323 seconds
Complete requests:      10000
Failed requests:        0
Write errors:           0
Total transferred:      1640000 bytes
Total POSTed:           1594670
HTML transferred:       220000 bytes
Requests per second:    750.58 [#/sec] (mean)
Time per request:       13322.956 [ms] (mean)
Time per request:       1.332 [ms] (mean, across all concurrent requests)
Transfer rate:          120.21 [Kbytes/sec] received
                        116.89 kb/s sent
                        237.10 kb/s total

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0 1653 2119.5    722    7005
Processing:   100  863 906.1    470    6949
Waiting:       94  863 906.1    469    6949
Total:        254 2517 2139.3   1797   11185

Percentage of the requests served within a certain time (ms)
  50%   1797
  66%   3245
  75%   3371
  80%   3438
  90%   7294
  95%   7513
  98%   7627
  99%   7952
 100%  11185 (longest request)
```

## 使用

### 安装
直接通过npm：
> que使用了ES6的相关特性，请在运行时加上`harmony`选项，或者使用io.js运行

```SHELL
npm install node-que --save
```

### 例子
```coffee
#单机模式
Que = require 'node-que'

queue = new Que 'myTaskQue'
queue.on 'done', (err, result) ->
  if err then console.error err
  console.log "done! result: #{result}"

handler = (taskData) ->
  new Promise (resolve, reject) ->
    #对传入数据进行自定义操作...
    resolve taskData.data
    
#指定处理函数
queue.processor handler

queue.push {data: 'myData'} for i in [0..10]
```

```coffee
#分布模式
#master，调度分配节点
Que = require 'node-que'
request = require 'superagent'

masterQue = new Que 'myTaskQue'
masterQue.master(['http://localhost:8081', 'http://localhost:8082']).listen 8083
masterQue.on 'done', (err, result) ->
  if err then console.error err
  console.log "done! result: #{result}"

#salve，工作节点
handler = (taskData) ->
  new Promise (resolve, reject) ->
    #对传入数据进行自定义操作...
    resolve taskData.data

salveQue1 = new Que 'myTaskQue'
salveQue2 = new Que 'myTaskQue'
salveQue1.salve(handler).listen 8081
salveQue2.salve(handler).listen 8082

#从脚本中向队列推入数据
masterQue.push {data: 'by script'} for i in [0..10]

#通过http api向队列推入数据
request
  .post 'http://localhost:8083/task'
  .send {data: 'by http api'}
  .set 'Accept', 'application/json'
  .end (err, res) ->
    if err then console.error err
    console.log res.status
```

### API

#### new Que(queueName)
queueName: 赋予任务队列的名字，用于区分不同队列，在分布模式下，`master`/`salve`队列的名字必须相同

生成一个Que实例

#### push(taskData)
taskData: 待处理数据

将待处理数据推入任务队列（`redis list`），暂只支持本地`redis`

#### processor(handler)
handler(taskData): 数据的处理函数，参数既是队列中的一个待处理数据，必须返回一个Promise实例

指定数据的处理函数

#### 错误处理与重试
队列中的每个任务在处理出现错误时，`Que`都会对其进行重试，若重试`5次`仍然未成功，则放弃这个任务

#### getNumberOfProcessed()
获取队列中已经处理完成的任务数

#### getNumberOfRejected()
获取队列中重试5次仍未成功后被放弃的任务数

#### master(salves).listen(port)

salves: 分布模式中，所有`salve工作节点`的地址数组

port: 此`master分配调度节点`的监听端口

启动分布模式，将此Que作为master节点，并指定所有salves

#### salve(handler).listen(port)

handler(taskData): 数据的处理函数，参数既是队列中的一个待处理数据，必须返回一个Promise实例

port: 此`salve工作节点`的监听端口

#### stop()
关闭队列

### http API

#### POST /task
将待处理数据推入处理队列

#### GET /task/processed
获取队列中已经处理完成的任务数

#### GET /task/rejected
获取队列中重试5次仍未成功后被放弃的任务数
