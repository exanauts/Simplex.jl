# Numerical Performance (2020-04-29T16:42:55.607)

## Instance: sc50a

- nrows   : 50
- ncols   : 48
- nnz     : 130
- sparsity: 0.05416666666666667

### CPU

```
Final objective value: -70.01264227388191
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1596s / 0.57%           3.84GiB / 25.3%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        1    9.17s   100%   9.17s   0.97GiB  100%   0.97GiB
   presolve                 1    4.33s  47.2%   4.33s    535MiB  53.9%   535MiB
     row reduction          1    4.32s  47.1%   4.32s    535MiB  53.9%   535MiB
   run core                 1    3.83s  41.7%   3.83s    368MiB  37.0%   368MiB
     Phase 1                1    3.69s  40.3%   3.69s    353MiB  35.5%   353MiB
       One iteration       11    791ms  8.62%  71.9ms   88.9MiB  8.95%  8.08MiB
         PF                10    384ms  4.19%  38.4ms   52.2MiB  5.25%  5.22MiB
         compute en...     11   96.3ms  1.05%  8.76ms   4.38MiB  0.44%   407KiB
           compute ...     11   96.2ms  1.05%  8.75ms   4.34MiB  0.44%   404KiB
         ratio test        10   92.1ms  1.00%  9.21ms   10.0MiB  1.01%  1.00MiB
         compute di...     10   82.5ms  0.90%  8.25ms   5.38MiB  0.54%   551KiB
         compute pB        11   12.9ms  0.14%  1.17ms    764KiB  0.08%  69.4KiB
         update basis      10   10.6ms  0.12%  1.06ms   1.67MiB  0.17%   171KiB
         detect cycly      10   16.5μs  0.00%  1.65μs   9.02KiB  0.00%     923B
       inverse              1    735ms  8.01%   735ms   75.1MiB  7.55%  75.1MiB
       compute xB           1    149ms  1.63%   149ms   23.3MiB  2.34%  23.3MiB
     Phase 2                1   1.16ms  0.01%  1.16ms    828KiB  0.08%   828KiB
       One iteration       21   1.00ms  0.01%  47.6μs    640KiB  0.06%  30.5KiB
         PF                20    317μs  0.00%  15.9μs    390KiB  0.04%  19.5KiB
         ratio test        20    228μs  0.00%  11.4μs   88.2KiB  0.01%  4.41KiB
         compute en...     21    137μs  0.00%  6.52μs   68.9KiB  0.01%  3.28KiB
           compute ...     21   60.1μs  0.00%  2.86μs   42.9KiB  0.00%  2.04KiB
         compute pB        21   45.4μs  0.00%  2.16μs   22.3KiB  0.00%  1.06KiB
         compute di...     20   32.6μs  0.00%  1.63μs   15.7KiB  0.00%     802B
         detect cycly      20   20.4μs  0.00%  1.02μs   18.0KiB  0.00%     923B
         update basis      20   11.7μs  0.00%   585ns   1.88KiB  0.00%    96.0B
       inverse              1    132μs  0.00%   132μs    182KiB  0.02%   182KiB
       compute xB           1   14.2μs  0.00%  14.2μs   3.47KiB  0.00%  3.47KiB
   scaling                  1    954ms  10.4%   954ms   86.1MiB  8.67%  86.1MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -70.01264227388192
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1616s / 1.82%           5.64GiB / 49.1%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        2    29.4s   100%   14.7s   2.77GiB  100%   1.39GiB
   run core                 2    23.2s  78.7%   11.6s   2.12GiB  76.6%  1.06GiB
     Phase 1                2    13.4s  45.4%   6.68s   1.52GiB  54.9%   778MiB
       One iteration       22    2.91s  9.90%   132ms    388MiB  13.7%  17.6MiB
         PF                20    1.47s  4.99%  73.4ms    219MiB  7.73%  11.0MiB
         ratio test        20    345ms  1.17%  17.3ms   42.3MiB  1.49%  2.11MiB
         compute di...     20    293ms  1.00%  14.7ms   43.1MiB  1.52%  2.16MiB
         compute en...     22    141ms  0.48%  6.39ms   7.46MiB  0.26%   347KiB
           compute ...     22    120ms  0.41%  5.47ms   7.17MiB  0.25%   334KiB
         compute pB        22   93.6ms  0.32%  4.25ms   6.18MiB  0.22%   288KiB
         update basis      20   10.9ms  0.04%   546μs   1.67MiB  0.06%  85.5KiB
         detect cycly      20   40.1μs  0.00%  2.01μs   18.0KiB  0.00%     923B
       inverse              2    2.37s  8.04%   1.18s    245MiB  8.63%   122MiB
       compute xB           2    665ms  2.26%   333ms   95.5MiB  3.37%  47.8MiB
     Phase 2                2   52.3ms  0.18%  26.1ms   3.04MiB  0.11%  1.52MiB
       One iteration       45   51.4ms  0.17%  1.14ms   2.84MiB  0.10%  64.6KiB
         ratio test        43   27.7ms  0.09%   643μs    920KiB  0.03%  21.4KiB
         compute en...     45   11.1ms  0.04%   246μs    456KiB  0.02%  10.1KiB
           compute ...     45   2.61ms  0.01%  58.0μs    242KiB  0.01%  5.38KiB
         PF                43   3.84ms  0.01%  89.3μs    770KiB  0.03%  17.9KiB
         compute pB        45   1.57ms  0.01%  34.8μs    303KiB  0.01%  6.74KiB
         compute di...     43   1.19ms  0.00%  27.8μs    123KiB  0.00%  2.85KiB
         update basis      43    634μs  0.00%  14.8μs   15.5KiB  0.00%     370B
         detect cycly      43   67.9μs  0.00%  1.58μs   38.7KiB  0.00%     921B
       inverse              2    571μs  0.00%   286μs    193KiB  0.01%  96.7KiB
       compute xB           2    239μs  0.00%   120μs   15.3KiB  0.00%  7.66KiB
   presolve                 2    4.34s  14.7%   2.17s    539MiB  19.0%   269MiB
     row reduction          2    4.33s  14.7%   2.16s    538MiB  19.0%   269MiB
   scaling                  2    956ms  3.25%   478ms   87.4MiB  3.08%  43.7MiB
 ──────────────────────────────────────────────────────────────────────────────
```
## Instance: sc50b

- nrows   : 50
- ncols   : 48
- nnz     : 118
- sparsity: 0.049166666666666664

### CPU

```
Final objective value: -69.99999999999997
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1616s / 1.82%           5.65GiB / 49.2%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        3    29.5s   100%   9.82s   2.78GiB  100%    948MiB
   run core                 3    23.2s  78.7%   7.73s   2.12GiB  76.5%   725MiB
     Phase 1                3    13.4s  45.3%   4.45s   1.52GiB  54.8%   519MiB
       One iteration       40    2.92s  9.90%  72.9ms    388MiB  13.7%  9.71MiB
         PF                37    1.47s  4.99%  39.7ms    220MiB  7.72%  5.93MiB
         ratio test        37    346ms  1.17%  9.34ms   42.3MiB  1.49%  1.14MiB
         compute di...     37    293ms  1.00%  7.92ms   43.2MiB  1.52%  1.17MiB
         compute en...     40    141ms  0.48%  3.52ms   7.59MiB  0.27%   194KiB
           compute ...     40    120ms  0.41%  3.01ms   7.25MiB  0.25%   185KiB
         compute pB        40   93.6ms  0.32%  2.34ms   6.20MiB  0.22%   159KiB
         update basis      37   10.9ms  0.04%   296μs   1.67MiB  0.06%  46.3KiB
         detect cycly      37   60.8μs  0.00%  1.64μs   33.4KiB  0.00%     925B
       inverse              3    2.37s  8.03%   789ms    245MiB  8.62%  81.7MiB
       compute xB           3    665ms  2.26%   222ms   95.5MiB  3.36%  31.8MiB
     Phase 2                3   53.4ms  0.18%  17.8ms   3.81MiB  0.13%  1.27MiB
       One iteration       65   52.4ms  0.18%   806μs   3.42MiB  0.12%  53.9KiB
         ratio test        62   27.9ms  0.09%   449μs   0.98MiB  0.03%  16.2KiB
         compute en...     65   11.2ms  0.04%   172μs    517KiB  0.02%  7.95KiB
           compute ...     65   2.66ms  0.01%  40.8μs    279KiB  0.01%  4.30KiB
         PF                62   4.26ms  0.01%  68.7μs   1.11MiB  0.04%  18.4KiB
         compute pB        65   1.61ms  0.01%  24.7μs    324KiB  0.01%  4.99KiB
         compute di...     62   1.22ms  0.00%  19.6μs    137KiB  0.00%  2.21KiB
         update basis      62    644μs  0.00%  10.4μs   17.3KiB  0.00%     286B
         detect cycly      62   87.4μs  0.00%  1.41μs   55.8KiB  0.00%     922B
       inverse              3    730μs  0.00%   243μs    376KiB  0.01%   125KiB
       compute xB           3    250μs  0.00%  83.2μs   18.6KiB  0.00%  6.21KiB
   presolve                 3    4.34s  14.7%   1.45s    541MiB  19.0%   180MiB
     row reduction          3    4.33s  14.7%   1.44s    541MiB  19.0%   180MiB
   scaling                  3    959ms  3.25%   320ms   89.1MiB  3.13%  29.7MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -69.99999999999996
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1617s / 1.83%           5.66GiB / 49.2%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        4    29.6s   100%   7.39s   2.78GiB  100%    713MiB
   run core                 4    23.3s  78.7%   5.82s   2.13GiB  76.4%   545MiB
     Phase 1                4    13.4s  45.4%   3.35s   1.52GiB  54.7%   390MiB
       One iteration       58    2.96s  10.0%  51.1ms    390MiB  13.7%  6.73MiB
         PF                54    1.47s  4.98%  27.2ms    220MiB  7.71%  4.07MiB
         ratio test        54    365ms  1.23%  6.75ms   42.9MiB  1.51%   814KiB
         compute di...     54    294ms  1.00%  5.45ms   43.3MiB  1.52%   821KiB
         compute en...     58    160ms  0.54%  2.76ms   8.11MiB  0.28%   143KiB
           compute ...     58    122ms  0.41%  2.11ms   7.39MiB  0.26%   130KiB
         compute pB        58   94.8ms  0.32%  1.63ms   6.28MiB  0.22%   111KiB
         update basis      54   11.4ms  0.04%   211μs   1.68MiB  0.06%  31.9KiB
         detect cycly      54    103μs  0.00%  1.90μs   48.8KiB  0.00%     926B
       inverse              4    2.37s  8.01%   592ms    245MiB  8.59%  61.3MiB
       compute xB           4    665ms  2.25%   166ms   95.6MiB  3.35%  23.9MiB
     Phase 2                4   96.9ms  0.33%  24.2ms   5.57MiB  0.20%  1.39MiB
       One iteration       85   95.2ms  0.32%  1.12ms   5.15MiB  0.18%  62.1KiB
         ratio test        81   51.2ms  0.17%   632μs   1.67MiB  0.06%  21.1KiB
         compute en...     85   20.1ms  0.07%   237μs    852KiB  0.03%  10.0KiB
           compute ...     85   4.80ms  0.02%  56.5μs    461KiB  0.02%  5.43KiB
         PF                81   7.33ms  0.02%  90.5μs   1.42MiB  0.05%  18.0KiB
         compute pB        85   2.95ms  0.01%  34.8μs    419KiB  0.01%  4.93KiB
         compute di...     81   2.32ms  0.01%  28.7μs    227KiB  0.01%  2.80KiB
         update basis      81   1.16ms  0.00%  14.3μs   28.6KiB  0.00%     361B
         detect cycly      81    131μs  0.00%  1.62μs   73.0KiB  0.00%     923B
       inverse              4   1.14ms  0.00%   284μs    387KiB  0.01%  96.9KiB
       compute xB           4    430μs  0.00%   107μs   30.8KiB  0.00%  7.70KiB
   presolve                 4    4.35s  14.7%   1.09s    544MiB  19.1%   136MiB
     row reduction          4    4.34s  14.7%   1.08s    544MiB  19.1%   136MiB
   scaling                  4    961ms  3.25%   240ms   90.8MiB  3.18%  22.7MiB
 ──────────────────────────────────────────────────────────────────────────────
```
## Instance: sc105

- nrows   : 105
- ncols   : 103
- nnz     : 280
- sparsity: 0.025889967637540454

### CPU

```
Final objective value: -53.35247614388573
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1617s / 1.83%           5.68GiB / 49.5%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        5    29.6s   100%   5.93s   2.81GiB  100%    576MiB
   run core                 5    23.3s  78.6%   4.66s   2.14GiB  76.0%   438MiB
     Phase 1                5    13.4s  45.3%   2.68s   1.53GiB  54.3%   313MiB
       One iteration       79    2.97s  10.0%  37.6ms    393MiB  13.6%  4.97MiB
         PF                74    1.47s  4.97%  19.9ms    221MiB  7.69%  2.99MiB
         ratio test        74    365ms  1.23%  4.94ms   43.1MiB  1.50%   596KiB
         compute di...     74    294ms  0.99%  3.98ms   43.3MiB  1.50%   600KiB
         compute en...     79    161ms  0.54%  2.03ms   8.43MiB  0.29%   109KiB
           compute ...     79    123ms  0.41%  1.55ms   7.56MiB  0.26%  98.0KiB
         compute pB        79   95.4ms  0.32%  1.21ms   6.33MiB  0.22%  82.0KiB
         update basis      74   11.4ms  0.04%   154μs   1.68MiB  0.06%  23.3KiB
         detect cycly      74    155μs  0.00%  2.10μs   76.9KiB  0.00%  1.04KiB
       inverse              5    2.37s  7.99%   473ms    246MiB  8.53%  49.1MiB
       compute xB           5    665ms  2.25%   133ms   95.6MiB  3.32%  19.1MiB
     Phase 2                5    107ms  0.36%  21.4ms   11.2MiB  0.39%  2.25MiB
       One iteration      133    105ms  0.35%   786μs   10.1MiB  0.35%  77.7KiB
         ratio test       128   52.8ms  0.18%   412μs   2.07MiB  0.07%  16.5KiB
         compute en...    133   20.9ms  0.07%   157μs   1.11MiB  0.04%  8.55KiB
           compute ...    133   5.10ms  0.02%  38.4μs    639KiB  0.02%  4.80KiB
         PF               128   12.2ms  0.04%  95.5μs   5.34MiB  0.19%  42.7KiB
         compute pB       133   3.98ms  0.01%  30.0μs    518KiB  0.02%  3.90KiB
         compute di...    128   2.46ms  0.01%  19.2μs    287KiB  0.01%  2.24KiB
         update basis     128   1.20ms  0.00%  9.34μs   33.0KiB  0.00%     264B
         detect cycly     128    320μs  0.00%  2.50μs    139KiB  0.00%  1.08KiB
       inverse              5   1.84ms  0.01%   369μs   1.10MiB  0.04%   225KiB
       compute xB           5    456μs  0.00%  91.3μs   37.4KiB  0.00%  7.47KiB
   presolve                 5    4.40s  14.8%   879ms    556MiB  19.3%   111MiB
     row reduction          5    4.39s  14.8%   878ms    556MiB  19.3%   111MiB
   scaling                  5    969ms  3.27%   194ms   96.7MiB  3.36%  19.3MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -53.35247614388565
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1617s / 1.86%           5.71GiB / 49.7%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        6    30.1s   100%   5.01s   2.84GiB  100%    485MiB
   run core                 6    23.7s  78.7%   3.94s   2.15GiB  75.6%   367MiB
     Phase 1                6    13.6s  45.1%   2.26s   1.53GiB  53.9%   261MiB
       One iteration      100    3.11s  10.3%  31.1ms    395MiB  13.6%  3.95MiB
         PF                94    1.48s  4.91%  15.7ms    222MiB  7.63%  2.36MiB
         ratio test        94    423ms  1.41%  4.50ms   44.1MiB  1.52%   481KiB
         compute di...     94    296ms  0.99%  3.15ms   43.4MiB  1.49%   473KiB
         compute en...    100    229ms  0.76%  2.29ms   9.58MiB  0.33%  98.1KiB
           compute ...    100    127ms  0.42%  1.27ms   7.73MiB  0.27%  79.2KiB
         compute pB       100   97.6ms  0.32%   976μs   6.42MiB  0.22%  65.8KiB
         update basis      94   12.2ms  0.04%   130μs   1.70MiB  0.06%  18.5KiB
         detect cycly      94    244μs  0.00%  2.60μs    105KiB  0.00%  1.12KiB
       inverse              6    2.37s  7.87%   395ms    246MiB  8.45%  41.0MiB
       compute xB           6    666ms  2.21%   111ms   95.6MiB  3.29%  15.9MiB
     Phase 2                6    332ms  1.10%  55.3ms   17.2MiB  0.59%  2.87MiB
       One iteration      182    328ms  1.09%  1.80ms   16.0MiB  0.55%  90.2KiB
         ratio test       176    192ms  0.64%  1.09ms   4.81MiB  0.17%  28.0KiB
         compute en...    182   68.5ms  0.23%   376μs   2.21MiB  0.08%  12.4KiB
           compute ...    182   12.4ms  0.04%  68.1μs   1.01MiB  0.03%  5.70KiB
         PF               176   23.8ms  0.08%   135μs   6.13MiB  0.21%  35.7KiB
         compute pB       182   8.51ms  0.03%  46.7μs    753KiB  0.03%  4.14KiB
         compute di...    176   6.17ms  0.02%  35.1μs    514KiB  0.02%  2.92KiB
         update basis     176   2.85ms  0.01%  16.2μs   61.5KiB  0.00%     358B
         detect cycly     176    539μs  0.00%  3.06μs    206KiB  0.01%  1.17KiB
       inverse              6   3.00ms  0.01%   499μs   1.11MiB  0.04%   190KiB
       compute xB           6    707μs  0.00%   118μs   49.6KiB  0.00%  8.27KiB
   presolve                 6    4.45s  14.8%   742ms    568MiB  19.5%  94.7MiB
     row reduction          6    4.44s  14.8%   740ms    568MiB  19.5%  94.6MiB
   scaling                  6    987ms  3.28%   165ms    103MiB  3.53%  17.1MiB
 ──────────────────────────────────────────────────────────────────────────────
```
## Instance: sc205

- nrows   : 205
- ncols   : 203
- nnz     : 551
- sparsity: 0.0132404181184669

### CPU

```
Final objective value: -52.39487567908582
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1617s / 1.88%           5.85GiB / 50.9%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        7    30.5s   100%   4.35s   2.97GiB  100%    435MiB
   run core                 7    23.8s  78.0%   3.40s   2.22GiB  74.6%   324MiB
     Phase 1                7    13.6s  44.6%   1.94s   1.55GiB  52.2%   227MiB
       One iteration      139    3.13s  10.3%  22.5ms    410MiB  13.5%  2.95MiB
         PF               132    1.49s  4.89%  11.3ms    234MiB  7.68%  1.77MiB
         ratio test       132    425ms  1.39%  3.22ms   44.7MiB  1.47%   347KiB
         compute di...    132    297ms  0.97%  2.25ms   43.5MiB  1.43%   337KiB
         compute en...    139    231ms  0.76%  1.66ms   10.7MiB  0.35%  78.9KiB
           compute ...    139    128ms  0.42%   918μs   8.33MiB  0.27%  61.4KiB
         compute pB       139   99.0ms  0.32%   712μs   6.56MiB  0.22%  48.3KiB
         update basis     132   12.2ms  0.04%  92.6μs   1.70MiB  0.06%  13.2KiB
         detect cycly     132    432μs  0.00%  3.28μs    188KiB  0.01%  1.42KiB
       inverse              7    2.37s  7.78%   339ms    248MiB  8.16%  35.5MiB
       compute xB           7    666ms  2.19%  95.1ms   95.6MiB  3.14%  13.7MiB
     Phase 2                7    399ms  1.31%  57.1ms   67.6MiB  2.22%  9.66MiB
       One iteration      310    393ms  1.29%  1.27ms   63.8MiB  2.09%   211KiB
         ratio test       303    197ms  0.65%   649μs   6.84MiB  0.22%  23.1KiB
         compute en...    310   71.1ms  0.23%   229μs   3.54MiB  0.12%  11.7KiB
           compute ...    310   13.3ms  0.04%  42.9μs   1.82MiB  0.06%  6.01KiB
         PF               302   70.0ms  0.23%   232μs   46.3MiB  1.52%   157KiB
         compute pB       310   13.1ms  0.04%  42.3μs   1.19MiB  0.04%  3.93KiB
         compute di...    303   6.66ms  0.02%  22.0μs    777KiB  0.02%  2.56KiB
         inverse            1   3.70ms  0.01%  3.70ms   2.75MiB  0.09%  2.75MiB
         update basis     303   2.97ms  0.01%  9.79μs   73.4KiB  0.00%     248B
         detect cycly     303   1.25ms  0.00%  4.13μs    482KiB  0.02%  1.59KiB
       inverse              7   5.01ms  0.02%   715μs   3.77MiB  0.12%   551KiB
       compute xB           7    761μs  0.00%   109μs   61.5KiB  0.00%  8.79KiB
   presolve                 7    4.69s  15.4%   670ms    610MiB  20.0%  87.2MiB
     row reduction          7    4.68s  15.4%   669ms    610MiB  20.0%  87.1MiB
   scaling                  7    1.03s  3.37%   147ms    125MiB  4.12%  17.9MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -52.39487567908579
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1619s / 1.98%           5.94GiB / 51.7%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        8    32.1s   100%   4.02s   3.07GiB  100%    393MiB
   run core                 8    25.2s  78.3%   3.15s   2.25GiB  73.3%   288MiB
     Phase 1                8    14.1s  43.8%   1.76s   1.56GiB  50.9%   200MiB
       One iteration      178    3.57s  11.1%  20.1ms    419MiB  13.3%  2.35MiB
         PF               170    1.50s  4.67%  8.83ms    235MiB  7.45%  1.38MiB
         ratio test       170    613ms  1.91%  3.61ms   48.0MiB  1.52%   289KiB
         compute en...    178    453ms  1.41%  2.55ms   14.8MiB  0.47%  84.9KiB
           compute ...    178    136ms  0.42%   763μs   8.76MiB  0.28%  50.4KiB
         compute di...    170    300ms  0.93%  1.77ms   43.7MiB  1.39%   263KiB
         compute pB       178    103ms  0.32%   577μs   6.77MiB  0.22%  38.9KiB
         update basis     170   13.5ms  0.04%  79.6μs   1.72MiB  0.05%  10.4KiB
         detect cycly     170    682μs  0.00%  4.01μs    271KiB  0.01%  1.59KiB
       inverse              8    2.37s  7.38%   297ms    248MiB  7.90%  31.1MiB
       compute xB           8    666ms  2.07%  83.3ms   95.6MiB  3.04%  12.0MiB
     Phase 2                8    1.34s  4.16%   167ms   89.3MiB  2.84%  11.2MiB
       One iteration      435    1.33s  4.13%  3.05ms   85.4MiB  2.72%   201KiB
         ratio test       427    843ms  2.62%  1.97ms   18.8MiB  0.60%  45.0KiB
         compute en...    435    260ms  0.81%   599μs   8.18MiB  0.26%  19.3KiB
           compute ...    435   34.1ms  0.11%  78.4μs   3.20MiB  0.10%  7.53KiB
         PF               425    106ms  0.33%   249μs   48.3MiB  1.53%   116KiB
         compute pB       435   24.1ms  0.08%  55.4μs   1.77MiB  0.06%  4.18KiB
         compute di...    427   15.8ms  0.05%  37.0μs   1.33MiB  0.04%  3.19KiB
         update basis     427   6.90ms  0.02%  16.2μs    147KiB  0.00%     353B
         inverse            2   5.59ms  0.02%  2.79ms   2.76MiB  0.09%  1.38MiB
         detect cycly     427   2.00ms  0.01%  4.69μs    751KiB  0.02%  1.76KiB
       inverse              8   6.93ms  0.02%   866μs   3.78MiB  0.12%   484KiB
       compute xB           8   1.00ms  0.00%   125μs   73.8KiB  0.00%  9.22KiB
   presolve                 8    4.88s  15.2%   610ms    652MiB  20.7%  81.5MiB
     row reduction          8    4.87s  15.2%   609ms    651MiB  20.7%  81.4MiB
   scaling                  8    1.11s  3.44%   138ms    148MiB  4.71%  18.5MiB
 ──────────────────────────────────────────────────────────────────────────────
```
