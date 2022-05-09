using DataFrames, CSV

include("transitive_closure.jl")

inputs = Dict(
    "small" => "1280_nodes.in",
    "medium" => "2560_nodes.in",
    "large" => "transitive_closure.in"
)

funcs = [warshall!, warshall_threads!, warshall_floops!]

executors = [ThreadedEx, WorkStealingEx, DepthFirstEx, TaskPoolEx, NondeterministicEx]

check_sequential = true

runs = []

for (size, file_path) in inputs
    for func in funcs
        for exec in executors
            run = (f=func, size=size, file_path=file_path, ex=exec, check_sequential=check_sequential)
            push!(runs, run)
        end
    end
end

iterations = 1

df = DataFrame(func=String[], input=String[], executor=String[], n_threads=Int64[], total_time=Float64[])
df_file_name = "transitive_closure_results.csv"

task_distribution = []

for run in runs
    it_dist = Dict()
    for it in 1:iterations
        @show run
        bench_sample = debug(
            run.f, run.file_path, ex=run.ex, check_sequential=run.check_sequential
        )
        it_dist[it] = bench_sample.task_distribution
        push!(df, (func=String(Symbol(run.f)), input=run.size, executor=String(Symbol(run.ex)), n_threads=nthreads(), total_time=bench_sample.suite["app"].time))
        CSV.write(df_file_name, df)
    end
    push!(task_distribution, (run=run, dist=it_dist))
end

open("transitive_closure_task_distribution.txt", "w") do io
    print(io, task_distribution)
end