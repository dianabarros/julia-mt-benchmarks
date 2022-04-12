c_remainder_lookup = [0x80, 0x40, 0x20, 0x10, 0x08, 0x04, 0x02, 0x01]


function BYTE_TO_BINARY(byte) 
    (byte & 0x80 != 0 ? '1' : '0'),
    (byte & 0x40 != 0 ? '1' : '0') ,
    (byte & 0x20 != 0 ? '1' : '0') ,
    (byte & 0x10 != 0 ? '1' : '0') ,
    (byte & 0x08 != 0 ? '1' : '0') ,
    (byte & 0x04 != 0 ? '1' : '0') ,
    (byte & 0x02 != 0 ? '1' : '0') ,
    (byte & 0x01 != 0 ? '1' : '0') 
end

function read_file()
    graph = UInt8[]
    nNodes = undef
    bytes_per_row = undef
    graph = undef
    for line in eachline(stdin)
        tokens = split(line, ' ')
        if tokens[1] == "p"
            nNodes = parse(Int, tokens[3])
            bytes_per_row = div((nNodes + 7), 8)
            graph = Vector{UInt8}(undef, nNodes*bytes_per_row)
            # @show bytes_per_row
        elseif tokens[1] == "a"
            r = parse(Int, tokens[2])
            c = parse(Int, tokens[3])
            c_int_div = div(c, 8)
            # @show r, c, c_int_div
            # @show bytes_per_row*r + c_int_div
            graph[bytes_per_row*r + c_int_div] = graph[bytes_per_row*r + c_int_div] | c_remainder_lookup[c%8]
        end
    end
    return nNodes, bytes_per_row, graph
end

function write_graph(nNodes, bytes_per_row, graph)
    for r in 0:nNodes-1
        for j in 0:bytes_per_row-1
            print(BYTE_TO_BINARY(graph[r * bytes_per_row + (j+1)]))
        end
        println()
    end
end

function warshall!(nNodes, bytes_per_row, graph)
    for c in 0:nNodes-1
        c_int_div = div(c,8)
        column_bit = c_remainder_lookup[c%8+1]
        # pragma omp parallel for private(r, j) shared(graph, c, c_int_div, column_bit, nNodes, bytes_per_row)
        for r in 0:nNodes-1
            if (r != c && (graph[r * bytes_per_row + c_int_div+1]&column_bit != 0))
                for j in 0:bytes_per_row-1
                    graph[r * bytes_per_row + (j+1)] = graph[r * bytes_per_row + (j+1)] | graph[c * bytes_per_row + (j+1)]
                end
            end
        end
    end
end


nNodes, bytes_per_row, graph = read_file()
println("Input:")
write_graph(nNodes, bytes_per_row, graph)
warshall!(nNodes, bytes_per_row, graph)
println("Output:")
write_graph(nNodes, bytes_per_row, graph)