using MD5

const MAX = 10

letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

function brute_force(hash1, str, i, n)
    global letters
    if i == n + 1
        hash2 = md5(String(str))
        @show String(str)
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

# hash1_str = "be5d75fa67ef370e98b3d3611c318156"

function crack_password(hash1_str::String)
    hash1 = hex2bytes(hash1_str)
    str = []
    for i in 2:8
        str = fill('\0',i)
        if brute_force(hash1, str, 1, i)
            break
        end
    end
    return String(str)
end