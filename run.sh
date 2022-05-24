for i in 2 4 8 16; do
    echo "Running Mutual Friendly Numbers with $i threads.";
    julia -t $i mutually_friendly_number/benchmarks.jl
done;
for i in 2 4 8 16; do
    echo "Running Password Cracking with $i threads.";
    julia -t $i password_cracking/benchmarks.jl
done;