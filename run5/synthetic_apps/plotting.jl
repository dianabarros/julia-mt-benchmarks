using DataFrames, CSV, VegaLite, Statistics

run_ = "run5"
app = "synthetic_apps"

df = DataFrame(CSV.File("$(run_)/$(app)/$(app)_1.csv"))
i = 2
while i <= 16
    temp = DataFrame(CSV.File("$(run_)/$(app)/$(app)_$(i).csv"))
    df = vcat(df,temp)
    i = i*2
end

gb = groupby(df, [:func, :input, :n_threads])
df = combine(gb, 
    [:main_loop_time, :imbalance] .=>  mean, [:main_loop_time, :imbalance] .=> std)

seq_df = vcat(df[df.func .== "balanced", :], df[df.func .== "unbalanced", :])
parallel_df = vcat(
    df[df.func .== "balanced_mt", :], df[df.func .== "balanced_spawn", :],
    df[df.func .== "unbalanced_mt", :], df[df.func .== "unbalanced_spawn", :]
)

parallel_seq_df = innerjoin(parallel_df, seq_df, on=[:input], renamecols= "_parallel" => "_seq")
parallel_seq_df = hcat(parallel_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(parallel_seq_df,1))))

speedup_df = select(parallel_seq_df, :, [:main_loop_time_mean_parallel, :main_loop_time_mean_seq] => ((main_loop_time_mean_parallel, main_loop_time_mean_seq) -> (main_loop_time_mean_seq./main_loop_time_mean_parallel)) => :speedup)

# TODO: change size?
speedup_plot = speedup_df |>
    @vlplot(
        mark={:bar, clip=true},
        x={"n_threads_parallel:n", axis={title="Number of threads"}},
        y={:speedup, axis={title="Speedup"}},
        color={:func_parallel, axis={title="Macros"}},
        column={:func_parallel, axis={title=nothing}},
        row={:input, axis={title="Input size"}}
    )
speedup_plot |> save("$(run_)/$(app)/speedup_plot.png")

imbalance_plot = parallel_df |>
    @vlplot(
        mark={:line, clip=true},
        x={"n_threads:q", axis={title="Number of threads"}},
        y={:imbalance_mean, axis={title="Imbalance (λ)"}},
        color={:func, axis={title="Macro"}},
        column={:input, axis={title="Input size"}}
        )
imbalance_plot |> save("$(run_)/$(app)/imbalance_plot.png")