echo "Compiling...";
gcc ../transitive_closure_seq_time.c -o tcst &&
gcc ../transitive_closure_time.c -o tct &&

for i in {1..10}; do
    echo "Running sequential version"
    ./tcst < ../1280_nodes.in >> time_logs/small_seq.txt
    ./tcst < ../2560_nodes.in >> time_logs/medium_seq.txt
    ./tcst < ../transitive_closure.in >> time_logs/large_seq.txt

    echo "Running OpenMP version with 2 threads"
    OMP_NUM_THREADS=2 ./tct < ../1280_nodes.in >> time_logs/small_mt_2.txt
    OMP_NUM_THREADS=2 ./tct < ../2560_nodes.in >> time_logs/medium_mt_2.txt
    OMP_NUM_THREADS=2 ./tct < ../transitive_closure.in >> time_logs/large_mt_2.txt

    echo "Running OpenMP version with 4 threads"
    OMP_NUM_THREADS=4 ./tct < ../1280_nodes.in >> time_logs/small_mt_4.txt
    OMP_NUM_THREADS=4 ./tct < ../2560_nodes.in >> time_logs/medium_mt_4.txt
    OMP_NUM_THREADS=4 ./tct < ../transitive_closure.in >> time_logs/large_mt_4.txt

    echo "Running OpenMP version with 8 threads"
    OMP_NUM_THREADS=8 ./tct < ../1280_nodes.in >> time_logs/small_mt_8.txt
    OMP_NUM_THREADS=8 ./tct < ../2560_nodes.in >> time_logs/medium_mt_8.txt
    OMP_NUM_THREADS=8 ./tct < ../transitive_closure.in >> time_logs/large_mt_8.txt

    echo "Running OpenMP version with 16 threads"
    OMP_NUM_THREADS=16 ./tct < ../1280_nodes.in >> time_logs/small_mt_16.txt
    OMP_NUM_THREADS=16 ./tct < ../2560_nodes.in >> time_logs/medium_mt_16.txt
    OMP_NUM_THREADS=16 ./tct < ../transitive_closure.in >> time_logs/large_mt_16.txt
done;