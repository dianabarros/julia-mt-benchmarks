echo "Compiling...";
gcc ../transitive_closure_seq_full_time.c -o tcsft &&
gcc ../transitive_closure_full_time.c -o tcft -fopenmp &&

for i in {1..10}; do
    echo "Running sequential version"
    ./tcsft < ../1280_nodes.in >> full_time_logs/small_seq.txt
    ./tcsft < ../2560_nodes.in >> full_time_logs/medium_seq.txt
    ./tcsft < ../transitive_closure.in >> full_time_logs/large_seq.txt

    echo "Running OpenMP version with 2 threads"
    OMP_NUM_THREADS=2 ./tcft < ../1280_nodes.in >> full_time_logs/small_mt_2.txt
    OMP_NUM_THREADS=2 ./tcft < ../2560_nodes.in >> full_time_logs/medium_mt_2.txt
    OMP_NUM_THREADS=2 ./tcft < ../transitive_closure.in >> full_time_logs/large_mt_2.txt

    echo "Running OpenMP version with 4 threads"
    OMP_NUM_THREADS=4 ./tcft < ../1280_nodes.in >> full_time_logs/small_mt_4.txt
    OMP_NUM_THREADS=4 ./tcft < ../2560_nodes.in >> full_time_logs/medium_mt_4.txt
    OMP_NUM_THREADS=4 ./tcft < ../transitive_closure.in >> full_time_logs/large_mt_4.txt

    echo "Running OpenMP version with 8 threads"
    OMP_NUM_THREADS=8 ./tcft < ../1280_nodes.in >> full_time_logs/small_mt_8.txt
    OMP_NUM_THREADS=8 ./tcft < ../2560_nodes.in >> full_time_logs/medium_mt_8.txt
    OMP_NUM_THREADS=8 ./tcft < ../transitive_closure.in >> full_time_logs/large_mt_8.txt

    echo "Running OpenMP version with 16 threads"
    OMP_NUM_THREADS=16 ./tcft < ../1280_nodes.in >> full_time_logs/small_mt_16.txt
    OMP_NUM_THREADS=16 ./tcft < ../2560_nodes.in >> full_time_logs/medium_mt_16.txt
    OMP_NUM_THREADS=16 ./tcft < ../transitive_closure.in >> full_time_logs/large_mt_16.txt
done;