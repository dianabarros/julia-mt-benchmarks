using FoldsThreads
using FLoops
using Base.Threads

thread_tasks = [Int64[] for _ in 1:nthreads()]

function gcd(u::Int64, v::Int64)
    if(v == 0)
        return u
    end
    return gcd(v, u % v)
end

function friendly_numbers(start::Int64, stop::Int64)
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

function friendly_numbers_parallel(start::Int64, stop::Int64)
    last = stop - start + 1
    the_num = zeros(Int64, last)
    num = zeros(Int64, last)
    den = zeros(Int64, last)
    result_a = zeros(Int64, last)
    result_b = zeros(Int64, last)
    @floop WorkStealingEx(basesize = 2) for i in start:stop
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

function main()
    start = 0
    stop = 10
    friendly_numbers(start, stop) == friendly_numbers_parallel(start, stop)
end