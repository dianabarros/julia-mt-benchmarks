import Pkg
Pkg.activate("password_cracking")

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

input_samples = 10

funcs = [debug_brute_force, debug_brute_force_threads, debug_brute_force_floop]
if !isnothing(args["funcs"])
    funcs = eval(Meta.parse(args["funcs"]))
end
benchmark_funcs = [brute_force, brute_force_floop, brute_force_threads]

basesizes = [div(length(letters), nthreads())]

executors = [ThreadedEx, WorkStealingEx, DepthFirstEx, TaskPoolEx, NondeterministicEx]
if !isnothing(args["executors"])
    executors = eval(Meta.parse(args["executors"]))
end

iterations = args["its"]
check_sequential = args["check_sequential"]

println("Preparing runs")
runs = []
bench_runs = []

for pw_size in keys(inputs)
    for pw in collect(keys(inputs[pw_size]))[1:input_samples]
        hash_str = inputs[pw_size][pw]
        for func in funcs
            if func == debug_brute_force_floop
                for exec in executors
                    for basesize in basesizes
                        run = (f=func, pw=pw, hash_str=hash_str, ex=exec, basesize=basesize, check_sequential=check_sequential)
                        push!(runs, run)
                    end
                end
            else
                run = (f=func, pw=pw, hash_str=hash_str, ex=nothing, basesize=nothing, check_sequential=check_sequential)
                push!(runs, run)
            end
        end
    end
end

for pw_size in keys(inputs)
    for pw in collect(keys(inputs[pw_size]))[1:1]
        hash_str = inputs[pw_size][pw]
        for func in benchmark_funcs
            if func == brute_force_floop
                for exec in executors
                    for basesize in basesizes
                        run = (f=func, pw=pw, hash_str=hash_str, ex=exec, basesize=basesize, check_sequential=check_sequential)
                        push!(bench_runs, run)
                    end
                end
            else
                run = (f=func, pw=pw, hash_str=hash_str, ex=nothing, basesize=nothing, check_sequential=check_sequential)
                push!(bench_runs, run)
            end
        end
    end
end

# compile run
println("Running compile runs")
debug_crack_password(debug_brute_force,"800618943025315f869e4e1f09471012")
debug_crack_password(debug_brute_force_threads,"800618943025315f869e4e1f09471012")
debug_crack_password(debug_brute_force_floop,"800618943025315f869e4e1f09471012", ex=ThreadedEx(basesize=2))
brute_force(hex2bytes("800618943025315f869e4e1f09471012"))
brute_force_threads(hex2bytes("800618943025315f869e4e1f09471012"))
brute_force_floop(hex2bytes("800618943025315f869e4e1f09471012"), ThreadedEx(basesize=2))

df = DataFrame(iteration = Int64[], func=String[], input=String[], executor=Vector{Union{String,Missing}}(), 
                basesize=Vector{Union{Int64,Missing}}(), n_threads=Int64[], total_bytes=Int64[], 
                main_loop_bytes=Int64[], main_loop_time=Float64[], total_time=Float64[], loop_1_time=Float64[], 
                loop_2_time=Float64[], loop_3_time=Float64[], loop_4_time=Float64[], loop_5_time=Float64[], 
                loop_6_time=Float64[], loop_7_time=Float64[], loop_8_time=Float64[])
df_file_name = string("pw_cracking_results_",nthreads(),".csv")

task_distribution = []
task_times = []

println("Running...")
for run in runs
    it_dist = Dict()
    it_ttime = Dict()
    for it in 1:iterations
        println("run = ", run)
        bench_sample = debug_crack_password(
            run.f, run.hash_str, ex=isnothing(run.ex) ? nothing : run.ex(basesize=run.basesize), check_sequential=run.check_sequential
        )
        it_dist[it] = bench_sample.loop_tasks
        for (key, value) in bench_sample.suite
            if !isnothing(findfirst("tasks", key))
                if !haskey(it_ttime,it) 
                    it_ttime[it] = Dict()
                end
                it_ttime[it][key] = value
            end
        end
        push!(df, (iteration=it, func=String(Symbol(run.f)), input=run.pw, executor=isnothing(run.ex) ? missing : String(Symbol(run.ex)), basesize=isnothing(run.basesize) ? missing : run.basesize, 
            n_threads=nthreads(), total_bytes=bench_sample.suite["app"].bytes, total_time=bench_sample.suite["app"].time,
            main_loop_bytes=bench_sample.suite["main_loop"].bytes, main_loop_time=bench_sample.suite["main_loop"].time,
            loop_1_time=haskey(bench_sample.suite, "loop_1") ? bench_sample.suite["loop_1"].time : 0.0, 
            loop_2_time=haskey(bench_sample.suite, "loop_2") ? bench_sample.suite["loop_2"].time : 0.0,
            loop_3_time=haskey(bench_sample.suite, "loop_3") ? bench_sample.suite["loop_3"].time : 0.0,
            loop_4_time=haskey(bench_sample.suite, "loop_4") ? bench_sample.suite["loop_4"].time : 0.0,
            loop_5_time=haskey(bench_sample.suite, "loop_5") ? bench_sample.suite["loop_5"].time : 0.0,
            loop_6_time=haskey(bench_sample.suite, "loop_6") ? bench_sample.suite["loop_6"].time : 0.0,
            loop_7_time=haskey(bench_sample.suite, "loop_7") ? bench_sample.suite["loop_7"].time : 0.0,
            loop_8_time=haskey(bench_sample.suite, "loop_8") ? bench_sample.suite["loop_8"].time : 0.0)
            )
        CSV.write(df_file_name, df)
    end
    push!(task_distribution, (run=run, dist=it_dist))
    if length(it_ttime) != 0
        push!(task_times, (run=run, dist=it_ttime))
    end
end

bench_df = DataFrame(func=String[], input=String[], executor=Vector{Union{String,Missing}}(), 
                basesize=Vector{Union{Int64,Missing}}(), n_threads=Int64[], memory=Int64[])
bench_df_file_name = string("pw_cracking_memory_",nthreads(),".csv")

for run in bench_runs
    println("BenchmarkTools run = ", run) 
    if isnothing(run.ex)
        suite = benchmark_brute_force(run.f, run.hash_str)
    else
        suite = benchmark_brute_force(run.f, run.hash_str, ex=run.ex(basesize=run.basesize))
    end
    push!(bench_df, (func=String(Symbol(run.f)), input=run.pw, executor=isnothing(run.ex) ? missing : String(Symbol(run.ex)), basesize=isnothing(run.basesize) ? missing : run.basesize, 
            n_threads=nthreads(), memory=suite.memory))
    CSV.write(bench_df_file_name, bench_df)
end

open(string("pw_craking_task_distribution_",nthreads(),".txt"), "w") do io
    print(io, task_distribution)
end

if length(task_times) != 0
    open(string("pw_craking_task_times_",nthreads(),".txt"), "w") do io
        print(io, task_times)
    end
end