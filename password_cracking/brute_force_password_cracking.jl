using MD5
using FoldsThreads
using FLoops
using Base.Threads

const MAX = 10

letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

thread_tasks = [String[] for _ in 1:nthreads()]
pw = ""

function brute_force(hash1, str, i, n)
    global letters
    if i == n + 1
        hash2 = md5(String(str))
        # @show String(str)
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

# works in parallel but doesnt seem to interrupt
# flow when result is found
# function brute_force_parallel(hash1, str, i, n)
#     global letters, thread_tasks, pw
#     push!(thread_tasks[threadid()], String(str))
#     if i == n + 1
#         hash2 = md5(String(str))
#         # @show String(str)
#         if hash1 == hash2
#             @show String(str)
#         end
#         return hash1 == hash2
#     end
#     @floop DepthFirstEx(basesize = div(length(letters),4)) for letter in letters 
#         new_str = str
#         new_str[i] = letter 
#         if brute_force_parallel(hash1, new_str, i + 1, n)
#             return true
#         end
#     end
#     return false
# end

# hash1_str = "be5d75fa67ef370e98b3d3611c318156"

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

function crack_password_parallel(hash1_str::String)
    hash1 = hex2bytes(hash1_str)
    str = []
    for i in 2:3
        str = fill('\0',i)
        if brute_force_parallel(hash1)
            break
        end
    end
end


function brute_force_parallel(hash1)
    lk = ReentrantLock()
    found = nothing
    @floop DepthFirstEx(basesize = div(length(letters),4)) for letter in letters if isnothing(found)
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
        @floop DepthFirstEx(basesize = div(length(letters),4)) for letter in letters if isnothing(found)
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
        @floop DepthFirstEx(basesize = div(length(letters),4)) for letter in letters if isnothing(found)
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
        @floop DepthFirstEx(basesize = div(length(letters),4)) for letter in letters if isnothing(found)
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
        @floop DepthFirstEx(basesize = div(length(letters),4)) for letter in letters if isnothing(found)
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
        @floop DepthFirstEx(basesize = div(length(letters),4)) for letter in letters if isnothing(found)
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
        @floop DepthFirstEx(basesize = div(length(letters),4)) for letter in letters if isnothing(found)
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
        @floop DepthFirstEx(basesize = div(length(letters),4)) for letter in letters if isnothing(found)
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
