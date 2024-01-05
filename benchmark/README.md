# Benchmarking devshell evaluation

devshell is built on top of nix, and the nixpkgs module system, which can take
quite a while to evaluate.

## Hyperfine

Command:

```console
nix run .#bench
```

Output:

```console
Benchmark 1: nix-instantiate ../shell.nix
  Time (mean ± σ):     568.2 ms ±  18.0 ms    [User: 486.2 ms, System: 81.1 ms]
  Range (min … max):   544.5 ms … 596.0 ms    10 runs
 
Benchmark 2: nix-instantiate ./devshell-nix.nix
  Time (mean ± σ):     189.6 ms ±  11.8 ms    [User: 150.1 ms, System: 38.6 ms]
  Range (min … max):   177.8 ms … 221.0 ms    13 runs
 
Benchmark 3: nix-instantiate ./devshell-toml.nix
  Time (mean ± σ):     194.0 ms ±   7.4 ms    [User: 155.1 ms, System: 38.8 ms]
  Range (min … max):   181.4 ms … 214.5 ms    15 runs
 
Benchmark 4: nix-instantiate ./nixpkgs-mkshell.nix
  Time (mean ± σ):     148.9 ms ±   4.7 ms    [User: 118.3 ms, System: 30.3 ms]
  Range (min … max):   143.7 ms … 164.6 ms    20 runs
 
Summary
  nix-instantiate ./nixpkgs-mkshell.nix ran
    1.27 ± 0.09 times faster than nix-instantiate ./devshell-nix.nix
    1.30 ± 0.06 times faster than nix-instantiate ./devshell-toml.nix
    3.82 ± 0.17 times faster than nix-instantiate ../shell.nix
```

## Nix stats

### repo shell

Command:

```console
NIX_SHOW_STATS=1 nix-instantiate ../shell.nix 2>&1
```

Output:

```console
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
/nix/store/6vha60nh201fd5m36nphysmsrvvk0zq0-devshell.drv
{
  "cpuTime": 0.42238301038742065,
  "envs": {
    "bytes": 17234184,
    "elements": 879269,
    "number": 637502
  },
  "gc": {
    "heapSize": 402915328,
    "totalBytes": 116416656
  },
  "list": {
    "bytes": 2528832,
    "concats": 28933,
    "elements": 316104
  },
  "nrAvoided": 869773,
  "nrFunctionCalls": 574722,
  "nrLookups": 387457,
  "nrOpUpdateValuesCopied": 2237754,
  "nrOpUpdates": 54186,
  "nrPrimOpCalls": 405710,
  "nrThunks": 958406,
  "sets": {
    "bytes": 46573200,
    "elements": 2771910,
    "number": 138915
  },
  "sizes": {
    "Attr": 16,
    "Bindings": 16,
    "Env": 16,
    "Value": 24
  },
  "symbols": {
    "bytes": 551230,
    "number": 48261
  },
  "values": {
    "bytes": 28690080,
    "number": 1195420
  }
}
```

### devshell-nix

Command:

```console
NIX_SHOW_STATS=1 nix-instantiate ./devshell-nix.nix 2>&1
```

Output:

```console
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
/nix/store/6zlkfp88d1ic0zyw49kb8srnqbwz5277-devshell.drv
{
  "cpuTime": 0.17254799604415894,
  "envs": {
    "bytes": 3515536,
    "elements": 175074,
    "number": 132184
  },
  "gc": {
    "heapSize": 402915328,
    "totalBytes": 39903680
  },
  "list": {
    "bytes": 580176,
    "concats": 3499,
    "elements": 72522
  },
  "nrAvoided": 192068,
  "nrFunctionCalls": 116933,
  "nrLookups": 56485,
  "nrOpUpdateValuesCopied": 1160535,
  "nrOpUpdates": 7873,
  "nrPrimOpCalls": 99486,
  "nrThunks": 274189,
  "sets": {
    "bytes": 22358832,
    "elements": 1364423,
    "number": 33004
  },
  "sizes": {
    "Attr": 16,
    "Bindings": 16,
    "Env": 16,
    "Value": 24
  },
  "symbols": {
    "bytes": 222375,
    "number": 23097
  },
  "values": {
    "bytes": 8141064,
    "number": 339211
  }
}
```

### devshell-toml

Command:

```console
NIX_SHOW_STATS=1 nix-instantiate ./devshell-toml.nix 2>&1
```

Output:

```console
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
/nix/store/6zlkfp88d1ic0zyw49kb8srnqbwz5277-devshell.drv
{
  "cpuTime": 0.14970900118350983,
  "envs": {
    "bytes": 3515888,
    "elements": 175092,
    "number": 132197
  },
  "gc": {
    "heapSize": 402915328,
    "totalBytes": 39907952
  },
  "list": {
    "bytes": 580248,
    "concats": 3498,
    "elements": 72531
  },
  "nrAvoided": 192084,
  "nrFunctionCalls": 116941,
  "nrLookups": 56497,
  "nrOpUpdateValuesCopied": 1160541,
  "nrOpUpdates": 7874,
  "nrPrimOpCalls": 99494,
  "nrThunks": 274209,
  "sets": {
    "bytes": 22359328,
    "elements": 1364444,
    "number": 33014
  },
  "sizes": {
    "Attr": 16,
    "Bindings": 16,
    "Env": 16,
    "Value": 24
  },
  "symbols": {
    "bytes": 222404,
    "number": 23100
  },
  "values": {
    "bytes": 8141856,
    "number": 339244
  }
}
```

### nixpkgs-mkshell

Command:

```console
NIX_SHOW_STATS=1 nix-instantiate ./nixpkgs-mkshell.nix 2>&1
```

Output:

```console
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
/nix/store/53c78xjnkv3f7c87cwly5hgys1kbdjqv-nix-shell.drv
{
  "cpuTime": 0.11669100075960159,
  "envs": {
    "bytes": 2552672,
    "elements": 126138,
    "number": 96473
  },
  "gc": {
    "heapSize": 402915328,
    "totalBytes": 34785856te ../shell.nix 2>&1
```
  },
  "list": {
    "bytes": 457816,
    "concats": 1927,
    "elements": 57227
  },
  "nrAvoided": 148098,
  "nrFunctionCalls": 85099,
  "nrLookups": 35864,
  "nrOpUpdateValuesCopied": 1078888,
  "nrOpUpdates": 5237,
  "nrPrimOpCalls": 79444,
  "nrThunks": 230270,
  "sets": {
    "bytes": 20572560,
    "elements": 1261476,
    "number": 24309
  },
  "sizes": {
    "Attr": 16,
    "Bindings": 16,
    "Env": 16,
    "Value": 24
  },
  "symbols": {
    "bytes": 218655,
    "number": 22549
  },
  "values": {
    "bytes": 6839184,
    "number": 284966
  }
}
```
