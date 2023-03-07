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
df[:,:func] = [macros[val] for val in df.func]

seq_df = vcat(df[df.func .== macros["balanced"], :], df[df.func .== macros["unbalanced"], :])
parallel_df = vcat(
    df[df.func .== macros["balanced_mt"], :], df[df.func .== macros["balanced_spawn"], :],
    df[df.func .== macros["unbalanced_mt"], :], df[df.func .== macros["unbalanced_spawn"], :]
)

parallel_seq_df = innerjoin(parallel_df, seq_df, on=[:input], renamecols= "_parallel" => "_seq")
parallel_seq_df = hcat(parallel_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(parallel_seq_df,1))))

speedup_df = select(parallel_seq_df, :, [:main_loop_time_mean_parallel, :main_loop_time_mean_seq] => ((main_loop_time_mean_parallel, main_loop_time_mean_seq) -> (main_loop_time_mean_seq./main_loop_time_mean_parallel)) => :speedup)

# TODO: change size?
speedup_plot = speedup_df |>
    @vlplot(
        mark={:bar, clip=true},
        x={"n_threads_parallel:n", axis={title=nothing}},
        y={:speedup, axis={title="Speedup"}},
        color={:func_parallel, axis={title="App - Macro"}},
        column={
            :func_parallel, 
            header={title="Number of Threads", labels=false, titleOrient=:bottom},
        },
        row={
            "input:n", 
            axis={title="Input size"},
            sort={field=:input,order=:descending}
        },
        width=100
    )
speedup_plot |> save("$(run_)/$(app)/speedup_plot_v2.png")

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