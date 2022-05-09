using FoldsThreads
using FLoops
using Base.Threads

mutable struct BenchmarkSample
    task_distribution::Vector{Vector{Int64}}
    suite::Dict{String,NamedTuple}
    correct_results::Union{Bool,Nothing}
end
BenchmarkSample(task_distribution, suite) = BenchmarkSample(task_distribution, suite, nothing)

function gcd(u::Int64, v::Int64)
    if(v == 0)
        return u
    end
    return gcd(v, u % v)
end

function friendly_numbers(
        start::Int64, stop::Int64
    ) where T
    last = stop - start + 1
    the_num = zeros(Int64, last)
    num = zeros(Int64, last)
    den = zeros(Int64, last)
    result_a = zeros(Int64, last)
    result_b = zeros(Int64, last)
    for i in start:stop
        ii = i - start
        sum = 1 + i
        the_num[ii+1] = i
        done = i
        factor = 2

        while (factor < done)
            if i % factor == 0
                sum += factor + div(i, factor)
                done = div(i, factor) 
                if done == factor
                    sum -= factor
                end
            end
            factor += 1
        end
        num[ii+1] = sum
        den[ii+1] = i
        n = gcd(num[ii+1], den[ii+1])
        num[ii+1] = div(num[ii+1], n)
        den[ii+1] = div(den[ii+1], n)
    end
    n_result = 0
    for i in 0:last-1
        for j in i+1:last-1
            if num[i+1] == num[j+1] && den[i+1] == den[j+1]
                result_a[n_result+1] = the_num[i+1]
                result_b[n_result+1] = the_num[j+1]
                n_result += 1
            end
        end
    end
    return result_a, result_b
end

function friendly_numbers_floop(start::Int64, stop::Int64, ex::FoldsThreads.FoldsBase.Executor)
    last = stop - start + 1
    the_num = zeros(Int64, last)
    num = zeros(Int64, last)
    den = zeros(Int64, last)
    result_a = zeros(Int64, last)
    result_b = zeros(Int64, last)
    @floop ex for i in start:stop
        global thread_tasks
        push!(thread_tasks[threadid()], i)
        ii = i - start
        sum = 1 + i
        the_num[ii+1] = i
        done = i
        factor = 2

        while (factor < done)
            if i % factor == 0
                sum += factor + div(i, factor)
                done = div(i, factor) 
                if done == factor
                    sum -= factor
                end
            end
            factor += 1
        end
        num[ii+1] = sum
        den[ii+1] = i
        n = gcd(num[ii+1], den[ii+1])
        num[ii+1] = div(num[ii+1], n)
        den[ii+1] = div(den[ii+1], n)
    end
    n_result = 0
    for i in 0:last-1
        for j in i+1:last-1
            if num[i+1] == num[j+1] && den[i+1] == den[j+1]
                result_a[n_result+1] = the_num[i+1]
                result_b[n_result+1] = the_num[j+1]
                n_result += 1
            end
        end
    end
    return result_a, result_b
end

function friendly_numbers_threads(start::Int64, stop::Int64, ex::FoldsThreads.FoldsBase.Executor)
    last = stop - start + 1
    the_num = zeros(Int64, last)
    num = zeros(Int64, last)
    den = zeros(Int64, last)
    result_a = zeros(Int64, last)
    result_b = zeros(Int64, last)
    @threads for i in start:stop
        global thread_tasks
        push!(thread_tasks[threadid()], i)
        ii = i - start
        sum = 1 + i
        the_num[ii+1] = i
        done = i
        factor = 2

        while (factor < done)
            if i % factor == 0
                sum += factor + div(i, factor)
                done = div(i, factor) 
                if done == factor
                    sum -= factor
                end
            end
            factor += 1
        end
        num[ii+1] = sum
        den[ii+1] = i
        n = gcd(num[ii+1], den[ii+1])
        num[ii+1] = div(num[ii+1], n)
        den[ii+1] = div(den[ii+1], n)
    end
    n_result = 0
    for i in 0:last-1
        for j in i+1:last-1
            if num[i+1] == num[j+1] && den[i+1] == den[j+1]
                result_a[n_result+1] = the_num[i+1]
                result_b[n_result+1] = the_num[j+1]
                n_result += 1
            end
        end
    end
    return result_a, result_b
end

function debug_friendly_numbers(
    start::Int64, stop::Int64; ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing, 
    task_distribution::Union{Vector{Vector{Int64}},Nothing}=nothing,
    suite::Union{Dict{T},Nothing}=nothing
) where T
last = stop - start + 1
the_num = zeros(Int64, last)
num = zeros(Int64, last)
den = zeros(Int64, last)
result_a = zeros(Int64, last)
result_b = zeros(Int64, last)
for i in start:stop
    ii = i - start
    sum = 1 + i
    the_num[ii+1] = i
    done = i
    factor = 2

    while (factor < done)
        if i % factor == 0
            sum += factor + div(i, factor)
            done = div(i, factor) 
            if done == factor
                sum -= factor
            end
        end
        factor += 1
    end
    num[ii+1] = sum
    den[ii+1] = i
    n = gcd(num[ii+1], den[ii+1])
    num[ii+1] = div(num[ii+1], n)
    den[ii+1] = div(den[ii+1], n)
end
n_result = 0
for i in 0:last-1
    for j in i+1:last-1
        if num[i+1] == num[j+1] && den[i+1] == den[j+1]
            result_a[n_result+1] = the_num[i+1]
            result_b[n_result+1] = the_num[j+1]
            n_result += 1
        end
    end
end
return result_a, result_b
end

function debug_friendly_numbers_floop(
        start::Int64, stop::Int64; ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing, 
        task_distribution::Union{Vector{Vector{Int64}},Nothing}=nothing,
        suite::Union{Dict{T},Nothing}=nothing
    ) where T
    last = stop - start + 1
    the_num = zeros(Int64, last)
    num = zeros(Int64, last)
    den = zeros(Int64, last)
    result_a = zeros(Int64, last)
    result_b = zeros(Int64, last)
    suite["loop"] = @timed begin
        @floop ex for i in start:stop
            push!(task_distribution[threadid()], i) 
            ii = i - start
            sum = 1 + i
            the_num[ii+1] = i
            done = i
            factor = 2

            while (factor < done)
                if i % factor == 0
                    sum += factor + div(i, factor)
                    done = div(i, factor) 
                    if done == factor
                        sum -= factor
                    end
                end
                factor += 1
            end
            num[ii+1] = sum
            den[ii+1] = i
            n = gcd(num[ii+1], den[ii+1])
            num[ii+1] = div(num[ii+1], n)
            den[ii+1] = div(den[ii+1], n)
        end
    end
    n_result = 0
    for i in 0:last-1
        for j in i+1:last-1
            if num[i+1] == num[j+1] && den[i+1] == den[j+1]
                result_a[n_result+1] = the_num[i+1]
                result_b[n_result+1] = the_num[j+1]
                n_result += 1
            end
        end
    end
    return result_a, result_b
end

function debug_friendly_numbers_threads(
        start::Int64, stop::Int64;ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing, 
        task_distribution::Union{Vector{Vector{Int64}},Nothing}=nothing,
        suite::Union{Dict{T},Nothing}=nothing
    ) where T
    last = stop - start + 1
    the_num = zeros(Int64, last)
    num = zeros(Int64, last)
    den = zeros(Int64, last)
    result_a = zeros(Int64, last)
    result_b = zeros(Int64, last)
    suite["loop"] = @timed begin
        @threads for i in start:stop
            push!(task_distribution[threadid()], i)
            ii = i - start
            sum = 1 + i
            the_num[ii+1] = i
            done = i
            factor = 2

            while (factor < done)
                if i % factor == 0
                    sum += factor + div(i, factor)
                    done = div(i, factor) 
                    if done == factor
                        sum -= factor
                    end
                end
                factor += 1
            end
            num[ii+1] = sum
            den[ii+1] = i
            n = gcd(num[ii+1], den[ii+1])
            num[ii+1] = div(num[ii+1], n)
            den[ii+1] = div(den[ii+1], n)
        end
    end
    n_result = 0
    for i in 0:last-1
        for j in i+1:last-1
            if num[i+1] == num[j+1] && den[i+1] == den[j+1]
                result_a[n_result+1] = the_num[i+1]
                result_b[n_result+1] = the_num[j+1]
                n_result += 1
            end
        end
    end
    return result_a, result_b
end



function debug(f::T, start::Int64, stop::Int64;
        ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing, 
        check_sequential::Union{Bool,Nothing}=nothing
    ) where T
    task_distribution = [Int64[] for _ in 1:nthreads()]
    suite = Dict()
    suite["app"] = @timed f(start, stop, ex=ex, task_distribution=task_distribution, suite=suite)
    correct_results = nothing
    if !isnothing(check_sequential) && check_sequential
        correct_results = friendly_numbers(start, stop) == suite["app"][1]
    end
    return BenchmarkSample(task_distribution, suite, correct_results)
end