# Numerical Performance (2020-04-29T16:36:54.075)

## Instance: sc50a

nrows   : 50
ncols   : 48
nnz     : 130
sparsity: 0.05416666666666667

### CPU

```
Final objective value: -70.01264227388191
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1234s / 0.67%           3.84GiB / 25.3%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        1    8.30s   100%   8.30s   0.97GiB  100%   0.97GiB
   presolve                 1    3.83s  46.1%   3.83s    535MiB  53.9%   535MiB
     row reduction          1    3.82s  46.1%   3.82s    535MiB  53.9%   535MiB
   run core                 1    3.53s  42.5%   3.53s    368MiB  37.0%   368MiB
     Phase 1                1    3.39s  40.9%   3.39s    353MiB  35.5%   353MiB
       One iteration       11    794ms  9.57%  72.2ms   88.9MiB  8.95%  8.08MiB
         PF                10    393ms  4.73%  39.3ms   52.2MiB  5.25%  5.22MiB
         ratio test        10   99.0ms  1.19%  9.90ms   10.0MiB  1.01%  1.00MiB
         compute di...     10   94.9ms  1.14%  9.49ms   5.38MiB  0.54%   551KiB
         compute en...     11   69.1ms  0.83%  6.28ms   4.38MiB  0.44%   407KiB
           compute ...     11   69.0ms  0.83%  6.27ms   4.34MiB  0.44%   404KiB
         update basis      10   12.2ms  0.15%  1.22ms   1.67MiB  0.17%   171KiB
         compute pB        11   11.0ms  0.13%   996μs    764KiB  0.08%  69.4KiB
         detect cycly      10   16.8μs  0.00%  1.68μs   9.02KiB  0.00%     923B
       inverse              1    577ms  6.95%   577ms   75.1MiB  7.55%  75.1MiB
       compute xB           1    148ms  1.79%   148ms   23.3MiB  2.34%  23.3MiB
     Phase 2                1   1.22ms  0.01%  1.22ms    828KiB  0.08%   828KiB
       One iteration       21   1.04ms  0.01%  49.4μs    640KiB  0.06%  30.5KiB
         PF                20    321μs  0.00%  16.0μs    390KiB  0.04%  19.5KiB
         ratio test        20    229μs  0.00%  11.5μs   88.2KiB  0.01%  4.41KiB
         compute en...     21    144μs  0.00%  6.85μs   68.9KiB  0.01%  3.28KiB
           compute ...     21   64.5μs  0.00%  3.07μs   42.9KiB  0.00%  2.04KiB
         compute pB        21   48.1μs  0.00%  2.29μs   22.3KiB  0.00%  1.06KiB
         compute di...     20   32.9μs  0.00%  1.64μs   15.7KiB  0.00%     802B
         detect cycly      20   24.7μs  0.00%  1.24μs   18.0KiB  0.00%     923B
         update basis      20   10.5μs  0.00%   523ns   1.88KiB  0.00%    96.0B
       inverse              1    140μs  0.00%   140μs    182KiB  0.02%   182KiB
       compute xB           1   20.3μs  0.00%  20.3μs   3.47KiB  0.00%  3.47KiB
   scaling                  1    881ms  10.6%   881ms   86.1MiB  8.67%  86.1MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -70.01264227388192
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1254s / 2.28%           5.64GiB / 49.1%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        2    28.6s   100%   14.3s   2.77GiB  100%   1.39GiB
   run core                 2    23.1s  80.6%   11.5s   2.12GiB  76.6%  1.06GiB
     Phase 1                2    13.8s  48.0%   6.88s   1.52GiB  54.9%   778MiB
       One iteration       22    3.09s  10.8%   140ms    388MiB  13.7%  17.6MiB
         PF                20    1.57s  5.48%  78.4ms    219MiB  7.73%  11.0MiB
         ratio test        20    376ms  1.31%  18.8ms   42.2MiB  1.49%  2.11MiB
         compute di...     20    322ms  1.12%  16.1ms   43.1MiB  1.52%  2.16MiB
         compute en...     22    113ms  0.39%  5.13ms   7.46MiB  0.26%   347KiB
           compute ...     22   92.2ms  0.32%  4.19ms   7.17MiB  0.25%   334KiB
         compute pB        22   94.6ms  0.33%  4.30ms   6.21MiB  0.22%   289KiB
         update basis      20   12.5ms  0.04%   624μs   1.67MiB  0.06%  85.5KiB
         detect cycly      20   41.3μs  0.00%  2.07μs   18.0KiB  0.00%     923B
       inverse              2    2.42s  8.45%   1.21s    245MiB  8.63%   122MiB
       compute xB           2    770ms  2.69%   385ms   95.5MiB  3.37%  47.8MiB
     Phase 2                2   53.7ms  0.19%  26.9ms   3.04MiB  0.11%  1.52MiB
       One iteration       45   52.8ms  0.18%  1.17ms   2.84MiB  0.10%  64.6KiB
         ratio test        43   28.1ms  0.10%   654μs    920KiB  0.03%  21.4KiB
         compute en...     45   11.5ms  0.04%   254μs    557KiB  0.02%  12.4KiB
           compute ...     45   2.91ms  0.01%  64.7μs    343KiB  0.01%  7.61KiB
         PF                43   4.01ms  0.01%  93.3μs    770KiB  0.03%  17.9KiB
         compute pB        45   1.57ms  0.01%  34.9μs    134KiB  0.00%  2.99KiB
         compute di...     43   1.30ms  0.00%  30.2μs    123KiB  0.00%  2.85KiB
         update basis      43    642μs  0.00%  14.9μs   15.5KiB  0.00%     370B
         detect cycly      43   74.2μs  0.00%  1.73μs   38.7KiB  0.00%     921B
       inverse              2    553μs  0.00%   277μs    193KiB  0.01%  96.7KiB
       compute xB           2    273μs  0.00%   137μs   15.3KiB  0.00%  7.66KiB
   presolve                 2    3.83s  13.4%   1.92s    539MiB  19.0%   269MiB
     row reduction          2    3.83s  13.4%   1.91s    538MiB  19.0%   269MiB
   scaling                  2    884ms  3.09%   442ms   87.4MiB  3.08%  43.7MiB
 ──────────────────────────────────────────────────────────────────────────────
```
## Instance: sc50b

nrows   : 50
ncols   : 48
nnz     : 118
sparsity: 0.049166666666666664

### CPU

```
Final objective value: -69.99999999999997
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1254s / 2.28%           5.65GiB / 49.2%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        3    28.6s   100%   9.54s   2.78GiB  100%    948MiB
   run core                 3    23.1s  80.6%   7.69s   2.12GiB  76.5%   725MiB
     Phase 1                3    13.8s  48.0%   4.58s   1.52GiB  54.8%   519MiB
       One iteration       40    3.09s  10.8%  77.2ms    388MiB  13.7%  9.71MiB
         PF                37    1.57s  5.48%  42.4ms    220MiB  7.72%  5.93MiB
         ratio test        37    376ms  1.31%  10.2ms   42.3MiB  1.49%  1.14MiB
         compute di...     37    322ms  1.12%  8.69ms   43.2MiB  1.52%  1.17MiB
         compute en...     40    113ms  0.39%  2.83ms   7.59MiB  0.27%   194KiB
           compute ...     40   92.3ms  0.32%  2.31ms   7.25MiB  0.25%   185KiB
         compute pB        40   94.7ms  0.33%  2.37ms   6.23MiB  0.22%   159KiB
         update basis      37   12.5ms  0.04%   337μs   1.67MiB  0.06%  46.3KiB
         detect cycly      37   61.2μs  0.00%  1.65μs   33.4KiB  0.00%     925B
       inverse              3    2.42s  8.45%   806ms    245MiB  8.62%  81.7MiB
       compute xB           3    770ms  2.69%   257ms   95.5MiB  3.36%  31.8MiB
     Phase 2                3   54.9ms  0.19%  18.3ms   3.81MiB  0.13%  1.27MiB
       One iteration       65   53.8ms  0.19%   828μs   3.42MiB  0.12%  53.9KiB
         ratio test        62   28.3ms  0.10%   457μs   0.98MiB  0.03%  16.2KiB
         compute en...     65   11.6ms  0.04%   178μs    617KiB  0.02%  9.50KiB
           compute ...     65   2.96ms  0.01%  45.5μs    380KiB  0.01%  5.84KiB
         PF                62   4.40ms  0.02%  70.9μs   1.11MiB  0.04%  18.4KiB
         compute pB        65   1.61ms  0.01%  24.8μs    156KiB  0.01%  2.40KiB
         compute di...     62   1.33ms  0.00%  21.4μs    137KiB  0.00%  2.21KiB
         update basis      62    651μs  0.00%  10.5μs   17.3KiB  0.00%     286B
         detect cycly      62   94.9μs  0.00%  1.53μs   55.8KiB  0.00%     922B
       inverse              3    703μs  0.00%   234μs    376KiB  0.01%   125KiB
       compute xB           3    282μs  0.00%  94.2μs   18.6KiB  0.00%  6.21KiB
   presolve                 3    3.84s  13.4%   1.28s    541MiB  19.0%   180MiB
     row reduction          3    3.83s  13.4%   1.28s    541MiB  19.0%   180MiB
   scaling                  3    887ms  3.10%   296ms   89.1MiB  3.13%  29.7MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -69.99999999999996
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1254s / 2.29%           5.66GiB / 49.2%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        4    28.8s   100%   7.19s   2.78GiB  100%    713MiB
   run core                 4    23.2s  80.6%   5.79s   2.13GiB  76.4%   545MiB
     Phase 1                4    13.8s  48.0%   3.45s   1.52GiB  54.7%   390MiB
       One iteration       58    3.14s  10.9%  54.1ms    390MiB  13.7%  6.73MiB
         PF                54    1.57s  5.47%  29.1ms    220MiB  7.71%  4.07MiB
         ratio test        54    398ms  1.38%  7.37ms   42.9MiB  1.50%   814KiB
         compute di...     54    323ms  1.12%  5.98ms   43.2MiB  1.52%   820KiB
         compute en...     58    134ms  0.47%  2.31ms   8.11MiB  0.28%   143KiB
           compute ...     58   94.8ms  0.33%  1.63ms   7.39MiB  0.26%   130KiB
         compute pB        58   96.3ms  0.33%  1.66ms   6.38MiB  0.22%   113KiB
         update basis      54   13.0ms  0.05%   241μs   1.68MiB  0.06%  31.9KiB
         detect cycly      54    106μs  0.00%  1.96μs   48.8KiB  0.00%     926B
       inverse              4    2.42s  8.41%   605ms    245MiB  8.59%  61.3MiB
       compute xB           4    770ms  2.68%   193ms   95.6MiB  3.35%  23.9MiB
     Phase 2                4    104ms  0.36%  26.1ms   5.57MiB  0.20%  1.39MiB
       One iteration       85    103ms  0.36%  1.21ms   5.15MiB  0.18%  62.1KiB
         ratio test        81   54.2ms  0.19%   669μs   1.67MiB  0.06%  21.1KiB
         compute en...     85   21.7ms  0.08%   255μs    952KiB  0.03%  11.2KiB
           compute ...     85   5.70ms  0.02%  67.1μs    562KiB  0.02%  6.61KiB
         PF                81   8.23ms  0.03%   102μs   1.42MiB  0.05%  18.0KiB
         compute pB        85   3.38ms  0.01%  39.8μs    251KiB  0.01%  2.95KiB
         compute di...     81   2.69ms  0.01%  33.2μs    227KiB  0.01%  2.80KiB
         update basis      81   1.22ms  0.00%  15.0μs   28.6KiB  0.00%     361B
         detect cycly      81    145μs  0.00%  1.79μs   73.0KiB  0.00%     923B
       inverse              4   1.13ms  0.00%   281μs    387KiB  0.01%  96.9KiB
       compute xB           4    517μs  0.00%   129μs   30.8KiB  0.00%  7.70KiB
   presolve                 4    3.85s  13.4%   963ms    544MiB  19.1%   136MiB
     row reduction          4    3.85s  13.4%   961ms    544MiB  19.1%   136MiB
   scaling                  4    891ms  3.10%   223ms   90.8MiB  3.18%  22.7MiB
 ──────────────────────────────────────────────────────────────────────────────
```
## Instance: sc105

nrows   : 105
ncols   : 103
nnz     : 280
sparsity: 0.025889967637540454

### CPU

```
Final objective value: -53.35247614388573
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1254s / 2.30%           5.68GiB / 49.5%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        5    28.9s   100%   5.77s   2.81GiB  100%    576MiB
   run core                 5    23.2s  80.4%   4.64s   2.14GiB  76.0%   438MiB
     Phase 1                5    13.8s  47.9%   2.76s   1.53GiB  54.3%   313MiB
       One iteration       79    3.14s  10.9%  39.8ms    393MiB  13.6%  4.97MiB
         PF                74    1.57s  5.45%  21.3ms    221MiB  7.69%  2.99MiB
         ratio test        74    398ms  1.38%  5.38ms   43.1MiB  1.50%   596KiB
         compute di...     74    323ms  1.12%  4.36ms   43.3MiB  1.50%   599KiB
         compute en...     79    135ms  0.47%  1.71ms   8.43MiB  0.29%   109KiB
           compute ...     79   94.9ms  0.33%  1.20ms   7.56MiB  0.26%  98.0KiB
         compute pB        79   97.4ms  0.34%  1.23ms   6.42MiB  0.22%  83.2KiB
         update basis      74   13.0ms  0.05%   176μs   1.68MiB  0.06%  23.3KiB
         detect cycly      74    139μs  0.00%  1.88μs   76.9KiB  0.00%  1.04KiB
       inverse              5    2.42s  8.38%   484ms    246MiB  8.53%  49.1MiB
       compute xB           5    770ms  2.67%   154ms   95.6MiB  3.32%  19.1MiB
     Phase 2                5    117ms  0.41%  23.5ms   11.2MiB  0.39%  2.25MiB
       One iteration      133    115ms  0.40%   864μs   10.1MiB  0.35%  77.7KiB
         ratio test       128   56.0ms  0.19%   438μs   2.07MiB  0.07%  16.5KiB
         compute en...    133   22.5ms  0.08%   170μs   1.21MiB  0.04%  9.30KiB
           compute ...    133   6.03ms  0.02%  45.4μs    739KiB  0.03%  5.56KiB
         PF               128   14.9ms  0.05%   117μs   5.34MiB  0.19%  42.7KiB
         compute pB       133   5.07ms  0.02%  38.1μs    350KiB  0.01%  2.63KiB
         compute di...    128   2.86ms  0.01%  22.4μs    287KiB  0.01%  2.24KiB
         update basis     128   1.26ms  0.00%  9.86μs   33.0KiB  0.00%     264B
         detect cycly     128    268μs  0.00%  2.09μs    139KiB  0.00%  1.08KiB
       inverse              5   1.66ms  0.01%   332μs   1.10MiB  0.04%   225KiB
       compute xB           5    570μs  0.00%   114μs   37.4KiB  0.00%  7.47KiB
   presolve                 5    3.93s  13.6%   786ms    556MiB  19.3%   111MiB
     row reduction          5    3.92s  13.6%   785ms    556MiB  19.3%   111MiB
   scaling                  5    901ms  3.12%   180ms   96.7MiB  3.36%  19.3MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -53.35247614388565
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1255s / 2.33%           5.71GiB / 49.7%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        6    29.2s   100%   4.87s   2.84GiB  100%    485MiB
   run core                 6    23.5s  80.4%   3.92s   2.15GiB  75.6%   367MiB
     Phase 1                6    13.9s  47.7%   2.32s   1.53GiB  53.9%   261MiB
       One iteration      100    3.26s  11.1%  32.6ms    395MiB  13.6%  3.95MiB
         PF                94    1.58s  5.40%  16.8ms    222MiB  7.63%  2.36MiB
         ratio test        94    443ms  1.52%  4.71ms   44.1MiB  1.52%   481KiB
         compute di...     94    324ms  1.11%  3.45ms   43.4MiB  1.49%   472KiB
         compute en...    100    188ms  0.64%  1.88ms   9.58MiB  0.33%  98.1KiB
           compute ...    100   98.5ms  0.34%   985μs   7.73MiB  0.27%  79.2KiB
         compute pB       100   99.1ms  0.34%   991μs   6.52MiB  0.22%  66.7KiB
         update basis      94   13.6ms  0.05%   145μs   1.70MiB  0.06%  18.5KiB
         detect cycly      94    211μs  0.00%  2.25μs    105KiB  0.00%  1.12KiB
       inverse              6    2.42s  8.28%   403ms    246MiB  8.45%  41.0MiB
       compute xB           6    770ms  2.64%   128ms   95.6MiB  3.29%  15.9MiB
     Phase 2                6    314ms  1.07%  52.3ms   17.2MiB  0.59%  2.87MiB
       One iteration      182    310ms  1.06%  1.70ms   16.0MiB  0.55%  90.2KiB
         ratio test       176    176ms  0.60%  1000μs   4.74MiB  0.16%  27.6KiB
         compute en...    182   64.0ms  0.22%   352μs   2.31MiB  0.08%  13.0KiB
           compute ...    182   12.7ms  0.04%  69.7μs   1.11MiB  0.04%  6.25KiB
         PF               176   25.5ms  0.09%   145μs   6.13MiB  0.21%  35.7KiB
         compute pB       182   9.34ms  0.03%  51.3μs    653KiB  0.02%  3.59KiB
         compute di...    176   6.32ms  0.02%  35.9μs    514KiB  0.02%  2.92KiB
         update basis     176   2.72ms  0.01%  15.4μs   61.5KiB  0.00%     358B
         detect cycly     176    469μs  0.00%  2.66μs    206KiB  0.01%  1.17KiB
       inverse              6   2.62ms  0.01%   437μs   1.11MiB  0.04%   190KiB
       compute xB           6    803μs  0.00%   134μs   49.6KiB  0.00%  8.27KiB
   presolve                 6    3.97s  13.6%   661ms    568MiB  19.5%  94.7MiB
     row reduction          6    3.96s  13.5%   660ms    568MiB  19.5%  94.6MiB
   scaling                  6    911ms  3.12%   152ms    103MiB  3.53%  17.1MiB
 ──────────────────────────────────────────────────────────────────────────────
```
## Instance: sc205

nrows   : 205
ncols   : 203
nnz     : 551
sparsity: 0.0132404181184669

### CPU

```
Final objective value: -52.39487567908582
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1255s / 2.35%           5.85GiB / 50.9%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        7    29.5s   100%   4.22s   2.97GiB  100%    435MiB
   run core                 7    23.6s  79.9%   3.37s   2.22GiB  74.6%   324MiB
     Phase 1                7    14.0s  47.3%   1.99s   1.55GiB  52.2%   227MiB
       One iteration      139    3.27s  11.1%  23.6ms    410MiB  13.5%  2.95MiB
         PF               132    1.59s  5.38%  12.0ms    234MiB  7.68%  1.77MiB
         ratio test       132    445ms  1.50%  3.37ms   44.7MiB  1.47%   347KiB
         compute di...    132    325ms  1.10%  2.46ms   43.4MiB  1.43%   337KiB
         compute en...    139    190ms  0.64%  1.37ms   10.7MiB  0.35%  78.9KiB
           compute ...    139   98.9ms  0.33%   711μs   8.33MiB  0.27%  61.4KiB
         compute pB       139    101ms  0.34%   725μs   6.65MiB  0.22%  49.0KiB
         update basis     132   13.6ms  0.05%   103μs   1.70MiB  0.06%  13.2KiB
         detect cycly     132    401μs  0.00%  3.04μs    188KiB  0.01%  1.42KiB
       inverse              7    2.42s  8.20%   346ms    248MiB  8.16%  35.5MiB
       compute xB           7    770ms  2.61%   110ms   95.6MiB  3.14%  13.7MiB
     Phase 2                7    379ms  1.28%  54.2ms   67.6MiB  2.22%  9.66MiB
       One iteration      310    374ms  1.26%  1.21ms   63.8MiB  2.09%   211KiB
         ratio test       303    181ms  0.61%   597μs   6.77MiB  0.22%  22.9KiB
         PF               302   71.2ms  0.24%   236μs   46.3MiB  1.52%   157KiB
         compute en...    310   66.3ms  0.22%   214μs   3.64MiB  0.12%  12.0KiB
           compute ...    310   13.5ms  0.05%  43.4μs   1.92MiB  0.06%  6.33KiB
         compute pB       310   14.4ms  0.05%  46.4μs   1.09MiB  0.04%  3.60KiB
         compute di...    303   6.72ms  0.02%  22.2μs    777KiB  0.02%  2.56KiB
         inverse            1   2.93ms  0.01%  2.93ms   2.75MiB  0.09%  2.75MiB
         update basis     303   2.81ms  0.01%  9.27μs   73.4KiB  0.00%     248B
         detect cycly     303   1.15ms  0.00%  3.80μs    482KiB  0.02%  1.59KiB
       inverse              7   4.32ms  0.01%   617μs   3.77MiB  0.12%   551KiB
       compute xB           7    863μs  0.00%   123μs   61.5KiB  0.00%  8.79KiB
   presolve                 7    4.16s  14.1%   594ms    610MiB  20.0%  87.2MiB
     row reduction          7    4.15s  14.1%   593ms    610MiB  20.0%  87.1MiB
   scaling                  7    944ms  3.20%   135ms    125MiB  4.12%  17.9MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -52.39487567908579
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1257s / 2.48%           5.94GiB / 51.7%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        8    31.1s   100%   3.89s   3.07GiB  100%    393MiB
   run core                 8    25.0s  80.3%   3.12s   2.25GiB  73.3%   288MiB
     Phase 1                8    14.4s  46.1%   1.79s   1.56GiB  50.9%   200MiB
       One iteration      178    3.65s  11.7%  20.5ms    419MiB  13.3%  2.35MiB
         PF               170    1.60s  5.14%  9.42ms    235MiB  7.45%  1.38MiB
         ratio test       170    605ms  1.95%  3.56ms   48.0MiB  1.52%   289KiB
         compute en...    178    381ms  1.22%  2.14ms   14.7MiB  0.47%  84.3KiB
           compute ...    178    106ms  0.34%   597μs   8.66MiB  0.28%  49.8KiB
         compute di...    170    328ms  1.05%  1.93ms   43.7MiB  1.39%   263KiB
         compute pB       178    104ms  0.33%   584μs   6.84MiB  0.22%  39.3KiB
         update basis     170   14.8ms  0.05%  87.0μs   1.72MiB  0.05%  10.4KiB
         detect cycly     170    619μs  0.00%  3.64μs    271KiB  0.01%  1.59KiB
       inverse              8    2.42s  7.79%   303ms    248MiB  7.90%  31.1MiB
       compute xB           8    771ms  2.48%  96.3ms   95.6MiB  3.04%  12.0MiB
     Phase 2                8    1.35s  4.34%   169ms   89.3MiB  2.84%  11.2MiB
       One iteration      435    1.34s  4.32%  3.09ms   85.4MiB  2.72%   201KiB
         ratio test       427    846ms  2.72%  1.98ms   18.7MiB  0.59%  44.8KiB
         compute en...    435    262ms  0.84%   601μs   8.30MiB  0.26%  19.5KiB
           compute ...    435   35.4ms  0.11%  81.4μs   3.31MiB  0.11%  7.80KiB
         PF               425    110ms  0.35%   258μs   48.3MiB  1.53%   116KiB
         compute pB       435   27.0ms  0.09%  62.1μs   1.68MiB  0.05%  3.95KiB
         compute di...    427   17.4ms  0.06%  40.7μs   1.33MiB  0.04%  3.19KiB
         update basis     427   6.93ms  0.02%  16.2μs    147KiB  0.00%     353B
         inverse            2   4.75ms  0.02%  2.37ms   2.76MiB  0.09%  1.38MiB
         detect cycly     427   1.88ms  0.01%  4.40μs    751KiB  0.02%  1.76KiB
       inverse              8   6.01ms  0.02%   752μs   3.78MiB  0.12%   484KiB
       compute xB           8   1.12ms  0.00%   140μs   73.8KiB  0.00%  9.22KiB
   presolve                 8    4.32s  13.9%   540ms    652MiB  20.7%  81.5MiB
     row reduction          8    4.32s  13.9%   540ms    651MiB  20.7%  81.4MiB
   scaling                  8    979ms  3.15%   122ms    148MiB  4.71%  18.5MiB
 ──────────────────────────────────────────────────────────────────────────────
```
