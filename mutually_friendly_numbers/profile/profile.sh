for i in {1..10}; do
    command time -v ../fsm 0 50000 > small_seq_log_${i}.txt
    # command time -v ../fsm 0 200000 > medium_seq_log_${i}.txt
    # command time -v ../fsm 0 350000 > large_seq_log_${i}.txt

    command time -v OMP_NUM_THREADS=2 ../fm 0 50000 > small_mt_2_log_${i}.txt
    # command time -v OMP_NUM_THREADS=2 ../fm 0 200000 > medium_mt_2_log_${i}.txt
    # command time -v OMP_NUM_THREADS=2 ../fm 0 350000 > large_mt_2_log_${i}.txt

    command time -v OMP_NUM_THREADS=4 ../fm 0 50000 > small_mt_4_log_${i}.txt
    command time -v OMP_NUM_THREADS=4 ../fm 0 200000 > medium_mt_4_log_${i}.txt
    command time -v OMP_NUM_THREADS=4 ../fm 0 350000 > large_mt_4_log_${i}.txt

    command time -v OMP_NUM_THREADS=8 ../fm 0 50000 > small_mt_8_log_${i}.txt
    command time -v OMP_NUM_THREADS=8 ../fm 0 200000 > medium_mt_8_log_${i}.txt
    command time -v OMP_NUM_THREADS=8 ../fm 0 350000 > large_mt_8_log_${i}.txt

    command time -v OMP_NUM_THREADS=16 ../fm 0 50000 > small_mt_16_log_${i}.txt
    command time -v OMP_NUM_THREADS=16 ../fm 0 200000 > medium_mt_16_log_${i}.txt
    command time -v OMP_NUM_THREADS=16 ../fm 0 350000 > large_mt_16_log_${i}.txt
done;