start_time=$(date +%s);
echo "Compiling...";
gcc ../brute_force_password_cracking_seq.c -lssl -lcrypto -o bfsm &&
gcc ../brute_force_password_cracking.c -lssl -lcrypto -o bfm -fopenmp &&

for i in {1..10}; do
    echo "Running sequential version"
    command time -v --output=mem_logs/small_seq_log_${i}.txt ./bfsm be5d75fa67ef370e98b3d3611c318156 
    command time -v --output=mem_logs/medium_seq_log_${i}.txt ./bfsm 9cbbf96d1973a60adebbb153f64b48f6
    command time -v --output=mem_logs/large_seq_log_${i}.txt ./bfsm 34799a12a6ef24ef95a0f3179ac3c78d

    echo "Running OpenMP version with 2 threads"
    OMP_NUM_THREADS=2 command time -v --output=mem_logs/small_mt_2_log_${i}.txt ./bfm be5d75fa67ef370e98b3d3611c318156
    OMP_NUM_THREADS=2 command time -v --output=mem_logs/medium_mt_2_log_${i}.txt ./bfm 9cbbf96d1973a60adebbb153f64b48f6
    OMP_NUM_THREADS=2 command time -v --output=mem_logs/large_mt_2_log_${i}.txt ./bfm 34799a12a6ef24ef95a0f3179ac3c78d

    echo "Running OpenMP version with 4 threads"
    OMP_NUM_THREADS=4 command time -v --output=mem_logs/small_mt_4_log_${i}.txt ./bfm be5d75fa67ef370e98b3d3611c318156
    OMP_NUM_THREADS=4 command time -v --output=mem_logs/medium_mt_4_log_${i}.txt ./bfm 9cbbf96d1973a60adebbb153f64b48f6
    OMP_NUM_THREADS=4 command time -v --output=mem_logs/large_mt_4_log_${i}.txt ./bfm 34799a12a6ef24ef95a0f3179ac3c78d

    echo "Running OpenMP version with 8 threads"
    OMP_NUM_THREADS=8 command time -v --output=mem_logs/small_mt_8_log_${i}.txt ./bfm be5d75fa67ef370e98b3d3611c318156
    OMP_NUM_THREADS=8 command time -v --output=mem_logs/medium_mt_8_log_${i}.txt ./bfm 9cbbf96d1973a60adebbb153f64b48f6
    OMP_NUM_THREADS=8 command time -v --output=mem_logs/large_mt_8_log_${i}.txt ./bfm 34799a12a6ef24ef95a0f3179ac3c78d

    echo "Running OpenMP version with 16 threads"
    OMP_NUM_THREADS=16 command time -v --output=mem_logs/small_mt_16_log_${i}.txt ./bfm be5d75fa67ef370e98b3d3611c318156
    OMP_NUM_THREADS=16 command time -v --output=mem_logs/medium_mt_16_log_${i}.txt ./bfm 9cbbf96d1973a60adebbb153f64b48f6
    OMP_NUM_THREADS=16 command time -v --output=mem_logs/large_mt_16_log_${i}.txt ./bfm 34799a12a6ef24ef95a0f3179ac3c78d
done;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";