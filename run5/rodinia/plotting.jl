using DataFrames, CSV, VegaLite, Statistics

run_ = "run5"
app = "rodinia"

df = vcat(
    DataFrame(CSV.File("$(run_)/$(app)/bfs_2.csv"))[:,[:func,:input,:n_threads,:main_loop_time,:imbalance]],
    DataFrame(CSV.File("$(run_)/$(app)/lud_2.csv"))[:,[:func,:input,:n_threads,:main_loop_time,:imbalance]]
)
srad_df = DataFrame(CSV.File("$(run_)/$(app)/srad_2.csv"))
i = 4
while i <= 16
    for func in ["bfs", "lud"]
        temp = DataFrame(CSV.File("$(run_)/$(app)/$(func)_$(i).csv"))[:,[:func,:input,:n_threads,:main_loop_time,:imbalance]]
        df = vcat(df,temp)
    end
    temp = DataFrame(CSV.File("$(run_)/$(app)/srad_$(i).csv"))
    srad_df = vcat(srad_df, temp)
    i = i*2
end


srad_gb = groupby(srad_df, [:func, :input, :n_threads])
srad_df = combine(srad_gb, 
    [:main_loop_time, :loop_1_imbalance, :loop_2_imbalance] .=>  mean, [:main_loop_time, :loop_1_imbalance, :loop_2_imbalance] .=> std)
# NOTE: ratio shows that the imbalance on loop1 is higher than loop 2, so we will analyse that one
srad_df[:, :loop_imbalance_ratio] = srad_df.loop_1_imbalance_mean./srad_df.loop_2_imbalance_mean
srad_df = srad_df[:,[:func,:input,:n_threads,:main_loop_time_mean, :main_loop_time_std,:loop_1_imbalance_mean,:loop_1_imbalance_std]]
srad_df = rename(srad_df, Dict(:loop_1_imbalance_mean => :imbalance_mean, :loop_1_imbalance_std => :imbalance_std))

gb = groupby(df, [:func, :input, :n_threads])
df = combine(gb, 
    [:main_loop_time, :imbalance] .=>  mean, [:main_loop_time, :imbalance] .=> std)

df = vcat(df, srad_df)
bench_names = Dict(
    "debug_bfs_spawn" => "bfs", "debug_bfs_threads" => "bfs", "debug_bfs" => "bfs",
    "debug_srad_spawn" => "srad", "debug_srad_threads" => "srad", "debug_srad" => "srad",
    "debug_lud_spawn" => "lud", "debug_lud_threads" => "lud", "debug_lud" => "lud"
)
df[:,"bench_name"] = [bench_names[value] for value in df.func]

seq_df = vcat(df[df.func .== "debug_bfs",:], df[df.func .== "debug_lud",:], df[df.func .== "debug_srad",:])
parallel_df = vcat(
    df[df.func .== "debug_bfs_threads", :], df[df.func .== "debug_bfs_spawn", :],
    df[df.func .== "debug_lud_threads", :], df[df.func .== "debug_lud_spawn", :],
    df[df.func .== "debug_srad_threads", :], df[df.func .== "debug_srad_spawn", :]
)

parallel_seq_df = innerjoin(parallel_df, seq_df, on=[:bench_name,:input, :n_threads], renamecols= "_parallel" => "_seq")
parallel_seq_df = hcat(parallel_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(parallel_seq_df,1))))

speedup_df = select(parallel_seq_df, :, [:main_loop_time_mean_parallel, :main_loop_time_mean_seq] => ((main_loop_time_mean_parallel, main_loop_time_mean_seq) -> (main_loop_time_mean_seq./main_loop_time_mean_parallel)) => :speedup)

bfs_speedup_plot = speedup_df[speedup_df.bench_name .== "bfs",:] |>
    @vlplot(
        title={text="BFS Speedup",anchor=:middle},
        mark={:line, clip=true},
        x={"n_threads:q", axis={title="Number of threads"}},
        y={:speedup, axis={title="Speedup"}},
        color={:func_parallel, axis={title="Macros"}},
        row={:input, axis={title="Input size"}}
    )

bfs_time_plot = speedup_df[speedup_df.bench_name .== "bfs",:] |>
    @vlplot(
        title={text="BFS Execution Time",anchor=:middle},
        mark={:bar, clip=true},
        x={"func_parallel:n", axis={title="Macro"}},
        y={:main_loop_time_mean_parallel, axis={title="Execution Time (s)"}},
        color={:func_parallel, axis={title="Macro"}},
        column={:input, axis={title="Input Size"}},
        row={:n_threads, axis={title="Number of threads"}}
    )

lud_speedup_plot = speedup_df[speedup_df.bench_name .== "lud",:] |>
    @vlplot(
        title={text="LUD Speedup",anchor=:middle},
        mark={:line, clip=true},
        x={"n_threads:q", axis={title="Number of threads"}},
        y={:speedup, axis={title="Speedup"}},
        color={:func_parallel, axis={title="Macros"}},
        row={:input, axis={title="Input size"}}
    )

lud_time_plot = speedup_df[speedup_df.bench_name .== "lud",:] |>
    @vlplot(
        title={text="LUD Execution Time",anchor=:middle},
        mark={:bar, clip=true},
        x={"func_parallel:n", axis={title="Macro"}},
        y={:main_loop_time_mean_parallel, axis={title="Execution Time (s)"}},
        color={:func_parallel, axis={title="Macro"}},
        column={:input, axis={title="Input Size"}},
        row={:n_threads, axis={title="Number of threads"}}
    )

srad_speedup_plot = speedup_df[speedup_df.bench_name .== "srad",:] |>
    @vlplot(
        title={text="SRAD_V2 Speedup",anchor=:middle},
        mark={:line, clip=true},
        x={"n_threads:q", axis={title="Number of threads"}},
        y={:speedup, axis={title="Speedup"}},
        color={:func_parallel, axis={title="Macros"}},
        row={:input, axis={title="Input size"}}
    )

srad_time_plot = speedup_df[speedup_df.bench_name .== "srad",:] |>
    @vlplot(
        title={text="SRAD_V2 Execution Time",anchor=:middle},
        mark={:bar, clip=true},
        x={"func_parallel:n", axis={title="Macro"}},
        y={:main_loop_time_mean_parallel, axis={title="Execution Time (s)"}},
        color={:func_parallel, axis={title="Macro"}},
        column={:input, axis={title="Input Size"}},
        row={:n_threads, axis={title="Number of threads"}}
    )

bfs_imbalance_plot = speedup_df[speedup_df.bench_name .== "bfs",:] |>
    @vlplot(
        title={text="BFS Imbalance",anchor=:middle},
        mark={:bar, clip=true},
        x={"func_parallel:n", axis={title="Macro"}},
        y={:imbalance_mean_parallel, axis={title="Imbalance (λ) "}},
        color={:func_parallel, axis={title="Macro"}},
        column={:input, axis={title="Input size"}},
        row={:n_threads, axis={title="Number of Threads"}}
    )
    

lud_imbalance_plot = speedup_df[speedup_df.bench_name .== "lud",:] |>
    @vlplot(
        title={text="LUD Imbalance",anchor=:middle},
        mark={:bar, clip=true},
        x={"func_parallel:n", axis={title="Macro"}},
        y={:imbalance_mean_parallel, axis={title="Imbalance (λ) "}},
        color={:func_parallel, axis={title="Macro"}},
        column={:input, axis={title="Input size"}},
        row={:n_threads, axis={title="Number of Threads"}}
    )

srad_imbalance_plot = speedup_df[speedup_df.bench_name .== "srad",:] |>
    @vlplot(
        title={text="SRAD_V2 Imbalance",anchor=:middle},
        mark={:bar, clip=true},
        x={"func_parallel:n", axis={title="Macro"}},
        y={:imbalance_mean_parallel, axis={title="Imbalance (λ) "}},
        color={:func_parallel, axis={title="Macro"}},
        column={:input, axis={title="Input size"}},
        row={:n_threads, axis={title="Number of Threads"}}
    )