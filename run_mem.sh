start_time=$(date +%s);
for i in 2 4 8 16; do
    echo "Running Mutual Friendly Numbers with $i threads.";
    julia -t $i mutually_friendly_numbers/mem_benchmark.jl;
done;
for i in 2 4 8 16; do
    echo "Running Password Cracking with $i threads.";
    julia -t $i password_cracking/mem_benchmark.jl;
done;
for i in 2 4 8 16; do
    echo "Running Transitive Closure with $i threads.";
    julia -t $i transitive_closure/mem_benchmark.jl;
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";