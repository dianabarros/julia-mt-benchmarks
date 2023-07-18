import Pkg
Pkg.activate("transitive_closure")

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

include("transitive_closure.jl")

BenchmarkTools.DEFAULT_PARAMETERS.samples = 4
BenchmarkTools.DEFAULT_PARAMETERS.evals = 1

inputs = Dict(
    "test" => "transitive_closure/transitive_closure2.in",
    "small" => "transitive_closure/1280_nodes.in",
    "medium" => "transitive_closure/2560_nodes.in",
    "large" => "transitive_closure/transitive_closure.in"
)
if !isnothing(args["inputs"])
    arg_inputs = Dict()
    for size in eval(Meta.parse(args["inputs"]))
        arg_inputs[size] = inputs[size]
    end
    inputs = arg_inputs
end

funcs = [debug_warshall!, debug_warshall_threads_static!, debug_warshall_threads_dynamic!, debug_warshall_floops!]
if !isnothing(args["funcs"])
    funcs = eval(Meta.parse(args["funcs"]))
end

benchmark_funcs = [warshall!, warshall_threads_static!, warshall_threads_dynamic!, warshall_floops!]
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

for (size, file_path) in inputs
    nNodes, bytes_per_row, graph = read_file(file_path)
    for func in funcs
        if func == debug_warshall_floops!
            for exec in executors
                for basesize in basesizes
                    if basesize == :default
                        run = (f=func, size=size, nNodes=nNodes, bytes_per_row=bytes_per_row, graph=graph, ex=exec, basesize=div(nNodes, nthreads()), check_sequential=check_sequential)
                    else
                        run = (f=func, size=size, nNodes=nNodes, bytes_per_row=bytes_per_row, graph=graph, ex=exec, basesize=basesize, check_sequential=check_sequential)
                    end
                    push!(runs, run)
                end
            end
        else
            run = (f=func, size=size, ex=nothing, basesize=nothing, nNodes=nNodes, bytes_per_row=bytes_per_row, graph=graph, check_sequential=check_sequential)
            push!(runs, run)
        end
    end
    for func in benchmark_funcs
        if func == warshall_floops!
            for exec in executors
                for basesize in basesizes
                    if basesize == :default
                        run = (f=func, size=size, nNodes=nNodes, bytes_per_row=bytes_per_row, graph=graph, ex=exec, basesize=div(nNodes, nthreads()), check_sequential=check_sequential)
                    else
                        run = (f=func, size=size, nNodes=nNodes, bytes_per_row=bytes_per_row, graph=graph, ex=exec, basesize=basesize, check_sequential=check_sequential)
                    end
                    push!(bench_runs, run)
                end
            end
        else
            run = (f=func, size=size, ex=nothing, basesize=nothing, nNodes=nNodes, bytes_per_row=bytes_per_row, graph=graph, check_sequential=check_sequential)
            push!(bench_runs, run)
        end
    end
end

#compile run
println("Running compile runs")
nNodes, bytes_per_row, graph = read_file("transitive_closure/transitive_closure2.in")
if args["timed"]
    debug(debug_warshall!, nNodes, bytes_per_row, graph)
    debug(debug_warshall_threads_static!, nNodes, bytes_per_row, graph)
    debug(debug_warshall_threads_dynamic!, nNodes, bytes_per_row, graph)
    debug(debug_warshall_floops!, nNodes, bytes_per_row, graph, ex=ThreadedEx(basesize=2))
end
if args["benchmarktools"]
    warshall!(nNodes, bytes_per_row, graph)
    warshall_threads_static!(nNodes, bytes_per_row, graph)
    warshall_threads_dynamic!(nNodes, bytes_per_row, graph)
    warshall_floops!(nNodes, bytes_per_row, graph, ThreadedEx(basesize=2))
end

if args["timed"]
    df = DataFrame(func=String[], input=String[], executor=Vector{Union{String,Missing}}(), n_threads=Int64[], 
    basesize=Vector{Union{Int64,Missing}}(),total_bytes=Int64[], total_time=Float64[])
    df_file_name = string("transitive_closure_results_t",nthreads(),"_1.csv")
    if isfile(string("transitive_closure_results_",nthreads(),".csv"))
        df_file_name = string("transitive_closure_results_t",nthreads(),"_2.csv")
    end
    if isfile(df_file_name)
        df_file_name = df_file_name[1:findfirst(".csv", df_file_name).start-1]
        file_num = parse(Int64, split(df_file_name, "_")[end])
        file_num += 1
        df_file_name = "transitive_closure_results_t$(nthreads())_$(file_num).csv"
    end

    println("Running...")
    # task_distribution = []
    # task_times = []
    for run in runs
        # it_dist = Dict()
        # it_ttime = Dict()
        GC.gc() # Forcing gc for getting metrics
        for it in 1:iterations
            println("run = ", (f=run.f, nNodes=run.nNodes, bytes_per_row=run.bytes_per_row, ex=run.ex, basesize=run.basesize, check_sequential=run.check_sequential)) 
            bench_sample = debug(
                run.f, run.nNodes, run.bytes_per_row, run.graph, ex=isnothing(run.ex) ? nothing : run.ex(basesize=run.basesize), check_sequential=run.check_sequential
            )
            # it_dist[it] = bench_sample.task_distribution
            # for (key, value) in bench_sample.suite
            #     if !isnothing(findfirst("tasks", key))
            #         if !haskey(it_ttime,it) 
            #             it_ttime[it] = Dict()
            #         end
            #         it_ttime[it][key] = value
            #     end
            # end
            push!(df, (func=String(Symbol(run.f)), input=run.size, executor=isnothing(run.ex) ? missing : String(Symbol(run.ex)),
                basesize=isnothing(run.basesize) ? missing : run.basesize, n_threads=nthreads(),
                total_bytes=bench_sample.suite["app"].bytes, total_time=bench_sample.suite["app"].time))
            CSV.write(df_file_name, df)
        end
        GC.gc() # Forcing gc for getting metrics
        # push!(task_distribution, (run=run, dist=it_dist))
        # if length(it_ttime) != 0
        #     push!(task_times, (run=run, dist=it_ttime))
        # end
    end
end

if args["benchmarktools"]
    bench_df = DataFrame(func=String[], input=String[], executor=Vector{Union{String,Missing}}(), basesize=Vector{Union{Int64,Missing}}(), n_threads=Int64[], memory=Int64[])
    bench_df_file_name = string("transitive_closure_memory_t",nthreads(),"_1.csv")
    if isfile(string("transitive_closure_memory_",nthreads(),".csv"))
        bench_df_file_name = string("transitive_closure_memory_t",nthreads(),"_2.csv")
    end
    if isfile(bench_df_file_name)
        bench_df_file_name = bench_df_file_name[1:findfirst(".csv", bench_df_file_name).start-1]
        file_num = parse(Int64, split(bench_df_file_name, "_")[end])
        file_num += 1
        bench_df_file_name = "transitive_closure_memory_t$(nthreads())_$(file_num).csv"
    end

    for run in bench_runs
        println("BenchmarkTools run = ", 
            (f=run.f, nNodes=run.nNodes, bytes_per_row=run.bytes_per_row, ex=run.ex, basesize=run.basesize, check_sequential=run.check_sequential) 
        ) 
        if isnothing(run.ex)
            suite = benchmark(run.f, run.nNodes, run.bytes_per_row, run.graph)
        else
            suite = benchmark(run.f, run.nNodes, run.bytes_per_row, run.graph, run.ex(basesize=run.basesize))
        end
        push!(bench_df, (func=String(Symbol(run.f)), input=run.size, executor=isnothing(run.ex) ? missing : String(Symbol(run.ex)),
                basesize=isnothing(run.basesize) ? missing : run.basesize, n_threads=nthreads(),
                memory=suite.memory))
        CSV.write(bench_df_file_name, bench_df)
    end
end

# open(string("transitive_closure_task_distribution_",nthreads(), ".txt"), "w") do io
#     print(io, (run=run, dist=task_distribution))
# end

# if length(task_times) != 0
#     open(string("transitive_closure_task_times_",nthreads(),".txt"), "w") do io
#         print(io, task_times)
#     end
# end

