# Simplex.jl
Julia implementation of a revised primal simplex method

The algorithm runs on CPU and GPU.

## How to run example (examples/netlib.jl)

1. Go to `netlib` directory.
1. Compile `emps.c` by `gcc emps.c -o emps`.
1. Run the script `get.sh` that downloads and uncompress some `mps` instances.
1. Now you have some test instances. Try (at the current directory)
```
julia --project=.. ../examples/netlib.jl
```

See [restuls.md](./examples/results.md) for numerical results.
