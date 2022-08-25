# For benchmarking the entire application instead of code blocks

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
    end

    return parse_args(s)
end

args = parse_commandline()

using DataFrames, CSV

include("friendly_numbers.jl")

BenchmarkTools.DEFAULT_PARAMETERS.samples = 10
BenchmarkTools.DEFAULT_PARAMETERS.evals = 1

inputs = Dict(
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

funcs =[friendly_numbers, friendly_numbers_threads, friendly_numbers_floop]
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
bench_runs = []
for (size, range) in inputs
    for func in funcs
        if func == friendly_numbers_floop
            for exec in executors
                run = (f=func, size=size, start=range[1], stop=range[2], ex=exec)
                push!(runs, run)
            end
        else
            run = (f=func, size=size, start=range[1], stop=range[2], ex=nothing)
            push!(runs, run)
        end
    end
end

# compile run
println("Running compile runs")
friendly_numbers(0, 10)
friendly_numbers_threads(0, 10)
friendly_numbers_floop(0, 10, ThreadedEx(basesize=2))

df = DataFrame(func=String[], input=String[], executor=Vector{Union{String, Missing}}(), 
    basesize = Vector{Union{Int64,Missing}}(), n_threads=Int64[], mem_usage=Int64[]
    )
df_file_name = string("mutually_friends_full_mem",nthreads(),".csv")

println("Running...")
for run in runs
    println("run = ", run)
    if isnothing(run.ex)
        suite = @benchmark $run.f($run.start, $run.stop)
    else
        basesize=div(run.stop-run.start, nthreads())
        suite = @benchmark $run.f($run.start, $run.stop, $run.ex(basesize=$basesize))
    end
    push!(df, (func=String(Symbol(run.f)), input=run.size, 
            executor=isnothing(run.ex) ? missing : String(Symbol(run.ex)), 
            basesize = isnothing(run.ex) ? missing : basesize, n_threads=nthreads(),
            mem_usage=suite.memory))
    CSV.write(df_file_name, df)
end