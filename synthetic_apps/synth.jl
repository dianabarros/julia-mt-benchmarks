using Base.Threads, Statistics, Base.Math
import Dates

#N = 10^2; k = 10^2; n = rand(Float64, N, k);

mutable struct BenchmarkSample{T}
    suite::Dict{T}
end

function unbalanced(N::Int64, k::Int64, n::Array{Float64,2}; suite::T) where T
    store = zeros(Float64, N, k)
    suite["main_loop"]["total_stats"] = @timed begin
        for i in 1:N
            for j in 1:div(k,i)
                for w in 1:50000
                    store[i,j] += hypot(i,j) + (cbrt(n[i,j])/csc(n[i,j]) * w * w) + (cosd(n[i,j])^tanh(n[i,j]) * w)
                end
            end
        end
    end
    return sum(sum(store, dims=2))
end

function unbalanced_mt(N::Int64, k::Int64, n::Array{Float64,2}; suite::T) where T
    store = zeros(Float64, N, k)
    suite["main_loop"]["total_stats"] = @timed begin
        @threads for i in 1:N
            push!(suite["main_loop"]["task_distribution"][threadid()], i)
            threadtime = @timed begin
                for j in 1:div(k,i)
                    for w in 1:50000
                        store[i,j] += hypot(i,j) + (cbrt(n[i,j])/csc(n[i,j]) * w * w) + (cosd(n[i,j])^tanh(n[i,j]) * w)
                    end
                end
            end
            suite["main_loop"]["thread_time"][threadid()] += threadtime.time
        end
    end
    return sum(sum(store, dims=2))
end

function unbalanced_mt(N::Int64, k::Int64, n::Array{Float64,2}, chunksize::Int64; suite::T) where T
    store = zeros(Float64, N, k)
    chunks = Int(ceil(N/chunksize))
    remainder = N % chunksize
    suite["main_loop"]["total_stats"] = @timed begin
        @threads for i in 1:chunks
            threadtime = @timed begin
                for c in 1:(chunksize*i <= N ? chunksize : remainder)
                    push!(suite["main_loop"]["task_distribution"][threadid()], (i-1)*chunksize + c)
                    for j in 1:div(k,i)
                        store[i,j] += hypot(i,j) + (cbrt(n[i,j])/csc(n[i,j]) * w * w) + (cosd(n[i,j])^tanh(n[i,j]) * w)
                    end
                end
            end
            suite["main_loop"]["thread_time"][threadid()] += threadtime.time
        end
    end
    return sum(sum(store, dims=2))
end

function unbalanced_spawn(N::Int64, k::Int64, n::Array{Float64,2}; suite::T) where T
    store = zeros(Float64, N, k)
    # tasktimings = Array{Pair{Dates.DateTime,Dates.DateTime},1}(undef,N)
    suite["main_loop"]["total_stats"] = @timed begin
        @sync for i in 1:N
            Threads.@spawn begin
                # start = Dates.unix2datetime(Dates.time())
                push!(suite["main_loop"]["task_distribution"][threadid()], i)
                threadtime = @timed begin
                    for j in 1:div(k,i)
                        for w in 1:50000
                            store[i,j] += hypot(i,j) + (cbrt(n[i,j])/csc(n[i,j]) * w * w) + (cosd(n[i,j])^tanh(n[i,j]) * w)
                        end
                    end
                end
                suite["main_loop"]["thread_time"][threadid()] += threadtime.time
                # tasktimings[i] = Pair(start ,Dates.unix2datetime(Dates.time()))
            end
        end
    end
    return sum(sum(store, dims=2))
end

function unbalanced_spawn(N::Int64, k::Int64, n::Array{Float64,2}, chunksize::Int64; suite::T) where T
    store = zeros(Float64, N, k)
    #tasktimings = Dict()
    chunks = Int(ceil(N/chunksize))
    remainder = N % chunksize
    suite["main_loop"]["total_stats"] = @timed begin
        @sync for i in 1:chunks
            Threads.@spawn begin
                #start = Dates.unix2datetime(Dates.time())
                threadtime = @timed begin
                    for c in 1:(chunksize*i <= N ? chunksize : remainder)
                        push!(suite["main_loop"]["task_distribution"][threadid()], (i-1)*chunksize + c)
                        for j in 1:div(k,(i-1)*chunksize + c)
                            # sleep(0.01)
                            store[i,j] += hypot(i,j) + (cbrt(n[i,j])/csc(n[i,j]) * w * w) + (cosd(n[i,j])^tanh(n[i,j]) * w)
                        end
                    end
                end
                suite["main_loop"]["thread_time"][threadid()] += threadtime.time
                #tasktimings[i] = Pair(start ,Dates.unix2datetime(Dates.time()))
            end
        end
    end
    return sum(sum(store, dims=2))
end

function balanced(N::Int64, k::Int64, n::Array{Float64,2}; suite::T) where T
    store = zeros(Float64, N, k)
    suite["main_loop"]["total_stats"] = @timed begin
        for i in 1:N
            for j in 1:k
                for w in 1:50000
                    #sleep(2)
                    store[i,j] += hypot(i,j) + (cbrt(n[i,j])/csc(n[i,j]) * w * w) + (cosd(n[i,j])^tanh(n[i,j]) * w)
                end
            end
        end
    end
    return sum(sum(store, dims=2))
end

function balanced_mt(N::Int64, k::Int64, n::Array{Float64,2}; suite::T) where T
    store = zeros(Float64, N, k)
    # tasktimings = zeros(N)
    suite["main_loop"]["total_stats"] = @timed begin
        @threads for i in 1:N
            push!(suite["main_loop"]["task_distribution"][threadid()], i)
            threadtime = @timed begin
                for j in 1:k
                    #sleep(0.01)
                    for w in 1:50000
                        store[i,j] += hypot(i,j) + (cbrt(n[i,j])/csc(n[i,j]) * w * w) + (cosd(n[i,j])^tanh(n[i,j]) * w)
                    end
                end
            end
            suite["main_loop"]["thread_time"][threadid()] += threadtime.time
        # tasktimings[i]+= threadtime[2]
        end
    end
    #return ((time[2], times),)
    return sum(sum(store, dims=2))
end

function balanced_mt(N::Int64, k::Int64, n::Array{Float64,2}, chunksize::Int64; suite::T) where T
    store = zeros(Float64, N, k)
    chunks = Int(ceil(N/chunksize))
    remainder = N % chunksize
    suite["main_loop"]["total_stats"] = @timed begin
        @threads for i in 1:chunks
            threadtime = @timed begin
                for c in 1:(chunksize*i <= N ? chunksize : remainder)
                    push!(suite["main_loop"]["task_distribution"][threadid()], (i-1)*chunksize + c)
                    for j in 1:k
                        # sleep(0.01)
                        store[i,j] += hypot(i,j) + (cbrt(n[i,j])/csc(n[i,j]) * w * w) + (cosd(n[i,j])^tanh(n[i,j]) * w)
                    end
                end
            end
            suite["main_loop"]["thread_time"][threadid()] += threadtime[2]
        end
    end
    return sum(sum(store, dims=2))
end

function balanced_spawn(N::Int64, k::Int64, n::Array{Float64,2}; suite::T) where T
    store = zeros(Float64, N, k)
    # tasktimings = zeros(N)
    # tasks = Array{Task,1}(undef,N)
    suite["main_loop"]["total_stats"] = @timed begin
        @sync for i in 1:N
        # for i in 1:N
            # tasks[i] = Threads.@spawn begin
            Threads.@spawn begin
                push!(suite["main_loop"]["task_distribution"][threadid()], i)
                threadtime = @timed begin
                    for j in 1:k
                        #sleep(20)
                        for w in 1:50000
                            store[i,j] += hypot(i,j) + (cbrt(n[i,j])/csc(n[i,j]) * w * w) + (cosd(n[i,j])^tanh(n[i,j]) * w)
                        end
                    end
                end
                suite["main_loop"]["thread_time"][threadid()] += threadtime.time
                # tasktimings[i] += threadtime[2]
            end
        end
        # for task in tasks
        #     wait(task)
        # end
    end
    return sum(sum(store, dims=2))
end

function balanced_spawn(N::Int64, k::Int64, n::Array{Float64,2}, chunksize::Int64; suite::T) where T
    store = zeros(Float64, N, k)
    #tasktimings = Dict()
    chunks = Int(ceil(N/chunksize))
    remainder = N % chunksize
    suite["main_loop"]["total_stats"] = @timed begin
        @sync for i in 1:chunks
            Threads.@spawn begin
                #start = Dates.unix2datetime(Dates.time())
                threadtime = @timed begin
                    for c in 1:(chunksize*i <= N ? chunksize : remainder)
                        push!(suite["main_loop"]["task_distribution"][threadid()], (i-1)*chunksize + c)
                        for j in 1:k
                            #sleep(2)
                            store[i,j] += hypot(i,j) + (cbrt(n[i,j])/csc(n[i,j]) * w * w) + (cosd(n[i,j])^tanh(n[i,j]) * w)
                        end
                    end
                end
                suite["main_loop"]["thread_time"][threadid()] += threadtime.time
                #tasktimings[i] = Pair(start ,Dates.unix2datetime(Dates.time()))
            end
        end
    end
    return sum(sum(store, dims=2))
end

function debug(f::T, N::Int64, k::Int64, n::Array{Float64,2}) where T
    suite = Dict(
        "main_loop" => Dict(
            "total_stats" => UndefInitializer(),
            "task_distribution" => [Int64[] for _ in 1:nthreads()],
            "thread_time" => zeros(Float64, nthreads())
        ),
        "app" => UndefInitializer()
    )
    suite["app"] = @timed f(N, k, n, suite=suite)
    return BenchmarkSample(suite)
end