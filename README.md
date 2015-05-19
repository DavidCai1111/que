# que
[![Build Status](https://travis-ci.org/DavidCai1993/que.svg)](https://travis-ci.org/DavidCai1993/que)
[![Coverage Status](https://coveralls.io/repos/DavidCai1993/que/badge.svg?branch=master)](https://coveralls.io/r/DavidCai1993/que?branch=master)

que

```SHELL
ab -n 10000 -c 10000 -p 'post.txt' -T 'application/json' http://127.0.0.1:8083/task
```

```SHELL
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

