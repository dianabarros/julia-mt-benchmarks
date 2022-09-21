for i in {1..10}; do
    echo "Running sequential version"
    command time -v --output=mem_logs/small_seq_log_${i}.txt ../tcsm < ../1280_nodes.in
    command time -v --output=mem_logs/medium_seq_log_${i}.txt ../tcsm < ../2560_nodes.in
    command time -v --output=mem_logs/large_seq_log_${i}.txt ../tcsm < ../transitive_closure.in

    echo "Running OpenMP version with 2 threads"
    OMP_NUM_THREADS=2 command time -v --output=mem_logs/small_mt_2_log_${i}.txt ../tcm < ../1280_nodes.in
    OMP_NUM_THREADS=2 command time -v --output=mem_logs/medium_mt_2_log_${i}.txt ../tcm < ../2560_nodes.in
    OMP_NUM_THREADS=2 command time -v --output=mem_logs/large_mt_2_log_${i}.txt ../tcm < ../transitive_closure.in

    echo "Running OpenMP version with 4 threads"
    OMP_NUM_THREADS=4 command time -v --output=mem_logs/small_mt_4_log_${i}.txt ../tcm < ../1280_nodes.in
    OMP_NUM_THREADS=4 command time -v --output=mem_logs/medium_mt_4_log_${i}.txt ../tcm < ../2560_nodes.in
    OMP_NUM_THREADS=4 command time -v --output=mem_logs/large_mt_4_log_${i}.txt ../tcm < ../transitive_closure.in

    echo "Running OpenMP version with 8 threads"
    OMP_NUM_THREADS=8 command time -v --output=mem_logs/small_mt_8_log_${i}.txt ../tcm < ../1280_nodes.in
    OMP_NUM_THREADS=8 command time -v --output=mem_logs/medium_mt_8_log_${i}.txt ../tcm < ../2560_nodes.in
    OMP_NUM_THREADS=8 command time -v --output=mem_logs/large_mt_8_log_${i}.txt ../tcm < ../transitive_closure.in

    echo "Running OpenMP version with 16 threads"
    OMP_NUM_THREADS=16 command time -v --output=mem_logs/small_mt_16_log_${i}.txt ../tcm < ../1280_nodes.in
    OMP_NUM_THREADS=16 command time -v --output=mem_logs/medium_mt_16_log_${i}.txt ../tcm < ../2560_nodes.in
    OMP_NUM_THREADS=16 command time -v --output=mem_logs/large_mt_16_log_${i}.txt ../tcm < ../transitive_closure.in
done;