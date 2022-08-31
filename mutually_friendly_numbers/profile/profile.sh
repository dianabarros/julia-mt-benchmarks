for i in {1..10}; do
    echo "Running sequential version"
    command time -v --output=small_seq_log_${i}.txt ../fsm 0 50000 
    command time -v --output=medium_seq_log_${i}.txt ../fsm 0 200000
    command time -v --output=large_seq_log_${i}.txt ../fsm 0 350000

    echo "Running OpenMP version with 2 threads"
    OMP_NUM_THREADS=2 command time -v --output=small_mt_2_log_${i}.txt ../fm 0 50000
    OMP_NUM_THREADS=2 command time -v --output=medium_mt_2_log_${i}.txt ../fm 0 200000
    OMP_NUM_THREADS=2 command time -v --output=large_mt_2_log_${i}.txt ../fm 0 350000

    echo "Running OpenMP version with 4 threads"
    OMP_NUM_THREADS=4 command time -v --output=small_mt_4_log_${i}.txt ../fm 0 50000
    OMP_NUM_THREADS=4 command time -v --output=medium_mt_4_log_${i}.txt ../fm 0 200000
    OMP_NUM_THREADS=4 command time -v --output=large_mt_4_log_${i}.txt ../fm 0 350000

    echo "Running OpenMP version with 8 threads"
    OMP_NUM_THREADS=8 command time -v --output=small_mt_8_log_${i}.txt ../fm 0 50000
    OMP_NUM_THREADS=8 command time -v --output=medium_mt_8_log_${i}.txt ../fm 0 200000
    OMP_NUM_THREADS=8 command time -v --output=large_mt_8_log_${i}.txt ../fm 0 350000

    echo "Running OpenMP version with 16 threads"
    OMP_NUM_THREADS=16 command time -v --output=small_mt_16_log_${i}.txt ../fm 0 50000
    OMP_NUM_THREADS=16 command time -v --output=medium_mt_16_log_${i}.txt ../fm 0 200000
    OMP_NUM_THREADS=16 command time -v --output=large_mt_16_log_${i}.txt ../fm 0 350000
done;