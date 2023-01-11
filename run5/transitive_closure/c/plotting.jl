using Statistics, DataFrames

run_number = "run5"
app = "transitive_closure"
language = "c"

loop_time = Dict()

function load_logs(run_number, app, language, logs, instance)
    d = Dict()
    open("$(run_number)/$(app)/$(language)/$(logs)/$(instance)_seq.txt","r") do io
        global instance_times
        instance_times = readlines(io)
        instance_times = parse.(Float64, instance_times) 
    end
    d[1] = copy(instance_times)
    i = 2
    while i <= 16
        open("$(run_number)/$(app)/$(language)/$(logs)/$(instance)_mt_$(i).txt","r") do io
            global instance_times
            instance_times = readlines(io)
            instance_times = parse.(Float64, instance_times) 
        end
        d[i] = copy(instance_times)
        i = i*2
    end
    return d
end

# LOOP TIME
logs = "time_logs"
instances = ["small", "medium", "large"]
for instance in instances
    global loop_time
    loop_time[instance] = load_logs(run_number, app, language, logs, instance)
end

# FULL TIME == LOOP TIME

# MEM LOGS
logs="mem_logs"
current_path = "$(run_number)/$(app)/$(language)/$(logs)/"
mem_files = readdir(current_path)
mem_logs = Dict(
    "small" => Dict(
        1 => Dict(),
        2 => Dict(),
        4 => Dict(),
        8 => Dict(),
        16 => Dict()
        ),
    "medium" => Dict(
        1 => Dict(),
        2 => Dict(),
        4 => Dict(),
        8 => Dict(),
        16 => Dict()
    ),
    "large" => Dict(
        1 => Dict(),
        2 => Dict(),
        4 => Dict(),
        8 => Dict(),
        16 => Dict()
    )
)
for file_name in mem_files
    global current_path, mem_logs
    params = split(file_name[1:findfirst(".txt", file_name).start-1],"_")
    size = params[1]
    alg = params[2]
    if alg == "seq"
        threads = 1
    else
        threads = parse(Int64,params[3])
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
                    if haskey(mem_logs[size][threads], stats[key])
                        push!(mem_logs[size][threads][stats[key]],val)
                    else
                        mem_logs[size][threads][stats[key]] = [val]
                    end
                end
            end
        end
    end
end

loop_time_df = DataFrame(func=String[], input=String[], n_threads=Int64[], time=Float64[])
for size in keys(loop_time)
    global loop_time_df
    for n_threads in keys(loop_time[size])
        repetitions = length(loop_time[size][n_threads])
        df = DataFrame(
            func=repeat([app], repetitions),
            input=repeat([size], repetitions),
            n_threads=repeat([n_threads], repetitions),
            time=loop_time[size][n_threads]
            )
        loop_time_df = vcat(loop_time_df, df)
    end
end

mem_logs_df = DataFrame(func=String[], input=String[], n_threads=Int64[], total_size=Int64[], max_rss=Int64[], avg_rss=Int64[])
for size in keys(mem_logs)
    global mem_logs_df
    for n_threads in keys(mem_logs[size])
        repetitions = length(mem_logs[size][n_threads]["max_rss"])
        df = DataFrame(
            func=repeat([app], repetitions),
            input=repeat([size], repetitions),
            n_threads=repeat([n_threads], repetitions),
            total_size=mem_logs[size][n_threads]["total_size"],
            max_rss=mem_logs[size][n_threads]["max_rss"],
            avg_rss=mem_logs[size][n_threads]["avg_rss"]
            )
        mem_logs_df = vcat(mem_logs_df, df)
    end
end