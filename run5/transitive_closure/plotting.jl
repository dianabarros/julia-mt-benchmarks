using DataFrames, CSV, VegaLite

run_ = "run5"
app = "transitive_closure"

julia_df = DataFrame(CSV.File("$(run_)/$(app)/julia/mt_seq_df.csv"))
julia_df = rename(julia_df, Dict(:func_mt=>:func, :total_time_mean_mt=>:time_mean ))
c_df = DataFrame(CSV.File("$(run_)/$(app)/c/speedup_df.csv"))
c_df = rename(c_df, Dict(:func_openmp => :func, :n_threads_openmp => :n_threads, :time_mean_openmp => :time_mean))

# TIME COMPARISON: LARGE 16 THREADS
large_julia_df = julia_df[julia_df.input .== "large", :]
large_c_df = c_df[c_df.input .== "large", :]

large_16_julia_df = large_julia_df[large_julia_df.n_threads .== 16, :]
large_16_c_df = large_c_df[large_c_df.n_threads .== 16, :]
large_16_c_df[!,:time_mean] .= large_16_c_df[!,:time_mean]/1000000

large_16_c_julia_df = vcat(large_16_c_df[!,[:func,:time_mean]], large_16_julia_df[!,[:func,:time_mean]])

# NOTE: close results, hard to distinguish, confirm if should be presented
large_16_c_julia_plot = large_16_c_julia_df |>
    @vlplot(
        mark={:bar, clip=true},
        x=:func,
        y={:time_mean},
        color=:func
    )

large_16_c_julia_plot |> save("$(run_)/$(app)/time_comparison_plot.png")

# SPEEDUP COMPARISON THREADEDEX
floop_df = julia_df[julia_df.func .== "debug_warshall_floops!", :] 
executor_df = floop_df[floop_df.executor_mt .== "DepthFirstEx", :]
threads_df = julia_df[julia_df.func .== "debug_warshall_threads!", :]

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

# NOTE: C had better speedup for every input size and with any number of threads
# TODO: evaluate the scheduling in C