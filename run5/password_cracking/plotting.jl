using DataFrames, CSV, VegaLite, Statistics

run_ = "run5"
app = "password_cracking"

julia_df = DataFrame(CSV.File("$(run_)/$(app)/julia/mt_seq_df.csv"))
julia_df = rename(julia_df, Dict(:func_mt=>:func, :main_loop_time_mean_mt=>:time_mean ))
c_df = DataFrame(CSV.File("$(run_)/$(app)/c/speedup_df.csv"))
c_df = rename(c_df, Dict(:func_openmp => :func, :n_threads_openmp => :n_threads, :time_mean_openmp => :time_mean))

# TIME COMPARISON: LARGE(6) 16 THREADS
large_julia_df = julia_df[julia_df.input .== "large", :]
large_c_df = c_df[c_df.input .== "large", :]

large_16_julia_df = large_julia_df[large_julia_df.n_threads .== 16, :]
large_16_c_df = large_c_df[large_c_df.n_threads .== 16, :]
large_16_c_df[!,:time_mean] .= large_16_c_df[!,:time_mean]/1000000

large_16_c_julia_df = vcat(large_16_c_df[!,[:func,:time_mean]], large_16_julia_df[!,[:func,:time_mean]])

# NOTE: big difference in time to C
large_16_c_julia_plot = large_16_c_julia_df |>
    @vlplot(
        mark={:bar, clip=true},
        x=:func,
        y={:time_mean},
        color=:func
    )

large_16_c_julia_plot |> save("$(run_)/$(app)/time_comparison_plot.png")

# SEQUENTIAL COMPARISON
julia_gb = groupby(julia_df[julia_df.func .== "debug_brute_force_floop", [:main_loop_time_mean_seq,:input]], [:input])
julia_seq_df = combine(julia_gb,:main_loop_time_mean_seq => mean)
julia_seq_df[!,"lang"] = repeat(["Julia"], first(size(julia_seq_df)))
julia_seq_df = rename(julia_seq_df, Dict(:main_loop_time_mean_seq_mean => :time_mean_seq))
c_gb = groupby(c_df, [:time_mean_seq, :input])
c_seq_df = combine(c_gb,nrow => :count)
c_seq_df[!, "lang"] = repeat(["C"], first(size(c_seq_df)))
c_seq_df[!, "time_mean_seq"] = c_seq_df.time_mean_seq ./ 1000000
seq_df = vcat(c_seq_df[!, [:input, :time_mean_seq, :lang]], julia_seq_df)

input_sizes = Dict(
    "small" => "Small",
    "medium" => "Medium",
    "large" => "Large"
)
seq_df[!, "input"] = [input_sizes[val] for val in seq_df.input]

seq_plot = seq_df |>
    @vlplot(
        mark={:bar, clip=true},
        width=100,
        x={:lang, axis={title=nothing}},
        y={:time_mean_seq, axis={title="Execution Time"}},
        color={:lang, axis={title="Language"}},
        # column={"n_threads:n", axis={title="Number of Threads"}},
        column={
            :input, axis={title="Input Size"},
            sort={field=:input,order=:descending} 
        }
    )
seq_plot |> save("$(run_)/$(app)/seq_time_plot.png")

# SPEEDUP COMPARISON THREADEDEX
floop_df = julia_df[julia_df.func .== "debug_brute_force_floop", :] 
executor_df = floop_df[floop_df.executor_mt .== "DepthFirstEx", :]
threads_df = julia_df[julia_df.func .== "debug_brute_force_threads", :]

executor_df.func .= "Julia - Floops (DepthFirstEx)"
threads_df.func .= "Julia - @threads"

julia_speedup_df = vcat(executor_df,threads_df)

c_df.func .= "C - OpenMP"

speedup_df = vcat(
    julia_speedup_df[:,[:func, :input, :n_threads, :speedup]],
    c_df[:,[:func, :input, :n_threads, :speedup]]
)

input_sizes = Dict(
    "small" => "Small",
    "medium" => "Medium",
    "large" => "Large"
)
speedup_df[:, "input"] = [input_sizes[val] for val in speedup_df.input]

speedup_plot = speedup_df |>
    @vlplot(
        mark={:bar, clip=true},
        x={:func, axis={title=nothing}},
        y={:speedup, axis={title="Speedup"}},
        color={:func, axis={title="Parallel Implementation"}},
        column={"n_threads:n", axis={title="Number of Threads"}},
        row={
            :input, axis={title="Input Size"},
            sort={field=:input,order=:descending} 
        }
    )

speedup_plot |> save("$(run_)/$(app)/speedup_plot.png")

# NOTE: 
#  - small: Julia speedup is better than C, best one with Floops DepthFirstEx, except with 
#   8 threads where OpenMP has better speedup
#  - medium: Julia speedup is better than C, best one varies (Floops or @threads)
#  - large: Julia speedup is better for 2 and 4 threads. C speedup is better with 8 and 16 
#   thereds where with 16 threds C speedup is 4times better than Julia speedup
# TODO: check values for C large with 16 threads to confirm the big difference in results
# TODO: evaluate the scheduling in C


# MEMORY ANALYSIS
c_mem_metric = "max_rss" # TODO: check metric
c_mem_df = DataFrame(CSV.File("$(run_)/$(app)/c/mem_df.csv"))
c_mem_df = rename(c_mem_df, Dict("$(c_mem_metric)_mean" => :memory_kb))
c_mem_df[:,"func"] = [v == 1 ? "C - Sequential" : "C - OpenMP" for v in c_mem_df[:,"n_threads"]]
c_seq_mem_df = c_mem_df[c_mem_df.n_threads .== 1, :]
c_openmp_mem_df = c_mem_df[c_mem_df.n_threads .!= 1, :]
c_mem_df = vcat(
    c_openmp_mem_df[:, [:func, :input, :n_threads, :memory_kb]],
    DataFrame(func=c_seq_mem_df.func, input=c_seq_mem_df.input, n_threads=repeat([2],length(c_seq_mem_df.n_threads)), memory_kb=c_seq_mem_df.memory_kb),
    DataFrame(func=c_seq_mem_df.func, input=c_seq_mem_df.input, n_threads=repeat([4],length(c_seq_mem_df.n_threads)), memory_kb=c_seq_mem_df.memory_kb),
    DataFrame(func=c_seq_mem_df.func, input=c_seq_mem_df.input, n_threads=repeat([8],length(c_seq_mem_df.n_threads)), memory_kb=c_seq_mem_df.memory_kb),
    DataFrame(func=c_seq_mem_df.func, input=c_seq_mem_df.input, n_threads=repeat([16],length(c_seq_mem_df.n_threads)), memory_kb=c_seq_mem_df.memory_kb)
)
c_mem_df[:, :memory_gb] = c_mem_df[:, :memory_kb] ./ 1e6
input_sizes = Dict(
    "small" => "Small",
    "medium" => "Medium",
    "large" => "Large"
)
c_mem_df[:, :input] = [input_sizes[val] for val in c_mem_df.input]

julia_executor = "DepthFirstEx"
julia_mem_df = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run_)/$(app)/julia/pw_cracking_memory_2.csv"))
i = 4
while i <= 16
    temp = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/$(run_)/$(app)/julia/pw_cracking_memory_$i.csv"))
    julia_mem_df = vcat(julia_mem_df,temp)
    i = i*2
end
# julia_mem_df[:, :memory_kb] = julia_mem_df[:, :memory] ./ 1e3
julia_mem_df[:, :memory_gb] = julia_mem_df[:, :memory] ./ 1e9
julia_mem_df.input = length.(julia_mem_df.input)
input_sizes = Dict(4 => "Small", 5 => "Medium", 6 => "Large")
julia_mem_df[!,"input"] = [input_sizes[val] for val in julia_mem_df[!,"input"]]

seq_mem_df = julia_mem_df[julia_mem_df.func .==  "brute_force", :]
seq_mem_df.func .= "Julia - Sequential"
threads_mem_df = julia_mem_df[julia_mem_df.func .==  "brute_force_threads", :]
threads_mem_df.func .= "Julia - @threads"
floop_mem_df = julia_mem_df[julia_mem_df.func .==  "brute_force_floop", :]
floop_mem_df.func .= "Julia - Floops ($(julia_executor))"

julia_mem_df = vcat(threads_mem_df, floop_mem_df[floop_mem_df.executor .== julia_executor, :])
julia_mem_df = vcat(julia_mem_df, seq_mem_df)

final_mem_df = vcat(c_mem_df[:, [:func, :input, :n_threads, :memory_gb]], julia_mem_df[:, [:func, :input, :n_threads, :memory_gb]])

# TODO: change for log scale?
mem_plot = final_mem_df |>
@vlplot(
    mark={:bar, clip=true},
    x={:func, axis={title=nothing}},
    y={:memory_gb, axis={title="Memory Usage (Gb)"}},
    color={:func, axis={title="Parallel Implementation"}},
    column={:n_threads, axis={title="Number of Threads"}},
    row={
        :input, axis={title="Input Size"},
        sort={field=:input,order=:descending} 
    }    
)

mem_plot |> save("$(run_)/$(app)/mem_plot.png")