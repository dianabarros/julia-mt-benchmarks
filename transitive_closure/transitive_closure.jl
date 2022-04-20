using Base.Threads
using FLoops
using FoldsThreads

mutable struct BenchmarkSample
    task_distribution::Vector{Vector{Int64}}
    suite::Dict{String,Tuple}
    correct_results::Union{Bool,Nothing}
end
BenchmarkSample(task_distribution, suite) = BenchmarkSample(task_distribution, suite, nothing)

c_remainder_lookup = Dict(0=>0x80,
                          1=>0x40, 
                          2=>0x20, 
                          3=>0x10, 
                          4=>0x08, 
                          5=>0x04, 
                          6=>0x02, 
                          7=>0x01)


function BYTE_TO_BINARY(byte) 
    (byte & 0x80 != 0 ? '1' : '0'),
    (byte & 0x40 != 0 ? '1' : '0') ,
    (byte & 0x20 != 0 ? '1' : '0') ,
    (byte & 0x10 != 0 ? '1' : '0') ,
    (byte & 0x08 != 0 ? '1' : '0') ,
    (byte & 0x04 != 0 ? '1' : '0') ,
    (byte & 0x02 != 0 ? '1' : '0') ,
    (byte & 0x01 != 0 ? '1' : '0') 
end

function read_file(file_path::String)
    graph = UInt8[]
    nNodes = undef
    bytes_per_row = undef
    graph = undef
    open(file_path, "r") do file
        for line in eachline(file)
            tokens = split(line, ' ')
            if tokens[1] == "p"
                nNodes = parse(Int, tokens[3])
                bytes_per_row = div((nNodes + 7), 8)
                graph = zeros(UInt8, (nNodes, bytes_per_row))
            elseif tokens[1] == "a"
                r = parse(Int, tokens[2]) - 1
                c = parse(Int, tokens[3]) - 1
                c_int_div = div(c, 8)
                graph[r + 1, c_int_div + 1] = graph[r + 1, c_int_div + 1] | c_remainder_lookup[c%8]
            end
        end
    end
    return nNodes, bytes_per_row, graph
end

function write_graph(nNodes, bytes_per_row, graph)
    for r in 0:nNodes-1
        for j in 0:bytes_per_row-1
            print(BYTE_TO_BINARY(graph[r * bytes_per_row + (j+1)]))
        end
        println()
    end
end

function warshall!(nNodes::Int64, bytes_per_row::Int64, graph::Matrix{UInt8};
    ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing, 
    task_distribution::Union{Vector{Vector{Int64}},Nothing}=nothing,
    suite::Union{Dict{String,Tuple},Nothing}=nothing
    )
    for c in 0:nNodes-1
        c_int_div = div(c,8)
        column_bit = c_remainder_lookup[c%8]
        for r in 0:nNodes-1
            if (r != c && (graph[r+1, c_int_div+1]&column_bit != 0))
                for j in 0:bytes_per_row-1
                    graph[r+1,j+1] = graph[r+1,j+1] | graph[c+1, j+1]
                end
            end
        end
    end
end

function warshall_floops!(nNodes::Int64, bytes_per_row::Int64, graph::Matrix{UInt8};
        ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing, 
        task_distribution::Union{Vector{Vector{Int64}},Nothing}=nothing,
        suite::Union{Dict{String,Tuple},Nothing}=nothing
    )
    for c in 0:nNodes-1
        c_int_div = div(c,8)
        column_bit = c_remainder_lookup[c%8]
        @floop ex for r in 0:nNodes-1
            push!(task_distribution[threadid()], r)
            if (r != c && (graph[r+1, c_int_div+1]&column_bit != 0))
                for j in 0:bytes_per_row-1
                    graph[r+1,j+1] = graph[r+1,j+1] | graph[c+1, j+1]
                end
            end
        end
    end
end

function warshall_threads!(nNodes::Int64, bytes_per_row::Int64, graph::Matrix{UInt8};
        ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing, 
        task_distribution::Union{Vector{Vector{Int64}},Nothing}=nothing,
        suite::Union{Dict{String,Tuple},Nothing}=nothing
    )
    for c in 0:nNodes-1
        c_int_div = div(c,8)
        column_bit = c_remainder_lookup[c%8]
        @threads for r in 0:nNodes-1
            push!(task_distribution[threadid()], r)
            if (r != c && (graph[r+1, c_int_div+1]&column_bit != 0))
                for j in 0:bytes_per_row-1
                    graph[r+1,j+1] = graph[r+1,j+1] | graph[c+1, j+1]
                end
            end
        end
    end
end

function debug(kwargs::NamedTuple{T}) where T
    task_distribution = [Int64[] for _ in 1:nthreads()]
    suite = Dict{String,Tuple}()
    nNodes, bytes_per_row, graph = read_file(kwargs.file_path)
    if haskey(kwargs, :ex)
        ex = kwargs.ex
    else
        ex = nothing
    end
    suite["app"] = @timed kwargs.f(nNodes, bytes_per_row, graph, 
        ex=ex, task_distribution=task_distribution, suite=suite)
    return BenchmarkSample(task_distribution, suite)
end