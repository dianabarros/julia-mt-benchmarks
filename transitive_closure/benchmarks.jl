import Pkg
Pkg.activate("transitive_closure")

using DataFrames, CSV

include("transitive_closure.jl")

inputs = Dict(
    "small" => "transitive_closure/1280_nodes.in",
    # "medium" => "transitive_closure/2560_nodes.in",
    # "large" => "transitive_closure/transitive_closure.in"
)

funcs = [warshall!, warshall_threads!, warshall_floops!]

executors = [ThreadedEx, WorkStealingEx, DepthFirstEx, TaskPoolEx, NondeterministicEx]

check_sequential = true

runs = []

for (size, file_path) in inputs
    nNodes, bytes_per_row, graph = read_file(file_path)
    for func in funcs
        if func == warshall_floops!
            for exec in executors
                run = (f=func, size=size, nNodes=nNodes, bytes_per_row=bytes_per_row, graph=graph, ex=exec, basesize=div(nNodes, nthreads()), check_sequential=check_sequential)
                push!(runs, run)
            end
        else
            run = (f=func, size=size, ex=nothing, basesize=nothing, nNodes=nNodes, bytes_per_row=bytes_per_row, graph=graph, check_sequential=check_sequential)
            push!(runs, run)
        end
    end
end

iterations = 1

df = DataFrame(func=String[], input=String[], executor=Vector{Union{String,Missing}}(), n_threads=Int64[], 
                basesize=Vector{Union{Int64,Missing}}(),total_bytes=Int64[], total_time=Float64[])
df_file_name = string("transitive_closure_results_",nthreads(),".csv")

task_distribution = []
task_times = []

for run in runs
    it_dist = Dict()
    it_ttime = Dict()
    for it in 1:iterations
        println("run = ", (f=run.f, nNodes=run.nNodes, bytes_per_row=run.bytes_per_row, ex=run.ex, basesize=run.basesize, check_sequential=run.check_sequential)) 
        bench_sample = debug(
            run.f, run.nNodes, run.bytes_per_row, run.graph, ex=isnothing(run.ex) ? nothing : run.ex(basesize=run.basesize), check_sequential=run.check_sequential
        )
        it_dist[it] = bench_sample.task_distribution
        for (key, value) in bench_sample.suite
            if !isnothing(findfirst("tasks", key))
                if !haskey(it_ttime,it) 
                    it_ttime[it] = Dict()
                end
                it_ttime[it][key] = value
            end
        end
        push!(df, (func=String(Symbol(run.f)), input=run.size, executor=isnothing(run.ex) ? missing : String(Symbol(run.ex)),
            basesize=isnothing(run.basesize) ? missing : run.basesize, n_threads=nthreads(),
            total_bytes=bench_sample.suite["app"].bytes, total_time=bench_sample.suite["app"].time))
        CSV.write(df_file_name, df)
    end
    push!(task_distribution, (run=run, dist=it_dist))
    if length(it_dist) != 0
        push!(task_times, (run=run, dist=it_dist))
    end
end

open(string("transitive_closure_task_distribution_",nthreads(),".txt"), "w") do io
    print(io, task_distribution)
end

if length(task_times) != 0
    open(string("mutually_friends_task_times_",nthreads(),".txt"), "w") do io
        print(io, task_times)
    end
end