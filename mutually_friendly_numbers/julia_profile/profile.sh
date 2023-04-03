start_time=$(date +%s);

echo "Compiling..."
julia ../friendly_numbers_mem_seq.jl 0 10
julia -t 2 ../friendly_numbers_mem_threads.jl 0 10
julia -t 2 ../friendly_numbers_mem_floops.jl 0 10 ThreadedEx

for i in {1..10}; do
    echo "Running sequential version"
    command time -v --output=small_seq_log_${i}.txt julia --compile=no ../friendly_numbers_mem_seq.jl  0 50000 
    command time -v --output=medium_seq_log_${i}.txt julia --compile=no ../friendly_numbers_mem_seq.jl 0 200000
    command time -v --output=large_seq_log_${i}.txt julia --compile=no ../friendly_numbers_mem_seq.jl 0 350000

    echo "Running @threads version with 2 threads"
    command time -v --output=small_mt_2_log_${i}.txt julia --compile=no -t 2 ../friendly_numbers_mem_threads.jl 0 50000 
    command time -v --output=medium_mt_2_log_${i}.txt julia --compile=no -t 2 ../friendly_numbers_mem_threads.jl 0 200000
    command time -v --output=large_mt_2_log_${i}.txt julia --compile=no -t 2 ../friendly_numbers_mem_threads.jl 0 350000

    echo "Running @threads version with 4 threads"
    command time -v --output=small_mt_4_log_${i}.txt julia --compile=no -t 4 ../friendly_numbers_mem_threads.jl 0 50000 
    command time -v --output=medium_mt_4_log_${i}.txt julia --compile=no -t 4 ../friendly_numbers_mem_threads.jl 0 200000
    command time -v --output=large_mt_4_log_${i}.txt julia --compile=no -t 4 ../friendly_numbers_mem_threads.jl 0 350000

    echo "Running @threads version with 8 threads"
    command time -v --output=small_mt_8_log_${i}.txt julia --compile=no -t 8 ../friendly_numbers_mem_threads.jl 0 50000 
    command time -v --output=medium_mt_8_log_${i}.txt julia --compile=no -t 8 ../friendly_numbers_mem_threads.jl 0 200000
    command time -v --output=large_mt_8_log_${i}.txt julia --compile=no -t 8 ../friendly_numbers_mem_threads.jl 0 350000

    echo "Running @threads version with 16 threads"
    command time -v --output=small_mt_16_log_${i}.txt julia --compile=no -t 16 ../friendly_numbers_mem_threads.jl 0 50000 
    command time -v --output=medium_mt_16_log_${i}.txt julia --compile=no -t 16 ../friendly_numbers_mem_threads.jl 0 200000
    command time -v --output=large_mt_16_log_${i}.txt julia --compile=no -t 16 ../friendly_numbers_mem_threads.jl 0 350000

    echo "Running FLoops version with 2 threads"
    command time -v --output=small_floops_2_log_${i}.txt julia --compile=no -t 2 ../friendly_numbers_mem_floops.jl 0 50000  ThreadedEx
    command time -v --output=medium_floops_2_log_${i}.txt julia --compile=no -t 2 ../friendly_numbers_mem_floops.jl 0 200000 ThreadedEx
    command time -v --output=large_floops_2_log_${i}.txt julia --compile=no -t 2 ../friendly_numbers_mem_floops.jl 0 350000 ThreadedEx

    echo "Running FLoops version with 4 threads"
    command time -v --output=small_floops_4_log_${i}.txt julia --compile=no -t 4 ../friendly_numbers_mem_floops.jl 0 50000  ThreadedEx
    command time -v --output=medium_floops_4_log_${i}.txt julia --compile=no -t 4 ../friendly_numbers_mem_floops.jl 0 200000 ThreadedEx
    command time -v --output=large_floops_4_log_${i}.txt julia --compile=no -t 4 ../friendly_numbers_mem_floops.jl 0 350000 ThreadedEx

    echo "Running FLoops version with 8 threads"
    command time -v --output=small_floops_8_log_${i}.txt julia --compile=no -t 8 ../friendly_numbers_mem_floops.jl 0 50000  ThreadedEx
    command time -v --output=medium_floops_8_log_${i}.txt julia --compile=no -t 8 ../friendly_numbers_mem_floops.jl 0 200000 ThreadedEx
    command time -v --output=large_floops_8_log_${i}.txt julia --compile=no -t 8 ../friendly_numbers_mem_floops.jl 0 350000 ThreadedEx

    echo "Running FLoops version with 16 threads"
    command time -v --output=small_floops_16_log_${i}.txt julia --compile=no -t 16 ../friendly_numbers_mem_floops.jl 0 50000  ThreadedEx
    command time -v --output=medium_floops_16_log_${i}.txt julia --compile=no -t 16 ../friendly_numbers_mem_floops.jl 0 200000 ThreadedEx
    command time -v --output=large_floops_16_log_${i}.txt julia --compile=no -t 16 ../friendly_numbers_mem_floops.jl 0 350000 ThreadedEx
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";