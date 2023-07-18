import Pkg
Pkg.activate("mutually_friendly_numbers")

using ArgParse 

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--inputs"
        "--funcs"
        "--bench-funcs"
        "--executors"
        "--no_check_sequential"
            action = :store_true
        "--its"
            arg_type = Int
            default = 10
        "--benchmarktools"
            action = :store_true
        "--timed"
            action = :store_true
    end

    return parse_args(s)
end

args = parse_commandline()

using DataFrames, CSV

include("friendly_numbers.jl")

BenchmarkTools.DEFAULT_PARAMETERS.samples = 10
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 3600
BenchmarkTools.DEFAULT_PARAMETERS.evals = 1


inputs = Dict(
    "test" => (0, 10),
    "small" => (0, 50000),
    "medium" => (0, 200000),
    "large" => (0, 350000)
)
if !isnothing(args["inputs"])
    arg_inputs = Dict()
    for size in eval(Meta.parse(args["inputs"]))
        arg_inputs[size] = inputs[size]
    end
    inputs = arg_inputs
end

funcs =[debug_friendly_numbers, debug_friendly_numbers_threads_static, debug_friendly_numbers_threads_dynamic, debug_friendly_numbers_floop]
if !isnothing(args["funcs"])
    funcs = eval(Meta.parse(args["funcs"]))
end

# benchmark_funcs = [benchmark_friendly_numbers, benchmark_friendly_numbers_floop, benchmark_friendly_numbers_threads]
benchmark_funcs = [friendly_numbers, friendly_numbers_threads_static, friendly_numbers_threads_dynamic, friendly_numbers_floop]
if !isnothing(args["bench-funcs"])
    funcs = eval(Meta.parse(args["bench-funcs"]))
end

executors = [ThreadedEx, WorkStealingEx, DepthFirstEx, TaskPoolEx, NondeterministicEx]
if !isnothing(args["executors"])
    executors = eval(Meta.parse(args["executors"]))
end

basesizes = [:default]

iterations = args["its"]
check_sequential = !args["no_check_sequential"]

println("Preparing runs")
runs = []
bench_runs = []
for (size, range) in inputs
    for func in funcs
        if func == debug_friendly_numbers_floop
            for exec in executors
                for basesize in basesizes
                    if basesize == :default
                        run = (f=func, size=size, start=range[1], stop=range[2], ex=exec(basesize=div(range[2]-range[1],nthreads())), basesize=div(range[2]-range[1],nthreads()), check_sequential=check_sequential)
                    else
                        run = (f=func, size=size, start=range[1], stop=range[2], ex=exec(basesize=basesize), basesize=basesize, check_sequential=check_sequential)
                    end
                    push!(runs, run)
                end
            end
        else
            run = (f=func, size=size, start=range[1], stop=range[2], ex=nothing, basesize=nothing, check_sequential=check_sequential)
            push!(runs, run)
        end
    end
    for func in benchmark_funcs
        if func == benchmark_friendly_numbers_floop
            for exec in executors
                for basesize in basesizes
                    if basesize == :default
                        run = (f=func, size=size, start=range[1], stop=range[2], ex=exec(basesize=div(range[2]-range[1],nthreads())), basesize=div(range[2]-range[1],nthreads()), check_sequential=check_sequential)
                    else
                        run = (f=func, size=size, start=range[1], stop=range[2], ex=exec(basesize=basesize), basesize=basesize, check_sequential=check_sequential)
                    end
                    push!(bench_runs, run)
                end
            end
        else
            run = (f=func, size=size, start=range[1], stop=range[2], ex=nothing, basesize=nothing, check_sequential=check_sequential)
            push!(bench_runs, run)
        end
    end
end

# compile run
println("Running compile runs")
if !args["timed"]
    debug(debug_friendly_numbers, 0, 10)
    debug(debug_friendly_numbers_threads_static, 0, 10)
    debug(debug_friendly_numbers_threads_dynamic, 0, 10)
    debug(debug_friendly_numbers_floop, 0, 10, ex=ThreadedEx(basesize=2))
end
if args["benchmarktools"]
    benchmark_friendly_numbers(0, 10)
    benchmark_friendly_numbers_threads_static(0, 10)
    benchmark_friendly_numbers_threads_dynamic(0, 10)
    benchmark_friendly_numbers_floop(0, 10, ThreadedEx(basesize=2))
end

if args["timed"]
    df = DataFrame(iteration = Int64[], func=String[], input=String[], executor=Vector{Union{String, Missing}}(), 
        basesize = Vector{Union{Int64,Missing}}(), n_threads=Int64[], total_bytes=Int64[], total_time=Float64[],
        main_loop_bytes=Int64[], main_loop_time=Float64[]
        )
    df_file_name = string("mutually_friends_results_t",nthreads(),"_1.csv")
    if isfile(string("mutually_friends_results_",nthreads(),".csv"))
        df_file_name = string("mutually_friends_results_t",nthreads(),"_2.csv")
    end
    if isfile(df_file_name)
        df_file_name = df_file_name[1:findfirst(".csv", df_file_name).start-1]
        file_num = parse(Int64, split(df_file_name, "_")[end])
        file_num += 1
        df_file_name = "mutually_friends_results_t$(nthreads())_$(file_num).csv"
    end

    # task_distribution = []
    # task_times = []

    println("Running...")
    for run in runs
        # it_dist = Dict()
        # it_ttime = Dict()
        for it in 1:iterations
            println("run = ", run) 
            bench_sample = debug(
                run.f, run.start, run.stop, ex=isnothing(run.basesize) ? nothing : run.ex, check_sequential=run.check_sequential
            )
            # it_dist[it] = bench_sample.task_distribution
            # if haskey(bench_sample.suite, "task")
            #     it_ttime[it] = bench_sample.suite["task"]
            # end
            ex_name = isnothing(run.ex) ? missing : string(typeof(run.ex).name.name)
            push!(df, (iteration=it, func=String(Symbol(run.f)), input=run.size, 
                executor=ex_name, 
                basesize = isnothing(run.basesize) ? missing : run.basesize, n_threads=nthreads(), total_bytes=bench_sample.suite["app"].bytes, 
                total_time=bench_sample.suite["app"].time,main_loop_bytes=bench_sample.suite["loop"].bytes, main_loop_time=bench_sample.suite["loop"].time))
            CSV.write(df_file_name, df)
        end
        # push!(task_distribution, (run=run, dist=it_dist))
        # if length(it_ttime) != 0
        #     push!(task_times, (run=run, dist=it_ttime))
        # end
    end
end

if args["benchmarktools"]
    bench_df = DataFrame(func=String[], input=String[], executor=Vector{Union{String, Missing}}(), 
            basesize = Vector{Union{Int64,Missing}}(), n_threads=Int64[], memory=Int64[]
            )
    bench_df_file_name = string("mutually_friends_memory_t",nthreads(),"_1.csv")
    if isfile(string("mutually_friends_memory_",nthreads(),".csv"))
        bench_df_file_name = string("mutually_friends_memory_t",nthreads(),"_2.csv")
    end
    if isfile(bench_df_file_name)
        bench_df_file_name = bench_df_file_name[1:findfirst(".csv", bench_df_file_name).start-1]
        file_num = parse(Int64, split(bench_df_file_name, "_")[end])
        file_num += 1
        bench_df_file_name = "mutually_friends_memory_t$(nthreads())_$(file_num).csv"
    end

    for run in bench_runs
        println("BenchmarkTools run = ", run) 
        if isnothing(run.ex)
            # suite = run.f(run.start, run.stop)
            suite = @benchmark $run.f($run.start, $run.stop)
        else
            # suite = run.f(run.start, run.stop, run.ex(basesize=basesize))
            suite = @benchmark $run.f($run.start, $run.stop, $run.ex)
        end
        ex_name = isnothing(run.ex) ? missing : string(typeof(run.ex).name.name)
        push!(bench_df, (func=String(Symbol(run.f)), input=run.size, 
                executor=ex_name, 
                basesize = isnothing(run.basesize) ? missing : run.basesize, n_threads=nthreads(),
                memory=suite.memory))
        CSV.write(bench_df_file_name, bench_df)
    end
end

# open(string("mutually_friends_task_distribution_",nthreads(),".txt"), "w") do io
#     print(io, task_distribution)
# end

# if length(task_times) != 0
#     open(string("mutually_friends_task_times_",nthreads(),".txt"), "w") do io
#         print(io, task_times)
#     end
# end
