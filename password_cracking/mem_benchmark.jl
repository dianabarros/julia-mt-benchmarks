# For benchmarking the entire application instead of code blocks

import Pkg
Pkg.activate("password_cracking")

using ArgParse 

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--inputs"
        "--sample"
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

include("brute_force_password_cracking.jl")

BenchmarkTools.DEFAULT_PARAMETERS.samples = 10
BenchmarkTools.DEFAULT_PARAMETERS.seconds = 1800
BenchmarkTools.DEFAULT_PARAMETERS.evals = 1

inputs = Dict(
    4 => Dict(
        "FAZE" => "be5d75fa67ef370e98b3d3611c318156",
        "ENCA" => "9b124d075302f51d5412a1fbe6d83ac9",
        "2ABR" => "4d602f3e818101225f216634e31cd8ed",
        "GRAM" => "6f4862a9a705c7dea77f97b43ebfb7df",
        "ZRNA" => "7d32ec88925bf045d8d337f9f083de5f",
        "0OLA" => "de04ff86e862cd3e380657323e303150",
        "PESS" => "9ec368597e78313f9171c7695d962057",
        "ALMA" => "3ebddf9804c556ddfd0e86eb23f59f51",
        "MADE" => "8551d9042765fcb1f22831ba010aa501",
        "TLES" => "c6a77b48edce59d77093f6d6e6f3504f"
    ),
    5 => Dict(
        "ANIMA" => "9cbbf96d1973a60adebbb153f64b48f6",
        "FANTA" => "452e37b78259f1ffc130ad85663f4c40",
        "GUERR" => "467fe75c655020c476f0199d47e883cd",
        "TRUQE" => "31012a20977110286088c4e7af1a884e",
        "VESKA" => "f9e9eb919de9df008f1ef4d4bbf31808",
        "PEDRE" => "e10710d272e22dfe91517b8ccc7def0e",
        "2VOPA" => "6ea4c5b271e879afa7aaa5592b72aaeb",
        "7LOMA" => "b56008e0f06e5f3a2f5156021a9b4e2b",
        "MASKA" => "39c2b07a337c0c7474839ce283c2d20e",
        "ZORRA" => "a549e5242472175ae8facd9f1d242150"
    ),
    6 => Dict(
        "GEOMET" => "34799a12a6ef24ef95a0f3179ac3c78d",
        "SANGUE" => "0fe2df8cc3c185033bb7b9906edae7d1",
        "ANGUES" => "05887c6b7ee5e63a089bd289d5aa3239",
        "TRAJES" => "f5b59ec5143d666b7239fcb29a51d816",
        "LUTASS" => "9cba3ac4fcfd9e5abd06ece9b8b33db5",
        "OUTONO" => "e3d0d777e0ce1b9ed8f68360879f4606",
        "CLIENT" => "ef10c650df47bffd6399e5e78da2a9b1",
        "9ASKAS" => "79973eac0daf545f164a4c0d71f99f58",
        "2POCAS" => "5c6a9d86bc6aad97122178e36ec053f6",
        "ZEBRAS" => "9c5cd8d2ad3478c090b050c23aca5d43"
    )
)

if !isnothing(args["inputs"])
    arg_inputs = Dict()
    for size in eval(Meta.parse(args["inputs"]))
        arg_inputs[size] = inputs[size]
    end
    inputs = arg_inputs
end

funcs =[brute_force, brute_force_floop, brute_force_threads]
if !isnothing(args["funcs"])
    funcs = eval(Meta.parse(args["funcs"]))
end

executors = [ThreadedEx, WorkStealingEx, DepthFirstEx, TaskPoolEx, NondeterministicEx]
if !isnothing(args["executors"])
    executors = eval(Meta.parse(args["executors"]))
end

input_sample = 1
if !isnothing(args["sample"])
    input_sample = eval(Meta.parse(args["sample"]))
end

check_sequential = args["check_sequential"]

println("Preparing runs")
runs = []
for pw_size in keys(inputs)
    sample = collect(keys(inputs[pw_size]))[input_sample]
    for func in funcs
        if func == brute_force_floop
            for exec in executors
                run = (f=func, size=pw_size, hash1=hex2bytes(inputs[pw_size][sample]), ex=exec, basesize=div(length(letters), nthreads()))
                push!(runs, run)
            end
        else
            run = (f=func, size=pw_size, hash1=hex2bytes(inputs[pw_size][sample]), ex=nothing, basesize=nothing)
            push!(runs, run)
        end
    end
end

# compile run
println("Running compile runs")
brute_force(hex2bytes("800618943025315f869e4e1f09471012"))
brute_force_floop(hex2bytes("800618943025315f869e4e1f09471012"), ThreadedEx())
brute_force_threads(hex2bytes("800618943025315f869e4e1f09471012"))

df = DataFrame(func=String[], input=Int64[], executor=Vector{Union{String, Missing}}(), 
    basesize = Vector{Union{Int64,Missing}}(), n_threads=Int64[], mem_usage=Int64[]
    )
df_file_name = string("password_cracking_full_mem_",nthreads(),".csv")

println("Running...")
for run in runs
    println("run = ", run)
    if isnothing(run.ex)
        suite = @benchmark $run.f($run.hash1)
    else
        suite = @benchmark $run.f($run.hash1, $run.ex(basesize=$run.basesize))
    end
    push!(df, (func=String(Symbol(run.f)), input=run.size, 
            executor=isnothing(run.ex) ? missing : String(Symbol(run.ex)), 
            basesize = isnothing(run.ex) ? missing : run.basesize, n_threads=nthreads(),
            mem_usage=suite.memory))
    CSV.write(df_file_name, df)
end