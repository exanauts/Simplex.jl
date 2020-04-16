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
             Tot / % measured:                   161s / 18.3%           5.12GiB / 54.0%

 Section                           ncalls     time   %tot     avg     alloc   %tot      avg
 ──────────────────────────────────────────────────────────────────────────────────────────
 run core                               1    26.6s  90.1%   26.6s   2.35GiB  84.9%  2.35GiB
   Phase 1                              1    15.1s  51.1%   15.1s   1.43GiB  51.7%  1.43GiB
     One iteration                    228    10.4s  35.1%  45.4ms   1.01GiB  36.6%  4.54MiB
       ratio test                     227    5.75s  19.5%  25.3ms    530MiB  18.7%  2.34MiB
       PF                             225    1.85s  6.26%  8.20ms    239MiB  8.46%  1.06MiB
       compute entering variable      228    964ms  3.27%  4.23ms   60.6MiB  2.14%   272KiB
         compute reduced cost         228    379ms  1.29%  1.66ms   48.5MiB  1.71%   218KiB
       compute pB                     228    670ms  2.27%  2.94ms   75.4MiB  2.67%   339KiB
       compute direction              227    307ms  1.04%  1.35ms   44.9MiB  1.59%   203KiB
       update basis                   227   16.0ms  0.05%  70.4μs   2.24MiB  0.08%  10.1KiB
       detect cycly                   227   3.79ms  0.01%  16.7μs    494KiB  0.02%  2.17KiB
       inverse                          2   3.00ms  0.01%  1.50ms   25.5KiB  0.00%  12.7KiB
     inverse                            1    1.98s  6.73%   1.98s    153MiB  5.41%   153MiB
     compute xB                         1    883ms  3.00%   883ms   98.2MiB  3.47%  98.2MiB
   Phase 2                              1    2.08s  7.05%   2.08s    169MiB  5.98%   169MiB
     One iteration                     34    2.08s  7.04%  61.0ms    169MiB  5.98%  4.98MiB
       ratio test                      33    2.00s  6.79%  60.7ms    167MiB  5.89%  5.05MiB
       compute entering variable       34   45.0ms  0.15%  1.32ms   1.12MiB  0.04%  33.9KiB
         compute reduced cost          34   4.50ms  0.02%   132μs    393KiB  0.01%  11.6KiB
       PF                              33   6.06ms  0.02%   184μs    467KiB  0.02%  14.1KiB
       compute pB                      34   2.33ms  0.01%  68.5μs    228KiB  0.01%  6.72KiB
       compute direction               33   1.87ms  0.01%  56.6μs    135KiB  0.00%  4.08KiB
       update basis                    33   1.00ms  0.00%  30.4μs   41.8KiB  0.00%  1.27KiB
       detect cycly                    33    286μs  0.00%  8.68μs   72.2KiB  0.00%  2.19KiB
     inverse                            1   1.62ms  0.01%  1.62ms   12.7KiB  0.00%  12.7KiB
     compute xB                         1    691μs  0.00%   691μs   15.6KiB  0.00%  15.6KiB
 row reduction                          1    2.93s  9.93%   2.93s    429MiB  15.1%   429MiB
 ──────────────────────────────────────────────────────────────────────────────────────────
 ```
