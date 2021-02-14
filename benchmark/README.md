# Benchmarking devshell evaluation

devshell is built on top of nix, and the nixpkgs module system, which can take
quite a while to evaluate.

## Hyperfine

`$ hyperfine -w 3 'nix-instantiate ../shell.nix' 'nix-instantiate ./devshell-nix.nix' 'nix-instantiate ./devshell-toml.nix' 'nix-instantiate ./nixpkgs-mkshell.nix'`
```
Benchmark #1: nix-instantiate ../shell.nix
  Time (mean ± σ):      1.082 s ±  0.011 s    [User: 732.6 ms, System: 154.7 ms]
  Range (min … max):    1.065 s …  1.099 s    10 runs
 
Benchmark #2: nix-instantiate ./devshell-nix.nix
  Time (mean ± σ):     412.1 ms ±   3.3 ms    [User: 300.0 ms, System: 63.8 ms]
  Range (min … max):   406.8 ms … 417.4 ms    10 runs
 
Benchmark #3: nix-instantiate ./devshell-toml.nix
  Time (mean ± σ):     411.6 ms ±   6.6 ms    [User: 299.7 ms, System: 64.7 ms]
  Range (min … max):   403.6 ms … 420.5 ms    10 runs
 
Benchmark #4: nix-instantiate ./nixpkgs-mkshell.nix
  Time (mean ± σ):     359.7 ms ±   9.1 ms    [User: 269.2 ms, System: 52.6 ms]
  Range (min … max):   349.8 ms … 379.9 ms    10 runs
 
Summary
  'nix-instantiate ./nixpkgs-mkshell.nix' ran
    1.14 ± 0.03 times faster than 'nix-instantiate ./devshell-toml.nix'
    1.15 ± 0.03 times faster than 'nix-instantiate ./devshell-nix.nix'
    3.01 ± 0.08 times faster than 'nix-instantiate ../shell.nix'
```

## Nix stats

### repo shell

`$ NIX_SHOW_STATS=1 nix-instantiate ./../shell.nix 2>&1`
```
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
/nix/store/xbadj2p1yva55gcm6n6ml028wdgbap5f-devshell.drv
{
  "cpuTime": 0.742534,
  "envs": {
    "number": 189808,
    "elements": 321331,
    "bytes": 5607576
  },
  "list": {
    "elements": 119124,
    "bytes": 952992,
    "concats": 13943
  },
  "values": {
    "number": 607122,
    "bytes": 14570928
  },
  "symbols": {
    "number": 37696,
    "bytes": 917618
  },
  "sets": {
    "number": 60629,
    "bytes": 42826168,
    "elements": 1764214
  },
  "sizes": {
    "Env": 16,
    "Value": 24,
    "Bindings": 8,
    "Attr": 24
  },
  "nrOpUpdates": 29262,
  "nrOpUpdateValuesCopied": 1463167,
  "nrThunks": 446497,
  "nrAvoided": 320262,
  "nrLookups": 175553,
  "nrPrimOpCalls": 139902,
  "nrFunctionCalls": 167314,
  "gc": {
    "heapSize": 402915328,
    "totalBytes": 75203696
  }
}
```


### devshell-nix

`$ NIX_SHOW_STATS=1 nix-instantiate ./devshell-nix.nix 2>&1`
```
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
/nix/store/r304514lvygyzh8l75cgjhkhfqs15d1m-devshell.drv
{
  "cpuTime": 0.364713,
  "envs": {
    "number": 74392,
    "elements": 105623,
    "bytes": 2035256
  },
  "list": {
    "elements": 40998,
    "bytes": 327984,
    "concats": 2342
  },
  "values": {
    "number": 243435,
    "bytes": 5842440
  },
  "symbols": {
    "number": 29700,
    "bytes": 662792
  },
  "sets": {
    "number": 18563,
    "bytes": 23664496,
    "elements": 979833
  },
  "sizes": {
    "Env": 16,
    "Value": 24,
    "Bindings": 8,
    "Attr": 24
  },
  "nrOpUpdates": 5563,
  "nrOpUpdateValuesCopied": 837612,
  "nrThunks": 186590,
  "nrAvoided": 109995,
  "nrLookups": 34126,
  "nrPrimOpCalls": 54602,
  "nrFunctionCalls": 65308,
  "gc": {
    "heapSize": 402915328,
    "totalBytes": 35643456
  }
}
```

### devshell-toml

`$ NIX_SHOW_STATS=1 nix-instantiate ./devshell-toml.nix 2>&1`
```
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
/nix/store/r304514lvygyzh8l75cgjhkhfqs15d1m-devshell.drv
{
  "cpuTime": 0.291564,
  "envs": {
    "number": 74405,
    "elements": 105638,
    "bytes": 2035584
  },
  "list": {
    "elements": 41008,
    "bytes": 328064,
    "concats": 2342
  },
  "values": {
    "number": 243463,
    "bytes": 5843112
  },
  "symbols": {
    "number": 29700,
    "bytes": 662793
  },
  "sets": {
    "number": 18572,
    "bytes": 23665144,
    "elements": 979857
  },
  "sizes": {
    "Env": 16,
    "Value": 24,
    "Bindings": 8,
    "Attr": 24
  },
  "nrOpUpdates": 5564,
  "nrOpUpdateValuesCopied": 837622,
  "nrThunks": 186605,
  "nrAvoided": 110009,
  "nrLookups": 34136,
  "nrPrimOpCalls": 54608,
  "nrFunctionCalls": 65318,
  "gc": {
    "heapSize": 402915328,
    "totalBytes": 35643456
  }
}
```

### nixpkgs-mkshell

`$ NIX_SHOW_STATS=1 nix-instantiate ./nixpkgs-mkshell.nix 2>&1`
```
warning: you did not specify '--add-root'; the result might be removed by the garbage collector
/nix/store/d0is0v6f86dsj2sjrdl0bszq0w0fhpn8-nix-shell.drv
{
  "cpuTime": 0.271529,
  "envs": {
    "number": 57978,
    "elements": 78401,
    "bytes": 1554856
  },
  "list": {
    "elements": 33856,
    "bytes": 270848,
    "concats": 1192
  },
  "values": {
    "number": 205224,
    "bytes": 4925376
  },
  "symbols": {
    "number": 29169,
    "bytes": 641516
  },
  "sets": {
    "number": 13313,
    "bytes": 22291168,
    "elements": 924361
  },
  "sizes": {
    "Env": 16,
    "Value": 24,
    "Bindings": 8,
    "Attr": 24
  },
  "nrOpUpdates": 3373,
  "nrOpUpdateValuesCopied": 797699,
  "nrThunks": 159998,
  "nrAvoided": 86376,
  "nrLookups": 19189,
  "nrPrimOpCalls": 46043,
  "nrFunctionCalls": 50785,
  "gc": {
    "heapSize": 402915328,
    "totalBytes": 32125552
  }
}
```
