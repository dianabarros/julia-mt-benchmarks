using DataFrames, CSV, VegaLite

run_ = "run5"
app = "password_cracking"

julia_df = DataFrame(CSV.File("$(run_)/$(app)/julia/mt_seq_df.csv"))
julia_df = rename(julia_df, Dict(:func_mt=>:func, :main_loop_time_mean_mt=>:time_mean ))
c_df = DataFrame(CSV.File("$(run_)/$(app)/c/speedup_df.csv"))
c_df = rename(c_df, Dict(:func_openmp => :func, :n_threads_openmp => :n_threads, :time_mean_openmp => :time_mean))

# TIME COMPARISON: LARGE(6) 16 THREADS
large_julia_df = julia_df[julia_df.input .== "large", :]
large_c_df = c_df[c_df.input .== "large", :]

large_16_julia_df = large_julia_df[large_julia_df.n_threads .== 16, :]
large_16_c_df = large_c_df[large_c_df.n_threads .== 16, :]
large_16_c_df[!,:time_mean] .= large_16_c_df[!,:time_mean]/1000000

large_16_c_julia_df = vcat(large_16_c_df[!,[:func,:time_mean]], large_16_julia_df[!,[:func,:time_mean]])

# NOTE: big difference in time to C
large_16_c_julia_plot = large_16_c_julia_df |>
    @vlplot(
        mark={:bar, clip=true},
        x=:func,
        y={:time_mean},
        color=:func
    )

large_16_c_julia_plot |> save("$(run_)/$(app)/time_comparison_plot.png")

# SPEEDUP COMPARISON THREADEDEX
floop_df = julia_df[julia_df.func .== "debug_brute_force_floop", :] 
executor_df = floop_df[floop_df.executor_mt .== "DepthFirstEx", :]
threads_df = julia_df[julia_df.func .== "debug_brute_force_threads", :]

executor_df.func .= "Julia - Floops (DepthFirstEx)"
threads_df.func .= "Julia - @threads"

julia_speedup_df = vcat(executor_df,threads_df)

c_df.func .= "C - OpenMP"

speedup_df = vcat(
    julia_speedup_df[:,[:func, :input, :n_threads, :speedup]],
    c_df[:,[:func, :input, :n_threads, :speedup]]
)

speedup_plot = speedup_df |>
    @vlplot(
        mark={:bar, clip=true},
        x=:func,
        y={:speedup},
        color=:func,
        column="n_threads:n",
        row=:input
    )

speedup_plot |> save("$(run_)/$(app)/speedup_plot.png")

# NOTE: 
#  - small: Julia speedup is better than C, best one with Floops DepthFirstEx, except with 
#   8 threads where OpenMP has better speedup
#  - medium: Julia speedup is better than C, best one varies (Floops or @threads)
#  - large: Julia speedup is better for 2 and 4 threads. C speedup is better with 8 and 16 
#   thereds where with 16 threds C speedup is 4times better than Julia speedup
# TODO: check values for C large with 16 threads to confirm the big difference in results
# TODO: evaluate the scheduling in C