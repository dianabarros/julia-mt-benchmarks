start_time=$(date +%s);
echo "Compiling...";
gcc ../friendly_sequencial_time.c -o fst &&
gcc ../friendly_time.c -o ft -fopenmp && 

for i in {1..10}; do
    echo "Running sequential version"
    ./fst 0 50000 >> time_logs/small_seq.txt
    ./fst 0 200000 >> time_logs/medium_seq.txt
    ./fst 0 350000 >> time_logs/large_seq.txt

    echo "Running OpenMP version with 2 threads"
    OMP_NUM_THREADS=2 ./ft 0 50000 >> time_logs/small_mt_2.txt
    OMP_NUM_THREADS=2 ./ft 0 200000 >> time_logs/medium_mt_2.txt
    OMP_NUM_THREADS=2 ./ft 0 350000 >> time_logs/large_mt_2.txt

    echo "Running OpenMP version with 4 threads"
    OMP_NUM_THREADS=4 ./ft 0 50000 >> time_logs/small_mt_4.txt
    OMP_NUM_THREADS=4 ./ft 0 200000 >> time_logs/medium_mt_4.txt
    OMP_NUM_THREADS=4 ./ft 0 350000 >> time_logs/large_mt_4.txt

    echo "Running OpenMP version with 8 threads"
    OMP_NUM_THREADS=8 ./ft 0 50000 >> time_logs/small_mt_8.txt
    OMP_NUM_THREADS=8 ./ft 0 200000 >> time_logs/medium_mt_8.txt
    OMP_NUM_THREADS=8 ./ft 0 350000 >> time_logs/large_mt_8.txt

    echo "Running OpenMP version with 16 threads"
    OMP_NUM_THREADS=16 ./ft 0 50000 >> time_logs/small_mt_16.txt
    OMP_NUM_THREADS=16 ./ft 0 200000 >> time_logs/medium_mt_16.txt
    OMP_NUM_THREADS=16 ./ft 0 350000 >> time_logs/large_mt_16.txt
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";