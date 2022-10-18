import Pkg
Pkg.activate("linked_list")

using ArgParse 
using DataFrames, CSV, Statistics

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

include("linked_list.jl")

inputs = Dict(
    "small" => (N=10^3, FS=50),
    "medium" => (N=10^4, FS=50),
    "large" => (N=10^5, FS=50)
)
if !isnothing(args["inputs"])
    arg_inputs = Dict()
    for size in eval(Meta.parse(args["inputs"]))
        arg_inputs[size] = inputs[size]
    end
    inputs = arg_inputs
end

funcs = [linked, linked_for, linked_task]
if !isnothing(args["funcs"])
    funcs = eval(Meta.parse(args["funcs"]))
end

iterations = args["its"]
check_sequential = args["check_sequential"]

println("Preparing runs")
runs = []
for (size, args) in inputs
    for func in funcs
        run = (f=func, size=size, N=args.N, FS=args.FS)
        push!(runs, run)
    end
end

println("Running compile runs")
debug(linked, 10, 50)
debug(linked_for, 10, 50)
debug(linked_task, 10, 50)

df = DataFrame(iteration = Int64[],func=String[], input=String[], n_threads=Int64[],
    main_loop_time=Float64[]
)
df_file_name = string("linked_list_",nthreads(),".csv")

println("Running...")
for run in runs
    for it in 1:iterations
        println("run = ", run) 
        bench_sample = debug(
            run.f, run.N, run.FS)
        push!(df, (iteration=it, func=String(Symbol(run.f)), input=run.size, n_threads=nthreads(),
            main_loop_time=bench_sample.suite["main_loop"]["total_stats"].time))
        CSV.write(df_file_name, df)
    end
end

# df |>
#        @vlplot(
#            :bar,
#            x={"func:n", title="Scheduling", axis=false, sort=["Sequential", "Static", "Dynamic"]},
#            y={"time:q", scale={type="log",base=20}, axis={grid=false}, title="Time (s)"},
#            column={"size:n", title="Size",sort=["Small","Medium","Large"]},
#                config={
#                view={stroke=:transparent},
#                axis={domainWidth=1},
#            },
#            color={"func:n", title="Scheduling", scale={range=["#e7ba52","#1f77b4","#9467bd"]}, sort=["Sequential", "Static", "Dynamic"]}
#            )



# df |>
#               @vlplot(
#                   :bar,
#                   title={text="Linked List Execution Times", anchor="middle", fontSize=20},
#                   x={"func:n", title="Scheduling", axis=false, sort=["Static", "Dynamic"]},
#                   y={"time:q", scale={type="log",base=20}, axis={grid=false, titleFontSize=14}, title="Time (s)"},
#                   column={"size:n",
#                           title="Size",
#                           sort=["Small","Medium","Large"],
#                           header={labelOrient="bottom", titleOrient="bottom", titleFontSize=14, labelFontSize=12}
#                    },
#                   config={
#                       view={stroke=:transparent},
#                       axis={domainWidth=1},
#                   },
#                   color={"func:n",
#                          title="Scheduling",
#                          axis={titleFontSize=14},
#                          scale={range=["#e7ba52","#1f77b4","#9467bd"]},
#                          sort=["Static", "Dynamic"],
#                          legend={titleFontSize=14,
#                                  labelFontSize=12
#                          }
#                    },
#                   width=70,
#                   height=190
#                   )