start_time=$(date +%s);
echo "Compiling...";
gcc ../brute_force_password_cracking_seq_full_time.c -lssl -lcrypto -o bfsft &&
gcc ../brute_force_password_cracking_full_time.c -lssl -lcrypto -o bfft -fopenmp &&

for i in {1..10}; do
    echo "Running sequential version"
    ./bfsft be5d75fa67ef370e98b3d3611c318156 >> full_time_logs/small_seq.txt
    ./bfsft 9cbbf96d1973a60adebbb153f64b48f6  >> full_time_logs/medium_seq.txt
    ./bfsft 34799a12a6ef24ef95a0f3179ac3c78d >> full_time_logs/large_seq.txt

    echo "Running OpenMP version with 2 threads"
    OMP_NUM_THREADS=2 ./bfft be5d75fa67ef370e98b3d3611c318156 >> full_time_logs/small_mt_2.txt
    OMP_NUM_THREADS=2 ./bfft 9cbbf96d1973a60adebbb153f64b48f6  >> full_time_logs/medium_mt_2.txt
    OMP_NUM_THREADS=2 ./bfft 34799a12a6ef24ef95a0f3179ac3c78d >> full_time_logs/large_mt_2.txt

    echo "Running OpenMP version with 4 threads"
    OMP_NUM_THREADS=4 ./bfft be5d75fa67ef370e98b3d3611c318156 >> full_time_logs/small_mt_4.txt
    OMP_NUM_THREADS=4 ./bfft 9cbbf96d1973a60adebbb153f64b48f6  >> full_time_logs/medium_mt_4.txt
    OMP_NUM_THREADS=4 ./bfft 34799a12a6ef24ef95a0f3179ac3c78d >> full_time_logs/large_mt_4.txt

    echo "Running OpenMP version with 8 threads"
    OMP_NUM_THREADS=8 ./bfft be5d75fa67ef370e98b3d3611c318156 >> full_time_logs/small_mt_8.txt
    OMP_NUM_THREADS=8 ./bfft 9cbbf96d1973a60adebbb153f64b48f6  >> full_time_logs/medium_mt_8.txt
    OMP_NUM_THREADS=8 ./bfft 34799a12a6ef24ef95a0f3179ac3c78d >> full_time_logs/large_mt_8.txt

    echo "Running OpenMP version with 16 threads"
    OMP_NUM_THREADS=16 ./bfft be5d75fa67ef370e98b3d3611c318156 >> full_time_logs/small_mt_16.txt
    OMP_NUM_THREADS=16 ./bfft 9cbbf96d1973a60adebbb153f64b48f6  >> full_time_logs/medium_mt_16.txt
    OMP_NUM_THREADS=16 ./bfft 34799a12a6ef24ef95a0f3179ac3c78d >> full_time_logs/large_mt_16.txt
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";