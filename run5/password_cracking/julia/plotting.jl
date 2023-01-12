using DataFrames, CSV, VegaLite
using Statistics

app = "password_cracking"
run = "run5"
func = "brute_force"

df = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run)/$(app)/julia/pw_cracking_results_2.csv"))
i = 4
while i <= 16
    temp = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run)/$(app)/julia/pw_cracking_results_$i.csv"))
    df = vcat(df,temp)
    i = i*2
end

df.input= length.(df.input)

gb = groupby(df, [:func, :executor, :basesize, :input, :n_threads])
df = combine(gb, 
    [:main_loop_bytes, :main_loop_time] .=>  mean, [:main_loop_bytes, :main_loop_time] .=> std)

floop_df = df[df.func .== "debug_$(func)_floop", :]

seq_time_df = df[df.func .==  "debug_$(func)", [:input, :n_threads, :main_loop_time_mean]]

floop_seq_df = innerjoin(floop_df, seq_time_df, on=[:input, :n_threads], renamecols= "_floop" => "_seq")
floop_seq_df = hcat(floop_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(floop_seq_df,1))))

floop_speedup = select(floop_seq_df, :, [:main_loop_time_mean_floop, :main_loop_time_mean_seq] => ((main_loop_time_mean_floop, main_loop_time_mean_seq) -> (main_loop_time_mean_seq./main_loop_time_mean_floop)) => :speedup)

# Comparing executors from FLoops
floop_speedup_plot = floop_speedup |>
    @vlplot(
        mark={:line, clip=true},
        x="n_threads:q",
        y={:speedup},
        color=:executor_floop,
        column=:input)
        # width=300, height=200)

floop_speedup_plot |> save("$(run)/$(app)/julia/floop_speedup_plot.png")

# NOTE: DepthFirstEx seems to have better performance among executors

mt_df = vcat(floop_df[floop_df.executor .== "DepthFirstEx",:], df[df.func .== "debug_$(func)_threads", :])
mt_seq_df = innerjoin(mt_df, seq_time_df, on=[:input, :n_threads], renamecols= "_mt" => "_seq")
mt_seq_df = hcat(mt_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(mt_seq_df,1))))
CSV.write("mt_seq_df.csv", mt_seq_df)

mt_speedup = select(mt_seq_df, :, [:main_loop_time_mean_mt, :main_loop_time_mean_seq] => ((main_loop_time_mean_mt, main_loop_time_mean_seq) -> (main_loop_time_mean_seq./main_loop_time_mean_mt)) => :speedup)

# Comparing native and FLoops with DepthFirstEx
mt_speedup_plot = mt_speedup |>
    @vlplot(
        mark={:line, clip=true},
        x="n_threads:q",
        y={:speedup},
        color=:func_mt,
        column=:input)
        # width=300, height=200)

mt_speedup_plot |> save("$(run)/$(app)/julia/mt_speedup_plot.png")

#NOTE: DepthFirstEx seems to have better performance than @threads
#    @threads speedup seems inconsistent between different sizes
#    it reaches a peak for medium input with 8 threads
#    it reaches a peak for large input with 4 threads and a valley with 8 threads then it increases again

mem_df = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run)/$(app)/julia/pw_cracking_memory_2.csv"))
i = 4
while i <= 16
    temp = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run)/$(app)/julia/pw_cracking_memory_$i.csv"))
    mem_df = vcat(mem_df,temp)
    i = i*2
end

mem_df.input = length.(mem_df.input)

mem_df = mem_df[mem_df.input .== 6, :]

mem_df[:, :memory_kb] = mem_df[:, :memory] ./ 1e3

mem_df[:, :memory_gb] = mem_df[:, :memory] ./ 1e9

seq_mem_df = mem_df[mem_df.func .==  "$(func)", :]
threads_df = mem_df[mem_df.func .==  "$(func)_threads", :]
floop_mem_df = mem_df[mem_df.func .==  "$(func)_floop", :]

# Comparing executors from FLoops
floop_mem_plot = floop_mem_df |>
    @vlplot(
        mark={:bar, clip=true},
        x=:executor,
        y={:memory_gb},
        color=:executor,
        column=:n_threads)

floop_mem_plot |> save("$(run)/$(app)/julia/floop_mem_plot.png")

# NOTE: DepthFirstEx seems to have better memory usage
#      The number of threads that showed more memory usage was 4

final_mem_df = vcat(threads_df, floop_mem_df[floop_mem_df.executor .== "DepthFirstEx", :])
final_mem_df = vcat(final_mem_df, seq_mem_df)
final_mem_df = final_mem_df[final_mem_df.n_threads .== 4, :]

mt_mem_plot = final_mem_df |>
    @vlplot(
        mark={:bar, clip=true},
        x=:func,
        y={:memory_gb},
        color=:func,
        column=:n_threads)

mt_mem_plot |> save("$(run)/$(app)/julia/mt_mem_plot.png")

# NOTE: multithreading consumes more memory than sequential

# TODO: analyse closely the comparisom between executor and threads 
#     refine the precision. As it is it seems to be similar usage