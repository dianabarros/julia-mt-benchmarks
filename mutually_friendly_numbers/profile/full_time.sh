start_time=$(date +%s);
echo "Compiling...";
gcc ../friendly_sequencial_full_time.c -o fsft &&
gcc ../friendly_full_time.c -o fft -fopenmp && 

for i in {1..10}; do
    echo "Running sequential version"
    ./fsft 0 50000 >> full_time_logs/small_seq.txt
    ./fsft 0 200000 >> full_time_logs/medium_seq.txt
    ./fsft 0 350000 >> full_time_logs/large_seq.txt

    echo "Running OpenMP version with 2 threads"
    OMP_NUM_THREADS=2 ./fft 0 50000 >> full_time_logs/small_mt_2.txt
    OMP_NUM_THREADS=2 ./fft 0 200000 >> full_time_logs/medium_mt_2.txt
    OMP_NUM_THREADS=2 ./fft 0 350000 >> full_time_logs/large_mt_2.txt

    echo "Running OpenMP version with 4 threads"
    OMP_NUM_THREADS=4 ./fft 0 50000 >> full_time_logs/small_mt_4.txt
    OMP_NUM_THREADS=4 ./fft 0 200000 >> full_time_logs/medium_mt_4.txt
    OMP_NUM_THREADS=4 ./fft 0 350000 >> full_time_logs/large_mt_4.txt

    echo "Running OpenMP version with 8 threads"
    OMP_NUM_THREADS=8 ./fft 0 50000 >> full_time_logs/small_mt_8.txt
    OMP_NUM_THREADS=8 ./fft 0 200000 >> full_time_logs/medium_mt_8.txt
    OMP_NUM_THREADS=8 ./fft 0 350000 >> full_time_logs/large_mt_8.txt

    echo "Running OpenMP version with 16 threads"
    OMP_NUM_THREADS=16 ./fft 0 50000 >> full_time_logs/small_mt_16.txt
    OMP_NUM_THREADS=16 ./fft 0 200000 >> full_time_logs/medium_mt_16.txt
    OMP_NUM_THREADS=16 ./fft 0 350000 >> full_time_logs/large_mt_16.txt
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";