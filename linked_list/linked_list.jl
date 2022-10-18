using Base.Threads
using BenchmarkTools, DataFrames, CSV, Dates

const benchmark_samples = 10
const benchmark_evals = 1

mutable struct BenchmarkSample{T}
    suite::Dict{T}
end

mutable struct Node
    data::Int64
    fibdata::Int64
    next::Union{Node, Nothing}
end

function fib(n::Int64)
    if n < 2
        return n
    else
        x = fib(n - 1)
        y = fib(n - 2)
        return x + y
    end
end

function fib_loop(n::Int64)
    n1 = 0
    n2 = 1
    count = 0
    if n > 1
        while count < n
            nth = n1 + n2
            n1 = n2
            n2 = nth
            count += 1
        end
    end
    return n1
end

function processwork(p::Node)
    p.fibdata = fib_loop(p.data)
end
    
function init_list(N::Int64, FS::Int64)
    head = Node(FS, 1, nothing)
    tmp = head
    for i in 1:N-1
        node = Node(FS + i*10, i, nothing)
        tmp.next = node
        tmp = node
    end
    return head
end

function print_list_for(vec_aux::Vector{Node}, N::Int64)
    for i in 1:N
        println("data: ", vec_aux[i].data, " - fibdata: ", vec_aux[i].fibdata)
    end
end

function for_loop(vec_aux::Vector{Node}, N::Int64)
    @threads for i in 1:N
        processwork(vec_aux[i])
    end
end

function linked_for(N::Int64, FS::Int64, suite::T) where T
    p = init_list(N, FS)
    vec_aux = Array{Node,1}(undef,N)
    for i in 1:N
        vec_aux[i] = p
        p = p.next
    end
    # benchmarks = @benchmark for_loop($vec_aux, $N) samples=benchmark_samples evals=benchmark_evals
    suite["main_loop"]["total_stats"] = (@timed for_loop(vec_aux, N))
    #print_list_for(vec_aux, N)
    # return benchmarks
end

function print_list_tasks(p::Node)
    while !isnothing(p)
        println("data: ", p.data, " - fibdata: ", p.fibdata)
        p = p.next
    end
end

function task_loop(p::Node)
    tmp = p
    @sync while !isnothing(tmp)
        pp = tmp
        Threads.@spawn processwork(pp)
        tmp = tmp.next
    end
end

function linked_task(N::Int64, FS::Int64, suite::T) where T
    head = init_list(N, FS)
    p = head
    # benchmarks = @benchmark task_loop($p) samples=benchmark_samples evals=benchmark_evals
    suite["main_loop"]["total_stats"] = (@timed task_loop(p))
    p = head
    # print_list_tasks(p)
    # return benchmarks
end

function seq_loop(p::Node)
    while !isnothing(p)
        processwork(p)
        p = p.next
    end
end

function linked(N::Int64, FS::Int64, suite::T) where T
    head = init_list(N, FS)
    p = head
    # benchmarks = @benchmark seq_loop($p) samples=benchmark_samples evals=benchmark_evals
    suite["main_loop"]["total_stats"] = (@timed seq_loop(p))
    p = head
    # return benchmarks
end

function debug(f::T, N::Int64, FS::Int64) where T
    suite = Dict(
        "main_loop" => Dict{Any,Any}(
            "total_stats" => nothing
        )
    )
    f(N, FS, suite)
    return BenchmarkSample(suite)
end
