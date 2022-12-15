start_time=$(date +%s);
julia instantiate.jl;
for i in 2 4 8 16 32 64; do
    echo "Running Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed; #--funcs [debug_warshall_threads!,debug_warshall!];
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";