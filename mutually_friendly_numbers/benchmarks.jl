import Pkg
Pkg.activate("mutually_friendly_numbers")

using ArgParse 

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--inputs"
        "--funcs"
        "--executors"
        "--check_sequential"
            action = :store_true
            default = false
        "--its"
            arg_type = Int
            default = 10
    end

    return parse_args(s)
end

args = parse_commandline()

using DataFrames, CSV

include("friendly_numbers.jl")

# TODO: Pick better inputs
inputs = Dict(
    "small" => (0, 50000),
    "medium" => (0, 100000),
    "large" => (0, 150000)
)
if !isnothing(args["inputs"])
    arg_inputs = Dict()
    for size in eval(Meta.parse(args["inputs"]))
        arg_inputs[size] = inputs[size]
    end
    inputs = arg_inputs
end

funcs =[debug_friendly_numbers, debug_friendly_numbers_threads, debug_friendly_numbers_floop]
if !isnothing(args["funcs"])
    funcs = eval(Meta.parse(args["funcs"]))
end

executors = [ThreadedEx, WorkStealingEx, DepthFirstEx, TaskPoolEx, NondeterministicEx]
if !isnothing(args["executors"])
    executors = eval(Meta.parse(args["executors"]))
end

iterations = args["its"]
check_sequential = args["check_sequential"]

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

# compile run
debug(debug_friendly_numbers, 0, 10)
debug(debug_friendly_numbers_threads, 0, 10)
debug(debug_friendly_numbers_floop, 0, 10, ex=ThreadedEx(basesize=2))

df = DataFrame(iteration = Int64[], func=String[], input=String[], executor=Vector{Union{String, Missing}}(), 
    basesize = Vector{Union{Int64,Missing}}(), n_threads=Int64[], total_bytes=Int64[], total_time=Float64[],
    main_loop_bytes=Int64[], main_loop_time=Float64[]
    )
df_file_name = string("mutually_friends_results_",nthreads(),".csv")

task_distribution = []
task_times = []

for run in runs
    it_dist = Dict()
    it_ttime = Dict()
    for it in 1:iterations
        println("run = ", run) 
        basesize=div(run.stop-run.start, nthreads())
        bench_sample = debug(
            run.f, run.start, run.stop, ex=isnothing(run.ex) ? nothing : run.ex(basesize=basesize), check_sequential=run.check_sequential
        )
        it_dist[it] = bench_sample.task_distribution
        if haskey(bench_sample.suite, "task")
            it_ttime[it] = bench_sample.suite["task"]
        end
        push!(df, (iteration=it, func=String(Symbol(run.f)), input=run.size, 
            executor=isnothing(run.ex) ? missing : String(Symbol(run.ex)), 
            basesize = isnothing(run.ex) ? missing : basesize, n_threads=nthreads(), total_bytes=bench_sample.suite["app"].bytes, 
            total_time=bench_sample.suite["app"].time,main_loop_bytes=bench_sample.suite["loop"].bytes, main_loop_time=bench_sample.suite["loop"].time))
        CSV.write(df_file_name, df)
    end
    push!(task_distribution, (run=run, dist=it_dist))
    if length(it_ttime) != 0
        push!(task_times, (run=run, dist=it_ttime))
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
