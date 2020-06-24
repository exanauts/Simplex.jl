# Numerical Performance (2020-06-24T16:47:09.247)

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
       Tot / % measured:            11.9s / 94.4%           0.99GiB / 98.1%    

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        1    11.3s   100%   11.3s   0.97GiB  100%   0.97GiB
   presolve                 1    5.65s  50.2%   5.65s    536MiB  53.9%   536MiB
     row reduction          1    5.64s  50.1%   5.64s    536MiB  53.9%   536MiB
   run core                 1    4.39s  39.0%   4.39s    368MiB  37.0%   368MiB
     Phase 1                1    4.23s  37.6%   4.23s    353MiB  35.5%   353MiB
       One iteration       11    818ms  7.26%  74.4ms   87.7MiB  8.83%  7.98MiB
         PF                10    384ms  3.41%  38.4ms   52.2MiB  5.25%  5.22MiB
         compute di...     10    112ms  0.99%  11.2ms   5.15MiB  0.52%   527KiB
         ratio test        10    106ms  0.94%  10.6ms   9.77MiB  0.98%  0.98MiB
         compute en...     11   74.8ms  0.66%  6.80ms   4.37MiB  0.44%   407KiB
           compute ...     11   74.7ms  0.66%  6.79ms   4.34MiB  0.44%   404KiB
         compute pB        11   13.8ms  0.12%  1.26ms    764KiB  0.08%  69.4KiB
         update basis      10   12.8ms  0.11%  1.28ms   1.67MiB  0.17%   171KiB
         detect cycly      10   18.9μs  0.00%  1.89μs   9.02KiB  0.00%     923B
       inverse              1    738ms  6.55%   738ms   75.1MiB  7.55%  75.1MiB
       compute xB           1    169ms  1.50%   169ms   23.3MiB  2.34%  23.3MiB
     Phase 2                1   1.16ms  0.01%  1.16ms    827KiB  0.08%   827KiB
       One iteration       21    949μs  0.01%  45.2μs    639KiB  0.06%  30.4KiB
         PF                20    302μs  0.00%  15.1μs    390KiB  0.04%  19.5KiB
         ratio test        20    221μs  0.00%  11.1μs   88.5KiB  0.01%  4.43KiB
         compute en...     21    125μs  0.00%  5.97μs   67.9KiB  0.01%  3.23KiB
           compute ...     21   50.8μs  0.00%  2.42μs   42.9KiB  0.00%  2.04KiB
         compute pB        21   41.4μs  0.00%  1.97μs   22.3KiB  0.00%  1.06KiB
         compute di...     20   27.0μs  0.00%  1.35μs   15.7KiB  0.00%     802B
         detect cycly      20   21.1μs  0.00%  1.05μs   18.0KiB  0.00%     923B
         update basis      20   11.3μs  0.00%   563ns   1.88KiB  0.00%    96.0B
       inverse              1    156μs  0.00%   156μs    182KiB  0.02%   182KiB
       compute xB           1   37.8μs  0.00%  37.8μs   3.47KiB  0.00%  3.47KiB
   scaling                  1    1.15s  10.2%   1.15s   85.9MiB  8.65%  85.9MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -70.01264227388192
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            25.3s / 100%            1.66GiB / 100%     

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        1    25.3s   100%   25.3s   1.66GiB  100%   1.66GiB
   run core                 1    24.6s  97.3%   24.6s   1.63GiB  97.8%  1.63GiB
     Phase 1                1    13.6s  53.7%   13.6s   1.04GiB  62.5%  1.04GiB
       One iteration       11    3.95s  15.6%   359ms    299MiB  17.6%  27.2MiB
         PF                10    2.08s  8.25%   208ms    167MiB  9.81%  16.7MiB
         ratio test        10    418ms  1.66%  41.8ms   32.3MiB  1.89%  3.23MiB
         compute di...     10    356ms  1.41%  35.6ms   37.7MiB  2.22%  3.77MiB
         compute pB        11    201ms  0.80%  18.3ms   5.44MiB  0.32%   506KiB
         compute en...     11   52.8ms  0.21%  4.80ms   3.06MiB  0.18%   285KiB
           compute ...     11   29.7ms  0.12%  2.70ms   2.83MiB  0.17%   264KiB
         update basis      10    367μs  0.00%  36.7μs   5.94KiB  0.00%     608B
         detect cycly      10   55.1μs  0.00%  5.51μs   9.02KiB  0.00%     923B
       inverse              1    2.35s  9.33%   2.35s    170MiB  10.0%   170MiB
       compute xB           1    876ms  3.47%   876ms   72.3MiB  4.25%  72.3MiB
     Phase 2                1   64.0ms  0.25%  64.0ms   2.24MiB  0.13%  2.24MiB
       One iteration       24   63.0ms  0.25%  2.62ms   2.21MiB  0.13%  94.3KiB
         ratio test        23   34.1ms  0.13%  1.48ms    835KiB  0.05%  36.3KiB
         compute en...     24   13.7ms  0.05%   569μs    376KiB  0.02%  15.7KiB
           compute ...     24   3.80ms  0.02%   158μs    199KiB  0.01%  8.30KiB
         PF                23   4.36ms  0.02%   190μs    381KiB  0.02%  16.6KiB
         compute pB        24   1.75ms  0.01%  72.8μs    112KiB  0.01%  4.67KiB
         compute di...     23   1.49ms  0.01%  64.9μs    107KiB  0.01%  4.65KiB
         update basis      23    807μs  0.00%  35.1μs   13.7KiB  0.00%     608B
         detect cycly      23   69.7μs  0.00%  3.03μs   20.7KiB  0.00%     920B
       inverse              1    609μs  0.00%   609μs   11.3KiB  0.00%  11.3KiB
       compute xB           1    352μs  0.00%   352μs   11.8KiB  0.00%  11.8KiB
   presolve                 1   4.39ms  0.02%  4.39ms   3.19MiB  0.19%  3.19MiB
     row reduction          1   4.38ms  0.02%  4.38ms   3.18MiB  0.19%  3.18MiB
   scaling                  1   1.81ms  0.01%  1.81ms   1.28MiB  0.07%  1.28MiB
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
       Tot / % measured:           13.6ms / 100%            6.29MiB / 100%     

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        1   13.6ms   100%  13.6ms   6.29MiB  100%   6.29MiB
   presolve                 1   6.25ms  46.0%  6.25ms   2.65MiB  42.2%  2.65MiB
     row reduction          1   6.24ms  45.9%  6.24ms   2.65MiB  42.2%  2.65MiB
   scaling                  1   3.95ms  29.1%  3.95ms   1.70MiB  27.0%  1.70MiB
   run core                 1   3.23ms  23.7%  3.23ms   1.88MiB  30.0%  1.88MiB
     Phase 1                1   1.91ms  14.1%  1.91ms   1.04MiB  16.6%  1.04MiB
       One iteration       18   1.08ms  7.93%  59.8μs    614KiB  9.54%  34.1KiB
         PF                17    312μs  2.30%  18.3μs    331KiB  5.14%  19.5KiB
         compute en...     18    249μs  1.83%  13.8μs    130KiB  2.02%  7.23KiB
           compute ...     18   76.3μs  0.56%  4.24μs   75.4KiB  1.17%  4.19KiB
         ratio test        17    219μs  1.61%  12.9μs   73.4KiB  1.14%  4.32KiB
         compute pB        18   44.9μs  0.33%  2.49μs   19.1KiB  0.30%  1.06KiB
         compute di...     17   40.1μs  0.30%  2.36μs   13.1KiB  0.20%     792B
         detect cycly      17   20.7μs  0.15%  1.22μs   15.4KiB  0.24%     928B
         update basis      17   12.2μs  0.09%   719ns   1.59KiB  0.02%    96.0B
       inverse              1    181μs  1.33%   181μs    181KiB  2.82%   181KiB
       compute xB           1   20.4μs  0.15%  20.4μs   5.13KiB  0.08%  5.13KiB
     Phase 2                1   1.21ms  8.91%  1.21ms    794KiB  12.3%   794KiB
       One iteration       20   1.02ms  7.48%  50.8μs    606KiB  9.42%  30.3KiB
         PF                19    307μs  2.26%  16.2μs    370KiB  5.75%  19.5KiB
         ratio test        19    264μs  1.95%  13.9μs   86.4KiB  1.34%  4.55KiB
         compute en...     20    162μs  1.19%  8.11μs   61.2KiB  0.95%  3.06KiB
           compute ...     20   53.5μs  0.39%  2.68μs   37.1KiB  0.58%  1.85KiB
         compute pB        20   47.5μs  0.35%  2.37μs   21.3KiB  0.33%  1.06KiB
         compute di...     19   30.7μs  0.23%  1.62μs   14.6KiB  0.23%     786B
         detect cycly      19   22.0μs  0.16%  1.16μs   17.2KiB  0.27%     925B
         update basis      19   10.2μs  0.07%   535ns   1.78KiB  0.03%    96.0B
       inverse              1    170μs  1.25%   170μs    182KiB  2.83%   182KiB
       compute xB           1   10.9μs  0.08%  10.9μs   3.31KiB  0.05%  3.31KiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -69.99999999999996
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            128ms / 100%            8.35MiB / 100%     

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        1    128ms   100%   128ms   8.35MiB  100%   8.35MiB
   run core                 1    120ms  93.6%   120ms   3.91MiB  46.8%  3.91MiB
     Phase 1                1   63.2ms  49.4%  63.2ms   2.11MiB  25.3%  2.11MiB
       One iteration       18   59.5ms  46.4%  3.30ms   1.78MiB  21.3%   101KiB
         ratio test        17   24.6ms  19.2%  1.45ms    597KiB  6.98%  35.1KiB
         compute en...     18   22.0ms  17.2%  1.22ms    496KiB  5.80%  27.5KiB
           compute ...     18   2.09ms  1.63%   116μs    144KiB  1.69%  8.01KiB
         PF                17   4.13ms  3.22%   243μs    283KiB  3.31%  16.7KiB
         compute pB        18   1.56ms  1.22%  86.5μs    154KiB  1.80%  8.55KiB
         compute di...     17   1.20ms  0.93%  70.4μs   80.0KiB  0.93%  4.70KiB
         update basis      17    602μs  0.47%  35.4μs   10.1KiB  0.12%     608B
         detect cycly      17   61.6μs  0.05%  3.62μs   15.4KiB  0.18%     928B
       inverse              1    561μs  0.44%   561μs   11.9KiB  0.14%  11.9KiB
       compute xB           1    264μs  0.21%   264μs   12.0KiB  0.14%  12.0KiB
     Phase 2                1   55.8ms  43.5%  55.8ms   1.76MiB  21.1%  1.76MiB
       One iteration       20   55.0ms  42.9%  2.75ms   1.74MiB  20.8%  89.0KiB
         ratio test        19   30.3ms  23.6%  1.59ms    707KiB  8.27%  37.2KiB
         compute en...     20   11.4ms  8.89%   569μs    333KiB  3.89%  16.6KiB
           compute ...     20   2.73ms  2.13%   136μs    182KiB  2.13%  9.10KiB
         PF                19   3.80ms  2.97%   200μs    316KiB  3.70%  16.7KiB
         compute pB        20   1.66ms  1.29%  82.8μs   95.0KiB  1.11%  4.75KiB
         compute di...     19   1.37ms  1.07%  71.9μs   89.4KiB  1.04%  4.70KiB
         update basis      19    666μs  0.52%  35.1μs   11.3KiB  0.13%     608B
         detect cycly      19   58.9μs  0.05%  3.10μs   17.2KiB  0.20%     925B
       inverse              1    527μs  0.41%   527μs   11.9KiB  0.14%  11.9KiB
       compute xB           1    252μs  0.20%   252μs   12.2KiB  0.14%  12.2KiB
   presolve                 1   4.83ms  3.77%  4.83ms   2.65MiB  31.7%  2.65MiB
     row reduction          1   4.82ms  3.76%  4.82ms   2.65MiB  31.7%  2.65MiB
   scaling                  1   3.03ms  2.37%  3.03ms   1.70MiB  20.3%  1.70MiB
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
       Tot / % measured:            107ms / 100%            28.2MiB / 100%     

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        1    107ms   100%   107ms   28.2MiB  100%   28.2MiB
   presolve                 1   80.4ms  75.1%  80.4ms   12.1MiB  43.1%  12.1MiB
     row reduction          1   80.4ms  75.1%  80.4ms   12.1MiB  43.1%  12.1MiB
   run core                 1   16.7ms  15.6%  16.7ms   10.0MiB  35.5%  10.0MiB
     Phase 2                1   9.82ms  9.17%  9.82ms   5.67MiB  20.1%  5.67MiB
       One iteration       48   9.09ms  8.49%   189μs   4.94MiB  17.5%   105KiB
         PF                47   5.18ms  4.84%   110μs   3.92MiB  13.9%  85.4KiB
         compute pB        48   1.29ms  1.20%  26.8μs   99.0KiB  0.34%  2.06KiB
         ratio test        47   1.14ms  1.06%  24.2μs    407KiB  1.41%  8.67KiB
         compute en...     48    592μs  0.55%  12.3μs    284KiB  0.98%  5.92KiB
           compute ...     48    252μs  0.24%  5.24μs    178KiB  0.62%  3.70KiB
         detect cycly      47    203μs  0.19%  4.31μs   65.7KiB  0.23%  1.40KiB
         compute di...     47    107μs  0.10%  2.28μs   60.5KiB  0.21%  1.29KiB
         update basis      47   28.6μs  0.03%   608ns   4.41KiB  0.02%    96.0B
       inverse              1    641μs  0.60%   641μs    739KiB  2.56%   739KiB
       compute xB           1   53.1μs  0.05%  53.1μs   6.59KiB  0.02%  6.59KiB
     Phase 1                1   6.60ms  6.17%  6.60ms   4.05MiB  14.4%  4.05MiB
       One iteration       21   3.93ms  3.67%   187μs   2.29MiB  8.14%   112KiB
         PF                20   1.80ms  1.68%  89.8μs   1.67MiB  5.92%  85.4KiB
         compute en...     21    581μs  0.54%  27.7μs    320KiB  1.11%  15.2KiB
           compute ...     21    158μs  0.15%  7.51μs    180KiB  0.62%  8.56KiB
         ratio test        20    492μs  0.46%  24.6μs    166KiB  0.57%  8.28KiB
         compute pB        21    486μs  0.45%  23.1μs   43.3KiB  0.15%  2.06KiB
         compute di...     20    108μs  0.10%  5.40μs   25.4KiB  0.09%  1.27KiB
         detect cycly      20   33.2μs  0.03%  1.66μs   28.0KiB  0.10%  1.40KiB
         update basis      20   16.2μs  0.02%   811ns   1.88KiB  0.01%    96.0B
       compute xB           1    467μs  0.44%   467μs   10.3KiB  0.04%  10.3KiB
       inverse              1    454μs  0.42%   454μs    738KiB  2.56%   738KiB
   scaling                  1   9.73ms  9.08%  9.73ms   5.90MiB  20.9%  5.90MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -53.35247614388565
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            414ms / 100%            28.3MiB / 100%     

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        1    414ms   100%   414ms   28.3MiB  100%   28.3MiB
   run core                 1    367ms  88.6%   367ms   10.1MiB  35.8%  10.1MiB
     Phase 2                1    226ms  54.6%   226ms   5.97MiB  21.1%  5.97MiB
       One iteration       49    224ms  54.2%  4.58ms   5.94MiB  21.0%   124KiB
         ratio test        48    139ms  33.5%  2.89ms   2.68MiB  9.49%  57.3KiB
         compute en...     49   46.3ms  11.2%   945μs   1.08MiB  3.82%  22.6KiB
           compute ...     49   6.77ms  1.64%   138μs    398KiB  1.37%  8.12KiB
         PF                48   12.5ms  3.02%   261μs    806KiB  2.78%  16.8KiB
         compute pB        49   4.32ms  1.04%  88.1μs    235KiB  0.81%  4.80KiB
         compute di...     48   4.15ms  1.00%  86.4μs    296KiB  1.02%  6.16KiB
         update basis      48   1.70ms  0.41%  35.4μs   28.5KiB  0.10%     608B
         detect cycly      48    344μs  0.08%  7.16μs   67.1KiB  0.23%  1.40KiB
       inverse              1   1.32ms  0.32%  1.32ms   11.9KiB  0.04%  11.9KiB
       compute xB           1    264μs  0.06%   264μs   12.2KiB  0.04%  12.2KiB
     Phase 1                1    138ms  33.5%   138ms   4.05MiB  14.3%  4.05MiB
       One iteration       21    130ms  31.3%  6.17ms   2.91MiB  10.3%   142KiB
         compute en...     21   56.7ms  13.7%  2.70ms   1.08MiB  3.82%  52.8KiB
           compute ...     21   3.07ms  0.74%   146μs    175KiB  0.60%  8.35KiB
         ratio test        20   53.3ms  12.9%  2.67ms   1.05MiB  3.71%  53.8KiB
         PF                20   6.81ms  1.65%   340μs    335KiB  1.16%  16.8KiB
         compute pB        21   2.40ms  0.58%   115μs    101KiB  0.35%  4.80KiB
         compute di...     20   1.88ms  0.45%  93.9μs   94.7KiB  0.33%  4.73KiB
         update basis      20    737μs  0.18%  36.9μs   11.9KiB  0.04%     608B
         detect cycly      20    133μs  0.03%  6.66μs   28.0KiB  0.10%  1.40KiB
       inverse              1    988μs  0.24%   988μs   11.9KiB  0.04%  11.9KiB
       compute xB           1    372μs  0.09%   372μs   13.6KiB  0.05%  13.6KiB
   presolve                 1   35.4ms  8.56%  35.4ms   12.0MiB  42.4%  12.0MiB
     row reduction          1   35.4ms  8.56%  35.4ms   12.0MiB  42.3%  12.0MiB
   scaling                  1   11.0ms  2.67%  11.0ms   5.90MiB  20.8%  5.90MiB
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
       Tot / % measured:            407ms / 100%             137MiB / 100%     

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        1    407ms   100%   407ms    137MiB  100%    137MiB
   presolve                 1    232ms  57.0%   232ms   42.0MiB  30.6%  42.0MiB
     row reduction          1    232ms  57.0%   232ms   42.0MiB  30.6%  42.0MiB
   run core                 1    134ms  33.1%   134ms   72.0MiB  52.5%  72.0MiB
     Phase 2                1    100ms  24.6%   100ms   50.4MiB  36.7%  50.4MiB
       One iteration      128   97.8ms  24.1%   764μs   47.7MiB  34.8%   382KiB
         PF               126   75.3ms  18.5%   597μs   40.1MiB  29.2%   326KiB
         compute pB       128   6.40ms  1.58%  50.0μs    464KiB  0.33%  3.63KiB
         ratio test       127   5.81ms  1.43%  45.8μs   2.03MiB  1.48%  16.4KiB
         inverse            1   3.50ms  0.86%  3.50ms   2.75MiB  2.01%  2.75MiB
         compute en...    128   3.03ms  0.74%  23.6μs   1.32MiB  0.96%  10.6KiB
           compute ...    128   1.14ms  0.28%  8.92μs    825KiB  0.59%  6.45KiB
         detect cycly     127    766μs  0.19%  6.03μs    276KiB  0.20%  2.17KiB
         compute di...    127    542μs  0.13%  4.27μs    262KiB  0.19%  2.07KiB
         update basis     127    127μs  0.03%   999ns   11.9KiB  0.01%    96.0B
       inverse              1   1.82ms  0.45%  1.82ms   2.66MiB  1.93%  2.66MiB
       compute xB           1    103μs  0.03%   103μs   11.9KiB  0.01%  11.9KiB
     Phase 1                1   33.9ms  8.33%  33.9ms   20.6MiB  15.0%  20.6MiB
       One iteration       39   23.7ms  5.84%   608μs   14.2MiB  10.4%   373KiB
         PF                38   16.0ms  3.93%   420μs   12.1MiB  8.82%   326KiB
         compute en...     39   2.51ms  0.62%  64.4μs   1.10MiB  0.80%  28.9KiB
           compute ...     39    640μs  0.16%  16.4μs    614KiB  0.44%  15.7KiB
         compute pB        39   2.19ms  0.54%  56.2μs    141KiB  0.10%  3.63KiB
         ratio test        38   1.85ms  0.45%  48.6μs    579KiB  0.41%  15.2KiB
         detect cycly      38    233μs  0.06%  6.13μs   83.0KiB  0.06%  2.18KiB
         compute di...     38    172μs  0.04%  4.54μs   77.8KiB  0.06%  2.05KiB
         update basis      38   42.0μs  0.01%  1.11μs   3.56KiB  0.00%    96.0B
       inverse              1   1.73ms  0.43%  1.73ms   2.65MiB  1.93%  2.65MiB
       compute xB           1    250μs  0.06%   250μs   18.7KiB  0.01%  18.7KiB
   scaling                  1   39.8ms  9.79%  39.8ms   22.8MiB  16.6%  22.8MiB
 ──────────────────────────────────────────────────────────────────────────────
```

### GPU

```
Final objective value: -52.39487567908579
 ──────────────────────────────────────────────────────────────────────────────
                                       Time                   Allocations      
                               ──────────────────────   ───────────────────────
       Tot / % measured:            1.74s / 100%             100MiB / 100%     

 Section               ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────
 run                        1    1.74s   100%   1.74s    100MiB  100%    100MiB
   run core                 1    1.49s  85.5%   1.49s   34.7MiB  34.6%  34.7MiB
     Phase 2                1    1.02s  58.4%   1.02s   21.7MiB  21.6%  21.7MiB
       One iteration      125    1.02s  58.3%  8.13ms   21.6MiB  21.6%   177KiB
         ratio test       124    687ms  39.4%  5.54ms   11.9MiB  11.9%  98.5KiB
         compute en...    125    204ms  11.7%  1.63ms   4.59MiB  4.58%  37.6KiB
           compute ...    125   25.9ms  1.49%   207μs   1.38MiB  1.38%  11.3KiB
         PF               123   46.9ms  2.69%   381μs   2.02MiB  2.02%  16.8KiB
         compute pB       125   12.3ms  0.71%  98.4μs    600KiB  0.58%  4.80KiB
         compute di...    124   10.3ms  0.59%  83.4μs    587KiB  0.57%  4.73KiB
         update basis     124   4.43ms  0.25%  35.7μs   73.6KiB  0.07%     608B
         inverse            1   1.74ms  0.10%  1.74ms   12.0KiB  0.01%  12.0KiB
         detect cycly     124   1.56ms  0.09%  12.6μs    270KiB  0.26%  2.17KiB
       inverse              1   2.18ms  0.13%  2.18ms   12.0KiB  0.01%  12.0KiB
       compute xB           1    292μs  0.02%   292μs   12.3KiB  0.01%  12.3KiB
     Phase 1                1    470ms  26.9%   470ms   12.7MiB  12.6%  12.7MiB
       One iteration       39    448ms  25.7%  11.5ms   8.67MiB  8.64%   228KiB
         compute en...     39    213ms  12.2%  5.45ms   3.73MiB  3.72%  97.8KiB
           compute ...     39   10.6ms  0.61%   272μs    336KiB  0.33%  8.62KiB
         ratio test        38    191ms  11.0%  5.04ms   3.33MiB  3.32%  89.8KiB
         PF                38   17.1ms  0.98%   450μs    656KiB  0.64%  17.3KiB
         compute di...     38   4.88ms  0.28%   128μs    180KiB  0.18%  4.73KiB
         compute pB        39   4.17ms  0.24%   107μs    187KiB  0.18%  4.80KiB
         update basis      38   1.45ms  0.08%  38.3μs   22.6KiB  0.02%     608B
         detect cycly      38    454μs  0.03%  11.9μs   83.0KiB  0.08%  2.18KiB
       inverse              1   2.40ms  0.14%  2.40ms   13.3KiB  0.01%  13.3KiB
       compute xB           1    459μs  0.03%   459μs   13.6KiB  0.01%  13.6KiB
   presolve                 1    212ms  12.2%   212ms   41.8MiB  41.7%  41.8MiB
     row reduction          1    212ms  12.2%   212ms   41.8MiB  41.7%  41.8MiB
   scaling                  1   38.8ms  2.23%  38.8ms   22.8MiB  22.7%  22.8MiB
 ──────────────────────────────────────────────────────────────────────────────
```
