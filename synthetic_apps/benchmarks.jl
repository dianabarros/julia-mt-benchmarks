import Pkg
Pkg.activate("synthetic_apps")

using ArgParse 
using DataFrames, CSV, Statistics

function calculate_imbalance(times)
    mean_time = mean(times)
    maximum_time = maximum(times)
    λ = (maximum_time/mean_time - 1) * 100
    return λ
end

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--inputs"
        "--funcs"
        "--check_sequential"
            action = :store_true
            default = false
        "--its"
            arg_type = Int
            default = 10
        "--benchmarktools"
            action = :store_true
            default = false
    end

    return parse_args(s)
end

args = parse_commandline()

include("synth.jl")

inputs = Dict(
    "small" => (N=10, k=500, n=rand(Float64, 10, 500)),
    "medium" => (N=100, k=500, n=rand(Float64, 100, 500)),
    "large" => (N=500, k=500, n=rand(Float64, 500, 500))
)
if !isnothing(args["inputs"])
    arg_inputs = Dict()
    for size in eval(Meta.parse(args["inputs"]))
        arg_inputs[size] = inputs[size]
    end
    inputs = arg_inputs
end

# Currently not running static
funcs =[unbalanced_mt, unbalanced_spawn, balanced_mt, balanced_spawn]
if !isnothing(args["funcs"])
    funcs = eval(Meta.parse(args["funcs"]))
end

iterations = args["its"]
check_sequential = args["check_sequential"]

println("Preparing runs")
runs = []
for (size, args) in inputs
    for func in funcs
        run = (f=func, size=size, N=args.N, k=args.k, n=args.n)
        push!(runs, run)
    end
end

println("Running compile runs")
debug(unbalanced, 10, 10, rand(Float64, 10, 10))
debug(unbalanced_mt, 10, 10, rand(Float64, 10, 10))
debug(unbalanced_spawn, 10, 10, rand(Float64, 10, 10))
debug(balanced, 10, 10, rand(Float64, 10, 10))
debug(balanced_mt, 10, 10, rand(Float64, 10, 10))
debug(balanced_spawn, 10, 10, rand(Float64, 10, 10))

df = DataFrame(iteration = Int64[], func=String[], input=String[], 
    n_threads=Int64[], main_loop_time=Float64[], imbalance=Float64[]
    )
df_file_name = string("synth_app_",nthreads(),".csv")

println("Running...")
for run in runs
    for it in 1:iterations
        println("run = ", (f=run.f, size=run.size, N=run.N, k=run.k)) 
        bench_sample = debug(
            run.f, run.N, run.k, run.n
        )

        imbalance = calculate_imbalance(bench_sample.suite["main_loop"]["thread_time"])
        push!(df, (iteration=it, func=String(Symbol(run.f)), input=run.size, n_threads=nthreads(),
            main_loop_time=bench_sample.suite["main_loop"]["total_stats"].time, imbalance=imbalance))
        CSV.write(df_file_name, df)
    end
end