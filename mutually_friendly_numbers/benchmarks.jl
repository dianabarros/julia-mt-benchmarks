import Pkg
Pkg.activate("mutually_friendly_numbers")

using DataFrames, CSV

include("friendly_numbers.jl")

# TODO: Pick better inputs
inputs = Dict(
    "small" => (0, 10000),
    "medium" => (0, 50000),
    "large" => (0, 100000)
)

funcs =[debug_friendly_numbers, debug_friendly_numbers_threads, debug_friendly_numbers_floop]

executors = [ThreadedEx, WorkStealingEx, DepthFirstEx, TaskPoolEx, NondeterministicEx]

check_sequential = false

runs = []
for (size, range) in inputs
    for func in funcs
        if func == debug_friendly_numbers_floop
            for exec in executors
                run = (f=func, size=size, start=range[1], stop=range[2], ex=exec, check_sequential=check_sequential)
                push!(runs, run)
            end
        else
            run = (f=func, size=size, start=range[1], stop=range[2], ex=nothing, check_sequential=check_sequential)
            push!(runs, run)
        end
    end
end

iterations = 1

df = DataFrame(fiteration = Int64[], unc=String[], input=String[], executor=Vector{Union{String, Missing}}(), 
    basesize = Vector{Union{Int64,Missing}}(), n_threads=Int64[], total_bytes=Int64[], total_time=Float64[]
    )
df_file_name = "mutually_friends_results.csv"

task_distribution = []
task_times = []

for run in runs
    it_dist = Dict()
    it_ttimes = Dict()
    for it in 1:iterations
        print("run = ", run) 
        basesize=div(run.stop-run.start, nthreads())
        bench_sample = debug(
            run.f, run.start, run.stop, ex=isnothing(run.ex) ? nothing : run.ex(basesize=basesize), check_sequential=run.check_sequential
        )
        it_dist[it] = bench_sample.task_distribution
        if haskey(bench_sample.suite, "task")
            it_ttimes[it] = bench_sample.suite["task"]
        end
        push!(df, (iteration=it, func=String(Symbol(run.f)), input=run.size, 
            executor=isnothing(run.ex) ? missing : String(Symbol(run.ex)), 
            basesize = isnothing(run.ex) ? missing : basesize, n_threads=nthreads(), total_bytes=bench_sample.suite["app"].bytes, 
            total_time=bench_sample.suite["app"].time))
        CSV.write(df_file_name, df)
    end
    push!(task_distribution, (run=run, dist=it_dist))
    if length(it_dist) != 0
        push!(task_times, (run=run, dist=it_dist))
    end
end

open(string("mutually_friends_task_distribution_",nthreads(),".txt"), "w") do io
    print(io, task_distribution)
end

if length(task_times) != 0
    open(string("mutually_friends_task_times_",nthreads(),".txt"), "w") do io
        print(io, task_times)
    end
end