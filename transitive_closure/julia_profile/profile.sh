start_time=$(date +%s);

for i in {1..10}; do
    echo "Running sequential version"
    command time -v --output=small_seq_log_${i}.txt julia ../transitive_closure_mem_seq.jl  ../1280_nodes.in
    command time -v --output=medium_seq_log_${i}.txt julia ../transitive_closure_mem_seq.jl ../2560_nodes.in
    command time -v --output=large_seq_log_${i}.txt julia ../transitive_closure_mem_seq.jl ../transitive_closure.in

    echo "Running @threads version with 2 threads"
    command time -v --output=small_mt_2_log_${i}.txt julia -t 2 ../transitive_closure_mem_threads.jl ../1280_nodes.in
    command time -v --output=medium_mt_2_log_${i}.txt julia -t 2 ../transitive_closure_mem_threads.jl ../2560_nodes.in
    command time -v --output=large_mt_2_log_${i}.txt julia -t 2 ../transitive_closure_mem_threads.jl ../transitive_closure.in

    echo "Running @threads version with 4 threads"
    command time -v --output=small_mt_4_log_${i}.txt julia -t 4 ../transitive_closure_mem_threads.jl ../1280_nodes.in
    command time -v --output=medium_mt_4_log_${i}.txt julia -t 4 ../transitive_closure_mem_threads.jl ../2560_nodes.in
    command time -v --output=large_mt_4_log_${i}.txt julia -t 4 ../transitive_closure_mem_threads.jl ../transitive_closure.in

    echo "Running @threads version with 8 threads"
    command time -v --output=small_mt_8_log_${i}.txt julia -t 8 ../transitive_closure_mem_threads.jl ../1280_nodes.in
    command time -v --output=medium_mt_8_log_${i}.txt julia -t 8 ../transitive_closure_mem_threads.jl ../2560_nodes.in
    command time -v --output=large_mt_8_log_${i}.txt julia -t 8 ../transitive_closure_mem_threads.jl ../transitive_closure.in

    echo "Running @threads version with 16 threads"
    command time -v --output=small_mt_16_log_${i}.txt julia -t 16 ../transitive_closure_mem_threads.jl ../1280_nodes.in
    command time -v --output=medium_mt_16_log_${i}.txt julia -t 16 ../transitive_closure_mem_threads.jl ../2560_nodes.in
    command time -v --output=large_mt_16_log_${i}.txt julia -t 16 ../transitive_closure_mem_threads.jl ../transitive_closure.in

    echo "Running FLoops version with 2 threads"
    command time -v --output=small_floops_2_log_${i}.txt julia -t 2 ../transitive_closure_mem_floops.jl ../1280_nodes.in DepthFirstEx
    command time -v --output=medium_floops_2_log_${i}.txt julia -t 2 ../transitive_closure_mem_floops.jl ../2560_nodes.in DepthFirstEx
    command time -v --output=large_floops_2_log_${i}.txt julia -t 2 ../transitive_closure_mem_floops.jl ../transitive_closure.in DepthFirstEx

    echo "Running FLoops version with 4 threads"
    command time -v --output=small_floops_4_log_${i}.txt julia -t 4 ../transitive_closure_mem_floops.jl ../1280_nodes.in DepthFirstEx
    command time -v --output=medium_floops_4_log_${i}.txt julia -t 4 ../transitive_closure_mem_floops.jl ../2560_nodes.in DepthFirstEx
    command time -v --output=large_floops_4_log_${i}.txt julia -t 4 ../transitive_closure_mem_floops.jl ../transitive_closure.in DepthFirstEx

    echo "Running FLoops version with 8 threads"
    command time -v --output=small_floops_8_log_${i}.txt julia -t 8 ../transitive_closure_mem_floops.jl ../1280_nodes.in DepthFirstEx
    command time -v --output=medium_floops_8_log_${i}.txt julia -t 8 ../transitive_closure_mem_floops.jl ../2560_nodes.in DepthFirstEx
    command time -v --output=large_floops_8_log_${i}.txt julia -t 8 ../transitive_closure_mem_floops.jl ../transitive_closure.in DepthFirstEx

    echo "Running FLoops version with 16 threads"
    command time -v --output=small_floops_16_log_${i}.txt julia -t 16 ../transitive_closure_mem_floops.jl ../1280_nodes.in DepthFirstEx
    command time -v --output=medium_floops_16_log_${i}.txt julia -t 16 ../transitive_closure_mem_floops.jl ../2560_nodes.in DepthFirstEx
    command time -v --output=large_floops_16_log_${i}.txt julia -t 16 ../transitive_closure_mem_floops.jl ../transitive_closure.in DepthFirstEx
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";