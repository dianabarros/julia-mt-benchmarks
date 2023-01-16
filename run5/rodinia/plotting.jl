using DataFrames, CSV, VegaLite, Statistics

run_ = "run5"
app = "rodinia"

df = vcat(
    DataFrame(CSV.File("$(run_)/$(app)/bfs_1.csv")),
    DataFrame(CSV.File("$(run_)/$(app)/lud_1.csv")),
    DataFrame(CSV.File("$(run_)/$(app)/srad_1.csv"))
)
i = 2
while i <= 16
    for func in ["bfs", "lud", "srad"]
        temp = DataFrame(CSV.File("$(run_)/$(app)/$(func)_$(i).csv"))
        df = vcat(df,temp)
    end
    i = i*2
end

gb = groupby(df, [:func, :input, :n_threads])
df = combine(gb, 
    [:main_loop_time, :imbalance] .=>  mean, [:main_loop_time, :imbalance] .=> std)

seq_df = vcat(df[df.func .== "debug_bfs"], df[df.func .== "debug_lud"], df[df.func .== "debug_srad"]) # TODO: confirm and run sequential
parallel_df = vcat(
    df[df.func .== "debug_bfs_mt"], df[df.func .== "debug_bfs_spawn"],
    df[df.func .== "debug_lud_mt"], df[df.func .== "debug_lud_spawn"],
    df[df.func .== "debug_srad_mt"], df[df.func .== "debug_srad_spawn"]
)

parallel_seq_df = innerjoin(parallel_df, seq_df, on=[:input, :n_threads], renamecols= "_parallel" => "_seq")
parallel_seq_df = hcat(parallel_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(parallel_seq_df,1))))

speedup_df = select(parallel_seq_df, :, [:main_loop_time_mean_parallel, :main_loop_time_mean_seq] => ((main_loop_time_mean_parallel, main_loop_time_mean_seq) -> (main_loop_time_mean_seq./main_loop_time_mean_parallel)) => :speedup)

speedup_plot = speedup_df |>
    @vlplot(
        mark={:line, clip=true},
        x="n_threads:q",
        y={:speedup},
        color=:func,
        column=:input
        )

imbalance_plot = parallel_df |>
    @vlplot(
        mark={:line, clip=true},
        x="n_threads:q",
        y={:imbalance_mean},
        color=:func,
        column=:input
        )