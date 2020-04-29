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

See [restuls.md](./examples/results.md) for numerical results.

## TODO

Several things can (or should) be done to improve the algorithm or the gpu computation.

- The current initial basis algorithm is very basic. Bixby's one can be tried.
- Crash may need to be implemented. Is this easy?
- What can I do more for gpu?
