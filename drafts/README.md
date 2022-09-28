Contains drafts of abandomned experiment ideas

### QAP

---

Considered because:
- Possible advantage from DepthFirst loop scheduling

Abandonmed because:
- Recursive implementation naturally travels through a depth first path. Would need work time invested for iterative implementation


### kmeans, nbody, fibonacci

---

### Shared Libs

---

Considered because:
- Would enable direct call from Julia through `ccall`, hence enabling the usage of BenchmarkTools, in which would facilitate the measurements of execution time and memory usage

Abandomned because:
- The transitive closure application would need rework for reading the input file and passing as inputs for the application
- Possible thread unsafety from calling form Julia