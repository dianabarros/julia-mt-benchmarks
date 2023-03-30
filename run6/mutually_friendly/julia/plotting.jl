using Statistics, DataFrames, CSV

run_number = "run6"
app = "mutually_friendly"
language = "julia"
executor = "ThreadedEx"

logs="memory"
current_path = "$(run_number)/$(app)/$(language)/$(logs)/"
mem_files = readdir(current_path)
mem_logs = Dict(
    "small" => Dict(
        1 => Dict("Julia - Sequential"=> Dict()),
        2 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict()),
        4 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict()),
        8 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict()),
        16 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict())
        ),
    "medium" => Dict(
        1 => Dict("Julia - Sequential"=> Dict()),
        2 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict()),
        4 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict()),
        8 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict()),
        16 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict())
    ),
    "large" => Dict(
        1 => Dict("Julia - Sequential"=> Dict()),
        2 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict()),
        4 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict()),
        8 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict()),
        16 => Dict("Julia - FLoops ($executor)" => Dict(), "Julia - @threads" => Dict()),
    )
)
for file_name in mem_files
    global current_path, mem_logs
    params = split(file_name[1:findfirst(".txt", file_name).start-1],"_")
    size = params[1]
    alg = params[2]
    if alg == "seq"
        func = "Julia - Sequential"
        threads = 1
    else
        threads = parse(Int64,params[3])
        if alg == "mt"
            func = "Julia - @threads"
        else
            func = "Julia - FLoops ($executor)"
        end
    end
    log_it = params[end]
    stats = Dict(
      "Average total size (kbytes)" => "total_size",
      "Maximum resident set size (kbytes)" => "max_rss",
      "Average resident set size (kbytes)" => "avg_rss"  
    )
    open(current_path*file_name, "r") do io
        lines = readlines(io)
        for line in lines
            for key in keys(stats)
                if occursin(key, line)
                    val = parse(Int64,split(line, ": ")[2])
                    if haskey(mem_logs[size][threads][func], stats[key])
                        push!(mem_logs[size][threads][func][stats[key]],val)
                    else
                        mem_logs[size][threads][func][stats[key]] = [val]
                    end
                end
            end
        end
    end
end

mem_logs_df = DataFrame(func=String[], input=String[], n_threads=Int64[], total_size=Int64[], max_rss=Int64[], avg_rss=Int64[])
for size in keys(mem_logs)
    global mem_logs_df
    for n_threads in keys(mem_logs[size])
        for func in keys(mem_logs[size][n_threads])
            if haskey(mem_logs[size][n_threads][func], "max_rss")
                repetitions = length(mem_logs[size][n_threads][func]["max_rss"])
                df = DataFrame(
                    func=repeat([func], repetitions),
                    input=repeat([size], repetitions),
                    n_threads=repeat([n_threads], repetitions),
                    total_size=mem_logs[size][n_threads][func]["total_size"],
                    max_rss=mem_logs[size][n_threads][func]["max_rss"],
                    avg_rss=mem_logs[size][n_threads][func]["avg_rss"]
                    )
                mem_logs_df = vcat(mem_logs_df, df)
            else
                println("No keys found for size $(size), n_threads $(n_threads), func $(func)")
            end
        end
    end
end

mem_metric = "max_rss"
mem_gb = groupby(mem_logs_df, [:func, :input, :n_threads])
mem_df = combine(mem_gb, mem_metric =>  mean, mem_metric=> std)
CSV.write("$(run_number)/$(app)/$(language)/mem_df.csv", mem_df)