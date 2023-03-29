start_time=$(date +%s);

for i in {1..10}; do
    echo "Running sequential version"
    command time -v --output=small_seq_log_${i}.txt julia ../brute_force_password_cracking_mem_seq.jl  be5d75fa67ef370e98b3d3611c318156
    command time -v --output=medium_seq_log_${i}.txt julia ../brute_force_password_cracking_mem_seq.jl 9cbbf96d1973a60adebbb153f64b48f6
    command time -v --output=large_seq_log_${i}.txt julia ../brute_force_password_cracking_mem_seq.jl 34799a12a6ef24ef95a0f3179ac3c78d

    echo "Running @threads version with 2 threads"
    command time -v --output=small_mt_2_log_${i}.txt julia -t 2 ../brute_force_password_cracking_mem_threads.jl be5d75fa67ef370e98b3d3611c318156
    command time -v --output=medium_mt_2_log_${i}.txt julia -t 2 ../brute_force_password_cracking_mem_threads.jl 9cbbf96d1973a60adebbb153f64b48f6
    command time -v --output=large_mt_2_log_${i}.txt julia -t 2 ../brute_force_password_cracking_mem_threads.jl 34799a12a6ef24ef95a0f3179ac3c78d

    echo "Running @threads version with 4 threads"
    command time -v --output=small_mt_4_log_${i}.txt julia -t 4 ../brute_force_password_cracking_mem_threads.jl be5d75fa67ef370e98b3d3611c318156
    command time -v --output=medium_mt_4_log_${i}.txt julia -t 4 ../brute_force_password_cracking_mem_threads.jl 9cbbf96d1973a60adebbb153f64b48f6
    command time -v --output=large_mt_4_log_${i}.txt julia -t 4 ../brute_force_password_cracking_mem_threads.jl 34799a12a6ef24ef95a0f3179ac3c78d

    echo "Running @threads version with 8 threads"
    command time -v --output=small_mt_8_log_${i}.txt julia -t 8 ../brute_force_password_cracking_mem_threads.jl be5d75fa67ef370e98b3d3611c318156
    command time -v --output=medium_mt_8_log_${i}.txt julia -t 8 ../brute_force_password_cracking_mem_threads.jl 9cbbf96d1973a60adebbb153f64b48f6
    command time -v --output=large_mt_8_log_${i}.txt julia -t 8 ../brute_force_password_cracking_mem_threads.jl 34799a12a6ef24ef95a0f3179ac3c78d

    echo "Running @threads version with 16 threads"
    command time -v --output=small_mt_16_log_${i}.txt julia -t 16 ../brute_force_password_cracking_mem_threads.jl be5d75fa67ef370e98b3d3611c318156
    command time -v --output=medium_mt_16_log_${i}.txt julia -t 16 ../brute_force_password_cracking_mem_threads.jl 9cbbf96d1973a60adebbb153f64b48f6
    command time -v --output=large_mt_16_log_${i}.txt julia -t 16 ../brute_force_password_cracking_mem_threads.jl 34799a12a6ef24ef95a0f3179ac3c78d

    echo "Running FLoops version with 2 threads"
    command time -v --output=small_floops_2_log_${i}.txt julia -t 2 ../brute_force_password_cracking_mem_floops.jl be5d75fa67ef370e98b3d3611c318156 DepthFirstEx
    command time -v --output=medium_floops_2_log_${i}.txt julia -t 2 ../brute_force_password_cracking_mem_floops.jl 9cbbf96d1973a60adebbb153f64b48f6 DepthFirstEx
    command time -v --output=large_floops_2_log_${i}.txt julia -t 2 ../brute_force_password_cracking_mem_floops.jl 34799a12a6ef24ef95a0f3179ac3c78d DepthFirstEx

    echo "Running FLoops version with 4 threads"
    command time -v --output=small_floops_4_log_${i}.txt julia -t 4 ../brute_force_password_cracking_mem_floops.jl be5d75fa67ef370e98b3d3611c318156 DepthFirstEx
    command time -v --output=medium_floops_4_log_${i}.txt julia -t 4 ../brute_force_password_cracking_mem_floops.jl 9cbbf96d1973a60adebbb153f64b48f6 DepthFirstEx
    command time -v --output=large_floops_4_log_${i}.txt julia -t 4 ../brute_force_password_cracking_mem_floops.jl 34799a12a6ef24ef95a0f3179ac3c78d DepthFirstEx

    echo "Running FLoops version with 8 threads"
    command time -v --output=small_floops_8_log_${i}.txt julia -t 8 ../brute_force_password_cracking_mem_floops.jl be5d75fa67ef370e98b3d3611c318156 DepthFirstEx
    command time -v --output=medium_floops_8_log_${i}.txt julia -t 8 ../brute_force_password_cracking_mem_floops.jl 9cbbf96d1973a60adebbb153f64b48f6 DepthFirstEx
    command time -v --output=large_floops_8_log_${i}.txt julia -t 8 ../brute_force_password_cracking_mem_floops.jl 34799a12a6ef24ef95a0f3179ac3c78d DepthFirstEx

    echo "Running FLoops version with 16 threads"
    command time -v --output=small_floops_16_log_${i}.txt julia -t 16 ../brute_force_password_cracking_mem_floops.jl be5d75fa67ef370e98b3d3611c318156 DepthFirstEx
    command time -v --output=medium_floops_16_log_${i}.txt julia -t 16 ../brute_force_password_cracking_mem_floops.jl 9cbbf96d1973a60adebbb153f64b48f6 DepthFirstEx
    command time -v --output=large_floops_16_log_${i}.txt julia -t 16 ../brute_force_password_cracking_mem_floops.jl 34799a12a6ef24ef95a0f3179ac3c78d DepthFirstEx
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";