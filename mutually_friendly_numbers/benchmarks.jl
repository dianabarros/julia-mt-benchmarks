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

check_sequential = true

runs = []
for (size, range) in inputs
    for func in funcs
        for exec in executors
            run = (f=func, size=size, start=range[1], stop=range[2], ex=exec, check_sequential=check_sequential)
            push!(runs, run)
        end
    end
end

iterations = 1

df = DataFrame(func=String[], input=String[], executor=String[], n_threads=Int64[], total_time=Float64[])
df_file_name = "mutually_friends_results.csv"

task_distribution = []

for run in runs
    it_dist = Dict()
    for it in 1:iterations
        @show run
        bench_sample = debug(
            run.f, run.start, run.stop, ex=run.ex(basesize=div(run.stop-run.start, nthreads())), check_sequential=run.check_sequential
        )
        it_dist[it] = bench_sample.task_distribution
        push!(df, (func=String(Symbol(run.f)), input=run.size, executor=String(Symbol(run.ex)), n_threads=nthreads(), total_time=bench_sample.suite["app"].time))
        CSV.write(df_file_name, df)
    end
    push!(task_distribution, (run=run, dist=it_dist))
end

open("mutually_friends_task_distribution.txt", "w") do io
    print(io, task_distribution)
end
