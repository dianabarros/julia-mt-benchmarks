using DataFrames, CSV, VegaLite

run_ = "run5"
app = "mutually_friendly"

julia_df = DataFrame(CSV.File("$(run_)/$(app)/julia/mt_seq_df.csv"))
c_df = DataFrame(CSV.File("$(run_)/$(app)/c/speedup_df.csv"))
c_df = rename(c_df, Dict(:func_openmp => :func, :n_threads_openmp => :n_threads, :time_mean_openmp => :time_mean))

large_julia_df = julia_df[julia_df.input .== "large", :]
large_c_df = c_df[c_df.input .== "large", :]

large_16_julia_df = large_julia_df[large_julia_df.n_threads .== 16, :]
large_16_julia_df = rename(large_16_julia_df, Dict(:func_mt=>:func, :main_loop_time_mean_mt=>:time_mean ))
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

# TODO: plot with julia and c speedups