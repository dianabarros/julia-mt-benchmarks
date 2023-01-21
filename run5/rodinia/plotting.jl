using DataFrames, CSV, VegaLite, Statistics

run_ = "run5"
app = "rodinia"


bfs_df = select!(DataFrame(CSV.File("$(run_)/$(app)/bfs_2.csv")), Not(:iteration))
lud_df = select!(DataFrame(CSV.File("$(run_)/$(app)/lud_2.csv")), Not(:iteration))
srad_df = select!(DataFrame(CSV.File("$(run_)/$(app)/srad_2.csv")), Not(:iteration))
i = 4
while i <= 16
    temp = select!(DataFrame(CSV.File("$(run_)/$(app)/bfs_$(i).csv")), Not(:iteration))
    bfs_df = vcat(bfs_df, temp)
    temp = select!(DataFrame(CSV.File("$(run_)/$(app)/lud_$(i).csv")), Not(:iteration))
    lud_df = vcat(lud_df, temp)
    temp = select!(DataFrame(CSV.File("$(run_)/$(app)/srad_$(i).csv")), Not(:iteration))
    srad_df = vcat(srad_df, temp)
    i = i * 2
end

bfs_gb = groupby(bfs_df, [:func, :input, :n_threads])
bfs_df = combine(bfs_gb,
    [:main_loop_time, :loop_1_mean_time, :imbalance] .=> mean, [:main_loop_time, :loop_1_mean_time, :imbalance] .=> std)

lud_gb = groupby(lud_df, [:func, :input, :n_threads])
lud_df = combine(lud_gb,
    [:main_loop_time, :loop_1_mean_time, :loop_2_mean_time, :imbalance, :loop_1_imbalance, :loop_2_imbalance] .=> mean, [:main_loop_time, :loop_1_mean_time, :loop_2_mean_time, :imbalance, :loop_1_imbalance, :loop_2_imbalance] .=> std)
# NOTE: determines that loop 1 mean time is higher than loop 2
lud_df[:, "loop_time_ratio"] = lud_df.loop_1_mean_time_mean ./ lud_df.loop_2_mean_time_mean

srad_gb = groupby(srad_df, [:func, :input, :n_threads])
srad_df = combine(srad_gb,
    [:main_loop_time, :loop_1_imbalance, :loop_2_imbalance] .=> mean, [:main_loop_time, :loop_1_imbalance, :loop_2_imbalance] .=> std)
# NOTE: ratio shows that the imbalance on loop1 is higher than loop 2, so we will analyse that one
srad_df[:, :loop_imbalance_ratio] = srad_df.loop_1_imbalance_mean ./ srad_df.loop_2_imbalance_mean
srad_df = srad_df[:, [:func, :input, :n_threads, :main_loop_time_mean, :main_loop_time_std, :loop_1_imbalance_mean, :loop_1_imbalance_std]]
srad_df = rename(srad_df, Dict(:loop_1_imbalance_mean => :imbalance_mean, :loop_1_imbalance_std => :imbalance_std))

bench_names = Dict(
    "debug_bfs_spawn" => "BFS - @spawn", "debug_bfs_threads" => "BFS - @threads", "debug_bfs" => "BFS - sequential",
    "debug_srad_spawn" => "SRAD_V2 - @spawn", "debug_srad_threads" => "SRAD_V2 - @threads", "debug_srad" => "SRAD_V2 - sequential",
    "debug_lud_spawn" => "LUD - @spawn", "debug_lud_threads" => "LUD - @threads", "debug_lud" => "LUD - sequential"
)
bfs_df[:, "func"] = [bench_names[value] for value in bfs_df.func]
lud_df[:, "func"] = [bench_names[value] for value in lud_df.func]
srad_df[:, "func"] = [bench_names[value] for value in srad_df.func]

seq_bfs_df = bfs_df[bfs_df.func.=="BFS - sequential", :]
seq_lud_df = lud_df[lud_df.func.=="LUD - sequential", :]
seq_srad_df = srad_df[srad_df.func.=="SRAD_V2 - sequential", :]
parallel_bfs_df = vcat(
    bfs_df[bfs_df.func.=="BFS - @threads", :], bfs_df[bfs_df.func.=="BFS - @spawn", :]
)
parallel_lud_df = vcat(
    lud_df[lud_df.func.=="LUD - @threads", :], lud_df[lud_df.func.=="LUD - @spawn", :]
)
parallel_srad_df = vcat(
    srad_df[srad_df.func.=="SRAD_V2 - @threads", :], srad_df[srad_df.func.=="SRAD_V2 - @spawn", :]
)

bfs_parallel_seq_df = innerjoin(parallel_bfs_df, seq_bfs_df, on=[:input, :n_threads], renamecols="_parallel" => "_seq")
bfs_parallel_seq_df = hcat(bfs_parallel_seq_df, DataFrame(speedup=Vector{Union{Missing,Float64}}(missing, size(bfs_parallel_seq_df, 1))))
bfs_parallel_seq_df = hcat(bfs_parallel_seq_df, DataFrame(loop_1_speedup=Vector{Union{Missing,Float64}}(missing, size(bfs_parallel_seq_df, 1))))

bfs_speedup_df = select(bfs_parallel_seq_df, :, 
[:main_loop_time_mean_parallel, :main_loop_time_mean_seq] => ((main_loop_time_mean_parallel, main_loop_time_mean_seq) -> (main_loop_time_mean_seq ./ main_loop_time_mean_parallel)) => :speedup)
bfs_speedup_df = select(bfs_speedup_df, :, 
[:loop_1_mean_time_mean_parallel, :loop_1_mean_time_mean_seq] => ((loop_1_mean_time_mean_parallel, loop_1_mean_time_mean_seq) -> (loop_1_mean_time_mean_seq ./ loop_1_mean_time_mean_parallel)) => :loop_1_speedup)

bfs_speedup_plot = bfs_speedup_df |>
                   @vlplot(
    title = {text = "BFS Speedup", anchor = :middle},
    mark = {:line, clip = true},
    x = {"n_threads:q", axis = {title = "Number of threads"}},
    y = {:loop_1_speedup, axis = {title = "Speedup"}},
    color = {:func_parallel, axis = {title = "Macros"}},
    row = {:input, axis = {title = "Input size"}}
)
bfs_speedup_plot |> save("$(run_)/$(app)/bfs_speedup_plot.png")

bfs_time_plot = bfs_speedup_df |>
                @vlplot(
    title = {text = "BFS Execution Time", anchor = :middle},
    mark = {:bar, clip = true},
    x = {"func_parallel:n", axis = {title = "Macro"}},
    y = {:loop_1_mean_time_mean_parallel, axis = {title = "Execution Time (s)"}},
    color = {:func_parallel, axis = {title = "Macro"}},
    column = {:input, axis = {title = "Input Size"}},
    row = {:n_threads, axis = {title = "Number of threads"}}
)
bfs_time_plot |> save("$(run_)/$(app)/bfs_time_plot.png")

bfs_imbalance_plot = bfs_speedup_df |>
                     @vlplot(
    title = {text = "BFS Imbalance", anchor = :middle},
    mark = {:bar, clip = true},
    x = {"func_parallel:n", axis = {title = "Macro"}},
    y = {:imbalance_mean_parallel, axis = {title = "Imbalance (λ) "}},
    color = {:func_parallel, axis = {title = "Macro"}},
    column = {:input, axis = {title = "Input size"}},
    row = {:n_threads, axis = {title = "Number of Threads"}}
)
bfs_imbalance_plot |> save("$(run_)/$(app)/bfs_imbalance_plot.png")


lud_parallel_seq_df = innerjoin(parallel_lud_df, seq_lud_df, on=[:input, :n_threads], renamecols="_parallel" => "_seq")
lud_parallel_seq_df = hcat(lud_parallel_seq_df, DataFrame(speedup=Vector{Union{Missing,Float64}}(missing, size(lud_parallel_seq_df, 1))))
lud_parallel_seq_df = hcat(lud_parallel_seq_df, DataFrame(loop_1_speedup=Vector{Union{Missing,Float64}}(missing, size(lud_parallel_seq_df, 1))))
lud_parallel_seq_df = hcat(lud_parallel_seq_df, DataFrame(loop_2_speedup=Vector{Union{Missing,Float64}}(missing, size(lud_parallel_seq_df, 1))))

lud_speedup_df = select(lud_parallel_seq_df, :, 
[:main_loop_time_mean_parallel, :main_loop_time_mean_seq] => ((main_loop_time_mean_parallel, main_loop_time_mean_seq) -> (main_loop_time_mean_seq ./ main_loop_time_mean_parallel)) => :speedup)
lud_speedup_df = select(lud_speedup_df, :, 
[:loop_1_mean_time_mean_parallel, :loop_1_mean_time_mean_seq] => ((loop_1_mean_time_mean_parallel, loop_1_mean_time_mean_seq) -> (loop_1_mean_time_mean_seq ./ loop_1_mean_time_mean_parallel)) => :loop_1_speedup)
lud_speedup_df = select(lud_speedup_df, :, 
[:loop_2_mean_time_mean_parallel, :loop_2_mean_time_mean_seq] => ((loop_2_mean_time_mean_parallel, loop_2_mean_time_mean_seq) -> (loop_2_mean_time_mean_seq ./ loop_2_mean_time_mean_parallel)) => :loop_2_speedup)

lud_speedup_plot = lud_speedup_df |>
                   @vlplot(
    title = {text = "LUD Speedup", anchor = :middle},
    mark = {:line, clip = true},
    x = {"n_threads:q", axis = {title = "Number of threads"}},
    y = {:loop_1_speedup, axis = {title = "Speedup"}},
    color = {:func_parallel, axis = {title = "Macros"}},
    row = {:input, axis = {title = "Input size"}}
)
lud_speedup_plot |> save("$(run_)/$(app)/lud_speedup_plot.png")

lud_time_plot = lud_speedup_df |>
                @vlplot(
    title = {text = "LUD Execution Time", anchor = :middle},
    mark = {:bar, clip = true},
    x = {"func_parallel:n", axis = {title = "Macro"}},
    y = {:loop_1_mean_time_mean_parallel, axis = {title = "Execution Time (s)"}},
    color = {:func_parallel, axis = {title = "Macro"}},
    column = {:input, axis = {title = "Input Size"}},
    row = {:n_threads, axis = {title = "Number of threads"}}
)
lud_time_plot |> save("$(run_)/$(app)/lud_time_plot.png")

lud_imbalance_plot = lud_speedup_df |>
                     @vlplot(
    title = {text = "LUD Imbalance", anchor = :middle},
    mark = {:bar, clip = true},
    x = {"func_parallel:n", axis = {title = "Macro"}},
    y = {:loop_1_imbalance_mean_parallel, axis = {title = "Imbalance (λ) "}},
    color = {:func_parallel, axis = {title = "Macro"}},
    column = {:input, axis = {title = "Input size"}},
    row = {:n_threads, axis = {title = "Number of Threads"}}
)
lud_imbalance_plot |> save("$(run_)/$(app)/lud_imbalance_plot.png")

srad_speedup_plot = lud_speedup_df |>
                    @vlplot(
    title = {text = "SRAD_V2 Speedup", anchor = :middle},
    mark = {:line, clip = true},
    x = {"n_threads:q", axis = {title = "Number of threads"}},
    y = {:speedup, axis = {title = "Speedup"}},
    color = {:func_parallel, axis = {title = "Macros"}},
    row = {:input, axis = {title = "Input size"}}
)
srad_speedup_plot |> save("$(run_)/$(app)/srad_speedup_plot.png")

srad_time_plot = speedup_df[speedup_df.bench_name.=="srad", :] |>
                 @vlplot(
    title = {text = "SRAD_V2 Execution Time", anchor = :middle},
    mark = {:bar, clip = true},
    x = {"func_parallel:n", axis = {title = "Macro"}},
    y = {:main_loop_time_mean_parallel, axis = {title = "Execution Time (s)"}},
    color = {:func_parallel, axis = {title = "Macro"}},
    column = {:input, axis = {title = "Input Size"}},
    row = {:n_threads, axis = {title = "Number of threads"}}
)
srad_time_plot |> save("$(run_)/$(app)/srad_time_plot.png")

srad_imbalance_plot = speedup_df[speedup_df.bench_name.=="srad", :] |>
                      @vlplot(
    title = {text = "SRAD_V2 Imbalance", anchor = :middle},
    mark = {:bar, clip = true},
    x = {"func_parallel:n", axis = {title = "Macro"}},
    y = {:imbalance_mean_parallel, axis = {title = "Imbalance (λ) "}},
    color = {:func_parallel, axis = {title = "Macro"}},
    column = {:input, axis = {title = "Input size"}},
    row = {:n_threads, axis = {title = "Number of Threads"}}
)
srad_imbalance_plot |> save("$(run_)/$(app)/srad_imbalance_plot.png")