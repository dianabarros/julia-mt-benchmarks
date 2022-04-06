using MD5
using FoldsThreads
using FLoops
using Base.Threads
using BenchmarkTools

mutable struct BenchmarkResults
    loop_tasks::Vector{Vector{Vector{Int64}}}
    suite::BenchmarkGroup
end

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

function debug_brute_force_parallel(hash1::Vector{UInt8}, ex::FoldsThreads.FoldsBase.Executor, loop_tasks, suite)
    lk = ReentrantLock()
    found = nothing
    suite["loop_1"] = @benchmarkable begin
        @floop $ex for letter in $letters if isnothing($found)
            local_str = fill('\0',1)
            local_str[1] = letter
            hash2 = md5(String(local_str))
            if $hash1 == hash2
                lock($lk) do
                    $found = String(local_str)
                end
                break
            end
        end end
    end

    suite["loop_2"] = @benchmarkable begin
        if isnothing($found)
            @floop $ex for letter in $letters if isnothing($found)
                local_str = fill('\0',2)
                local_str[1] = letter
                for letter in $letters
                    local_str[2] = letter
                    hash2 = md5(String(local_str))
                    if $hash1 == hash2
                        lock($lk) do
                            $found = String(local_str)
                        end
                        break
                    end
                end
            end end   
        end
    end

    suite["loop_3"] = @benchmarkable begin
        if isnothing($found)
            @floop $ex for letter in $letters if isnothing($found)
                local_str = fill('\0',3)
                local_str[1] = letter
                for letter in $letters if isnothing($found)
                    local_str[2] = letter
                    for letter in $letters
                        local_str[3] = letter
                        hash2 = md5(String(local_str))
                        if $hash1 == hash2
                            lock($lk) do
                                $found = String(local_str)
                            end
                            break
                        end
                    end
                end end
            end end
        end
    end

    suite["loop_4"] = @benchmarkable begin
        if isnothing($found)
            @floop $ex for letter in $letters if isnothing($found)
                local_str = fill('\0',4)
                local_str[1] = letter
                for letter in $letters if isnothing($found)
                    local_str[2] = letter
                    for letter in $letters if isnothing($found)
                        local_str[3] = letter
                        for letter in $letters
                            local_str[4] = letter
                            hash2 = md5(String(local_str))
                            if $hash1 == hash2
                                lock($lk) do
                                    $found = String(local_str)
                                end
                                break
                            end
                        end
                    end end
                end end
            end end
        end
    end

    suite["loop_5"] = @benchmarkable begin
        if isnothing($found)
            @floop $ex for letter in $letters if isnothing($found)
                local_str = fill('\0',5)
                local_str[1] = letter
                for letter in $letters if isnothing($found)
                    local_str[2] = letter
                    for letter in $letters if isnothing($found)
                        local_str[3] = letter
                        for letter in $letters if isnothing($found)
                            local_str[4] = letter
                            for letter in $letters
                                local_str[5] = letter
                                hash2 = md5(String(local_str))
                                if $hash1 == hash2
                                    lock($lk) do
                                        $found = String(local_str)
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

    suite["loop_6"] = @benchmarkable begin
        if isnothing($found)
            @floop $ex for letter in $letters if isnothing($found)
                local_str = fill('\0',6)
                local_str[1] = letter
                for letter in $letters if isnothing($found)
                    local_str[2] = letter
                    for letter in $letters if isnothing($found)
                        local_str[3] = letter
                        for letter in $letters if isnothing($found)
                            local_str[4] = letter
                            for letter in $letters if isnothing($found)
                                local_str[5] = letter
                                for letter in $letters
                                    local_str[6] = letter
                                    hash2 = md5(String(local_str))
                                    if $hash1 == hash2
                                        lock($lk) do
                                            $found = String(local_str)
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

    suite["loop_7"] = @benchmarkable begin
        if isnothing($found)
            @floop $ex for letter in $letters if isnothing($found)
                local_str = fill('\0',7)
                local_str[1] = letter
                for letter in $letters if isnothing($found)
                    local_str[2] = letter
                    for letter in $letters if isnothing($found)
                        local_str[3] = letter
                        for letter in $letters if isnothing($found)
                            local_str[4] = letter
                            for letter in $letters if isnothing($found)
                                local_str[5] = letter
                                for letter in $letters if isnothing($found)
                                    local_str[6] = letter
                                    for letter in $letters
                                        local_str[7] = letter
                                        hash2 = md5(String(local_str))
                                        if $hash1 == hash2
                                            lock($lk) do
                                                $found = String(local_str)
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

    suite["loop_8"] = @benchmarkable begin
        if isnothing($found)
            @floop $ex for letter in $letters if isnothing($found)
                local_str = fill('\0',8)
                local_str[1] = letter
                for letter in $letters if isnothing($found)
                    local_str[2] = letter
                    for letter in $letters if isnothing($found)
                        local_str[3] = letter
                        for letter in $letters if isnothing($found)
                            local_str[4] = letter
                            for letter in $letters if isnothing($found)
                                local_str[5] = letter
                                for letter in $letters if isnothing($found)
                                    local_str[6] = letter
                                    for letter in $letters if isnothing($found)
                                        local_str[7] = letter
                                        for letter in $letters
                                            local_str[8] = letter
                                            hash2 = md5(String(local_str))
                                            if $hash1 == hash2
                                                lock($lk) do
                                                    $found = String(local_str)
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

function debug_crack_password_parallel(kwargs::NamedTuple{T}) where T
    loop_tasks = [[Int64[] for _ in 1:nthreads()] for _ in 1:8]
    suite = BenchmarkGroup()
    hash1 = hex2bytes(kwargs.hash1_str)
    debug_brute_force_parallel(hash1, kwargs.ex, loop_tasks, suite)
    tune!(suite)
    return BenchmarkResults(loop_tasks, suite)
end