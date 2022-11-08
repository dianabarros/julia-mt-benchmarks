using DataFrames, CSV, VegaLite
using Statistics

app = "transitive_closure"

# df = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/run2/$(app)/$(app)_results_2.csv"))
# i = 4
# while i <= 16
#     temp = DataFrame(CSV.File("/Users/diana.barros/Documents/julia-mt-benchmarks/run2/$(app)/$(app)_results_$i.csv"))
#     df = vcat(df,temp)
#     i = i*2
# end

df = nothing
for (root, dirs, files) in walkdir(".")
    for file in files
        if !occursin(".jl", file)
            if isnothing(df)
                df = DataFrame(CSV.File(joinpath(root, file)))
            else
                temp = DataFrame(CSV.File(joinpath(root, file)))
                df = vcat(df,temp)
            end
        end
    end
end

# transitive_closure
# 1- Reduce to mean for each execution+input+nthreads(+executor+basesize)
# 2- Speedup floops
# 3- Speedup of Best floops Speedup and the others

gb = groupby(df, [:func, :executor, :basesize, :input, :n_threads])
count_df = combine(gb, :func => length => :count)
CSV.write("count_floops.csv", count_df)
df = combine(gb, 
    [:total_bytes, :total_time] .=>  mean, [:total_bytes, :total_time] .=> std)
CSV.write("mean_floops.csv", df)

floop_df = df[df.func .== "warshall_floops!", :]

seq_time_df = df[df.func .==  "warshall!", [:input, :n_threads, :total_time_mean]]

floop_seq_df = innerjoin(floop_df, seq_time_df, on=[:input, :n_threads], renamecols= "_floop" => "_seq")
floop_seq_df = hcat(floop_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(floop_seq_df,1))))

floop_speedup = select(floop_seq_df, :, [:total_time_mean_floop, :total_time_mean_seq] => ((total_time_mean_floop, total_time_mean_seq) -> (total_time_mean_seq./total_time_mean_floop)) => :speedup)

# Comparing executors from FLoops
floop_speedup_plot = floop_speedup |>
    @vlplot(
        mark={:line, clip=true},
        x="n_threads:q",
        y={:speedup},
        color=:executor_floop,
        column=:input)
        # width=300, height=200)

floop_speedup_plot |> save("run2/password_cracking/floop_speedup_plot.png")

mt_df = vcat(floop_df[floop_df.executor .== "DepthFirstEx",:], df[df.func .== "warshall_threads!", :])
mt_seq_df = innerjoin(mt_df, seq_time_df, on=[:input, :n_threads], renamecols= "_mt" => "_seq")
mt_seq_df = hcat(mt_seq_df, DataFrame(speedup=Vector{Union{Missing, Float64}}(missing,size(mt_seq_df,1))))

mt_speedup = select(mt_seq_df, :, [:total_time_mean_mt, :total_time_mean_seq] => ((total_time_mean_mt, total_time_mean_seq) -> (total_time_mean_seq./total_time_mean_mt)) => :speedup)

# Comparing native and FLoops with DepthFirstEx
mt_speedup_plot = mt_speedup |>
    @vlplot(
        mark={:line, clip=true},
        x="n_threads:q",
        y={:speedup},
        color=:func_mt,
        column=:input)
        # width=300, height=200)

mt_speedup_plot |> save("run2/$(app)/mt_speedup_plot.png")