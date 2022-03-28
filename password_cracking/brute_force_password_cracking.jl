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
function brute_force_parallel(hash1, str, i, n)
    global letters, thread_tasks, pw
    push!(thread_tasks[threadid()], String(str))
    if i == n + 1
        hash2 = md5(String(str))
        # @show String(str)
        if hash1 == hash2
            @show String(str)
        end
        return hash1 == hash2
    end
    @floop DepthFirstEx() for letter in letters 
        new_str = str
        new_str[i] = letter 
        if brute_force_parallel(hash1, new_str, i + 1, n)
            return true
        end
    end
    return false
end

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
    found = false
    for i in 2:3
        str = fill('\0',i)
        if brute_force_parallel(hash1, str, 1, i)
            found = true
            break
        end
    end
    if found
        # doesnt work for parallel
        return String(str)
    end
end