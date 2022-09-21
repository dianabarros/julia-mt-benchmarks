gcc ../friendly_sequencial_time.c -o fst;
gcc ../friendly_time.c -o ft -fopenmp;

for i in {1..10}; do
    echo "Running sequential version"
    ../fsm 0 50000 >> time_logs/small_seq.txt
    ../fsm 0 200000 >> time_logs/medium_seq.txt
    ../fsm 0 350000 >> time_logs/large_seq.txt

    echo "Running OpenMP version with 2 threads"
    OMP_NUM_THREADS=2 ../fm 0 50000 >> time_logs/small_mt_2.txt
    OMP_NUM_THREADS=2 ../fm 0 200000 >> time_logs/medium_mt_2.txt
    OMP_NUM_THREADS=2 ../fm 0 350000 >> time_logs/large_mt_2.txt

    echo "Running OpenMP version with 4 threads"
    OMP_NUM_THREADS=4 ../fm 0 50000 >> time_logs/small_mt_4.txt
    OMP_NUM_THREADS=4 ../fm 0 200000 >> time_logs/medium_mt_4.txt
    OMP_NUM_THREADS=4 ../fm 0 350000 >> time_logs/large_mt_4.txt

    echo "Running OpenMP version with 8 threads"
    OMP_NUM_THREADS=8 ../fm 0 50000 >> time_logs/small_mt_8.txt
    OMP_NUM_THREADS=8 ../fm 0 200000 >> time_logs/medium_mt_8.txt
    OMP_NUM_THREADS=8 ../fm 0 350000 >> time_logs/large_mt_8.txt

    echo "Running OpenMP version with 16 threads"
    OMP_NUM_THREADS=16 ../fm 0 50000 >> time_logs/small_mt_16.txt
    OMP_NUM_THREADS=16 ../fm 0 200000 >> time_logs/medium_mt_16.txt
    OMP_NUM_THREADS=16 ../fm 0 350000 >> time_logs/large_mt_16.txt
done;