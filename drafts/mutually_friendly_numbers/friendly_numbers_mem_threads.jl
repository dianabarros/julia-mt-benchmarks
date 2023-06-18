using Pkg
Pkg.activate("../../mutually_friendly_numbers")

import Profile

using Base.Threads

function gcd(u::Int64, v::Int64)
    if(v == 0)
        return u
    end
    return gcd(v, u % v)
end

function friendly_numbers_threads(start::Int64, stop::Int64, suite::Dict{T}) where T
    last = stop - start + 1
    the_num = zeros(Int64, last)
    num = zeros(Int64, last)
    den = zeros(Int64, last)
    result_a = zeros(Int64, last)
    result_b = zeros(Int64, last)
    @threads for i in start:stop
        push!(suite["task_distribution"][threadid()], i)
        thread_stats = @timed begin
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
        suite["thread_time"][threadid()] += thread_stats.time
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

# start = parse(Int64,ARGS[1])
# stop = parse(Int64, ARGS[2])
# friendly_numbers_threads(start, stop)

# Profile.clear_malloc_data()
# friendly_numbers_threads(0, 50000)