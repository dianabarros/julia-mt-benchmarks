start_time=$(date +%s);
for i in 2 4 8 16; do
    echo "Running Small ThreadedEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"small\"] --funcs [debug_warshall_floops!] --executors [ThreadedEx];
    mkdir -p transitive_closure_threadedex_small
    mv *.csv *.txt transitive_closure_threadedex_small
done;
for i in 2 4 8 16; do
    echo "Running Medium ThreadedEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"medium\"] --funcs [debug_warshall_floops!] --executors [ThreadedEx];
    mkdir -p transitive_closure_threadedex_medium
    mv *.csv *.txt transitive_closure_threadedex_medium
done;
for i in 2 4 8 16; do
    echo "Running Large ThreadedEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"large\"] --funcs [debug_warshall_floops!] --executors [ThreadedEx];
    mkdir -p transitive_closure_threadedex_large
    mv *.csv *.txt transitive_closure_threadedex_large
done;

for i in 2 4 8 16; do
    echo "Running Small WorkStealingEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"small\"] --funcs [debug_warshall_floops!] --executors [WorkStealingEx];
    mkdir -p transitive_closure_workstealingex_small
    mv *.csv *.txt transitive_closure_workstealingex_small
done;
for i in 2 4 8 16; do
    echo "Running Medium WorkStealingEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"medium\"] --funcs [debug_warshall_floops!] --executors [WorkStealingEx];
    mkdir -p transitive_closure_workstealingex_medium
    mv *.csv *.txt transitive_closure_workstealingex_medium
done;
for i in 2 4 8 16; do
    echo "Running Large WorkStealingEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"large\"] --funcs [debug_warshall_floops!] --executors [WorkStealingEx];
    mkdir -p transitive_closure_workstealingex_large
    mv *.csv *.txt transitive_closure_workstealingex_large
done;

for i in 2 4 8 16; do
    echo "Running Small DepthFirstEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"small\"] --funcs [debug_warshall_floops!] --executors [DepthFirstEx];
    mkdir -p transitive_closure_depthfirstex_small
    mv *.csv *.txt transitive_closure_depthfirstex_small
done;
for i in 2 4 8 16; do
    echo "Running Medium DepthFirstEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"medium\"] --funcs [debug_warshall_floops!] --executors [DepthFirstEx];
    mkdir -p transitive_closure_depthfirstex_medium
    mv *.csv *.txt transitive_closure_depthfirstex_medium
done;
for i in 2 4 8 16; do
    echo "Running Large DepthFirstEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"large\"] --funcs [debug_warshall_floops!] --executors [DepthFirstEx];
    mkdir -p transitive_closure_depthfirstex_large
    mv *.csv *.txt transitive_closure_depthfirstex_large
done;

for i in 2 4 8 16; do
    echo "Running Small TaskPoolEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"small\"] --funcs [debug_warshall_floops!] --executors [TaskPoolEx];
    mkdir -p transitive_closure_taskpoolex_small
    mv *.csv *.txt transitive_closure_taskpoolex_small
done;
for i in 2 4 8 16; do
    echo "Running Medium TaskPoolEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"medium\"] --funcs [debug_warshall_floops!] --executors [TaskPoolEx];
    mkdir -p transitive_closure_taskpoolex_medium
    mv *.csv *.txt transitive_closure_taskpoolex_medium
done;
for i in 2 4 8 16; do
    echo "Running Large TaskPoolEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"large\"] --funcs [debug_warshall_floops!] --executors [TaskPoolEx];
    mkdir -p transitive_closure_taskpoolex_large
    mv *.csv *.txt transitive_closure_taskpoolex_large
done;

for i in 2 4 8 16; do
    echo "Running Small NondeterministicEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"small\"] --funcs [debug_warshall_floops!] --executors [NondeterministicEx];
    mkdir -p transitive_closure_nondet_small
    mv *.csv *.txt transitive_closure_nondet_small
done;
for i in 2 4 8 16; do
    echo "Running Medium NondeterministicEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"medium\"] --funcs [debug_warshall_floops!] --executors [NondeterministicEx];
    mkdir -p transitive_closure_nondet_medium
    mv *.csv *.txt transitive_closure_nondet_medium
done;
for i in 2 4 8 16; do
    echo "Running Large NondeterministicEx Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed --inputs [\"large\"] --funcs [debug_warshall_floops!] --executors [NondeterministicEx];
    mkdir -p transitive_closure_nondet_large
    mv *.csv *.txt transitive_closure_nondet_large
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";