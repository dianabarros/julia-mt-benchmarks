using Pkg
Pkg.activate("../../password_cracking")

using MD5

letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890"

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

hash1 = hex2bytes(ARGS[1])
brute_force(hash1)