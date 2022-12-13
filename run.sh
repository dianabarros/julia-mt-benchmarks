start_time=$(date +%s);
for i in 2 4 8 16 32 64; do
    echo "Running Mutual Friendly Numbers with $i threads.";
    julia -t $i mutually_friendly_numbers/benchmarks.jl --timed;
done;
for i in 2 4 8 16 32 64; do
    echo "Running Password Cracking with $i threads.";
    julia -t $i password_cracking/benchmarks.jl --timed;
done;
for i in 2 4 8 16 32 64; do
    echo "Running Transitive Closure with $i threads.";
    julia -t $i transitive_closure/benchmarks.jl --timed; #--funcs [debug_warshall_threads!,debug_warshall!];
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";