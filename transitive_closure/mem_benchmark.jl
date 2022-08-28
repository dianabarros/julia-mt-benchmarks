# For benchmarking the entire application instead of code blocks

import Pkg
Pkg.activate("transitive_closure")

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
    end

    return parse_args(s)
end

args = parse_commandline()

using DataFrames, CSV

include("transitive_closure.jl")

BenchmarkTools.DEFAULT_PARAMETERS.samples = 4
BenchmarkTools.DEFAULT_PARAMETERS.evals = 1

inputs = Dict(
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

funcs =[warshall!, warshall_floops!, warshall_threads!]
if !isnothing(args["funcs"])
    funcs = eval(Meta.parse(args["funcs"]))
end

executors = [ThreadedEx, WorkStealingEx, DepthFirstEx, TaskPoolEx, NondeterministicEx]
if !isnothing(args["executors"])
    executors = eval(Meta.parse(args["executors"]))
end

check_sequential = args["check_sequential"]

println("Preparing runs")
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

# compile run
println("Running compile runs")
nNodes, bytes_per_row, graph = read_file("transitive_closure/transitive_closure2.in")
warshall!(nNodes, bytes_per_row, graph)
warshall_threads!(nNodes, bytes_per_row, graph)
warshall_floops!(nNodes, bytes_per_row, graph, ThreadedEx(basesize=2))

df = DataFrame(func=String[], input=String[], executor=Vector{Union{String, Missing}}(), 
    basesize = Vector{Union{Int64,Missing}}(), n_threads=Int64[], mem_usage=Int64[]
    )
df_file_name = string("transitive_closure_full_mem_",nthreads(),".csv")

println("Running...")
for run in runs
    println("run = ", (f=run.f, nNodes=run.nNodes, bytes_per_row=run.bytes_per_row, ex=run.ex, basesize=run.basesize, check_sequential=run.check_sequential)) 
    if isnothing(run.ex)
        suite = @benchmark $run.f($run.nNodes, $run.bytes_per_row, $run.graph)
    else
        suite = @benchmark $run.f($run.nNodes, $run.bytes_per_row, $run.graph, $run.ex(basesize=$run.basesize))
    end
    push!(df, (func=String(Symbol(run.f)), input=run.size, 
            executor=isnothing(run.ex) ? missing : String(Symbol(run.ex)), 
            basesize = isnothing(run.ex) ? missing : run.basesize, n_threads=nthreads(),
            mem_usage=suite.memory))
    CSV.write(df_file_name, df)
end