start_time=$(date +%s);
julia instantiate.jl;
echo "Running Password Cracking with 4 threads.";
julia -t 4 password_cracking/benchmarks.jl --timed --inputs [6] --its 1;
end_time=$(date +%s);
elapsed=$(( end_time - start_time ));
eval "echo Elapsed time: $(date -ud "@$elapsed" +'$((%s/3600/24)) days %H hr %M min %S sec')";