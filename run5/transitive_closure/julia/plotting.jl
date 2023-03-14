using DataFrames, CSV, VegaLite
using Statistics

app = "transitive_closure"
run = "run5"
func = "warshall"

df = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run)/$(app)/julia/$(app)_results.csv"))
# i = 4
# while i <= 16
#     temp = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run)/$(app)/julia/$(app)_results_$i.csv"))
#     df = vcat(df,temp)
#     i = i*2
# end

gb = groupby(df, [:func, :executor, :basesize, :input, :n_threads])
df = combine(gb, 
    [:total_bytes, :total_time] .=>  mean, [:total_bytes, :total_time] .=> std)

floop_df = df[df.func .== "debug_$(func)_floops!", :]

seq_time_df = df[df.func .==  "debug_$(func)!", [:input, :n_threads, :total_time_mean]]

floop_seq_df = innerjoin(floop_df, seq_time_df, on=[:input, :n_threads], renamecols= "_floop" => "_seq")
floop_seq_df = hcat(floop_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(floop_seq_df,1))))


floop_speedup = select(floop_seq_df, :, [:total_time_mean_floop, :total_time_mean_seq] => ((total_time_mean_floop, total_time_mean_seq) -> (total_time_mean_seq./total_time_mean_floop)) => :speedup)

# Comparing executors from FLoops
floop_speedup_plot = floop_speedup |>
    @vlplot(
        mark={:line, clip=true},
        x={"n_threads:q", axis={title="Number of Threads"}},
        y={:speedup, axis={title="Speedup"}},
        color={:executor_floop, axis={title="Executor"}},
        column={:input, axis={title="Input size"}})
        # width=300, height=200)

floop_speedup_plot |> save("$(run)/$(app)/julia/floop_speedup_plot.png")

# NOTE: DepthFirstEx seems to have better performance among executors

mt_df = vcat(floop_df[floop_df.executor .== "DepthFirstEx",:], df[df.func .== "debug_$(func)_threads!", :])
mt_seq_df = innerjoin(mt_df, seq_time_df, on=[:input, :n_threads], renamecols= "_mt" => "_seq")
mt_seq_df = hcat(mt_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(mt_seq_df,1))))

mt_speedup = select(mt_seq_df, :, [:total_time_mean_mt, :total_time_mean_seq] => ((total_time_mean_mt, total_time_mean_seq) -> (total_time_mean_seq./total_time_mean_mt)) => :speedup)
CSV.write("$(run)/$(app)/julia/mt_seq_df.csv", mt_speedup)

# Comparing native and FLoops with DepthFirstEx
mt_speedup_plot = mt_speedup |>
    @vlplot(
        mark={:line, clip=true},
        x={"n_threads:q", axis={title="Number of Threads"}},
        y={:speedup, axis={title="Speedup"}},
        color={:func_mt, axis={title="Parallel Implementation"}},
        column={:input, axis={title="Input size"}})
        # width=300, height=200)

mt_speedup_plot |> save("$(run)/$(app)/julia/mt_speedup_plot.png")

# NOTE: @threads had better performance than Floops with DepthFirstEx

mem_df = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run)/$(app)/julia/$(app)_memory_2.csv"))
i = 4
while i <= 16
    temp = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run)/$(app)/julia/$(app)_memory_$i.csv"))
    mem_df = vcat(mem_df,temp)
    i = i*2
end

# mem_df = mem_df[mem_df.input .== "large", :]

mem_df[:, :memory_kb] = mem_df[:, :memory] ./ 1e3

mem_df[:, :memory_gb] = mem_df[:, :memory] ./ 1e9

seq_mem_df = mem_df[mem_df.func .==  "$(func)!", :] # NOTE: neglegible comparing to multithreading
threads_df = mem_df[mem_df.func .==  "$(func)_threads!", :]
floop_mem_df = mem_df[mem_df.func .==  "$(func)_floops!", :]

final_mem_df = vcat(threads_df, floop_mem_df[floop_mem_df.executor .== "DepthFirstEx", :])
final_mem_df = vcat(final_mem_df, seq_mem_df)
# final_mem_df = final_mem_df[final_mem_df.n_threads .== 16, :]

mt_mem_plot = final_mem_df |>
    @vlplot(
        mark={:bar, clip=true},
        x={:func, axis={title=nothing}},
        y={:memory_kb, axis={title="Memory Usage (Kb)"}},
        color={:func, axis={title="Parallel Implementation"}},
        column={:n_threads, axis={title="Number of Threads"}},
        row={:input, axis={title="Input size"}}    
    )

mt_mem_plot |> save("$(run)/$(app)/julia/mt_mem_plot.png")

# NOTE: NondeterministicEx had worse performance
#      Removing it to be able to compare the other executors
floop_mem_df = floop_mem_df[floop_mem_df.executor .!= "NondeterministicEx", :]

# Comparing executors from FLoops
floop_mem_plot = floop_mem_df |>
    @vlplot(
        mark={:bar, clip=true},
        x={:executor, axis={title=nothing}},
        y={:memory_kb, axis={title="Memory Usage (Kb)"}},
        color={:executor, axis={title="Executor"}},
        column={:n_threads, axis={title="Number of Threads"}},
        row={:input, axis={title="Input size"}}
    )

floop_mem_plot |> save("$(run)/$(app)/julia/floop_mem_plot.png")

# NOTE: ThreadedEx had better memory usage, DepthFirstEx is similar
#      Number of threads that seems to use more memory is 16

# TODO: check if needed to remove sequential for not allocating bytes

# NOTE: @thread had better memory usage

# SCALABILITY

df = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run)/$(app)/julia/scalability/$(app)_results_2.csv"))
i = 4
while i <= 64
    temp = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run)/$(app)/julia/scalability/$(app)_results_$i.csv"))
    df = vcat(df,temp)
    i = i*2
end

gb = groupby(df, [:func, :executor, :basesize, :input, :n_threads])
df = combine(gb, 
    [:total_bytes, :total_time] .=>  mean, [:total_bytes, :total_time] .=> std)

input_sizes = Dict(
    "small" => "Small",
    "medium" => "Medium",
    "large" => "Large"
)
df[!, "input"] = [input_sizes[val] for val in df.input]

floop_df = df[df.func .== "debug_$(func)_floops!", :]

seq_time_df = df[df.func .==  "debug_$(func)!", [:input, :n_threads, :total_time_mean]]

floop_seq_df = innerjoin(floop_df, seq_time_df, on=[:input, :n_threads], renamecols= "_floop" => "_seq")
floop_seq_df = hcat(floop_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(floop_seq_df,1))))

floop_speedup = select(floop_seq_df, :, [:total_time_mean_floop, :total_time_mean_seq] => ((total_time_mean_floop, total_time_mean_seq) -> (total_time_mean_seq./total_time_mean_floop)) => :speedup)

# Comparing executors from FLoops
floop_speedup_plot = floop_speedup |>
    @vlplot(
        mark={:line, clip=true},
        x={"n_threads:q", axis={title="Number of Threads"}},
        y={:speedup, axis={title="Speedup"}},
        color={:executor_floop, axis={title="Executor"}},
        column={:input, axis={title="Input size"},sort={field=:input,order=:descending}}
        # width=300, height=200
    )

floop_speedup_plot |> save("$(run)/$(app)/julia/scalability/floop_speedup_plot.png")

# NOTE: ThreadedEx seems to have better performance among executors

julia_executor = "ThreadedEx"
threads_df = df[df.func .== "debug_$(func)_threads!",:]
threads_df.func .= "Julia - @threads"
executor_df = floop_df[floop_df.executor .== julia_executor,:]
executor_df.func .= "Julia - Floops ($(julia_executor))"
mt_df = vcat(executor_df, threads_df)
mt_seq_df = innerjoin(mt_df, seq_time_df, on=[:input, :n_threads], renamecols= "_mt" => "_seq")
mt_seq_df = hcat(mt_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(mt_seq_df,1))))

mt_speedup = select(mt_seq_df, :, [:total_time_mean_mt, :total_time_mean_seq] => ((total_time_mean_mt, total_time_mean_seq) -> (total_time_mean_seq./total_time_mean_mt)) => :speedup)

# Comparing native and FLoops with DepthFirstEx
mt_speedup_plot = mt_speedup |>
    @vlplot(
        mark={:line, clip=true},
        x={"n_threads:q", axis={title="Number of Threads"}},
        y={:speedup, axis={title="Speedup"}},
        color={:func_mt, axis={title="Parallel Implementation"}},
        column={:input, axis={title="Input size"},sort={field=:input,order=:descending}}
        # width=300, height=200
    )

mt_speedup_plot |> save("$(run)/$(app)/julia/scalability/mt_speedup_plot.png")