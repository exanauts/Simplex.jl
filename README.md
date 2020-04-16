# Simplex.jl
Julia implementation of a revised primal simplex method

The algorithm runs on CPU and GPU.

## How to run example (examples/netlib.jl)

1. Go to `netlib` directory.
1. Compile `emps.c` by `gcc emps.c -o emps`.
1. Run the script `get.sh` that downloads and uncompress some `mps` instances.
1. Now you have some test instances. Try (at the current directory)
```
julia --project=.. ../examples/netlib.jl 1 3
```
where the first argument `1` runs on cpu (`2` for gpu) and the second argument is for the choice of pivoting algorithms.

## TODO

Several things can (or should) be done to improve the algorithm or the gpu computation.

- The current initial basis algorithm is very basic. Bixby's one can be tried.
- Crash may need to be implemented. Is this easy?
- What can I do more for gpu?

## Sample Benchmark on sc205.mps

### CPU

```
 ──────────────────────────────────────────────────────────────────────────────────────────
                                                   Time                   Allocations
                                           ──────────────────────   ───────────────────────
             Tot / % measured:                   100s / 6.08%           2.95GiB / 25.7%

 Section                           ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────────────────
 row reduction                          1    3.34s  55.2%   3.34s    429MiB  55.4%   429MiB
 run core                               1    2.72s  44.8%   2.72s    345MiB  44.6%   345MiB
   Phase 1                              1    2.60s  42.9%   2.60s    305MiB  39.3%   305MiB
     One iteration                    223    1.13s  18.7%  5.09ms    187MiB  24.2%   861KiB
       PF                             220    569ms  9.38%  2.58ms    126MiB  16.2%   584KiB
       ratio test                     222    158ms  2.60%   710μs   18.6MiB  2.41%  86.0KiB
       compute entering variable      223    101ms  1.66%   452μs   10.3MiB  1.33%  47.2KiB
         compute reduced cost         223   96.0ms  1.58%   430μs   8.00MiB  1.03%  36.7KiB
       compute direction              222   80.9ms  1.33%   364μs   5.67MiB  0.73%  26.2KiB
       compute pB                     223   23.7ms  0.39%   106μs   1.40MiB  0.18%  6.44KiB
       update basis                   222   18.7ms  0.31%  84.2μs   2.12MiB  0.27%  9.79KiB
       inverse                          2   3.93ms  0.06%  1.97ms   5.42MiB  0.70%  2.71MiB
       detect cycly                   222   2.93ms  0.05%  13.2μs    483KiB  0.06%  2.17KiB
     inverse                            1    1.04s  17.2%   1.04s   80.3MiB  10.4%  80.3MiB
     compute xB                         1    262ms  4.33%   262ms   22.5MiB  2.91%  22.5MiB
   Phase 2                              1   61.4ms  1.01%  61.4ms   38.0MiB  4.92%  38.0MiB
     inverse                            1   42.1ms  0.69%  42.1ms   7.69MiB  0.99%  7.69MiB
     One iteration                     43   19.0ms  0.31%   441μs   30.0MiB  3.88%   714KiB
       PF                              42   9.07ms  0.15%   216μs   13.4MiB  1.73%   326KiB
       compute entering variable       43   6.08ms  0.10%   141μs   15.2MiB  1.97%   363KiB
         compute reduced cost          43   5.67ms  0.09%   132μs   15.1MiB  1.95%   359KiB
       compute pB                      43   1.50ms  0.02%  34.8μs    156KiB  0.02%  3.63KiB
       ratio test                      42   1.35ms  0.02%  32.0μs    748KiB  0.09%  17.8KiB
       compute direction               42    147μs  0.00%  3.50μs    226KiB  0.03%  5.39KiB
       detect cycly                    42    127μs  0.00%  3.03μs   91.6KiB  0.01%  2.18KiB
       update basis                    42   48.5μs  0.00%  1.16μs   31.5KiB  0.00%     768B
     compute xB                         1    247μs  0.00%   247μs    363KiB  0.05%   363KiB
 ──────────────────────────────────────────────────────────────────────────────────────────
 ```
 
 ### GPU
 
 ```
 ──────────────────────────────────────────────────────────────────────────────────────────
                                                   Time                   Allocations      
                                           ──────────────────────   ───────────────────────
             Tot / % measured:                   129s / 15.2%           4.33GiB / 46.9%    

 Section                           ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────────────────
 run core                               1    16.8s  85.6%   16.8s   1.61GiB  79.4%  1.61GiB
   Phase 1                              1    10.2s  52.2%   10.2s   1.02GiB  50.1%  1.02GiB
     One iteration                    228    6.04s  30.9%  26.5ms    573MiB  27.6%  2.51MiB
       PF                             225    2.05s  10.4%  9.09ms    238MiB  11.5%  1.06MiB
       ratio test                     227    1.21s  6.20%  5.35ms   66.6MiB  3.21%   300KiB
       compute entering variable      228    1.00s  5.12%  4.39ms   60.9MiB  2.93%   273KiB
         compute reduced cost         228    401ms  2.05%  1.76ms   48.7MiB  2.35%   219KiB
       compute pB                     228    679ms  3.47%  2.98ms   75.5MiB  3.64%   339KiB
       compute direction              227    319ms  1.63%  1.40ms   46.1MiB  2.22%   208KiB
       update basis                   227   28.7ms  0.15%   126μs   2.24MiB  0.11%  10.1KiB
       inverse                          2   3.03ms  0.02%  1.52ms   25.9KiB  0.00%  13.0KiB
       detect cycly                   227   2.90ms  0.01%  12.8μs    494KiB  0.02%  2.17KiB
     inverse                            1    1.57s  8.00%   1.57s    160MiB  7.71%   160MiB
     compute xB                         1    733ms  3.74%   733ms   97.9MiB  4.72%  97.9MiB
   Phase 2                              1    206ms  1.05%   206ms   6.03MiB  0.29%  6.03MiB
     One iteration                     34    204ms  1.04%  6.00ms   6.00MiB  0.29%   181KiB
       ratio test                      33    145ms  0.74%  4.41ms   3.49MiB  0.17%   108KiB
       compute entering variable       34   44.1ms  0.23%  1.30ms   1.10MiB  0.05%  33.0KiB
         compute reduced cost          34   7.48ms  0.04%   220μs    363KiB  0.02%  10.7KiB
       PF                              33   3.73ms  0.02%   113μs    467KiB  0.02%  14.1KiB
       compute pB                      34   1.60ms  0.01%  47.2μs    272KiB  0.01%  8.01KiB
       compute direction               33   1.15ms  0.01%  34.9μs    135KiB  0.01%  4.08KiB
       update basis                    33    844μs  0.00%  25.6μs   41.8KiB  0.00%  1.27KiB
       detect cycly                    33    119μs  0.00%  3.62μs   72.2KiB  0.00%  2.19KiB
     inverse                            1   1.59ms  0.01%  1.59ms   15.8KiB  0.00%  15.8KiB
     compute xB                         1    224μs  0.00%   224μs   15.6KiB  0.00%  15.6KiB
 row reduction                          1    2.82s  14.4%   2.82s    429MiB  20.6%   429MiB
 ────────────────────────────────────────────────────────────────────────────────────────── 
 ```
