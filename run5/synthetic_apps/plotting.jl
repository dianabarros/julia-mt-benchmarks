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

input_sizes = Dict(
    "small" => "Small", "medium" => "Medium", "large" => "Large"
)
macros = Dict(
    "balanced"  => "Balanced",
    "unbalanced"  => "Unbalanced",
    "balanced_mt" => "Balanced - @threads",
    "balanced_spawn" => "Balanced - @spawn",
    "unbalanced_mt" => "Unbalanced - @threads",
    "unbalanced_spawn" => "Unbalanced - @spawn"
)

df[:,:input] = [input_sizes[val] for val in df.input]

balanced_seq_df = df[df.func .== "balanced", :]
unbalanced_seq_df = df[df.func .== "unbalanced", :]
balanced_parallel_df = vcat(df[df.func .== "balanced_mt", :], df[df.func .== "balanced_spawn", :])
unbalanced_parallel_df = vcat(df[df.func .== "unbalanced_mt", :], df[df.func .== "unbalanced_spawn", :])

balanced_parallel_seq_df = innerjoin(balanced_parallel_df, balanced_seq_df, on=[:input], renamecols= "_parallel" => "_seq")
balanced_parallel_seq_df = hcat(balanced_parallel_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(balanced_parallel_seq_df,1))))
balanced_speedup = select(balanced_parallel_seq_df, :, [:main_loop_time_mean_parallel, :main_loop_time_mean_seq] => ((main_loop_time_mean_parallel, main_loop_time_mean_seq) -> (main_loop_time_mean_seq./main_loop_time_mean_parallel)) => :speedup)

unbalanced_parallel_seq_df = innerjoin(unbalanced_parallel_df, unbalanced_seq_df, on=[:input], renamecols= "_parallel" => "_seq")
unbalanced_parallel_seq_df = hcat(unbalanced_parallel_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(unbalanced_parallel_seq_df,1))))
unbalanced_speedup = select(unbalanced_parallel_seq_df, :, [:main_loop_time_mean_parallel, :main_loop_time_mean_seq] => ((main_loop_time_mean_parallel, main_loop_time_mean_seq) -> (main_loop_time_mean_seq./main_loop_time_mean_parallel)) => :speedup)

speedup_df = vcat(balanced_speedup, unbalanced_speedup)
speedup_df[:,:func_parallel] = [macros[val] for val in speedup_df.func_parallel]

speedup_plot = speedup_df |>
    @vlplot(
        mark={:line, clip=true},
        x={"n_threads_parallel:n", axis={title=nothing}},
        y={:speedup, axis={title="Speedup"}},
        color={:func_parallel, axis={title="App - Macro"}},
        column={
            :input, axis={title="Input size"},
            sort={field=:input,order=:descending} 
        },
        # row={
        #     "input:n", 
        #     axis={title="Input size"},
        #     sort={field=:input,order=:descending}
        # },
        width=165
    )
speedup_plot |> save("$(run_)/$(app)/speedup_plot_v2.png")

parallel_df = vcat(balanced_parallel_df, unbalanced_parallel_df)
parallel_df[:,:func] = [macros[val] for val in parallel_df.func]

imbalance_plot = parallel_df |>
    @vlplot(
        mark={:line, clip=true},
        x={"n_threads:q", axis={title="Number of Threads"}},
        y={:imbalance_mean, axis={title="λ (%)"}},
        color={:func, axis={title="App - Macro"}},
        column={
            "input:n", 
            axis={title="Input size"},
            sort=["Small", "Medium, Large"]
        }
    )
imbalance_plot |> save("$(run_)/$(app)/imbalance_plot.png")