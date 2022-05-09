using MD5
using FoldsThreads
using FLoops
using Base.Threads

mutable struct BenchmarkSample
    loop_tasks::Vector{Vector{Vector{Int64}}}
    suite::Dict{String,NamedTuple}
    correct_results::Union{Bool,Nothing}
end
BenchmarkSample(loop_tasks, suite) = BenchmarkSample(loop_tasks, suite, nothing)

letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

thread_tasks = [String[] for _ in 1:nthreads()]

function brute_force(hash1, str, i, n)
    global letters
    if i == n + 1
        hash2 = md5(String(str))
        return hash1 == hash2
    end
    for letter in letters 
        str[i] = letter 
        if brute_force(hash1, str, i + 1, n)
            return true
        end
    end
    return false
end

function brute_force(hash1::Vector{UInt8})
    found = nothing
    for letter in letters if isnothing(found)
        local_str = fill('\0',1)
        local_str[1] = letter
        hash2 = md5(String(local_str))
        if hash1 == hash2
            found = String(local_str)
            break
        end
    end end

    if isnothing(found)
        for letter in letters if isnothing(found)
            local_str = fill('\0',2)
            local_str[1] = letter
            for letter in letters
                local_str[2] = letter
                hash2 = md5(String(local_str))
                if hash1 == hash2
                    found = String(local_str)
                    break
                end
            end
        end end   
    end

    if isnothing(found)
        for letter in letters if isnothing(found)
            local_str = fill('\0',3)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters
                    local_str[3] = letter
                    hash2 = md5(String(local_str))
                    if hash1 == hash2
                        found = String(local_str)
                        break
                    end
                end
            end end
        end end
    end

    if isnothing(found)
        for letter in letters if isnothing(found)
            local_str = fill('\0',4)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters if isnothing(found)
                    local_str[3] = letter
                    for letter in letters
                        local_str[4] = letter
                        hash2 = md5(String(local_str))
                        if hash1 == hash2
                            found = String(local_str)
                            break
                        end
                    end
                end end
            end end
        end end
    end

    if isnothing(found)
        for letter in letters if isnothing(found)
            local_str = fill('\0',5)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters if isnothing(found)
                    local_str[3] = letter
                    for letter in letters if isnothing(found)
                        local_str[4] = letter
                        for letter in letters
                            local_str[5] = letter
                            hash2 = md5(String(local_str))
                            if hash1 == hash2
                                found = String(local_str)
                                break
                            end
                        end
                    end end
                end end
            end end
        end end
    end

    if isnothing(found)
        for letter in letters if isnothing(found)
            local_str = fill('\0',6)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters if isnothing(found)
                    local_str[3] = letter
                    for letter in letters if isnothing(found)
                        local_str[4] = letter
                        for letter in letters if isnothing(found)
                            local_str[5] = letter
                            for letter in letters
                                local_str[6] = letter
                                hash2 = md5(String(local_str))
                                if hash1 == hash2
                                    found = String(local_str)
                                    break
                                end
                            end
                        end end
                    end end
                end end
            end end
        end end
    end

    if isnothing(found)
        for letter in letters if isnothing(found)
            local_str = fill('\0',7)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters if isnothing(found)
                    local_str[3] = letter
                    for letter in letters if isnothing(found)
                        local_str[4] = letter
                        for letter in letters if isnothing(found)
                            local_str[5] = letter
                            for letter in letters if isnothing(found)
                                local_str[6] = letter
                                for letter in letters
                                    local_str[7] = letter
                                    hash2 = md5(String(local_str))
                                    if hash1 == hash2
                                        found = String(local_str)
                                        break
                                    end
                                end
                            end end
                        end end
                    end end
                end end
            end end
        end end
    end

    if isnothing(found)
        for letter in letters if isnothing(found)
            local_str = fill('\0',8)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters if isnothing(found)
                    local_str[3] = letter
                    for letter in letters if isnothing(found)
                        local_str[4] = letter
                        for letter in letters if isnothing(found)
                            local_str[5] = letter
                            for letter in letters if isnothing(found)
                                local_str[6] = letter
                                for letter in letters if isnothing(found)
                                    local_str[7] = letter
                                    for letter in letters
                                        local_str[8] = letter
                                        hash2 = md5(String(local_str))
                                        if hash1 == hash2
                                            found = String(local_str)
                                            break
                                        end
                                    end
                                end end
                            end end
                        end end
                    end end
                end end
            end end
        end end
    end
    return found
end

function debug_brute_force(
    hash1::Vector{UInt8}; ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing,
    loop_tasks::Union{Vector{Vector{Vector{Int64}}},Nothing}=nothing,
    suite::Union{Dict{String,NamedTuple},Nothing}
    )
    found = nothing
    suite["loop_1"] = @timed begin
        for letter in letters if isnothing(found)
            local_str = fill('\0',1)
            local_str[1] = letter
            hash2 = md5(String(local_str))
            if hash1 == hash2
                found = String(local_str)
                break
            end
        end end
    end

    suite["loop_2"] = @timed begin
        if isnothing(found)
            for letter in letters if isnothing(found)
                local_str = fill('\0',2)
                local_str[1] = letter
                for letter in letters
                    local_str[2] = letter
                    hash2 = md5(String(local_str))
                    if hash1 == hash2
                        found = String(local_str)
                        break
                    end
                end
            end end   
        end
    end

    suite["loop_3"] = @timed begin
        if isnothing(found)
            for letter in letters if isnothing(found)
                local_str = fill('\0',3)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters
                        local_str[3] = letter
                        hash2 = md5(String(local_str))
                        if hash1 == hash2
                            found = String(local_str)
                            break
                        end
                    end
                end end
            end end
        end
    end

    suite["loop_4"] = @timed begin
        if isnothing(found)
            for letter in letters if isnothing(found)
                local_str = fill('\0',4)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters
                            local_str[4] = letter
                            hash2 = md5(String(local_str))
                            if hash1 == hash2
                                found = String(local_str)
                                break
                            end
                        end
                    end end
                end end
            end end
        end
    end

    suite["loop_5"] = @timed begin
        if isnothing(found)
            for letter in letters if isnothing(found)
                local_str = fill('\0',5)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters
                                local_str[5] = letter
                                hash2 = md5(String(local_str))
                                if hash1 == hash2
                                    found = String(local_str)
                                    break
                                end
                            end
                        end end
                    end end
                end end
            end end
        end
    end

    suite["loop_6"] = @timed begin
        if isnothing(found)
            for letter in letters if isnothing(found)
                local_str = fill('\0',6)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters if isnothing(found)
                                local_str[5] = letter
                                for letter in letters
                                    local_str[6] = letter
                                    hash2 = md5(String(local_str))
                                    if hash1 == hash2
                                        found = String(local_str)
                                        break
                                    end
                                end
                            end end
                        end end
                    end end
                end end
            end end
        end
    end

    suite["loop_7"] = @timed begin
        if isnothing(found)
            for letter in letters if isnothing(found)
                local_str = fill('\0',7)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters if isnothing(found)
                                local_str[5] = letter
                                for letter in letters if isnothing(found)
                                    local_str[6] = letter
                                    for letter in letters
                                        local_str[7] = letter
                                        hash2 = md5(String(local_str))
                                        if hash1 == hash2
                                            found = String(local_str)
                                            break
                                        end
                                    end
                                end end
                            end end
                        end end
                    end end
                end end
            end end
        end
    end

    suite["loop_8"] = @timed begin
        if isnothing(found)
            for letter in letters if isnothing(found)
                local_str = fill('\0',8)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters if isnothing(found)
                                local_str[5] = letter
                                for letter in letters if isnothing(found)
                                    local_str[6] = letter
                                    for letter in letters if isnothing(found)
                                        local_str[7] = letter
                                        for letter in letters
                                            local_str[8] = letter
                                            hash2 = md5(String(local_str))
                                            if hash1 == hash2
                                                found = String(local_str)
                                                break
                                            end
                                        end
                                    end end
                                end end
                            end end
                        end end
                    end end
                end end
            end end
        end
    end
    return found
end

function brute_force_parallel(hash1::Vector{UInt8}, ex::FoldsThreads.FoldsBase.Executor)
    lk = ReentrantLock()
    found = nothing
    @floop ex for letter in letters if isnothing(found)
        local_str = fill('\0',1)
        local_str[1] = letter
        hash2 = md5(String(local_str))
        if hash1 == hash2
            lock(lk) do
                found = String(local_str)
            end
            break
        end
    end end

    if isnothing(found)
        @floop ex for letter in letters if isnothing(found)
            local_str = fill('\0',2)
            local_str[1] = letter
            for letter in letters
                local_str[2] = letter
                hash2 = md5(String(local_str))
                if hash1 == hash2
                    lock(lk) do
                        found = String(local_str)
                    end
                    break
                end
            end
        end end   
    end

    if isnothing(found)
        @floop ex for letter in letters if isnothing(found)
            local_str = fill('\0',3)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters
                    local_str[3] = letter
                    hash2 = md5(String(local_str))
                    if hash1 == hash2
                        lock(lk) do
                            found = String(local_str)
                        end
                        break
                    end
                end
            end end
        end end
    end

    if isnothing(found)
        @floop ex for letter in letters if isnothing(found)
            local_str = fill('\0',4)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters if isnothing(found)
                    local_str[3] = letter
                    for letter in letters
                        local_str[4] = letter
                        hash2 = md5(String(local_str))
                        if hash1 == hash2
                            lock(lk) do
                                found = String(local_str)
                            end
                            break
                        end
                    end
                end end
            end end
        end end
    end

    if isnothing(found)
        @floop ex for letter in letters if isnothing(found)
            local_str = fill('\0',5)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters if isnothing(found)
                    local_str[3] = letter
                    for letter in letters if isnothing(found)
                        local_str[4] = letter
                        for letter in letters
                            local_str[5] = letter
                            hash2 = md5(String(local_str))
                            if hash1 == hash2
                                lock(lk) do
                                    found = String(local_str)
                                end
                                break
                            end
                        end
                    end end
                end end
            end end
        end end
    end

    if isnothing(found)
        @floop ex for letter in letters if isnothing(found)
            local_str = fill('\0',6)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters if isnothing(found)
                    local_str[3] = letter
                    for letter in letters if isnothing(found)
                        local_str[4] = letter
                        for letter in letters if isnothing(found)
                            local_str[5] = letter
                            for letter in letters
                                local_str[6] = letter
                                hash2 = md5(String(local_str))
                                if hash1 == hash2
                                    lock(lk) do
                                        found = String(local_str)
                                    end
                                    break
                                end
                            end
                        end end
                    end end
                end end
            end end
        end end
    end

    if isnothing(found)
        @floop ex for letter in letters if isnothing(found)
            local_str = fill('\0',7)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters if isnothing(found)
                    local_str[3] = letter
                    for letter in letters if isnothing(found)
                        local_str[4] = letter
                        for letter in letters if isnothing(found)
                            local_str[5] = letter
                            for letter in letters if isnothing(found)
                                local_str[6] = letter
                                for letter in letters
                                    local_str[7] = letter
                                    hash2 = md5(String(local_str))
                                    if hash1 == hash2
                                        lock(lk) do
                                            found = String(local_str)
                                        end
                                        break
                                    end
                                end
                            end end
                        end end
                    end end
                end end
            end end
        end end
    end

    if isnothing(found)
        @floop ex for letter in letters if isnothing(found)
            local_str = fill('\0',8)
            local_str[1] = letter
            for letter in letters if isnothing(found)
                local_str[2] = letter
                for letter in letters if isnothing(found)
                    local_str[3] = letter
                    for letter in letters if isnothing(found)
                        local_str[4] = letter
                        for letter in letters if isnothing(found)
                            local_str[5] = letter
                            for letter in letters if isnothing(found)
                                local_str[6] = letter
                                for letter in letters if isnothing(found)
                                    local_str[7] = letter
                                    for letter in letters
                                        local_str[8] = letter
                                        hash2 = md5(String(local_str))
                                        if hash1 == hash2
                                            lock(lk) do
                                                found = String(local_str)
                                            end
                                            break
                                        end
                                    end
                                end end
                            end end
                        end end
                    end end
                end end
            end end
        end end
    end
    return found
end

function debug_brute_force_floop(
        hash1::Vector{UInt8}; ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing,
        loop_tasks::Union{Vector{Vector{Vector{Int64}}},Nothing}=nothing,
        suite::Union{Dict{String,NamedTuple},Nothing}
    )
    lk = ReentrantLock()
    found = nothing
    suite["loop_1"] = @timed begin
        @floop ex for letter in letters if isnothing(found)
            push!(loop_tasks[1][threadid()], Int(letter))
            local_str = fill('\0',1)
            local_str[1] = letter
            hash2 = md5(String(local_str))
            if hash1 == hash2
                lock(lk) do
                    found = String(local_str)
                end
                break
            end
        end end
    end

    suite["loop_2"] = @timed begin
        if isnothing(found)
            @floop ex for letter in letters if isnothing(found)
                push!(loop_tasks[2][threadid()], Int(letter))
                local_str = fill('\0',2)
                local_str[1] = letter
                for letter in letters
                    local_str[2] = letter
                    hash2 = md5(String(local_str))
                    if hash1 == hash2
                        lock(lk) do
                            found = String(local_str)
                        end
                        break
                    end
                end
            end end   
        end
    end

    suite["loop_3"] = @timed begin
        if isnothing(found)
            @floop ex for letter in letters if isnothing(found)
                push!(loop_tasks[3][threadid()], Int(letter))
                local_str = fill('\0',3)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters
                        local_str[3] = letter
                        hash2 = md5(String(local_str))
                        if hash1 == hash2
                            lock(lk) do
                                found = String(local_str)
                            end
                            break
                        end
                    end
                end end
            end end
        end
    end

    suite["loop_4"] = @timed begin
        if isnothing(found)
            @floop ex for letter in letters if isnothing(found)
                push!(loop_tasks[4][threadid()], Int(letter))
                local_str = fill('\0',4)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters
                            local_str[4] = letter
                            hash2 = md5(String(local_str))
                            if hash1 == hash2
                                lock(lk) do
                                    found = String(local_str)
                                end
                                break
                            end
                        end
                    end end
                end end
            end end
        end
    end

    suite["loop_5"] = @timed begin
        if isnothing(found)
            @floop ex for letter in letters if isnothing(found)
                push!(loop_tasks[5][threadid()], Int(letter))
                local_str = fill('\0',5)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters
                                local_str[5] = letter
                                hash2 = md5(String(local_str))
                                if hash1 == hash2
                                    lock(lk) do
                                        found = String(local_str)
                                    end
                                    break
                                end
                            end
                        end end
                    end end
                end end
            end end
        end
    end

    suite["loop_6"] = @timed begin
        if isnothing(found)
            @floop ex for letter in letters if isnothing(found)
                push!(loop_tasks[6][threadid()], Int(letter))
                local_str = fill('\0',6)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters if isnothing(found)
                                local_str[5] = letter
                                for letter in letters
                                    local_str[6] = letter
                                    hash2 = md5(String(local_str))
                                    if hash1 == hash2
                                        lock(lk) do
                                            found = String(local_str)
                                        end
                                        break
                                    end
                                end
                            end end
                        end end
                    end end
                end end
            end end
        end
    end

    suite["loop_7"] = @timed begin
        if isnothing(found)
            @floop ex for letter in letters if isnothing(found)
                push!(loop_tasks[7][threadid()], Int(letter))
                local_str = fill('\0',7)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters if isnothing(found)
                                local_str[5] = letter
                                for letter in letters if isnothing(found)
                                    local_str[6] = letter
                                    for letter in letters
                                        local_str[7] = letter
                                        hash2 = md5(String(local_str))
                                        if hash1 == hash2
                                            lock(lk) do
                                                found = String(local_str)
                                            end
                                            break
                                        end
                                    end
                                end end
                            end end
                        end end
                    end end
                end end
            end end
        end
    end

    suite["loop_8"] = @timed begin
        if isnothing(found)
            @floop ex for letter in letters if isnothing(found)
                push!(loop_tasks[8][threadid()], Int(letter))
                local_str = fill('\0',8)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters if isnothing(found)
                                local_str[5] = letter
                                for letter in letters if isnothing(found)
                                    local_str[6] = letter
                                    for letter in letters if isnothing(found)
                                        local_str[7] = letter
                                        for letter in letters
                                            local_str[8] = letter
                                            hash2 = md5(String(local_str))
                                            if hash1 == hash2
                                                lock(lk) do
                                                    found = String(local_str)
                                                end
                                                break
                                            end
                                        end
                                    end end
                                end end
                            end end
                        end end
                    end end
                end end
            end end
        end
    end
    return found
end

function debug_brute_force_threads(
        hash1::Vector{UInt8}; ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing,
        loop_tasks::Union{Vector{Vector{Vector{Int64}}},Nothing}=nothing,
        suite::Union{Dict{String,NamedTuple},Nothing}
    )
    lk = ReentrantLock()
    found = nothing
    suite["loop_1"] = @timed begin
        @threads for letter in letters if isnothing(found)
            push!(loop_tasks[1][threadid()], Int(letter))
            local_str = fill('\0',1)
            local_str[1] = letter
            hash2 = md5(String(local_str))
            if hash1 == hash2
                lock(lk) do
                    found = String(local_str)
                end
                break
            end
        end end
    end

    suite["loop_2"] = @timed begin
        if isnothing(found)
            @threads for letter in letters if isnothing(found)
                push!(loop_tasks[2][threadid()], Int(letter))
                local_str = fill('\0',2)
                local_str[1] = letter
                for letter in letters
                    local_str[2] = letter
                    hash2 = md5(String(local_str))
                    if hash1 == hash2
                        lock(lk) do
                            found = String(local_str)
                        end
                        break
                    end
                end
            end end   
        end
    end

    suite["loop_3"] = @timed begin
        if isnothing(found)
            @threads for letter in letters if isnothing(found)
                push!(loop_tasks[3][threadid()], Int(letter))
                local_str = fill('\0',3)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters
                        local_str[3] = letter
                        hash2 = md5(String(local_str))
                        if hash1 == hash2
                            lock(lk) do
                                found = String(local_str)
                            end
                            break
                        end
                    end
                end end
            end end
        end
    end

    suite["loop_4"] = @timed begin
        if isnothing(found)
            @threads for letter in letters if isnothing(found)
                push!(loop_tasks[4][threadid()], Int(letter))
                local_str = fill('\0',4)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters
                            local_str[4] = letter
                            hash2 = md5(String(local_str))
                            if hash1 == hash2
                                lock(lk) do
                                    found = String(local_str)
                                end
                                break
                            end
                        end
                    end end
                end end
            end end
        end
    end

    suite["loop_5"] = @timed begin
        if isnothing(found)
            @threads for letter in letters if isnothing(found)
                push!(loop_tasks[5][threadid()], Int(letter))
                local_str = fill('\0',5)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters
                                local_str[5] = letter
                                hash2 = md5(String(local_str))
                                if hash1 == hash2
                                    lock(lk) do
                                        found = String(local_str)
                                    end
                                    break
                                end
                            end
                        end end
                    end end
                end end
            end end
        end
    end

    suite["loop_6"] = @timed begin
        if isnothing(found)
            @threads for letter in letters if isnothing(found)
                push!(loop_tasks[6][threadid()], Int(letter))
                local_str = fill('\0',6)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters if isnothing(found)
                                local_str[5] = letter
                                for letter in letters
                                    local_str[6] = letter
                                    hash2 = md5(String(local_str))
                                    if hash1 == hash2
                                        lock(lk) do
                                            found = String(local_str)
                                        end
                                        break
                                    end
                                end
                            end end
                        end end
                    end end
                end end
            end end
        end
    end

    suite["loop_7"] = @timed begin
        if isnothing(found)
            @threads for letter in letters if isnothing(found)
                push!(loop_tasks[7][threadid()], Int(letter))
                local_str = fill('\0',7)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters if isnothing(found)
                                local_str[5] = letter
                                for letter in letters if isnothing(found)
                                    local_str[6] = letter
                                    for letter in letters
                                        local_str[7] = letter
                                        hash2 = md5(String(local_str))
                                        if hash1 == hash2
                                            lock(lk) do
                                                found = String(local_str)
                                            end
                                            break
                                        end
                                    end
                                end end
                            end end
                        end end
                    end end
                end end
            end end
        end
    end

    suite["loop_8"] = @timed begin
        if isnothing(found)
            @threads for letter in letters if isnothing(found)
                push!(loop_tasks[8][threadid()], Int(letter))
                local_str = fill('\0',8)
                local_str[1] = letter
                for letter in letters if isnothing(found)
                    local_str[2] = letter
                    for letter in letters if isnothing(found)
                        local_str[3] = letter
                        for letter in letters if isnothing(found)
                            local_str[4] = letter
                            for letter in letters if isnothing(found)
                                local_str[5] = letter
                                for letter in letters if isnothing(found)
                                    local_str[6] = letter
                                    for letter in letters if isnothing(found)
                                        local_str[7] = letter
                                        for letter in letters
                                            local_str[8] = letter
                                            hash2 = md5(String(local_str))
                                            if hash1 == hash2
                                                lock(lk) do
                                                    found = String(local_str)
                                                end
                                                break
                                            end
                                        end
                                    end end
                                end end
                            end end
                        end end
                    end end
                end end
            end end
        end
    end
    return found
end

function crack_password(hash1_str::String)
    hash1 = hex2bytes(hash1_str)
    str = []
    found =  false
    for i in 2:8
        str = fill('\0',i)
        if brute_force(hash1, str, 1, i)
            found = true
            break
        end
    end
    if found
        return String(str)
    end
end

function crack_password_parallel(kwargs::NamedTuple{T}) where T
    hash1 = hex2bytes(kwargs.hash1_str)
    return brute_force_parallel(hash1, kwargs.ex)
end

function debug_crack_password(
        f::T, hash1_str::String;
        ex::Union{FoldsThreads.FoldsBase.Executor,Nothing}=nothing, 
        check_sequential::Union{Bool,Nothing}=nothing
    ) where T
    loop_tasks = [[Int64[] for _ in 1:nthreads()] for _ in 1:8]
    suite = Dict{String,NamedTuple}()
    hash1 = hex2bytes(hash1_str)
    suite["app"] = @timed f(hash1, ex=ex, loop_tasks=loop_tasks, suite=suite)
    correct_results = nothing
    if !isnothing(check_sequential) && check_sequential
        correct_results = brute_force(hash1) == suite["app"].value
    end
    return BenchmarkSample(loop_tasks, suite, correct_results)
end