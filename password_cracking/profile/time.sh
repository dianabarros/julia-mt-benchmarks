echo "Compiling...";
gcc ../brute_force_password_cracking_seq_time.c -lssl -lcrypto -o bfst &&
gcc ../brute_force_password_cracking_time.c -lssl -lcrypto -o bft -fopenmp &&

for i in {1..10}; do
    echo "Running sequential version"
    ./bfst be5d75fa67ef370e98b3d3611c318156 >> time_logs/small_seq.txt
    ./bfst 9cbbf96d1973a60adebbb153f64b48f6  >> time_logs/medium_seq.txt
    ./bfst 34799a12a6ef24ef95a0f3179ac3c78d >> time_logs/large_seq.txt

    echo "Running OpenMP version with 2 threads"
    OMP_NUM_THREADS=2 ./bft be5d75fa67ef370e98b3d3611c318156 >> time_logs/small_mt_2.txt
    OMP_NUM_THREADS=2 ./bft 9cbbf96d1973a60adebbb153f64b48f6  >> time_logs/medium_mt_2.txt
    OMP_NUM_THREADS=2 ./bft 34799a12a6ef24ef95a0f3179ac3c78d >> time_logs/large_mt_2.txt

    echo "Running OpenMP version with 4 threads"
    OMP_NUM_THREADS=4 ./bft be5d75fa67ef370e98b3d3611c318156 >> time_logs/small_mt_4.txt
    OMP_NUM_THREADS=4 ./bft 9cbbf96d1973a60adebbb153f64b48f6  >> time_logs/medium_mt_4.txt
    OMP_NUM_THREADS=4 ./bft 34799a12a6ef24ef95a0f3179ac3c78d >> time_logs/large_mt_4.txt

    echo "Running OpenMP version with 8 threads"
    OMP_NUM_THREADS=8 ./bft be5d75fa67ef370e98b3d3611c318156 >> time_logs/small_mt_8.txt
    OMP_NUM_THREADS=8 ./bft 9cbbf96d1973a60adebbb153f64b48f6  >> time_logs/medium_mt_8.txt
    OMP_NUM_THREADS=8 ./bft 34799a12a6ef24ef95a0f3179ac3c78d >> time_logs/large_mt_8.txt

    echo "Running OpenMP version with 16 threads"
    OMP_NUM_THREADS=16 ./bft be5d75fa67ef370e98b3d3611c318156 >> time_logs/small_mt_16.txt
    OMP_NUM_THREADS=16 ./bft 9cbbf96d1973a60adebbb153f64b48f6  >> time_logs/medium_mt_16.txt
    OMP_NUM_THREADS=16 ./bft 34799a12a6ef24ef95a0f3179ac3c78d >> time_logs/large_mt_16.txt
done;